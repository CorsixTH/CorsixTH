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

class THCursor;
struct THClipRect : public SDL_Rect
{
    typedef Sint16 xy_t;
    typedef Uint16 wh_t;
};
struct THRenderTargetCreationParams;

/*!
    Utility class for decoding 32bpp images.
*/
class FullColourRenderer
{
public:
    //! Initialize the renderer for a specific render.
    /*!
        @param iWidth Pixel width of the resulting image
        @param iHeight Pixel height of the resulting image
    */
    FullColourRenderer(int iWidth, int iHeight);
    virtual ~FullColourRenderer() = default;

    //! Decode a 32bpp image, and push it to the storage backend.
    /*!
        @param pImg Encoded 32bpp image.
        @param pPalette Palette of a legacy sprite.
        @param iSpriteFlags Flags how to render the sprite.
        @return Decoding was successful.
    */
    bool decodeImage(const uint8_t* pImg, const THPalette *pPalette, uint32_t iSpriteFlags);

private:
    //! Store a decoded pixel. Use m_iX and m_iY if necessary.
    /*!
        @param pixel Pixel to store.
    */
    virtual void storeARGB(uint32_t pixel) = 0;

    const int m_iWidth;
    const int m_iHeight;
    int m_iX;
    int m_iY;

    //! Push a pixel to the storage.
    /*!
        @param iValue Pixel value to store.
    */
    inline void _pushPixel(uint32_t iValue)
    {
        if (m_iY < m_iHeight)
        {
            storeARGB(iValue);
            m_iX++;
            if (m_iX >= m_iWidth)
            {
                m_iX = 0;
                m_iY++;
            }
        }
        else
        {
            m_iX = 1; // Will return 'failed'.
        }
    }
};

class FullColourStoring : public FullColourRenderer
{
public:
    FullColourStoring(uint32_t *pDest, int iWidth, int iHeight);

private:
    void storeARGB(uint32_t pixel) override;

    //! Pointer to the storage (not owned by this class).
    uint32_t *m_pDest;
};

class WxStoring : public FullColourRenderer
{
public:
    WxStoring(uint8_t* pRGBData, uint8_t* pAData, int iWidth, int iHeight);

private:
    void storeARGB(uint32_t pixel) override;

    //! Pointer to the RGB storage (not owned by this class).
    uint8_t *m_pRGBData;

    //! Pointer to the Alpha channel storage (not owned by this class).
    uint8_t *m_pAData;
};

class THRenderTarget
{
public: // External API
    THRenderTarget();
    ~THRenderTarget();

    //! Initialise the render target
    bool create(const THRenderTargetCreationParams* pParams);

    //! Update the parameters for the render target
    bool update(const THRenderTargetCreationParams* pParams);

    //! Shut down the render target
    void destroy();

    //! Get the reason for the last operation failing
    const char* getLastError();

    //! Begin rendering a new frame
    bool startFrame();

    //! Finish rendering the current frame and present it
    bool endFrame();

    //! Paint the entire render target black
    bool fillBlack();

    //! Sets a blue filter on the current surface.
    // Used to add the blue effect when the game is paused.
    void setBlueFilterActive(bool bActivate);

    //! Encode an RGB triplet for fillRect()
    uint32_t mapColour(uint8_t iR, uint8_t iG, uint8_t iB);

    //! Fill a rectangle of the render target with a solid colour
    bool fillRect(uint32_t iColour, int iX, int iY, int iW, int iH);

    //! Get the current clip rectangle
    void getClipRect(THClipRect* pRect) const;

    //! Get the width of the render target (in pixels)
    int getWidth() const;

    //! Get the height of the render target (in pixels)
    int getHeight() const;

    //! Set the new clip rectangle
    void setClipRect(const THClipRect* pRect);

    //! Enable optimisations for non-overlapping draws
    void startNonOverlapping();

    //! Disable optimisations for non-overlapping draws
    void finishNonOverlapping();

    //! Set the cursor to be used
    void setCursor(THCursor* pCursor);

    //! Update the cursor position (if the cursor is being simulated)
    void setCursorPosition(int iX, int iY);

    //! Take a screenshot and save it as a bitmap
    bool takeScreenshot(const char* sFile);

    //! Set the amount by which future draw operations are scaled.
    /*!
        @param fScale New scale to use.
        @param eWhatToScale Th kind of items to scale.
        @return Whether the scale could be set.
     */
    bool setScaleFactor(double fScale, THScaledItems eWhatToScale);

    //! Set the window caption
    void setCaption(const char* sCaption);
	
    //! Toggle mouse capture on the window.
    void setWindowGrab(bool bActivate);

    //! Get any user-displayable information to describe the renderer path used
    const char *getRendererDetails() const;

    // If you add any extra methods here which are called from outside the
    // rendering engine, then be sure to at least add dummy implementations
    // to the other rendering engines.

public: // Internal (this rendering engine only) API
    SDL_Renderer *getRenderer() const { return m_pRenderer; }

    //! Should bitmaps be scaled?
    /*!
        @param [out] pFactor If the function returns \c true, the factor to use
            for scaling (can be \c nullptr if not interested in the value).
        @return Whether bitmaps should be scaled.
     */
    bool shouldScaleBitmaps(double* pFactor);

    SDL_Texture* createPalettizedTexture(int iWidth, int iHeight, const uint8_t* pPixels,
                                         const THPalette* pPalette, uint32_t iSpriteFlags) const;
    SDL_Texture* createTexture(int iWidth, int iHeight, const uint32_t* pPixels) const;
    void draw(SDL_Texture *pTexture, const SDL_Rect *prcSrcRect, const SDL_Rect *prcDstRect, int iFlags);
    void drawLine(THLine *pLine, int iX, int iY);

private:
    SDL_Window *m_pWindow;
    SDL_Renderer *m_pRenderer;
    SDL_Texture *m_pZoomTexture;
    SDL_PixelFormat *m_pFormat;
    bool m_bBlueFilterActive;
    THCursor* m_pCursor;
    double m_fBitmapScaleFactor; ///< Bitmap scale factor.
    int m_iWidth;
    int m_iHeight;
    int m_iCursorX;
    int m_iCursorY;
    bool m_bShouldScaleBitmaps; ///< Whether bitmaps should be scaled.
    bool m_bSupportsTargetTextures;

    // In SDL2 < 2.0.4 there is an issue with the y coordinates used for
    // ClipRects in opengl and opengles.
    // see: https://bugzilla.libsdl.org/show_bug.cgi?id=2700
    bool m_bApplyOpenGlClipFix;

    void _flushZoomBuffer();
};

//! 32bpp ARGB colour. See #THPalette::packARGB
typedef uint32_t THColour;

//! 8bpp palette class.
class THPalette
{
public: // External API
    THPalette();

    //! Load palette from the supplied data.
    /*!
        Note that the data uses palette entries of 6 bit colours.
        @param pData Data loaded from the file.
        @param iDataLength Size of the data.
        @return Whether loading of the palette succeeded.
    */
    bool loadFromTHFile(const uint8_t* pData, size_t iDataLength);

    //! Set an entry of the palette.
    /*!
        The RGB colour (255, 0, 255) is used as the transparent colour.
        @param iEntry Entry number to change.
        @param iR Amount of red in the new entry.
        @param iG Amount of green in the new entry.
        @param iB Amount of blue in the new entry.
        @return Setting the entry succeeded.
    */
    bool setEntry(int iEntry, uint8_t iR, uint8_t iG, uint8_t iB);

public: // Internal (this rendering engine only) API

    //! Convert A, R, G, B values to a 32bpp colour.
    /*!
        @param iA Amount of opacity (0-255).
        @param iR Amount of red (0-255).
        @param iG Amount of green (0-255).
        @param iB Amount of blue (0-255).
        @return 32bpp value representing the provided colour values.
    */
    inline static THColour packARGB(uint8_t iA, uint8_t iR, uint8_t iG, uint8_t iB)
    {
        return (static_cast<THColour>(iR) <<  0) |
        (static_cast<THColour>(iG) <<  8) |
        (static_cast<THColour>(iB) << 16) |
        (static_cast<THColour>(iA) << 24) ;
    }

    //! Get the red component of a colour.
    /*!
        @param iColour Colour to examine.
        @return The red component intensity of the colour.
    */
    inline static uint8_t getR(THColour iColour)
    {
        return static_cast<uint8_t>((iColour >> 0) & 0xFF);
    }

    //! Get the green component of a colour.
    /*!
        @param iColour Colour to examine.
        @return The green component intensity of the colour.
    */
    inline static uint8_t getG(THColour iColour)
    {
        return static_cast<uint8_t>((iColour >> 8) & 0xFF);
    }

    //! Get the blue component of a colour.
    /*!
        @param iColour Colour to examine.
        @return The blue component intensity of the colour.
    */
    inline static uint8_t getB(THColour iColour)
    {
        return static_cast<uint8_t>((iColour >> 16) & 0xFF);
    }

    //! Get the opacity component of a colour.
    /*!
        @param iColour Colour to examine.
        @return The opacity of the colour.
    */
    inline static uint8_t getA(THColour iColour)
    {
        return static_cast<uint8_t>((iColour >> 24) & 0xFF);
    }

    //! Get the number of colours in the palette.
    /*!
        @return The number of colours in the palette.
    */
    int getColourCount() const;

    //! Get the internal palette data for fast (read-only) access.
    /*!
        @return Table with all 256 colours of the palette.
    */
    const THColour* getARGBData() const;

    //! Set an entry of the palette.
    /*!
        @param iEntry Entry to modify.
        @param iVal Palette value to set.
    */
    inline void setARGB(int iEntry, uint32_t iVal)
    {
        m_aColoursARGB[iEntry] = iVal;
    }

private:
    //! 32bpp palette colours associated with the 8bpp colour index.
    uint32_t m_aColoursARGB[256];

    //! Number of colours in the palette.
    int m_iNumColours;
};

//! Stored image.
class THRawBitmap
{
public:
    THRawBitmap();
    ~THRawBitmap();

    //! Set the palette of the image.
    /*!
        @param pPalette Palette to set for this image.
    */
    void setPalette(const THPalette* pPalette);

    //! Load the image from the supplied pixel data.
    /*!
        Loader uses the palette supplied before.
        @param pPixelData Image data loaded from a TH file.
        @param iPixelDataLength Size of the loaded image data.
        @param iWidth Width of the image.
        @param pEventualCanvas Canvas to render the image to (eventually).
        @return Loading was a success.
    */
    bool loadFromTHFile(const uint8_t* pPixelData, size_t iPixelDataLength,
                        int iWidth, THRenderTarget *pEventualCanvas);

    //! Draw the image at a given position at the given canvas.
    /*!
        @param pCanvas Canvas to draw at.
        @param iX Destination x position.
        @param iY Destination y position.
    */
    void draw(THRenderTarget* pCanvas, int iX, int iY);

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
    void draw(THRenderTarget* pCanvas, int iX, int iY, int iSrcX, int iSrcY,
              int iWidth, int iHeight);

private:
    //! Image stored in SDL format for quick rendering.
    SDL_Texture *m_pTexture;

    //! Palette of the image.
    const THPalette* m_pPalette;

    //! Target canvas.
    THRenderTarget* m_pTarget;

    //! Width of the stored image.
    int m_iWidth;

    //! Height of the stored image.
    int m_iHeight;
};

//! Sheet of sprites.
class THSpriteSheet
{
public: // External API
    THSpriteSheet();
    ~THSpriteSheet();

    //! Set the palette to use for the sprites in the sheet.
    /*!
        @param pPalette Palette to use for the sprites at the sheet.
    */
    void setPalette(const THPalette* pPalette);

    //! Load the sprites from the supplied data (using the palette supplied earlier).
    /*!
        @param pTableData Start of table data with TH sprite information (see th_sprite_t).
        @param iTableDataLength Length of the table data.
        @param pChunkData Start of image data (chunks).
        @param iChunkDataLength Length of the chunk data.
        @param bComplexChunks Whether the supplied chunks are 'complex'.
        @param pEventualCanvas Canvas to draw at.
        @return Loading succeeded.
    */
    bool loadFromTHFile(const uint8_t* pTableData, size_t iTableDataLength,
                        const uint8_t* pChunkData, size_t iChunkDataLength,
                        bool bComplexChunks, THRenderTarget* pEventualCanvas);

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
    bool setSpriteData(size_t iSprite, const uint8_t *pData, bool bTakeData,
                       size_t iDataLength, int iWidth, int iHeight);

    //! Supply a new mapped palette to a sprite.
    /*!
        @param iSprite Sprite getting the mapped palette.
        @param pMap The palette map to apply.
        @param iAlt32 What to do for a 32bpp sprite (#THDF_Alt32_Mask bits).
    */
    void setSpriteAltPaletteMap(size_t iSprite, const uint8_t* pMap, uint32_t iAlt32);

    //! Get the number of sprites at the sheet.
    /*!
        @return The number of sprites available at the sheet.
    */
    size_t getSpriteCount() const;

    //! Set the number of sprites in the sheet.
    /*!
        @param iCount The desired number of sprites.
        @param pCanvas Canvas to draw at.
        @return Whether the number of sprites could be allocated.
    */
    bool setSpriteCount(size_t iCount, THRenderTarget* pCanvas);

    //! Get size of a sprite.
    /*!
        @param iSprite Sprite to get info from.
        @param pWidth [out] If not nullptr, the sprite width is stored in the destination.
        @param pHeight [out] If not nullptr, the sprite height is stored in the destination.
        @return Size could be provided for the sprite.
    */
    bool getSpriteSize(size_t iSprite, unsigned int* pWidth, unsigned int* pHeight) const;

    //! Get size of a sprite, assuming all input is correctly supplied.
    /*!
        @param iSprite Sprite to get info from.
        @param pWidth [out] The sprite width is stored in the destination.
        @param pHeight [out] The sprite height is stored in the destination.
    */
    void getSpriteSizeUnchecked(size_t iSprite, unsigned int* pWidth, unsigned int* pHeight) const;

    //! Get the best colour to represent the sprite.
    /*!
        @param iSprite Sprite number to analyze.
        @param pColour [out] Resulting colour.
        @return Best colour could be established.
    */
    bool getSpriteAverageColour(size_t iSprite, THColour* pColour) const;

    //! Draw a sprite onto the canvas.
    /*!
        @param pCanvas Canvas to draw on.
        @param iSprite Sprite to draw.
        @param iX X position to draw the sprite.
        @param iY Y position to draw the sprite.
        @param iFlags Flags to apply for drawing.
    */
    void drawSprite(THRenderTarget* pCanvas, size_t iSprite, int iX, int iY, uint32_t iFlags);

    //! Test whether a sprite was hit.
    /*!
        @param iSprite Sprite being tested.
        @param iX X position of the point to test relative to the origin of the sprite.
        @param iY Y position of the point to test relative to the origin of the sprite.
        @param iFlags Draw flags to apply to the sprite before testing.
        @return Whether the sprite covers the give point.
    */
    bool hitTestSprite(size_t iSprite, int iX, int iY, uint32_t iFlags) const;

public: // Internal (this rendering engine only) API
    //! Draw a sprite into wxImage data arrays (for the Map Editor)
    /*!
        @param iSprite Sprite number to draw.
        @param pRGBData Output RGB data array.
        @param pAData Output Alpha channel array.
    */
    void wxDrawSprite(size_t iSprite, uint8_t* pRGBData, uint8_t* pAData);

private:
    friend class THCursor;
#if CORSIX_TH_USE_PACK_PRAGMAS
#pragma pack(push)
#pragma pack(1)
#endif
    //! Sprite structure in the table file.
    struct th_sprite_t
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
    struct sprite_t
    {
        //! SDL structure containing the sprite with original palette.
        SDL_Texture *pTexture;

        //! SDL structure containing the sprite with alternative palette.
        SDL_Texture *pAltTexture;

        //! Data of the sprite.
        const uint8_t *pData;

        //! Alternative palette (if available).
        const uint8_t *pAltPaletteMap;

        //! Flags how to render the sprite, contains #THDF_Alt32_Mask bits.
        uint32_t iSpriteFlags;

        //! Width of the sprite.
        int iWidth;

        //! Height of the sprite.
        int iHeight;
    } *m_pSprites;

    //! Original palette.
    const THPalette* m_pPalette;

    //! Target to render to.
    THRenderTarget* m_pTarget;

    //! Number of sprites in the sprite sheet.
    size_t m_iSpriteCount;

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
    SDL_Texture *_makeAltBitmap(sprite_t *pSprite);
};

class THCursor
{
public:
    THCursor();
    ~THCursor();

    bool createFromSprite(THSpriteSheet* pSheet, size_t iSprite,
                          int iHotspotX = 0, int iHotspotY = 0);

    void use(THRenderTarget* pTarget);

    static bool setPosition(THRenderTarget* pTarget, int iX, int iY);

    void draw(THRenderTarget* pCanvas, int iX, int iY);
private:
    SDL_Surface* m_pBitmap;
    SDL_Cursor* m_pCursorHidden;
    int m_iHotspotX;
    int m_iHotspotY;
};


class THLine
{
public:
    THLine();
    ~THLine();

    void moveTo(double fX, double fY);

    void lineTo(double fX, double fY);

    void setWidth(double lineWidth);

    void draw(THRenderTarget* pCanvas, int iX, int iY);

    void setColour(uint8_t iR, uint8_t iG, uint8_t iB, uint8_t iA = 255);

    void persist(LuaPersistWriter *pWriter) const;
    void depersist(LuaPersistReader *pReader);

private:
    friend class THRenderTarget;
    void initialize();

    enum THLineOpType {
        THLOP_MOVE,
        THLOP_LINE
    };

    struct THLineOperation : public THLinkList
    {
        THLineOpType type;
        double m_fX, m_fY;
        THLineOperation(THLineOpType type, double m_fX, double m_fY) : type(type), m_fX(m_fX), m_fY(m_fY) {
            m_pNext = nullptr;
        }
    };

    THLineOperation* m_pFirstOp;
    THLineOperation* m_pCurrentOp;
    double m_fWidth;
    uint8_t m_iR, m_iG, m_iB, m_iA;
};

#endif // CORSIX_TH_TH_GFX_SDL_H_
