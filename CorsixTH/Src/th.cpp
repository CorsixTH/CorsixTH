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

THLinkList::THLinkList()
{
    pPrev = NULL;
    pNext = NULL;
}

THLinkList::~THLinkList()
{
    removeFromList();
}

void THLinkList::removeFromList()
{
    if(pPrev != NULL)
    {
        pPrev->pNext = pNext;
    }
    if(pNext != NULL)
    {
        pNext->pPrev = pPrev;
        pNext = NULL;
    }
    pPrev = NULL;
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

    m_sData = new char[iDataLength - iHeaderLength + 2];
    memcpy(m_sData, pData + iHeaderLength, iDataLength - iHeaderLength);
    m_sData[iDataLength - iHeaderLength] = 0;
    m_sData[iDataLength - iHeaderLength + 1] = 0;
    const char *sData = m_sData;
    const char *sDataEnd = sData + iDataLength - iHeaderLength + 1;

    m_iSectionCount = iSectionCount;
    m_pSections = new section_t[iSectionCount];
    for(unsigned int i = 0; i < iSectionCount; ++i)
    {
        m_pSections[i].iSize = reinterpret_cast<const uint16_t*>(pData)[i + 1];
        m_pSections[i].pStrings = new const char*[m_pSections[i].iSize];

        for(unsigned int j = 0; j < m_pSections[i].iSize; ++j)
        {
            m_pSections[i].pStrings[j] = sData;
            if(sData != sDataEnd)
            {
                sData += strlen(sData) + 1;
            }
        }
    }

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
