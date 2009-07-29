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
#include <D3DX9.h>
#pragma comment(lib, "D3D9")
#pragma comment(lib, "D3DX9")
#include "th_gfx.h"
#include <new>

THRenderTarget::THRenderTarget()
{
    pD3D = NULL;
    pDevice = NULL;
    pSprite = NULL;
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
    colour_t* pColour = m_aColours;
    for(int i = 0; i < m_iNumColours; ++i, pData += 3, ++pColour)
    {
        pColour->r = gs_iTHColourLUT[pData[0] & 0x3F];
        pColour->g = gs_iTHColourLUT[pData[1] & 0x3F];
        pColour->b = gs_iTHColourLUT[pData[2] & 0x3F];
    }

    return true;
}

void THPalette::assign(THRenderTarget* pTarget) const
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

THSpriteSheet::THSpriteSheet()
{
    m_pSprites = 0;
    m_iSpriteCount = 0;
    m_pPalette = NULL;
    m_pDevice = NULL;
}

THSpriteSheet::~THSpriteSheet()
{
    _freeSprites();
}

void THSpriteSheet::_freeSprites()
{
    for(unsigned int i = 0; i < m_iSpriteCount; ++i)
    {
        if(m_pSprites[i].pBitmap)
            m_pSprites[i].pBitmap->Release();
        if(m_pSprites[i].pData)
            delete[] (m_pSprites[i].pData - 1024);
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
    return true;
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

    // Crop to clip rectangle
    RECT rcSource;
    rcSource.left = 0;
    rcSource.top = 0;
    rcSource.right = m_pSprites[iSprite].iWidth;
    rcSource.bottom = m_pSprites[iSprite].iHeight;
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
