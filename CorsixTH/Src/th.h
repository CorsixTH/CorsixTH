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

struct THLinkList
{
    THLinkList();
    ~THLinkList();

    THLinkList* pPrev;
    THLinkList* pNext;

    void removeFromList();
};

class THStringList
{
public:
    THStringList();
    ~THStringList();

    bool loadFromTHFile(const unsigned char* pData, size_t iDataLength);

    unsigned int getSectionCount();
    unsigned int getSectionSize(unsigned int iSection);
    const char* getString(unsigned int iSection, unsigned int iIndex);

protected:
    struct section_t
    {
        unsigned int iSize;
        const char** pStrings;
    };

    unsigned int m_iSectionCount;
    section_t* m_pSections;
    char* m_sData;
};

#endif // CORSIX_TH_TH_H_
