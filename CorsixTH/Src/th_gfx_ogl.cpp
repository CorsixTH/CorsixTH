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
#ifdef CORSIX_TH_USE_OGL_RENDERER

#include "th_gfx.h"
#include <new>
#ifdef _MSC_VER
#pragma comment(lib, "OpenGL32")
#endif

THRenderTarget::THRenderTarget()
{
    pSDL = NULL;
}

void THRenderTarget_GetClipRect(const THRenderTarget* pTarget, THClipRect* pRect)
{
}

void THRenderTarget_SetClipRect(THRenderTarget* pTarget, const THClipRect* pRect)
{
}

void THRenderTarget_StartNonOverlapping(THRenderTarget* pTarget)
{
    // No optimisations at the moment
}

void THRenderTarget_FinishNonOverlapping(THRenderTarget* pTarget)
{
    // No optimisations at the moment
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
        *pColour = 0xFF << 24
            | (gs_iTHColourLUT[pData[0] & 0x3F])
            | (gs_iTHColourLUT[pData[1] & 0x3F]) << 8
            | (gs_iTHColourLUT[pData[2] & 0x3F]) << 16;
    }

    return true;
}

void THPalette::assign(THRenderTarget*, bool) const
{
}

int THPalette::getColourCount() const
{
    return m_iNumColours;
}

const unsigned char* THPalette::getColourData() const
{
    return (unsigned char*)m_aColours;
}

THSpriteSheet::THSpriteSheet()
{
    m_pSprites = 0;
    m_iSpriteCount = 0;
    m_pPalette = NULL;
}

THSpriteSheet::~THSpriteSheet()
{
    _freeSprites();
}

void THSpriteSheet::_freeSprites()
{
    for(unsigned int i = 0; i < m_iSpriteCount; ++i)
    {
        /*
        if(m_pSprites[i].pBitmap)
            m_pSprites[i].pBitmap->Release();
            */
        if(m_pSprites[i].pData)
            delete[] (m_pSprites[i].pData - 1024);
    }
    delete[] m_pSprites;
    m_pSprites = NULL;
    m_iSpriteCount = 0;
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
    return false;
}

void THSpriteSheet::setSpriteAltPaletteMap(unsigned int iSprite, const unsigned char* pMap)
{
    if(iSprite >= m_iSpriteCount)
        return;

    /*
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
    */
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

}

#endif // CORSIX_TH_USE_OGL_RENDERER
