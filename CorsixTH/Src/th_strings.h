#ifndef CORSIX_TH_TH_STRINGS_H_
#define CORSIX_TH_TH_STRINGS_H_

#include "config.h"

#include <cwctype>
#include <stdexcept>

constexpr unsigned int invalid_char_codepoint = 0xFFFD;
constexpr unsigned int ideographic_space_codepoint = 0x3000;

size_t discard_leading_set_bits(uint8_t& byte) {
  size_t count = 0;
  while ((byte & 0x80) != 0) {
    count++;
    byte = static_cast<uint8_t>(byte << 1);
  }
  byte = byte >> count;
  return count;
}

unsigned int next_utf8_codepoint(const char*& sString, const char* end) {
  if (sString >= end) {
    throw std::out_of_range("pointer is outside of string");
  }

  uint8_t cur_byte = *reinterpret_cast<const uint8_t*>(sString++);
  size_t leading_bit_count = discard_leading_set_bits(cur_byte);

  if (leading_bit_count == 1 || leading_bit_count > 4) {
    // A single leading bit is a continuation character. A utf-8 character
    // can be at most 4 bytes long.
    return invalid_char_codepoint;
  }

  unsigned int codepoint = cur_byte;
  for (size_t i = 1; i < leading_bit_count; ++i) {
    if (sString == end) {
      return invalid_char_codepoint;
    }

    cur_byte = *reinterpret_cast<const uint8_t*>(sString++);
    size_t continue_leading_bits = discard_leading_set_bits(cur_byte);

    if (continue_leading_bits != 1) {
      // Not enough continuation characters
      return invalid_char_codepoint;
    }
    codepoint = (codepoint << 6) | cur_byte;
  }
  return codepoint;
}

unsigned int decode_utf8(const char* sString, const char* end) {
  return next_utf8_codepoint(sString, end);
}

const char* previous_utf8_codepoint(const char* sString) {
  do {
    --sString;
  } while (((*sString) & 0xC0) == 0x80);
  return sString;
}

void skip_utf8_whitespace(const char*& sString, const char* end) {
  if (sString >= end) {
    return;
  }
  unsigned int iCode = decode_utf8(sString, end);
  while ((std::iswspace(iCode) || iCode == ideographic_space_codepoint)) {
    next_utf8_codepoint(sString, end);
    if (sString == end) {
      return;
    }
    iCode = decode_utf8(sString, end);
  }
}

constexpr uint16_t unicode_to_cp437_table[0x60] = {
    0xFF, 0xAD, 0x9B, 0x9C, 0x3F, 0x9D, 0x3F, 0x3F, 0x3F, 0x3F, 0xA6, 0xAE,
    0xAA, 0x3F, 0x3F, 0x3F, 0xF8, 0xF1, 0xFD, 0x3F, 0x3F, 0x3F, 0x3F, 0xFA,
    0x3F, 0x3F, 0xA7, 0xAF, 0xAC, 0xAB, 0x3F, 0xA8, 0x3F, 0x3F, 0x3F, 0x3F,
    0x8E, 0x8F, 0x3F, 0x80, 0x3F, 0x90, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F,
    0x3F, 0xA5, 0x3F, 0x3F, 0x3F, 0x3F, 0x99, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F,
    0x9A, 0x3F, 0x3F, 0xE1, 0x85, 0xA0, 0x83, 0x3F, 0x84, 0x86, 0x91, 0x87,
    0x8A, 0x82, 0x88, 0x89, 0x8D, 0xA1, 0x8C, 0x8B, 0x3F, 0xA4, 0x95, 0xA2,
    0x93, 0x3F, 0x94, 0xF6, 0x3F, 0x97, 0xA3, 0x96, 0x81, 0x3F, 0x3F, 0x98};

unsigned int unicode_to_codepage_437(unsigned int iCodePoint) {
  if (iCodePoint < 0x80) return iCodePoint;
  if (iCodePoint < 0xA0) return '?';
  if (iCodePoint < 0x100) return unicode_to_cp437_table[iCodePoint - 0xA0];
  switch (iCodePoint) {
    case 0x0192:
      return 0x9F;
    case 0x0393:
      return 0xE2;
    case 0x0398:
      return 0xE9;
    case 0x03A3:
      return 0xE4;
    case 0x03A6:
      return 0xE8;
    case 0x03A9:
      return 0xEA;
    case 0x03B1:
      return 0xE0;
    case 0x03B4:
      return 0xEB;
    case 0x03B5:
      return 0xEE;
    case 0x03BC:
      return 0xE6;
    case 0x03C0:
      return 0xE3;
    case 0x03C3:
      return 0xE5;
    case 0x03C4:
      return 0xE7;
    case 0x03C6:
      return 0xED;
    case 0x207F:
      return 0xFC;
    case 0x20A7:
      return 0x9E;
    case 0x2219:
      return 0xF9;
    case 0x221A:
      return 0xFB;
    case 0x221E:
      return 0xEC;
    case 0x2229:
      return 0xEF;
    case 0x2248:
      return 0xF7;
    case 0x2261:
      return 0xF0;
    case 0x2264:
      return 0xF3;
    case 0x2265:
      return 0xF2;
    case 0x2310:
      return 0xA9;
    case 0x2320:
      return 0xF4;
    case 0x2321:
      return 0xF5;
    case 0x25A0:
      return 0xFE;
  }
  return 0x3F;
}

#endif
