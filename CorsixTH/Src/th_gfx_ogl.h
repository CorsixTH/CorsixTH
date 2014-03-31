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

#ifndef CORSIX_TH_TH_GFX_OGL_H_
#define CORSIX_TH_TH_GFX_OGL_H_
#include "config.h"
#ifdef CORSIX_TH_USE_OGL_RENDERER
#ifdef CORSIX_TH_HAS_RENDERING_ENGINE
#error More than one rendering engine enabled in config file
#endif
#define CORSIX_TH_HAS_RENDERING_ENGINE
#ifdef _WIN32
#ifndef CORSIX_TH_USE_WIN32_SDK
#error Windows Platform SDK usage must be enabled to use OGL renderer on Win32
#endif
#include <windows.h>
#endif
#include <SDL.h>
#ifdef CORSIX_TH_USE_OGL_RENDER_TO_TEXTURE
#define GL_GLEXT_PROTOTYPES
#else
#define NO_SDL_GLEXT
#endif

#include <SDL_opengl.h>
#include "persist_lua.h"

//Darrell: The wxWindows OGL includes can stop these from being defined in
//SDL_opengl.h so as a temporary solution I'm defining them here.
#ifdef __APPLE__
typedef GLboolean (APIENTRYP PFNGLISRENDERBUFFEREXTPROC) (GLuint renderbuffer);
typedef void (APIENTRYP PFNGLBINDRENDERBUFFEREXTPROC) (GLenum target, GLuint renderbuffer);
typedef void (APIENTRYP PFNGLDELETERENDERBUFFERSEXTPROC) (GLsizei n, const GLuint *renderbuffers);
typedef void (APIENTRYP PFNGLGENRENDERBUFFERSEXTPROC) (GLsizei n, GLuint *renderbuffers);
typedef void (APIENTRYP PFNGLRENDERBUFFERSTORAGEEXTPROC) (GLenum target, GLenum internalformat, GLsizei width, GLsizei height);
typedef void (APIENTRYP PFNGLGETRENDERBUFFERPARAMETERIVEXTPROC) (GLenum target, GLenum pname, GLint *params);
typedef GLboolean (APIENTRYP PFNGLISFRAMEBUFFEREXTPROC) (GLuint framebuffer);
typedef void (APIENTRYP PFNGLBINDFRAMEBUFFEREXTPROC) (GLenum target, GLuint framebuffer);
typedef void (APIENTRYP PFNGLDELETEFRAMEBUFFERSEXTPROC) (GLsizei n, const GLuint *framebuffers);
typedef void (APIENTRYP PFNGLGENFRAMEBUFFERSEXTPROC) (GLsizei n, GLuint *framebuffers);
typedef GLenum (APIENTRYP PFNGLCHECKFRAMEBUFFERSTATUSEXTPROC) (GLenum target);
typedef void (APIENTRYP PFNGLFRAMEBUFFERTEXTURE1DEXTPROC) (GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level);
typedef void (APIENTRYP PFNGLFRAMEBUFFERTEXTURE2DEXTPROC) (GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level);
typedef void (APIENTRYP PFNGLFRAMEBUFFERTEXTURE3DEXTPROC) (GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level, GLint zoffset);
typedef void (APIENTRYP PFNGLFRAMEBUFFERRENDERBUFFEREXTPROC) (GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer);
typedef void (APIENTRYP PFNGLGETFRAMEBUFFERATTACHMENTPARAMETERIVEXTPROC) (GLenum target, GLenum attachment, GLenum pname, GLint *params);
typedef void (APIENTRYP PFNGLGENERATEMIPMAPEXTPROC) (GLenum target);
#endif

class THCursor;
struct THRenderTargetCreationParams;

struct THClipRect
{
    typedef  int16_t xy_t;
    typedef uint16_t wh_t;
    xy_t x, y;
    wh_t w, h;
};

struct THOGL_Vertex
{
    float u, v;
    uint32_t colour;
    float x, y, z;
    // The texture is not part of the GL vertex, but is included with the
    // vertex data to make it simpler to sort verticies by texture.
    GLuint tex;
};

typedef uint32_t THColour;

class THPalette
{
public: // External API
    THPalette();

    bool loadFromTHFile(const unsigned char* pData, size_t iDataLength);
    bool setEntry(int iEntry, uint8_t iR, uint8_t iG, uint8_t iB);

public: // Internal (this rendering engine only) API
    inline static uint32_t packARGB(uint8_t iA, uint8_t iR, uint8_t iG, uint8_t iB)
    {
        return (static_cast<uint32_t>(iR) <<  0) |
               (static_cast<uint32_t>(iG) <<  8) |
               (static_cast<uint32_t>(iB) << 16) |
               (static_cast<uint32_t>(iA) << 24) ;
    }
    int getColourCount() const;
    const uint32_t* getARGBData() const;

protected:
    uint32_t m_aColoursARGB[256];
    int m_iNumColours;
};

class THRenderTarget
{
public: // External API
    THRenderTarget();
    ~THRenderTarget();

    bool create(const THRenderTargetCreationParams* pParams);
    const char* getLastError();

    bool startFrame();
    bool endFrame();
    bool fillBlack();
    void setBlueFilterActive(bool bActivate);
    uint32_t mapColour(uint8_t iR, uint8_t iG, uint8_t iB);
    bool fillRect(uint32_t iColour, int iX, int iY, int iW, int iH);
    void getClipRect(THClipRect* pRect) const;
    int getWidth() const;
    int getHeight() const;
    void setClipRect(const THClipRect* pRect);
    void startNonOverlapping();
    void finishNonOverlapping();
    void setCursor(THCursor* pCursor);
    void setCursorPosition(int iX, int iY);
    bool takeScreenshot(const char* sFile);
    bool setScaleFactor(float fScale, THScaledItems eWhatToScale);
    // If you add any extra methods here which are called from outside the
    // rendering engine, then be sure to at least add dummy implementations
    // to the other rendering engines.

public: // Internal (this rendering engine only) API
    THOGL_Vertex* allocVerticies(size_t iCount, GLuint iTexture);
    void draw(GLuint iTexture, unsigned int iWidth, unsigned int iHeight,
        int iX, int iY, unsigned long iFlags, unsigned int iWidth2,
        unsigned int iHeight2, unsigned int iTexX, unsigned int iTexY);
    bool flushSprites();
    GLuint createTexture(int iWidth, int iHeight, const unsigned char* pPixels,
                         const THPalette* pPalette, int* pWidth2 = NULL,
                         int* pHeight2 = NULL);
    static GLuint createTexture(int iWidth2, int iHeight2, const uint32_t* pPixels);
    static GLenum getGLError();
    static void setGLProjection(GLdouble fWidth, GLdouble fHeight);
    bool shouldScaleBitmaps(float* pFactor);

protected:
    SDL_Surface* m_pSurface;
    THOGL_Vertex *m_pVerticies;
#ifdef CORSIX_TH_USE_OGL_RENDER_TO_TEXTURE
    PFNGLGENFRAMEBUFFERSEXTPROC m_glGenFramebuffersEXT;
    PFNGLBINDFRAMEBUFFEREXTPROC m_glBindFramebufferEXT;
    PFNGLFRAMEBUFFERTEXTURE2DEXTPROC m_glFramebufferTexture2DEXT;
    PFNGLDELETEFRAMEBUFFERSEXTPROC m_glDeleteFramebuffersEXT;
    PFNGLCHECKFRAMEBUFFERSTATUSEXTPROC m_glCheckFramebufferStatusEXT;
    float m_fZoomScale;
    GLuint m_iZoomTexture;
    GLuint m_iZoomFrameBuffer;
    int m_iZoomTextureSize;
    bool m_bUsingZoomBuffer;
#endif

    THClipRect m_rcClip;
    float m_fBitmapScaleFactor;
    size_t m_iVertexCount;
    size_t m_iVertexLength;
    size_t m_iNonOverlappingStart;
    int m_iNonOverlapping;
    int m_iWidth;
    int m_iHeight;
    bool m_bShouldScaleBitmaps;

    bool m_bBlueFilterActive;

    void _drawVerts(size_t iFirst, size_t iLast);
    void _flushZoomBuffer();
};

class THRawBitmap
{
public: // External API
    THRawBitmap();
    ~THRawBitmap();

    void setPalette(const THPalette* pPalette);

    bool loadFromTHFile(const unsigned char* pPixelData, size_t iPixelDataLength,
                        int iWidth, THRenderTarget *pEventualCanvas);

    void draw(THRenderTarget* pCanvas, int iX, int iY);
    void draw(THRenderTarget* pCanvas, int iX, int iY, int iSrcX, int iSrcY,
              int iWidth, int iHeight);

protected:
    GLuint m_iTexture;
    const THPalette* m_pPalette;
    THRenderTarget* m_pTarget;
    int m_iWidth;
    int m_iWidth2;
    int m_iHeight;
    int m_iHeight2;
};

class THSpriteSheet
{
public: // External API
    THSpriteSheet();
    ~THSpriteSheet();

    void setPalette(const THPalette* pPalette);

    bool loadFromTHFile(const unsigned char* pTableData, size_t iTableDataLength,
                        const unsigned char* pChunkData, size_t iChunkDataLength,
                        bool bComplexChunks, THRenderTarget* pEventualCanvas);

    void setSpriteAltPaletteMap(unsigned int iSprite, const unsigned char* pMap);

    unsigned int getSpriteCount() const;
    bool getSpriteSize(unsigned int iSprite, unsigned int* pX, unsigned int* pY) const;
    void getSpriteSizeUnchecked(unsigned int iSprite, unsigned int* pX, unsigned int* pY) const;

    bool getSpriteAverageColour(unsigned int iSprite, THColour* pColour) const;

    void drawSprite(THRenderTarget* pCanvas, unsigned int iSprite, int iX, int iY, unsigned long iFlags);
    bool hitTestSprite(unsigned int iSprite, int iX, int iY, unsigned long iFlags) const;

public: // Internal (this rendering engine only) API
    //! Draw a sprite into wxImage data arrays (for the Map Editor)
    void wxDrawSprite(unsigned int iSprite, unsigned char* pRGBData, unsigned char* pAData);

protected:
    friend class THCursor;
#if CORSIX_TH_USE_PACK_PRAGMAS
#pragma pack(push)
#pragma pack(1)
#endif
    struct th_sprite_t
    {
        uint32_t position;
        unsigned char width;
        unsigned char height;
    } CORSIX_TH_PACKED_FLAGS;
#if CORSIX_TH_USE_PACK_PRAGMAS
#pragma pack(pop)
#endif

    struct sprite_t
    {
        GLuint iTexture;
        GLuint iAltTexture;
        unsigned char *pData;
        const unsigned char *pAltPaletteMap;
        unsigned int iSheetX;
        unsigned int iSheetY;
        unsigned int iWidth;
        unsigned int iHeight;
        unsigned int iWidth2;
        unsigned int iHeight2;
    } *m_pSprites;
    const THPalette* m_pPalette;
    THRenderTarget* m_pTarget;
    GLuint m_iMegaTexture;
    unsigned int m_iMegaTextureSize;
    unsigned int m_iSpriteCount;

    void _freeSprites();
    bool _tryFitSingleTex(sprite_t** ppSortedSprites, unsigned int iSize);
    void _makeSingleTex(sprite_t** ppSortedSprites, unsigned int iSize);
    GLuint _makeAltBitmap(sprite_t *pSprite);
    static int _sortSpritesHeight(const void*, const void*);
};

class THCursor
{
public: // External API
    THCursor();
    ~THCursor();

    bool createFromSprite(THSpriteSheet* pSheet, unsigned int iSprite,
                          int iHotspotX = 0, int iHotspotY = 0);

    void use(THRenderTarget* pTarget);

    static bool setPosition(THRenderTarget* pTarget, int iX, int iY);

protected:
    friend class THRenderTarget;
};

class THLine
{
public:
    THLine();
    ~THLine();

    void moveTo(double fX, double fY);

    void lineTo(double fX, double fY);

    void setWidth(double lineWidth);

    void draw(THRenderTarget* pCanvas, int iX, int iY);

    void setColour(uint8_t iR, uint8_t iG, uint8_t iB, uint8_t iA = 255);

    void persist(LuaPersistWriter *pWriter) const;
    void depersist(LuaPersistReader *pReader);

protected:
    void initialize();

    enum THLineOpType {
        THLOP_MOVE,
        THLOP_LINE
    };

    struct THLineOperation : public THLinkList
    {
        THLineOpType type;
        double m_fX, m_fY;
        THLineOperation(THLineOpType type, double m_fX, double m_fY) : type(type), m_fX(m_fX), m_fY(m_fY) {
            m_pNext = NULL;
        }
    };

    THLineOperation* m_pFirstOp;
    THLineOperation* m_pCurrentOp;
    double m_fWidth;
    uint8_t m_iR, m_iG, m_iB, m_iA;
};

#endif // CORSIX_TH_USE_OGL_RENDERER
#endif // CORSIX_TH_TH_GFX_OGL_H_
