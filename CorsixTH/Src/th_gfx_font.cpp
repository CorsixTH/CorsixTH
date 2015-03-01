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

#include "config.h"
#include "th_gfx_font.h"
#ifdef CORSIX_TH_USE_FREETYPE2
#include FT_GLYPH_H
#include <vector>
#include <map>
#endif

static unsigned int utf8next(const char*& sString)
{
    unsigned int iCode = *reinterpret_cast<const uint8_t*>(sString++);
    unsigned int iContinuation;
    if(iCode & 0x80)
    {
        if((iCode & 0x40) == 0)
        {
            // Invalid encoding: character should not start with a continuation
            // byte. Hence return the Unicode replacement character.
            return 0xFFFD;
        }
        else
        {
#define CONTINUATION_CHAR \
    iContinuation = *reinterpret_cast<const uint8_t*>(sString); \
    if((iContinuation & 0xC0) != 0x80) \
        /* Invalid encoding: not enough continuation characters. */ \
        return 0xFFFD; \
    iCode = (iCode << 6) | (iContinuation & 0x3F); \
    ++sString

            iCode &= 0x3F;
            if(iCode & 0x20)
            {
                iCode &= 0x1F;
                if(iCode & 0x10)
                {
                    iCode &= 0x0F;
                    if(iCode & 0x08)
                    {
                        // Invalid encoding: too-long byte sequence. Hence
                        // return the Unicode replacement character.
                        return 0xFFFD;
                    }
                    CONTINUATION_CHAR;
                }
                CONTINUATION_CHAR;
            }
            CONTINUATION_CHAR;
        }

#undef CONTINUATION_CHAR
    }
    return iCode;
}

#ifdef CORSIX_TH_USE_FREETYPE2
// Since these functions are only used when we use freetype2, this silences
// warnings about defined and not used.

static unsigned int utf8decode(const char* sString)
{
    return utf8next(sString);
}

static const char* utf8prev(const char* sString)
{
    do
    {
        --sString;
    } while(((*sString) & 0xC0) == 0x80);
    return sString;
}
#endif

THFont::THFont()
{
}

THFont::~THFont()
{
}

THBitmapFont::THBitmapFont()
{
    m_pSpriteSheet = NULL;
    m_iCharSep = 0;
    m_iLineSep = 0;
}

void THBitmapFont::setSpriteSheet(THSpriteSheet* pSpriteSheet)
{
    m_pSpriteSheet = pSpriteSheet;
}

void THBitmapFont::setSeparation(int iCharSep, int iLineSep)
{
    m_iCharSep = iCharSep;
    m_iLineSep = iLineSep;
}

static const uint16_t g_aUnicodeToCP437[0x60] = {
    0xFF, 0xAD, 0x9B, 0x9C, 0x3F, 0x9D, 0x3F, 0x3F, 0x3F, 0x3F, 0xA6, 0xAE,
    0xAA, 0x3F, 0x3F, 0x3F, 0xF8, 0xF1, 0xFD, 0x3F, 0x3F, 0x3F, 0x3F, 0xFA,
    0x3F, 0x3F, 0xA7, 0xAF, 0xAC, 0xAB, 0x3F, 0xA8, 0x3F, 0x3F, 0x3F, 0x3F,
    0x8E, 0x8F, 0x3F, 0x80, 0x3F, 0x90, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F,
    0x3F, 0xA5, 0x3F, 0x3F, 0x3F, 0x3F, 0x99, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F,
    0x9A, 0x3F, 0x3F, 0xE1, 0x85, 0xA0, 0x83, 0x3F, 0x84, 0x86, 0x91, 0x87,
    0x8A, 0x82, 0x88, 0x89, 0x8D, 0xA1, 0x8C, 0x8B, 0x3F, 0xA4, 0x95, 0xA2,
    0x93, 0x3F, 0x94, 0xF6, 0x3F, 0x97, 0xA3, 0x96, 0x81, 0x3F, 0x3F, 0x98
};

static unsigned int unicodeToCodepage437(unsigned int iCodePoint)
{
    if(iCodePoint < 0x80)
        return iCodePoint;
    if(iCodePoint < 0xA0)
        return '?';
    if(iCodePoint < 0x100)
        return g_aUnicodeToCP437[iCodePoint - 0xA0];
    switch(iCodePoint)
    {
        case 0x0192: return 0x9F;
        case 0x0393: return 0xE2;
        case 0x0398: return 0xE9;
        case 0x03A3: return 0xE4;
        case 0x03A6: return 0xE8;
        case 0x03A9: return 0xEA;
        case 0x03B1: return 0xE0;
        case 0x03B4: return 0xEB;
        case 0x03B5: return 0xEE;
        case 0x03BC: return 0xE6;
        case 0x03C0: return 0xE3;
        case 0x03C3: return 0xE5;
        case 0x03C4: return 0xE7;
        case 0x03C6: return 0xED;
        case 0x207F: return 0xFC;
        case 0x20A7: return 0x9E;
        case 0x2219: return 0xF9;
        case 0x221A: return 0xFB;
        case 0x221E: return 0xEC;
        case 0x2229: return 0xEF;
        case 0x2248: return 0xF7;
        case 0x2261: return 0xF0;
        case 0x2264: return 0xF3;
        case 0x2265: return 0xF2;
        case 0x2310: return 0xA9;
        case 0x2320: return 0xF4;
        case 0x2321: return 0xF5;
        case 0x25A0: return 0xFE;
    }
    return 0x3F;
}

void THBitmapFont::getTextSize(const char* sMessage, size_t iMessageLength, int* pX, int* pY) const
{
    int iX = 0;
    unsigned int iTallest = 0;
    if(iMessageLength != 0 && m_pSpriteSheet != NULL)
    {
        const unsigned int iFirstASCII = 31;
        unsigned int iLastASCII = static_cast<unsigned int>(m_pSpriteSheet->getSpriteCount()) + iFirstASCII;
        const char* sMessageEnd = sMessage + iMessageLength;
        iX = -m_iCharSep;

        while(sMessage != sMessageEnd)
        {
            unsigned int iChar = unicodeToCodepage437(utf8next(sMessage));
            if(iFirstASCII <= iChar && iChar <= iLastASCII)
            {
                iChar -= iFirstASCII;
                unsigned int iWidth, iHeight;
                m_pSpriteSheet->getSpriteSizeUnchecked(iChar, &iWidth, &iHeight);
                iX += iWidth + m_iCharSep;
                if(iHeight > iTallest)
                    iTallest = iHeight;
            }
        }
    }
    if(pX)
        *pX = iX;
    if(pY)
        *pY = (int)iTallest;
}

void THBitmapFont::drawText(THRenderTarget* pCanvas, const char* sMessage, size_t iMessageLength, int iX, int iY) const
{
    pCanvas->startNonOverlapping();
    if(iMessageLength != 0 && m_pSpriteSheet != NULL)
    {
        const unsigned int iFirstASCII = 31;
        unsigned int iLastASCII = static_cast<unsigned int>(m_pSpriteSheet->getSpriteCount()) + iFirstASCII;
        const char* sMessageEnd = sMessage + iMessageLength;

        while(sMessage != sMessageEnd)
        {
            unsigned int iChar = unicodeToCodepage437(utf8next(sMessage));
            if(iFirstASCII <= iChar && iChar <= iLastASCII)
            {
                iChar -= iFirstASCII;
                unsigned int iWidth, iHeight;
                m_pSpriteSheet->drawSprite(pCanvas, iChar, iX, iY, 0);
                m_pSpriteSheet->getSpriteSizeUnchecked(iChar, &iWidth, &iHeight);
                iX += iWidth + m_iCharSep;
            }
        }
    }
    pCanvas->finishNonOverlapping();
}

int THBitmapFont::drawTextWrapped(THRenderTarget* pCanvas, const char* sMessage,
                        size_t iMessageLength, int iX, int iY, int iWidth,
                        int *pResultingWidth, int *pLastX, eTHAlign eAlign) const
{
    int iResultingWidth = 0;
    int iLastX = 0;
    if(iMessageLength != 0 && m_pSpriteSheet != NULL)
    {
        const unsigned int iFirstASCII = 31;
        unsigned int iLastASCII = static_cast<unsigned int>(m_pSpriteSheet->getSpriteCount()) + iFirstASCII;
        const char* sMessageEnd = sMessage + iMessageLength;

        while(sMessage != sMessageEnd)
        {
            const char* sBreakPosition = sMessageEnd;
            const char* sLastGoodBreakPosition = sBreakPosition;
            int iMsgWidth = -m_iCharSep;
            int iMsgBreakWidth = iMsgWidth;
            unsigned int iTallest = 0;
            const char* s;

            for(s = sMessage; s != sMessageEnd; )
            {
                const char* sOld = s;
                unsigned int iChar = unicodeToCodepage437(utf8next(s));
                unsigned int iCharWidth = 0, iCharHeight = 0;
                if(iFirstASCII <= iChar && iChar <= iLastASCII)
                {
                    m_pSpriteSheet->getSpriteSizeUnchecked(iChar - iFirstASCII, &iCharWidth, &iCharHeight);
                }
                iMsgWidth += m_iCharSep + iCharWidth;
                if(iChar == ' ')
                {
                    sLastGoodBreakPosition = sOld;
                    iMsgBreakWidth = iMsgWidth - iCharWidth;
                }
                if(iMsgWidth > iWidth)
                {
                    sBreakPosition = sLastGoodBreakPosition;
                    break;
                }
                if(iCharHeight > iTallest)
                    iTallest = iCharHeight;
            }

            if(s == sMessageEnd)
                iMsgBreakWidth = iMsgWidth;
            if(iMsgBreakWidth > iResultingWidth)
                iResultingWidth = iMsgBreakWidth;
            if(pCanvas)
            {
                int iXOffset = 0;
                if(iMsgBreakWidth < iWidth)
                    iXOffset = (iWidth - iMsgBreakWidth) * static_cast<int>(eAlign) / 2;
                drawText(pCanvas, sMessage, sBreakPosition - sMessage, iX + iXOffset, iY);
            }
            sMessage = sBreakPosition;
            if(sMessage != sMessageEnd)
            {
                utf8next(sMessage);
            }
            iY += static_cast<int>(iTallest) + m_iLineSep;
            iLastX = iMsgWidth;
        }
    }
    if(pResultingWidth != NULL)
        *pResultingWidth = iResultingWidth;
    if(pLastX != NULL)
        *pLastX = iX + iLastX;
    return iY;
}

#ifdef CORSIX_TH_USE_FREETYPE2
FT_Library THFreeTypeFont::ms_pFreeType = NULL;
int THFreeTypeFont::ms_iFreeTypeInitCount = 0;

THFreeTypeFont::THFreeTypeFont()
{
    m_pFace = NULL;
    m_bDoneFreeTypeInit = false;
    for(cached_text_t* pEntry = m_aCache;
        pEntry != m_aCache + (1 << ms_CacheSizeLog2); ++pEntry)
    {
        pEntry->sMessage = NULL;
        pEntry->iMessageLength = 0;
        pEntry->iMessageBufferLength = 0;
        pEntry->eAlign = Align_Left;
        pEntry->iWidth = 0;
        pEntry->iHeight = 0;
        pEntry->iWidestLine = 0;
        pEntry->iLastX = 0;
        pEntry->pData = NULL;
        pEntry->bIsValid = false;
        _setNullTexture(pEntry);
    }
}

THFreeTypeFont::~THFreeTypeFont()
{
    for(cached_text_t* pEntry = m_aCache;
        pEntry != m_aCache + (1 << ms_CacheSizeLog2); ++pEntry)
    {
        _freeTexture(pEntry);
    }
    if(m_pFace != NULL)
        FT_Done_Face(m_pFace);
    if(m_bDoneFreeTypeInit)
    {
        if(--ms_iFreeTypeInitCount == 0)
        {
            FT_Done_FreeType(ms_pFreeType);
            ms_pFreeType = NULL;
        }
    }
}

const char* THFreeTypeFont::getCopyrightNotice()
{
    return "Portions of this software are copyright \xC2\xA9 2010 " \
        "The FreeType Project (www.freetype.org).  All rights reserved.";
}

FT_Error THFreeTypeFont::initialise()
{
    if(m_bDoneFreeTypeInit)
        return FT_Err_Ok;
    if(ms_iFreeTypeInitCount == 0)
    {
        int iError = FT_Init_FreeType(&ms_pFreeType);
        if(iError != FT_Err_Ok)
            return iError;
    }
    ++ms_iFreeTypeInitCount;
    m_bDoneFreeTypeInit = true;
    return FT_Err_Ok;
}

void THFreeTypeFont::clearCache()
{
    for(cached_text_t* pEntry = m_aCache;
        pEntry != m_aCache + (1 << ms_CacheSizeLog2); ++pEntry)
    {
        pEntry->bIsValid = false;
        _freeTexture(pEntry);
        _setNullTexture(pEntry);
    }
}

FT_Error THFreeTypeFont::setFace(const uint8_t* pData, size_t iLength)
{
    int iError;
    if(ms_pFreeType == NULL)
    {
        iError = initialise();
        if(iError != FT_Err_Ok)
            return iError;
    }
    if(m_pFace)
    {
        iError = FT_Done_Face(m_pFace);
        if(iError != FT_Err_Ok)
            return iError;
        m_pFace = NULL;
    }
    iError = FT_New_Memory_Face(ms_pFreeType, pData, static_cast<FT_Long>(iLength), 0, &m_pFace);
    return iError;
}

FT_Error THFreeTypeFont::matchBitmapFont(THSpriteSheet* pBitmapFontSpriteSheet)
{
    if(pBitmapFontSpriteSheet == NULL)
        return FT_Err_Invalid_Argument;

    // Try to take the size and colour of a standard character (em is generally
    // the standard font character, but for fonts which only have numbers, zero
    // seems like the next best choice).
    for(const char* sCharToTry = "M0"; *sCharToTry; ++sCharToTry)
    {
        unsigned int iWidth, iHeight;
        unsigned int iSprite = *sCharToTry - 31;
        if(pBitmapFontSpriteSheet->getSpriteSize(iSprite, &iWidth, &iHeight)
        && pBitmapFontSpriteSheet->getSpriteAverageColour(iSprite, &m_oColour)
        && iWidth > 1 && iHeight > 1)
        {
            return setPixelSize(iWidth, iHeight);
        }
    }

    // Take the average size of all characters, and the colour of one of them.
    unsigned int iWidthSum = 0, iHeightSum = 0, iAverageNum = 0;
    for(unsigned int i = 0; i < pBitmapFontSpriteSheet->getSpriteCount(); ++i)
    {
        unsigned int iWidth, iHeight;
        pBitmapFontSpriteSheet->getSpriteSizeUnchecked(i, &iWidth, &iHeight);
        if(iWidth <= 1 || iHeight <= 1)
            continue;
        if(!pBitmapFontSpriteSheet->getSpriteAverageColour(i, &m_oColour))
            continue;
        iWidthSum += iWidth;
        iHeightSum += iHeight;
        ++iAverageNum;
    }
    if(iAverageNum == 0)
        return FT_Err_Divide_By_Zero;

    return setPixelSize((iWidthSum + iAverageNum / 2) / iAverageNum,
                        (iHeightSum + iAverageNum / 2) / iAverageNum);
}

FT_Error THFreeTypeFont::setPixelSize(int iWidth, int iHeight)
{
    if(m_pFace == NULL)
        return FT_Err_Invalid_Face_Handle;

    if(_isMonochrome() || iHeight <= 14 || iWidth <= 9)
    {
        // Look for a bitmap strike of a similar size
        int iBestBitmapScore = 50;
        FT_Int iBestBitmapIndex = -1;
        for(FT_Int i = 0; i < m_pFace->num_fixed_sizes; ++i)
        {
            if(m_pFace->available_sizes[i].height > iHeight)
                continue;
            int iDeltaH = iHeight - m_pFace->available_sizes[i].height;
            int iDeltaW = m_pFace->available_sizes[i].width - iWidth;
            int iScore = iDeltaH * iDeltaH * 3 + iDeltaW * iDeltaW;
            if(iScore < iBestBitmapScore)
            {
                iBestBitmapScore = iScore;
                iBestBitmapIndex = i;
            }
        }

        // Select the bitmap strike, if there was one
        if(iBestBitmapIndex != -1)
            return FT_Select_Size(m_pFace, iBestBitmapIndex);
    }

    // Go with the original size request if there was no bitmap strike, unless
    // the size was very small, in which case scale things up, as vector fonts
    // look rather poor at small sizes.
    if(iHeight < 14)
    {
        iWidth = iWidth * 14 / iHeight;
        iHeight = 14;
    }
    if(iWidth < 9)
    {
        iHeight = iHeight * 9 / iWidth;
        iWidth = 9;
    }
    return FT_Set_Pixel_Sizes(m_pFace, iWidth, iHeight);
}

void THFreeTypeFont::getTextSize(const char* sMessage, size_t iMessageLength,
                             int* pX, int* pY) const
{
    int iY = drawTextWrapped(NULL, sMessage, iMessageLength, 0, 0, INT_MAX, pX);
    if(pY)
        *pY = iY;
}

void THFreeTypeFont::drawText(THRenderTarget* pCanvas, const char* sMessage,
                          size_t iMessageLength, int iX, int iY) const
{
    drawTextWrapped(pCanvas, sMessage, iMessageLength, iX, iY, INT_MAX);
}

struct codepoint_glyph_t
{
    FT_Glyph_Metrics oMetrics;
    FT_Glyph pGlyph;
    FT_UInt iGlyphIndex;
};

int THFreeTypeFont::drawTextWrapped(THRenderTarget* pCanvas, const char* sMessage,
                                size_t iMessageLength, int iX, int iY,
                                int iWidth, int *pResultingWidth, int *pLastX,
                                eTHAlign eAlign) const
{
    // Calculate an index into the cache to use for this piece of text.
    size_t iHash = iMessageLength
        + (static_cast<size_t>(iWidth) << (ms_CacheSizeLog2 / 2))
        + (static_cast<size_t>(eAlign) << ms_CacheSizeLog2);
    for(size_t i = 0; i < iMessageLength; ++i)
        iHash ^= (iHash << 5) + (iHash >> 2) + static_cast<size_t>(sMessage[i]);
    iHash &= (1 << ms_CacheSizeLog2) - 1;

    cached_text_t* pEntry = m_aCache + iHash;
    if(pEntry->iMessageLength != iMessageLength || pEntry->iWidth > iWidth
        || (iWidth != INT_MAX && pEntry->iWidth < iWidth)
        || pEntry->eAlign != eAlign || !pEntry->bIsValid
        || memcmp(pEntry->sMessage, sMessage, iMessageLength) != 0)
    {
        // Cache entry does not match the message being drawn, so discard the
        // cache entry.
        _freeTexture(pEntry);
        _setNullTexture(pEntry);
        delete[] pEntry->pData;
        pEntry->pData = NULL;
        pEntry->bIsValid = false;

        // Set the entry metadata to that of the new message.
        if(iMessageLength > pEntry->iMessageBufferLength)
        {
            delete[] pEntry->sMessage;
            pEntry->sMessage = new char[iMessageLength];
            pEntry->iMessageBufferLength = iMessageLength;
        }
        memcpy(pEntry->sMessage, sMessage, iMessageLength);
        pEntry->iMessageLength = iMessageLength;
        pEntry->iWidth = iWidth;
        pEntry->eAlign = eAlign;

        // Split the message into lines, and determine the position within the
        // line for each character.
        std::vector<std::pair<const char*, const char*> > vLines;
        std::vector<FT_Vector> vCharPositions(iMessageLength);
        std::map<unsigned int, codepoint_glyph_t> mapGlyphs;
        vLines.reserve(2);

        FT_Vector ftvPen = {0, 0};
        FT_Bool bUseKerning = FT_HAS_KERNING(m_pFace);
        FT_UInt iPreviousGlyphIndex = 0;

        const char* sMessageStart = sMessage;
        const char* sMessageEnd = sMessage + iMessageLength;
        const char* sLineStart = sMessageStart;
        const char* sLineBreakPosition = sLineStart;

        while(sMessage != sMessageEnd)
        {
            const char* sOldMessage = sMessage;
            unsigned int iCode = utf8next(sMessage);
            codepoint_glyph_t& oGlyph = mapGlyphs[iCode];
            if(oGlyph.pGlyph == NULL)
            {
                oGlyph.iGlyphIndex = FT_Get_Char_Index(m_pFace, iCode);

                /* FT_Error iError = */
                FT_Load_Glyph(m_pFace, oGlyph.iGlyphIndex, FT_LOAD_DEFAULT);
                // TODO: iError != FT_Err_Ok

                /* iError = */
                FT_Get_Glyph(m_pFace->glyph, &oGlyph.pGlyph);
                // TODO: iError != FT_Err_Ok

                oGlyph.oMetrics = m_pFace->glyph->metrics;
            }

            // Apply kerning
            if(bUseKerning && iPreviousGlyphIndex && oGlyph.iGlyphIndex)
            {
                FT_Vector ftvKerning;
                FT_Get_Kerning(m_pFace, iPreviousGlyphIndex,
                    oGlyph.iGlyphIndex, FT_KERNING_DEFAULT, &ftvKerning);
                ftvPen.x += ftvKerning.x;
                ftvPen.y += ftvKerning.y;
            }

            // Make an automatic line break if one is needed.
            if((ftvPen.x + oGlyph.oMetrics.horiBearingX +
                oGlyph.oMetrics.width + 63) / 64 >= iWidth)
            {
                ftvPen.x = ftvPen.y = 0;
                iPreviousGlyphIndex = 0;
                if(sLineStart != sLineBreakPosition)
                {
                    vLines.push_back(std::make_pair(sLineStart, sLineBreakPosition));
                    utf8next(sLineBreakPosition);
                    sMessage = sLineStart = sLineBreakPosition;
                }
                else
                {
                    vLines.push_back(std::make_pair(sLineStart, sOldMessage));
                    sMessage = sLineStart = sLineBreakPosition = sOldMessage;
                }
                continue;
            }

            // Determine if a line can be broken at the current position.
            if(iCode == ' ')
                sLineBreakPosition = sOldMessage;

            // Save and advance the pen.
            vCharPositions[sOldMessage - sMessageStart] = ftvPen;
            iPreviousGlyphIndex = oGlyph.iGlyphIndex;
            ftvPen.x += oGlyph.oMetrics.horiAdvance;
        }
        if(sLineStart != sMessageEnd)
            vLines.push_back(std::make_pair(sLineStart, sMessageEnd));
        sMessage = sMessageStart;

        // Finalise the position of each character (alignment might change X,
        // and baseline / lines will change Y), and calculate overall height
        // and widest line.
        FT_Pos iPriorLinesHeight = 0;
        FT_Pos iLineWidth = 0, iAlignDelta = 0, iWidestLine = 0;
        const FT_Pos iLineSpacing = 2 << 6;
        for(std::vector<std::pair<const char*, const char*> >::const_iterator
            itr = vLines.begin(), itrEnd = vLines.end(); itr != itrEnd; ++itr)
        {
            // Skip empty lines (shouldn't happen anyway?).
            if(itr->first == itr->second)
                continue;

            // Calculate the X change resulting from alignment.
            const char* sLastChar = utf8prev(itr->second);
            codepoint_glyph_t& oLastGlyph = mapGlyphs[utf8decode(sLastChar)];
            iLineWidth = vCharPositions[sLastChar - sMessage].x
                + oLastGlyph.oMetrics.horiBearingX
                + oLastGlyph.oMetrics.width;
            if((iLineWidth >> 6) < iWidth)
            {
                iAlignDelta = ((iWidth * 64 - iLineWidth) *
                    static_cast<int>(eAlign)) / 2;
            }
            if(iLineWidth > iWidestLine)
                iWidestLine = iLineWidth;

            // Calculate the line height and baseline position.
            FT_Pos iLineHeight = 0;
            FT_Pos iBaselinePos = 0;
            for(const char* s = itr->first; s != itr->second; )
            {
                codepoint_glyph_t& oGlyph = mapGlyphs[utf8next(s)];
                FT_Pos iBearingY = oGlyph.oMetrics.horiBearingY;
                FT_Pos iCoBearingY = oGlyph.oMetrics.height - iBearingY;
                if(iBearingY > iBaselinePos)
                    iBaselinePos = iBearingY;
                if(iCoBearingY > iLineHeight)
                    iLineHeight = iCoBearingY;
            }
            iBaselinePos = ((iBaselinePos + 63) >> 6) << 6; // Pixel-align
            iLineHeight += iBaselinePos;
            iLineHeight += iLineSpacing;
            iLineHeight = ((iLineHeight + 63) >> 6) << 6; // Pixel-align

            // Apply the character position changes.
            for(const char* s = itr->first; s != itr->second; utf8next(s))
            {
                FT_Vector& ftvPos = vCharPositions[s - sMessage];
                ftvPos.x += iAlignDelta;
                ftvPos.y += iBaselinePos + iPriorLinesHeight;
            }
            iPriorLinesHeight += iLineHeight;
        }
        if(iPriorLinesHeight > 0)
            iPriorLinesHeight -= iLineSpacing;
        pEntry->iHeight = static_cast<int>(1 + (iPriorLinesHeight >> 6));
        pEntry->iWidestLine = static_cast<int>(1 + (iWidestLine >> 6));
        if(iWidth == INT_MAX)
            pEntry->iWidth = pEntry->iWidestLine;
        pEntry->iLastX = 1 + (static_cast<int>(iLineWidth + iAlignDelta) >> 6);

        // Get a bitmap for each glyph.
        bool bIsMonochrome = _isMonochrome();
        FT_Render_Mode eRenderMode = bIsMonochrome ? FT_RENDER_MODE_MONO
            : FT_RENDER_MODE_NORMAL;
        for(std::map<unsigned int, codepoint_glyph_t>::iterator itr =
            mapGlyphs.begin(), itrEnd = mapGlyphs.end(); itr != itrEnd; ++itr)
        {
            FT_Glyph_To_Bitmap(&itr->second.pGlyph, eRenderMode, NULL, 1);
        }

        // Prepare a canvas for rendering.
        pEntry->pData = new uint8_t[pEntry->iWidth * pEntry->iHeight];
        memset(pEntry->pData, 0, pEntry->iWidth * pEntry->iHeight);

        // Render each character to the canvas.
        for(std::vector<std::pair<const char*, const char*> >::const_iterator
            itr = vLines.begin(), itrEnd = vLines.end(); itr != itrEnd; ++itr)
        {
            for(const char* s = itr->first; s != itr->second; )
            {
                FT_Vector& ftvPos = vCharPositions[s - sMessage];
                FT_BitmapGlyph pGlyph = reinterpret_cast<FT_BitmapGlyph>(
                    mapGlyphs[utf8next(s)].pGlyph);
                FT_Pos x = pGlyph->left + (ftvPos.x >> 6);
                FT_Pos y = (ftvPos.y >> 6) - pGlyph->top;
                // We may have asked for grayscale but been given monochrome,
                // hence use the bitmap's pixel_mode rather than bIsMonochrome.
                switch(pGlyph->bitmap.pixel_mode)
                {
                case FT_PIXEL_MODE_GRAY:
                    _renderGray(pEntry, &pGlyph->bitmap, x, y);
                    break;
                case FT_PIXEL_MODE_MONO:
                    _renderMono(pEntry, &pGlyph->bitmap, x, y);
                    break;
                }
            }
        }

        // Free all glyphs.
        for(std::map<unsigned int, codepoint_glyph_t>::const_iterator itr =
            mapGlyphs.begin(), itrEnd = mapGlyphs.end(); itr != itrEnd; ++itr)
        {
            FT_Done_Glyph(itr->second.pGlyph);
        }

        // Convert the canvas to a texture
        _makeTexture(pCanvas, pEntry);
        pEntry->bIsValid = true;
    }

    if(pCanvas != NULL)
        _drawTexture(pCanvas, pEntry, iX, iY);
    if(pResultingWidth != NULL)
        *pResultingWidth = pEntry->iWidestLine;
    if(pLastX != NULL)
        *pLastX = iX + pEntry->iLastX;
    return iY + pEntry->iHeight;
}

// In theory, the renderers should only be invoked with coordinates which end
// up within the canvas being rendered to. In practice, this might not happen,
// at which point the following line can be removed.
// #define TRUST_RENDER_COORDS

void THFreeTypeFont::_renderMono(cached_text_t *pCacheEntry, FT_Bitmap* pBitmap, FT_Pos x, FT_Pos y) const
{
    uint8_t* pOutRow = pCacheEntry->pData + y * pCacheEntry->iWidth + x;
    uint8_t* pInRow = pBitmap->buffer;
    for(int iY = 0; iY < pBitmap->rows; ++iY, pOutRow += pCacheEntry->iWidth,
        pInRow += pBitmap->pitch)
    {
#ifndef TRUST_RENDER_COORDS
        if(y + iY < 0)
            continue;
        if(y + iY >= pCacheEntry->iHeight)
            break;
#endif
        uint8_t *pIn = pInRow, *pOut = pOutRow;
        uint8_t iMask = 0x80;
        for(int iX = 0; iX < pBitmap->width; ++iX, ++pOut)
        {
#ifndef TRUST_RENDER_COORDS
            if(x + iX < 0)
                continue;
            if(x + iX >= pCacheEntry->iWidth)
                break;
#endif
            if(*pIn & iMask)
                *pOut = 0xFF;
            iMask  = static_cast<uint8_t>(iMask / 2);
            if(iMask == 0)
            {
                iMask = 0x80;
                ++pIn;
            }
        }
    }
}

void THFreeTypeFont::_renderGray(cached_text_t *pCacheEntry, FT_Bitmap* pBitmap, FT_Pos x, FT_Pos y) const
{
    uint8_t* pOutRow = pCacheEntry->pData + y * pCacheEntry->iWidth + x;
    uint8_t* pInRow = pBitmap->buffer;
    for(int iY = 0; iY < pBitmap->rows; ++iY, pOutRow += pCacheEntry->iWidth,
        pInRow += pBitmap->pitch)
    {
#ifndef TRUST_RENDER_COORDS
        if(y + iY < 0)
            continue;
        if(y + iY >= pCacheEntry->iHeight)
            break;
#endif
        uint8_t *pIn = pInRow, *pOut = pOutRow;
        for(int iX = 0; iX < pBitmap->width; ++iX, ++pIn, ++pOut)
        {
#ifndef TRUST_RENDER_COORDS
            if(x + iX < 0)
                continue;
            if(x + iX >= pCacheEntry->iWidth)
                break;
#endif
            unsigned int iIn = *pIn;
            unsigned int iOut = *pOut;
            uint8_t cMerged = static_cast<uint8_t>(iIn + iOut - (iIn * iOut) / 255);
            *pOut = cMerged;
        }
    }
}

#endif // CORSIX_TH_USE_FREETYPE2
