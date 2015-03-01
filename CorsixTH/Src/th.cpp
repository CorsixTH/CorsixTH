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
    m_drawingLayer = 0;
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
    for(size_t i = 0; i < m_iSectionCount; ++i)
        delete[] m_pSections[i].pStrings;
    delete[] m_pSections;
    delete[] m_sData;
}

#include "cp437_table.h"
#include "cp936_table.h"

static void utf8encode(uint8_t*& sOut, uint32_t iCodepoint)
{
    if(iCodepoint <= 0x7F)
    {
        *sOut = static_cast<char>(iCodepoint);
        ++sOut;
    }
    else if(iCodepoint <= 0x7FF)
    {
        uint8_t cSextet = iCodepoint & 0x3F;
        iCodepoint >>= 6;
        sOut[0] = static_cast<uint8_t>(0xC0 + iCodepoint);
        sOut[1] = static_cast<uint8_t>(0x80 + cSextet);
        sOut += 2;
    }
    else if(iCodepoint <= 0xFFFF)
    {
        uint8_t cSextet2 = iCodepoint & 0x3F;
        iCodepoint >>= 6;
        uint8_t cSextet1 = iCodepoint & 0x3F;
        iCodepoint >>= 6;
        sOut[0] = static_cast<uint8_t>(0xE0 + iCodepoint);
        sOut[1] = static_cast<uint8_t>(0x80 + cSextet1);
        sOut[2] = static_cast<uint8_t>(0x80 + cSextet2);
        sOut += 3;
    }
    else
    {
        uint8_t cSextet3 = iCodepoint & 0x3F;
        iCodepoint >>= 6;
        uint8_t cSextet2 = iCodepoint & 0x3F;
        iCodepoint >>= 6;
        uint8_t cSextet1 = iCodepoint & 0x3F;
        iCodepoint >>= 6;
        sOut[0] = static_cast<uint8_t>(0xF0 + iCodepoint);
        sOut[1] = static_cast<uint8_t>(0x80 + cSextet1);
        sOut[2] = static_cast<uint8_t>(0x80 + cSextet2);
        sOut[3] = static_cast<uint8_t>(0x80 + cSextet3);
        sOut += 4;
    }
}

static void CopyStringCP437(const uint8_t*& sIn, uint8_t*& sOut)
{
    uint8_t cChar;
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

static void CopyStringCP936(const uint8_t*& sIn, uint8_t*& sOut)
{
    uint8_t cChar1, cChar2;
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

bool THStringList::loadFromTHFile(const uint8_t* pData, size_t iDataLength)
{
    for(size_t i = 0; i < m_iSectionCount; ++i)
        delete[] m_pSections[i].pStrings;
    delete[] m_pSections;
    delete[] m_sData;
    m_pSections = NULL;
    m_sData = NULL;
    m_iSectionCount = 0;

    if(iDataLength < 2)
        return false;

    size_t iSectionCount = *reinterpret_cast<const uint16_t*>(pData);
    size_t iHeaderLength = (iSectionCount + 1) * 2;

    if(iDataLength < iHeaderLength)
        return false;

    // Determine whether the encoding is CP437 or GB2312 (CP936).
    // The range of bytes 0xB0 through 0xDF are box drawing characters in CP437
    // which shouldn't occur much (if ever) in TH strings, whereas they are
    // commonly used in GB2312 encoding.
    const uint8_t *sStringData = pData + iHeaderLength;
    size_t iStringDataLength = iDataLength - iHeaderLength;
    size_t iBCDCount = 0;
    for(size_t i = 0; i < iStringDataLength; ++i)
    {
        if(0xB0 <= sStringData[i] && sStringData[i] <= 0xDF)
            ++iBCDCount;
    }
    void (*fnCopyString)(const uint8_t*&, uint8_t*&);
    if(iBCDCount * 10 >= iStringDataLength)
        fnCopyString = CopyStringCP936;
    else
        fnCopyString = CopyStringCP437;

    m_sData = new (std::nothrow) uint8_t[iStringDataLength * 2 + 2];
    if(m_sData == NULL)
        return false;

    uint8_t *sDataOut = m_sData;
    const uint8_t *sDataEnd = sStringData + iStringDataLength;

    m_iSectionCount = iSectionCount;
    m_pSections = new section_t[iSectionCount];
    for(size_t i = 0; i < iSectionCount; ++i)
    {
        m_pSections[i].iSize = reinterpret_cast<const uint16_t*>(pData)[i + 1];
        m_pSections[i].pStrings = new const char*[m_pSections[i].iSize];

        for(size_t j = 0; j < m_pSections[i].iSize; ++j)
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

size_t THStringList::getSectionCount()
{
    return m_iSectionCount;
}

size_t THStringList::getSectionSize(size_t iSection)
{
    return iSection < m_iSectionCount ? m_pSections[iSection].iSize : 0;
}

const char* THStringList::getString(size_t iSection, size_t iIndex)
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
