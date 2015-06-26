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

#ifndef CORSIX_TH_TH_H_
#define CORSIX_TH_TH_H_
#include "config.h"

//! Generic linked list class (for inheriting from)
struct THLinkList
{
    THLinkList() ;
    ~THLinkList();

    THLinkList* m_pPrev;
    THLinkList* m_pNext;

    void removeFromList();
    int getDrawingLayer() {return m_drawingLayer;}
    void setDrawingLayer(int layer) {m_drawingLayer = layer;}

    int m_drawingLayer;
};

//! Theme Hospital localised string list
class THStringList
{
public:
    THStringList();
    ~THStringList();

    bool loadFromTHFile(const uint8_t* pData, size_t iDataLength);

    //! Get the number of sections in the string list
    size_t getSectionCount();

    //! Get the number of strings in a section of the string list
    size_t getSectionSize(size_t iSection);

    //! Get a string from the string list
    /*!
        @param iSection Section index in range [0, getSectionCount() - 1]
        @param iIndex String index in range [0, getSectionSize(iSection) - 1]
        @return NULL if the index is invalid, otherwise a UTF-8 encoded string.
    */
    const char* getString(size_t iSection, size_t iIndex);

protected:
    struct section_t
    {
        //! Size of pStrings array
        size_t iSize;
        //! Array of string pointers (into THStringList::m_sData)
        const char** pStrings;
    };

    //! Size of m_pSections array
    size_t m_iSectionCount;
    //! Section information
    section_t* m_pSections;
    //! Memory block containing all the actual strings
    uint8_t* m_sData;
};

#endif // CORSIX_TH_TH_H_
