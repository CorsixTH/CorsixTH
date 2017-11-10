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
#include <iostream>
#include <cstring>
#include <cstdio>
#include <algorithm>

FullColourRenderer::FullColourRenderer(int iWidth, int iHeight) : m_iWidth(iWidth), m_iHeight(iHeight)
{
    m_iX = 0;
    m_iY = 0;
}

//! Convert a colour to an equivalent grey scale level.
/*!
    @param iOpacity Opacity of the pixel.
    @param iR Red colour intensity.
    @param iG Green colour intensity.
    @param iB Blue colour intensity.
    @return 32bpp colour pixel in grey scale.
 */
static inline uint32_t makeGreyScale(uint8_t iOpacity, uint8_t iR, uint8_t iG, uint8_t iB)
{
    // http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
    // 0.2126*R + 0.7152*G + 0.0722*B
    // 0.2126 * 65536 = 13932.9536 -> 1393
    // 0.7152 * 65536 = 46871.3472
    // 0.0722 * 65536 =  4731.6992 -> 4732
    // 13933 + 46871 + 4732 = 65536 = 2**16
    uint8_t iGrey = static_cast<uint8_t>((13933 * iR + 46871 * iG + 4732 * iB) >> 16);
    return THPalette::packARGB(iOpacity, iGrey, iGrey, iGrey);
}

//! Convert a colour by swapping red and blue channel.
/*!
    @param iOpacity Opacity of the pixel.
    @param iR Red colour intensity.
    @param iG Green colour intensity.
    @param iB Blue colour intensity.
    @return 32bpp colour pixel with red and blue swapped.
 */
static inline uint32_t makeSwapRedBlue(uint8_t iOpacity, uint8_t iR, uint8_t iG, uint8_t iB)
{
    // http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
    // The Y factor for red is 0.2126, and for blue 0.0722. This means red is about 3 times stronger than blue.
    // Simple swapping channels will thus distort the balance. This code compensates for that by computing
    // red  = blue * 0.0722 / 0.2126 = blue * 1083 / 3189
    // blue = red  * 0.2126 / 0.0722 = red  * 1063 / 361 (clipped at max blue, 255)
    uint8_t iNewRed = static_cast<uint8_t>(iB * 1083 / 3189);
    int iNewBlue = iR * 1063 / 361;
    if (iNewBlue > 255)
        iNewBlue = 255;
    return THPalette::packARGB(iOpacity, iNewRed, iG, static_cast<uint8_t>(iNewBlue));
}

bool FullColourRenderer::decodeImage(const uint8_t* pImg, const THPalette *pPalette, uint32_t iSpriteFlags)
{
    if (m_iWidth <= 0 || m_iHeight <= 0)
        return false;

    iSpriteFlags &= THDF_Alt32_Mask;

    const uint32_t* pColours = pPalette->getARGBData();
    for (;;) {
        uint8_t iType = *pImg++;
        size_t iLength = iType & 63;
        switch (iType >> 6)
        {
            case 0: // Fixed fully opaque 32bpp pixels
                while (iLength > 0)
                {
                    uint32_t iColour;
                    if (iSpriteFlags == THDF_Alt32_BlueRedSwap)
                        iColour = makeSwapRedBlue(0xFF, pImg[0], pImg[1], pImg[2]);
                    else if (iSpriteFlags == THDF_Alt32_GreyScale)
                        iColour = makeGreyScale(0xFF, pImg[0], pImg[1], pImg[2]);
                    else
                        iColour = THPalette::packARGB(0xFF, pImg[0], pImg[1], pImg[2]);
                    _pushPixel(iColour);
                    pImg += 3;
                    iLength--;
                }
                break;

            case 1: // Fixed partially transparent 32bpp pixels
            {
                uint8_t iOpacity = *pImg++;
                while (iLength > 0)
                {
                    uint32_t iColour;
                    if (iSpriteFlags == THDF_Alt32_BlueRedSwap)
                        iColour = makeSwapRedBlue(0xFF, pImg[0], pImg[1], pImg[2]);
                    else if (iSpriteFlags == THDF_Alt32_GreyScale)
                        iColour = makeGreyScale(iOpacity, pImg[0], pImg[1], pImg[2]);
                    else
                        iColour = THPalette::packARGB(iOpacity, pImg[0], pImg[1], pImg[2]);
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
                uint8_t iTable = *pImg++;
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

WxStoring::WxStoring(uint8_t* pRGBData, uint8_t* pAData, int iWidth, int iHeight) : FullColourRenderer(iWidth, iHeight)
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
    m_pWindow = nullptr;
    m_pRenderer = nullptr;
    m_pFormat = nullptr;
    m_pCursor = nullptr;
    m_pZoomTexture = nullptr;
    m_bShouldScaleBitmaps = false;
    m_bBlueFilterActive = false;
    m_bApplyOpenGlClipFix = false;
    m_iWidth = -1;
    m_iHeight = -1;
}

THRenderTarget::~THRenderTarget()
{
    destroy();
}

bool THRenderTarget::create(const THRenderTargetCreationParams* pParams)
{
    if (m_pRenderer != nullptr)
        return false;

    SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "linear");
    m_pFormat = SDL_AllocFormat(SDL_PIXELFORMAT_ABGR8888);
    m_pWindow = SDL_CreateWindow("CorsixTH",
                                 SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
                                 pParams->iWidth, pParams->iHeight,
                                 SDL_WINDOW_OPENGL|SDL_WINDOW_RESIZABLE);
    if (!m_pWindow)
    {
        return false;
    }

    Uint32 iRendererFlags = (pParams->bPresentImmediate ? 0 : SDL_RENDERER_PRESENTVSYNC);
    m_pRenderer = SDL_CreateRenderer(m_pWindow, -1, iRendererFlags);

    SDL_RendererInfo info;
    SDL_GetRendererInfo(m_pRenderer, &info);
    m_bSupportsTargetTextures = (info.flags & SDL_RENDERER_TARGETTEXTURE) != 0;

    SDL_version sdlVersion;
    SDL_GetVersion(&sdlVersion);
    m_bApplyOpenGlClipFix = std::strncmp(info.name, "opengl", 6) == 0 && sdlVersion.major == 2 && sdlVersion.minor == 0 && sdlVersion.patch < 4;

    return update(pParams);
}

bool THRenderTarget::update(const THRenderTargetCreationParams* pParams)
{
    if (m_pWindow == nullptr)
    {
        return false;
    }

    bool bUpdateSize = (m_iWidth != pParams->iWidth) || (m_iHeight != pParams->iHeight);
    m_iWidth = pParams->iWidth;
    m_iHeight = pParams->iHeight;

    bool bIsFullscreen = ((SDL_GetWindowFlags(m_pWindow) & SDL_WINDOW_FULLSCREEN_DESKTOP) == SDL_WINDOW_FULLSCREEN_DESKTOP);
    if (bIsFullscreen != pParams->bFullscreen)
    {
        SDL_SetWindowFullscreen(m_pWindow, (pParams->bFullscreen ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0));
    }

    if (bUpdateSize || bIsFullscreen != pParams->bFullscreen)
    {
        SDL_SetWindowSize(m_pWindow, m_iWidth, m_iHeight);
    }

    if (bUpdateSize)
    {
        SDL_RenderSetLogicalSize(m_pRenderer, m_iWidth, m_iHeight);
    }

    return true;
}

void THRenderTarget::destroy()
{
    if (m_pFormat)
    {
        SDL_FreeFormat(m_pFormat);
        m_pFormat = nullptr;
    }

    if (m_pZoomTexture)
    {
        SDL_DestroyTexture(m_pZoomTexture);
        m_pZoomTexture = nullptr;
    }

    if (m_pRenderer)
    {
        SDL_DestroyRenderer(m_pRenderer);
        m_pRenderer = nullptr;
    }

    if (m_pWindow)
    {
        SDL_DestroyWindow(m_pWindow);
        m_pWindow = nullptr;
    }
}

bool THRenderTarget::setScaleFactor(double fScale, THScaledItems eWhatToScale)
{
    _flushZoomBuffer();
    m_bShouldScaleBitmaps = false;

    if(fScale <= 0.000)
    {
        return false;
    }
    else if(eWhatToScale == THSI_All && m_bSupportsTargetTextures)
    {
        //Draw everything from now until the next scale to m_pZoomTexture
        //with the appropriate virtual size, which will be copied scaled to
        //fit the window.
        int virtWidth = static_cast<int>(m_iWidth / fScale);
        int virtHeight = static_cast<int>(m_iHeight / fScale);

        m_pZoomTexture = SDL_CreateTexture(m_pRenderer,
                                           SDL_PIXELFORMAT_ABGR8888,
                                           SDL_TEXTUREACCESS_TARGET,
                                           virtWidth,
                                           virtHeight
                                          );

        SDL_RenderSetLogicalSize(m_pRenderer, virtWidth, virtHeight);
        if(SDL_SetRenderTarget(m_pRenderer, m_pZoomTexture) != 0)
        {
            std::cout << "Warning: Could not render to zoom texture - " << SDL_GetError() << std::endl;

            SDL_RenderSetLogicalSize(m_pRenderer, m_iWidth, m_iHeight);
            SDL_DestroyTexture(m_pZoomTexture);
            m_pZoomTexture = nullptr;
            return false;
        }

        // Clear the new texture to transparent/black.
        SDL_SetRenderDrawColor(m_pRenderer, 0, 0, 0, SDL_ALPHA_TRANSPARENT);
        SDL_RenderClear(m_pRenderer);

        return true;
    }
    else if(0.999 <= fScale && fScale <= 1.001)
    {
        return true;
    }
    else if(eWhatToScale == THSI_Bitmaps)
    {
        m_bShouldScaleBitmaps = true;
        m_fBitmapScaleFactor = fScale;

        return true;
    }
    else
    {
        return false;
    }
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
    _flushZoomBuffer();

    // End the frame by adding the cursor and possibly a filter.
    if(m_pCursor)
    {
        m_pCursor->draw(this, m_iCursorX, m_iCursorY);
    }
    if(m_bBlueFilterActive)
    {
        SDL_SetRenderDrawBlendMode(m_pRenderer, SDL_BLENDMODE_BLEND);
        SDL_SetRenderDrawColor(m_pRenderer, 51, 51, 255, 128); // r=0.2, g=0.2, b=1, a=0.5 .
        SDL_RenderFillRect(m_pRenderer, nullptr);
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

// Actiate and Deactivate SDL function to capture mouse to window
void THRenderTarget::setWindowGrab(bool bActivate)
{
    SDL_SetWindowGrab(m_pWindow, bActivate ? SDL_TRUE : SDL_FALSE);
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
    // SDL returns empty rect when clipping is disabled -> return full rect for CTH
    if (SDL_RectEmpty(pRect))
    {
        pRect->x = pRect->y = 0;
        pRect->w = m_iWidth;
        pRect->h = m_iHeight;
    }

    if(m_bApplyOpenGlClipFix)
    {
        int renderWidth, renderHeight;
        SDL_RenderGetLogicalSize(m_pRenderer, &renderWidth, &renderHeight);
        pRect->y = renderHeight - pRect->y - pRect->h;
    }
}

void THRenderTarget::setClipRect(const THClipRect* pRect)
{
    // Full clip rect for CTH means clipping disabled
    if (pRect == nullptr || (pRect->w == m_iWidth && pRect->h == m_iHeight))
    {
        SDL_RenderSetClipRect(m_pRenderer, nullptr);
        return;
    }

    SDL_Rect SDLRect = {
        pRect->x,
        pRect->y,
        pRect->w,
        pRect->h
    };

    // For some reason, SDL treats an empty rect (h or w <= 0) as if you turned
    // off clipping, so we replace it with a rect that's outside our viewport.
    const SDL_Rect rcBogus = { -2, -2, 1, 1 };
    if (SDL_RectEmpty(&SDLRect))
    {
        SDLRect = rcBogus;
    }

    if(m_bApplyOpenGlClipFix)
    {
        int renderWidth, renderHeight;
        SDL_RenderGetLogicalSize(m_pRenderer, &renderWidth, &renderHeight);
        SDLRect.y = renderHeight - SDLRect.y - SDLRect.h;
    }

    SDL_RenderSetClipRect(m_pRenderer, &SDLRect);
}

int THRenderTarget::getWidth() const
{
    int w;
    SDL_RenderGetLogicalSize(m_pRenderer, &w, nullptr);
    return w;
}

int THRenderTarget::getHeight() const
{
    int h;
    SDL_RenderGetLogicalSize(m_pRenderer, nullptr, &h);
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
    int width = 0, height = 0;
    if (SDL_GetRendererOutputSize(m_pRenderer, &width, &height) == -1)
        return false;

    // Create a window-sized surface, RGB format (0 Rmask means RGB.)
    SDL_Surface* pRgbSurface = SDL_CreateRGBSurface(0, width, height, 24, 0, 0, 0, 0);
    if (pRgbSurface == nullptr)
        return false;

    int readStatus = -1;
    if (SDL_LockSurface(pRgbSurface) != -1)
    {
        // Ask the renderer to (slowly) fill the surface with renderer
        // output data.
        readStatus = SDL_RenderReadPixels(m_pRenderer,
                                          nullptr,
                                          pRgbSurface->format->format,
                                          pRgbSurface->pixels,
                                          pRgbSurface->pitch);
        SDL_UnlockSurface(pRgbSurface);

        if (readStatus != -1)
            SDL_SaveBMP(pRgbSurface, sFile);
    }

    SDL_FreeSurface(pRgbSurface);

    return (readStatus != -1);
}


bool THRenderTarget::shouldScaleBitmaps(double* pFactor)
{
    if(!m_bShouldScaleBitmaps)
        return false;
    if(pFactor)
        *pFactor = m_fBitmapScaleFactor;
    return true;
}

void THRenderTarget::_flushZoomBuffer()
{
    if(m_pZoomTexture == nullptr) { return; }

    SDL_SetRenderTarget(m_pRenderer, nullptr);
    SDL_RenderSetLogicalSize(m_pRenderer, m_iWidth, m_iHeight);
    SDL_SetTextureBlendMode(m_pZoomTexture, SDL_BLENDMODE_BLEND);
    SDL_RenderCopy(m_pRenderer, m_pZoomTexture, nullptr, nullptr);
    SDL_DestroyTexture(m_pZoomTexture);
    m_pZoomTexture = nullptr;
}

//! Convert legacy 8bpp sprite data to recoloured 32bpp data, using special recolour table 0xFF.
/*!
    @param pPixelData Legacy 8bpp pixels.
    @param iPixelDataLength Number of pixels in the \a pPixelData.
    @return Converted 32bpp pixel data, if succeeded else nullptr is returned. Caller should free the returned memory.
 */
static uint8_t *convertLegacySprite(const uint8_t* pPixelData, size_t iPixelDataLength)
{
    // Recolour blocks are 63 pixels long.
    // XXX To reduce the size of the 32bpp data, transparent pixels can be stored more compactly.
    size_t iNumFilled = iPixelDataLength / 63;
    size_t iRemaining = iPixelDataLength - iNumFilled * 63;
    size_t iNewSize = iNumFilled * (3 + 63) + ((iRemaining > 0) ? 3 + iRemaining : 0);

    uint8_t *pData = new (std::nothrow) uint8_t[iNewSize];
    if (pData == nullptr)
        return nullptr;

    uint8_t *pDest = pData;
    while (iPixelDataLength > 0)
    {
        size_t iLength = (iPixelDataLength >= 63) ? 63 : iPixelDataLength;
        *pDest++ = static_cast<uint8_t>(iLength + 0xC0); // Recolour layer type of block.
        *pDest++ = 0xFF; // Use special table 0xFF (which uses the palette as table).
        *pDest++ = 0xFF; // Non-transparent.
        std::memcpy(pDest, pPixelData, iLength);
        pDest += iLength;
        pPixelData += iLength;
        iPixelDataLength -= iLength;
    }
    return pData;
}

SDL_Texture* THRenderTarget::createPalettizedTexture(
            int iWidth, int iHeight, const uint8_t* pPixels,
            const THPalette* pPalette, uint32_t iSpriteFlags) const
{
    uint32_t *pARGBPixels = new (std::nothrow) uint32_t[iWidth * iHeight];
    if(pARGBPixels == nullptr)
        return 0;

    FullColourStoring oRenderer(pARGBPixels, iWidth, iHeight);
    bool bOk = oRenderer.decodeImage(pPixels, pPalette, iSpriteFlags);
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
    SDL_UpdateTexture(pTexture, nullptr, pPixels, static_cast<int>(sizeof(*pPixels) * iWidth));
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
        SDL_RenderCopyEx(m_pRenderer, pTexture, prcSrcRect, prcDstRect, 0, nullptr, (SDL_RendererFlip)iSDLFlip);
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
            SDL_RenderDrawLine(m_pRenderer, static_cast<int>(lastX + iX),
                                            static_cast<int>(lastY + iY),
                                            static_cast<int>(op->m_fX + iX),
                                            static_cast<int>(op->m_fY + iY));
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

static const uint8_t gs_iTHColourLUT[0x40] = {
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

bool THPalette::loadFromTHFile(const uint8_t* pData, size_t iDataLength)
{
    if(iDataLength != 256 * 3)
        return false;

    m_iNumColours = static_cast<int>(iDataLength / 3);
    for(int i = 0; i < m_iNumColours; ++i, pData += 3)
    {
        uint8_t iR = gs_iTHColourLUT[pData[0] & 0x3F];
        uint8_t iG = gs_iTHColourLUT[pData[1] & 0x3F];
        uint8_t iB = gs_iTHColourLUT[pData[2] & 0x3F];
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
    m_pTexture = nullptr;
    m_pPalette = nullptr;
    m_pTarget = nullptr;
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

bool THRawBitmap::loadFromTHFile(const uint8_t* pPixelData,
                                 size_t iPixelDataLength, int iWidth,
                                 THRenderTarget *pEventualCanvas)
{
    if(pEventualCanvas == nullptr)
        return false;

    pPixelData = convertLegacySprite(pPixelData, iPixelDataLength);
    if (pPixelData == nullptr)
        return false;

    int iHeight = static_cast<int>(iPixelDataLength) / iWidth;
    m_pTexture = pEventualCanvas->createPalettizedTexture(iWidth, iHeight, pPixelData, m_pPalette, THDF_Alt32_Plain);
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
static bool testSprite(const uint8_t* pData, size_t iDataLength, int iWidth, int iHeight)
{
    if (iWidth <= 0 || iHeight <= 0)
        return true;

    size_t iCount = iWidth * iHeight;
    while (iCount > 0)
    {
        if (iDataLength < 1)
            return false;
        iDataLength--;
        uint8_t iType = *pData++;

        size_t iLength = iType & 63;
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

void THRawBitmap::draw(THRenderTarget* pCanvas, int iX, int iY)
{
    draw(pCanvas, iX, iY, 0, 0, m_iWidth, m_iHeight);
}

void THRawBitmap::draw(THRenderTarget* pCanvas, int iX, int iY,
                       int iSrcX, int iSrcY, int iWidth, int iHeight)
{
    double fScaleFactor;
    if (m_pTexture == nullptr)
        return;

    if(!pCanvas->shouldScaleBitmaps(&fScaleFactor))
    {
        fScaleFactor = 1;
    }

    const SDL_Rect rcSrc  = { iSrcX, iSrcY, iWidth, iHeight };
    const SDL_Rect rcDest = { iX,
                              iY,
                              static_cast<int>(iWidth  * fScaleFactor),
                              static_cast<int>(iHeight * fScaleFactor) };

    pCanvas->draw(m_pTexture, &rcSrc, &rcDest, 0);
}

THSpriteSheet::THSpriteSheet()
{
    m_pSprites = nullptr;
    m_pPalette = nullptr;
    m_pTarget = nullptr;
    m_iSpriteCount = 0;
}

THSpriteSheet::~THSpriteSheet()
{
    _freeSprites();
}

void THSpriteSheet::_freeSingleSprite(size_t iNumber)
{
    if (iNumber >= m_iSpriteCount)
        return;

    if (m_pSprites[iNumber].pTexture != nullptr)
    {
        SDL_DestroyTexture(m_pSprites[iNumber].pTexture);
        m_pSprites[iNumber].pTexture = nullptr;
    }
    if (m_pSprites[iNumber].pAltTexture != nullptr)
    {
        SDL_DestroyTexture(m_pSprites[iNumber].pAltTexture);
        m_pSprites[iNumber].pAltTexture = nullptr;
    }
    if(m_pSprites[iNumber].pData != nullptr)
    {
        delete[] m_pSprites[iNumber].pData;
        m_pSprites[iNumber].pData = nullptr;
    }
}

void THSpriteSheet::_freeSprites()
{
    for(size_t i = 0; i < m_iSpriteCount; ++i)
        _freeSingleSprite(i);

    delete[] m_pSprites;
    m_pSprites = nullptr;
    m_iSpriteCount = 0;
}

void THSpriteSheet::setPalette(const THPalette* pPalette)
{
    m_pPalette = pPalette;
}

bool THSpriteSheet::setSpriteCount(size_t iCount, THRenderTarget* pCanvas)
{
    _freeSprites();

    if(pCanvas == nullptr)
        return false;
    m_pTarget = pCanvas;

    m_iSpriteCount = iCount;
    m_pSprites = new (std::nothrow) sprite_t[m_iSpriteCount];
    if(m_pSprites == nullptr)
    {
        m_iSpriteCount = 0;
        return false;
    }

    for (size_t i = 0; i < m_iSpriteCount; i++)
    {
        sprite_t &spr = m_pSprites[i];
        spr.pTexture = nullptr;
        spr.pAltTexture = nullptr;
        spr.pData = nullptr;
        spr.pAltPaletteMap = nullptr;
        spr.iSpriteFlags = THDF_Alt32_Plain;
        spr.iWidth = 0;
        spr.iHeight = 0;
    }

    return true;
}

bool THSpriteSheet::loadFromTHFile(const uint8_t* pTableData, size_t iTableDataLength,
                                   const uint8_t* pChunkData, size_t iChunkDataLength,
                                   bool bComplexChunks, THRenderTarget* pCanvas)
{
    _freeSprites();
    if(pCanvas == nullptr)
        return false;

    size_t iCount = iTableDataLength / sizeof(th_sprite_t);
    if (!setSpriteCount(iCount, pCanvas))
        return false;

    for(size_t i = 0; i < m_iSpriteCount; ++i)
    {
        sprite_t *pSprite = m_pSprites + i;
        const th_sprite_t *pTHSprite = reinterpret_cast<const th_sprite_t*>(pTableData) + i;

        pSprite->pTexture = nullptr;
        pSprite->pAltTexture = nullptr;
        pSprite->pData = nullptr;
        pSprite->pAltPaletteMap = nullptr;
        pSprite->iWidth = pTHSprite->width;
        pSprite->iHeight = pTHSprite->height;

        if(pSprite->iWidth == 0 || pSprite->iHeight == 0)
            continue;

        {
            uint8_t *pData = new uint8_t[pSprite->iWidth * pSprite->iHeight];
            THChunkRenderer oRenderer(pSprite->iWidth, pSprite->iHeight, pData);
            int iDataLen = static_cast<int>(iChunkDataLength) - static_cast<int>(pTHSprite->position);
            if(iDataLen < 0)
                iDataLen = 0;
            oRenderer.decodeChunks(pChunkData + pTHSprite->position, iDataLen, bComplexChunks);
            pData = oRenderer.takeData();
            pSprite->pData = convertLegacySprite(pData, pSprite->iWidth * pSprite->iHeight);
            delete[] pData;
        }
    }
    return true;
}

bool THSpriteSheet::setSpriteData(size_t iSprite, const uint8_t *pData, bool bTakeData,
                                  size_t iDataLength, int iWidth, int iHeight)
{
    if (iSprite >= m_iSpriteCount)
        return false;

    if (!testSprite(pData, iDataLength, iWidth, iHeight))
    {
        std::printf("Sprite number %zu has a bad encoding, skipping", iSprite);
        return false;
    }

    _freeSingleSprite(iSprite);
    sprite_t *pSprite = m_pSprites + iSprite;
    if (bTakeData)
    {
        pSprite->pData = pData;
    }
    else
    {
        uint8_t *pNewData = new (std::nothrow) uint8_t[iDataLength];
        if (pNewData == nullptr)
            return false;

        std::memcpy(pNewData, pData, iDataLength);
        pSprite->pData = pNewData;
    }

    pSprite->iWidth = iWidth;
    pSprite->iHeight = iHeight;
    return true;
}

void THSpriteSheet::setSpriteAltPaletteMap(size_t iSprite, const uint8_t* pMap, uint32_t iAlt32)
{
    if(iSprite >= m_iSpriteCount)
        return;

    sprite_t *pSprite = m_pSprites + iSprite;
    if(pSprite->pAltPaletteMap != pMap)
    {
        pSprite->pAltPaletteMap = pMap;
        pSprite->iSpriteFlags = iAlt32;
        if(pSprite->pAltTexture)
        {
            SDL_DestroyTexture(pSprite->pAltTexture);
            pSprite->pAltTexture = nullptr;
        }
    }
}

size_t THSpriteSheet::getSpriteCount() const
{
    return m_iSpriteCount;
}

bool THSpriteSheet::getSpriteSize(size_t iSprite, unsigned int* pWidth, unsigned int* pHeight) const
{
    if(iSprite >= m_iSpriteCount)
        return false;
    if(pWidth != nullptr)
        *pWidth = m_pSprites[iSprite].iWidth;
    if(pHeight != nullptr)
        *pHeight = m_pSprites[iSprite].iHeight;
    return true;
}

void THSpriteSheet::getSpriteSizeUnchecked(size_t iSprite, unsigned int* pWidth, unsigned int* pHeight) const
{
    *pWidth = m_pSprites[iSprite].iWidth;
    *pHeight = m_pSprites[iSprite].iHeight;
}

bool THSpriteSheet::getSpriteAverageColour(size_t iSprite, THColour* pColour) const
{
    if(iSprite >= m_iSpriteCount)
        return false;
    const sprite_t *pSprite = m_pSprites + iSprite;
    int iCountTotal = 0;
    int iUsageCounts[256] = {0};
    for(long i = 0; i < pSprite->iWidth * pSprite->iHeight; ++i)
    {
        uint8_t cPalIndex = pSprite->pData[i];
        uint32_t iColour = m_pPalette->getARGBData()[cPalIndex];
        if((iColour >> 24) == 0)
            continue;
        // Grant higher score to pixels with high or low intensity (helps avoid grey fonts)
        int iR = THPalette::getR(iColour);
        int iG = THPalette::getG(iColour);
        int iB = THPalette::getB(iColour);
        uint8_t cIntensity = static_cast<uint8_t>((iR + iG + iB) / 3);
        int iScore = 1 + std::max(0, 3 - ((255 - cIntensity) / 32)) + std::max(0, 3 - (cIntensity / 32));
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

void THSpriteSheet::drawSprite(THRenderTarget* pCanvas, size_t iSprite, int iX, int iY, uint32_t iFlags)
{
    if(iSprite >= m_iSpriteCount || pCanvas == nullptr || pCanvas != m_pTarget)
        return;
    sprite_t &sprite = m_pSprites[iSprite];

    // Find or create the texture
    SDL_Texture *pTexture = sprite.pTexture;
    if(!pTexture)
    {
        if(sprite.pData == nullptr)
            return;

        uint32_t iSprFlags = (sprite.iSpriteFlags & ~THDF_Alt32_Mask) | THDF_Alt32_Plain;
        pTexture = m_pTarget->createPalettizedTexture(sprite.iWidth, sprite.iHeight,
                                                      sprite.pData, m_pPalette, iSprFlags);
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

void THSpriteSheet::wxDrawSprite(size_t iSprite, uint8_t* pRGBData, uint8_t* pAData)
{
    if(iSprite >= m_iSpriteCount || pRGBData == nullptr || pAData == nullptr)
        return;
    sprite_t *pSprite = m_pSprites + iSprite;

    WxStoring oRenderer(pRGBData, pAData, pSprite->iWidth, pSprite->iHeight);
    oRenderer.decodeImage(pSprite->pData, m_pPalette, pSprite->iSpriteFlags);
}

SDL_Texture* THSpriteSheet::_makeAltBitmap(sprite_t *pSprite)
{
    const uint32_t *pPalette = m_pPalette->getARGBData();

    if (!pSprite->pAltPaletteMap) // Use normal palette.
    {
        uint32_t iSprFlags = (pSprite->iSpriteFlags & ~THDF_Alt32_Mask) | THDF_Alt32_Plain;
        pSprite->pAltTexture = m_pTarget->createPalettizedTexture(pSprite->iWidth, pSprite->iHeight,
                                                                  pSprite->pData, m_pPalette, iSprFlags);
    }
    else if (!pPalette) // Draw alternative palette, but no palette set (ie 32bpp image).
    {
        pSprite->pAltTexture = m_pTarget->createPalettizedTexture(pSprite->iWidth, pSprite->iHeight,
                                                                  pSprite->pData, m_pPalette, pSprite->iSpriteFlags);
    }
    else // Paletted image, build recolour palette.
    {
        THPalette oPalette;
        for (int iColour = 0; iColour < 255; iColour++)
        {
            oPalette.setARGB(iColour, pPalette[pSprite->pAltPaletteMap[iColour]]);
        }
        oPalette.setARGB(255, pPalette[255]); // Colour 0xFF doesn't get remapped.

        pSprite->pAltTexture = m_pTarget->createPalettizedTexture(pSprite->iWidth, pSprite->iHeight,
                                                                  pSprite->pData, &oPalette, pSprite->iSpriteFlags);
    }

    return pSprite->pAltTexture;
}

/**
 * Get the colour data of pixel \a iPixelNumber (\a iWidth * y + x)
 * @param pImg 32bpp image data.
 * @param iWidth Width of the image.
 * @param iHeight Height of the image.
 * @param pPalette Palette of the image, or \c nullptr.
 * @param iPixelNumber Number of the pixel to retrieve.
 */
static uint32_t get32BppPixel(const uint8_t* pImg, int iWidth, int iHeight,
                              const THPalette *pPalette, size_t iPixelNumber)
{
    if (iWidth <= 0 || iHeight <= 0 || iPixelNumber < 0 ||
        iPixelNumber >= static_cast<size_t>(iWidth) * iHeight)
    {
        return THPalette::packARGB(0, 0, 0,0);
    }

    for (;;) {
        uint8_t iType = *pImg++;
        size_t iLength = iType & 63;
        switch (iType >> 6)
        {
            case 0: // Fixed fully opaque 32bpp pixels
                if (iPixelNumber >= iLength)
                {
                    pImg += 3 * iLength;
                    iPixelNumber -= iLength;
                    break;
                }

                while (iLength > 0)
                {
                    if (iPixelNumber == 0)
                        return THPalette::packARGB(0xFF, pImg[0], pImg[1], pImg[2]);

                    iPixelNumber--;
                    pImg += 3;
                    iLength--;
                }
                break;

            case 1: // Fixed partially transparent 32bpp pixels
            {
                uint8_t iOpacity = *pImg++;
                if (iPixelNumber >= iLength)
                {
                    pImg += 3 * iLength;
                    iPixelNumber -= iLength;
                    break;
                }

                while (iLength > 0)
                {
                    if (iPixelNumber == 0)
                        return THPalette::packARGB(iOpacity, pImg[0], pImg[1], pImg[2]);

                    iPixelNumber--;
                    pImg += 3;
                    iLength--;
                }
                break;
            }

            case 2: // Fixed fully transparent pixels
            {
                if (iPixelNumber >= iLength)
                {
                    iPixelNumber -= iLength;
                    break;
                }

                return THPalette::packARGB(0, 0, 0, 0);
            }

            case 3: // Recolour layer
            {
                uint8_t iTable = *pImg++;
                pImg++; // Skip reading the opacity for now.
                if (iPixelNumber >= iLength)
                {
                    pImg += iLength;
                    iPixelNumber -= iLength;
                    break;
                }

                if (iTable == 0xFF && pPalette != nullptr)
                {
                    // Legacy sprite data. Use the palette to recolour the layer.
                    // Note that the iOpacity is ignored here.
                    const uint32_t* pColours = pPalette->getARGBData();
                    return pColours[pImg[iPixelNumber]];
                }
                else
                {
                    // TODO: Add proper recolour layers, where RGB comes from
                    // table 'iTable' at index *pImg (iLength times), and
                    // opacity comes from the byte after the iTable byte.
                    //
                    // For now just draw black pixels, so it won't go unnoticed.
                    return THPalette::packARGB(0xFF, 0, 0, 0);
                }
            }
        }
    }
}

bool THSpriteSheet::hitTestSprite(size_t iSprite, int iX, int iY, uint32_t iFlags) const
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

    uint32_t iCol = get32BppPixel(sprite.pData, iWidth, iHeight, m_pPalette, iY * iWidth + iX);
    return THPalette::getA(iCol) != 0;
}

THCursor::THCursor()
{
    m_pBitmap = nullptr;
    m_iHotspotX = 0;
    m_iHotspotY = 0;
    m_pCursorHidden = nullptr;
}

THCursor::~THCursor()
{
    SDL_FreeSurface(m_pBitmap);
    SDL_FreeCursor(m_pCursorHidden);
}

bool THCursor::createFromSprite(THSpriteSheet* pSheet, size_t iSprite,
                                int iHotspotX, int iHotspotY)
{
#if 0
    SDL_FreeSurface(m_pBitmap);
    m_pBitmap = nullptr;

    if(pSheet == nullptr || iSprite >= pSheet->getSpriteCount())
        return false;
    SDL_Surface *pSprite = pSheet->_getSpriteBitmap(iSprite, 0);
    if(pSprite == nullptr || (m_pBitmap = SDL_DisplayFormat(pSprite)) == nullptr)
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
    SDL_BlitSurface(m_pBitmap, nullptr, pCanvas->getRawSurface(), &rcDest);
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

void THFreeTypeFont::_freeTexture(cached_text_t* pCacheEntry) const
{
    if(pCacheEntry->pTexture != nullptr)
    {
        SDL_DestroyTexture(pCacheEntry->pTexture);
        pCacheEntry->pTexture = nullptr;
    }
}


void THFreeTypeFont::_makeTexture(THRenderTarget *pEventualCanvas, cached_text_t* pCacheEntry) const
{
    uint32_t* pPixels = new uint32_t[pCacheEntry->iWidth * pCacheEntry->iHeight];
    std::memset(pPixels, 0, pCacheEntry->iWidth * pCacheEntry->iHeight * sizeof(uint32_t));
    uint8_t* pInRow = pCacheEntry->pData;
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
    if(pCacheEntry->pTexture == nullptr)
        return;

    SDL_Rect rcDest = { iX, iY, pCacheEntry->iWidth, pCacheEntry->iHeight };
    pCanvas->draw(pCacheEntry->pTexture, nullptr, &rcDest, 0);
}

#endif // CORSIX_TH_USE_FREETYPE2
