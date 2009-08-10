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
#ifdef CORSIX_TH_USE_D3D9X
#include <D3DX9.h>
#endif
#include "th_gfx.h"
#include <new>
#ifdef _MSC_VER
#pragma comment(lib, "D3D9")
#ifdef CORSIX_TH_USE_D3D9X
#pragma comment(lib, "D3DX9")
#endif
#endif

THRenderTarget::THRenderTarget()
{
    pD3D = NULL;
    pDevice = NULL;
#ifdef CORSIX_TH_USE_D3D9X
    pSprite = NULL;
#endif
    pTexture = NULL;
    THRenderTarget_SetClipRect(this, NULL);
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

#ifdef CORSIX_TH_USE_D3D9X

void THRenderTarget_StartNonOverlapping(THRenderTarget* pTarget)
{
    if(pTarget->pSprite)
    {
        pTarget->pSprite->End();
        pTarget->pSprite->Begin(D3DXSPRITE_ALPHABLEND |
            D3DXSPRITE_DONOTSAVESTATE | D3DXSPRITE_DONOTMODIFY_RENDERSTATE |
            D3DXSPRITE_SORT_TEXTURE);
    }
}

void THRenderTarget_FinishNonOverlapping(THRenderTarget* pTarget)
{
    if(pTarget->pSprite)
    {
        pTarget->pSprite->End();
        pTarget->pSprite->Begin(D3DXSPRITE_ALPHABLEND |
            D3DXSPRITE_DONOTSAVESTATE | D3DXSPRITE_DONOTMODIFY_RENDERSTATE);
    }
}

#else

void THRenderTarget_StartNonOverlapping(THRenderTarget* pTarget)
{
    pTarget->iNonOverlappingStart = pTarget->iVertexCount;
    //THDX9_FlushSprites(pTarget);
    pTarget->bNonOverlapping = true;
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
    size_t iStart = pTarget->iNonOverlappingStart;
    IDirect3DTexture9 *pTexture = pTarget->pVerticies[iStart].tex;
    for(size_t i = iStart + 6; i < pTarget->iVertexCount; i += 6)
    {
        if(pTarget->pVerticies[i].tex != pTexture)
        {
            qsort(pTarget->pVerticies + iStart,
                (pTarget->iVertexCount - iStart) / 6,
                sizeof(THDX9_Vertex) * 6, sprite_tex_compare);
            break;
        }
    }

    //THDX9_FlushSprites(pTarget);
    pTarget->bNonOverlapping = false;
}

#endif

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

    m_iNumColours = iDataLength / 3;
    colour_t* pCol = m_aColours;
    for(int i = 0; i < m_iNumColours; ++i, pData += 3, ++pCol)
    {
        pCol->r = gs_iTHColourLUT[pData[0] & 0x3F];
        pCol->g = gs_iTHColourLUT[pData[1] & 0x3F];
        pCol->b = gs_iTHColourLUT[pData[2] & 0x3F];
        if(pCol->r == 0xFF && pCol->g == 0 && pCol->b == 0xFF)
            m_aColoursARGB[i] = D3DCOLOR_ARGB(0x00, 0x00, 0x00, 0x00);
        else
            m_aColoursARGB[i] = D3DCOLOR_ARGB(0xFF, pCol->r, pCol->g, pCol->b);
    }

    return true;
}

void THPalette::assign(THRenderTarget*, bool) const
{
    // DX9 rendering engine must have palettes assigned during texture creation
    // and hence assigning one later is a null operation.
}

int THPalette::getColourCount() const
{
    return m_iNumColours;
}

const unsigned char* THPalette::getColourData() const
{
    return &m_aColours[0].b;
}

const uint32_t* THPalette::getARGBData() const
{
    return m_aColoursARGB;
}

#ifdef CORSIX_TH_USE_D3D9X

IDirect3DTexture9* THDX9_CreateTexture(int iWidth, int iHeight,
                                       const unsigned char* pPixels,
                                       const THPalette* pPalette,
                                       IDirect3DDevice9* pDevice,
                                       bool bNoAllocate)
{
    // The easiest way to load a texture appears to be prefixing the data with
    // a TGA header and having D3DX load it as a TGA file in memory.
#pragma pack(push)
#pragma pack(1)
    struct tga_header
    {
        uint8_t ident_size;
        uint8_t colour_map_type;
        uint8_t image_type;
        uint16_t colour_map_start;
        uint16_t colour_map_length;
        uint8_t colour_map_bpp;
        uint16_t x_start;
        uint16_t y_start;
        uint16_t width;
        uint16_t height;
        uint8_t bpp;
        uint8_t flags;
    };
#pragma pack(pop)

    size_t iPaletteSize = pPalette->getColourCount() * 3;
    size_t iHeaderSize = iPaletteSize + sizeof(tga_header);
    size_t iDataSize = iWidth * iHeight;
    size_t iTGASize = iHeaderSize + iDataSize;
    unsigned char *pTGA;
    if(bNoAllocate)
        pTGA = const_cast<unsigned char*>(pPixels) - iHeaderSize;
    else
        pTGA = new unsigned char[iTGASize];
    tga_header *pHeader = reinterpret_cast<tga_header*>(pTGA);

    pHeader->ident_size = 0;
    pHeader->colour_map_type = 1;
    pHeader->image_type = 1;
    pHeader->colour_map_start = 0;
    pHeader->colour_map_length = static_cast<uint16_t>(pPalette->getColourCount());
    pHeader->colour_map_bpp = 24;
    pHeader->x_start = 0;
    pHeader->y_start = 0;
    pHeader->width = static_cast<uint16_t>(iWidth);
    pHeader->height = static_cast<uint16_t>(iHeight);
    pHeader->bpp = 8;
    pHeader->flags = 0x20;

    memcpy(pTGA + sizeof(tga_header), pPalette->getColourData(), iPaletteSize);
    if(!bNoAllocate)
    {
        memcpy(pTGA + iHeaderSize, pPixels, iDataSize);
    }

    IDirect3DTexture9 *pTexture = NULL;
    if(D3DXCreateTextureFromFileInMemoryEx(pDevice, pTGA, iTGASize,
        D3DX_DEFAULT, D3DX_DEFAULT, 1, 0, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED,
        D3DX_FILTER_NONE, D3DX_FILTER_NONE, D3DCOLOR_ARGB(0xFF, 0xFF, 0, 0xFF),
        NULL, NULL, &pTexture) != D3D_OK || pTexture == NULL)
    {
        if(!bNoAllocate)
            delete[] pTGA;
        return NULL;
    }
    else
    {
        if(!bNoAllocate)
            delete[] pTGA;
        return pTexture;
    }
}

#else

IDirect3DTexture9* THDX9_CreateTexture(int iWidth, int iHeight,
                                       const unsigned char* pPixels,
                                       const THPalette* pPalette,
                                       IDirect3DDevice9* pDevice,
                                       bool)
{
    int iWidth2 = 1;
    int iHeight2 = 1;
    while(iWidth2 < iWidth)
        iWidth2 <<= 1;
    while(iHeight2 < iHeight)
        iHeight2 <<= 1;

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

THDX9_Vertex* THDX9_AllocVerticies(THRenderTarget* pTarget, size_t iCount)
{
    if(pTarget->iVertexCount + iCount > pTarget->iVertexLength)
    {
        pTarget->iVertexLength = (pTarget->iVertexLength * 2) + iCount;
        pTarget->pVerticies = (THDX9_Vertex*)realloc(pTarget->pVerticies,
            sizeof(THDX9_Vertex) * pTarget->iVertexLength);
    }
    THDX9_Vertex *pResult = pTarget->pVerticies + pTarget->iVertexCount;
    pTarget->iVertexCount += iCount;
    return pResult;
}

void THDX9_FlushSprites(THRenderTarget* pTarget)
{
    if(pTarget->iVertexCount == 0)
        return;
    
    IDirect3DTexture9 *pTexture = pTarget->pVerticies[0].tex;
    pTarget->pDevice->SetTexture(0, pTexture);
    size_t iStart = 0;
    for(size_t i = 6; i < pTarget->iVertexCount; i += 6)
    {
        if(pTarget->pVerticies[i].tex != pTexture)
        {
            pTarget->pDevice->DrawPrimitiveUP(D3DPT_TRIANGLELIST,
                (i - iStart) / 3, pTarget->pVerticies + iStart,
                sizeof(THDX9_Vertex));
            iStart = i;
            pTexture = pTarget->pVerticies[i].tex;
            pTarget->pDevice->SetTexture(0, pTexture);
        }
    }
    pTarget->pDevice->DrawPrimitiveUP(D3DPT_TRIANGLELIST,
        (pTarget->iVertexCount - iStart) / 3, pTarget->pVerticies + iStart,
        sizeof(THDX9_Vertex));

    pTarget->iVertexCount = 0;
}

#endif

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

#ifdef CORSIX_TH_USE_D3D9X
static const D3DXMATRIX g_mtxIdentity(
    1.0f, 0.0f, 0.0f, 0.0f,
    0.0f, 1.0f, 0.0f, 0.0f,
    0.0f, 0.0f, 1.0f, 0.0f,
    0.0f, 0.0f, 0.0f, 1.0f);

static const D3DXMATRIX g_mtxFlipH(
   -1.0f, 0.0f, 0.0f, 0.0f,
    0.0f, 1.0f, 0.0f, 0.0f,
    0.0f, 0.0f, 1.0f, 0.0f,
    0.0f, 0.0f, 0.0f, 1.0f);

static const D3DXMATRIX g_mtxFlipV(
    1.0f, 0.0f, 0.0f, 0.0f,
    0.0f,-1.0f, 0.0f, 0.0f,
    0.0f, 0.0f, 1.0f, 0.0f,
    0.0f, 0.0f, 0.0f, 1.0f);

static const D3DXMATRIX g_mtxFlipVH(
   -1.0f, 0.0f, 0.0f, 0.0f,
    0.0f,-1.0f, 0.0f, 0.0f,
    0.0f, 0.0f, 1.0f, 0.0f,
    0.0f, 0.0f, 0.0f, 1.0f);
#endif

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
            pSprite->pData, m_pPalette, m_pDevice, true);
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
                unsigned int iWidth, unsigned int iHeight, int iX, int iY,
                unsigned long iFlags, unsigned int iWidth2,
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

#ifdef CORSIX_TH_USE_D3D9X
    // Perform horizontal and vertical flips
    switch(iFlags & (THDF_FlipHorizontal | THDF_FlipVertical))
    {
    case 0:
        pCanvas->pSprite->SetTransform(&g_mtxIdentity);
        break;
    case THDF_FlipHorizontal:
        pCanvas->pSprite->SetTransform(&g_mtxFlipH);
        iX = -iX + rcSource.left - rcSource.right;
        break;
    case THDF_FlipVertical:
        pCanvas->pSprite->SetTransform(&g_mtxFlipV);
        iY = -iY + rcSource.top - rcSource.bottom;
        break;
    case THDF_FlipHorizontal | THDF_FlipVertical:
        pCanvas->pSprite->SetTransform(&g_mtxFlipVH);
        iX = -iX + rcSource.left - rcSource.right;
        iY = -iY + rcSource.top - rcSource.bottom;
        break;
    }

    // Do the actual drawing
    D3DXVECTOR3 vPosition((FLOAT)iX, (FLOAT)iY, 0.0f);
    pCanvas->pSprite->Draw(pTexture, &rcSource, NULL, &vPosition, cColour);
#else
    float fX = (float)iX;
    float fY = (float)iY;
    float fWidth = (float)(rcSource.right - rcSource.left);
    float fHeight = (float)(rcSource.bottom - rcSource.top);
    float fSprWidth = (float)iWidth2;
    float fSprHeight = (float)iHeight2;
    if(iFlags & THDF_FlipHorizontal)
    {
        LONG tmp = rcSource.right;
        rcSource.right = rcSource.left;
        rcSource.left = tmp;
    }
    if(iFlags & THDF_FlipVertical)
    {
        LONG tmp = rcSource.bottom;
        rcSource.bottom = rcSource.top;
        rcSource.top = tmp;
    }

#define SetVertexData(n) \
    pVerticies[0].tex = pTexture; \
    pVerticies[0].x = fX; \
    pVerticies[0].y = fY; \
    pVerticies[0].z = 0.0f; \
    pVerticies[1].x = fX + fWidth; \
    pVerticies[1].y = fY; \
    pVerticies[1].z = 0.0f; \
    pVerticies[2].x = fX + fWidth; \
    pVerticies[2].y = fY + fHeight; \
    pVerticies[2].z = 0.0f; \
    pVerticies[n].x = fX; \
    pVerticies[n].y = fY + fHeight; \
    pVerticies[n].z = 0.0f; \
    pVerticies[0].colour = cColour; \
    pVerticies[1].colour = cColour; \
    pVerticies[2].colour = cColour; \
    pVerticies[n].colour = cColour; \
    pVerticies[0].u = (float)rcSource.left   / fSprWidth; \
    pVerticies[0].v = (float)rcSource.top    / fSprHeight; \
    pVerticies[1].u = (float)rcSource.right  / fSprWidth; \
    pVerticies[1].v = pVerticies[0].v; \
    pVerticies[2].u = pVerticies[1].u; \
    pVerticies[2].v = (float)rcSource.bottom / fSprHeight; \
    pVerticies[n].u = pVerticies[0].u; \
    pVerticies[n].v = pVerticies[2].v; \

    THDX9_Vertex *pVerticies = THDX9_AllocVerticies(pCanvas, 6);
    SetVertexData(5);
    pVerticies[3] = pVerticies[0];
    pVerticies[4] = pVerticies[2];
#undef SetVertexData
#endif
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
            pSprite->iHeight, pData, m_pPalette, m_pDevice, true);
        pData -= 1024;
        delete[] pData;
    }
    return pSprite->pAltBitmap;
}

#endif // CORSIX_TH_USE_DX9_RENDERER
