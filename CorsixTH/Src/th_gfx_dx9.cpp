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

#include "config.h"
#ifdef CORSIX_TH_USE_DX9_RENDERER

#include <D3D9.h>
#include "th_gfx.h"
#include <new>
#ifdef _MSC_VER
#pragma comment(lib, "D3D9")
#endif

THRenderTarget::THRenderTarget()
{
    pD3D = NULL;
    pDevice = NULL;
    pVerticies = NULL;
	pWhiteTexture = NULL;
    THRenderTarget_SetClipRect(this, NULL);
    iVertexCount = 0;
    iVertexLength = 0;
    iNonOverlappingStart = 0;
    iNonOverlapping = 0;
}

THRenderTarget::~THRenderTarget()
{
	if(pWhiteTexture != NULL)
	{
		pWhiteTexture->Release();
		pWhiteTexture = NULL;
	}
    if(pVerticies != NULL)
    {
        free(pVerticies);
        pVerticies = NULL;
    }
    if(pDevice != NULL)
    {
        pDevice->Release();
        pDevice = NULL;
    }
    if(pD3D != NULL)
    {
        pD3D->Release();
        pD3D = NULL;
    }
}

void THRenderTarget_GetClipRect(const THRenderTarget* pTarget, THClipRect* pRect)
{
    *pRect = pTarget->rcClip;
}

void THRenderTarget_SetClipRect(THRenderTarget* pTarget, const THClipRect* pRect)
{
    if(pRect != NULL)
    {
        pTarget->rcClip = *pRect;
    }
    else
    {
        pTarget->rcClip.x = -1000;
        pTarget->rcClip.y = -1000;
        pTarget->rcClip.w = 0xFFFF;
        pTarget->rcClip.h = 0xFFFF;
    }
}
void THRenderTarget_StartNonOverlapping(THRenderTarget* pTarget)
{
    if(pTarget->iNonOverlapping++ == 0)
        pTarget->iNonOverlappingStart = pTarget->iVertexCount;
}

static int sprite_tex_compare(const void* left, const void* right)
{
    const THDX9_Vertex *pLeft  = reinterpret_cast<const THDX9_Vertex*>(left);
    const THDX9_Vertex *pRight = reinterpret_cast<const THDX9_Vertex*>(right);

    if(pLeft->tex == pRight->tex)
        return 0;
    else if(pLeft->tex < pRight->tex)
        return -1;
    else
        return 1;
}

void THRenderTarget_FinishNonOverlapping(THRenderTarget* pTarget)
{
    if(--pTarget->iNonOverlapping > 0)
        return;

    // If more than one texture is used in the range of non-overlapping
    // sprites, then sort the entire range by texture.

    size_t iStart = pTarget->iNonOverlappingStart;
    IDirect3DTexture9 *pTexture = pTarget->pVerticies[iStart].tex;
    for(size_t i = iStart + 4; i < pTarget->iVertexCount; i += 4)
    {
        if(pTarget->pVerticies[i].tex != pTexture)
        {
            qsort(pTarget->pVerticies + iStart,
                (pTarget->iVertexCount - iStart) / 4,
                sizeof(THDX9_Vertex) * 4, sprite_tex_compare);
            break;
        }
    }
}


THPalette::THPalette()
{
}

static const unsigned char gs_iTHColourLUT[0x40] = {
    // Maps 0-63 to 0-255
    0x00, 0x04, 0x08, 0x0C, 0x10, 0x14, 0x18, 0x1C,
    0x20, 0x24, 0x28, 0x2D, 0x31, 0x35, 0x39, 0x3D,
    0x41, 0x45, 0x49, 0x4D, 0x51, 0x55, 0x59, 0x5D,
    0x61, 0x65, 0x69, 0x6D, 0x71, 0x75, 0x79, 0x7D,
    0x82, 0x86, 0x8A, 0x8E, 0x92, 0x96, 0x9A, 0x9E,
    0xA2, 0xA6, 0xAA, 0xAE, 0xB2, 0xB6, 0xBA, 0xBE,
    0xC2, 0xC6, 0xCA, 0xCE, 0xD2, 0xD7, 0xDB, 0xDF,
    0xE3, 0xE7, 0xEB, 0xEF, 0xF3, 0xF7, 0xFB, 0xFF,
};

bool THPalette::loadFromTHFile(const unsigned char* pData, size_t iDataLength)
{
    if(iDataLength != 256 * 3)
        return false;

    m_iNumColours = static_cast<int>(iDataLength / 3);
    for(int i = 0; i < m_iNumColours; ++i, pData += 3)
    {
        unsigned char iR = gs_iTHColourLUT[pData[0] & 0x3F];
        unsigned char iG = gs_iTHColourLUT[pData[1] & 0x3F];
        unsigned char iB = gs_iTHColourLUT[pData[2] & 0x3F];
        D3DCOLOR iColour = D3DCOLOR_ARGB(0xFF, iR, iG, iB);
        // Remap magenta to transparent
        if(iColour == D3DCOLOR_ARGB(0xFF, 0xFF, 0x00, 0xFF))
            iColour = D3DCOLOR_ARGB(0x00, 0x00, 0x00, 0x00);
        m_aColoursARGB[i] = iColour;
    }

    return true;
}

int THPalette::getColourCount() const
{
    return m_iNumColours;
}

const uint32_t* THPalette::getARGBData() const
{
    return m_aColoursARGB;
}

IDirect3DTexture9* THDX9_CreateSolidTexture(int iWidth, int iHeight,
											uint32_t iColour,
											IDirect3DDevice9* pDevice)
{
	IDirect3DTexture9 *pTexture = NULL;
    if(pDevice->CreateTexture(iWidth, iHeight, 1, 0, D3DFMT_A8R8G8B8,
        D3DPOOL_MANAGED, &pTexture, NULL) != D3D_OK || pTexture == NULL)
    {
        return NULL;
    }
    D3DLOCKED_RECT rcLocked;
    if(pTexture->LockRect(0, &rcLocked, NULL, D3DLOCK_DISCARD) != D3D_OK)
    {
        pTexture->Release();
        return NULL;
    }

    uint8_t* pData = reinterpret_cast<uint8_t*>(rcLocked.pBits);
    for(int y = 0; y < iHeight; ++y, pData += rcLocked.Pitch)
    {
        uint32_t* pRow = reinterpret_cast<uint32_t*>(pData);
        for(int x = 0; x < iWidth; ++x, ++pRow)
        {
            *pRow = iColour;
        }
    }

    pTexture->UnlockRect(0);
    return pTexture;
}

IDirect3DTexture9* THDX9_CreateTexture(int iWidth, int iHeight,
                                       const unsigned char* pPixels,
                                       const THPalette* pPalette,
                                       IDirect3DDevice9* pDevice,
                                       int* pWidth2,
                                       int* pHeight2)
{
    int iWidth2 = 1;
    int iHeight2 = 1;
    while(iWidth2 < iWidth)
        iWidth2 <<= 1;
    while(iHeight2 < iHeight)
        iHeight2 <<= 1;
    if(pWidth2)
        *pWidth2 = iWidth2;
    if(pHeight2)
        *pHeight2 = iHeight2;

    // It might seem attractive to try and use 8-bit paletted textures rather
    // than 32-bit RGBA textures, but very few cards support 8-bit textures, so
    // it isn't worth implementing.

    IDirect3DTexture9 *pTexture = NULL;
    if(pDevice->CreateTexture(iWidth2, iHeight2, 1, 0, D3DFMT_A8R8G8B8,
        D3DPOOL_MANAGED, &pTexture, NULL) != D3D_OK || pTexture == NULL)
    {
        return NULL;
    }
    D3DLOCKED_RECT rcLocked;
    if(pTexture->LockRect(0, &rcLocked, NULL, D3DLOCK_DISCARD) != D3D_OK)
    {
        pTexture->Release();
        return NULL;
    }

    uint8_t* pData = reinterpret_cast<uint8_t*>(rcLocked.pBits);
    const uint32_t* pColours = pPalette->getARGBData();
    for(int y = 0; y < iHeight; ++y, pData += rcLocked.Pitch)
    {
        uint32_t* pRow = reinterpret_cast<uint32_t*>(pData);
        for(int x = 0; x < iWidth; ++x, ++pPixels, ++pRow)
        {
            *pRow = pColours[*pPixels];
        }
        for(int x = iWidth; x < iWidth2; ++x, ++pRow)
        {
            *pRow = D3DCOLOR_ARGB(0, 0, 0, 0);
        }
    }
    for(int y = iHeight; y < iHeight2; ++y, pData += rcLocked.Pitch)
    {
        uint32_t* pRow = reinterpret_cast<uint32_t*>(pData);
        for(int x = 0; x < iWidth2; ++x, ++pRow)
        {
            *pRow = D3DCOLOR_ARGB(0, 0, 0, 0);
        }
    }

    pTexture->UnlockRect(0);
    return pTexture;
}

THDX9_Vertex* THDX9_AllocVerticies(THRenderTarget* pTarget,
                                   size_t iCount,
                                   IDirect3DTexture9* pTexture)
{
    if(pTarget->iVertexCount + iCount > pTarget->iVertexLength)
    {
        pTarget->iVertexLength = (pTarget->iVertexLength * 2) + iCount;
        pTarget->pVerticies = (THDX9_Vertex*)realloc(pTarget->pVerticies,
            sizeof(THDX9_Vertex) * pTarget->iVertexLength);
    }
    THDX9_Vertex *pResult = pTarget->pVerticies + pTarget->iVertexCount;
    pResult[0].tex = pTexture;
    pTarget->iVertexCount += iCount;
    return pResult;
}

static inline void THDX9_DrawVerts(THRenderTarget* pTarget, size_t iFirst, size_t iLast)
{
    // Note: Convential wisdom might suggest that DrawIndexedPrimitive
    // would be more efficient to use than DrawIndexedPrimitiveUP, however the
    // vertex buffer would have to be modified each frame. My experiments have
    // shown that using vertex buffers and index buffers yields no frame rate
    // increase, whilst still increasing the complexity. Therefore the code
    // should stick to using DrawIndexedPrimitiveUP for the immediate future.

    UINT iCount = static_cast<UINT>(iLast - iFirst);
    pTarget->pDevice->DrawIndexedPrimitiveUP(D3DPT_TRIANGLELIST, 0, iCount,
        iCount / 2, pTarget->aiVertexIndicies, D3DFMT_INDEX16,
        pTarget->pVerticies + iFirst, static_cast<UINT>(sizeof(THDX9_Vertex)));
}

void THDX9_FlushSprites(THRenderTarget* pTarget)
{
    if(pTarget->iVertexCount == 0)
        return;
  
    IDirect3DTexture9 *pTexture = pTarget->pVerticies[0].tex;
    pTarget->pDevice->SetTexture(0, pTexture);
    size_t iStart = 0;
    size_t iIndexCount = 0;
    for(size_t i = 4; i < pTarget->iVertexCount; i += 4)
    {
        iIndexCount += 6;
        if(pTarget->pVerticies[i].tex != pTexture ||
            iIndexCount == THDX9_INDEX_BUFFER_LENGTH)
        {
            THDX9_DrawVerts(pTarget, iStart, i);
            iIndexCount = 0;
            iStart = i;
            pTexture = pTarget->pVerticies[i].tex;
            pTarget->pDevice->SetTexture(0, pTexture);
        }
    }
    THDX9_DrawVerts(pTarget, iStart, pTarget->iVertexCount);

    pTarget->iVertexCount = 0;
}

THRawBitmap::THRawBitmap()
{
    m_pBitmap = NULL;
    m_pPalette = NULL;
    m_iWidth = -1;
    m_iHeight = -1;
}

THRawBitmap::~THRawBitmap()
{
    if(m_pBitmap)
        m_pBitmap->Release();
}

void THRawBitmap::setPalette(const THPalette* pPalette)
{
    m_pPalette = pPalette;
}

bool THRawBitmap::loadFromTHFile(const unsigned char* pPixelData,
                                 size_t iPixelDataLength,
                                 int iWidth, THRenderTarget *pEventualCanvas)
{
    if(m_pPalette == NULL)
        return false;

    if(m_pBitmap)
    {
        m_pBitmap->Release();
        m_pBitmap = NULL;
    }

    m_iWidth = iWidth;
    m_iHeight = static_cast<int>(iPixelDataLength) / iWidth;
    m_pBitmap = THDX9_CreateTexture(iWidth, m_iHeight, pPixelData, m_pPalette,
        pEventualCanvas->pDevice, &m_iWidth2, &m_iHeight2);

    return m_pBitmap != NULL;
}

void THRawBitmap::draw(THRenderTarget* pCanvas, int iX, int iY)
{
    THDX9_Draw(pCanvas, m_pBitmap, m_iWidth, m_iHeight, iX, iY, 0,
        m_iWidth2, m_iHeight2, 0, 0);
}

void THRawBitmap::draw(THRenderTarget* pCanvas, int iX, int iY,
		      int iSrcX, int iSrcY, int iWidth, int iHeight)
{
	THDX9_Draw(pCanvas, m_pBitmap, iWidth, iHeight, iX, iY, 0,
		m_iWidth2, m_iHeight2, iSrcX, iSrcY);
}

THSpriteSheet::THSpriteSheet()
{
    m_pSprites = 0;
    m_iSpriteCount = 0;
    m_pPalette = NULL;
    m_pDevice = NULL;
    m_pMegaSheet = NULL;
}

THSpriteSheet::~THSpriteSheet()
{
    _freeSprites();
}

void THSpriteSheet::_freeSprites()
{
    for(unsigned int i = 0; i < m_iSpriteCount; ++i)
    {
        if(m_pSprites[i].pBitmap && m_pSprites[i].pBitmap != m_pMegaSheet)
            m_pSprites[i].pBitmap->Release();
        if(m_pSprites[i].pAltBitmap)
            m_pSprites[i].pAltBitmap->Release();
        if(m_pSprites[i].pData)
            delete[] (m_pSprites[i].pData - 1024);
    }
    if(m_pMegaSheet)
    {
        m_pMegaSheet->Release();
        m_pMegaSheet = NULL;
    }
    delete[] m_pSprites;
    m_pSprites = NULL;
    m_iSpriteCount = 0;
    if(m_pDevice)
    {
        m_pDevice->Release();
        m_pDevice = NULL;
    }
}

void THSpriteSheet::setPalette(const THPalette* pPalette)
{
    m_pPalette = pPalette;
}

bool THSpriteSheet::loadFromTHFile(
                    const unsigned char* pTableData, size_t iTableDataLength,
                    const unsigned char* pChunkData, size_t iChunkDataLength,
                    bool bComplexChunks, THRenderTarget* pCanvas)
{
    _freeSprites();
    if(pCanvas == NULL)
    {
        return false;
    }
    m_pDevice = pCanvas->pDevice;
    m_pDevice->AddRef();

    m_iSpriteCount = (unsigned int)(iTableDataLength / sizeof(th_sprite_t));
    m_pSprites = new (std::nothrow) sprite_t[m_iSpriteCount];
    if(m_pSprites == NULL)
    {
        m_iSpriteCount = 0;
        return false;
    }

    for(unsigned int i = 0; i < m_iSpriteCount; ++i)
    {
        sprite_t *pSprite = m_pSprites + i;
        const th_sprite_t *pTHSprite = reinterpret_cast<const th_sprite_t*>(pTableData) + i;

        pSprite->pBitmap = NULL;
        pSprite->pAltBitmap = NULL;
        pSprite->pData = NULL;
        pSprite->pAltPaletteMap = NULL;
        pSprite->iWidth = pTHSprite->width;
        pSprite->iHeight = pTHSprite->height;
        pSprite->iWidth2 = 1;
        pSprite->iHeight2 = 1;
        while(pSprite->iWidth2 < pSprite->iWidth)
            pSprite->iWidth2 <<= 1;
        while(pSprite->iHeight2 < pSprite->iHeight)
            pSprite->iHeight2 <<= 1;

        if(pSprite->iWidth == 0 || pSprite->iHeight == 0)
            continue;

        {
            unsigned char *pData = new unsigned char[pSprite->iWidth * pSprite->iHeight + 1024];
            THChunkRenderer oRenderer(pSprite->iWidth, pSprite->iHeight, pData + 1024);
            int iDataLen = static_cast<int>(iChunkDataLength) - static_cast<int>(pTHSprite->position);
            if(iDataLen < 0)
                iDataLen = 0;
            oRenderer.decodeChunks(pChunkData + pTHSprite->position, iDataLen, bComplexChunks);
            pSprite->pData = oRenderer.takeData();
        }
    }

    sprite_t **ppSortedSprites = new sprite_t*[m_iSpriteCount];
    for(unsigned int i = 0; i < m_iSpriteCount; ++i)
    {
        ppSortedSprites[i] = m_pSprites + i;
    }
    qsort(ppSortedSprites, m_iSpriteCount, sizeof(sprite_t*), _sortSpritesHeight);

    unsigned int iSize;
    if(_tryFitSingleTex(ppSortedSprites, 2048))
    {
        iSize = 2048;
        if(_tryFitSingleTex(ppSortedSprites, 1024))
        {
            iSize = 1024;
            if(_tryFitSingleTex(ppSortedSprites, 512))
            {
                iSize = 512;
                if(_tryFitSingleTex(ppSortedSprites, 256))
                {
                    iSize = 256;
                    if(_tryFitSingleTex(ppSortedSprites, 128))
                        iSize = 128;
                }
            }
        }
    }
    else
    {
        delete[] ppSortedSprites;
        return true;
    }

    _makeSingleTex(ppSortedSprites, iSize);
    delete[] ppSortedSprites;
    return true;
}

void THSpriteSheet::_makeSingleTex(sprite_t** ppSortedSprites, unsigned int iSize)
{
    IDirect3DTexture9 *pTexture = NULL;
    if(m_pDevice->CreateTexture(iSize, iSize, 1, 0, D3DFMT_A8R8G8B8,
        D3DPOOL_MANAGED, &pTexture, NULL) != D3D_OK || pTexture == NULL)
    {
        return;
    }
    D3DLOCKED_RECT rcLocked;
    if(pTexture->LockRect(0, &rcLocked, NULL, D3DLOCK_DISCARD) != D3D_OK)
    {
        pTexture->Release();
        return;
    }

    // Pass 1: Fill entirely transparent
    uint8_t* pData = reinterpret_cast<uint8_t*>(rcLocked.pBits);
    for(unsigned int y = 0; y < iSize; ++y, pData += rcLocked.Pitch)
    {
        uint32_t* pRow = reinterpret_cast<uint32_t*>(pData);
        for(unsigned int x = 0; x < iSize; ++x, ++pRow)
        {
            *pRow = D3DCOLOR_ARGB(0, 0, 0, 0);
        }
    }

    // Pass 2: Blit sprites onto sheet
    const uint32_t* pColours = m_pPalette->getARGBData();
    unsigned int iX = 0;
    unsigned int iY = 0;
    unsigned int iTallest = ppSortedSprites[0]->iHeight;
    for(unsigned int i = 0; i < m_iSpriteCount; ++i)
    {
        sprite_t *pSprite = ppSortedSprites[i];
        if(pSprite->pData == NULL)
            break;

        pSprite->pBitmap = pTexture;
        if(iX + pSprite->iWidth > iSize)
        {
            iX = 0;
            iY += iTallest;
            iTallest = pSprite->iHeight;
        }
        pSprite->iSheetX = iX;
        pSprite->iSheetY = iY;
        iX += pSprite->iWidth;

        const unsigned char *pPixels = pSprite->pData;
        uint8_t* pData = reinterpret_cast<uint8_t*>(rcLocked.pBits);
        pData += pSprite->iSheetY * rcLocked.Pitch + pSprite->iSheetX * 4;
        for(unsigned int y = 0; y < pSprite->iHeight; ++y, pData += rcLocked.Pitch)
        {
            uint32_t* pRow = reinterpret_cast<uint32_t*>(pData);
            for(unsigned int x = 0; x < pSprite->iWidth; ++x, ++pRow, ++pPixels)
            {
                *pRow = pColours[*pPixels];
            }
        }
    }

    pTexture->UnlockRect(0);
    m_pMegaSheet = pTexture;
    m_iMegaSheetSize = iSize;
}

int THSpriteSheet::_sortSpritesHeight(const void* left, const void* right)
{
    const sprite_t *pLeft = *reinterpret_cast<const sprite_t* const*>(left);
    const sprite_t *pRight = *reinterpret_cast<const sprite_t* const*>(right);

    // Move all NULL datas to the end
    if(pLeft->pData == NULL || pRight->pData == NULL)
    {
        if(pLeft->pData == NULL && pRight->pData == NULL)
            return 0;
        if(pLeft->pData == NULL)
            return 1;
        else
            return -1;
    }

    // Sort from tallest to shortest
    return static_cast<int>(pRight->iHeight) - static_cast<int>(pLeft->iHeight);
}

bool THSpriteSheet::_tryFitSingleTex(sprite_t** ppSortedSprites, unsigned int iSize)
{
    // There are probably better algorithms for trying to fit lots of small
    // rectangular sprites onto a single square sheet, but sorting them by
    // height and then filling up one row at a time is simple and yields a good
    // enough result.

    unsigned int iX = 0;
    unsigned int iY = 0;
    unsigned int iTallest = ppSortedSprites[0]->iHeight;
    for(unsigned int i = 0; i < m_iSpriteCount; ++i)
    {
        sprite_t *pSprite = ppSortedSprites[i];
        if(pSprite->pData == NULL)
            break;
        if(pSprite->iWidth > iSize || pSprite->iHeight > iSize)
            return false;
        if(iX + pSprite->iWidth > iSize)
        {
            iX = 0;
            iY += iTallest;
            iTallest = pSprite->iHeight;
        }
        iX += pSprite->iWidth;
    }

    iY += iTallest;
    return iY <= iSize;
}

void THSpriteSheet::setSpriteAltPaletteMap(unsigned int iSprite, const unsigned char* pMap)
{
    if(iSprite >= m_iSpriteCount)
        return;

    sprite_t *pSprite = m_pSprites + iSprite;
    if(pSprite->pAltPaletteMap != pMap)
    {
        pSprite->pAltPaletteMap = pMap;
        if(pSprite->pAltBitmap)
        {
            pSprite->pAltBitmap->Release();
            pSprite->pAltBitmap = NULL;
        }
    }
}

unsigned int THSpriteSheet::getSpriteCount() const
{
    return m_iSpriteCount;
}

bool THSpriteSheet::getSpriteSize(unsigned int iSprite, unsigned int* pX, unsigned int* pY) const
{
    if(iSprite >= m_iSpriteCount)
        return false;
    if(pX != NULL)
        *pX = m_pSprites[iSprite].iWidth;
    if(pY != NULL)
        *pY = m_pSprites[iSprite].iHeight;
    return true;
}

void THSpriteSheet::getSpriteSizeUnchecked(unsigned int iSprite, unsigned int* pX, unsigned int* pY) const
{
    *pX = m_pSprites[iSprite].iWidth;
    *pY = m_pSprites[iSprite].iHeight;
}

void THSpriteSheet::drawSprite(THRenderTarget* pCanvas, unsigned int iSprite, int iX, int iY, unsigned long iFlags)
{
    if(iSprite >= m_iSpriteCount || pCanvas == NULL)
        return;
    sprite_t *pSprite = m_pSprites + iSprite;

    // Find or create the texture
    IDirect3DTexture9 *pTexture = pSprite->pBitmap;
    if(pTexture == NULL)
    {
        if(pSprite->pData == NULL)
            return;

        pTexture = THDX9_CreateTexture(pSprite->iWidth, pSprite->iHeight,
            pSprite->pData, m_pPalette, m_pDevice);
        pSprite->pBitmap = pTexture;
    }
    if(iFlags & THDF_AltPalette)
    {
        pTexture = pSprite->pAltBitmap;
        if(pTexture == NULL)
        {
            pTexture = _makeAltBitmap(pSprite);
            if(pTexture == NULL)
                return;
        }
    }

    if(pTexture == m_pMegaSheet)
    {
        THDX9_Draw(pCanvas, pTexture, m_pSprites[iSprite].iWidth,
            m_pSprites[iSprite].iHeight, iX, iY, iFlags, m_iMegaSheetSize,
            m_iMegaSheetSize, m_pSprites[iSprite].iSheetX,
            m_pSprites[iSprite].iSheetY);
    }
    else
    {
        THDX9_Draw(pCanvas, pTexture, m_pSprites[iSprite].iWidth,
            m_pSprites[iSprite].iHeight, iX, iY, iFlags,
            m_pSprites[iSprite].iWidth2, m_pSprites[iSprite].iHeight2, 0, 0);
    }
}

void THDX9_Draw(THRenderTarget* pCanvas, IDirect3DTexture9 *pTexture,
                unsigned int iWidth, unsigned int iHeight,
                int iX, int iY, unsigned long iFlags, unsigned int iWidth2,
                unsigned int iHeight2, unsigned int iTexX, unsigned int iTexY)
{
    // Crop to clip rectangle
    RECT rcSource;
    rcSource.left = 0;
    rcSource.top = 0;
    rcSource.right = iWidth;
    rcSource.bottom = iHeight;
    if(iX + rcSource.right > pCanvas->rcClip.x + pCanvas->rcClip.w)
    {
        rcSource.right = pCanvas->rcClip.x + pCanvas->rcClip.w - iX;
    }
    if(iY + rcSource.bottom > pCanvas->rcClip.y + pCanvas->rcClip.h)
    {
        rcSource.bottom = pCanvas->rcClip.y + pCanvas->rcClip.h - iY;
    }
    if(iX + rcSource.left < pCanvas->rcClip.x)
    {
        rcSource.left = pCanvas->rcClip.x - iX;
        iX = pCanvas->rcClip.x;
    }
    if(iY + rcSource.top < pCanvas->rcClip.y)
    {
        rcSource.top = pCanvas->rcClip.y - iY;
        iY = pCanvas->rcClip.y;
    }
    if(rcSource.right < rcSource.left)
        rcSource.right = rcSource.left;
    if(rcSource.bottom < rcSource.top)
        rcSource.bottom = rcSource.top;

    rcSource.left += iTexX;
    rcSource.right += iTexX;
    rcSource.bottom += iTexY;
    rcSource.top += iTexY;

    // Set alpha blending options
    D3DCOLOR cColour;
    switch(iFlags & (THDF_Alpha50 | THDF_Alpha75))
    {
    case 0:
        cColour = D3DCOLOR_ARGB(0xFF, 0xFF, 0xFF, 0xFF);
        break;
    case THDF_Alpha50:
        cColour = D3DCOLOR_ARGB(0x80, 0xFF, 0xFF, 0xFF);
        break;
    default:
        cColour = D3DCOLOR_ARGB(0x40, 0xFF, 0xFF, 0xFF);
        break;
    }
    float fX = (float)iX;
    float fY = (float)iY;
    float fWidth = (float)(rcSource.right - rcSource.left);
    float fHeight = (float)(rcSource.bottom - rcSource.top);
    float fSprWidth = (float)iWidth2;
    float fSprHeight = (float)iHeight2;
    if(iFlags & THDF_FlipHorizontal)
    {
        rcSource.left = iTexX * 2 + iWidth - rcSource.left;
        rcSource.right = iTexX * 2 + iWidth - rcSource.right;
    }
    if(iFlags & THDF_FlipVertical)
    {
        rcSource.top = iTexY * 2 + iHeight - rcSource.top;
        rcSource.bottom = iTexY * 2 + iHeight - rcSource.bottom;
    }

#define SetVertexData(n, x_, y_, u_, v_) \
    pVerticies[n].x = fX + (float) x_; \
    pVerticies[n].y = fY + (float) y_; \
    pVerticies[n].z = 0.0f; \
    pVerticies[n].colour = cColour; \
    pVerticies[n].u = (float) u_; \
    pVerticies[n].v = (float) v_; \

    THDX9_Vertex *pVerticies = THDX9_AllocVerticies(pCanvas, 4, pTexture);
    SetVertexData(0, 0, 0, rcSource.left / fSprWidth, rcSource.top / fSprHeight);
    SetVertexData(1, fWidth, 0, rcSource.right  / fSprWidth, pVerticies[0].v);
    SetVertexData(2, fWidth, fHeight, pVerticies[1].u, rcSource.bottom / fSprHeight);
    SetVertexData(3, 0, fHeight, pVerticies[0].u, pVerticies[2].v);
#undef SetVertexData
}

uint16_t gs_iIndexLUT[6] = {0, 1, 2, 0, 2, 3};

void THDX9_FillIndexBuffer(uint16_t* pVerticies, size_t iFirst, size_t iCount)
{
    for(; iCount > 0; ++iFirst, --iCount)
    {
        size_t iMod = iFirst % 6;
        size_t iBase = (iFirst / 6) * 4;
        pVerticies[iFirst] = static_cast<uint16_t>(iBase) + gs_iIndexLUT[iMod];
    }
}

IDirect3DTexture9* THSpriteSheet::_makeAltBitmap(sprite_t *pSprite)
{
    if(pSprite->pAltPaletteMap == NULL)
    {
        pSprite->pAltBitmap = pSprite->pBitmap;
        pSprite->pAltBitmap->AddRef();
    }
    else
    {
        int iPixelCount = pSprite->iHeight * pSprite->iWidth;
        unsigned char *pData = new unsigned char[iPixelCount + 1024];
        pData += 1024;
        for(int i = 0; i < iPixelCount; ++i)
        {
            unsigned char iPixel = pSprite->pData[i];
            if(iPixel != 0xFF)
                iPixel = pSprite->pAltPaletteMap[iPixel];
            pData[i] = iPixel;
        }
        pSprite->pAltBitmap = THDX9_CreateTexture(pSprite->iWidth,
            pSprite->iHeight, pData, m_pPalette, m_pDevice);
        pData -= 1024;
        delete[] pData;
    }
    return pSprite->pAltBitmap;
}

#endif // CORSIX_TH_USE_DX9_RENDERER
