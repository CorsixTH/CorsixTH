/*
Copyright (c) 2009-2013 Peter "Corsix" Cawley and Edvin "Lego3" Linge

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

#ifndef CORSIX_TH_TH_GFX_SDL_H_
#define CORSIX_TH_TH_GFX_SDL_H_
#include "config.h"

#include <SDL.h>
#include "persist_lua.h"

class cursor;
struct clip_rect : public SDL_Rect {
    typedef Sint16 x_y_type;
    typedef Uint16 w_h_type;
};
struct render_target_creation_params;

/*!
    Utility class for decoding 32bpp images.
*/
class full_colour_renderer
{
public:
    //! Initialize the renderer for a specific render.
    /*!
        @param iWidth Pixel width of the resulting image
        @param iHeight Pixel height of the resulting image
    */
    full_colour_renderer(int iWidth, int iHeight);
    virtual ~full_colour_renderer() = default;

    //! Decode a 32bpp image, and push it to the storage backend.
    /*!
        @param pImg Encoded 32bpp image.
        @param pPalette Palette of a legacy sprite.
        @param iSpriteFlags Flags how to render the sprite.
        @return Decoding was successful.
    */
    bool decode_image(const uint8_t* pImg, const ::palette *pPalette, uint32_t iSpriteFlags);

private:
    //! Store a decoded pixel. Use x and y if necessary.
    /*!
        @param pixel Pixel to store.
    */
    virtual void store_argb(uint32_t pixel) = 0;

    const int width;
    const int height;
    int x;
    int y;

    //! Push a pixel to the storage.
    /*!
        @param iValue Pixel value to store.
    */
    inline void push_pixel(uint32_t iValue)
    {
        if (y < height)
        {
            store_argb(iValue);
            x++;
            if (x >= width)
            {
                x = 0;
                y++;
            }
        }
        else
        {
            x = 1; // Will return 'failed'.
        }
    }
};

class full_colour_storing : public full_colour_renderer
{
public:
    full_colour_storing(uint32_t *pDest, int iWidth, int iHeight);

private:
    void store_argb(uint32_t pixel) override;

    //! Pointer to the storage (not owned by this class).
    uint32_t *destination;
};

class wx_storing : public full_colour_renderer
{
public:
    wx_storing(uint8_t* pRGBData, uint8_t* pAData, int iWidth, int iHeight);

private:
    void store_argb(uint32_t pixel) override;

    //! Pointer to the RGB storage (not owned by this class).
    uint8_t *rgb_data;

    //! Pointer to the Alpha channel storage (not owned by this class).
    uint8_t *alpha_data;
};

class render_target
{
public: // External API
    render_target();
    ~render_target();

    //! Initialise the render target
    bool create(const render_target_creation_params* pParams);

    //! Update the parameters for the render target
    bool update(const render_target_creation_params* pParams);

    //! Shut down the render target
    void destroy();

    //! Get the reason for the last operation failing
    const char* get_last_error();

    //! Begin rendering a new frame
    bool start_frame();

    //! Finish rendering the current frame and present it
    bool end_frame();

    //! Paint the entire render target black
    bool fill_black();

    //! Sets a blue filter on the current surface.
    // Used to add the blue effect when the game is paused.
    void set_blue_filter_active(bool bActivate);

    //! Encode an RGB triplet for fillRect()
    uint32_t map_colour(uint8_t iR, uint8_t iG, uint8_t iB);

    //! Fill a rectangle of the render target with a solid colour
    bool fill_rect(uint32_t iColour, int iX, int iY, int iW, int iH);

    //! Get the current clip rectangle
    void get_clip_rect(clip_rect* pRect) const;

    //! Get the width of the render target (in pixels)
    int get_width() const;

    //! Get the height of the render target (in pixels)
    int get_height() const;

    //! Set the new clip rectangle
    void set_clip_rect(const clip_rect* pRect);

    //! Enable optimisations for non-overlapping draws
    void start_nonoverlapping_draws();

    //! Disable optimisations for non-overlapping draws
    void finish_nonoverlapping_draws();

    //! Set the cursor to be used
    void set_cursor(cursor* pCursor);

    //! Update the cursor position (if the cursor is being simulated)
    void set_cursor_position(int iX, int iY);

    //! Take a screenshot and save it as a bitmap
    bool take_screenshot(const char* sFile);

    //! Set the amount by which future draw operations are scaled.
    /*!
        @param fScale New scale to use.
        @param eWhatToScale Th kind of items to scale.
        @return Whether the scale could be set.
     */
    bool set_scale_factor(double fScale, scaled_items eWhatToScale);

    //! Set the window caption
    void set_caption(const char* sCaption);
	
    //! Toggle mouse capture on the window.
    void set_window_grab(bool bActivate);

    //! Get any user-displayable information to describe the renderer path used
    const char *get_renderer_details() const;

    // If you add any extra methods here which are called from outside the
    // rendering engine, then be sure to at least add dummy implementations
    // to the other rendering engines.

public: // Internal (this rendering engine only) API
    SDL_Renderer *get_renderer() const { return renderer; }

    //! Should bitmaps be scaled?
    /*!
        @param [out] pFactor If the function returns \c true, the factor to use
            for scaling (can be \c nullptr if not interested in the value).
        @return Whether bitmaps should be scaled.
     */
    bool should_scale_bitmaps(double* pFactor);

    SDL_Texture* create_palettized_texture(int iWidth, int iHeight, const uint8_t* pPixels,
                                           const ::palette* pPalette, uint32_t iSpriteFlags) const;
    SDL_Texture* create_texture(int iWidth, int iHeight, const uint32_t* pPixels) const;
    void draw(SDL_Texture *pTexture, const SDL_Rect *prcSrcRect, const SDL_Rect *prcDstRect, int iFlags);
    void draw_line(line *pLine, int iX, int iY);

private:
    SDL_Window *window;
    SDL_Renderer *renderer;
    SDL_Texture *zoom_texture;
    SDL_PixelFormat *pixel_format;
    bool blue_filter_active;
    cursor* game_cursor;
    double bitmap_scale_factor; ///< Bitmap scale factor.
    int width;
    int height;
    int cursor_x;
    int cursor_y;
    bool scale_bitmaps; ///< Whether bitmaps should be scaled.
    bool supports_target_textures;

    // In SDL2 < 2.0.4 there is an issue with the y coordinates used for
    // ClipRects in opengl and opengles.
    // see: https://bugzilla.libsdl.org/show_bug.cgi?id=2700
    bool apply_opengl_clip_fix;

    void flush_zoom_buffer();
};

//! 32bpp ARGB colour. See #palette::pack_argb
typedef uint32_t argb_colour;

//! 8bpp palette class.
class palette
{
public: // External API
    palette();

    //! Load palette from the supplied data.
    /*!
        Note that the data uses palette entries of 6 bit colours.
        @param pData Data loaded from the file.
        @param iDataLength Size of the data.
        @return Whether loading of the palette succeeded.
    */
    bool load_from_th_file(const uint8_t* pData, size_t iDataLength);

    //! Set an entry of the palette.
    /*!
        The RGB colour (255, 0, 255) is used as the transparent colour.
        @param iEntry Entry number to change.
        @param iR Amount of red in the new entry.
        @param iG Amount of green in the new entry.
        @param iB Amount of blue in the new entry.
        @return Setting the entry succeeded.
    */
    bool set_entry(int iEntry, uint8_t iR, uint8_t iG, uint8_t iB);

public: // Internal (this rendering engine only) API

    //! Convert A, R, G, B values to a 32bpp colour.
    /*!
        @param iA Amount of opacity (0-255).
        @param iR Amount of red (0-255).
        @param iG Amount of green (0-255).
        @param iB Amount of blue (0-255).
        @return 32bpp value representing the provided colour values.
    */
    inline static argb_colour pack_argb(uint8_t iA, uint8_t iR, uint8_t iG, uint8_t iB)
    {
        return (static_cast<argb_colour>(iR) <<  0) |
        (static_cast<argb_colour>(iG) <<  8) |
        (static_cast<argb_colour>(iB) << 16) |
        (static_cast<argb_colour>(iA) << 24) ;
    }

    //! Get the red component of a colour.
    /*!
        @param iColour Colour to examine.
        @return The red component intensity of the colour.
    */
    inline static uint8_t get_red(argb_colour iColour)
    {
        return static_cast<uint8_t>((iColour >> 0) & 0xFF);
    }

    //! Get the green component of a colour.
    /*!
        @param iColour Colour to examine.
        @return The green component intensity of the colour.
    */
    inline static uint8_t get_green(argb_colour iColour)
    {
        return static_cast<uint8_t>((iColour >> 8) & 0xFF);
    }

    //! Get the blue component of a colour.
    /*!
        @param iColour Colour to examine.
        @return The blue component intensity of the colour.
    */
    inline static uint8_t get_blue(argb_colour iColour)
    {
        return static_cast<uint8_t>((iColour >> 16) & 0xFF);
    }

    //! Get the opacity component of a colour.
    /*!
        @param iColour Colour to examine.
        @return The opacity of the colour.
    */
    inline static uint8_t get_alpha(argb_colour iColour)
    {
        return static_cast<uint8_t>((iColour >> 24) & 0xFF);
    }

    //! Get the number of colours in the palette.
    /*!
        @return The number of colours in the palette.
    */
    int get_colour_count() const;

    //! Get the internal palette data for fast (read-only) access.
    /*!
        @return Table with all 256 colours of the palette.
    */
    const argb_colour* get_argb_data() const;

    //! Set an entry of the palette.
    /*!
        @param iEntry Entry to modify.
        @param iVal Palette value to set.
    */
    inline void set_argb(int iEntry, uint32_t iVal)
    {
        colour_index_to_argb_map[iEntry] = iVal;
    }

private:
    //! 32bpp palette colours associated with the 8bpp colour index.
    uint32_t colour_index_to_argb_map[256];

    //! Number of colours in the palette.
    int colour_count;
};

//! Stored image.
class raw_bitmap
{
public:
    raw_bitmap();
    ~raw_bitmap();

    //! Set the palette of the image.
    /*!
        @param pPalette Palette to set for this image.
    */
    void set_palette(const ::palette* pPalette);

    //! Load the image from the supplied pixel data.
    /*!
        Loader uses the palette supplied before.
        @param pPixelData Image data loaded from a TH file.
        @param iPixelDataLength Size of the loaded image data.
        @param iWidth Width of the image.
        @param pEventualCanvas Canvas to render the image to (eventually).
        @return Loading was a success.
    */
    bool load_from_th_file(const uint8_t* pPixelData, size_t iPixelDataLength,
                           int iWidth, render_target *pEventualCanvas);

    //! Draw the image at a given position at the given canvas.
    /*!
        @param pCanvas Canvas to draw at.
        @param iX Destination x position.
        @param iY Destination y position.
    */
    void draw(render_target* pCanvas, int iX, int iY);

    //! Draw part of the image at a given position at the given canvas.
    /*!
        @param pCanvas Canvas to draw at.
        @param iX Destination x position.
        @param iY Destination y position.
        @param iSrcX X position of the part to display.
        @param iSrcY Y position of the part to display.
        @param iWidth Width of the part to display.
        @param iHeight Height of the part to display.
    */
    void draw(render_target* pCanvas, int iX, int iY, int iSrcX, int iSrcY,
              int iWidth, int iHeight);

private:
    //! Image stored in SDL format for quick rendering.
    SDL_Texture *texture;

    //! Palette of the image.
    const ::palette* bitmap_palette;

    //! Target canvas.
    render_target* target;

    //! Width of the stored image.
    int width;

    //! Height of the stored image.
    int height;
};

//! Sheet of sprites.
class sprite_sheet
{
public: // External API
    sprite_sheet();
    ~sprite_sheet();

    //! Set the palette to use for the sprites in the sheet.
    /*!
        @param pPalette Palette to use for the sprites at the sheet.
    */
    void set_palette(const ::palette* pPalette);

    //! Load the sprites from the supplied data (using the palette supplied earlier).
    /*!
        @param pTableData Start of table data with TH sprite information (see th_sprite_properties).
        @param iTableDataLength Length of the table data.
        @param pChunkData Start of image data (chunks).
        @param iChunkDataLength Length of the chunk data.
        @param bComplexChunks Whether the supplied chunks are 'complex'.
        @param pEventualCanvas Canvas to draw at.
        @return Loading succeeded.
    */
    bool load_from_th_file(const uint8_t* pTableData, size_t iTableDataLength,
                           const uint8_t* pChunkData, size_t iChunkDataLength,
                           bool bComplexChunks, render_target* pEventualCanvas);

    //! Set the data of a sprite.
    /*!
        @param iSprite Number of the sprite to set.
        @param pData Data of the sprite.
        @param bTakeData Whether the data block may be taken (must be new[] then).
        @param iDataLength Length of the data.
        @param iWidth Width of the sprite.
        @param iHeight Height of the sprite.
        @return Setting the sprite succeeded.
    */
    bool set_sprite_data(size_t iSprite, const uint8_t *pData, bool bTakeData,
                         size_t iDataLength, int iWidth, int iHeight);

    //! Supply a new mapped palette to a sprite.
    /*!
        @param iSprite Sprite getting the mapped palette.
        @param pMap The palette map to apply.
        @param iAlt32 What to do for a 32bpp sprite (#THDF_Alt32_Mask bits).
    */
    void set_sprite_alt_palette_map(size_t iSprite, const uint8_t* pMap, uint32_t iAlt32);

    //! Get the number of sprites at the sheet.
    /*!
        @return The number of sprites available at the sheet.
    */
    size_t get_sprite_count() const;

    //! Set the number of sprites in the sheet.
    /*!
        @param iCount The desired number of sprites.
        @param pCanvas Canvas to draw at.
        @return Whether the number of sprites could be allocated.
    */
    bool set_sprite_count(size_t iCount, render_target* pCanvas);

    //! Get size of a sprite.
    /*!
        @param iSprite Sprite to get info from.
        @param pWidth [out] If not nullptr, the sprite width is stored in the destination.
        @param pHeight [out] If not nullptr, the sprite height is stored in the destination.
        @return Size could be provided for the sprite.
    */
    bool get_sprite_size(size_t iSprite, unsigned int* pWidth, unsigned int* pHeight) const;

    //! Get size of a sprite, assuming all input is correctly supplied.
    /*!
        @param iSprite Sprite to get info from.
        @param pWidth [out] The sprite width is stored in the destination.
        @param pHeight [out] The sprite height is stored in the destination.
    */
    void get_sprite_size_unchecked(size_t iSprite, unsigned int* pWidth, unsigned int* pHeight) const;

    //! Get the best colour to represent the sprite.
    /*!
        @param iSprite Sprite number to analyze.
        @param pColour [out] Resulting colour.
        @return Best colour could be established.
    */
    bool get_sprite_average_colour(size_t iSprite, argb_colour* pColour) const;

    //! Draw a sprite onto the canvas.
    /*!
        @param pCanvas Canvas to draw on.
        @param iSprite Sprite to draw.
        @param iX X position to draw the sprite.
        @param iY Y position to draw the sprite.
        @param iFlags Flags to apply for drawing.
    */
    void draw_sprite(render_target* pCanvas, size_t iSprite, int iX, int iY, uint32_t iFlags);

    //! Test whether a sprite was hit.
    /*!
        @param iSprite Sprite being tested.
        @param iX X position of the point to test relative to the origin of the sprite.
        @param iY Y position of the point to test relative to the origin of the sprite.
        @param iFlags Draw flags to apply to the sprite before testing.
        @return Whether the sprite covers the give point.
    */
    bool hit_test_sprite(size_t iSprite, int iX, int iY, uint32_t iFlags) const;

public: // Internal (this rendering engine only) API
    //! Draw a sprite into wxImage data arrays (for the Map Editor)
    /*!
        @param iSprite Sprite number to draw.
        @param pRGBData Output RGB data array.
        @param pAData Output Alpha channel array.
    */
    void wx_draw_sprite(size_t iSprite, uint8_t* pRGBData, uint8_t* pAData);

private:
    friend class cursor;
#if CORSIX_TH_USE_PACK_PRAGMAS
#pragma pack(push)
#pragma pack(1)
#endif
    //! Sprite structure in the table file.
    struct th_sprite_properties
    {
        //! Position of the sprite in the chunk data file.
        uint32_t position;

        //! Width of the sprite.
        uint8_t width;

        //! Height of the sprite.
        uint8_t height;
    } CORSIX_TH_PACKED_FLAGS;
#if CORSIX_TH_USE_PACK_PRAGMAS
#pragma pack(pop)
#endif

    //! Sprites of the sheet.
    struct sprite
    {
        //! SDL structure containing the sprite with original palette.
        SDL_Texture *texture;

        //! SDL structure containing the sprite with alternative palette.
        SDL_Texture *alt_texture;

        //! Data of the sprite.
        const uint8_t *data;

        //! Alternative palette (if available).
        const uint8_t *alt_palette_map;

        //! Flags how to render the sprite, contains #THDF_Alt32_Mask bits.
        uint32_t sprite_flags;

        //! Width of the sprite.
        int width;

        //! Height of the sprite.
        int height;
    } *sprites;

    //! Original palette.
    const ::palette* palette;

    //! Target to render to.
    render_target* target;

    //! Number of sprites in the sprite sheet.
    size_t sprite_count;

    //! Free memory of a single sprite.
    /*!
        @param iNumber Number of the sprite to clear.
    */
    void _freeSingleSprite(size_t iNumber);

    //! Free the memory used by the sprites. Also releases the SDL bitmaps.
    void _freeSprites();

    //! Construct an alternative version (with its alternative palette map) of the sprite.
    /*!
        @param pSprite Sprite to change.
        @return SDL texture containing the sprite.
    */
    SDL_Texture *_makeAltBitmap(sprite *pSprite);
};

class cursor
{
public:
    cursor();
    ~cursor();

    bool create_from_sprite(sprite_sheet* pSheet, size_t iSprite,
                            int iHotspotX = 0, int iHotspotY = 0);

    void use(render_target* pTarget);

    static bool set_position(render_target* pTarget, int iX, int iY);

    void draw(render_target* pCanvas, int iX, int iY);
private:
    SDL_Surface* bitmap;
    SDL_Cursor* hidden_cursor;
    int hotspot_x;
    int hotspot_y;
};


class line
{
public:
    line();
    ~line();

    void move_to(double fX, double fY);

    void line_to(double fX, double fY);

    void set_width(double lineWidth);

    void draw(render_target* pCanvas, int iX, int iY);

    void set_colour(uint8_t iR, uint8_t iG, uint8_t iB, uint8_t iA = 255);

    void persist(lua_persist_writer *pWriter) const;
    void depersist(lua_persist_reader *pReader);

private:
    friend class render_target;
    void initialize();

    enum class line_operation_type {
        move,
        line
    };

    class line_operation : public link_list
    {
    public:
        line_operation_type type;
        double x, y;
        line_operation(line_operation_type type, double x, double y) : type(type), x(x), y(y) {
            next = nullptr;
        }
    };

    line_operation* first_operation;
    line_operation* current_operation;
    double width;
    uint8_t red, green, blue, alpha;
};

#endif // CORSIX_TH_TH_GFX_SDL_H_
