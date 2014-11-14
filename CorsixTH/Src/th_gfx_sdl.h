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
        @param width Pixel width of the resulting image
        @param height Pixel height of the resulting image
    */
    FullColourRenderer(int iWidth, int iHeight);
    virtual ~FullColourRenderer();

    //! Decode a 32bpp image, and push it to the storage backend.
    /*!
        @param pImg Encoded 32bpp image.
        @param pPalette Palette of a legacy sprite.
        @return Decoding was successful.
    */
    bool decodeImage(const unsigned char* pImg, const THPalette *pPalette);

protected:
    //! Store a decoded pixel. Use m_iX and m_iY if necessary.
    /*!
        @param pixel Pixel to store.
    */
    virtual void storeARGB(uint32_t pixel) = 0;

    const int m_iWidth;
    const int m_iHeight;
    int m_iX;
    int m_iY;

private:
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

protected:
    virtual void storeARGB(uint32_t pixel);

protected:
    //! Pointer to the storage (not owned by this class).
    uint32_t *m_pDest;
};

class WxStoring : public FullColourRenderer
{
public:
    WxStoring(unsigned char* pRGBData, unsigned char* pAData, int iWidth, int iHeight);

protected:
    virtual void storeARGB(uint32_t pixel);

protected:
    //! Pointer to the RGB storage (not owned by this class).
    unsigned char *m_pRGBData;

    //! Pointer to the Alpha channel storage (not owned by this class).
    unsigned char *m_pAData;
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

    //! Set the amount by which future draw operations are scaled
    bool setScaleFactor(float fScale, THScaledItems eWhatToScale);

    //! Set the window caption
    void setCaption(const char* sCaption);

    //! Get any user-displayable information to describe the renderer path used
    const char *getRendererDetails() const;

    // If you add any extra methods here which are called from outside the
    // rendering engine, then be sure to at least add dummy implementations
    // to the other rendering engines.

public: // Internal (this rendering engine only) API
    SDL_Renderer *getRenderer() const { return m_pRenderer; }
    bool shouldScaleBitmaps(float* pFactor);
    SDL_Texture* createPalettizedTexture(int iWidth, int iHeight, const unsigned char* pPixels,
                                         const THPalette* pPalette) const;
    SDL_Texture* createTexture(int iWidth, int iHeight, const uint32_t* pPixels) const;
    void draw(SDL_Texture *pTexture, const SDL_Rect *prcSrcRect, const SDL_Rect *prcDstRect, int iFlags);
    void drawLine(THLine *pLine, int iX, int iY);

protected:
    SDL_Window *m_pWindow;
    SDL_Renderer *m_pRenderer;
    SDL_Texture *m_pZoomTexture;
    SDL_PixelFormat *m_pFormat;
    bool m_bBlueFilterActive;
    THCursor* m_pCursor;
    float m_fBitmapScaleFactor;
    int m_iWidth;
    int m_iHeight;
    int m_iCursorX;
    int m_iCursorY;
    bool m_bShouldScaleBitmaps;
    bool m_bSupportsTargetTextures;

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
    bool loadFromTHFile(const unsigned char* pData, size_t iDataLength);

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
    inline static unsigned char getR(THColour iColour)
    {
        return static_cast<uint8_t>((iColour >> 0) & 0xFF);
    }

    //! Get the green component of a colour.
    /*!
        @param iColour Colour to examine.
        @return The green component intensity of the colour.
    */
    inline static unsigned char getG(THColour iColour)
    {
        return static_cast<uint8_t>((iColour >> 8) & 0xFF);
    }

    //! Get the blue component of a colour.
    /*!
        @param iColour Colour to examine.
        @return The blue component intensity of the colour.
    */
    inline static unsigned char getB(THColour iColour)
    {
        return static_cast<uint8_t>((iColour >> 16) & 0xFF);
    }

    //! Get the opacity component of a colour.
    /*!
        @param iColour Colour to examine.
        @return The opacity of the colour.
    */
    inline static unsigned char getA(THColour iColour)
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

protected:
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
    bool loadFromTHFile(const unsigned char* pPixelData, size_t iPixelDataLength,
                        int iWidth, THRenderTarget *pEventualCanvas);

    //! Load the image from the supplied full colour pixel data.
    /*!
        @param pData Image data.
        @param iLength Size of the loaded image data.
        @param pEventualCanvas Canvas to render the image to (eventually).
        @return Loading was a success.
    */
    bool loadFullColour(const unsigned char* pData, size_t iLength,
                        THRenderTarget *pEventualCanvas);

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

protected:
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

    //! Whether to use the m_iXOffset and m_iYOffset.
    bool m_bUseOffsets;

    //! Horizontal offset of the stored image, if m_bUseOffsets is set.
    int m_iXOffset;
    //
    //! Vertical offset of the stored image, if m_bUseOffsets is set.
    int m_iYOffset;
};

#define ZERO_XOFFSET 0
#define ZERO_YOFFSET 0

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
    bool loadFromTHFile(const unsigned char* pTableData, size_t iTableDataLength,
                        const unsigned char* pChunkData, size_t iChunkDataLength,
                        bool bComplexChunks, THRenderTarget* pEventualCanvas);

    //! Load the image from the supplied full colour pixel data.
    /*!
        @param pData Image data.
        @param iLength Size of the loaded image data.
        @param pEventualCanvas Canvas to render the image to (eventually).
        @return Loading was a success.
    */
    bool loadFullColour(const unsigned char* pData, size_t iLength,
                        THRenderTarget *pEventualCanvas);

    //! Supply a new mapped palette to a sprite.
    /*!
        @param iSprite Sprite getting the mapped palette.
        @param pMap The palette map to apply.
    */
    void setSpriteAltPaletteMap(unsigned int iSprite, const unsigned char* pMap);

    //! Get the number of sprites at the sheet.
    /*!
        @return The number of sprites available at the sheet.
    */
    unsigned int getSpriteCount() const;

    //! Get size of a sprite.
    /*!
        @param iSprite Sprite to get info from.
        @param pWidth [out] If not NULL, the sprite width is stored in the destination.
        @param pHeight [out] If not NULL, the sprite height is stored in the destination.
        @return Size could be provided for the sprite.
    */
    bool getSpriteSize(unsigned int iSprite, unsigned int* pWidth, unsigned int* pHeight) const;

    //! Get size of a sprite, assuming all input is correctly supplied.
    /*!
        @param iSprite Sprite to get info from.
        @param pWidth [out] The sprite width is stored in the destination.
        @param pHeight [out] The sprite height is stored in the destination.
    */
    void getSpriteSizeUnchecked(unsigned int iSprite, unsigned int* pWidth, unsigned int* pHeight) const;

    //! Get the best colour to represent the sprite.
    /*!
        @param iSprite Sprite number to analyze.
        @param pColour [out] Resulting colour.
        @return Best colour could be established.
    */
    bool getSpriteAverageColour(unsigned int iSprite, THColour* pColour) const;

    //! Draw a sprite onto the canvas.
    /*!
        @param pCanvas Canvas to draw on.
        @param iSprite Sprite to draw.
        @param iXPos X position to draw the sprite.
        @param iYPos Y position to draw the sprite.
        @param iXOffset X offset to draw the sprite.
        @param iYOffset Y offset to draw the sprite.
        @param iFlags Flags to apply for drawing.
    */
    void drawSprite(THRenderTarget* pCanvas, unsigned int iSprite, int iXPos, int iYPos,
                    int iXOffset, int iYOffset, unsigned long iFlags);

    //! Test whether a sprite was hit.
    /*!
        @param iSprite Sprite being tested.
        @param iX X position of the point to test relative to the origin of the sprite.
        @param iY Y position of the point to test relative to the origin of the sprite.
        @param iFlags Draw flags to apply to the sprite before testing.
        @return Whether the sprite covers the give point.
    */
    bool hitTestSprite(unsigned int iSprite, int iX, int iY, unsigned long iFlags) const;

public: // Internal (this rendering engine only) API
    //! Draw a sprite into wxImage data arrays (for the Map Editor)
    /*!
        @param iSprite Sprite number to draw.
        @param pRGBData Output RGB data array.
        @param pAData Output Alpha channel array.
    */
    void wxDrawSprite(unsigned int iSprite, unsigned char* pRGBData, unsigned char* pAData);

protected:
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
        unsigned char width;

        //! Height of the sprite.
        unsigned char height;
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

        //! Data of the sprite (width * height bytes).
        unsigned char *pData;

        //! Alternative palette (if available).
        const unsigned char *pAltPaletteMap;

        //! Width of the sprite.
        unsigned int iWidth;

        //! Height of the sprite.
        unsigned int iHeight;

        //! Whether to use the supplied offsets.
        bool bUseOffsets;

        //! Horizontal offset of the sprite if bUseOffsets is true.
        unsigned int iXOffset;

        //! Vertical offset of the sprite if bUseOffsets is true.
        unsigned int iYOffset;
    } *m_pSprites;

    //! Original palette.
    const THPalette* m_pPalette;

    //! Target to render to.
    THRenderTarget* m_pTarget;

    //! Number of sprites in the sprite sheet.
    unsigned int m_iSpriteCount;

    //! Free memory of a single sprite.
    /*!
        @param iNumber Number of the sprite to clear.
    */
    void _freeSingleSprite(unsigned int iNumber);

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

    bool createFromSprite(THSpriteSheet* pSheet, unsigned int iSprite,
                          int iHotspotX = 0, int iHotspotY = 0);

    void use(THRenderTarget* pTarget);

    static bool setPosition(THRenderTarget* pTarget, int iX, int iY);

    void draw(THRenderTarget* pCanvas, int iX, int iY);
protected:
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

protected:
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
            m_pNext = NULL;
        }
    };

    THLineOperation* m_pFirstOp;
    THLineOperation* m_pCurrentOp;
    double m_fWidth;
    uint8_t m_iR, m_iG, m_iB, m_iA;
};

#endif // CORSIX_TH_TH_GFX_SDL_H_
