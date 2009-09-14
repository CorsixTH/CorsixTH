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
#ifdef CORSIX_TH_HAS_RENDERING_ENGINE
#error More than one rendering engine enabled in config file
#endif
#define CORSIX_TH_HAS_RENDERING_ENGINE

struct IDirect3D9;
struct IDirect3DDevice9;
struct IDirect3DTexture9;
struct IDirect3DSurface9;
class THCursor;
struct THRenderTargetCreationParams;

struct THClipRect
{
	int16_t x, y;
	uint16_t w, h;
};

#pragma pack(push)
#pragma pack(1)
struct THDX9_Vertex
{
    float x, y, z;
    uint32_t colour;
    float u, v;
    // The texture is not part of the FVF, but is included with the vertex data
    // to make it simpler to sort verticies by texture.
    IDirect3DTexture9 *tex;
};
#pragma pack(pop)

// The index buffer length must be a multiple of 6 (as 6 are used per quad).
// A 16-bit index buffer is used, hence it can only reference 2^16 verticies.
// As each quad uses 4 verticies and 6 indicies, the optimum index buffer
// length is ((2 ^ 16) / 4) * 6 == 0x18000
#define THDX9_INDEX_BUFFER_LENGTH  0x18000

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
	bool setCursorPosition(int iX, int iY);

    IDirect3DDevice9* getRawDevice() {return m_pDevice;}
    THDX9_Vertex* allocVerticies(size_t iCount, IDirect3DTexture9* pTexture);
    void draw(IDirect3DTexture9 *pTexture, unsigned int iWidth,
        unsigned int iHeight, int iX, int iY, unsigned long iFlags,
        unsigned int iWidth2, unsigned int iHeight2, unsigned int iTexX,
        unsigned int iTexY);
    void flushSprites();

protected:
    IDirect3D9 *m_pD3D;
    IDirect3DDevice9 *m_pDevice;
    THDX9_Vertex *m_pVerticies;
	IDirect3DTexture9 *m_pWhiteTexture;
    const char *m_sLastError;
    THClipRect m_rcClip;
    size_t m_iVertexCount;
    size_t m_iVertexLength;
    size_t m_iNonOverlappingStart;
    int m_iNonOverlapping;
	bool m_bIsWindowed;
	bool m_bIsHardwareCursorSupported;
	bool m_bIsCursorInHardware;
    uint16_t m_aiVertexIndicies[THDX9_INDEX_BUFFER_LENGTH];

    void _drawVerts(size_t iFirst, size_t iLast);
};

class THPalette
{
public:
    THPalette();

    bool loadFromTHFile(const unsigned char* pData, size_t iDataLength);

    int getColourCount() const;
    const uint32_t* getARGBData() const;

protected:
    uint32_t m_aColoursARGB[256];
    int m_iNumColours;
};

IDirect3DTexture9* THDX9_CreateSolidTexture(int iWidth, int iHeight,
											uint32_t iColour,
											IDirect3DDevice9* pDevice);

IDirect3DTexture9* THDX9_CreateTexture(int iWidth, int iHeight,
                                       const unsigned char* pPixels,
                                       const THPalette* pPalette,
                                       IDirect3DDevice9* pDevice,
                                       int* pWidth2 = NULL,
                                       int* pHeight2 = NULL);

void THDX9_FillIndexBuffer(uint16_t* pVerticies, size_t iFirst, size_t iCount);

class THRawBitmap
{
public:
    THRawBitmap();
    ~THRawBitmap();

    void setPalette(const THPalette* pPalette);

    bool loadFromTHFile(const unsigned char* pPixelData, size_t iPixelDataLength,
                        int iWidth, THRenderTarget *pEventualCanvas);

    void draw(THRenderTarget* pCanvas, int iX, int iY);
	void draw(THRenderTarget* pCanvas, int iX, int iY, int iSrcX, int iSrcY,
		      int iWidth, int iHeight);

protected:
    IDirect3DTexture9* m_pBitmap;
    const THPalette* m_pPalette;
    int m_iWidth;
    int m_iWidth2;
    int m_iHeight;
    int m_iHeight2;
};

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
        IDirect3DTexture9 *pBitmap;
        IDirect3DTexture9 *pAltBitmap;
        unsigned char *pData;
        const unsigned char *pAltPaletteMap;
        unsigned int iSheetX;
        unsigned int iSheetY;
        unsigned int iWidth;
        unsigned int iHeight;
        unsigned int iWidth2;
        unsigned int iHeight2;
    } *m_pSprites;
    const THPalette* m_pPalette;
    IDirect3DDevice9* m_pDevice;
    IDirect3DTexture9* m_pMegaSheet;
    unsigned int m_iMegaSheetSize;
    unsigned int m_iSpriteCount;

    void _freeSprites();
    bool _tryFitSingleTex(sprite_t** ppSortedSprites, unsigned int iSize);
    void _makeSingleTex(sprite_t** ppSortedSprites, unsigned int iSize);
    IDirect3DTexture9* _makeAltBitmap(sprite_t *pSprite);
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

protected:
	friend class THRenderTarget;

	IDirect3DSurface9* m_pBitmap;
	unsigned int m_iHotspotX;
	unsigned int m_iHotspotY;
	bool m_bHardwareCompatible;
};

#endif // CORSIX_TH_USE_DX9_RENDERER
#endif // CORSIX_TH_TH_GFX_DX9_H_
