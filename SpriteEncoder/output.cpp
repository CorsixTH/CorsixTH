/*
Copyright (c) 2013 Albert "Alberth" Hofkamp

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
#include <cstdio>
#include <cstdlib>
#include <cassert>
#include "output.h"

DataBlock::DataBlock()
{
    m_iUsed = 0;
    m_pNext = NULL;
}

bool DataBlock::Full()
{
    return m_iUsed == BUF_SIZE;
}

void DataBlock::Add(unsigned char byte)
{
    assert(m_iUsed < BUF_SIZE);
    buffer[m_iUsed++] = byte;
}

void DataBlock::Write(FILE *handle)
{
    if (fwrite(buffer, 1, m_iUsed, handle) != (size_t)m_iUsed)
    {
        fprintf(stderr, "Writing output failed!\n");
        exit(1);
    }
}

Output::Output()
{
    m_pFirst = NULL;
    m_pLast = NULL;
}

Output::~Output()
{
    DataBlock *pBlk = m_pFirst;
    while (pBlk != NULL)
    {
        DataBlock *pBlk2 = pBlk->m_pNext;
        delete pBlk;
        pBlk = pBlk2;
    }
}

void Output::Uint16(int iValue)
{
    Uint8(iValue & 0xFF);
    Uint8((iValue >> 8) & 0xFF);
}

void Output::Uint8(unsigned char byte)
{
    if (m_pLast == NULL || m_pLast->Full())
    {
        DataBlock *pBlk = new DataBlock();
        if (m_pLast == NULL)
        {
            m_pFirst = pBlk;
            m_pLast = pBlk;
        }
        else
        {
            m_pLast->m_pNext = pBlk;
            m_pLast = pBlk;
        }
    }
    m_pLast->Add(byte);
}

int Output::Reserve(int iSize)
{
    // Count current size.
    int iLength = 0;
    DataBlock *pBlk = m_pFirst;
    while (pBlk != NULL)
    {
        iLength += pBlk->m_iUsed;
        pBlk = pBlk->m_pNext;
    }

    // Add 'size' bytes as reserved space.
    for (int i = 0; i < iSize; i++)
    {
        Uint8(0);
    }
    return iLength;
}

void Output::Write(int iAddress, unsigned char iValue)
{
    int iOffset = 0;
    DataBlock *pBlk = m_pFirst;
    while (pBlk != NULL && iOffset + pBlk->m_iUsed < iAddress)
    {
        iOffset += pBlk->m_iUsed;
        pBlk = pBlk->m_pNext;
    }
    assert(pBlk != NULL);
    iAddress -= iOffset;
    assert(iAddress >= 0 && iAddress < BUF_SIZE);
    pBlk->buffer[iAddress] = iValue;
}

void Output::Write(const char *fname)
{
    FILE *handle = fopen(fname, "wb");
    DataBlock *pBlk = m_pFirst;
    while (pBlk != NULL)
    {
        pBlk->Write(handle);
        pBlk = pBlk->m_pNext;
    }
    fclose(handle);
}

// vim: et sw=4 ts=4 sts=4
