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

#include "config.h"

#include "th_gfx.h"
#ifdef CORSIX_TH_USE_FREETYPE2
#include "th_gfx_font.h"
#endif
#include "th_map.h"
#include <new>
#ifndef max
#define max(a, b) ((a) > (b) ? (a) : (b))
#endif

THRenderTarget::THRenderTarget()
{
    m_pWindow = NULL;
    m_pRenderer = NULL;
    m_pFormat = NULL;
    m_pCursor = NULL;
    m_bShouldScaleBitmaps = false;
}

THRenderTarget::~THRenderTarget()
{
    SDL_FreeFormat(m_pFormat);
    SDL_DestroyRenderer(m_pRenderer);
    SDL_DestroyWindow(m_pWindow);
}

bool THRenderTarget::create(const THRenderTargetCreationParams* pParams)
{
    if(m_pRenderer != NULL)
        return false;

    SDL_CreateWindowAndRenderer(pParams->iWidth, pParams->iHeight,
                                pParams->iSDLFlags, &m_pWindow, &m_pRenderer);

    if (!m_pWindow || !m_pRenderer)
    {
        return false;
    }

    SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "linear");

    SDL_SetWindowTitle(m_pWindow, "CorsixTH");
    SDL_RenderSetLogicalSize(m_pRenderer, pParams->iWidth, pParams->iHeight);
    m_pFormat = SDL_AllocFormat(SDL_PIXELFORMAT_ABGR8888);

    return true;
}

bool THRenderTarget::setScaleFactor(float fScale, THScaledItems eWhatToScale)
{
    m_bShouldScaleBitmaps = false;
    if(0.999 <= fScale && fScale <= 1.001)
        return true;

    // TODO: Fix this.
    return false;
}

void THRenderTarget::setCaption(const char* sCaption)
{
    SDL_SetWindowTitle(m_pWindow, sCaption);
}

const char* THRenderTarget::getLastError()
{
    return SDL_GetError();
}

bool THRenderTarget::startFrame()
{
    fillBlack();
    return true;
}

bool THRenderTarget::endFrame()
{
    // End the frame by adding the cursor and possibly a filter.
    if(m_pCursor)
    {
        m_pCursor->draw(this, m_iCursorX, m_iCursorY);
    }
    if(m_bBlueFilterActive)
    {
        SDL_SetRenderDrawBlendMode(m_pRenderer, SDL_BLENDMODE_BLEND);
        SDL_SetRenderDrawColor(m_pRenderer, 255*0.7f, 255*0.7f, 255*1.0f, 255*0.5f);
        SDL_RenderFillRect(m_pRenderer, NULL);
    }

    SDL_RenderPresent(m_pRenderer);
    return true;
}

bool THRenderTarget::fillBlack()
{
    SDL_SetRenderDrawColor(m_pRenderer, 0, 0, 0, SDL_ALPHA_OPAQUE);
    SDL_RenderClear(m_pRenderer);

    return true;
}

void THRenderTarget::setBlueFilterActive(bool bActivate)
{
    m_bBlueFilterActive = bActivate;
}

uint32_t THRenderTarget::mapColour(uint8_t iR, uint8_t iG, uint8_t iB)
{
    return THPalette::packARGB(0xFF, iR, iG, iB);
}

bool THRenderTarget::fillRect(uint32_t iColour, int iX, int iY, int iW, int iH)
{
    SDL_Rect rcDest = {
        .x = iX,
        .y = iY,
        .w = iW,
        .h = iH
    };

    Uint8 r, g, b, a;
    SDL_GetRGBA(iColour, m_pFormat, &r, &g, &b, &a);

    SDL_SetRenderDrawBlendMode(m_pRenderer, SDL_BLENDMODE_BLEND);
    SDL_SetRenderDrawColor(m_pRenderer, r, g, b, a);
    SDL_RenderFillRect(m_pRenderer, &rcDest);

    return true;
}

void THRenderTarget::getClipRect(THClipRect* pRect) const
{
    SDL_RenderGetClipRect(m_pRenderer, reinterpret_cast<SDL_Rect*>(pRect));
}

void THRenderTarget::setClipRect(const THClipRect* pRect)
{
    SDL_RenderSetClipRect(m_pRenderer, reinterpret_cast<const SDL_Rect*>(pRect));
}

int THRenderTarget::getWidth() const
{
    int w;
    SDL_RenderGetLogicalSize(m_pRenderer, &w, NULL);
    return w;
}

int THRenderTarget::getHeight() const
{
    int h;
    SDL_RenderGetLogicalSize(m_pRenderer, NULL, &h);
    return h;
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
    // TODO: Implement this.
    return false;
}


bool THRenderTarget::shouldScaleBitmaps(float* pFactor)
{
    if(!m_bShouldScaleBitmaps)
        return false;
    if(pFactor)
        *pFactor = m_fBitmapScaleFactor;
    return true;
}

SDL_Texture* THRenderTarget::createPalettizedTexture(int iWidth, int iHeight,
                                                     const unsigned char* pPixels,
                                                     const THPalette* pPalette) const
{
    uint32_t *pARGBPixels = new (std::nothrow) uint32_t[iWidth * iHeight];
    if(pARGBPixels == NULL)
        return 0;
    const uint32_t* pColours = pPalette->getARGBData();

    uint32_t *pRow = pARGBPixels;
    for(int y = 0; y < iHeight; ++y)
    {
        for(int x = 0; x < iWidth; ++x, ++pPixels, ++pRow)
        {
            *pRow = pColours[*pPixels];
        }
    }

    SDL_Texture *pTexture = createTexture(iWidth, iHeight, pARGBPixels);
    delete [] pARGBPixels;
    return pTexture;
}

SDL_Texture* THRenderTarget::createTexture(int iWidth, int iHeight,
                                           const uint32_t* pPixels) const
{
    SDL_Texture *pTexture = SDL_CreateTexture(m_pRenderer, m_pFormat->format, SDL_TEXTUREACCESS_STATIC, iWidth, iHeight);
    SDL_UpdateTexture(pTexture, NULL, pPixels, sizeof(*pPixels) * iWidth);
    SDL_SetTextureBlendMode(pTexture, SDL_BLENDMODE_BLEND);
    SDL_SetTextureColorMod(pTexture, 0xFF, 0xFF, 0xFF);
    SDL_SetTextureAlphaMod(pTexture, 0xFF);

    return pTexture;
}

void THRenderTarget::draw(SDL_Texture *pTexture, const SDL_Rect *prcSrcRect, const SDL_Rect *prcDstRect, int iFlags)
{
    SDL_SetTextureAlphaMod(pTexture, 0xFF);
    if (iFlags & THDF_Alpha50)
    {
        SDL_SetTextureAlphaMod(pTexture, 0x80);
    }
    else if (iFlags & THDF_Alpha75)
    {
        SDL_SetTextureAlphaMod(pTexture, 0x40);
    }

    int iSDLFlip = SDL_FLIP_NONE;
    if(iFlags & THDF_FlipHorizontal)
        iSDLFlip |= SDL_FLIP_HORIZONTAL;
    if (iFlags & THDF_FlipVertical)
        iSDLFlip |= SDL_FLIP_VERTICAL;

    if (iSDLFlip != 0) {
        SDL_RenderCopyEx(m_pRenderer, pTexture, prcSrcRect, prcDstRect, 0, NULL, (SDL_RendererFlip)iSDLFlip);
    } else {
        SDL_RenderCopy(m_pRenderer, pTexture, prcSrcRect, prcDstRect);
    }
}


void THRenderTarget::drawLine(THLine *pLine, int iX, int iY)
{
    SDL_SetRenderDrawColor(m_pRenderer, pLine->m_iR, pLine->m_iG, pLine->m_iB, pLine->m_iA);

    double lastX, lastY;
    lastX = pLine->m_pFirstOp->m_fX;
    lastY = pLine->m_pFirstOp->m_fY;

    THLine::THLineOperation* op = (THLine::THLineOperation*)(pLine->m_pFirstOp->m_pNext);
    while (op) {
        if (op->type == THLine::THLOP_LINE) {
            SDL_RenderDrawLine(m_pRenderer, lastX + iX, lastY + iY, op->m_fX + iX, op->m_fY + iY);
        }

        lastX = op->m_fX;
        lastY = op->m_fY;

        op = (THLine::THLineOperation*)(op->m_pNext);
    }
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

    m_iNumColours = static_cast<int>(iDataLength / 3);
    for(int i = 0; i < m_iNumColours; ++i, pData += 3)
    {
        unsigned char iR = gs_iTHColourLUT[pData[0] & 0x3F];
        unsigned char iG = gs_iTHColourLUT[pData[1] & 0x3F];
        unsigned char iB = gs_iTHColourLUT[pData[2] & 0x3F];
        uint32_t iColour = packARGB(0xFF, iR, iG, iB);
        // Remap magenta to transparent
        if(iColour == packARGB(0xFF, 0xFF, 0x00, 0xFF))
            iColour = packARGB(0x00, 0x00, 0x00, 0x00);
        m_aColoursARGB[i] = iColour;
    }

    return true;
}

bool THPalette::setEntry(int iEntry, uint8_t iR, uint8_t iG, uint8_t iB)
{
    if(iEntry < 0 || iEntry >= m_iNumColours)
        return false;
    uint32_t iColour = packARGB(0xFF, iR, iG, iB);
    // Remap magenta to transparent
    if(iColour == packARGB(0xFF, 0xFF, 0x00, 0xFF))
        iColour = packARGB(0x00, 0x00, 0x00, 0x00);
    m_aColoursARGB[iEntry] = iColour;
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

THRawBitmap::THRawBitmap()
{
    m_pTexture = NULL;
    m_pPalette = NULL;
    m_pTarget = NULL;
    m_iWidth = 0;
    m_iHeight = 0;
}

THRawBitmap::~THRawBitmap()
{
    if (m_pTexture)
    {
        SDL_DestroyTexture(m_pTexture);
    }
}

void THRawBitmap::setPalette(const THPalette* pPalette)
{
    m_pPalette = pPalette;
}

bool THRawBitmap::loadFromTHFile(const unsigned char* pPixelData,
                                 size_t iPixelDataLength, int iWidth,
                                 THRenderTarget *pEventualCanvas)
{
    if(pEventualCanvas == NULL)
        return false;

    int iHeight = static_cast<int>(iPixelDataLength)/iWidth;
    m_pTexture = pEventualCanvas->createPalettizedTexture(iWidth, iHeight, pPixelData, m_pPalette);

    if(!m_pTexture)
        return false;

    m_iWidth = iWidth;
    m_iHeight = static_cast<int>(iPixelDataLength) / iWidth;
    m_pTarget = pEventualCanvas;

    return true;
}

void THRawBitmap::draw(THRenderTarget* pCanvas, int iX, int iY)
{
    if(m_pTexture == NULL)
        return;

    const SDL_Rect rcDest = {
        .x = iX,
        .y = iY,
        .w = m_iWidth,
        .h = m_iHeight,
    };

    pCanvas->draw(m_pTexture, NULL, &rcDest, 0);
}

void THRawBitmap::draw(THRenderTarget* pCanvas, int iX, int iY,
                       int iSrcX, int iSrcY, int iWidth, int iHeight)
{
    if (m_pTexture == NULL)
        return;

    const SDL_Rect rcSrc = {
        .x = iSrcX,
        .y = iSrcY,
        .w = iWidth,
        .h = iHeight,
    };

    const SDL_Rect rcDest = {
        .x = iX,
        .y = iY,
        .w = m_iWidth,
        .h = m_iHeight,
    };

    pCanvas->draw(m_pTexture, &rcSrc, &rcDest, 0);
}

THSpriteSheet::THSpriteSheet()
{
    m_pSprites = NULL;
    m_pPalette = NULL;
    m_pTarget = NULL;
    m_pMegaTexture = 0;
    m_iMegaTextureSize = 0;
    m_iSpriteCount = 0;
}

THSpriteSheet::~THSpriteSheet()
{
    _freeSprites();
}

void THSpriteSheet::_freeSprites()
{
    for(unsigned int i = 0; i < m_iSpriteCount; ++i)
    {
        if (m_pSprites[i].pTexture != m_pMegaTexture)
            SDL_DestroyTexture(m_pSprites[i].pTexture);
        if (m_pSprites[i].pAltTexture != m_pMegaTexture)
            SDL_DestroyTexture(m_pSprites[i].pAltTexture);
        if(m_pSprites[i].pData)
            delete[] m_pSprites[i].pData;
    }
    delete[] m_pSprites;
    m_pSprites = NULL;
    m_iSpriteCount = 0;

    SDL_DestroyTexture(m_pMegaTexture);
    m_pMegaTexture = NULL;
    m_iMegaTextureSize = 0;
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
        return false;

    m_iSpriteCount = (unsigned int)(iTableDataLength / sizeof(th_sprite_t));
    m_pSprites = new (std::nothrow) sprite_t[m_iSpriteCount];
    if(m_pSprites == NULL)
    {
        m_iSpriteCount = 0;
        return false;
    }
    m_pTarget = pCanvas;

    for(unsigned int i = 0; i < m_iSpriteCount; ++i)
    {
        sprite_t *pSprite = m_pSprites + i;
        const th_sprite_t *pTHSprite = reinterpret_cast<const th_sprite_t*>(pTableData) + i;

        pSprite->pTexture = NULL;
        pSprite->pAltTexture = NULL;
        pSprite->pData = NULL;
        pSprite->pAltPaletteMap = NULL;
        pSprite->iWidth = pTHSprite->width;
        pSprite->iHeight = pTHSprite->height;

        if(pSprite->iWidth == 0 || pSprite->iHeight == 0)
            continue;

        {
            unsigned char *pData = new unsigned char[pSprite->iWidth * pSprite->iHeight];
            THChunkRenderer oRenderer(pSprite->iWidth, pSprite->iHeight, pData);
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

void THSpriteSheet::_makeSingleTex(sprite_t** ppSortedSprites, unsigned int iSize)
{
    uint32_t *pData = new (std::nothrow) uint32_t[iSize * iSize];
    if(pData == NULL)
        return;

    // Pass 1: Fill entirely transparent
    uint32_t* pRow = pData;
    uint32_t iTransparent = THPalette::packARGB(0x00, 0x00, 0x00, 0x00);
    for(unsigned int y = 0; y < iSize; ++y)
    {
        for(unsigned int x = 0; x < iSize; ++x, ++pRow)
        {
            *pRow = iTransparent;
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

        pSprite->pTexture = m_pMegaTexture;
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
        pRow = pData + pSprite->iSheetY * iSize + pSprite->iSheetX;
        for(unsigned int y = 0; y < pSprite->iHeight; ++y)
        {
            for(unsigned int x = 0; x < pSprite->iWidth; ++x, ++pRow, ++pPixels)
            {
                *pRow = pColours[*pPixels];
            }
        }
    }

    m_pMegaTexture = m_pTarget->createTexture(iSize, iSize, pData);
    delete[] pData;
    if(m_pMegaTexture)
        m_iMegaTextureSize = iSize;
}

void THSpriteSheet::setSpriteAltPaletteMap(unsigned int iSprite, const unsigned char* pMap)
{
    if(iSprite >= m_iSpriteCount)
        return;

    sprite_t *pSprite = m_pSprites + iSprite;
    if(pSprite->pAltPaletteMap != pMap)
    {
        pSprite->pAltPaletteMap = pMap;
        if(pSprite->pAltTexture)
        {
            // TODO: alt texture == mega?
            SDL_DestroyTexture(pSprite->pAltTexture);
            pSprite->pAltTexture = NULL;
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

bool THSpriteSheet::getSpriteAverageColour(unsigned int iSprite, THColour* pColour) const
{
    if(iSprite >= m_iSpriteCount)
        return false;
    const sprite_t *pSprite = m_pSprites + iSprite;
    int iCountTotal = 0;
    int iUsageCounts[256] = {0};
    for(unsigned int i = 0; i < pSprite->iWidth * pSprite->iHeight; ++i)
    {
        unsigned char cPalIndex = pSprite->pData[i];
        uint32_t iColour = m_pPalette->getARGBData()[cPalIndex];
        if((iColour >> 24) == 0)
            continue;
        // Grant higher score to pixels with high or low intensity (helps avoid grey fonts)
        unsigned char iR = static_cast<uint8_t> ((iColour >>  0) & 0xFF);
        unsigned char iG = static_cast<uint8_t> ((iColour >>  8) & 0xFF);
        unsigned char iB = static_cast<uint8_t> ((iColour >> 16) & 0xFF);
        unsigned char cIntensity = (unsigned char)(((int)iR + (int)iG + (int)iB) / 3);
        int iScore = 1 + max(0, 3 - ((255 - cIntensity) / 32)) + max(0, 3 - (cIntensity / 32));
        iUsageCounts[cPalIndex] += iScore;
        iCountTotal += iScore;
    }
    if(iCountTotal == 0)
        return false;
    int iHighestCountIndex = 0;
    for(int i = 0; i < 256; ++i)
    {
        if(iUsageCounts[i] > iUsageCounts[iHighestCountIndex])
            iHighestCountIndex = i;
    }
    *pColour = m_pPalette->getARGBData()[iHighestCountIndex];
    return true;
}

void THSpriteSheet::drawSprite(THRenderTarget* pCanvas, unsigned int iSprite, int iX, int iY, unsigned long iFlags)
{
    if(iSprite >= m_iSpriteCount || pCanvas == NULL || pCanvas != m_pTarget)
        return;
    sprite_t &sprite = m_pSprites[iSprite];

    // Find or create the texture
    SDL_Texture *pTexture = sprite.pTexture;
    if(!pTexture)
    {
        if(sprite.pData == NULL)
            return;

        pTexture = m_pTarget->createPalettizedTexture(sprite.iWidth, sprite.iHeight,
                                                      sprite.pData, m_pPalette);
        sprite.pTexture = pTexture;
    }
    if(iFlags & THDF_AltPalette)
    {
        pTexture = sprite.pAltTexture;
        if(!pTexture)
        {
            pTexture = _makeAltBitmap(&sprite);
            if(!pTexture)
                return;
        }
    }

    SDL_Rect rcSrc = {
        .x = 0,
        .y = 0,
        .w = sprite.iWidth,
        .h = sprite.iHeight,
    };

    SDL_Rect rcDest = {
        .x = iX,
        .y = iY,
        .w = sprite.iWidth,
        .h = sprite.iHeight,
    };


    if(pTexture == m_pMegaTexture)
    {
        rcSrc.x = sprite.iSheetX;
        rcSrc.y = sprite.iSheetY;
    }

    pCanvas->draw(pTexture, &rcSrc, &rcDest, iFlags);
}

void THSpriteSheet::wxDrawSprite(unsigned int iSprite, unsigned char* pRGBData, unsigned char* pAData)
{
    if(iSprite >= m_iSpriteCount || pRGBData == NULL || pAData == NULL)
        return;
    sprite_t *pSprite = m_pSprites + iSprite;
    const uint32_t* pColours = m_pPalette->getARGBData();

    const unsigned char *pPixels = pSprite->pData;
    for(unsigned int y = 0; y < pSprite->iHeight; ++y)
    {
        for(unsigned int x = 0; x < pSprite->iWidth; ++x, ++pPixels, ++pAData, pRGBData += 3)
        {
            pRGBData[0] = (pColours[*pPixels] >>  0) & 0xFF;
            pRGBData[1] = (pColours[*pPixels] >>  8) & 0xFF;
            pRGBData[2] = (pColours[*pPixels] >> 16) & 0xFF;
            pAData  [0] = (pColours[*pPixels] >> 24) & 0xFF;
        }
    }
}

SDL_Texture* THSpriteSheet::_makeAltBitmap(sprite_t *pSprite)
{
    int iPixelCount = pSprite->iHeight * pSprite->iWidth;
    unsigned char *pData = new unsigned char[iPixelCount];
    for(int i = 0; i < iPixelCount; ++i)
    {
        unsigned char iPixel = pSprite->pData[i];
        if(iPixel != 0xFF && pSprite->pAltPaletteMap)
            iPixel = pSprite->pAltPaletteMap[iPixel];
        pData[i] = iPixel;
    }
    pSprite->pAltTexture = m_pTarget->createPalettizedTexture(pSprite->iWidth, pSprite->iHeight,
                                                              pData, m_pPalette);
    delete[] pData;
    return pSprite->pAltTexture;
}

bool THSpriteSheet::hitTestSprite(unsigned int iSprite, int iX, int iY, unsigned long iFlags) const
{
    if(iX < 0 || iY < 0 || iSprite >= m_iSpriteCount)
        return false;
    int iWidth = m_pSprites[iSprite].iWidth;
    int iHeight = m_pSprites[iSprite].iHeight;
    if(iX >= iWidth || iY >= iHeight)
        return false;
    if(iFlags & THDF_FlipHorizontal)
        iX = iWidth - iX - 1;
    if(iFlags & THDF_FlipVertical)
        iY = iHeight - iY - 1;
    return (m_pPalette->getARGBData()
            [m_pSprites[iSprite].pData[iY * iWidth + iX]] >> 24) != 0;
}

THCursor::THCursor()
{
    m_pBitmap = NULL;
    m_iHotspotX = 0;
    m_iHotspotY = 0;
    m_pCursorHidden = NULL;
}

THCursor::~THCursor()
{
    SDL_FreeSurface(m_pBitmap);
    SDL_FreeCursor(m_pCursorHidden);
}

bool THCursor::createFromSprite(THSpriteSheet* pSheet, unsigned int iSprite,
                                int iHotspotX, int iHotspotY)
{
#if 0
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
#else
    return false;
#endif
}

void THCursor::use(THRenderTarget* pTarget)
{
#if 0
    //SDL_ShowCursor(0) is buggy in fullscreen until 1.3 (they say)
    //  use transparent cursor for same effect
    uint8_t uData = 0;
    m_pCursorHidden = SDL_CreateCursor(&uData, &uData, 8, 1, 0, 0);
    SDL_SetCursor(m_pCursorHidden);
    pTarget->setCursor(this);
#endif
}

bool THCursor::setPosition(THRenderTarget* pTarget, int iX, int iY)
{
#if 0
    pTarget->setCursorPosition(iX, iY);
    return true;
#else
    return false;
#endif
}

void THCursor::draw(THRenderTarget* pCanvas, int iX, int iY)
{
#if 0
    SDL_Rect rcDest;
    rcDest.x = (Sint16)(iX - m_iHotspotX);
    rcDest.y = (Sint16)(iY - m_iHotspotY);
    SDL_BlitSurface(m_pBitmap, NULL, pCanvas->getRawSurface(), &rcDest);
#endif
}

THLine::THLine()
{
    initialize();
}

THLine::~THLine()
{
    THLineOperation* op = m_pFirstOp;
    while (op) {
        THLineOperation* next = (THLineOperation*)(op->m_pNext);
        delete(op);
        op = next;
    }
}

void THLine::initialize()
{
    m_fWidth = 1;
    m_iR = 0;
    m_iG = 0;
    m_iB = 0;
    m_iA = 255;

    // We start at 0,0
    m_pFirstOp = new THLineOperation(THLOP_MOVE, 0, 0);
    m_pCurrentOp = m_pFirstOp;
}

void THLine::moveTo(double fX, double fY)
{
    THLineOperation* previous = m_pCurrentOp;
    m_pCurrentOp = new THLineOperation(THLOP_MOVE, fX, fY);
    previous->m_pNext = m_pCurrentOp;
}

void THLine::lineTo(double fX, double fY)
{
    THLineOperation* previous = m_pCurrentOp;
    m_pCurrentOp = new THLineOperation(THLOP_LINE, fX, fY);
    previous->m_pNext = m_pCurrentOp;
}

void THLine::setWidth(double pLineWidth)
{
    m_fWidth = pLineWidth;
}

void THLine::setColour(uint8_t iR, uint8_t iG, uint8_t iB, uint8_t iA)
{
    m_iR = iR;
    m_iG = iG;
    m_iB = iB;
    m_iA = iA;
}

void THLine::draw(THRenderTarget* pCanvas, int iX, int iY)
{
    pCanvas->drawLine(this, iX, iY);
}

void THLine::persist(LuaPersistWriter *pWriter) const
{
    pWriter->writeVUInt((uint32_t)m_iR);
    pWriter->writeVUInt((uint32_t)m_iG);
    pWriter->writeVUInt((uint32_t)m_iB);
    pWriter->writeVUInt((uint32_t)m_iA);
    pWriter->writeVFloat(m_fWidth);

    THLineOperation* op = (THLineOperation*)(m_pFirstOp->m_pNext);
    uint32_t numOps = 0;
    for (; op; numOps++) {
        op = (THLineOperation*)(op->m_pNext);
    }

    pWriter->writeVUInt(numOps);

    op = (THLineOperation*)(m_pFirstOp->m_pNext);
    while (op) {
        pWriter->writeVUInt((uint32_t)op->type);
        pWriter->writeVFloat<double>(op->m_fX);
        pWriter->writeVFloat(op->m_fY);

        op = (THLineOperation*)(op->m_pNext);
    }
}

void THLine::depersist(LuaPersistReader *pReader)
{
    initialize();

    pReader->readVUInt(m_iR);
    pReader->readVUInt(m_iG);
    pReader->readVUInt(m_iB);
    pReader->readVUInt(m_iA);
    pReader->readVFloat(m_fWidth);

    uint32_t numOps = 0;
    pReader->readVUInt(numOps);
    for (uint32_t i = 0; i < numOps; i++) {
        THLineOpType type;
        double fX, fY;
        pReader->readVUInt((uint32_t&)type);
        pReader->readVFloat(fX);
        pReader->readVFloat(fY);

        if (type == THLOP_MOVE) {
            moveTo(fX, fY);
        } else if (type == THLOP_LINE) {
            lineTo(fX, fY);
        }
    }
}

#ifdef CORSIX_TH_USE_FREETYPE2
bool THFreeTypeFont::_isMonochrome() const
{
    return true;
}

void THFreeTypeFont::_setNullTexture(cached_text_t* pCacheEntry) const
{
    pCacheEntry->pTexture = NULL;
}

void THFreeTypeFont::_freeTexture(cached_text_t* pCacheEntry) const
{
    if(pCacheEntry->pTexture != NULL)
    {
        SDL_DestroyTexture(reinterpret_cast<SDL_Texture*>(pCacheEntry->pTexture));
    }
}


void THFreeTypeFont::_makeTexture(THRenderTarget *pEventualCanvas, cached_text_t* pCacheEntry) const
{
    uint32_t* pPixels = new uint32_t[pCacheEntry->iWidth * pCacheEntry->iHeight];
    memset(pPixels, 0, pCacheEntry->iWidth * pCacheEntry->iHeight * sizeof(uint32_t));
    unsigned char* pInRow = pCacheEntry->pData;
    uint32_t* pOutRow = pPixels;
    uint32_t iColBase = m_oColour & 0xFFFFFF;
    for(int iY = 0; iY < pCacheEntry->iHeight; ++iY, pOutRow += pCacheEntry->iWidth,
        pInRow += pCacheEntry->iWidth)
    {
        for(int iX = 0; iX < pCacheEntry->iWidth; ++iX)
        {
            pOutRow[iX] = (static_cast<uint32_t>(pInRow[iX]) << 24) | iColBase;
        }
    }

    pCacheEntry->pTexture = pEventualCanvas->createTexture(pCacheEntry->iWidth, pCacheEntry->iHeight, pPixels);
    delete[] pPixels;
}

void THFreeTypeFont::_drawTexture(THRenderTarget* pCanvas, cached_text_t* pCacheEntry, int iX, int iY) const
{
    if(pCacheEntry->iTexture == 0)
        return;

    SDL_Rect rcDest = {
        .x = iX,
        .y = iY,
        .w = pCacheEntry->iWidth,
        .h = pCacheEntry->iHeight,
    };
    pCanvas->draw(reinterpret_cast<SDL_Texture*>(pCacheEntry->pTexture), NULL, &rcDest, 0);
}

#endif // CORSIX_TH_USE_FREETYPE2