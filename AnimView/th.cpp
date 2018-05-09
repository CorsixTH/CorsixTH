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

#include "th.h"
#include "../common/rnc.h"
#include <wx/app.h>
#include <wx/toplevel.h>
#include <wx/filename.h>
#include <algorithm>
#include <array>
#include <set>
#include <stdexcept>
#include <vector>

static const unsigned char palette_upscale_map[0x40] = {
    0x00, 0x04, 0x08, 0x0C, 0x10, 0x14, 0x18, 0x1C,
    0x20, 0x24, 0x28, 0x2D, 0x31, 0x35, 0x39, 0x3D,
    0x41, 0x45, 0x49, 0x4D, 0x51, 0x55, 0x59, 0x5D,
    0x61, 0x65, 0x69, 0x6D, 0x71, 0x75, 0x79, 0x7D,
    0x82, 0x86, 0x8A, 0x8E, 0x92, 0x96, 0x9A, 0x9E,
    0xA2, 0xA6, 0xAA, 0xAE, 0xB2, 0xB6, 0xBA, 0xBE,
    0xC2, 0xC6, 0xCA, 0xCE, 0xD2, 0xD7, 0xDB, 0xDF,
    0xE3, 0xE7, 0xEB, 0xEF, 0xF3, 0xF7, 0xFB, 0xFF,
};

class ChunkRenderer
{
public:
    ChunkRenderer(int width, int height, unsigned char *buffer = NULL)
    {
        m_data = buffer ? buffer : new unsigned char[width * height];
        m_ptr = m_data;
        m_end = m_data + width * height;
        m_x = 0;
        m_y = 0;
        m_width = width;
        m_height = height;
        m_skip_eol = false;
    }

    ~ChunkRenderer()
    {
        delete[] m_data;
    }

    bool isDone() const
    {
        return m_ptr == m_end;
    }

    unsigned char* takeData()
    {
        unsigned char *buffer = m_data;
        m_data = 0;
        return buffer;
    }

    const unsigned char* getData() const
    {
        return m_data;
    }

    void chunkFillToEndOfLine(unsigned char value)
    {
        if(m_x != 0 || !m_skip_eol)
        {
            chunkFill(m_width - m_x, value);
        }
        m_skip_eol = false;
    }

    void chunkFinish(unsigned char value)
    {
        chunkFill(m_end - m_ptr, value);
    }

    void chunkFill(int npixels, unsigned char value)
    {
        _fixNpixels(npixels);
        if(npixels > 0)
        {
            memset(m_ptr, value, npixels);
            _incrementPosition(npixels);
        }
    }

    void chunkCopy(int npixels, const unsigned char* data)
    {
        _fixNpixels(npixels);
        if(npixels > 0)
        {
            memcpy(m_ptr, data, npixels);
            _incrementPosition(npixels);
        }
    }

protected:
    inline void _fixNpixels(int& npixels) const
    {
        if(m_ptr + npixels > m_end)
        {
            npixels = m_end - m_ptr;
        }
    }

    inline void _incrementPosition(int npixels)
    {
        m_ptr += npixels;
        m_x += npixels;
        m_y += m_x / m_width;
        m_x = m_x % m_width;
        m_skip_eol = true;
    }

    unsigned char *m_data, *m_ptr, *m_end;
    int m_x, m_y, m_width, m_height;
    bool m_skip_eol;
};

static void decode_chunks(ChunkRenderer& renderer, const unsigned char* data, int datalen, unsigned char transparent)
{
    while(!renderer.isDone() && datalen > 0)
    {
        unsigned char b = *data;
        --datalen;
        ++data;
        if(b == 0)
        {
            renderer.chunkFillToEndOfLine(transparent);
        }
        else if(b < 0x80)
        {
            int amt = b;
            if(datalen < amt)
                amt = datalen;
            renderer.chunkCopy(amt, data);
            data += amt;
            datalen -= amt;
        }
        else
        {
            renderer.chunkFill(0x100 - b, transparent);
        }
    }
    renderer.chunkFinish(transparent);
}

static void decode_chunks_complex(ChunkRenderer& renderer, const unsigned char* data, int datalen, unsigned char transparent)
{
    while(!renderer.isDone() && datalen > 0)
    {
        unsigned char b = *data;
        --datalen;
        ++data;
        if(b == 0)
        {
            renderer.chunkFillToEndOfLine(transparent);
        }
        else if(b < 0x40)
        {
            int amt = b;
            if(datalen < amt)
                amt = datalen;
            renderer.chunkCopy(amt, data);
            data += amt;
            datalen -= amt;
        }
        else if((b & 0xC0) == 0x80)
        {
            renderer.chunkFill(b - 0x80, transparent);
        }
        else
        {
            int amt;
            unsigned char colour = 0;
            if(b == 0xFF)
            {
                if(datalen < 2)
                {
                    break;
                }
                amt = (int)data[0];
                colour = data[1];
                data += 2;
                datalen -= 2;
            }
            else
            {
                amt = b - 60 - (b & 0x80) / 2;
                if(datalen > 0)
                {
                    colour = *data;
                    ++data;
                    --datalen;
                }
            }
            renderer.chunkFill(amt, colour);
        }
    }
    renderer.chunkFinish(transparent);
}

THLayerMask::THLayerMask()
{
    clear();
}

void THLayerMask::clear()
{
    for(int i = 0; i < 13; ++i)
        m_iMask[i] = 0;
}

THAnimations::THAnimations()
{
    anims = std::vector<th_anim_t>();
    frames = std::vector<th_frame_t>();
    elementList = std::vector<uint16_t>();
    elements = std::vector<th_element_t>();
    sprites = std::vector<th_sprite_t>();
    spriteBitmaps = std::vector<Bitmap>();
    chunks = std::vector<uint8_t>();
    colours = std::vector<th_colour_t>();
    ghostMaps = std::array<unsigned char, 256 * 256 * 4>();
    for(int iMap = 0; iMap < 256 * 4; ++iMap)
    {
        for(int iCol = 0; iCol < 256; ++iCol)
        {
            ghostMaps[iMap * 256 + iCol] = iCol;
        }
    }
    m_iGhostMapOffset = 0;
}

THAnimations::~THAnimations()
{
}

bool THAnimations::isAnimationDuplicate(size_t iAnimation)
{
    if(iAnimation < anims.size())
        return anims.at(iAnimation).unknown == 1;
    else
        return true;
}

size_t THAnimations::markDuplicates()
{
    size_t iNonDuplicateCount = 0;

    std::set<uint16_t> seen;
    for(th_anim_t& anim : anims)
    {
        uint16_t iFrame = anim.frame;
        uint16_t iFirstFrame = iFrame;
        do
        {
            if(seen.find(iFrame) != seen.end()) {
                anim.unknown = 1;
            } else {
                seen.insert(iFrame);
            }
            iFrame = frames.at(iFrame).next;
        } while(iFrame != iFirstFrame);

        if(anim.unknown == 0)
        {
            ++iNonDuplicateCount;
        }
    }

    return iNonDuplicateCount;
}

bool THAnimations::loadFrameFile(wxString sFilename)
{
    if(!loadVector(frames, sFilename))
        return false;

    /*
      256 is a common flag - could be x-flip.
      The lower byte can also take non-zero values - could be ghost palette
      indices.
    */

    return true;
}

bool THAnimations::loadTableFile(wxString sFilename)
{
    spriteBitmaps.clear();
    if(!loadVector(sprites, sFilename))
        return false;
    spriteBitmaps.resize(sprites.size());
    return true;
}

bool THAnimations::loadPaletteFile(wxString sFilename)
{
    if (!loadVector(colours, sFilename))
        return false;
    for (th_colour_t& colour : colours)
    {
        colour.r = palette_upscale_map[colour.r & 0x3F];
        colour.g = palette_upscale_map[colour.g & 0x3F];
        colour.b = palette_upscale_map[colour.b & 0x3F];
    }
    return true;
}

bool THAnimations::loadGhostFile(wxString sFilename, int iIndex)
{
    if(iIndex < 0 || iIndex >= 4)
        return false;

    std::vector<unsigned char> data;

    if (!loadVector(data, sFilename))
        return false;

    if (data.size() != 256 * 256) {
        return false;
    }

    std::copy(data.begin(), data.end(), ghostMaps.begin() + iIndex * 256 * 256);
    return true;
}

void THAnimations::setGhost(int iFile, int iIndex)
{
    m_iGhostMapOffset = iFile * 256 * 256 + iIndex * 256;
}

size_t THAnimations::getAnimationCount()
{
    return anims.size();
}

size_t THAnimations::getSpriteCount()
{
    return sprites.size();
}

void THAnimations::setSpritePath(wxString aPath)
{
    m_sSpritePath = aPath;
}

void THAnimations::getAnimationMask(size_t iAnimation, THLayerMask& mskLayers)
{
    mskLayers.clear();
    if(iAnimation >= anims.size())
        return;

    uint16_t iFrameIndex = anims.at(iAnimation).frame;
    if(iFrameIndex >= frames.size())
        return;
    uint16_t iFirstFrameIndex = iFrameIndex;

    do
    {
        th_frame_t* pFrame = &(frames.at(iFrameIndex));
        uint32_t iListIndex = pFrame->list_index;
        th_element_t* pElement;
        while((pElement = _getElement(iListIndex++)))
        {
            mskLayers.set(pElement->flags >> 4, pElement->layerid);
        }
        iFrameIndex = frames.at(iFrameIndex).next;
    } while(iFrameIndex < frames.size() && iFrameIndex != iFirstFrameIndex);
}

size_t THAnimations::getFrameCount(size_t iAnimation)
{
    if(iAnimation >= anims.size())
        return 0;
    size_t iCount = 0;
    uint16_t iFirstFrame = anims.at(iAnimation).frame;
    if(iFirstFrame < frames.size())
    {
        ++iCount;
        uint16_t iFrame = frames.at(iFirstFrame).next;
        while(iFrame != iFirstFrame && iFrame < frames.size() && iCount < 1024)
        {
            ++iCount;
            iFrame = frames.at(iFrame).next;
        }
    }
    return iCount;
}

bool THAnimations::doesAnimationIncludeFrame(size_t iAnimation, size_t iFrame)
{
    if(iAnimation >= anims.size() || iFrame >= frames.size())
        return 0;
    uint16_t iFirstFrame = anims.at(iAnimation).frame;
    uint16_t iFrameNow = iFirstFrame;
    do
    {
        if(iFrameNow >= frames.size())
            break;
        if(iFrame == iFrameNow)
            return true;
        iFrameNow = frames.at(iFrameNow).next;
    } while(iFrameNow != iFirstFrame);
    return false;
}

Bitmap* THAnimations::getSpriteBitmap(size_t iSprite, bool bComplex)
{
    if(iSprite >= sprites.size())
        return nullptr;

    if (!spriteBitmaps.at(iSprite).IsOk())
    {
        wxString spriteFile = m_sSpritePath + wxString::Format(L"a%04ue.png", (int)iSprite);
        th_sprite_t* pSprite = &(sprites.at(iSprite));

        ChunkRenderer oRenderer(pSprite->width, pSprite->height);
        (bComplex ? decode_chunks_complex : decode_chunks)(oRenderer, (const unsigned char*)chunks.data() + pSprite->offset, chunks.size() - pSprite->offset, 0xFF);
        spriteBitmaps[iSprite].create(pSprite->width, pSprite->height, oRenderer.getData());
    }

    return &(spriteBitmaps.at(iSprite));
}

th_frame_t* THAnimations::getFrameStruct(size_t iAnimation, size_t iFrame)
{
    if(iAnimation >= anims.size())
        return 0;
    uint16_t iFrameIndex = anims.at(iAnimation).frame;
    while(iFrame--)
    {
        iFrameIndex = frames.at(iFrameIndex).next;
    }
    return &(frames.at(iFrameIndex));
}

void THAnimations::drawFrame(wxImage& imgCanvas, size_t iAnimation, size_t iFrame, const THLayerMask* pMask, wxSize& size, int iXOffset, int iYOffset)
{
    if(iAnimation >= anims.size())
        return;
    uint16_t iFrameIndex = anims.at(iAnimation).frame;
    while(iFrame--)
    {
        iFrameIndex = frames.at(iFrameIndex).next;
    }

    th_frame_t* pFrame = &(frames.at(iFrameIndex));
    th_element_t* pElement;
    uint32_t iListIndex = pFrame->list_index;
    int iFarX = 0;
    int iFarY = 0;
    while((pElement = _getElement(iListIndex++)))
    {
        if(pMask != NULL && !pMask->isSet(pElement->flags >> 4, pElement->layerid))
            continue;
        uint16_t iSpriteIndex = pElement->table_position / sizeof(th_sprite_t);
        th_sprite_t* pSprite = &(sprites.at(iSpriteIndex));
        int iRight = pElement->offx + pSprite->width;
        int iBottom = pElement->offy + pSprite->height;
        if(iRight > iFarX)
            iFarX = iRight;
        if(iBottom > iFarY)
            iFarY = iBottom;

        getSpriteBitmap(iSpriteIndex)->blit(imgCanvas, pElement->offx + iXOffset, pElement->offy + iYOffset, ghostMaps.data() + m_iGhostMapOffset, colours.data(), pElement->flags & 0xF);
    }
    size.x = iFarX;
    size.y = iFarY;
}

th_element_t* THAnimations::_getElement(uint32_t iListIndex)
{
    if(iListIndex >= elementList.size())
        return nullptr;
    uint16_t iElementIndex = elementList.at(iListIndex);
    if(iElementIndex >= elements.size())
        return nullptr;
    return &(elements.at(iElementIndex));
}

unsigned char* THAnimations::Decompress(unsigned char* pData, size_t& iLength)
{
    unsigned long outlen = rnc_output_size(pData);
    unsigned char* outbuf = new unsigned char[outlen];
    if (rnc_input_size(pData) != iLength) {
        throw std::length_error("rnc data does not match the expected length");
    }

    if(rnc_unpack(pData, outbuf) == rnc_status::ok)
    {
        delete[] pData;
        iLength = outlen;
        return outbuf;
    }
    else
    {
        delete[] pData;
        delete[] outbuf;
        iLength = 0;
        return nullptr;
    }
}

Bitmap::Bitmap() :
        m_iWidth(0),
        m_iHeight(0),
        m_pData(nullptr)
{
}

Bitmap::~Bitmap()
{
    delete[] m_pData;
}

void Bitmap::create(int iWidth, int iHeight)
{
    delete[] m_pData;
    m_pData = new uint8_t[iWidth * iHeight];
    m_iWidth = iWidth;
    m_iHeight = iHeight;
    memset(m_pData, 0xFF, iWidth * iHeight);
}

void Bitmap::create(int iWidth, int iHeight, const uint8_t* pData)
{
    delete[] m_pData;
    m_pData = new uint8_t[iWidth * iHeight];
    m_iWidth = iWidth;
    m_iHeight = iHeight;
    memcpy(m_pData, pData, iWidth * iHeight);
}

void Bitmap::blit(Bitmap& bmpCanvas, int iX, int iY, int iFlags) const
{
    for(int y = 0; y < m_iHeight; ++y)
    {
        for(int x = 0; x < m_iWidth; ++x)
        {
            uint8_t src = pixel(x, y);
            if(src == 0xFF)
                continue;
            int iDstX = iX + x;
            int iDstY = iY + y;
            if(iFlags & 0x2)
                iDstY = iY + m_iHeight - 1 - y;
            if(iFlags & 0x1)
                iDstX = iX + m_iWidth - 1 - x;
            bmpCanvas.pixel(iDstX, iDstY) = src;
        }
    }
}

static inline void _merge(th_colour_t& dst, const th_colour_t& src)
{
    dst.r = (uint8_t)(((unsigned int)dst.r + (unsigned int)src.r)/2);
    dst.g = (uint8_t)(((unsigned int)dst.g + (unsigned int)src.g)/2);
    dst.b = (uint8_t)(((unsigned int)dst.b + (unsigned int)src.b)/2);
}

void Bitmap::blit(wxImage& imgCanvas, int iX, int iY, const unsigned char* pColourTranslate, const th_colour_t* pPalette, int iFlags) const
{
    if(m_iHeight == 0 || m_iWidth == 0)
        return;

    th_colour_t* pCanvas = (th_colour_t*)imgCanvas.GetData();
    int iCanvasWidth = imgCanvas.GetWidth();
    if(m_iHeight > 256 || m_iWidth > 256)
    {
        return;
    }
    for(int y = 0; y < m_iHeight; ++y)
    {
        for(int x = 0; x < m_iWidth; ++x)
        {
            uint8_t src = pixel(x, y);
            if(src == 0xFF && (iFlags & 0x8000) == 0)
                continue;
            if(pColourTranslate != NULL)
            {
                src = pColourTranslate[src];
                if(src == 0xFF && (iFlags & 0x8000) == 0)
                    continue;
            }
            int iDstX = iX + x;
            int iDstY = iY + y;
            if(iFlags & 0x2)
                iDstY = iY + m_iHeight - 1 - y;
            if(iFlags & 0x1)
                iDstX = iX + m_iWidth - 1 - x;
            th_colour_t srcc = pPalette[src];
            if(iFlags & 0xC)
            {
                th_colour_t dstc = pCanvas[iDstY * iCanvasWidth + iDstX];
                switch(iFlags & 0xC)
                {
                case 0x8:
                    _merge(srcc, dstc);
                    // fall-through
                case 0x4:
                    _merge(srcc, dstc);
                    break;
                }
            }
            pCanvas[iDstY * iCanvasWidth + iDstX] = srcc;
            if(imgCanvas.HasAlpha())
            {
                //set completely opaque
                imgCanvas.SetAlpha(iDstX,iDstY,(unsigned char)255);
            }
        }
    }
}
