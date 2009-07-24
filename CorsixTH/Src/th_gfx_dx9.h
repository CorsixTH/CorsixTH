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

#ifndef CORSIX_TH_TH_GFX_DX9_H_
#define CORSIX_TH_TH_GFX_DX9_H_
#include "config.h"
#ifdef CORSIX_TH_USE_DX9_RENDERER

struct IDirect3D9;
struct IDirect3DDevice9;
struct IDirect3DTexture9;
struct ID3DXSprite;

struct THClipRect
{
	int16_t x, y;
	uint16_t w, h;
};

struct THRenderTarget
{
    THRenderTarget();

    IDirect3D9 *pD3D;
    IDirect3DDevice9 *pDevice;
    ID3DXSprite *pSprite;
    IDirect3DTexture9 *pTexture;
    THClipRect rcClip;
};

void THRenderTarget_GetClipRect(const THRenderTarget* pTarget, THClipRect* pRect);
void THRenderTarget_SetClipRect(THRenderTarget* pTarget, const THClipRect* pRect);

class THPalette
{
public:
    THPalette();

    bool loadFromTHFile(const unsigned char* pData, size_t iDataLength);

    int getColourCount() const;
    const unsigned char* getColourData() const;
    void assign(THRenderTarget* pTarget) const;

protected:
#pragma pack(push)
#pragma pack(1)
    struct colour_t
    {
        unsigned char b;
        unsigned char g;
        unsigned char r;
    } m_aColours[256];
#pragma pack(pop)
    int m_iNumColours;
};

IDirect3DTexture9* THDX9_CreateTexture(int iWidth, int iHeight,
                                       const unsigned char* pPixels,
                                       const THPalette* pPalette,
                                       IDirect3DDevice9* pDevice,
                                       bool bNoAllocate = false);

class THSpriteSheet
{
public:
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

    void drawSprite(THRenderTarget* pCanvas, unsigned int iSprite, int iX, int iY, unsigned long iFlags);

protected:
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
        IDirect3DTexture9 *pBitmap;
        IDirect3DTexture9 *pAltBitmap;
        unsigned char *pData;
        const unsigned char *pAltPaletteMap;
        unsigned int iWidth;
        unsigned int iHeight;
    } *m_pSprites;
    const THPalette* m_pPalette;
    IDirect3DDevice9* m_pDevice;
    unsigned int m_iSpriteCount;

    void _freeSprites();
    IDirect3DTexture9* _makeAltBitmap(sprite_t *pSprite);
};

#endif // CORSIX_TH_USE_DX9_RENDERER
#endif // CORSIX_TH_TH_GFX_DX9_H_
