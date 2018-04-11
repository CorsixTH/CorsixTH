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

enum class text_alignment {
    left = 0,
    center = 1,
    right = 2,
};

/** Structure for the bounds of a text string that is rendered to the screen. */
struct text_layout
{
    //! Number of rows the rendered text spans
    int row_count;

    //! Left X-coordinate for the start of the text
    int start_x;

    //! Right X-coordinate for the right part of the last letter rendered
    int end_x;

    //! Top Y-coordinate for the start of the text
    int start_y;

    //! Bottom Y-coordinate for the end of the text
    int end_y;

    //! Width of the widest line in the text
    int width;
};

class font
{
public:
    virtual ~font() = default;

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
    virtual text_layout get_text_dimensions(const char* sMessage, size_t iMessageLength,
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
    virtual void draw_text(render_target* pCanvas, const char* sMessage,
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
    virtual text_layout draw_text_wrapped(render_target* pCanvas, const char* sMessage,
            size_t iMessageLength, int iX, int iY,
            int iWidth, int iMaxRows = INT_MAX, int iSkipRows = 0,
            text_alignment eAlign = text_alignment::left) const = 0;
};

class bitmap_font final : public font
{
public:
    bitmap_font();

    //! Set the character glyph sprite sheet
    /*!
        The sprite sheet should have the space character (ASCII 0x20) at sprite
        index 1, and other ASCII characters following on in simple order (i.e.
        '!' (ASCII 0x21) at index 2, 'A' (ASCII 0x41) at index 34, etc.)
    */
    void set_sprite_sheet(sprite_sheet* pSpriteSheet);

    sprite_sheet* get_sprite_sheet() {return sheet;}

    //! Set the separation between characters and between lines
    /*!
        Generally, the sprite sheet glyphs will already include separation, and
        thus no extra separation is required (set iCharSep and iLineSep to 0).
    */
    void set_separation(int iCharSep, int iLineSep);

    text_layout get_text_dimensions(const char* sMessage, size_t iMessageLength,
            int iMaxWidth = INT_MAX) const override;

    void draw_text(render_target* pCanvas, const char* sMessage,
                   size_t iMessageLength, int iX, int iY) const override;

    text_layout draw_text_wrapped(render_target* pCanvas, const char* sMessage,
            size_t iMessageLength, int iX, int iY,
            int iWidth, int iMaxRows = INT_MAX, int iSkipRows = 0,
            text_alignment eAlign = text_alignment::left) const override;

private:
    sprite_sheet* sheet;
    int letter_spacing;
    int line_spacing;
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
class freetype_font final : public font
{
public:
    freetype_font();
    ~freetype_font();

    //! Get the copyright notice which should be displayed for FreeType2.
    /*!
        To comply with the FreeType2 license, the string returned by this
        function needs to be displayed at some point.
        @return A null-terminated UTF-8 encoded string.
    */
    static const char* get_copyright_notice();

    //! Initialise the FreeType2 library.
    /*!
        This will be called automatically by setFace() as required.
    */
    FT_Error initialise();

    //! Remove all cached strings, as our graphics context has changed
    void clear_cache();

    //! Set the font face to be used.
    /*!
        @param pData Pointer to the start of a font file loaded into memory.
            This block of memory must remain valid for at least the lifetime
            of the THFreeTypeFont objcect.
        @param iLength The size, in bytes, of the font file at pData.
    */
    FT_Error set_face(const uint8_t* pData, size_t iLength);

    //! Set the font size and colour to match that of a bitmap font.
    /*!
        Note that the matching is done on a best-effort basis, and will likely
        not be perfect. This must be called after setFace().

        @param pBitmapFontSpriteSheet The sprite sheet of the bitmap font.
    */
    FT_Error match_bitmap_font(sprite_sheet* pBitmapFontSpriteSheet);

    //! Set the ideal character size using pixel values.
    /*!
        Note that the given size might be changed a small amount if doing so
        would result in a much nicer rendered font. This must be called after
        setFace().
    */
    FT_Error set_ideal_character_size(int iWidth, int iHeight);

    text_layout get_text_dimensions(const char* sMessage, size_t iMessageLength,
            int iMaxWidth = INT_MAX) const override;

    void draw_text(render_target* pCanvas, const char* sMessage,
                   size_t iMessageLength, int iX, int iY) const override;

    text_layout draw_text_wrapped(render_target* pCanvas, const char* sMessage,
            size_t iMessageLength, int iX, int iY,
            int iWidth, int iMaxRows = INT_MAX, int iSkipRows = 0,
            text_alignment eAlign = text_alignment::left) const override;

private:
    struct cached_text
    {
        //! The text being converted to pixels
        char* message;

        //! Raw pixel data in row major 8-bit greyscale
        uint8_t* data;

        //! Generated texture ready to be rendered
        SDL_Texture* texture;

        //! The length of sMessage
        size_t message_length;

        //! The size of the buffer allocated to store sMessage
        size_t message_buffer_length;

        //! Width of the image to draw
        int width;

        //! Height of the image to draw
        int height;

        //! The width of the longest line of text in in the textbox in pixels
        int widest_line_width;

        //! X Coordinate trailing the last character in canvas coordinates
        int last_x;

        //! Number of rows required
        int row_count;

        //! Alignment of the message in the box
        text_alignment alignment;

        //! True when the data reflects the message given the size constraints
        bool is_valid;
    };

    //! Render a FreeType2 monochrome bitmap to a cache canvas.
    void render_mono(cached_text *pCacheEntry, FT_Bitmap* pBitmap, FT_Pos x, FT_Pos y) const;

    //! Render a FreeType2 grayscale bitmap to a cache canvas.
    void render_gray(cached_text *pCacheEntry, FT_Bitmap* pBitmap, FT_Pos x, FT_Pos y) const;

    static FT_Library freetype_library;
    static int freetype_init_count;
    static const int cache_size_log2 = 7;
    FT_Face font_face;
    argb_colour colour;
    bool is_done_freetype_init;
    mutable cached_text cache[1 << cache_size_log2];

    // The following five methods are implemented by the rendering engine.

    //! Query if 1-bit monochrome or 8-bit grayscale rendering should be used.
    /*!
        @return true if 1-bit monochrome rendering should be used, false if
            8-bit grayscale rendering should be used (though in the latter
            case, 1-bit rendering might still get used).
    */
    bool is_monochrome() const;

    //! Convert a cache canvas containing rendered text into a texture.
    /*!
        @param pEventualCanvas A pointer to the rendertarget we'll be using to
            draw this.
        @param pCacheEntry A cache entry whose pData field points to a pixmap
            of size iWidth by iHeight. This method will convert said pixmap to
            an object which can be used by the rendering engine, and store the
            result in the pTexture or iTexture field.
    */
    void make_texture(render_target *pEventualCanvas, cached_text* pCacheEntry) const;

    //! Free a previously-made texture of a cache entry.
    /*!
        This call should free all the resources previously allocated by a call
        to _makeTexture() and set the texture field to indicate no texture.

        @param pCacheEntry A cache entry previously passed to _makeTexture().
    */
    void free_texture(cached_text* pCacheEntry) const;

    //! Render a previously-made texture of a cache entry.
    /*!
        @param pCanvas The canvas on which to draw.
        @param pCacheEntry A cache entry containing the texture to draw, which
            will have been stored in the pTexture or iTexture field by a prior
            call to _makeTexture().
        @param iX The X position at which to draw the texture on the canvas.
        @param iY The Y position at which to draw the texture on the canvas.
    */
    void draw_texture(render_target* pCanvas, cached_text* pCacheEntry,
                      int iX, int iY) const;
};
#endif // CORSIX_TH_USE_FREETYPE2

#endif // CORSIX_TH_TH_GFX_FONT_H_
