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

#ifndef CORSIX_TH_TH_GFX_H_
#define CORSIX_TH_TH_GFX_H_
#include "th.h"
#include "th_gfx_sdl.h"
#include "th_gfx_dx9.h"
#include <stddef.h>

#ifndef CORSIX_TH_HAS_RENDERING_ENGINE
#error No rendering engine enabled in config file
#endif

enum THDrawFlags
{
    // Sprite drawing flags
    THDF_FlipHorizontal = 1 <<  0,
    THDF_FlipVertical   = 1 <<  1,
    THDF_Alpha50        = 1 <<  2,
    THDF_Alpha75        = 1 <<  3,
    THDF_AltPalette     = 1 <<  4,

    // Object attached to tile flags
    THDF_EarlyList      = 1 << 10,
    THDF_ListBottom     = 1 << 11,
};

struct THDrawable : public THLinkList
{
    void (*fnDraw)(THDrawable* pSelf, THRenderTarget* pCanvas, int iDestX, int iDestY);
    unsigned long iFlags;
};

class THChunkRenderer
{
public:
    THChunkRenderer(int width, int height, unsigned char *buffer = NULL);
    ~THChunkRenderer();

    void decodeChunks(const unsigned char* pData, int iDataLen, bool bComplex);

    inline bool isDone() {return m_ptr == m_end;}
    unsigned char* takeData();
    inline const unsigned char* getData() const {return m_data;}

    void chunkCopy(int npixels, const unsigned char* data);
    void chunkFill(int npixels, unsigned char value);
    void chunkFillToEndOfLine(unsigned char value);
    void chunkFinish(unsigned char value);

protected:
    inline void _fixNpixels(int& npixels) const;
    inline void _incrementPosition(int npixels);

    unsigned char *m_data, *m_ptr, *m_end;
    int m_x, m_y, m_width, m_height;
    bool m_skip_eol;
};

class THFont
{
public:
    THFont();

    void setSpriteSheet(THSpriteSheet* pSpriteSheet);
    void setSeparation(int iCharSep, int iLineSep);

    void getTextSize(const char* sMessage, size_t iMessageLength, int* pX, int* pY) const;
    void drawText(THRenderTarget* pCanvas, const char* sMessage, size_t iMessageLength, int iX, int iY) const;
    void drawTextWrapped(THRenderTarget* pCanvas, const char* sMessage, size_t iMessageLength, int iX, int iY, int iWidth) const;

protected:
    THSpriteSheet* m_pSpriteSheet;
    int m_iCharSep;
    int m_iLineSep;
};

struct THLayers_t
{
    unsigned char iLayerContents[13];
};

class THAnimationManager
{
public:
    THAnimationManager();
    ~THAnimationManager();

    void setSpriteSheet(THSpriteSheet* pSpriteSheet);

    bool loadFromTHFile(const unsigned char* pStartData, size_t iStartDataLength,
                        const unsigned char* pFrameData, size_t iFrameDataLength,
                        const unsigned char* pListData, size_t iListDataLength,
                        const unsigned char* pElementData, size_t iElementDataLength);

    unsigned int getAnimationCount() const;
    unsigned int getFrameCount() const;

    unsigned int getFirstFrame(unsigned int iAnimation) const;
    unsigned int getNextFrame(unsigned int iFrame) const;

    void setAnimationAltPaletteMap(unsigned int iAnimation, const unsigned char* pMap);
    void drawFrame(THRenderTarget* pCanvas, unsigned int iFrame, const THLayers_t& oLayers, int iX, int iY, unsigned long iFlags) const;

protected:
#pragma pack(push)
#pragma pack(1)
    struct th_anim_t
    {
        uint16_t frame;
        uint16_t unknown;
    };

    struct th_frame_t
    {
        uint32_t list_index;
        uint8_t width;
        uint8_t height;
        uint16_t flags;
        uint16_t next;
    };

    struct th_element_t
    {
        uint16_t table_position;
        uint8_t offx;
        uint8_t offy;
        uint8_t flags;
        uint8_t layerid;
    };
#pragma pack(pop)

    struct frame_t
    {
        unsigned int iListIndex;
        unsigned int iNextFrame;
    };

    struct element_t
    {
        unsigned int iSprite;
        unsigned int iFlags;
        int iX;
        int iY;
        unsigned char iLayer;
        unsigned char iLayerId;
    };

    unsigned int* m_pFirstFrames;
    frame_t* m_pFrames;
    uint16_t* m_pElementList;
    element_t* m_pElements;
    THSpriteSheet* m_pSpriteSheet;

    unsigned int m_iAnimationCount;
    unsigned int m_iFrameCount;
    unsigned int m_iElementCount;
};

class THAnimation : protected THDrawable
{
public:
    THAnimation();

    void removeFromTile();
    void attachToTile(THLinkList *pMapNode);

    void tick();
    void draw(THRenderTarget* pCanvas, int iDestX, int iDestY);

    THLinkList* getPrevious() {return this->pPrev;}
    unsigned long getFlags() {return this->iFlags;}
    unsigned int getAnimation() {return m_iAnimation;}
    int getX() {return m_iX;}
    int getY() {return m_iY;}

    void setAnimation(THAnimationManager* pManager, unsigned int iAnimation);
    void setFlags(unsigned long iFlags) {this->iFlags = iFlags;}
    void setPosition(int iX, int iY) {m_iX = iX, m_iY = iY;}
    void setSpeed(int iX, int iY) {m_iSpeedX = iX, m_iSpeedY = iY;}
    void setLayer(int iLayer, int iId);

protected:
    THAnimationManager *m_pManager;
    unsigned int m_iAnimation;
    unsigned int m_iFrame;
    int m_iX;
    int m_iY;
    int m_iSpeedX;
    int m_iSpeedY;
    THLayers_t m_oLayers;
};

#endif // CORSIX_TH_TH_GFX_H_
