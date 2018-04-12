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
#include <cstring>
#include <stdexcept>

link_list::link_list()
{
    drawing_layer = 0;
    prev = nullptr;
    next = nullptr;
}

link_list::~link_list()
{
    remove_from_list();
}

void link_list::remove_from_list()
{
    if(prev != nullptr)
    {
        prev->next = next;
    }
    if(next != nullptr)
    {
        next->prev = prev;
        next = nullptr;
    }
    prev = nullptr;
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
            utf8encode(sOut, cp437_to_unicode_table[cChar - 0x80]);
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
                utf8encode(sOut, cp936_to_unicode_table[cChar1-0x81][cChar2-0x40]);
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

th_string_list::th_string_list(const uint8_t* data, size_t length)
{
    if(length < 2)
        throw std::invalid_argument("length must be 2 or larger");

    size_t iSectionCount = *reinterpret_cast<const uint16_t*>(data);
    size_t iHeaderLength = (iSectionCount + 1) * 2;

    if(length < iHeaderLength)
        throw std::invalid_argument("iDataLength must be larger than the header");

    size_t iStringDataLength = length - iHeaderLength;
    const uint8_t *sStringData = data + iHeaderLength;
    const uint8_t *sDataEnd = sStringData + iStringDataLength;

    // Determine whether the encoding is CP437 or GB2312 (CP936).
    // The range of bytes 0xB0 through 0xDF are box drawing characters in CP437
    // which shouldn't occur much (if ever) in TH strings, whereas they are
    // commonly used in GB2312 encoding. We use 10% as a threshold.
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

    // String buffer sized to accept the largest possible reencoding of the
    // characters interpreted as CP936 or CP437 (2 bytes per character).
    string_buffer.resize(iStringDataLength * 2 + 2);

    uint8_t *sDataOut = string_buffer.data();
    sections.resize(iSectionCount);
    for(size_t i = 0; i < iSectionCount; ++i)
    {
        size_t section_size = reinterpret_cast<const uint16_t*>(data)[i + 1];
        sections[i].reserve(section_size);
        for(size_t j = 0; j < section_size; ++j)
        {
            sections[i].push_back(reinterpret_cast<char*>(sDataOut));
            if(sStringData != sDataEnd)
            {
                fnCopyString(sStringData, sDataOut);
            }
        }
    }
    // Terminate final string with nil character
    *sDataOut = 0;
}

th_string_list::~th_string_list()
{}

size_t th_string_list::get_section_count()
{
    return sections.size();
}

size_t th_string_list::get_section_size(size_t section)
{
    return section < sections.size() ? sections[section].size() : 0;
}

const char* th_string_list::get_string(size_t section, size_t index)
{
    if(index < get_section_size(section))
    {
        return sections[section][index];
    }
    return nullptr;
}
