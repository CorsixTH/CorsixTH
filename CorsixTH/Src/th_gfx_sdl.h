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

    // If you add any extra methods here which are called from outside the
    // rendering engine, then be sure to at least add dummy implementations
    // to the other rendering engines.

public: // Internal (this rendering engine only) API
    bool shouldScaleBitmaps(float* pFactor);
    SDL_Texture* createPalettizedTexture(int iWidth, int iHeight, const unsigned char* pPixels,
                                         const THPalette* pPalette) const;
    SDL_Texture* createTexture(int iWidth, int iHeight, const uint32_t* pPixels) const;
    void draw(SDL_Texture *pTexture, const SDL_Rect *prcSrcRect, const SDL_Rect *prcDstRect, int iFlags);
    void drawLine(THLine *pLine, int iX, int iY);

protected:
    SDL_Window *m_pWindow;
    SDL_Renderer *m_pRenderer;
    SDL_PixelFormat *m_pFormat;
    bool m_bBlueFilterActive;
    THCursor* m_pCursor;
    float m_fBitmapScaleFactor;
    int m_iCursorX;
    int m_iCursorY;
    bool m_bShouldScaleBitmaps;
};

typedef uint32_t THColour;

class THPalette
{
public: // External API
    THPalette();

    bool loadFromTHFile(const unsigned char* pData, size_t iDataLength);
    bool setEntry(int iEntry, uint8_t iR, uint8_t iG, uint8_t iB);

public: // Internal (this rendering engine only) API
    inline static uint32_t packARGB(uint8_t iA, uint8_t iR, uint8_t iG, uint8_t iB)
    {
        return (static_cast<uint32_t>(iR) <<  0) |
        (static_cast<uint32_t>(iG) <<  8) |
        (static_cast<uint32_t>(iB) << 16) |
        (static_cast<uint32_t>(iA) << 24) ;
    }
    int getColourCount() const;
    const uint32_t* getARGBData() const;

protected:
    uint32_t m_aColoursARGB[256];
    int m_iNumColours;
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
    SDL_Texture *m_pTexture;
    const THPalette* m_pPalette;
    THRenderTarget* m_pTarget;
    int m_iWidth;
    int m_iHeight;
};


class THSpriteSheet
{
public: // External API
    THSpriteSheet();
    ~THSpriteSheet();

    void setPalette(const THPalette* pPalette);

    bool loadFromTHFile(const unsigned char* pTableData, size_t iTableDataLength,
                        const unsigned char* pChunkData, size_t iChunkDataLength,
                        bool bComplexChunks, THRenderTarget* pEventualCanvas);

    void setSpriteAltPaletteMap(unsigned int iSprite, const unsigned char* pMap);

    unsigned int getSpriteCount() const;
    bool getSpriteSize(unsigned int iSprite, unsigned int* pX, unsigned int* pY) const;
    void getSpriteSizeUnchecked(unsigned int iSprite, unsigned int* pX, unsigned int* pY) const;

    bool getSpriteAverageColour(unsigned int iSprite, THColour* pColour) const;

    void drawSprite(THRenderTarget* pCanvas, unsigned int iSprite, int iX, int iY, unsigned long iFlags);
    bool hitTestSprite(unsigned int iSprite, int iX, int iY, unsigned long iFlags) const;

public: // Internal (this rendering engine only) API
    //! Draw a sprite into wxImage data arrays (for the Map Editor)
    void wxDrawSprite(unsigned int iSprite, unsigned char* pRGBData, unsigned char* pAData);

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
        SDL_Texture *pTexture;
        SDL_Texture *pAltTexture;
        unsigned char *pData;
        const unsigned char *pAltPaletteMap;
        unsigned int iSheetX;
        unsigned int iSheetY;
        unsigned int iWidth;
        unsigned int iHeight;
    } *m_pSprites;
    const THPalette* m_pPalette;
    THRenderTarget* m_pTarget;
    SDL_Texture *m_pMegaTexture;
    unsigned int m_iMegaTextureSize;
    unsigned int m_iSpriteCount;

    void _freeSprites();
    bool _tryFitSingleTex(sprite_t** ppSortedSprites, unsigned int iSize);
    void _makeSingleTex(sprite_t** ppSortedSprites, unsigned int iSize);
    SDL_Texture *_makeAltBitmap(sprite_t *pSprite);
    static int _sortSpritesHeight(const void*, const void*);
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
