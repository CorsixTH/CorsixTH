/*
Copyright (c) 2010 Peter "Corsix" Cawley

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#include "run_length_encoder.h"
#include "persist_lua.h"
#include <new>
#include <algorithm>

IntegerRunLengthEncoder::IntegerRunLengthEncoder()
{
    m_pBuffer = nullptr;
    m_pOutput = nullptr;
    _clean();
}

IntegerRunLengthEncoder::~IntegerRunLengthEncoder()
{
    _clean();
}

void IntegerRunLengthEncoder::_clean()
{
    delete[] m_pBuffer;
    delete[] m_pOutput;
    m_pBuffer = nullptr;
    m_pOutput = nullptr;
    m_iRecordSize = 0;
    m_iBufferSize = 0;
    m_iBufferSizeUsed = 0;
    m_iBufferOffset = 0;
    m_iOutputSize = 0;
    m_iOutputSizeUsed = 0;
    m_iObjectSize = 0;
    m_iObjectCount = 0;
}

bool IntegerRunLengthEncoder::initialise(size_t iRecordSize)
{
    _clean();
    m_iRecordSize = iRecordSize;

    // Buffer must hold at least 7 + 2 * 8 records, as the maximum object size
    // is 8 records, 2 of which are needed to detect a repeat, and 7 for the
    // offset at which the objects are found.
    m_iBufferSize = iRecordSize * 8 * 4;
    m_iBufferSizeUsed = 0;
    m_iBufferOffset = 0;
    m_pBuffer = new (std::nothrow) uint32_t[m_iBufferSize];
    if(!m_pBuffer)
        return false;

    m_iOutputSize = iRecordSize * 32;
    m_iOutputSizeUsed = 0;
    m_pOutput = new (std::nothrow) uint32_t[m_iOutputSize];
    if(!m_pOutput)
        return false;

    m_iObjectSize = 0;
    m_iObjectCount = 0;

    return true;
}

void IntegerRunLengthEncoder::write(uint32_t iValue)
{
    m_pBuffer[(m_iBufferOffset + m_iBufferSizeUsed) % m_iBufferSize] = iValue;
    if(++m_iBufferSizeUsed == m_iBufferSize)
        _flush(false);
}

void IntegerRunLengthEncoder::finish()
{
    if(m_iBufferSizeUsed != 0)
        _flush(true);
}

void IntegerRunLengthEncoder::_flush(bool bAll)
{
    do
    {
        if(m_iObjectSize == 0)
        {
            // Decide on the size of the next object
            // Want the object size which gives most object repeats, then for
            // two sizes with the same repeat count, the smaller size.
            size_t iBestRepeats = 0;
            size_t iBestSize = 0;
            size_t iBestOffset = 0;
            for(size_t iNumRecords = 1; iNumRecords <= 8; ++iNumRecords)
            {
                for(size_t iOffset = 0; iOffset < iNumRecords; ++iOffset)
                {
                    size_t iNumRepeats = 0;
                    size_t iObjSize = iNumRecords * m_iRecordSize;
                    while(iObjSize * (iOffset + iNumRepeats + 1) <= m_iBufferSizeUsed
                        && _areRangesEqual(0, iNumRepeats, iOffset, iObjSize))
                    {
                        ++iNumRepeats;
                    }
                    if(iNumRepeats > iBestRepeats
                    ||(iNumRepeats == iBestRepeats && iObjSize < iBestSize))
                    {
                        iBestRepeats = iNumRepeats;
                        iBestSize = iObjSize;
                        iBestOffset = iOffset;
                    }
                }
            }
            if(iBestRepeats == 1)
            {
                // No repeats were found, so the best we can do is output
                // a large non-repeating blob.
                _output(std::min(m_iBufferSizeUsed, 8 * m_iRecordSize), 1);
            }
            else
            {
                if(iBestOffset != 0)
                    _output(iBestOffset * m_iRecordSize, 1);
                // Mark the object as the current one, and remove all but the
                // last instance of it from the buffer. On the next flush, the
                // new data might continue the same object, hence why the
                // object isn't output just yet.
                m_iObjectSize = iBestSize;
                m_iObjectCount = iBestRepeats - 1;
                m_iBufferOffset = (m_iBufferOffset + m_iObjectSize * m_iObjectCount) % m_iBufferSize;
                m_iBufferSizeUsed -= m_iObjectSize * m_iObjectCount;
            }
        }
        else
        {
            // Try to match more of the current object
            while(m_iObjectSize * 2 <= m_iBufferSizeUsed &&
                  _areRangesEqual(0, 1, 0, m_iObjectSize))
            {
                ++m_iObjectCount;
                m_iBufferOffset = (m_iBufferOffset + m_iObjectSize) % m_iBufferSize;
                m_iBufferSizeUsed -= m_iObjectSize;
            }
            // Write data
            if(m_iObjectSize * 2 <= m_iBufferSizeUsed || bAll)
            {
                _output(m_iObjectSize, m_iObjectCount + 1);
                m_iObjectSize = 0;
                m_iObjectCount = 0;
            }
        }
    } while(bAll && m_iBufferSizeUsed != 0);
}

bool IntegerRunLengthEncoder::_areRangesEqual(size_t iObjIdx1, size_t iObjIdx2,
                                              size_t iOffset, size_t iObjSize) const
{
    iObjIdx1 = m_iBufferOffset + iOffset * m_iRecordSize + iObjIdx1 * iObjSize;
    iObjIdx2 = m_iBufferOffset + iOffset * m_iRecordSize + iObjIdx2 * iObjSize;
    for(size_t i = 0; i < iObjSize; ++i)
    {
        if(m_pBuffer[(iObjIdx1 + i) % m_iBufferSize]
        != m_pBuffer[(iObjIdx2 + i) % m_iBufferSize])
        {
            return false;
        }
    }
    return true;
}

bool IntegerRunLengthEncoder::_output(size_t iObjSize, size_t iObjCount)
{
    // Grow the output array if needed
    if(m_iOutputSize - m_iOutputSizeUsed <= iObjSize)
    {
        size_t iNewSize = (m_iOutputSize + iObjSize) * 2;
        uint32_t *pNewOutput = new (std::nothrow) uint32_t[iNewSize];
        if(!pNewOutput)
            return false;
#ifdef _MSC_VER
#pragma warning(disable: 4996)
#endif
        std::copy(m_pOutput, m_pOutput + m_iOutputSizeUsed, pNewOutput);
#ifdef _MSC_VER
#pragma warning(default: 4996)
#endif
        delete[] m_pOutput;
        m_pOutput = pNewOutput;
        m_iOutputSize = iNewSize;
    }
    size_t iHeader = (iObjSize / m_iRecordSize - 1) + 8 * (iObjCount - 1);
    m_pOutput[m_iOutputSizeUsed++] = static_cast<uint32_t>(iHeader);
    // Move the object from the buffer to the output
    for(size_t i = 0; i < iObjSize; ++i)
    {
        m_pOutput[m_iOutputSizeUsed++] = m_pBuffer[m_iBufferOffset];
        m_iBufferOffset = (m_iBufferOffset + 1) % m_iBufferSize;
    }
    m_iBufferSizeUsed -= iObjSize;
    return true;
}

uint32_t* IntegerRunLengthEncoder::getOutput(size_t *pCount) const
{
    if(pCount)
        *pCount = m_iOutputSizeUsed;
    return m_pOutput;
}

void IntegerRunLengthEncoder::pumpOutput(LuaPersistWriter *pWriter) const
{
    pWriter->writeVUInt(m_iOutputSizeUsed);
    for(size_t i = 0; i < m_iOutputSizeUsed; ++i)
    {
        pWriter->writeVUInt(m_pOutput[i]);
    }
}

IntegerRunLengthDecoder::IntegerRunLengthDecoder()
{
    m_pBuffer = nullptr;
    _clean();
}

IntegerRunLengthDecoder::~IntegerRunLengthDecoder()
{
    _clean();
}

void IntegerRunLengthDecoder::_clean()
{
    delete[] m_pBuffer;
    m_pBuffer = nullptr;
    m_pReader = nullptr;
    m_pInput = nullptr;
    m_pInputEnd = nullptr;
    m_iNumReadsRemaining = 0;
    m_iRepeatCount = 0;
    m_iRecordSize = 0;
    m_iObjectIndex = 0;
    m_iObjectSize = 0;
}

bool IntegerRunLengthDecoder::initialise(size_t iRecordSize, LuaPersistReader *pReader)
{
    _clean();

    m_pBuffer = new (std::nothrow) uint32_t[9 * iRecordSize];
    if(!m_pBuffer)
        return false;
    m_pReader = pReader;
    m_iRecordSize = iRecordSize;
    return pReader->readVUInt(m_iNumReadsRemaining);
}

bool IntegerRunLengthDecoder::initialise(size_t iRecordSize, const uint32_t *pInput, size_t iCount)
{
    _clean();

    m_pBuffer = new (std::nothrow) uint32_t[9 * iRecordSize];
    if(!m_pBuffer)
        return false;
    m_pInput = pInput;
    m_pInputEnd = pInput + iCount;
    m_iRecordSize = iRecordSize;
    return true;
}

uint32_t IntegerRunLengthDecoder::read()
{
    if(m_iRepeatCount == 0)
    {
        uint32_t iHeader = 0;
        if(m_pReader)
        {
            m_pReader->readVUInt(iHeader);
            --m_iNumReadsRemaining;
        }
        else
            iHeader = *(m_pInput++);
        m_iObjectSize = m_iRecordSize * (1 + (iHeader & 7));
        m_iRepeatCount = (iHeader / 8) + 1;
        if(m_pReader)
        {
            for(size_t i = 0; i < m_iObjectSize; ++i)
            {
                m_pReader->readVUInt(m_pBuffer[i]);
                --m_iNumReadsRemaining;
            }
        }
        else
        {
            for(size_t i = 0; i < m_iObjectSize; ++i)
                m_pBuffer[i] = *(m_pInput++);
        }
    }

    uint32_t iValue = m_pBuffer[m_iObjectIndex];
    if(++m_iObjectIndex == m_iObjectSize)
    {
        m_iObjectIndex = 0;
        --m_iRepeatCount;
    }
    return iValue;
}

bool IntegerRunLengthDecoder::isFinished() const
{
    if(m_pReader)
        return m_iNumReadsRemaining == 0 && m_iRepeatCount == 0;
    else
        return m_pInput == m_pInputEnd && m_iRepeatCount == 0;
}
