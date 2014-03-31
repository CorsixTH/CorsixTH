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
#ifdef CORSIX_TH_USE_OGL_RENDERER

#include "th_gfx.h"
#include <new>
#include <math.h>
#ifdef _MSC_VER
#pragma comment(lib, "OpenGL32")
#endif
#ifndef _WIN32
struct RECT
{
    long top, bottom, left, right;
};
#ifndef max
#define max(a, b) ((a) > (b) ? (a) : (b))
#endif
#endif

THRenderTarget::THRenderTarget()
{
    m_pSurface = NULL;
    m_pVerticies = NULL;
    setClipRect(NULL);
    m_iVertexCount = 0;
    m_iVertexLength = 0;
    m_iNonOverlappingStart = 0;
    m_iNonOverlapping = 0;
    m_iWidth = 0;
    m_iHeight = 0;
#ifdef CORSIX_TH_USE_OGL_RENDER_TO_TEXTURE
    m_glGenFramebuffersEXT = NULL;
    m_glBindFramebufferEXT = NULL;
    m_glFramebufferTexture2DEXT = NULL;
    m_glDeleteFramebuffersEXT = NULL;
    m_glCheckFramebufferStatusEXT = NULL;
    m_iZoomTexture = 0;
    m_iZoomFrameBuffer = 0;
    m_iZoomTextureSize = 0;
    m_bUsingZoomBuffer = false;
#endif
    m_bShouldScaleBitmaps = false;
}

THRenderTarget::~THRenderTarget()
{
    if(m_pVerticies != NULL)
    {
        free(m_pVerticies);
        m_pVerticies = NULL;
    }
#ifdef CORSIX_TH_USE_OGL_RENDER_TO_TEXTURE
    if(m_iZoomFrameBuffer != 0)
    {
        m_glDeleteFramebuffersEXT(1, &m_iZoomFrameBuffer);
        m_iZoomFrameBuffer = 0;
    }
    if(m_iZoomTexture != 0)
    {
        glDeleteTextures(1, &m_iZoomTexture);
        m_iZoomTexture = 0;
    }
#endif
}

bool THRenderTarget::create(const THRenderTargetCreationParams* pParams)
{
    int iBPP = pParams->iBPP;
    if(!pParams->bReuseContext)
    {
        if(iBPP == 0)
            iBPP = SDL_GetVideoInfo()->vfmt->BitsPerPixel;
        switch(iBPP)
        {
        case 8:
            SDL_GL_SetAttribute(SDL_GL_RED_SIZE,   3);
            SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 3);
            SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE,  2);
            break;
        case 15:
        case 16:
            SDL_GL_SetAttribute(SDL_GL_RED_SIZE,   5);
            SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 5);
            SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE,  5);
            break;
        default:
            SDL_GL_SetAttribute(SDL_GL_RED_SIZE,   8);
            SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
            SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE,  8);
            break;
        }
        SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 0);
        SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, pParams->bDoubleBuffered   ? 1:0);
        SDL_GL_SetAttribute(SDL_GL_SWAP_CONTROL, pParams->bPresentImmediate ? 0:1);
        m_pSurface = SDL_SetVideoMode(pParams->iWidth, pParams->iHeight, iBPP,
            pParams->iSDLFlags);
        if(m_pSurface == NULL)
            return false;
    }

    m_bBlueFilterActive = false;

    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    if(!pParams->bReuseContext)
        glViewport(0, 0, pParams->iWidth, pParams->iHeight);
    m_iWidth = pParams->iWidth;
    m_iHeight = pParams->iHeight;
    GLdouble fWidth = (GLdouble)pParams->iWidth;
    GLdouble fHeight = (GLdouble)pParams->iHeight;
    setGLProjection(fWidth, fHeight);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    if(getGLError() != GL_NO_ERROR)
    {
        m_pSurface = NULL;
        return false;
    }

#ifdef CORSIX_TH_USE_OGL_RENDER_TO_TEXTURE
    bool bFoundAll = true;
    // TODO: SDL_GL_GetProcAddress doesn't work without a call to
    // SDL_SetVideoMode, which isn't done when a context is being
    // re-used.
#define FIND(name, typ) \
    m_ ## name ## EXT = NULL; \
    if(bFoundAll && !pParams->bReuseContext) \
    { \
        m_ ## name ## EXT = (typ) SDL_GL_GetProcAddress(#name "EXT"); \
        if(!m_ ## name ## EXT) \
        { \
            m_ ## name ## EXT = (typ) SDL_GL_GetProcAddress(#name "ARB"); \
            if(!m_ ## name ## EXT) \
            { \
                m_ ## name ## EXT = (typ) SDL_GL_GetProcAddress(#name); \
                if(!m_ ## name ## EXT) \
                    bFoundAll = false; \
            } \
        } \
    }
    FIND(glGenFramebuffers       , PFNGLGENFRAMEBUFFERSEXTPROC);
    FIND(glBindFramebuffer       , PFNGLBINDFRAMEBUFFEREXTPROC);
    FIND(glFramebufferTexture2D  , PFNGLFRAMEBUFFERTEXTURE2DEXTPROC);
    FIND(glDeleteFramebuffers    , PFNGLDELETEFRAMEBUFFERSEXTPROC);
    FIND(glCheckFramebufferStatus, PFNGLCHECKFRAMEBUFFERSTATUSEXTPROC);
#undef FIND
#endif

    return true;
}

void THRenderTarget::setGLProjection(GLdouble fWidth, GLdouble fHeight)
{
    // NB: The loaded matrix is the transpose of the visible matrix
    const GLdouble mtxProjection[16] = {
              2.0 / fWidth ,        0.0           , 0.0, 0.0,
              0.0          ,       -2.0 / fHeight , 0.0, 0.0,
              0.0          ,        0.0           , 1.0, 0.0,
      -1.0 - (1.0 / fWidth), 1.0 + (1.0 / fHeight), 0.0, 1.0
    };
    glMatrixMode(GL_PROJECTION);
    glLoadMatrixd(mtxProjection);
    glTranslated(0.5, 0.5, 0.0);
}

bool THRenderTarget::shouldScaleBitmaps(float* pFactor)
{
    if(!m_bShouldScaleBitmaps)
        return false;
    if(pFactor)
        *pFactor = m_fBitmapScaleFactor;
    return true;
}

bool THRenderTarget::setScaleFactor(float fScale, THScaledItems eWhatToScale)
{
    flushSprites();
    _flushZoomBuffer();
    m_bShouldScaleBitmaps = false;

    if(eWhatToScale == THSI_None || (0.999 <= fScale && fScale <= 1.001))
    {
        // Effectively back to no scaling, so nothing more to do
        return true;
    }
    if(eWhatToScale == THSI_Bitmaps)
    {
        m_bShouldScaleBitmaps = true;
        m_fBitmapScaleFactor = fScale;
        return true;
    }

#ifdef CORSIX_TH_USE_OGL_RENDER_TO_TEXTURE
    if(eWhatToScale == THSI_All && m_glCheckFramebufferStatusEXT)
    {
        if(fScale <= 0.0f)
            return false;
        float fVirtualSize = static_cast<float>(max(m_iWidth, m_iHeight)) / fScale;
        unsigned int iZoomTextureSize = 1 << static_cast<unsigned int>(
            ceil(logf(fVirtualSize) / logf(2)));
        if(iZoomTextureSize == 0) // Catch integer overflow
            return false;

        // Create the render texture
        if(m_iZoomTextureSize != iZoomTextureSize)
        {
            if(m_iZoomFrameBuffer != 0)
            {
                m_glDeleteFramebuffersEXT(1, &m_iZoomFrameBuffer);
                m_iZoomFrameBuffer = 0;
            }
            if(m_iZoomTexture != 0)
            {
                glDeleteTextures(1, &m_iZoomTexture);
                m_iZoomTexture = 0;
            }

            m_iZoomTextureSize = 0;

            // Create texture
            glGenTextures(1, &m_iZoomTexture);
            if(getGLError() != GL_NO_ERROR)
                return false;
            glBindTexture(GL_TEXTURE_2D, m_iZoomTexture);
            if(getGLError() != GL_NO_ERROR)
                return false;
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            float fMaximumAnistropy;
            glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &fMaximumAnistropy);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, fMaximumAnistropy);

            glTexImage2D(GL_TEXTURE_2D, 0, 4, iZoomTextureSize, iZoomTextureSize, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
            if(getGLError() != GL_NO_ERROR)
                return false;

            // Create and check frame buffer
            m_glGenFramebuffersEXT(1, &m_iZoomFrameBuffer);
            if(getGLError() != GL_NO_ERROR)
                return false;
            m_glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, m_iZoomFrameBuffer);
            if(getGLError() != GL_NO_ERROR)
                return false;
            m_glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, m_iZoomTexture, 0);
            if(getGLError() != GL_NO_ERROR)
                return false;
            GLenum status = m_glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
            if(status != GL_FRAMEBUFFER_COMPLETE_EXT)
                return false;
            m_glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);

            m_iZoomTextureSize = iZoomTextureSize;
        }
        m_glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, m_iZoomFrameBuffer);
        glViewport(0,0,m_iZoomTextureSize, m_iZoomTextureSize);
        setGLProjection(m_iZoomTextureSize, m_iZoomTextureSize);
        m_bUsingZoomBuffer = true;
        m_fZoomScale = fScale;
        glClearColor(0.0, 0.0, 0.0, 0.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        return true;
    }
#endif
    return false;
}

void THRenderTarget::_flushZoomBuffer()
{
#ifdef CORSIX_TH_USE_OGL_RENDER_TO_TEXTURE
    if(!m_bUsingZoomBuffer)
        return;
    m_bUsingZoomBuffer = false;

    m_glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
    glViewport(0,0,m_iWidth, m_iHeight);
    setGLProjection(m_iWidth, m_iHeight);

    float fFactor = m_fZoomScale * static_cast<float>(m_iZoomTextureSize);
#define SetVertexData(n, x_, y_) \
    pVerticies[n].x = (float)x_; \
    pVerticies[n].y = (float)y_; \
    pVerticies[n].z = 0.0f; \
    pVerticies[n].colour = THPalette::packARGB(0xFF, 0xFF, 0xFF, 0xFF); \
    pVerticies[n].u = (float)x_ / fFactor; \
    pVerticies[n].v = 1.0f - (float)y_ / fFactor

    THOGL_Vertex *pVerticies = allocVerticies(4, m_iZoomTexture);
    SetVertexData(0, 0, 0);
    SetVertexData(1, m_iWidth, 0);
    SetVertexData(2, m_iWidth, m_iHeight);
    SetVertexData(3, 0, m_iHeight);
#undef SetVertexData
    flushSprites();
#endif
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
    if(!flushSprites())
        return false;
    _flushZoomBuffer();

    // Possibly add a blue filter on top of everything
    if (m_bBlueFilterActive)
    {
        // This particular quad will not have any texture on it.
        glDisable(GL_TEXTURE_2D);
        glBegin(GL_QUADS);
            glColor4f(0.0f,0.0f,1.0f, 0.3f);
            glVertex3f(0.0f, 0.0f, 0.0f);
            glVertex3f((GLfloat) (GLfloat) getWidth(), 0.0f, 0.0f);
            glVertex3f((GLfloat) getWidth(), (GLfloat) getHeight(), 0.0f);
            glVertex3f(0.0f, (GLfloat) getHeight(), 0.0f);
        glEnd();
        glEnable(GL_TEXTURE_2D);
    }

    if(m_pSurface)
        SDL_GL_SwapBuffers();
    return true;
}

bool THRenderTarget::flushSprites()
{
    if(m_iVertexCount == 0)
        return true;

    GLuint iTexture = m_pVerticies[0].tex;
    glBindTexture(GL_TEXTURE_2D, iTexture);
    if(getGLError() != GL_NO_ERROR)
        goto gl_err;
    {
        size_t iStart = 0;
        for(size_t i = 4; i < m_iVertexCount; i += 4)
        {
            if(m_pVerticies[i].tex != iTexture)
            {
                _drawVerts(iStart, i);
                if(getGLError() != GL_NO_ERROR)
                    goto gl_err;
                iStart = i;
                iTexture = m_pVerticies[i].tex;
                glBindTexture(GL_TEXTURE_2D, iTexture);
                if(getGLError() != GL_NO_ERROR)
                    goto gl_err;
            }
        }
        _drawVerts(iStart, m_iVertexCount);
    }
    if(getGLError() != GL_NO_ERROR)
        goto gl_err;

    m_iVertexCount = 0;
    return true;
gl_err:
    m_iVertexCount = 0;
    return false;
}

GLenum THRenderTarget::getGLError()
{
    GLenum eError = glGetError();
    if(eError != GL_NO_ERROR)
    {
        // Clear multiple error bits, if there are any
        while(glGetError())
            ;
    }
    return eError;
}

void THRenderTarget::_drawVerts(size_t iFirst, size_t iLast)
{
    glInterleavedArrays(GL_T2F_C4UB_V3F, sizeof(THOGL_Vertex),
        m_pVerticies + iFirst);
    glDrawArrays(GL_QUADS, 0, static_cast<GLsizei>(iLast - iFirst));
}

bool THRenderTarget::fillBlack()
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    return getGLError() == GL_NO_ERROR;
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
    draw(0, iW, iH, iX, iY, 0, 1, 1, 0, 0);
    THOGL_Vertex* pVerts = m_pVerticies + m_iVertexCount;
    for(int i = 1; i <= 4; ++i)
    {
        pVerts[-i].colour = iColour;
    }
    return true;
}

void THRenderTarget::getClipRect(THClipRect* pRect) const
{
    *pRect = m_rcClip;
}

int THRenderTarget::getWidth() const
{
    return m_iWidth;
}

int THRenderTarget::getHeight() const
{
    return m_iHeight;
}

void THRenderTarget::setClipRect(const THClipRect* pRect)
{
    if(pRect != NULL)
    {
        m_rcClip = *pRect;
    }
    else
    {
        m_rcClip.x = -1000;
        m_rcClip.y = -1000;
        m_rcClip.w = 0xFFFF;
        m_rcClip.h = 0xFFFF;
    }
}

void THRenderTarget::startNonOverlapping()
{
    if(m_iNonOverlapping++ == 0)
        m_iNonOverlappingStart = m_iVertexCount;
}

static int sprite_tex_compare(const void* left, const void* right)
{
    const THOGL_Vertex *pLeft  = reinterpret_cast<const THOGL_Vertex*>(left);
    const THOGL_Vertex *pRight = reinterpret_cast<const THOGL_Vertex*>(right);

    if(pLeft->tex == pRight->tex)
        return 0;
    else if(pLeft->tex < pRight->tex)
        return -1;
    else
        return 1;
}

void THRenderTarget::finishNonOverlapping()
{
    if(--m_iNonOverlapping > 0)
        return;

    // If more than one texture is used in the range of non-overlapping
    // sprites, then sort the entire range by texture.

    size_t iStart = m_iNonOverlappingStart;
    GLuint iTexture = m_pVerticies[iStart].tex;
    for(size_t i = iStart + 4; i < m_iVertexCount; i += 4)
    {
        if(m_pVerticies[i].tex != iTexture)
        {
            qsort(m_pVerticies + iStart, (m_iVertexCount - iStart) / 4,
                sizeof(THOGL_Vertex) * 4, sprite_tex_compare);
            break;
        }
    }
}

void THRenderTarget::setCursor(THCursor* pCursor)
{
    // TODO (low priority, as Lua will simulate a cursor)
}

void THRenderTarget::setCursorPosition(int iX, int iY)
{
    // TODO (low priority, as Lua will simulate a cursor)
}

SDL_Surface* flipSurface(SDL_Surface* pSurface)
{
    SDL_Surface *pSurfaceFlipped = SDL_CreateRGBSurface(pSurface->flags, pSurface->w, pSurface->h, pSurface->format->BitsPerPixel,
        pSurface->format->Rmask, pSurface->format->Gmask, pSurface->format->Bmask, pSurface->format->Amask);
    if (pSurfaceFlipped == NULL) return NULL;

    uint8_t* src = reinterpret_cast<uint8_t*>(pSurface->pixels);
    uint8_t* dest = reinterpret_cast<uint8_t*>(pSurfaceFlipped->pixels);

    for(int iY = 0; iY < pSurface->h; ++iY)
    {
        memcpy(dest + pSurface->pitch * iY, src + pSurface->pitch * (pSurface->h - 1 - iY), pSurface->pitch);
    }
    return pSurfaceFlipped;
}

bool THRenderTarget::takeScreenshot(const char* sFile)
{
    SDL_Surface *pSurface = SDL_CreateRGBSurface(SDL_SWSURFACE, this->m_iWidth, this->m_iHeight, 24, 0x000000FF, 0x0000FF00, 0x00FF0000, 0);
    if(pSurface == NULL)
    {
        SDL_SetError("Could not create screenshot buffer");
        return false;
    }

    // Read from buffer onto SDL surface
    glReadBuffer(GL_FRONT);
    glReadPixels(0, 0, this->m_iWidth, this->m_iHeight, GL_RGB, GL_UNSIGNED_BYTE, pSurface->pixels);

    // Flip y
    SDL_Surface *pSurfaceFlipped = flipSurface(pSurface);
    if(pSurfaceFlipped == NULL)
    {
        SDL_SetError("Could not create inverted screenshot buffer");
        return false;
    }

    // Save contents of SDL surface
    bool bResult = SDL_SaveBMP(pSurfaceFlipped, sFile) == 0;
    SDL_FreeSurface(pSurface);
    SDL_FreeSurface(pSurfaceFlipped);

    return bResult;
}

int roundUp2(int x)
{
    x--;
    x |= x >>  1;
    x |= x >>  2;
    x |= x >>  3;
    x |= x >>  4;
    x |= x >> 16;
    x++;
    return x;
}

GLuint THRenderTarget::createTexture(int iWidth, int iHeight,
                                     const unsigned char* pPixels,
                                     const THPalette* pPalette,
                                     int* pWidth2, int* pHeight2)
{
    int iWidth2 = roundUp2(iWidth);
    int iHeight2 = roundUp2(iHeight);
    if(pWidth2)
        *pWidth2 = iWidth2;
    if(pHeight2)
        *pHeight2 = iHeight2;

    uint32_t *pRGBAPixels = new (std::nothrow) uint32_t[iWidth2 * iHeight2];
    if(pRGBAPixels == NULL)
        return 0;
    const uint32_t iTransparent = THPalette::packARGB(0x00, 0x00, 0x00, 0x00);
    const uint32_t* pColours = pPalette->getARGBData();

    uint32_t *pRow = pRGBAPixels;
    for(int y = 0; y < iHeight; ++y)
    {
        for(int x = 0; x < iWidth; ++x, ++pPixels, ++pRow)
        {
            *pRow = pColours[*pPixels];
        }
        for(int x = iWidth; x < iWidth2; ++x, ++pRow)
        {
            *pRow = iTransparent;
        }
    }
    for(int y = iHeight; y < iHeight2; ++y)
    {
        for(int x = 0; x < iWidth2; ++x, ++pRow)
        {
            *pRow = iTransparent;
        }
    }

    GLuint iTextureID = createTexture(iWidth2, iHeight2, pRGBAPixels);
    delete[] pRGBAPixels;
    return iTextureID;
}

GLuint THRenderTarget::createTexture(int iWidth2, int iHeight2, const uint32_t* pPixels)
{
    GLuint iTextureID;
    glGenTextures(1, &iTextureID);
    glBindTexture(GL_TEXTURE_2D, iTextureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, iWidth2, iHeight2, 0, GL_RGBA,
        GL_UNSIGNED_BYTE, pPixels);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    if(getGLError() != GL_NO_ERROR)
    {
        glDeleteTextures(1, &iTextureID);
        return 0;
    }
    return iTextureID;
}

THOGL_Vertex* THRenderTarget::allocVerticies(size_t iCount,
                                             GLuint iTexture)
{
    if(m_iVertexCount + iCount > m_iVertexLength)
    {
        m_iVertexLength = (m_iVertexLength * 2) + iCount;
        m_pVerticies = (THOGL_Vertex*)realloc(m_pVerticies,
            sizeof(THOGL_Vertex) * m_iVertexLength);
    }
    THOGL_Vertex *pResult = m_pVerticies + m_iVertexCount;
    pResult[0].tex = iTexture;
    m_iVertexCount += iCount;
    return pResult;
}

void THRenderTarget::draw(GLuint iTexture, unsigned int iWidth,
                          unsigned int iHeight, int iX, int iY,
                          unsigned long iFlags, unsigned int iWidth2,
                          unsigned int iHeight2, unsigned int iTexX,
                          unsigned int iTexY)
{
    // Crop to clip rectangle
    RECT rcSource;
    rcSource.left = 0;
    rcSource.top = 0;
    rcSource.right = iWidth;
    rcSource.bottom = iHeight;
    if(iX + rcSource.right > m_rcClip.x + m_rcClip.w)
    {
        rcSource.right = m_rcClip.x + m_rcClip.w - iX;
    }
    if(iY + rcSource.bottom > m_rcClip.y + m_rcClip.h)
    {
        rcSource.bottom = m_rcClip.y + m_rcClip.h - iY;
    }
    if(iX + rcSource.left < m_rcClip.x)
    {
        rcSource.left = m_rcClip.x - iX;
        iX = m_rcClip.x;
    }
    if(iY + rcSource.top < m_rcClip.y)
    {
        rcSource.top = m_rcClip.y - iY;
        iY = m_rcClip.y;
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
    uint32_t cColour;
    switch(iFlags & (THDF_Alpha50 | THDF_Alpha75))
    {
    case 0:
        cColour = THPalette::packARGB(0xFF, 0xFF, 0xFF, 0xFF);
        break;
    case THDF_Alpha50:
        cColour = THPalette::packARGB(0x80, 0xFF, 0xFF, 0xFF);
        break;
    default:
        cColour = THPalette::packARGB(0x40, 0xFF, 0xFF, 0xFF);
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
    pVerticies[n].v = (float) v_

    THOGL_Vertex *pVerticies = allocVerticies(4, iTexture);
    SetVertexData(0, 0, 0, rcSource.left / fSprWidth, rcSource.top / fSprHeight);
    SetVertexData(1, fWidth, 0, rcSource.right  / fSprWidth, pVerticies[0].v);
    SetVertexData(2, fWidth, fHeight, pVerticies[1].u, rcSource.bottom / fSprHeight);
    SetVertexData(3, 0, fHeight, pVerticies[0].u, pVerticies[2].v);
#undef SetVertexData
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
    m_iTexture = 0;
    m_pPalette = NULL;
    m_pTarget = NULL;
    m_iWidth = 0;
    m_iWidth2 = 0;
    m_iHeight = 0;
    m_iHeight2 = 0;
}

THRawBitmap::~THRawBitmap()
{
    glDeleteTextures(1, &m_iTexture);
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
    if(!(m_iTexture = pEventualCanvas->createTexture(iWidth,
        static_cast<int>(iPixelDataLength)/iWidth, pPixelData, m_pPalette,
        &m_iWidth2, &m_iHeight2)))
    {
        return false;
    }
    m_iWidth = iWidth;
    m_iHeight = static_cast<int>(iPixelDataLength) / iWidth;
    m_pTarget = pEventualCanvas;

    return true;
}

void THRawBitmap::draw(THRenderTarget* pCanvas, int iX, int iY)
{
    draw(pCanvas, iX, iY, 0, 0, m_iWidth, m_iHeight);
}

void THRawBitmap::draw(THRenderTarget* pCanvas, int iX, int iY, int iSrcX,
                       int iSrcY, int iWidth, int iHeight)
{
    if(pCanvas == NULL || pCanvas != m_pTarget)
        return;

    float fScaleFactor;
    bool bShouldScale = pCanvas->shouldScaleBitmaps(&fScaleFactor);
    if(bShouldScale)
    {
        pCanvas->flushSprites();
        glMatrixMode(GL_MODELVIEW);
        glScalef(fScaleFactor, fScaleFactor, 1.0f);
    }

    pCanvas->draw(m_iTexture, iWidth, iHeight, iX, iY, 0, m_iWidth2,
        m_iHeight2, iSrcX, iSrcY);

    if(bShouldScale)
    {
        pCanvas->flushSprites();
        glLoadIdentity();
    }
}

THSpriteSheet::THSpriteSheet()
{
    m_pSprites = NULL;
    m_pPalette = NULL;
    m_pTarget = NULL;
    m_iMegaTexture = 0;
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
        glDeleteTextures(1, &m_pSprites[i].iTexture);
        glDeleteTextures(1, &m_pSprites[i].iAltTexture);
        if(m_pSprites[i].pData)
            delete[] m_pSprites[i].pData;
    }
    delete[] m_pSprites;
    m_pSprites = NULL;
    m_iSpriteCount = 0;
    glDeleteTextures(1, &m_iMegaTexture);
    m_iMegaTexture = 0;
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

        pSprite->iTexture = 0;
        pSprite->iAltTexture = 0;
        pSprite->pData = NULL;
        pSprite->pAltPaletteMap = NULL;
        pSprite->iWidth = pTHSprite->width;
        pSprite->iHeight = pTHSprite->height;
        pSprite->iWidth2 = roundUp2(pSprite->iWidth);
        pSprite->iHeight2 = roundUp2(pSprite->iHeight);

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

        pSprite->iTexture = m_iMegaTexture;
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

    m_iMegaTexture = m_pTarget->createTexture(iSize, iSize, pData);
    delete[] pData;
    if(m_iMegaTexture != 0)
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
        if(pSprite->iAltTexture)
        {
            glDeleteTextures(1, &pSprite->iAltTexture);
            pSprite->iAltTexture = 0;
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
    sprite_t *pSprite = m_pSprites + iSprite;

    // Find or create the texture
    GLuint iTexture = pSprite->iTexture;
    if(iTexture == 0)
    {
        if(pSprite->pData == NULL)
            return;

        iTexture = m_pTarget->createTexture(pSprite->iWidth, pSprite->iHeight,
            pSprite->pData, m_pPalette);
        pSprite->iTexture = iTexture;
    }
    if(iFlags & THDF_AltPalette)
    {
        iTexture = pSprite->iAltTexture;
        if(iTexture == 0)
        {
            iTexture = _makeAltBitmap(pSprite);
            if(iTexture == 0)
                return;
        }
    }

    if(iTexture == m_iMegaTexture)
    {
        pCanvas->draw(iTexture, m_pSprites[iSprite].iWidth,
            m_pSprites[iSprite].iHeight, iX, iY, iFlags, m_iMegaTextureSize,
            m_iMegaTextureSize, m_pSprites[iSprite].iSheetX,
            m_pSprites[iSprite].iSheetY);
    }
    else
    {
        pCanvas->draw(iTexture, m_pSprites[iSprite].iWidth,
            m_pSprites[iSprite].iHeight, iX, iY, iFlags,
            m_pSprites[iSprite].iWidth2, m_pSprites[iSprite].iHeight2, 0, 0);
    }
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

GLuint THSpriteSheet::_makeAltBitmap(sprite_t *pSprite)
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
    pSprite->iAltTexture = m_pTarget->createTexture(pSprite->iWidth,
        pSprite->iHeight, pData, m_pPalette);
    delete[] pData;
    return pSprite->iAltTexture;
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
    // TODO (low priority, as Lua will simulate a cursor)
}

THCursor::~THCursor()
{
    // TODO (low priority, as Lua will simulate a cursor)
}

bool THCursor::createFromSprite(THSpriteSheet* pSheet, unsigned int iSprite,
                                int iHotspotX, int iHotspotY)
{
    // TODO (low priority, as Lua will simulate a cursor)
    return false;
}

void THCursor::use(THRenderTarget* pTarget)
{
    // TODO (low priority, as Lua will simulate a cursor)
}

bool THCursor::setPosition(THRenderTarget* pTarget, int iX, int iY)
{
    // TODO (low priority, as Lua will simulate a cursor)
    return false;
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
    pCanvas->flushSprites(); // Without this the lines are draw behind sprites/textures

    // Strangely drawing at 0,0 would draw outside of the screen
    // so we start at 1,0. This makes OpenGl behave like DirectX.
    iX++;

    glDisable(GL_TEXTURE_2D);
    glColor4ub(m_iR, m_iG, m_iB, m_iA);
    glLineWidth(m_fWidth);

    double lastX, lastY;
    lastX = m_pFirstOp->m_fX;
    lastY = m_pFirstOp->m_fY;

    THLineOperation* op = (THLineOperation*)(m_pFirstOp->m_pNext);
    while (op) {
        if (op->type == THLOP_LINE) {
            glBegin(GL_LINES);
            glVertex3f(lastX + iX, lastY + iY, 0.0f);
            glVertex3f(op->m_fX + iX, op->m_fY + iY, 0.0f);
            glEnd();
        }

        lastX = op->m_fX;
        lastY = op->m_fY;

        op = (THLineOperation*)(op->m_pNext);
    }
    glEnable(GL_TEXTURE_2D);
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
    return false;
}

void THFreeTypeFont::_setNullTexture(cached_text_t* pCacheEntry) const
{
    pCacheEntry->iTexture = 0;
}

void THFreeTypeFont::_freeTexture(cached_text_t* pCacheEntry) const
{
    if(pCacheEntry->iTexture != 0)
    {
        GLuint iTexture = static_cast<GLuint>(pCacheEntry->iTexture);
        glDeleteTextures(1, &iTexture);
    }
}

void THFreeTypeFont::_makeTexture(cached_text_t* pCacheEntry) const
{
    int iWidth2 = roundUp2(pCacheEntry->iWidth);
    int iHeight2 = roundUp2(pCacheEntry->iHeight);
    uint32_t* pPixels = new uint32_t[iWidth2 * iHeight2];
    memset(pPixels, 0, iWidth2 * iHeight2 * sizeof(uint32_t));
    unsigned char* pInRow = pCacheEntry->pData;
    uint32_t* pOutRow = pPixels;
    uint32_t iColBase = m_oColour & 0xFFFFFF;
    for(int iY = 0; iY < pCacheEntry->iHeight; ++iY, pOutRow += iWidth2,
        pInRow += pCacheEntry->iWidth)
    {
        for(int iX = 0; iX < pCacheEntry->iWidth; ++iX)
        {
            pOutRow[iX] = (static_cast<uint32_t>(pInRow[iX]) << 24) | iColBase;
        }
    }
    pCacheEntry->iTexture = static_cast<int>(THRenderTarget::createTexture(iWidth2, iHeight2, pPixels));
    delete[] pPixels;
}

void THFreeTypeFont::_drawTexture(THRenderTarget* pCanvas, cached_text_t* pCacheEntry, int iX, int iY) const
{
    if(pCacheEntry->iTexture == 0)
        return;

    pCanvas->draw(static_cast<GLuint>(pCacheEntry->iTexture),
        pCacheEntry->iWidth, pCacheEntry->iHeight, iX, iY, 0,
        roundUp2(pCacheEntry->iWidth), roundUp2(pCacheEntry->iHeight), 0, 0);
    // As the cache entry might get re-used, flush sprites now.
    pCanvas->flushSprites();
}
#endif // CORSIX_TH_USE_FREETYPE2

#endif // CORSIX_TH_USE_OGL_RENDERER
