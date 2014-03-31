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
#ifdef CORSIX_TH_USE_SDL_RENDERER
#include "th_gfx.h"
#ifdef CORSIX_TH_USE_FREETYPE2
#include "th_gfx_font.h"
#endif
#include "th_map.h"
#include "agg_rendering_buffer.h"
#include "agg_pixfmt_rgb.h"
#include "agg_pixfmt_rgba.h"
#include "agg_renderer_base.h"
#include "agg_span_interpolator_linear.h"
#include "agg_span_image_filter_rgb.h"
#include "agg_scanline_p.h"
#include "agg_renderer_scanline.h"
#include "agg_span_allocator.h"
#include "agg_rasterizer_scanline_aa.h"
#include "agg_conv_stroke.h"
#include "agg_vcgen_stroke.cpp"
#include <new>
#ifndef max
#define max(a, b) ((a) > (b) ? (a) : (b))
#endif

THRenderTarget::THRenderTarget()
{
    m_pSurface = NULL;
    m_pDummySurface = NULL;
    m_pCursor = NULL;
    m_bShouldScaleBitmaps = false;
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

    // Create another surface that's simply blue. This is used as an overlay
    // when the game is paused to create a blue filter.
    m_bBlueFilterActive = false;
    const SDL_PixelFormat& fmt = *(m_pSurface->format);
    m_pDummySurface = SDL_CreateRGBSurface(SDL_HWSURFACE, pParams->iWidth, pParams->iHeight,
        fmt.BitsPerPixel, fmt.Rmask,fmt.Gmask,fmt.Bmask,fmt.Amask );
    SDL_FillRect(m_pDummySurface, NULL, mapColour(50, 50, 200));
    SDL_SetAlpha(m_pDummySurface, SDL_SRCALPHA, 128);

    return m_pSurface != NULL;
}

bool THRenderTarget::setScaleFactor(float fScale, THScaledItems eWhatToScale)
{
    m_bShouldScaleBitmaps = false;
    if(0.999 <= fScale && fScale <= 1.001)
        return true;

    if(eWhatToScale & ~THSI_Bitmaps)
        return false;

    if(((eWhatToScale & THSI_Bitmaps) != 0) && (fScale != 1.0))
    {
        m_bShouldScaleBitmaps = true;
        m_fBitmapScaleFactor = fScale;
    }
    return true;
}

bool THRenderTarget::shouldScaleBitmaps(float* pFactor)
{
    if(!m_bShouldScaleBitmaps)
        return false;
    if(pFactor)
        *pFactor = m_fBitmapScaleFactor;
    return true;
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
    // End the frame by adding the cursor and possibly a filter.
    if(m_pCursor)
    {
        m_pCursor->draw(this, m_iCursorX, m_iCursorY);
    }
    if(m_bBlueFilterActive)
    {
        SDL_BlitSurface(m_pDummySurface, NULL, this->getRawSurface(), NULL);
    }
    return SDL_Flip(m_pSurface) == 0;
}

bool THRenderTarget::fillBlack()
{
    return SDL_FillRect(m_pSurface, NULL, mapColour(0, 0, 0)) == 0;
}

void THRenderTarget::setBlueFilterActive(bool bActivate)
{
    m_bBlueFilterActive = bActivate;
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

int THRenderTarget::getWidth() const
{
    return static_cast<int>(m_pSurface->w);
}

int THRenderTarget::getHeight() const
{
    return static_cast<int>(m_pSurface->h);
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
    m_pCachedScaledBitmap = NULL;
    m_pPalette = NULL;
    m_pData = NULL;
}

THRawBitmap::~THRawBitmap()
{
    SDL_FreeSurface(m_pBitmap);
    SDL_FreeSurface(m_pCachedScaledBitmap);
    delete[] m_pData;
}

void THRawBitmap::setPalette(const THPalette* pPalette)
{
    m_pPalette = pPalette;
}

template <class PixFmt>
class image_accessor_clip_rgb24_pal8
{
public:
    typedef PixFmt   pixfmt_type;
    typedef typename pixfmt_type::color_type color_type;
    typedef typename pixfmt_type::order_type order_type;
    typedef typename pixfmt_type::value_type value_type;
    enum pix_width_e { pix_width = pixfmt_type::pix_width };

    typedef agg::rendering_buffer palbuf_type;
    typedef THPalette pal_type;
    typedef pal_type::colour_t palcol_type;

    image_accessor_clip_rgb24_pal8() {}
    explicit image_accessor_clip_rgb24_pal8(const palbuf_type& buf,
                                            const pal_type& pal,
                                            const color_type& bk) :
        m_pixf(&buf), m_pal(&pal)
    {
        pixfmt_type::make_pix(m_bk_buf, bk);
    }

    void background_color(const color_type& bk)
    {
        pixfmt_type::make_pix(m_bk_buf, bk);
    }

private:
    AGG_INLINE const agg::int8u* pixel()
    {
        if(m_y >= 0 && m_y < (int)m_pixf->height() &&
        m_x >= 0 && m_x < (int)m_pixf->width())
        {
            palcol_type c = (*m_pal)[m_pixf->row_ptr(m_y)[m_x]];
            m_fg_buf[order_type::R] = c.r;
            m_fg_buf[order_type::G] = c.g;
            m_fg_buf[order_type::B] = c.b;
            return m_fg_buf;
        }
        return m_bk_buf;
    }

public:
    AGG_INLINE const agg::int8u* span(int x, int y, unsigned len)
    {
        m_x = m_x0 = x;
        m_y = y;
        return pixel();
    }

    AGG_INLINE const agg::int8u* next_x()
    {
        ++m_x;
        return pixel();
    }

    AGG_INLINE const agg::int8u* next_y()
    {
        ++m_y;
        m_x = m_x0;
        return pixel();
    }

private:
    const palbuf_type* m_pixf;
    const pal_type*    m_pal;
    agg::int8u         m_bk_buf[4];
    agg::int8u         m_fg_buf[4];
    int                m_x, m_x0, m_y;
};

class rasterizer_scanline_rect
{
public:
    rasterizer_scanline_rect(int x, int y, unsigned int width, unsigned int height)
    {
        m_x = x;
        m_y = y;
        m_width = width;
        m_height = height;
    }

    bool rewind_scanlines()
    {
        if(m_width > 0 && m_height > 0)
        {
            m_ycurr = m_y - 1;
            return true;
        }
        return false;
    }

    int min_x()
    {
        return m_x;
    }

    int max_x()
    {
        return m_x + m_width - 1;
    }

    template<class Scanline> bool sweep_scanline(Scanline& sl)
    {
        if(static_cast<unsigned int>(++m_ycurr) >= static_cast<unsigned int>(m_y + m_height))
            return false;
        sl.reset_spans();
        sl.add_span(m_x, m_width, agg::cover_full);
        sl.finalize(m_ycurr);
        return true;
    }

protected:
    int m_x, m_y;
    unsigned int m_width, m_height;
    int m_ycurr;
};

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

bool THRawBitmap::_checkScaled(THRenderTarget* pCanvas, SDL_Rect& rcDest)
{
    float fFactor;
    if(!pCanvas->shouldScaleBitmaps(&fFactor))
        return false;
    int iScaledWidth = (int)((float)m_pBitmap->w * fFactor);
    if(!m_pCachedScaledBitmap || m_pCachedScaledBitmap->w != iScaledWidth)
    {
        SDL_FreeSurface(m_pCachedScaledBitmap);
        Uint32 iRMask, iGMask, iBMask;
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
        iRMask = 0xff000000;
        iGMask = 0x00ff0000;
        iBMask = 0x0000ff00;
#else
        iRMask = 0x000000ff;
        iGMask = 0x0000ff00;
        iBMask = 0x00ff0000;
#endif

        m_pCachedScaledBitmap = SDL_CreateRGBSurface(SDL_SWSURFACE, iScaledWidth, (int)((float)m_pBitmap->h * fFactor), 24, iRMask, iGMask, iBMask, 0);
        SDL_LockSurface(m_pCachedScaledBitmap);
        SDL_LockSurface(m_pBitmap);

        typedef agg::pixfmt_rgb24_pre pixfmt_pre_t;
        typedef agg::renderer_base<pixfmt_pre_t> renbase_pre_t;
        typedef image_accessor_clip_rgb24_pal8<pixfmt_pre_t> imgsrc_t;
        typedef agg::span_interpolator_linear<> interpolator_t;
        typedef agg::span_image_filter_rgb_2x2<imgsrc_t, interpolator_t> span_gen_type;
        agg::scanline_p8 sl;
        agg::span_allocator<pixfmt_pre_t::color_type> sa;
        agg::image_filter<agg::image_filter_bilinear> filter;
        agg::trans_affine_scaling img_mtx(1.0 / fFactor);
        agg::rendering_buffer rbuf_src(m_pData, m_pBitmap->w, m_pBitmap->h, m_pBitmap->pitch);
        imgsrc_t img_src(rbuf_src, *m_pPalette, agg::rgba(0.0, 0.0, 0.0));
        interpolator_t interpolator(img_mtx);
        span_gen_type sg(img_src, interpolator, filter);
        agg::rendering_buffer rbuf(reinterpret_cast<unsigned char*>(m_pCachedScaledBitmap->pixels), m_pCachedScaledBitmap->w, m_pCachedScaledBitmap->h, m_pCachedScaledBitmap->pitch);
        pixfmt_pre_t pixf_pre(rbuf);
        renbase_pre_t rbase_pre(pixf_pre);
        rasterizer_scanline_rect ras(0, 0, rbuf.width(), rbuf.height());
        rbase_pre.clear(agg::rgba(1.0,0,0,0));
        agg::render_scanlines_aa(ras, sl, rbase_pre, sa, sg);

        SDL_UnlockSurface(m_pBitmap);
        SDL_UnlockSurface(m_pCachedScaledBitmap);
    }
    rcDest.x = (Sint16)((float)rcDest.x * fFactor);
    rcDest.y = (Sint16)((float)rcDest.y * fFactor);
    return true;
}

void THRawBitmap::draw(THRenderTarget* pCanvas, int iX, int iY)
{
    if(m_pBitmap == NULL)
        return;

    SDL_Rect rcDest;
    rcDest.x = iX;
    rcDest.y = iY;
    SDL_BlitSurface(_checkScaled(pCanvas, rcDest) ? m_pCachedScaledBitmap :
        m_pBitmap, NULL, pCanvas->getRawSurface(), &rcDest);
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
    SDL_BlitSurface(_checkScaled(pCanvas, rcDest) ? m_pCachedScaledBitmap :
        m_pBitmap, &rcSrc, pCanvas->getRawSurface(), &rcDest);
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
        if(cPalIndex == m_pPalette->m_iTransparentIndex)
            continue;
        // Grant higher score to pixels with high or low intensity (helps avoid grey fonts)
        THColour col = ((*m_pPalette)[cPalIndex]);
        unsigned char cIntensity = (unsigned char)(((int)col.r + (int)col.b + (int)col.g) / 3);
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
    *pColour = (*m_pPalette)[iHighestCountIndex];
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
    //SDL_ShowCursor(0) is buggy in fullscreen until 1.3 (they say)
    //  use transparent cursor for same effect
    uint8_t uData = 0;
    m_pCursorHidden = SDL_CreateCursor(&uData, &uData, 8, 1, 0, 0);
    SDL_SetCursor(m_pCursorHidden);
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

THLine::THLine()
{
    initialize();
}

void THLine::initialize()
{
    m_fWidth = 1;
    m_iR = 0;
    m_iG = 0;
    m_iB = 0;
    m_iA = 255;
    m_pBitmap = NULL;
    m_fMaxX = 0;
    m_fMaxY = 0;
    m_oPath = new agg::path_storage();
}

THLine::~THLine()
{
    SDL_FreeSurface(m_pBitmap);
    delete(m_oPath);
}

void THLine::moveTo(double fX, double fY)
{
    m_oPath->move_to(fX, fY);

    m_fMaxX = fX > m_fMaxX ? fX : m_fMaxX;
    m_fMaxY = fY > m_fMaxY ? fY : m_fMaxY;

    SDL_FreeSurface(m_pBitmap);
    m_pBitmap = NULL;
}

void THLine::lineTo(double fX, double fY)
{
    m_oPath->line_to(fX, fY);

    m_fMaxX = fX > m_fMaxX ? fX : m_fMaxX;
    m_fMaxY = fY > m_fMaxY ? fY : m_fMaxY;

    SDL_FreeSurface(m_pBitmap);
    m_pBitmap = NULL;
}

void THLine::setWidth(double pLineWidth)
{
    m_fWidth = pLineWidth;

    SDL_FreeSurface(m_pBitmap);
    m_pBitmap = NULL;
}

void THLine::setColour(uint8_t iR, uint8_t iG, uint8_t iB, uint8_t iA)
{
    m_iR = iR;
    m_iG = iG;
    m_iB = iB;
    m_iA = iA;

    SDL_FreeSurface(m_pBitmap);
    m_pBitmap = NULL;
}

void THLine::draw(THRenderTarget* pCanvas, int iX, int iY)
{
    // Strangely drawing at 0,0 would draw outside of the screen
    // so we start at 1,0. This makes SDL behave like DirectX.
    SDL_Rect rcDest;
    rcDest.x = iX + 1;
    rcDest.y = iY;

    // Try to get a cached line surface
    if (m_pBitmap) {
        SDL_BlitSurface(m_pBitmap, NULL, pCanvas->getRawSurface(), &rcDest);
        return;
    }

    // No cache, let's build a new one
    SDL_FreeSurface(m_pBitmap);

    Uint32 amask;
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
    amask = 0x000000ff;
#else
    amask = 0xff000000;
#endif

    const SDL_PixelFormat& fmt = *(pCanvas->getRawSurface()->format);
    m_pBitmap = SDL_CreateRGBSurface(SDL_HWSURFACE | SDL_SRCALPHA, (int)ceil(m_fMaxX), (int)ceil(m_fMaxY), fmt.BitsPerPixel, fmt.Rmask, fmt.Gmask, fmt.Bmask, amask);

    agg::rendering_buffer rbuf(reinterpret_cast<agg::int8u*>(m_pBitmap->pixels), m_pBitmap->w, m_pBitmap->h, m_pBitmap->pitch);
    agg::pixfmt_rgba32 pixf(rbuf);
    agg::renderer_base<agg::pixfmt_rgba32> renb(pixf);

    agg::conv_stroke<agg::path_storage> stroke(*m_oPath);
    stroke.width(m_fWidth);

    agg::rasterizer_scanline_aa<> ras;
    ras.add_path(stroke);

    agg::scanline_p8 sl;
    agg::render_scanlines_aa_solid(ras, sl, renb, agg::rgba8(m_iB, m_iG, m_iR, m_iA));

    SDL_BlitSurface(m_pBitmap, NULL, pCanvas->getRawSurface(), &rcDest);
}

void THLine::persist(LuaPersistWriter *pWriter) const
{
    pWriter->writeVUInt((uint32_t)m_iR);
    pWriter->writeVUInt((uint32_t)m_iG);
    pWriter->writeVUInt((uint32_t)m_iB);
    pWriter->writeVUInt((uint32_t)m_iA);
    pWriter->writeVFloat(m_fWidth);

    unsigned numOps = m_oPath->total_vertices();
    pWriter->writeVUInt(numOps);

    for (unsigned i = 0; i < numOps; i++) {
        unsigned command = m_oPath->command(i);

        double fX, fY;
        m_oPath->vertex(i, &fX, &fY);

        if (command == agg::path_cmd_move_to) {
            command = (unsigned)THLOP_MOVE;
        } else if (command == agg::path_cmd_line_to) {
            command = (unsigned)THLOP_LINE;
        }

        pWriter->writeVUInt(command);
        pWriter->writeVFloat(fX);
        pWriter->writeVFloat(fY);
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
        unsigned type;
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
        SDL_FreeSurface(reinterpret_cast<SDL_Surface*>(pCacheEntry->pTexture));
    }
}

void THFreeTypeFont::_makeTexture(cached_text_t* pCacheEntry) const
{
    SDL_Surface *pSurface = SDL_CreateRGBSurfaceFrom(pCacheEntry->pData,
        pCacheEntry->iWidth, pCacheEntry->iHeight, 8, pCacheEntry->iWidth, 0,
        0, 0, 0);
    SDL_SetColors(pSurface, const_cast<SDL_Color*>(&m_oColour), 0xFF, 1);
    SDL_SetColorKey(pSurface, SDL_SRCCOLORKEY | SDL_RLEACCEL, 0);
    pCacheEntry->pTexture = reinterpret_cast<void*>(pSurface);
}

void THFreeTypeFont::_drawTexture(THRenderTarget* pCanvas, cached_text_t* pCacheEntry, int iX, int iY) const
{
    SDL_Rect rcDest = {iX, iY, 0, 0};
    SDL_BlitSurface(reinterpret_cast<SDL_Surface*>(pCacheEntry->pTexture),
        NULL, pCanvas->getRawSurface(), &rcDest);
}
#endif // CORSIX_TH_USE_FREETYPE2

#endif // CORSIX_TH_USE_SDL_RENDERER
