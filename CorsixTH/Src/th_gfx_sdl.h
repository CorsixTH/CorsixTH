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

#ifndef CORSIX_TH_TH_GFX_SDL_H_
#define CORSIX_TH_TH_GFX_SDL_H_
#include "config.h"
#ifdef CORSIX_TH_USE_SDL_RENDERER
#ifdef CORSIX_TH_HAS_RENDERING_ENGINE
#error More than one rendering engine enabled in config file
#endif
#define CORSIX_TH_HAS_RENDERING_ENGINE
#include <SDL.h>

class THCursor;
struct THClipRect : public SDL_Rect
{
    typedef Sint16 xy_t;
    typedef Uint16 wh_t;
};
struct THRenderTargetCreationParams;

class THRenderTarget
{
public: // External API
    THRenderTarget();
    ~THRenderTarget();

    //! Initialise the render target
    bool create(const THRenderTargetCreationParams* pParams);

    //! Get the reason for the last operation failing
    const char* getLastError();

    //! Begin rendering a new frame
    bool startFrame();

    //! Finish rendering the current frame and present it
    bool endFrame();

    //! Paint the entire render target black
    bool fillBlack();

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

    // If you add any extra methods here which are called from outside the
    // rendering engine, then be sure to at least add dummy implementations
    // to the other rendering engines.

public: // Internal (this rendering engine only) API

    SDL_Surface* getRawSurface() {return m_pSurface;}
    const SDL_Surface* getRawSurface() const {return m_pSurface;}
    bool shouldScaleBitmaps(float* pFactor);

protected:
    SDL_Surface* m_pSurface;
    THCursor* m_pCursor;
    float m_fBitmapScaleFactor;
    int m_iCursorX;
    int m_iCursorY;
    bool m_bShouldScaleBitmaps;
};

typedef SDL_Colour THColour;

class THPalette
{
public:
    THPalette();
    typedef SDL_Colour colour_t;

    bool loadFromTHFile(const unsigned char* pData, size_t iDataLength);
    bool setEntry(int iEntry, uint8_t iR, uint8_t iG, uint8_t iB);

    colour_t operator[] (uint8_t iIndex) const {return m_aColours[iIndex];}

protected:
    friend class THSpriteSheet;
    friend class THRawBitmap;

    void _assign(THRenderTarget* pTarget) const;
    void _assign(SDL_Surface* pSurface) const;

    colour_t m_aColours[256];
    int m_iNumColours;
    int m_iTransparentIndex;
};

class THRawBitmap
{
public:
    THRawBitmap();
    ~THRawBitmap();

    void setPalette(const THPalette* pPalette);

    bool loadFromTHFile(const unsigned char* pPixelData, size_t iPixelDataLength,
                        int iWidth, THRenderTarget *pUnused);

    void draw(THRenderTarget* pCanvas, int iX, int iY);
    void draw(THRenderTarget* pCanvas, int iX, int iY, int iSrcX, int iSrcY,
              int iWidth, int iHeight);

protected:
    bool _checkScaled(THRenderTarget* pCanvas, SDL_Rect& rcDest);

    SDL_Surface* m_pBitmap;
    SDL_Surface* m_pCachedScaledBitmap;
    unsigned char* m_pData;
    const THPalette* m_pPalette;
};

class THSpriteSheet
{
public:
    THSpriteSheet();
    ~THSpriteSheet();

    void setPalette(const THPalette* pPalette);

    //! Load a sprite sheet from Theme Hospital data
    /*!
        @param bComplexChunks See THChunkRenderer::decodeChunks()
    */
    bool loadFromTHFile(const unsigned char* pTableData, size_t iTableDataLength,
                        const unsigned char* pChunkData, size_t iChunkDataLength,
                        bool bComplexChunks, THRenderTarget *pUnused);

    void setSpriteAltPaletteMap(unsigned int iSprite, const unsigned char* pMap);

    unsigned int getSpriteCount() const;

    //! Get the size of a sprite
    /*!
        @param iSprite Sprite index. Should be in range [0, getSpriteCount() - 1].
        @param pX Pointer to store width at. May be NULL.
        @param pY Pointer to store height at. May be NULL.
        @return true if the sprite index was valid, false otherwise.
    */
    bool getSpriteSize(unsigned int iSprite, unsigned int* pX, unsigned int* pY) const;

    //! Get the size of a sprite
    /*!
        @param iSprite Sprite index. Must be in range [0, getSpriteCount() - 1].
        @param pX Pointer to store width at. Must not be NULL.
        @param pY Pointer to store height at. Must not be NULL.
    */
    void getSpriteSizeUnchecked(unsigned int iSprite, unsigned int* pX, unsigned int* pY) const;

    //! Get the average of the non-transparent pixels of a sprite
    /*!
        For this function, "average" means the mode (i.e. the colour which
        occurs most frequently) rather than an arithmetic mean.
        @param iSprite Sprite index. Should be in range [0, getSpriteCount() - 1].
        @param pColour Pointer to store resulting average at.
        @return true if there was an average colour (i.e. sprite existed and
            had at least one opaque pixel), false otherwise.
    */
    bool getSpriteAverageColour(unsigned int iSprite, THColour* pColour) const;

    void drawSprite(THRenderTarget* pCanvas, unsigned int iSprite, int iX, int iY, unsigned long iFlags);
    bool hitTestSprite(unsigned int iSprite, int iX, int iY, unsigned long iFlags) const;

protected:
    friend class THCursor;
#if CORSIX_TH_USE_PACK_PRAGMAS
#pragma pack(push)
#pragma pack(1)
#endif
    struct th_sprite_t
    {
        uint32_t position;
        unsigned char width;
        unsigned char height;
    } CORSIX_TH_PACKED_FLAGS;
#if CORSIX_TH_USE_PACK_PRAGMAS
#pragma pack(pop)
#endif

    struct sprite_t
    {
        SDL_Surface *pBitmap[32];
        unsigned char *pData;
        const unsigned char *pAltPaletteMap;
        unsigned int iWidth;
        unsigned int iHeight;
    } *m_pSprites;
    const THPalette* m_pPalette;
    unsigned int m_iSpriteCount;
    bool m_bHasAnyFlaggedBitmaps;

    void _freeSprites();
    SDL_Surface* _getSpriteBitmap(unsigned int iSprite, unsigned long iFlags);
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

#endif // CORSIX_TH_USE_SDL_RENDERER
#endif // CORSIX_TH_TH_GFX_SDL_H_
