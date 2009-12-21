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
#include <new>

THRenderTarget::THRenderTarget()
{
    m_pSurface = NULL;
    m_pCursor = NULL;
}

THRenderTarget::~THRenderTarget()
{
}

bool THRenderTarget::create(const THRenderTargetCreationParams* pParams)
{
    if(m_pSurface != NULL)
        return false;
    m_pSurface = SDL_SetVideoMode(pParams->iWidth, pParams->iHeight,
        pParams->iBPP, pParams->iSDLFlags);
    return m_pSurface != NULL;
}

const char* THRenderTarget::getLastError()
{
    return SDL_GetError();
}

bool THRenderTarget::startFrame()
{
    return true;
}

bool THRenderTarget::endFrame()
{
    if(m_pCursor)
    {
        m_pCursor->draw(this, m_iCursorX, m_iCursorY);
    }
    return SDL_Flip(m_pSurface) == 0;
}

bool THRenderTarget::fillBlack()
{
    return SDL_FillRect(m_pSurface, NULL, mapColour(0, 0, 0)) == 0;
}

uint32_t THRenderTarget::mapColour(uint8_t iR, uint8_t iG, uint8_t iB)
{
    return SDL_MapRGB(m_pSurface->format, iR, iG, iB);
}

bool THRenderTarget::fillRect(uint32_t iColour, int iX, int iY, int iW, int iH)
{
    SDL_Rect rcDest;
    rcDest.x = iX;
    rcDest.y = iY;
    rcDest.w = iW;
    rcDest.h = iH;
    return SDL_FillRect(m_pSurface, &rcDest, iColour) == 0;
}

void THRenderTarget::getClipRect(THClipRect* pRect) const
{
    SDL_GetClipRect(m_pSurface, reinterpret_cast<SDL_Rect*>(pRect));
}

void THRenderTarget::setClipRect(const THClipRect* pRect)
{
    SDL_SetClipRect(m_pSurface, reinterpret_cast<const SDL_Rect*>(pRect));
}

void THRenderTarget::startNonOverlapping()
{
     // SDL has no optimisations for drawing lots of non-overlapping sprites
}

void THRenderTarget::finishNonOverlapping()
{
     // SDL has no optimisations for drawing lots of non-overlapping sprites
}

void THRenderTarget::setCursor(THCursor* pCursor)
{
    m_pCursor = pCursor;
}

void THRenderTarget::setCursorPosition(int iX, int iY)
{
    m_iCursorX = iX;
    m_iCursorY = iY;
}

bool THRenderTarget::takeScreenshot(const char* sFile)
{
    return SDL_SaveBMP(m_pSurface, sFile) == 0;
}

THPalette::THPalette()
{
    m_iNumColours = 0;
    m_iTransparentIndex = -1;
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

    m_iNumColours = static_cast<int>(iDataLength) / 3;
    m_iTransparentIndex = -1;
    colour_t* pColour = m_aColours;
    for(int i = 0; i < m_iNumColours; ++i, pData += 3, ++pColour)
    {
        pColour->r = gs_iTHColourLUT[pData[0] & 0x3F];
        pColour->g = gs_iTHColourLUT[pData[1] & 0x3F];
        pColour->b = gs_iTHColourLUT[pData[2] & 0x3F];
        if(pColour->r == 0xFF && pColour->g == 0 && pColour->b == 0xFF)
            m_iTransparentIndex = i;
        pColour->unused = 0;
    }

    return true;
}

bool THPalette::setEntry(int iEntry, uint8_t iR, uint8_t iG, uint8_t iB)
{
    if(iEntry < 0 || iEntry >= m_iNumColours)
        return false;
    colour_t* pColour = m_aColours + iEntry;
    pColour->r = iR;
    pColour->g = iG;
    pColour->b = iB;
    if(iR == 0xFF && iG == 0 && iB == 0xFF)
        m_iTransparentIndex = iEntry;
    return true;
}

void THPalette::_assign(THRenderTarget* pTarget) const
{
    _assign(pTarget->getRawSurface());
}

void THPalette::_assign(SDL_Surface *pSurface) const
{
    SDL_SetPalette(pSurface, SDL_PHYSPAL | SDL_LOGPAL,
        const_cast<SDL_Colour*>(m_aColours), 0, m_iNumColours);
    if(m_iTransparentIndex != -1)
    {
        SDL_SetColorKey(pSurface, SDL_SRCCOLORKEY | SDL_RLEACCEL,
            static_cast<Uint32>(m_iTransparentIndex));
    }
    else
        SDL_SetColorKey(pSurface, 0, 0);
}

THRawBitmap::THRawBitmap()
{
    m_pBitmap = NULL;
    m_pPalette = NULL;
    m_pData = NULL;
}

THRawBitmap::~THRawBitmap()
{
    SDL_FreeSurface(m_pBitmap);
    delete[] m_pData;
}

void THRawBitmap::setPalette(const THPalette* pPalette)
{
    m_pPalette = pPalette;
}

bool THRawBitmap::loadFromTHFile(const unsigned char* pPixelData,
                                 size_t iPixelDataLength,
                                 int iWidth, THRenderTarget *pUnused)
{
    if(m_pPalette == NULL)
        return false;

    SDL_FreeSurface(m_pBitmap);
    m_pBitmap = NULL;
    delete[] m_pData;
    m_pData = NULL;

    m_pData = new (std::nothrow) unsigned char[iPixelDataLength];
    if(m_pData == NULL)
        return false;
    memcpy(m_pData, pPixelData, iPixelDataLength);

    int iHeight = static_cast<int>(iPixelDataLength) / iWidth;
    m_pBitmap = SDL_CreateRGBSurfaceFrom(m_pData, iWidth, iHeight, 8, iWidth, 0, 0, 0, 0);
    if(m_pBitmap == NULL)
        return false;
    m_pPalette->_assign(m_pBitmap);

    return true;
}

void THRawBitmap::draw(THRenderTarget* pCanvas, int iX, int iY)
{
    if(m_pBitmap == NULL)
        return;

    SDL_Rect rcDest;
    rcDest.x = iX;
    rcDest.y = iY;
    SDL_BlitSurface(m_pBitmap, NULL, pCanvas->getRawSurface(), &rcDest);
}

void THRawBitmap::draw(THRenderTarget* pCanvas, int iX, int iY, 
                       int iSrcX, int iSrcY, int iWidth, int iHeight)
{
    if(m_pBitmap == NULL)
        return;

    SDL_Rect rcSrc;
    rcSrc.x = iSrcX;
    rcSrc.y = iSrcY;
    rcSrc.w = iWidth;
    rcSrc.h = iHeight;
    SDL_Rect rcDest;
    rcDest.x = iX;
    rcDest.y = iY;
    SDL_BlitSurface(m_pBitmap, &rcSrc, pCanvas->getRawSurface(), &rcDest);
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
            m_pPalette->_assign(pSprite->pBitmap[0]);
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
    SDL_BlitSurface(pSprite, NULL, pCanvas->getRawSurface(), &rctDest);
}

bool THSpriteSheet::hitTestSprite(unsigned int iSprite, int iX, int iY, unsigned long iFlags) const
{
    if(iX < 0 || iY < 0 || iSprite >= m_iSpriteCount)
        return false;
    int iWidth = (int)m_pSprites[iSprite].iWidth;
    int iHeight = (int)m_pSprites[iSprite].iHeight;
    if(iX >= iWidth || iY >= iHeight)
        return false;
    if(iFlags & THDF_FlipHorizontal)
        iX = iWidth - iX - 1;
    if(iFlags & THDF_FlipVertical)
        iY = iHeight - iY - 1;
    return (int)m_pSprites[iSprite].pData[iY * iWidth + iX] != m_pPalette->m_iTransparentIndex;
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

SDL_Surface* THSpriteSheet::_getSpriteBitmap(unsigned int iSprite, unsigned long iFlags)
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
    m_pPalette->_assign(pBitmap);

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

THCursor::THCursor()
{
    m_pBitmap = NULL;
    m_iHotspotX = 0;
    m_iHotspotY = 0;
}

THCursor::~THCursor()
{
    SDL_FreeSurface(m_pBitmap);
}

bool THCursor::createFromSprite(THSpriteSheet* pSheet, unsigned int iSprite,
                                int iHotspotX, int iHotspotY)
{
    SDL_FreeSurface(m_pBitmap);
    m_pBitmap = NULL;

    if(pSheet == NULL || iSprite >= pSheet->getSpriteCount())
        return false;
    SDL_Surface *pSprite = pSheet->_getSpriteBitmap(iSprite, 0);
    if(pSprite == NULL || (m_pBitmap = SDL_DisplayFormat(pSprite)) == NULL)
        return false;
    m_iHotspotX = iHotspotX;
    m_iHotspotY = iHotspotY;
    return true;
}

void THCursor::use(THRenderTarget* pTarget)
{
    SDL_ShowCursor(0);
    pTarget->setCursor(this);
}

bool THCursor::setPosition(THRenderTarget* pTarget, int iX, int iY)
{
    pTarget->setCursorPosition(iX, iY);
    return true;
}

void THCursor::draw(THRenderTarget* pCanvas, int iX, int iY)
{
    SDL_Rect rcDest;
    rcDest.x = (Sint16)(iX - m_iHotspotX);
    rcDest.y = (Sint16)(iY - m_iHotspotY);
    SDL_BlitSurface(m_pBitmap, NULL, pCanvas->getRawSurface(), &rcDest);
}

#endif // CORSIX_TH_USE_SDL_RENDERER
