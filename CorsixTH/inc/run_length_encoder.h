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

#ifndef CORSIX_TH_RLE_H_
#define CORSIX_TH_RLE_H_
#include "config.h"

class LuaPersistReader;
class LuaPersistWriter;

//! Encoder for reducing the amount of space to store a sequence of integers
/*!
    Designed primarily for reducing the amount of space taken up by persisting
    a THMap, this encoder transforms a sequence of integer records into a
    sequence of pairs, each pair having an integer object, and a repeat count.
    Terminology:
      * Integer - An unsigned integer (up to) 32 bits wide.
      * Record - One or more integers (for example, when encoding map nodes,
                 each record would be 6 integers if a map node had 6 fields).
      * Object - One or more records. Each object has an associated repeat
                 count.
*/
class IntegerRunLengthEncoder
{
public:
    IntegerRunLengthEncoder();
    ~IntegerRunLengthEncoder();

    //! (Re-)initialise the encoder
    /*!
        Prepares the encoder for accepting a sequence of records.

        \param iRecordSize The number of integers in a record.
    */
    bool initialise(size_t iRecordSize);

    //! Supply the next integer in the input sequence to the encoder
    void write(uint32_t iValue);

    //! Inform the encoder that the input sequence has finished
    /*!
        finish() must be called prior to getOutput() or pumpOutput().
        write() must not be called after finish() has been called.
    */
    void finish();

    uint32_t* getOutput(size_t *pCount) const;
    void pumpOutput(LuaPersistWriter *pWriter) const;

private:
    void _clean();

    //! Reduce the amount of data in the buffer
    /*!
        \param bAll If true, will reduce m_iBufferSizeUsed to zero.
                    If false, will reduce m_iBufferSizeUsed by some amount.
    */
    void _flush(bool bAll);

    bool _areRangesEqual(size_t iObjIdx1, size_t iObjIdx2, size_t iOffset, size_t iObjSize) const;
    bool _output(size_t iObjSize, size_t iObjCount);

    //! A circular fixed-size buffer holding the most recent input
    uint32_t* m_pBuffer;
    //! A variable-length array holding the output sequence
    uint32_t* m_pOutput;
    //! The number of integers in a record
    size_t m_iRecordSize;
    //! The maximum number of integers stored in the buffer
    size_t m_iBufferSize;
    //! The current number of integers stored in the buffer
    size_t m_iBufferSizeUsed;
    //! The index into m_pBuffer of the 1st integer
    size_t m_iBufferOffset;
    //! The maximum number of integers storable in the output (before the
    //! output array has to be resized).
    size_t m_iOutputSize;
    //! The current number of integers stored in the output
    size_t m_iOutputSizeUsed;
    //! The number of integers in the current object (multiple of record size)
    size_t m_iObjectSize;
    //! The number of copies of the current object already seen and removed
    //! from the buffer.
    size_t m_iObjectCount;
};

class IntegerRunLengthDecoder
{
public:
    IntegerRunLengthDecoder();
    ~IntegerRunLengthDecoder();

    bool initialise(size_t iRecordSize, LuaPersistReader *pReader);
    bool initialise(size_t iRecordSize, const uint32_t *pInput, size_t iCount);
    uint32_t read();
    bool isFinished() const;

private:
    void _clean();

    uint32_t* m_pBuffer;
    LuaPersistReader* m_pReader;
    const uint32_t* m_pInput;
    union
    {
        const uint32_t* m_pInputEnd;
        size_t m_iNumReadsRemaining;
    };
    size_t m_iRepeatCount;
    size_t m_iRecordSize;
    size_t m_iObjectIndex;
    size_t m_iObjectSize;
};

#endif // CORSIX_TH_RLE_H_
