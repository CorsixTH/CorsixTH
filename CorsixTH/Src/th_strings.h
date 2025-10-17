#ifndef CORSIX_TH_TH_STRINGS_H_
#define CORSIX_TH_TH_STRINGS_H_

#include "config.h"

constexpr unsigned int invalid_char_codepoint = 0xFFFD;
constexpr unsigned int ideographic_space_codepoint = 0x3000;

size_t discard_leading_set_bits(uint8_t& byte);

unsigned int next_utf8_codepoint(const char*& sString, const char* end);

unsigned int decode_utf8(const char* sString, const char* end);

const char* previous_utf8_codepoint(const char* sString);

void skip_utf8_whitespace(const char*& sString, const char* end);

unsigned int unicode_to_codepage_437(unsigned int iCodePoint);

#endif
