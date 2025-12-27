/*
Copyright (c) 2010 Peter "Corsix" Cawley

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

#include "th_gfx_font.h"

#include "config.h"

#include <ft2build.h>  // IWYU pragma: keep
// IWYU pragma: no_include "freetype/config/ftheader.h"

#include "th_strings.h"
#include FT_FREETYPE_H
#include FT_ERRORS_H
#include FT_GLYPH_H
#include FT_IMAGE_H
#include FT_TYPES_H
#include <algorithm>
#include <cstring>
#include <map>
#include <utility>
#include <vector>

#include "th_gfx.h"

bitmap_font::bitmap_font() = default;

void bitmap_font::set_sprite_sheet(sprite_sheet* pSpriteSheet) {
  sheet = pSpriteSheet;
}

void bitmap_font::set_separation(int iCharSep, int iLineSep) {
  letter_spacing = iCharSep;
  line_spacing = iLineSep;
}

void bitmap_font::set_scale_factor(int factor) { scale_factor = factor; }

text_layout bitmap_font::get_text_dimensions(const char* sMessage,
                                             size_t iMessageLength,
                                             int iMaxWidth) const {
  return draw_text_wrapped(nullptr, sMessage, iMessageLength, 0, 0, iMaxWidth,
                           INT_MAX, 0);
}

void bitmap_font::draw_text(render_target* pCanvas, const char* sMessage,
                            size_t iMessageLength, int iX, int iY) const {
  pCanvas->start_nonoverlapping_draws();
  if (iMessageLength != 0 && sheet != nullptr) {
    const unsigned int iFirstASCII = 31;
    unsigned int iLastASCII =
        static_cast<unsigned int>(sheet->get_sprite_count()) + iFirstASCII;
    const char* sMessageEnd = sMessage + iMessageLength;
    int scaled_letter_spacing = letter_spacing * scale_factor;

    while (sMessage != sMessageEnd) {
      unsigned int iChar =
          unicode_to_codepage_437(next_utf8_codepoint(sMessage, sMessageEnd));
      if (iFirstASCII <= iChar && iChar <= iLastASCII) {
        iChar -= iFirstASCII;
        int iWidth;
        int iHeight;
        sheet->draw_sprite(pCanvas, iChar, iX, iY, thdf_nearest, 0,
                           animation_effect::none, scale_factor);
        sheet->get_sprite_size_unchecked(iChar, &iWidth, &iHeight);
        iWidth *= scale_factor;
        iHeight *= scale_factor;
        iX += iWidth + scaled_letter_spacing;
      }
    }
  }
  pCanvas->finish_nonoverlapping_draws();
}

text_layout bitmap_font::draw_text_wrapped(render_target* pCanvas,
                                           const char* sMessage,
                                           size_t iMessageLength, int iX,
                                           int iY, int iWidth, int iMaxRows,
                                           int iSkipRows,
                                           text_alignment eAlign) const {
  text_layout oDrawArea = {};
  int iSkippedRows = 0;
  if (iMessageLength != 0 && sheet != nullptr) {
    const unsigned int iFirstASCII = 31;
    unsigned int iLastASCII =
        static_cast<unsigned int>(sheet->get_sprite_count()) + iFirstASCII;
    const char* sMessageEnd = sMessage + iMessageLength;

    while (sMessage != sMessageEnd && oDrawArea.row_count < iMaxRows) {
      const char* sBreakPosition = sMessageEnd;
      const char* sLastGoodBreakPosition = sBreakPosition;
      int scaled_letter_spacing = letter_spacing * scale_factor;
      int scaled_line_spacing = line_spacing * scale_factor;
      int iMsgWidth = -scaled_letter_spacing;
      int iMsgBreakWidth = iMsgWidth;
      int iTallest = 0;
      const char* s;
      bool foundNewLine = false;
      unsigned int iNextChar = 0;

      for (s = sMessage; s != sMessageEnd;) {
        const char* sOld = s;
        unsigned int iChar =
            unicode_to_codepage_437(next_utf8_codepoint(s, sMessageEnd));
        iNextChar = unicode_to_codepage_437(static_cast<unsigned char>(*s));
        if ((iChar == '\n' && iNextChar == '\n') ||
            (iChar == '/' && iNextChar == '/')) {
          foundNewLine = true;
          iMsgBreakWidth = iMsgWidth;
          sBreakPosition = sOld;
          break;
        }
        int iCharWidth = 0;
        int iCharHeight = 0;
        if (iFirstASCII <= iChar && iChar <= iLastASCII) {
          sheet->get_sprite_size_unchecked(iChar - iFirstASCII, &iCharWidth,
                                           &iCharHeight);
          iCharWidth *= scale_factor;
          iCharHeight *= scale_factor;
        }
        iMsgWidth += scaled_letter_spacing + iCharWidth;
        if (iChar == ' ') {
          sLastGoodBreakPosition = sOld;
          iMsgBreakWidth = iMsgWidth - iCharWidth;
        }

        if (iMsgWidth > iWidth) {
          sBreakPosition = sLastGoodBreakPosition;
          break;
        }
        if (iCharHeight > iTallest) iTallest = iCharHeight;
      }

      if (s == sMessageEnd) iMsgBreakWidth = iMsgWidth;
      if (iMsgBreakWidth > oDrawArea.width) oDrawArea.width = iMsgBreakWidth;

      if (iSkippedRows >= iSkipRows) {
        if (pCanvas) {
          int iXOffset = 0;
          if (iMsgBreakWidth < iWidth)
            iXOffset = (iWidth - iMsgBreakWidth) * static_cast<int>(eAlign) / 2;
          draw_text(pCanvas, sMessage, sBreakPosition - sMessage, iX + iXOffset,
                    iY);
        }
        iY += static_cast<int>(iTallest) + scaled_line_spacing;
        oDrawArea.end_x = iMsgWidth;
        oDrawArea.row_count++;
        if (foundNewLine) {
          iY += static_cast<int>(iTallest) + scaled_line_spacing;
          oDrawArea.row_count++;
        }
      } else {
        iSkippedRows++;
        if (foundNewLine) {
          if (iSkippedRows == iSkipRows) {
            iY += static_cast<int>(iTallest) + scaled_line_spacing;
            oDrawArea.row_count++;
          }
          iSkippedRows++;
        }
      }
      sMessage = sBreakPosition;
      if (sMessage != sMessageEnd) {
        next_utf8_codepoint(sMessage, sMessageEnd);
        if (foundNewLine) {
          next_utf8_codepoint(sMessage, sMessageEnd);
        }
      }
    }
  }
  oDrawArea.end_x = iX + oDrawArea.end_x;
  oDrawArea.end_y = iY;
  return oDrawArea;
}

FT_Library freetype_font::freetype_library = nullptr;
int freetype_font::freetype_init_count = 0;

freetype_font::freetype_font() {
  for (cached_text* pEntry = cache; pEntry != cache + (1 << cache_size_log2);
       ++pEntry) {
    pEntry->message = nullptr;
    pEntry->message_length = 0;
    pEntry->message_buffer_length = 0;
    pEntry->alignment = text_alignment::left;
    pEntry->width = 0;
    pEntry->height = 0;
    pEntry->widest_line_width = 0;
    pEntry->last_x = 0;
    pEntry->data = nullptr;
    pEntry->is_valid = false;
    pEntry->texture = nullptr;
  }
}

freetype_font::~freetype_font() {
  for (cached_text* pEntry = cache; pEntry != cache + (1 << cache_size_log2);
       ++pEntry) {
    delete[] pEntry->message;
    delete[] pEntry->data;
    free_texture(pEntry);
  }
  if (font_face != nullptr) FT_Done_Face(font_face);
  if (is_done_freetype_init) {
    if (--freetype_init_count == 0) {
      FT_Done_FreeType(freetype_library);
      freetype_library = nullptr;
    }
  }
}

const char* freetype_font::get_copyright_notice() {
  return "Portions of this software are copyright \xC2\xA9 2010 "
         "The FreeType Project (www.freetype.org).  All rights reserved.";
}

FT_Error freetype_font::initialise() {
  if (is_done_freetype_init) return FT_Err_Ok;
  if (freetype_init_count == 0) {
    int iError = FT_Init_FreeType(&freetype_library);
    if (iError != FT_Err_Ok) return iError;
  }
  ++freetype_init_count;
  is_done_freetype_init = true;
  return FT_Err_Ok;
}

void freetype_font::clear_cache() {
  for (cached_text* pEntry = cache; pEntry != cache + (1 << cache_size_log2);
       ++pEntry) {
    pEntry->is_valid = false;
    free_texture(pEntry);
  }
}

FT_Error freetype_font::set_face(const uint8_t* pData, size_t iLength) {
  int iError;
  if (freetype_library == nullptr) {
    iError = initialise();
    if (iError != FT_Err_Ok) return iError;
  }
  if (font_face) {
    iError = FT_Done_Face(font_face);
    if (iError != FT_Err_Ok) return iError;
    font_face = nullptr;
  }
  iError = FT_New_Memory_Face(freetype_library, pData,
                              static_cast<FT_Long>(iLength), 0, &font_face);
  return iError;
}

FT_Error freetype_font::match_bitmap_font(sprite_sheet* font_spritesheet,
                                          argb_colour* color, int* width,
                                          int* height) {
  if (font_spritesheet == nullptr) return FT_Err_Invalid_Argument;

  // Try to take the size and colour of a standard character (em is generally
  // the standard font character, but for fonts which only have numbers, zero
  // seems like the next best choice).
  for (const char* sCharToTry = "M0"; *sCharToTry; ++sCharToTry) {
    unsigned int iSprite = *sCharToTry - 31;
    if (font_spritesheet->get_sprite_size(iSprite, width, height) &&
        font_spritesheet->get_sprite_average_colour(iSprite, color) &&
        *width > 1 && *height > 1) {
      return FT_Err_Ok;
    }
  }

  // Take the average size of all characters, and the colour of one of them.
  int iWidthSum = 0;
  int iHeightSum = 0;
  int iAverageNum = 0;
  for (size_t i = 0; i < font_spritesheet->get_sprite_count(); ++i) {
    int iWidth;
    int iHeight;
    font_spritesheet->get_sprite_size_unchecked(i, &iWidth, &iHeight);
    if (iWidth <= 1 || iHeight <= 1) continue;
    if (!font_spritesheet->get_sprite_average_colour(i, color)) continue;
    iWidthSum += *width;
    iHeightSum += *height;
    ++iAverageNum;
  }
  if (iAverageNum == 0) return FT_Err_Divide_By_Zero;

  *width = (iWidthSum + iAverageNum / 2) / iAverageNum;
  *height = (iHeightSum + iAverageNum / 2) / iAverageNum;
  return FT_Err_Ok;
}

FT_Error freetype_font::set_ideal_character_size(int iWidth, int iHeight) {
  if (font_face == nullptr) return FT_Err_Invalid_Face_Handle;

  if (is_monochrome() || iHeight <= 14 || iWidth <= 9) {
    // Look for a bitmap strike of a similar size
    int iBestBitmapScore = 50;
    FT_Int iBestBitmapIndex = -1;
    for (FT_Int i = 0; i < font_face->num_fixed_sizes; ++i) {
      if (font_face->available_sizes[i].height > iHeight) continue;
      int iDeltaH = iHeight - font_face->available_sizes[i].height;
      int iDeltaW = font_face->available_sizes[i].width - iWidth;
      int iScore = iDeltaH * iDeltaH * 3 + iDeltaW * iDeltaW;
      if (iScore < iBestBitmapScore) {
        iBestBitmapScore = iScore;
        iBestBitmapIndex = i;
      }
    }

    // Select the bitmap strike, if there was one
    if (iBestBitmapIndex != -1)
      return FT_Select_Size(font_face, iBestBitmapIndex);
  }

  // Go with the original size request if there was no bitmap strike, unless
  // the size was very small, in which case scale things up, as vector fonts
  // look rather poor at small sizes.
  if (iHeight < 14) {
    iWidth = iWidth * 14 / iHeight;
    iHeight = 14;
  }
  if (iWidth < 9) {
    iHeight = iHeight * 9 / iWidth;
    iWidth = 9;
  }
  return FT_Set_Pixel_Sizes(font_face, iWidth, iHeight);
}

void freetype_font::set_font_color(argb_colour color) { font_color = color; }

void freetype_font::set_shadow_options(const font_shadow_options& options) {
  shadow_opts = options;
}

text_layout freetype_font::get_text_dimensions(const char* sMessage,
                                               size_t iMessageLength,
                                               int iMaxWidth) const {
  return draw_text_wrapped(nullptr, sMessage, iMessageLength, 0, 0, iMaxWidth,
                           INT_MAX, 0);
}

void freetype_font::draw_text(render_target* pCanvas, const char* sMessage,
                              size_t iMessageLength, int iX, int iY) const {
  draw_text_wrapped(pCanvas, sMessage, iMessageLength, iX, iY, INT_MAX);
}

namespace {

struct codepoint_glyph {
  FT_Glyph_Metrics metrics;
  FT_Glyph glyph;
  FT_UInt index;
};

enum class CJK_breakable { nonbreakable = 0, break_after, break_before };

// Determine if the character code is a suitable Chinese/Japanese/Korean
// character for a line break.
CJK_breakable isCjkBreakCharacter(unsigned int charcode) {
  if (charcode == ideographic_space_codepoint ||
      charcode == 0x3001 ||  // Ideographic comma
      charcode == 0x3002 ||  // Ideographic full stop
      charcode == 0x301e ||  // Double prime quotation mark
      charcode == 0xff09 ||  // Fullwidth right parenthesis
      charcode == 0xff0c ||  // Fullwidth comma
      charcode == 0xff0d ||  // Fullwidth hyphen-minus
      charcode == 0xff1a ||  // Fullwidth Colon
      charcode == 0xff1b ||  // Fullwidth semicolon
      charcode == 0xff1f)    // Fullwidth question mark
    return CJK_breakable::break_after;
  if (charcode == 0x301d ||  // Reversed double prime quotation mark
      charcode == 0xff08)    // Fullwidth left parenthesis
    return CJK_breakable::break_before;
  return CJK_breakable::nonbreakable;
}

FT_Pos pixel_align(FT_Pos position) { return ((position + 63) >> 6) << 6; }

}  // namespace

text_layout freetype_font::draw_text_wrapped(render_target* pCanvas,
                                             const char* sMessage,
                                             size_t iMessageLength, int iX,
                                             int iY, int iWidth, int iMaxRows,
                                             int iSkipRows,
                                             text_alignment eAlign) const {
  text_layout oDrawArea = {};
  int iNumRows = 0;
  int iHandledRows = 0;

  // Calculate an index into the cache to use for this piece of text.
  size_t iHash = iMessageLength +
                 (static_cast<size_t>(iMaxRows) << (cache_size_log2 / 8)) +
                 (static_cast<size_t>(iSkipRows) << (cache_size_log2 / 4)) +
                 (static_cast<size_t>(iWidth) << (cache_size_log2 / 2)) +
                 (static_cast<size_t>(eAlign) << cache_size_log2);
  for (size_t i = 0; i < iMessageLength; ++i)
    iHash ^= (iHash << 5) + (iHash >> 2) + static_cast<size_t>(sMessage[i]);
  iHash &= (1 << cache_size_log2) - 1;

  cached_text* pEntry = cache + iHash;
  if (pEntry->message_length != iMessageLength || pEntry->width > iWidth ||
      (iWidth != INT_MAX && pEntry->width < iWidth) ||
      pEntry->alignment != eAlign || !pEntry->is_valid ||
      std::memcmp(pEntry->message, sMessage, iMessageLength) != 0) {
    // Cache entry does not match the message being drawn, so discard the
    // cache entry.
    free_texture(pEntry);
    delete[] pEntry->data;
    pEntry->data = nullptr;
    pEntry->is_valid = false;

    int width_before_shadow = iWidth;
    if (iWidth < INT_MAX && shadow_opts.enabled) {
      width_before_shadow -= abs(shadow_opts.offset_x);
    }

    // Set the entry metadata to that of the new message.
    if (iMessageLength > pEntry->message_buffer_length) {
      delete[] pEntry->message;
      pEntry->message = new char[iMessageLength];
      pEntry->message_buffer_length = iMessageLength;
    }
    std::memcpy(pEntry->message, sMessage, iMessageLength);
    pEntry->message_length = iMessageLength;
    pEntry->width = iWidth;
    pEntry->alignment = eAlign;

    // Split the message into lines, and determine the position within the
    // line for each character.
    std::vector<std::pair<const char*, const char*> > vLines;
    std::vector<FT_Vector> vCharPositions(iMessageLength);
    std::map<unsigned int, codepoint_glyph> mapGlyphs;
    vLines.reserve(2);

    FT_Vector ftvPen = {0, 0};
    FT_Bool bUseKerning = FT_HAS_KERNING(font_face);
    FT_UInt iPreviousGlyphIndex = 0;

    const char* sMessageStart = sMessage;
    const char* sMessageEnd = sMessage + iMessageLength;
    const char* sLineStart = sMessageStart;
    const char* sLineBreakPosition = sLineStart;

    while (sMessage != sMessageEnd) {
      const char* sOldMessage = sMessage;
      unsigned int iCode = next_utf8_codepoint(sMessage, sMessageEnd);
      unsigned int iNextCode =
          *reinterpret_cast<const unsigned char*>(sMessage);
      bool bIsNewLine = (iCode == '\n' && iNextCode == '\n') ||
                        (iCode == '/' && iNextCode == '/');
      // Just replace single line breaks with space.
      if (!bIsNewLine && iCode == '\n') {
        iCode = ' ';
      }

      codepoint_glyph& oGlyph = mapGlyphs[iCode];
      if (oGlyph.glyph == nullptr) {
        oGlyph.index = FT_Get_Char_Index(font_face, iCode);

        /* FT_Error iError = */
        FT_Load_Glyph(font_face, oGlyph.index, FT_LOAD_DEFAULT);
        // TODO: iError != FT_Err_Ok

        /* iError = */
        FT_Get_Glyph(font_face->glyph, &oGlyph.glyph);
        // TODO: iError != FT_Err_Ok

        oGlyph.metrics = font_face->glyph->metrics;
      }

      // Apply kerning
      if (bUseKerning && iPreviousGlyphIndex && oGlyph.index) {
        FT_Vector ftvKerning;
        FT_Get_Kerning(font_face, iPreviousGlyphIndex, oGlyph.index,
                       FT_KERNING_DEFAULT, &ftvKerning);
        ftvPen.x += ftvKerning.x;
        ftvPen.y += ftvKerning.y;
      }

      // Make an automatic line break if one is needed.
      long line_width_with_glyph =
          (ftvPen.x + oGlyph.metrics.horiBearingX + oGlyph.metrics.width + 63) /
          64;
      if (line_width_with_glyph >= width_before_shadow || bIsNewLine) {
        if (bIsNewLine) {
          sLineBreakPosition = sOldMessage;
        }
        ftvPen.x = ftvPen.y = 0;
        iPreviousGlyphIndex = 0;
        if (sLineStart != sLineBreakPosition) {
          // Only really save if we have skipped enough lines
          if (iHandledRows >= iSkipRows) {
            vLines.push_back(std::make_pair(sLineStart, sLineBreakPosition));
          }
          if (bIsNewLine) {
            if (iHandledRows + 1 >= iSkipRows) {
              vLines.push_back(
                  std::make_pair(sLineBreakPosition, sLineBreakPosition));
            }
            // skip // or \n\n
            next_utf8_codepoint(sLineBreakPosition, sMessageEnd);
            next_utf8_codepoint(sLineBreakPosition, sMessageEnd);
            iHandledRows++;
          }
          sMessage = sLineStart = sLineBreakPosition;
          // Skip leading white space on a line
          skip_utf8_whitespace(sMessage, sMessageEnd);
        } else {
          if (iHandledRows >= iSkipRows) {
            vLines.push_back(std::make_pair(sLineStart, sOldMessage));
          }
          if (bIsNewLine) {
            // skip // or \n\n
            next_utf8_codepoint(sMessage, sMessageEnd);
            next_utf8_codepoint(sMessage, sMessageEnd);
            sLineStart = sLineBreakPosition = sMessage;
          } else {
            sMessage = sLineStart = sLineBreakPosition = sOldMessage;
          }
        }
        iHandledRows++;
        continue;
      }

      // Determine if a line can be broken at the current position.
      if (iCode == ' ') {
        sLineBreakPosition = sOldMessage;
      } else {
        switch (isCjkBreakCharacter(iCode)) {
          case CJK_breakable::break_after:
            // break after this codepoint (cjk codepoints are 3 bytes in
            // utf-8)
            sLineBreakPosition = sOldMessage + 3;
            break;
          case CJK_breakable::break_before:
            // break before this codepoint
            sLineBreakPosition = sOldMessage;
            break;
          default:
            break;
        }
      }

      // Save (unless we are skipping lines) and advance the pen.
      if (iHandledRows >= iSkipRows) {
        vCharPositions[sOldMessage - sMessageStart] = ftvPen;
      }

      iPreviousGlyphIndex = oGlyph.index;
      ftvPen.x += oGlyph.metrics.horiAdvance;
    }
    if (sLineStart != sMessageEnd)
      vLines.push_back(std::make_pair(sLineStart, sMessageEnd));
    sMessage = sMessageStart;

    // Finalise the position of each character (alignment might change X,
    // and baseline / lines will change Y), and calculate overall height
    // and widest line.
    FT_Pos iPriorLinesHeight = 0;
    FT_Pos iLineWidth = 0, iAlignDelta = 0, iWidestLine = 0;
    const FT_Pos iLineSpacing = 2 << 6;
    codepoint_glyph& oGlyph = mapGlyphs['l'];
    FT_Pos iBearingY = oGlyph.metrics.horiBearingY;
    FT_Pos iNormalLineHeight = oGlyph.metrics.height - iBearingY;

    iBearingY = pixel_align(iBearingY);
    iNormalLineHeight += iBearingY;
    iNormalLineHeight += iLineSpacing;

    iNormalLineHeight = pixel_align(iNormalLineHeight);

    for (auto itr = vLines.begin(); itr != vLines.end() && iNumRows < iMaxRows;
         ++itr) {
      // Calculate the X change resulting from alignment.
      const char* sLastChar = previous_utf8_codepoint(itr->second);
      codepoint_glyph& oLastGlyph =
          mapGlyphs[decode_utf8(sLastChar, sMessageEnd)];
      iLineWidth = vCharPositions[sLastChar - sMessage].x +
                   oLastGlyph.metrics.horiBearingX + oLastGlyph.metrics.width;
      if ((iLineWidth >> 6) < iWidth && eAlign != text_alignment::left) {
        iAlignDelta =
            ((iWidth * 64 - iLineWidth) * static_cast<int>(eAlign)) / 2;
      }
      if (iLineWidth > iWidestLine) iWidestLine = iLineWidth;

      // Calculate the line height and baseline position.
      FT_Pos iLineHeight = 0;
      FT_Pos iBaselinePos = 0;
      for (const char* s = itr->first; s < itr->second;) {
        codepoint_glyph& oGlyph =
            mapGlyphs[next_utf8_codepoint(s, sMessageEnd)];
        FT_Pos iBearingY = oGlyph.metrics.horiBearingY;
        FT_Pos iCoBearingY = oGlyph.metrics.height - iBearingY;
        if (iBearingY > iBaselinePos) iBaselinePos = iBearingY;
        if (iCoBearingY > iLineHeight) iLineHeight = iCoBearingY;
      }

      iBaselinePos = pixel_align(iBaselinePos);
      iLineHeight += iBaselinePos;
      iLineHeight += iLineSpacing;
      iLineHeight = pixel_align(iLineHeight);

      iNormalLineHeight = std::max(iNormalLineHeight, iLineHeight);

      // Apply the character position changes.
      for (const char* s = itr->first; s < itr->second;
           next_utf8_codepoint(s, sMessageEnd)) {
        FT_Vector& ftvPos = vCharPositions[s - sMessage];
        ftvPos.x += iAlignDelta;
        ftvPos.y += iBaselinePos + iPriorLinesHeight;
      }
      // Empty lines is a special case
      if (itr->first == itr->second) {
        iPriorLinesHeight += iNormalLineHeight;
      } else {
        iPriorLinesHeight += iLineHeight;
      }
      iNumRows++;
    }
    if (iPriorLinesHeight > 0) iPriorLinesHeight -= iLineSpacing;
    pEntry->height = static_cast<int>(1 + (iPriorLinesHeight >> 6));
    pEntry->widest_line_width = static_cast<int>(1 + (iWidestLine >> 6));
    if (shadow_opts.enabled) {
      pEntry->widest_line_width += std::abs(shadow_opts.offset_x);
      pEntry->height += std::abs(shadow_opts.offset_y);
    }
    if (iWidth == INT_MAX) pEntry->width = pEntry->widest_line_width;
    pEntry->row_count = iNumRows;
    pEntry->last_x = 1 + (static_cast<int>(iLineWidth + iAlignDelta) >> 6);

    // Get a bitmap for each glyph.
    bool bIsMonochrome = is_monochrome();
    FT_Render_Mode eRenderMode =
        bIsMonochrome ? FT_RENDER_MODE_MONO : FT_RENDER_MODE_NORMAL;
    for (auto itr = mapGlyphs.begin(), itrEnd = mapGlyphs.end(); itr != itrEnd;
         ++itr) {
      FT_Glyph_To_Bitmap(&itr->second.glyph, eRenderMode, nullptr, 1);
    }

    // Prepare a canvas for rendering.
    pEntry->data = new uint8_t[pEntry->width * pEntry->height];
    std::memset(pEntry->data, 0, pEntry->width * pEntry->height);

    int iDrawnLines = 0;
    // Render each character to the canvas.
    for (auto itr = vLines.begin();
         itr != vLines.end() && iDrawnLines < iMaxRows + iSkipRows; ++itr) {
      iDrawnLines++;
      for (const char* s = itr->first; s < itr->second;) {
        FT_Vector& ftvPos = vCharPositions[s - sMessage];
        unsigned int iCode = next_utf8_codepoint(s, sMessageEnd);
        if (iCode == '\n') {
          iCode = ' ';
        }
        FT_BitmapGlyph pGlyph =
            reinterpret_cast<FT_BitmapGlyph>(mapGlyphs[iCode].glyph);
        FT_Pos x = pGlyph->left + (ftvPos.x >> 6);
        FT_Pos y = (ftvPos.y >> 6) - pGlyph->top;
        // We may have asked for grayscale but been given monochrome,
        // hence use the bitmap's pixel_mode rather than bIsMonochrome.
        switch (pGlyph->bitmap.pixel_mode) {
          case FT_PIXEL_MODE_GRAY:
            render_gray(pEntry, &pGlyph->bitmap, x, y);
            break;
          case FT_PIXEL_MODE_MONO:
            render_mono(pEntry, &pGlyph->bitmap, x, y);
            break;
        }
      }
    }

    // Free all glyphs.
    for (auto itr = mapGlyphs.begin(); itr != mapGlyphs.end(); ++itr) {
      FT_Done_Glyph(itr->second.glyph);
    }

    pEntry->is_valid = true;
  }

  if (pCanvas != nullptr) {
    if (pEntry->texture == nullptr) {
      make_texture(pCanvas, pEntry);
    }
    draw_texture(pCanvas, pEntry, iX, iY);
  }
  oDrawArea.width = pEntry->widest_line_width;
  oDrawArea.end_x = iX + pEntry->last_x;
  oDrawArea.end_y = iY + pEntry->height;
  oDrawArea.row_count = pEntry->row_count;
  return oDrawArea;
}

// In theory, the renderers should only be invoked with coordinates which end
// up within the canvas being rendered to. In practice, this might not happen,
// at which point the following line can be removed.
// #define TRUST_RENDER_COORDS

void freetype_font::render_mono(cached_text* pCacheEntry, FT_Bitmap* pBitmap,
                                FT_Pos x, FT_Pos y) const {
  uint8_t* pOutRow = pCacheEntry->data + y * pCacheEntry->width + x;
  uint8_t* pInRow = pBitmap->buffer;
  int rows = static_cast<int>(pBitmap->rows);
  int width = static_cast<int>(pBitmap->width);
  for (int iY = 0; iY < rows;
       ++iY, pOutRow += pCacheEntry->width, pInRow += pBitmap->pitch) {
#ifndef TRUST_RENDER_COORDS
    if (y + iY < 0) continue;
    if (y + iY >= pCacheEntry->height) break;
#endif
    uint8_t *pIn = pInRow, *pOut = pOutRow;
    uint8_t iMask = 0x80;
    for (int iX = 0; iX < width; ++iX, ++pOut) {
#ifndef TRUST_RENDER_COORDS
      if (x + iX < 0) continue;
      if (x + iX >= pCacheEntry->width) break;
#endif
      if (*pIn & iMask) *pOut = 0xFF;
      iMask = static_cast<uint8_t>(iMask / 2);
      if (iMask == 0) {
        iMask = 0x80;
        ++pIn;
      }
    }
  }
}

void freetype_font::render_gray(cached_text* pCacheEntry, FT_Bitmap* pBitmap,
                                FT_Pos x, FT_Pos y) const {
  uint8_t* pOutRow = pCacheEntry->data + y * pCacheEntry->width + x;
  uint8_t* pInRow = pBitmap->buffer;
  int rows = static_cast<int>(pBitmap->rows);
  int width = static_cast<int>(pBitmap->width);
  for (int iY = 0; iY < rows;
       ++iY, pOutRow += pCacheEntry->width, pInRow += pBitmap->pitch) {
#ifndef TRUST_RENDER_COORDS
    if (y + iY < 0) continue;
    if (y + iY >= pCacheEntry->height) break;
#endif
    uint8_t *pIn = pInRow, *pOut = pOutRow;
    for (int iX = 0; iX < width; ++iX, ++pIn, ++pOut) {
#ifndef TRUST_RENDER_COORDS
      if (x + iX < 0) continue;
      if (x + iX >= pCacheEntry->width) break;
#endif
      unsigned int iIn = *pIn;
      unsigned int iOut = *pOut;
      uint8_t cMerged = static_cast<uint8_t>(iIn + iOut - (iIn * iOut) / 255);
      *pOut = cMerged;
    }
  }
}
