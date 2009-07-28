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
#ifdef CORSIX_TH_USE_SDL_RENDERER
#include "th_gfx.h"
#include "th_map.h"
#include <SDL.h>
#include <new>

void THRenderTarget_GetClipRect(const THRenderTarget* pTarget, THClipRect* pRect)
{
    SDL_GetClipRect(const_cast<SDL_Surface*>(pTarget), reinterpret_cast<SDL_Rect*>(pRect));
}

void THRenderTarget_SetClipRect(THRenderTarget* pTarget, const THClipRect* pRect)
{
    SDL_SetClipRect(pTarget, reinterpret_cast<const SDL_Rect*>(pRect));
}

void THRenderTarget_StartNonOverlapping(THRenderTarget* pTarget)
{
    // SDL has no optimisations for drawing lots of non-overlapping sprites
}

void THRenderTarget_FinishNonOverlapping(THRenderTarget* pTarget)
{
    // SDL has no optimisations for drawing lots of non-overlapping sprites
}

THPalette::THPalette()
{
    m_iNumColours = 0;
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
        pColour->unused = 0;
    }

    return true;
}

void THPalette::assign(THRenderTarget* pTarget) const
{
    struct compile_time_assert
    {
        int colour_size[sizeof(SDL_Color) == sizeof(colour_t) ? 1 : -1];
    };

    SDL_SetPalette(pTarget, SDL_PHYSPAL | SDL_LOGPAL, (SDL_Color*)m_aColours, 0, m_iNumColours);
    SDL_SetColorKey(pTarget, SDL_SRCCOLORKEY | SDL_RLEACCEL, 0xFF);
}

THSpriteSheet::THSpriteSheet()
{
    m_pSprites = NULL;
    m_pPalette = NULL;
    m_iSpriteCount = 0;
    m_bHasAnyFlaggedBitmaps = false;
}

THSpriteSheet::~THSpriteSheet()
{
    _freeSprites();
}

void THSpriteSheet::_freeSprites()
{
    if(m_bHasAnyFlaggedBitmaps)
    {
        for(unsigned int i = 0; i < m_iSpriteCount; ++i)
        {
            for(unsigned int j = 0; j < 32; ++j)
                SDL_FreeSurface(m_pSprites[i].pBitmap[j]);
            delete[] m_pSprites[i].pData;
        }
    }
    else
    {
        for(unsigned int i = 0; i < m_iSpriteCount; ++i)
        {
            SDL_FreeSurface(m_pSprites[i].pBitmap[0]);
            delete[] m_pSprites[i].pData;
        }
    }
    delete[] m_pSprites;
    m_pSprites = NULL;
    m_iSpriteCount = 0;
    m_bHasAnyFlaggedBitmaps = false;
}

void THSpriteSheet::setPalette(const THPalette* pPalette)
{
    m_pPalette = pPalette;
}

bool THSpriteSheet::loadFromTHFile(
                        const unsigned char* pTableData, size_t iTableDataLength,
                        const unsigned char* pChunkData, size_t iChunkDataLength,
                        bool bComplexChunks, THRenderTarget*)
{
    _freeSprites();
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
        for(unsigned int j = 0; j < 32; ++j)
            m_pSprites[i].pBitmap[j] = NULL;
        pSprite->pData = NULL;
        pSprite->pAltPaletteMap = NULL;
        pSprite->iWidth = pTHSprite->width;
        pSprite->iHeight = pTHSprite->height;

        if(pSprite->iWidth == 0 || pSprite->iHeight == 0)
            continue;

        {
            THChunkRenderer oRenderer(pSprite->iWidth, pSprite->iHeight, NULL);
            int iDataLen = static_cast<int>(iChunkDataLength) - static_cast<int>(pTHSprite->position);
            if(iDataLen < 0)
                iDataLen = 0;
            oRenderer.decodeChunks(pChunkData + pTHSprite->position, iDataLen, bComplexChunks);
            pSprite->pData = oRenderer.takeData();
        }

        pSprite->pBitmap[0] = SDL_CreateRGBSurfaceFrom(pSprite->pData,
            pSprite->iWidth, pSprite->iHeight, 8, pSprite->iWidth, 0, 0, 0, 0);

        if(pSprite->pBitmap[0] != NULL)
            m_pPalette->assign(pSprite->pBitmap[0]);
    }

    return true;
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
    if(iSprite >= m_iSpriteCount)
        return;

    SDL_Surface *pSprite = _getSpriteBitmap(iSprite, iFlags & 0x1F);
    if(pSprite == NULL)
        return;

    SDL_Rect rctDest;
    rctDest.x = iX;
    rctDest.y = iY;
    SDL_BlitSurface(pSprite, NULL, pCanvas, &rctDest);
}

void THSpriteSheet::setSpriteAltPaletteMap(unsigned int iSprite, const unsigned char* pMap)
{
    if(iSprite >= m_iSpriteCount)
        return;

    sprite_t *pSprite = m_pSprites + iSprite;
    if(pSprite->pAltPaletteMap != pMap)
    {
        pSprite->pAltPaletteMap = pMap;
        for(int i = 16; i < 32; ++i)
        {
            SDL_FreeSurface(pSprite->pBitmap[i]);
            pSprite->pBitmap[i] = NULL;
        }
    }
}

THRenderTarget* THSpriteSheet::_getSpriteBitmap(unsigned int iSprite, unsigned long iFlags)
{
    SDL_Surface* pBitmap = m_pSprites[iSprite].pBitmap[iFlags];
    if(pBitmap != NULL)
        return pBitmap;
    if(m_pSprites[iSprite].pData == NULL)
        return NULL;

    m_bHasAnyFlaggedBitmaps = true;

    THDrawFlags eTask;
    SDL_Surface* pBaseBitmap;
    if(iFlags & THDF_AltPalette)
    {
        pBaseBitmap = _getSpriteBitmap(iSprite, iFlags & ~THDF_AltPalette);
        eTask = THDF_AltPalette;
    }
    else if(iFlags & (THDF_Alpha75 | THDF_Alpha50))
    {
        pBaseBitmap = _getSpriteBitmap(iSprite, iFlags & 0x3);
        eTask = (iFlags & THDF_Alpha75) ? THDF_Alpha75 : THDF_Alpha50;
    }
    else if(iFlags == (THDF_FlipHorizontal | THDF_FlipVertical))
    {
        pBaseBitmap = _getSpriteBitmap(iSprite, THDF_FlipHorizontal);
        eTask = THDF_FlipVertical;
    }
    else // iFlags == THDF_FlipHorizontal or THDF_FlipVertical
    {
        pBaseBitmap = _getSpriteBitmap(iSprite, 0);
        eTask = (THDrawFlags)iFlags;
    }
    if(pBaseBitmap == NULL)
        return NULL;

    pBitmap = SDL_CreateRGBSurface(SDL_HWSURFACE | SDL_SRCCOLORKEY,
        pBaseBitmap->w, pBaseBitmap->h, 8, 0, 0, 0, 0);
    m_pPalette->assign(pBitmap);

    if(eTask == THDF_AltPalette)
    {
        SDL_LockSurface(pBitmap);
        SDL_LockSurface(pBaseBitmap);
        unsigned char *pDestPixels = (unsigned char*)pBitmap->pixels;
        const unsigned char *pSrcPixels = (const unsigned char*)pBaseBitmap->pixels;
        const unsigned char *pMap = m_pSprites[iSprite].pAltPaletteMap;
        for(int iY = 0; iY < pBitmap->h; ++iY)
        {
            if(pMap)
            {
                for(int iX = 0; iX < pBitmap->w; ++iX)
                {
                    unsigned char iPixel = pSrcPixels[iX];
                    if(iPixel != 0xFF)
                        iPixel = pMap[iPixel];
                    pDestPixels[iX] = iPixel;
                }
            }
            else
                memcpy(pDestPixels, pSrcPixels, pBitmap->w);
            pDestPixels += pBitmap->pitch;
            pSrcPixels += pBaseBitmap->pitch;
        }
        SDL_UnlockSurface(pBaseBitmap);
        SDL_UnlockSurface(pBitmap);
    }
    else if(eTask == THDF_Alpha50 || eTask == THDF_Alpha75)
    {
        SDL_LockSurface(pBitmap);
        SDL_LockSurface(pBaseBitmap);
        unsigned char *pDestPixels = (unsigned char*)pBitmap->pixels;
        const unsigned char *pSrcPixels = (const unsigned char*)pBaseBitmap->pixels;
        for(int iY = 0; iY < pBitmap->h; ++iY)
        {
            memcpy(pDestPixels, pSrcPixels, pBitmap->w);
            pDestPixels += pBitmap->pitch;
            pSrcPixels += pBaseBitmap->pitch;
        }
        SDL_UnlockSurface(pBaseBitmap);
        SDL_UnlockSurface(pBitmap);

        SDL_SetAlpha(pBitmap, SDL_SRCALPHA | SDL_RLEACCEL, eTask == THDF_Alpha50 ? 128 : 64);
    }
    else
    {
        SDL_LockSurface(pBitmap);
        SDL_LockSurface(pBaseBitmap);
        unsigned char *pDestPixels = (unsigned char*)pBitmap->pixels;
        const unsigned char *pSrcPixels = (const unsigned char*)pBaseBitmap->pixels;

        if(eTask == THDF_FlipHorizontal)
        {
            for(int iY = 0; iY < pBitmap->h; ++iY)
            {
                for(int iX = 0; iX < pBitmap->w; ++iX)
                {
                    pDestPixels[iX] = pSrcPixels[pBitmap->w - iX - 1];
                }
                pDestPixels += pBitmap->pitch;
                pSrcPixels += pBaseBitmap->pitch;
            }
        }
        else
        {
            pSrcPixels += pBaseBitmap->pitch * (pBaseBitmap->h - 1);
            for(int iY = 0; iY < pBitmap->h; ++iY)
            {
                memcpy(pDestPixels, pSrcPixels, pBitmap->w);
                pDestPixels += pBitmap->pitch;
                pSrcPixels -= pBaseBitmap->pitch;
            }
        }

        SDL_UnlockSurface(pBaseBitmap);
        SDL_UnlockSurface(pBitmap);
    }

    m_pSprites[iSprite].pBitmap[iFlags] = pBitmap;
    return pBitmap;
}

#endif // CORSIX_TH_USE_SDL_RENDERER
