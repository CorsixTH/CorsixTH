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

#ifndef CORSIX_TH_TH_GFX_FONT_H_
#define CORSIX_TH_TH_GFX_FONT_H_
#include "th_gfx.h"
#ifdef CORSIX_TH_USE_FREETYPE2
#include <ft2build.h>
#include FT_FREETYPE_H
#endif

enum eTHAlign
{
    Align_Left = 0,
    Align_Center = 1,
    Align_Right = 2,
};

/** Structure for the bounds of a text string that is rendered to the screen. */
struct THFontDrawArea
{
    //! Number of rows the rendered text spans
    int iNumRows;

    //! Left X-coordinate for the start of the text
    int iStartX;

    //! Right X-coordinate for the right part of the last letter rendered
    int iEndX;

    //! Top Y-coordinate for the start of the text
    int iStartY;

    //! Bottom Y-coordinate for the end of the text
    int iEndY;

    //! Width of the widest line in the text
    int iWidth;
};

class THFont
{
public:
    virtual ~THFont() = default;

    //! Get the size of drawn text.
    /*!
        If iMaxWidth is specified the text will wrap, so that the height can
        span multiple rows. Otherwise gets the size of a single line of text.
        @param sMessage A UTF-8 encoded string containing a single line of text
            to measure the width and height of.
        @param iMessageLength The length, in bytes (not characters), of the
            string at sMessage.
        @param iMaxWidth The maximum length, in pixels, that the text may
            occupy. Default is INT_MAX.
    */
    virtual THFontDrawArea getTextSize(const char* sMessage, size_t iMessageLength,
                                       int iMaxWidth = INT_MAX) const = 0;

    //! Draw a single line of text
    /*!
        @param pCanvas The render target to draw onto.
        @param sMessage A UTF-8 encoded string containing a single line of text
            to draw.
        @param iMessageLength The length, in bytes (not characters), of the
            string at sMessage.
        @param iX The X coordinate of the top-left corner of the bounding
            rectangle for the drawn text.
        @param iY The Y coordinate of the top-left corner of the bounding
            rectangle for the drawn text.
    */
    virtual void drawText(THRenderTarget* pCanvas, const char* sMessage,
                          size_t iMessageLength, int iX, int iY) const = 0;

    //! Draw a single line of text, splitting it at word boundaries
    /*!
        This function still only draws a single line of text (i.e. any line
        breaks like \r and \n in sMessage are ignored), but inserts line breaks
        between words so that no single line is wider than iWidth pixels.
        If iMaxRows is specified it will simply cut after that many rows.
        @param pCanvas The canvas on which to draw. Can be nullptr, in which case
          nothing is drawn, but other calculations are still made.
        @param sMessage The line of text to draw, encoded in CP437.
        @param iMessageLength The length (in bytes) of sMessage.
        @param iX The X position to start drawing on the canvas.
        @param iY The Y position to start drawing on the canvas.
        @param iWidth The maximum width of each line of text.
        @param iMaxRows The maximum number of rows to draw. Default is INT_MAX.
        @param iSkipRows Start rendering text after skipping this many rows.
        @param eAlign How to align each line of text if the width of the line
          of text is smaller than iWidth.
    */
    virtual THFontDrawArea drawTextWrapped(THRenderTarget* pCanvas, const char* sMessage,
                                           size_t iMessageLength, int iX, int iY,
                                           int iWidth, int iMaxRows = INT_MAX, int iSkipRows = 0,
                                           eTHAlign eAlign = Align_Left) const = 0;
};

class THBitmapFont final : public THFont
{
public:
    THBitmapFont();

    //! Set the character glyph sprite sheet
    /*!
        The sprite sheet should have the space character (ASCII 0x20) at sprite
        index 1, and other ASCII characters following on in simple order (i.e.
        '!' (ASCII 0x21) at index 2, 'A' (ASCII 0x41) at index 34, etc.)
    */
    void setSpriteSheet(THSpriteSheet* pSpriteSheet);

    THSpriteSheet* getSpriteSheet() {return m_pSpriteSheet;}

    //! Set the separation between characters and between lines
    /*!
        Generally, the sprite sheet glyphs will already include separation, and
        thus no extra separation is required (set iCharSep and iLineSep to 0).
    */
    void setSeparation(int iCharSep, int iLineSep);

    THFontDrawArea getTextSize(const char* sMessage, size_t iMessageLength,
                               int iMaxWidth = INT_MAX) const override;

    void drawText(THRenderTarget* pCanvas, const char* sMessage,
                  size_t iMessageLength, int iX, int iY) const override;

    THFontDrawArea drawTextWrapped(THRenderTarget* pCanvas, const char* sMessage,
                                   size_t iMessageLength, int iX, int iY,
                                   int iWidth, int iMaxRows = INT_MAX, int iSkipRows = 0,
                                   eTHAlign eAlign = Align_Left) const override;

private:
    THSpriteSheet* m_pSpriteSheet;
    int m_iCharSep;
    int m_iLineSep;
};

#ifdef CORSIX_TH_USE_FREETYPE2
//! Adaptor around the FreeType2 library to a THFont.
/*!
    Due to the relatively high cost of rendering a message with FreeType, this
    class implements internal caching of messages, so rendering a message once
    will be quite expensive, but subsequently rendering the same message again
    will be quite cheap (provided that it hasn't fallen out of the cache).

    Unlike THBitmapFont which sits entirely on top of existing interfaces, some
    of the internal methods of this class are implemented by each individual
    rendering engine (said methods are roughly for the equivalent of the
    THRawBitmap class, but with an alpha channel, and a single colour rather
    than a palette).
*/
class THFreeTypeFont final : public THFont
{
public:
    THFreeTypeFont();
    ~THFreeTypeFont();

    //! Get the copyright notice which should be displayed for FreeType2.
    /*!
        To comply with the FreeType2 license, the string returned by this
        function needs to be displayed at some point.
        @return A null-terminated UTF-8 encoded string.
    */
    static const char* getCopyrightNotice();

    //! Initialise the FreeType2 library.
    /*!
        This will be called automatically by setFace() as required.
    */
    FT_Error initialise();

    //! Remove all cached strings, as our graphics context has changed
    void clearCache();

    //! Set the font face to be used.
    /*!
        @param pData Pointer to the start of a font file loaded into memory.
            This block of memory must remain valid for at least the lifetime
            of the THFreeTypeFont objcect.
        @param iLength The size, in bytes, of the font file at pData.
    */
    FT_Error setFace(const uint8_t* pData, size_t iLength);

    //! Set the font size and colour to match that of a bitmap font.
    /*!
        Note that the matching is done on a best-effort basis, and will likely
        not be perfect. This must be called after setFace().

        @param pBitmapFontSpriteSheet The sprite sheet of the bitmap font.
    */
    FT_Error matchBitmapFont(THSpriteSheet* pBitmapFontSpriteSheet);

    //! Set the ideal character size using pixel values.
    /*!
        Note that the given size might be changed a small amount if doing so
        would result in a much nicer rendered font. This must be called after
        setFace().
    */
    FT_Error setPixelSize(int iWidth, int iHeight);

    THFontDrawArea getTextSize(const char* sMessage, size_t iMessageLength,
                               int iMaxWidth = INT_MAX) const override;

    void drawText(THRenderTarget* pCanvas, const char* sMessage,
                  size_t iMessageLength, int iX, int iY) const override;

    THFontDrawArea drawTextWrapped(THRenderTarget* pCanvas, const char* sMessage,
                                   size_t iMessageLength, int iX, int iY,
                                   int iWidth, int iMaxRows = INT_MAX, int iSkipRows = 0,
                                   eTHAlign eAlign = Align_Left) const override;

private:
    struct cached_text_t
    {
        //! The text being converted to pixels
        char* sMessage;

        //! Raw pixel data in row major 8-bit greyscale
        uint8_t* pData;

        //! Generated texture ready to be rendered
        void* pTexture;

        //! The length of sMessage
        size_t iMessageLength;

        //! The size of the buffer allocated to store sMessage
        size_t iMessageBufferLength;

        //! Width of the image to draw
        int iWidth;

        //! Height of the image to draw
        int iHeight;

        //! The width of the longest line of text in in the textbox in pixels
        int iWidestLine;

        //! X Coordinate trailing the last character in canvas coordinates
        int iLastX;

        //! Number of rows required
        int iNumRows;

        //! Alignment of the message in the box
        eTHAlign eAlign;

        //! True when the pData reflects the sMessage given the size constraints
        bool bIsValid;
    };

    //! Render a FreeType2 monochrome bitmap to a cache canvas.
    void _renderMono(cached_text_t *pCacheEntry, FT_Bitmap* pBitmap, FT_Pos x, FT_Pos y) const;

    //! Render a FreeType2 grayscale bitmap to a cache canvas.
    void _renderGray(cached_text_t *pCacheEntry, FT_Bitmap* pBitmap, FT_Pos x, FT_Pos y) const;

    static FT_Library ms_pFreeType;
    static int ms_iFreeTypeInitCount;
    static const int ms_CacheSizeLog2 = 7;
    FT_Face m_pFace;
    THColour m_oColour;
    bool m_bDoneFreeTypeInit;
    mutable cached_text_t m_aCache[1 << ms_CacheSizeLog2];

    // The following five methods are implemented by the rendering engine.

    //! Query if 1-bit monochrome or 8-bit grayscale rendering should be used.
    /*!
        @return true if 1-bit monochrome rendering should be used, false if
            8-bit grayscale rendering should be used (though in the latter
            case, 1-bit rendering might still get used).
    */
    bool _isMonochrome() const;

    //! Convert a cache canvas containing rendered text into a texture.
    /*!
        @param pEventualCanvas A pointer to the rendertarget we'll be using to
            draw this.
        @param pCacheEntry A cache entry whose pData field points to a pixmap
            of size iWidth by iHeight. This method will convert said pixmap to
            an object which can be used by the rendering engine, and store the
            result in the pTexture or iTexture field.
    */
    void _makeTexture(THRenderTarget *pEventualCanvas, cached_text_t* pCacheEntry) const;

    //! Free a previously-made texture of a cache entry.
    /*!
        This call should free all the resources previously allocated by a call
        to _makeTexture() and set the texture field to indicate no texture.

        @param pCacheEntry A cache entry previously passed to _makeTexture().
    */
    void _freeTexture(cached_text_t* pCacheEntry) const;

    //! Render a previously-made texture of a cache entry.
    /*!
        @param pCanvas The canvas on which to draw.
        @param pCacheEntry A cache entry containing the texture to draw, which
            will have been stored in the pTexture or iTexture field by a prior
            call to _makeTexture().
        @param iX The X position at which to draw the texture on the canvas.
        @param iY The Y position at which to draw the texture on the canvas.
    */
    void _drawTexture(THRenderTarget* pCanvas, cached_text_t* pCacheEntry,
                      int iX, int iY) const;
};
#endif // CORSIX_TH_USE_FREETYPE2

#endif // CORSIX_TH_TH_GFX_FONT_H_
