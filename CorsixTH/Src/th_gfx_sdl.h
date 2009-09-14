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
typedef SDL_Rect THClipRect;
struct THRenderTargetCreationParams;

class THRenderTarget
{
public:
	THRenderTarget();
    ~THRenderTarget();

    bool create(const THRenderTargetCreationParams* pParams);
    const char* getLastError();

    bool startFrame();
    bool endFrame();
    bool fillBlack();
    uint32_t mapColour(uint8_t iR, uint8_t iG, uint8_t iB);
    bool fillRect(uint32_t iColour, int iX, int iY, int iW, int iH);
    void getClipRect(THClipRect* pRect) const;
    void setClipRect(const THClipRect* pRect);
    void startNonOverlapping();
    void finishNonOverlapping();
    void setCursor(THCursor* pCursor);
	void setCursorPosition(int iX, int iY);

	SDL_Surface* getRawSurface() {return m_pSurface;}
	const SDL_Surface* getRawSurface() const {return m_pSurface;}

protected:
	SDL_Surface* m_pSurface;
	THCursor* m_pCursor;
	int m_iCursorX;
	int m_iCursorY;
};

class THPalette
{
public:
    THPalette();

    bool loadFromTHFile(const unsigned char* pData, size_t iDataLength);

protected:
    friend class THSpriteSheet;
    friend class THRawBitmap;

    void _assign(THRenderTarget* pTarget) const;
	void _assign(SDL_Surface* pSurface) const;

    typedef SDL_Colour colour_t;
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
    SDL_Surface* m_pBitmap;
    unsigned char* m_pData;
    const THPalette* m_pPalette;
};

class THSpriteSheet
{
public:
    THSpriteSheet();
    ~THSpriteSheet();

    void setPalette(const THPalette* pPalette);

    bool loadFromTHFile(const unsigned char* pTableData, size_t iTableDataLength,
                        const unsigned char* pChunkData, size_t iChunkDataLength,
                        bool bComplexChunks, THRenderTarget *pUnused);

    void setSpriteAltPaletteMap(unsigned int iSprite, const unsigned char* pMap);

    unsigned int getSpriteCount() const;
    bool getSpriteSize(unsigned int iSprite, unsigned int* pX, unsigned int* pY) const;
    void getSpriteSizeUnchecked(unsigned int iSprite, unsigned int* pX, unsigned int* pY) const;

    void drawSprite(THRenderTarget* pCanvas, unsigned int iSprite, int iX, int iY, unsigned long iFlags);
	bool hitTestSprite(unsigned int iSprite, int iX, int iY, unsigned long iFlags) const;

protected:
	friend class THCursor;
#pragma pack(push)
#pragma pack(1)
    struct th_sprite_t
    {
        uint32_t position;
        unsigned char width;
        unsigned char height;
    };
#pragma pack(pop)

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
	int m_iHotspotX;
	int m_iHotspotY;
};

#endif // CORSIX_TH_USE_SDL_RENDERER
#endif // CORSIX_TH_TH_GFX_SDL_H_
