/*
Copyright (c) 2009 Peter "Corsix" Cawley

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

#include "config.h"
#include "th.h"
#include <string.h>
#include <memory.h>
#include <new>

THLinkList::THLinkList()
{
    m_pPrev = NULL;
    m_pNext = NULL;
}

THLinkList::~THLinkList()
{
    removeFromList();
}

void THLinkList::removeFromList()
{
    if(m_pPrev != NULL)
    {
        m_pPrev->m_pNext = m_pNext;
    }
    if(m_pNext != NULL)
    {
        m_pNext->m_pPrev = m_pPrev;
        m_pNext = NULL;
    }
    m_pPrev = NULL;
}

THStringList::THStringList()
{
    m_iSectionCount = 0;
    m_pSections = NULL;
    m_sData = NULL;
}

THStringList::~THStringList()
{
    for(unsigned int i = 0; i < m_iSectionCount; ++i)
        delete[] m_pSections[i].pStrings;
    delete[] m_pSections;
    delete[] m_sData;
}

#include "cp437_table.h"
#include "cp936_table.h"

static void utf8encode(unsigned char*& sOut, uint32_t iCodepoint)
{
    if(iCodepoint <= 0x7F)
    {
        *sOut = static_cast<char>(iCodepoint);
        ++sOut;
    }
    else if(iCodepoint <= 0x7FF)
    {
        unsigned char cSextet = iCodepoint & 0x3F;
        iCodepoint >>= 6;
        sOut[0] = 0xC0 + iCodepoint;
        sOut[1] = 0x80 + cSextet;
        sOut += 2;
    }
    else if(iCodepoint <= 0xFFFF)
    {
        unsigned char cSextet2 = iCodepoint & 0x3F;
        iCodepoint >>= 6;
        unsigned char cSextet1 = iCodepoint & 0x3F;
        iCodepoint >>= 6;
        sOut[0] = 0xE0 + iCodepoint;
        sOut[1] = 0x80 + cSextet1;
        sOut[2] = 0x80 + cSextet2;
        sOut += 3;
    }
    else
    {
        unsigned char cSextet3 = iCodepoint & 0x3F;
        iCodepoint >>= 6;
        unsigned char cSextet2 = iCodepoint & 0x3F;
        iCodepoint >>= 6;
        unsigned char cSextet1 = iCodepoint & 0x3F;
        iCodepoint >>= 6;
        sOut[0] = 0xF0 + iCodepoint;
        sOut[1] = 0x80 + cSextet1;
        sOut[2] = 0x80 + cSextet2;
        sOut[3] = 0x80 + cSextet3;
        sOut += 4;
    }
}

static void CopyStringId(const unsigned char*& sIn, unsigned char*& sOut)
{
    size_t iLength = strlen(reinterpret_cast<const char*>(sIn)) + 1;
    memcpy(sOut, sIn, iLength);
    sIn += iLength;
    sOut += iLength;
}

static void CopyStringCP437(const unsigned char*& sIn, unsigned char*& sOut)
{
    unsigned char cChar;
    do
    {
        cChar = *sIn;
        ++sIn;
        if(cChar < 0x80)
        {
            *sOut = cChar;
            ++sOut;
        }
        else
        {
            utf8encode(sOut, g_aCP437toUnicode[cChar - 0x80]);
        }
    } while(cChar != 0);
}

static void CopyStringCP936(const unsigned char*& sIn, unsigned char*& sOut)
{
    unsigned char cChar1, cChar2;
    do
    {
        cChar1 = *sIn;
        ++sIn;
        if(cChar1 < 0x81 || cChar1 == 0xFF)
        {
            *sOut = cChar1;
            ++sOut;
        }
        else
        {
            cChar2 = *sIn;
            ++sIn;
            if(0x40 <= cChar2 && cChar2 <= 0xFE)
            {
                utf8encode(sOut, g_aCP936toUnicode[cChar1-0x81][cChar2-0x40]);
                // The Theme Hospital string tables seem to like following a
                // multibyte character with a superfluous space.
                cChar2 = *sIn;
                if(cChar2 == ' ')
                    ++sIn;
            }
            else
            {
                *sOut = cChar1;
                ++sOut;
                *sOut = cChar2;
                ++sOut;
            }
        }
    } while(cChar1 != 0);
}

bool THStringList::loadFromTHFile(const unsigned char* pData, size_t iDataLength)
{
    for(unsigned int i = 0; i < m_iSectionCount; ++i)
        delete[] m_pSections[i].pStrings;
    delete[] m_pSections;
    delete[] m_sData;
    m_pSections = NULL;
    m_sData = NULL;
    m_iSectionCount = 0;

    if(iDataLength < 2)
        return false;

    unsigned int iSectionCount = *reinterpret_cast<const uint16_t*>(pData);
    unsigned int iHeaderLength = (iSectionCount + 1) * 2;

    if(iDataLength < iHeaderLength)
        return false;

    // Determine whether the encoding is CP437 or GB2312 (CP936).
    // The range of bytes 0xB0 through 0xDF are box drawing characters in CP437
    // which shouldn't occur much (if ever) in TH strings, whereas they are
    // commonly used in GB2312 encoding.
    const unsigned char *sStringData = pData + iHeaderLength;
    size_t iStringDataLength = iDataLength - iHeaderLength;
    size_t iBCDCount = 0;
    for(size_t i = 0; i < iStringDataLength; ++i)
    {
        if(0xB0 <= sStringData[i] && sStringData[i] <= 0xDF)
            ++iBCDCount;
    }
    void (*fnCopyString)(const unsigned char*&, unsigned char*&);
    if(iBCDCount * 10 >= iStringDataLength)
        fnCopyString = CopyStringCP936;
    else
        fnCopyString = CopyStringCP437;

    m_sData = new (std::nothrow) unsigned char[iStringDataLength * 2 + 2];
    if(m_sData == NULL)
        return false;

    unsigned char *sDataOut = m_sData;
    const unsigned char *sDataEnd = sStringData + iStringDataLength;

    m_iSectionCount = iSectionCount;
    m_pSections = new section_t[iSectionCount];
    for(unsigned int i = 0; i < iSectionCount; ++i)
    {
        m_pSections[i].iSize = reinterpret_cast<const uint16_t*>(pData)[i + 1];
        m_pSections[i].pStrings = new const char*[m_pSections[i].iSize];

        for(unsigned int j = 0; j < m_pSections[i].iSize; ++j)
        {
            m_pSections[i].pStrings[j] = reinterpret_cast<char*>(sDataOut);
            if(sStringData != sDataEnd)
            {
                fnCopyString(sStringData, sDataOut);
            }
        }
    }
    *sDataOut = 0;

    return true;
}

unsigned int THStringList::getSectionCount()
{
    return m_iSectionCount;
}

unsigned int THStringList::getSectionSize(unsigned int iSection)
{
    return iSection < m_iSectionCount ? m_pSections[iSection].iSize : 0;
}

const char* THStringList::getString(unsigned int iSection, unsigned int iIndex)
{
    if(iSection < m_iSectionCount)
    {
        if(iIndex < m_pSections[iSection].iSize)
        {
            return m_pSections[iSection].pStrings[iIndex];
        }
    }
    return NULL;
}
