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

FullColourRenderer::FullColourRenderer(int iWidth, int iHeight) : m_iWidth(iWidth), m_iHeight(iHeight)
{
    m_iX = 0;
    m_iY = 0;
}

FullColourRenderer::~FullColourRenderer()
{
}

bool FullColourRenderer::decodeImage(const unsigned char* pImg, const THPalette *pPalette)
{
    if (m_iWidth <= 0 || m_iHeight <= 0)
        return false;

    const uint32_t* pColours = pPalette->getARGBData();
    for (;;) {
        unsigned char iType = *pImg++;
        int iLength = iType & 63;
        switch (iType >> 6)
        {
            case 0: // Fixed fully opaque 32bpp pixels
                while (iLength > 0)
                {
                    uint32_t iColour = THPalette::packARGB(0xFF, pImg[0], pImg[1], pImg[2]);
                    _pushPixel(iColour);
                    pImg += 3;
                    iLength--;
                }
                break;

            case 1: // Fixed partially transparent 32bpp pixels
            {
                unsigned char iOpacity = *pImg++;
                while (iLength > 0)
                {
                    uint32_t iColour = THPalette::packARGB(iOpacity, pImg[0], pImg[1], pImg[2]);
                    _pushPixel(iColour);
                    pImg += 3;
                    iLength--;
                }
                break;
            }

            case 2: // Fixed fully transparent pixels
            {
                static const uint32_t iTransparent = THPalette::packARGB(0, 0, 0, 0);
                while (iLength > 0)
                {
                    _pushPixel(iTransparent);
                    iLength--;
                }
                break;
            }

            case 3: // Recolour layer
            {
                unsigned char iTable = *pImg++;
                pImg++; // Skip reading the opacity for now.
                if (iTable == 0xFF)
                {
                    // Legacy sprite data. Use the palette to recolour the layer.
                    // Note that the iOpacity is ignored here.
                    while (iLength > 0)
                    {
                        _pushPixel(pColours[*pImg++]);
                        iLength--;
                    }
                }
                else
                {
                    // TODO: Add proper recolour layers, where RGB comes from
                    // table 'iTable' at index *pImg (iLength times), and
                    // opacity comes from the byte after the iTable byte.
                    //
                    // For now just draw black pixels, so it won't go unnoticed.
                    while (iLength > 0)
                    {
                        uint32_t iColour = THPalette::packARGB(0xFF, 0, 0, 0);
                        _pushPixel(iColour);
                        iLength--;
                    }
                }
                break;
            }
        }

        if (m_iY >= m_iHeight)
            break;
    }
    return m_iX == 0;
}

FullColourStoring::FullColourStoring(uint32_t *pDest, int iWidth, int iHeight) : FullColourRenderer(iWidth, iHeight)
{
    m_pDest = pDest;
}

void FullColourStoring::storeARGB(uint32_t pixel)
{
    *m_pDest++ = pixel;
}

WxStoring::WxStoring(unsigned char* pRGBData, unsigned char* pAData, int iWidth, int iHeight) : FullColourRenderer(iWidth, iHeight)
{
    m_pRGBData = pRGBData;
    m_pAData = pAData;
}

void WxStoring::storeARGB(uint32_t pixel)
{
    m_pRGBData[0] = THPalette::getR(pixel);
    m_pRGBData[1] = THPalette::getG(pixel);
    m_pRGBData[2] = THPalette::getB(pixel);
    m_pRGBData += 3;

    *m_pAData++ = THPalette::getA(pixel);
}

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

    SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "linear");

    m_pWindow = SDL_CreateWindow("CorsixTH",
                                 SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
                                 pParams->iWidth, pParams->iHeight,
                                 SDL_WINDOW_OPENGL | pParams->iSDLFlags);
    if (!m_pWindow)
    {
        return false;
    }

    m_pRenderer = SDL_CreateRenderer(m_pWindow, -1, (pParams->bPresentImmediate ? 0 : SDL_RENDERER_PRESENTVSYNC));
    if (!m_pRenderer)
    {
        return false;
    }

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

const char *THRenderTarget::getRendererDetails() const
{
    SDL_RendererInfo info = {};
    SDL_GetRendererInfo(m_pRenderer, &info);
    return info.name;
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
    SDL_Rect rcDest = { iX, iY, iW, iH };

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

//! Convert legacy 8bpp sprite data to recoloured 32bpp data, using special recolour table 0xFF.
/*!
    @param pPixelData Legacy 8bpp pixels.
    @param iPixelDataLength Number of pixels in the \a pPixelData.
    @return Converted 32bpp pixel data, if succeeded else NULL is returned. Caller should free the returned memory.
 */
static unsigned char *convertLegacySprite(const unsigned char* pPixelData, size_t iPixelDataLength)
{
    // Recolour blocks are 63 pixels long.
    // XXX To reduce the size of the 32bpp data, transparent pixels can be stored more compactly.
    size_t iNumFilled = iPixelDataLength / 63;
    size_t iRemaining = iPixelDataLength - iNumFilled * 63;
    size_t iNewSize = iNumFilled * (3 + 63) + ((iRemaining > 0) ? 3 + iRemaining : 0);

    unsigned char *pData = new (std::nothrow) unsigned char[iNewSize];
    if (pData == NULL)
        return NULL;

    unsigned char *pDest = pData;
    while (iPixelDataLength > 0)
    {
        size_t iLength = (iPixelDataLength >= 63) ? 63 : iPixelDataLength;
        *pDest++ = iLength + 0xC0; // Recolour layer type of block.
        *pDest++ = 0xFF; // Use special table 0xFF (which uses the palette as table).
        *pDest++ = 0xFF; // Non-transparent.
        memcpy(pDest, pPixelData, iLength);
        pDest += iLength;
        pPixelData += iLength;
        iPixelDataLength -= iLength;
    }
    return pData;
}

SDL_Texture* THRenderTarget::createPalettizedTexture(int iWidth, int iHeight,
                                                     const unsigned char* pPixels,
                                                     const THPalette* pPalette) const
{
    uint32_t *pARGBPixels = new (std::nothrow) uint32_t[iWidth * iHeight];
    if(pARGBPixels == NULL)
        return 0;

    FullColourStoring oRenderer(pARGBPixels, iWidth, iHeight);
    bool bOk = oRenderer.decodeImage(pPixels, pPalette);
    if (!bOk)
        return 0;

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

//! Helper function to read a word from memory.
/*! @param pData Pointer to the word to read.
    @return The read word value.
 */
static unsigned int readWord(const unsigned char* pData)
{
    return *pData | (pData[1] << 8);
}

//! Helper function to read a long word from memory.
/*! @param pData Pointer to the word to read.
    @return The read word value.
 */
static unsigned int readLong(const unsigned char* pData)
{
    return readWord(pData) | (readWord(pData + 2) << 16);
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

    pPixelData = convertLegacySprite(pPixelData, iPixelDataLength);
    if (pPixelData == NULL)
        return false;

    int iHeight = static_cast<int>(iPixelDataLength) / iWidth;
    m_pTexture = pEventualCanvas->createPalettizedTexture(iWidth, iHeight, pPixelData, m_pPalette);
    if(!m_pTexture)
        return false;

    m_iWidth = iWidth;
    m_iHeight = iHeight;
    m_pTarget = pEventualCanvas;
    return true;
}

/**
 * Test whether the loaded full colour sprite loads correctly.
 * @param pData Data of the sprite.
 * @param iDataLength Length of the sprite data.
 * @param iWidth Width of the sprite.
 * @param iHeight Height of the sprite.
 * @return Whether the sprite loads correctly (at the end of the sprite, all data is used).
 */
static bool testSprite(const unsigned char* pData, size_t iDataLength, int iWidth, int iHeight)
{
    if (iWidth <= 0 || iHeight <= 0)
        return true;

    size_t iCount = iWidth * iHeight;
    while (iCount > 0)
    {
        if (iDataLength < 1)
            return false;
        iDataLength--;
        unsigned char iType = *pData++;

        int iLength = iType & 63;
        switch (iType >> 6)
        {
            case 0: // Fixed fully opaque 32bpp pixels
                if (iCount < iLength || iDataLength < iLength * 3)
                    return false;
                iCount -= iLength;
                iDataLength -= iLength * 3;
                pData += iLength * 3;
                break;

            case 1: // Fixed partially transparent 32bpp pixels
                if (iDataLength < 1)
                    return false;
                iDataLength--;
                pData++; // Opacity byte.

                if (iCount < iLength || iDataLength < iLength * 3)
                    return false;
                iCount -= iLength;
                iDataLength -= iLength * 3;
                pData += iLength * 3;
                break;

            case 2: // Fixed fully transparent pixels
                if (iCount < iLength)
                    return false;
                iCount -= iLength;
                break;

            case 3: // Recolour layer
                if (iDataLength < 2)
                    return false;
                iDataLength -= 2;
                pData += 2; // Table number, opacity byte.

                if (iCount < iLength || iDataLength < iLength)
                    return false;
                iCount -= iLength;
                iDataLength -= iLength;
                pData += iLength;
                break;
        }
    }
    return iDataLength == 0;
}


bool THRawBitmap::loadFullColour(const unsigned char* pData, size_t iLength,
                                 THRenderTarget *pEventualCanvas)
{
    if(pEventualCanvas == NULL)
        return false;

    static const unsigned char header[] = {'C', 'T', 'H', 'G', 2, 0};

    if(iLength < 6 || memcmp(header, pData, 6) != 0)
        return false;
    pData += 6; iLength -= 6;

    if (iLength < 4+2+2+2) // Length of a sprite header.
        return false;

    uint32_t iSprLength = readLong(pData);
    pData += 4; iLength -= 4;
    if (iSprLength < 2+2+2 || iSprLength > iLength)
        return false;

    unsigned int iSprite = readWord(pData);
    int iWidth = readWord(pData + 2);
    int iHeight = readWord(pData + 4);
    pData += 6; iLength -= 6;
    iSprLength -= 6;

    if (iSprite > 0)
        return false; // Only load sprite 0.

    if (!testSprite(pData, iSprLength, iWidth, iHeight))
        return false;

    m_pTexture = pEventualCanvas->createPalettizedTexture(iWidth, iHeight, pData, m_pPalette);
    if(!m_pTexture)
        return false;

    m_iWidth = iWidth;
    m_iHeight = iHeight;
    m_pTarget = pEventualCanvas;
    return true;
}

void THRawBitmap::draw(THRenderTarget* pCanvas, int iX, int iY)
{
    if(m_pTexture == NULL)
        return;

    const SDL_Rect rcDest = { iX, iY, m_iWidth, m_iHeight };

    pCanvas->draw(m_pTexture, NULL, &rcDest, 0);
}

void THRawBitmap::draw(THRenderTarget* pCanvas, int iX, int iY,
                       int iSrcX, int iSrcY, int iWidth, int iHeight)
{
    if (m_pTexture == NULL)
        return;

    const SDL_Rect rcSrc  = { iSrcX, iSrcY, iWidth, iHeight };
    const SDL_Rect rcDest = { iX,    iY,    iWidth, iHeight };

    pCanvas->draw(m_pTexture, &rcSrc, &rcDest, 0);
}

THSpriteSheet::THSpriteSheet()
{
    m_pSprites = NULL;
    m_pPalette = NULL;
    m_pTarget = NULL;
    m_iSpriteCount = 0;
}

THSpriteSheet::~THSpriteSheet()
{
    _freeSprites();
}

void THSpriteSheet::_freeSingleSprite(unsigned int iNumber)
{
    if (iNumber >= m_iSpriteCount)
        return;

    if (m_pSprites[iNumber].pTexture != NULL)
    {
        SDL_DestroyTexture(m_pSprites[iNumber].pTexture);
        m_pSprites[iNumber].pTexture = NULL;
    }
    if (m_pSprites[iNumber].pAltTexture != NULL)
    {
        SDL_DestroyTexture(m_pSprites[iNumber].pAltTexture);
        m_pSprites[iNumber].pAltTexture = NULL;
    }
    if(m_pSprites[iNumber].pData != NULL)
    {
        delete[] m_pSprites[iNumber].pData;
        m_pSprites[iNumber].pData = NULL;
    }
}

void THSpriteSheet::_freeSprites()
{
    for(unsigned int i = 0; i < m_iSpriteCount; ++i)
        _freeSingleSprite(i);

    delete[] m_pSprites;
    m_pSprites = NULL;
    m_iSpriteCount = 0;
}

void THSpriteSheet::setPalette(const THPalette* pPalette)
{
    m_pPalette = pPalette;
}

bool THSpriteSheet::loadFromTHFile(const unsigned char* pTableData, size_t iTableDataLength,
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
            pData = oRenderer.takeData();
            pSprite->pData = convertLegacySprite(pData, pSprite->iWidth * pSprite->iHeight);
            delete pData;
        }
    }
    return true;
}

bool THSpriteSheet::loadFullColour(const unsigned char* pData, size_t iLength,
                                 THRenderTarget *pEventualCanvas)
{
    static const unsigned char header[] = {'C', 'T', 'H', 'G', 2, 0};

    if(iLength < 6 || memcmp(header, pData, 6) != 0)
        return false;
    pData += 6; iLength -= 6;

    while (iLength >= 4+2+2+2) // Length of a sprite header.
    {
        uint32_t iSprLength = readLong(pData);
        pData += 4; iLength -= 4;
        if (iSprLength < 2+2+2 || iSprLength > iLength)
            return false;

        unsigned int iSprite = readWord(pData);
        int iWidth = readWord(pData + 2);
        int iHeight = readWord(pData + 4);
        pData += 6; iLength -= 6;
        iSprLength -= 6;

        if (iSprite >= m_iSpriteCount)
            break;

        if (!testSprite(pData, iSprLength, iWidth, iHeight))
        {
            printf("Sprite number %d has a bad encoding, skipping remainder of the file", iSprite);
            return false;
        }

        _freeSingleSprite(iSprite);
        sprite_t *pSprite = m_pSprites + iSprite;
        pSprite->pData = new (std::nothrow) unsigned char[iSprLength];
        if (pSprite->pData == NULL)
            return false;

        memcpy(pSprite->pData, pData, iSprLength);
        iLength -= iSprLength;
        pData += iSprLength;

        pSprite->iWidth = iWidth;
        pSprite->iHeight = iHeight;
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
        if(pSprite->pAltTexture)
        {
            SDL_DestroyTexture(pSprite->pAltTexture);
            pSprite->pAltTexture = NULL;
        }
    }
}

unsigned int THSpriteSheet::getSpriteCount() const
{
    return m_iSpriteCount;
}

bool THSpriteSheet::getSpriteSize(unsigned int iSprite, unsigned int* pWidth, unsigned int* pHeight) const
{
    if(iSprite >= m_iSpriteCount)
        return false;
    if(pWidth != NULL)
        *pWidth = m_pSprites[iSprite].iWidth;
    if(pHeight != NULL)
        *pHeight = m_pSprites[iSprite].iHeight;
    return true;
}

void THSpriteSheet::getSpriteSizeUnchecked(unsigned int iSprite, unsigned int* pWidth, unsigned int* pHeight) const
{
    *pWidth = m_pSprites[iSprite].iWidth;
    *pHeight = m_pSprites[iSprite].iHeight;
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
        int iR = THPalette::getR(iColour);
        int iG = THPalette::getG(iColour);
        int iB = THPalette::getB(iColour);
        unsigned char cIntensity = (unsigned char)((iR + iG + iB) / 3);
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

    SDL_Rect rcSrc  = { 0,  0,  sprite.iWidth, sprite.iHeight };
    SDL_Rect rcDest = { iX, iY, sprite.iWidth, sprite.iHeight };

    pCanvas->draw(pTexture, &rcSrc, &rcDest, iFlags);
}

void THSpriteSheet::wxDrawSprite(unsigned int iSprite, unsigned char* pRGBData, unsigned char* pAData)
{
    if(iSprite >= m_iSpriteCount || pRGBData == NULL || pAData == NULL)
        return;
    sprite_t *pSprite = m_pSprites + iSprite;

    WxStoring oRenderer(pRGBData, pAData, pSprite->iWidth, pSprite->iHeight);
    oRenderer.decodeImage(pSprite->pData, m_pPalette);
}

SDL_Texture* THSpriteSheet::_makeAltBitmap(sprite_t *pSprite)
{
    if (!pSprite->pAltPaletteMap)
    {
        pSprite->pAltTexture = m_pTarget->createPalettizedTexture(pSprite->iWidth, pSprite->iHeight,
                                                                  pSprite->pData, m_pPalette);
    }
    else
    {
        const uint32_t *pPalette = m_pPalette->getARGBData();

        THPalette oPalette;
        for (int iColour = 0; iColour < 255; iColour++)
        {
            oPalette.setARGB(iColour, pPalette[pSprite->pAltPaletteMap[iColour]]);
        }
        oPalette.setARGB(255, pPalette[255]); // Colour 0xFF doesn't get remapped.

        pSprite->pAltTexture = m_pTarget->createPalettizedTexture(pSprite->iWidth, pSprite->iHeight,
                                                                  pSprite->pData, &oPalette);
    }

    return pSprite->pAltTexture;
}

bool THSpriteSheet::hitTestSprite(unsigned int iSprite, int iX, int iY, unsigned long iFlags) const
{
    if(iX < 0 || iY < 0 || iSprite >= m_iSpriteCount)
        return false;

    sprite_t &sprite = m_pSprites[iSprite];
    int iWidth = sprite.iWidth;
    int iHeight = sprite.iHeight;
    if(iX >= iWidth || iY >= iHeight)
        return false;
    if(iFlags & THDF_FlipHorizontal)
        iX = iWidth - iX - 1;
    if(iFlags & THDF_FlipVertical)
        iY = iHeight - iY - 1;
    unsigned char cPalIndex = sprite.pData[iY * iWidth + iX];

    const uint32_t* pColours = m_pPalette->getARGBData();
    return THPalette::getA(pColours[cPalIndex]) != 0;
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

    SDL_Rect rcDest = { iX, iY, pCacheEntry->iWidth, pCacheEntry->iHeight };
    pCanvas->draw(reinterpret_cast<SDL_Texture*>(pCacheEntry->pTexture), NULL, &rcDest, 0);
}

#endif // CORSIX_TH_USE_FREETYPE2
