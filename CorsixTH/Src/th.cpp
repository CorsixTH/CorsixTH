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

#include "th.h"

#include "config.h"

#include <array>
#include <stdexcept>

#include "cp437_table.h"
#include "cp936_table.h"
#include "cpmik_table.h"

link_list::link_list() = default;

link_list::~link_list() { remove_from_list(); }

void link_list::remove_from_list() {
  if (prev != nullptr) {
    prev->next = next;
  }
  if (next != nullptr) {
    next->prev = prev;
    next = nullptr;
  }
  prev = nullptr;
}

namespace {

void utf8encode(uint8_t*& sOut, uint32_t iCodepoint) {
  if (iCodepoint <= 0x7F) {
    *sOut = static_cast<char>(iCodepoint);
    ++sOut;
  } else if (iCodepoint <= 0x7FF) {
    uint8_t cSextet = iCodepoint & 0x3F;
    iCodepoint >>= 6;
    sOut[0] = static_cast<uint8_t>(0xC0 + iCodepoint);
    sOut[1] = static_cast<uint8_t>(0x80 + cSextet);
    sOut += 2;
  } else if (iCodepoint <= 0xFFFF) {
    uint8_t cSextet2 = iCodepoint & 0x3F;
    iCodepoint >>= 6;
    uint8_t cSextet1 = iCodepoint & 0x3F;
    iCodepoint >>= 6;
    sOut[0] = static_cast<uint8_t>(0xE0 + iCodepoint);
    sOut[1] = static_cast<uint8_t>(0x80 + cSextet1);
    sOut[2] = static_cast<uint8_t>(0x80 + cSextet2);
    sOut += 3;
  } else {
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

void CopyStringCP437(const uint8_t*& sIn, uint8_t*& sOut) {
  uint8_t cChar;
  do {
    cChar = *sIn;
    ++sIn;
    if (cChar < 0x80) {
      *sOut = cChar;
      ++sOut;
    } else {
      utf8encode(sOut, cp437_to_unicode_table[cChar - 0x80]);
    }
  } while (cChar != 0);
}

void CopyStringMIK(const uint8_t*& sIn, uint8_t*& sOut) {
  uint8_t cChar;
  do {
    cChar = *sIn;
    ++sIn;
    if (cChar < 0x80) {
      *sOut = cChar;
      ++sOut;
    } else {
      utf8encode(sOut, cpmik_to_unicode_table[cChar - 0x80]);
    }
  } while (cChar != 0);
}

void CopyStringCP936(const uint8_t*& sIn, uint8_t*& sOut) {
  uint8_t cChar1, cChar2;
  do {
    cChar1 = *sIn;
    ++sIn;
    if (cChar1 < 0x81 || cChar1 == 0xFF) {
      *sOut = cChar1;
      ++sOut;
    } else {
      cChar2 = *sIn;
      ++sIn;
      if (0x40 <= cChar2 && cChar2 <= 0xFE) {
        utf8encode(sOut, cp936_to_unicode_table[cChar1 - 0x81][cChar2 - 0x40]);
        // The Theme Hospital string tables seem to like following a
        // multibyte character with a superfluous space.
        cChar2 = *sIn;
        if (cChar2 == ' ') ++sIn;
      } else {
        *sOut = cChar1;
        ++sOut;
        *sOut = cChar2;
        ++sOut;
      }
    }
  } while (cChar1 != 0);
}

enum class encoding { cp437, cp936, mik };

encoding detect_encoding(const uint8_t* data, size_t length) {
  const uint8_t mik_prefix[] = {0x8C, 0xA5, 0xA4, 0xB1, 0xA5};
  if (length >= sizeof(mik_prefix) &&
      std::equal(mik_prefix, mik_prefix + sizeof(mik_prefix), data)) {
    // The MIK encoding is used in the Russian version of the game, and has a
    // fixed length of 0x1619D bytes.
    return encoding::mik;
  }

  // The range of bytes 0xB0 through 0xDF are box drawing characters in CP437
  // which shouldn't occur much (if ever) in TH strings, whereas they are
  // commonly used in GB2312 encoding. We use 10% as a threshold.
  size_t iBCDCount = 0;
  for (size_t i = 0; i < length; ++i) {
    if (0xB0 <= data[i] && data[i] <= 0xDF) ++iBCDCount;
  }
  if (iBCDCount * 10 >= length)
    return encoding::cp936;
  else
    return encoding::cp437;
}

}  // namespace

// https://github.com/CorsixTH/theme-hospital-spec/blob/master/format-specification.md#strings
th_string_list::th_string_list(const uint8_t* data, size_t length) {
  if (length < 2) throw std::invalid_argument("length must be 2 or larger");

  size_t iSectionCount = bytes_to_uint16_le(data);
  size_t iHeaderLength = (iSectionCount + 1) * 2;

  if (length < iHeaderLength)
    throw std::invalid_argument("iDataLength must be larger than the header");

  size_t iStringDataLength = length - iHeaderLength;
  const uint8_t* sStringData = data + iHeaderLength;
  const uint8_t* sDataEnd = sStringData + iStringDataLength;

  void (*fnCopyString)(const uint8_t*&, uint8_t*&);
  switch (detect_encoding(sStringData, iStringDataLength)) {
    case encoding::cp437:
      fnCopyString = CopyStringCP437;
      break;
    case encoding::cp936:
      fnCopyString = CopyStringCP936;
      break;
    case encoding::mik:
      fnCopyString = CopyStringMIK;
  }

  // String buffer sized to accept the largest possible reencoding of the
  // characters interpreted as CP936 or CP437 (2 bytes per character).
  string_buffer.resize(iStringDataLength * 2 + 2);

  uint8_t* sDataOut = string_buffer.data();
  sections.resize(iSectionCount);
  for (size_t i = 0; i < iSectionCount; ++i) {
    // The section sizes start at offset 2 in the data, after the section count.
    // Each section size is 2 bytes.
    size_t sectionSizeOffset = (i + 1) * 2;
    size_t sectionSize = bytes_to_uint16_le(data + sectionSizeOffset);

    // Read the strings for the section.
    //
    // All of the strings get stored in string_buffer which sDataOut points
    // into. The sections vectors get filled with the pointers to the start of
    // each string in string_buffer.
    sections[i].reserve(sectionSize);
    for (size_t j = 0; j < sectionSize; ++j) {
      sections[i].push_back(reinterpret_cast<char*>(sDataOut));
      if (sStringData != sDataEnd) {
        fnCopyString(sStringData, sDataOut);
      }
    }
  }
  // Terminate final string with nil character
  *sDataOut = 0;
}

size_t th_string_list::get_section_count() const { return sections.size(); }

size_t th_string_list::get_section_size(size_t section) const {
  return section < sections.size() ? sections[section].size() : 0;
}

const char* th_string_list::get_string(size_t section, size_t index) const {
  if (index < get_section_size(section)) {
    return sections[section][index];
  }
  return nullptr;
}
