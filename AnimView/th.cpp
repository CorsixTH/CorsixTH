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
#include <wx/app.h>
#include <wx/toplevel.h>
#include <wx/filename.h>
#include <map>

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
    m_pAnims = NULL;
    m_pFrames = NULL;
    m_pElementList = NULL;
    m_pElements = NULL;
    m_pSprites = NULL;
    m_pSpriteBitmaps = NULL;
    m_pChunks = NULL;
    m_pColours = NULL;
    m_pGhostMaps = new unsigned char[256 * 256 * 4];
    for(int iMap = 0; iMap < 256 * 4; ++iMap)
    {
        for(int iCol = 0; iCol < 256; ++iCol)
        {
            m_pGhostMaps[iMap * 256 + iCol] = iCol;
        }
    }
    m_iGhostMapOffset = 0;
    m_iAnimCount = 0;
    m_iFrameCount = 0;
    m_iElementListCount = 0;
    m_iElementCount = 0;
    m_iSpriteCount = 0;
    m_iChunkCount = 0;
    m_iColourCount = 0;
}

THAnimations::~THAnimations()
{
    delete[] m_pAnims;
    delete[] m_pFrames;
    delete[] m_pElementList;
    delete[] m_pElements;
    delete[] m_pSprites;
    delete[] m_pSpriteBitmaps;
    delete[] m_pChunks;
    delete[] m_pColours;
    delete[] m_pGhostMaps;
}

bool THAnimations::isAnimationDuplicate(size_t iAnimation)
{
    if(iAnimation < m_iAnimCount)
        return m_pAnims[iAnimation].unknown == 1;
    else
        return true;
}

size_t THAnimations::markDuplicates()
{
    size_t iNonDuplicateCount = 0;

    std::map<uint16_t, bool> mapSeen;
    for(size_t i = 0; i < m_iAnimCount; ++i)
    {
        uint16_t iFrame = m_pAnims[i].frame;
        uint16_t iFirstFrame = iFrame;
        do
        {
            if(mapSeen[iFrame])
                m_pAnims[i].unknown = 1;
            else
                mapSeen[iFrame] = true;
            iFrame = m_pFrames[iFrame].next;
        } while(iFrame != iFirstFrame);
        if(m_pAnims[i].unknown == 0)
        {
            ++iNonDuplicateCount;
        }
    }

    return iNonDuplicateCount;
}

bool THAnimations::loadFrameFile(wxString sFilename)
{
    if(!_loadArray(m_pFrames, m_iFrameCount, sFilename))
        return false;

    /*
      256 is a common flag - could be x-flip.
      The lower byte can also take non-zero values - could be ghost palette
      indicies.
    */
    /*
    FILE *f = fopen("E:\\list.txt", "wt");
    for(size_t i = 0; i < m_iFrameCount; ++i)
    {
        if(m_pFrames[i].flags != 0)
        {
            fprintf(f, "%i, %i,\n", (int)i, (int)m_pFrames[i].flags);
        }
    }
    fclose(f);
    */

    return true;
}

bool THAnimations::loadTableFile(wxString sFilename)
{
    delete[] m_pSpriteBitmaps;
    m_pSpriteBitmaps = 0;
    if(!_loadArray(m_pSprites, m_iSpriteCount, sFilename))
        return false;
    m_pSpriteBitmaps = new Bitmap[m_iSpriteCount];
    return true;
}

void THAnimations::writeElementData(wxString aPath, wxTextOutputStream *outputLog, wxTextOutputStream *outputXml, size_t iAnimation, 
        size_t iFrame, const THLayerMask* pMask, wxSize& size)
{
    if(iAnimation >= m_iAnimCount)
        return;
    uint16_t iFrameIndex = m_pAnims[iAnimation].frame;
    while(iFrame--)
    {
        iFrameIndex = m_pFrames[iFrameIndex].next;
    }

    th_frame_t* pFrame = m_pFrames + iFrameIndex;
    th_element_t* pElement;
    uint32_t iListIndex = pFrame->list_index;
    int iFarX = 0;
    int iFarY = 0;
    while((pElement = _getElement(iListIndex++)))
    {
        //wxString aePath = aPath + wxString::Format(L"e%u", iListIndex);
        //if(!wxFileName::DirExists(aePath))
        //{
        //    wxFileName::Mkdir(aePath);
        //}

        uint16_t iSpriteIndex = pElement->table_position / sizeof(th_sprite_t);
        wxString elementFile = aPath + wxString::Format(L"a%04ue.png", iSpriteIndex);

        th_sprite_t* pSprite = m_pSprites + iSpriteIndex;
        int iRight = pElement->offx + pSprite->width;
        int iBottom = pElement->offy + pSprite->height;
        if(iRight > iFarX)
            iFarX = iRight;
        if(iBottom > iFarY)
            iFarY = iBottom;
        if(pMask != NULL && !pMask->isSet(pElement->flags >> 4, pElement->layerid))
            continue;
        outputXml->WriteString(wxString::Format(L"\t\t\t\t<sprite id='%u' flags='%u' xoffset='%u' yoffset='%u' width='%u' height='%u'/>\n", 
                iSpriteIndex, pElement->flags, pElement->offx, pElement->offy, pSprite->width, pSprite->height ));
        if(!wxFileName::FileExists(elementFile) && pSprite->width > 0 && pSprite->height > 0)
        {
            wxImage imgSprite(pSprite->width, pSprite->height, true);
            if(!imgSprite.HasAlpha())
            {
                imgSprite.SetAlpha();
            }
            for(int iX = 0; iX < pSprite->width; ++iX)
            {
                for(int iY = 0; iY < pSprite->height; ++iY)
                {
                    imgSprite.SetAlpha(iX,iY,(unsigned char)0);
                }
            }
            getSpriteBitmap(iSpriteIndex)->blit(imgSprite, 0, 0, m_pGhostMaps + m_iGhostMapOffset, m_pColours, pElement->flags & 0xF);
            if(!imgSprite.SaveFile(elementFile,wxBITMAP_TYPE_PNG))
                return;
            outputLog->WriteString(wxString::Format(L"E%u\t%u\t%u\t%u\t%u\t%u\t%u\t%u\t%u\t%u\t%u\n", iSpriteIndex,  
                    pElement->table_position, pElement->flags, pElement->layerid, pElement->offx, pElement->offy, 
                    iListIndex, sizeof(th_sprite_t), pSprite->width, pSprite->height, pSprite->offset));
        }
    }
    size.x = iFarX;
    size.y = iFarY;

}

void THAnimations::writeTableDataHeader(wxTextOutputStream *outputLog)
{
    outputLog->WriteString(wxString::Format(L"Element\tTablePos\tFlags\tLayerID\tXoff\tYoff\tListIndex\tSpriteSize\tWidth\tHeight\tOffset\n"));
}

bool THAnimations::loadPaletteFile(wxString sFilename)
{
    if(!_loadArray(m_pColours, m_iColourCount, sFilename))
        return false;
    for(size_t i = 0; i < m_iColourCount; ++i)
    {
        m_pColours[i].r = palette_upscale_map[m_pColours[i].r & 0x3F];
        m_pColours[i].g = palette_upscale_map[m_pColours[i].g & 0x3F];
        m_pColours[i].b = palette_upscale_map[m_pColours[i].b & 0x3F];
    }
    return true;
}

bool THAnimations::loadGhostFile(wxString sFilename, int iIndex)
{
    if(iIndex < 0 || iIndex >= 4)
        return false;

    unsigned char *pData = NULL;
    size_t iDataLen;

    if(!_loadArray(pData, iDataLen, sFilename))
        return false;

    if(iDataLen != 256 * 256)
    {
        delete[] pData;
        return false;
    }

    memcpy(m_pGhostMaps + iIndex * 256 * 256, pData, 256 * 256);
    delete[] pData;
    return true;
}

void THAnimations::setGhost(int iFile, int iIndex)
{
    m_iGhostMapOffset = iFile * 256 * 256 + iIndex * 256;
}

size_t THAnimations::getAnimationCount()
{
    return m_iAnimCount;
}

size_t THAnimations::getSpriteCount()
{
    return m_iSpriteCount;
}

void THAnimations::getAnimationMask(size_t iAnimation, THLayerMask& mskLayers)
{
    mskLayers.clear();
    if(iAnimation >= m_iAnimCount)
        return;

    uint16_t iFrameIndex = m_pAnims[iAnimation].frame;
    uint16_t iFirstFrameIndex = iFrameIndex;

    do
    {
        th_frame_t* pFrame = m_pFrames + iFrameIndex;
        uint32_t iListIndex = pFrame->list_index;
        th_element_t* pElement;
        while((pElement = _getElement(iListIndex++)))
        {
            mskLayers.set(pElement->flags >> 4, pElement->layerid);
        }
        iFrameIndex = m_pFrames[iFrameIndex].next;
    } while(iFrameIndex != iFirstFrameIndex);
}

size_t THAnimations::getFrameCount(size_t iAnimation)
{
    if(iAnimation >= m_iAnimCount)
        return 0;
    size_t iCount = 0;
    uint16_t iFirstFrame = m_pAnims[iAnimation].frame;
    if(iFirstFrame < m_iFrameCount)
    {
        ++iCount;
        uint16_t iFrame = m_pFrames[iFirstFrame].next;
        while(iFrame != iFirstFrame && iFrame < m_iFrameCount && iCount < 1024)
        {
            ++iCount;
            iFrame = m_pFrames[iFrame].next;
        }
    }
    return iCount;
}

uint16_t THAnimations::getUnknownField(size_t iAnimation)
{
    if(iAnimation >= m_iAnimCount)
        return 0;
    return m_pAnims[iAnimation].unknown;
}

bool THAnimations::doesAnimationIncludeFrame(size_t iAnimation, size_t iFrame)
{
    if(iAnimation >= m_iAnimCount || iFrame >= m_iFrameCount)
        return 0;
    uint16_t iFirstFrame = m_pAnims[iAnimation].frame;
    uint16_t iFrameNow = iFirstFrame;
    do
    {
        if(iFrameNow >= m_iFrameCount)
            break;
        if(iFrame == iFrameNow)
            return true;
        iFrameNow = m_pFrames[iFrameNow].next;
    } while(iFrameNow != iFirstFrame);
    return false;
}

Bitmap* THAnimations::getSpriteBitmap(size_t iSprite, bool bComplex)
{
    if(iSprite >= m_iSpriteCount)
        return NULL;

    if(!m_pSpriteBitmaps[iSprite].IsOk())
    {
        th_sprite_t* pSprite = m_pSprites + iSprite;
        ChunkRenderer oRenderer(pSprite->width, pSprite->height);
        (bComplex ? decode_chunks_complex : decode_chunks)(oRenderer, (const unsigned char*)m_pChunks + pSprite->offset, m_iChunkCount - pSprite->offset, 0xFF);
        m_pSpriteBitmaps[iSprite].create(pSprite->width, pSprite->height, oRenderer.getData());
    }

    return m_pSpriteBitmaps + iSprite;
}

uint16_t THAnimations::getFrameFlags(size_t iAnimation, size_t iFrame)
{
    if(iAnimation >= m_iAnimCount)
        return 0;
    uint16_t iFrameIndex = m_pAnims[iAnimation].frame;
    while(iFrame--)
    {
        iFrameIndex = m_pFrames[iFrameIndex].next;
    }
    return m_pFrames[iFrameIndex].flags;
}

void THAnimations::drawFrame(wxImage& imgCanvas, size_t iAnimation, size_t iFrame, const THLayerMask* pMask, wxSize& size, int iXOffset, int iYOffset)
{
    if(iAnimation >= m_iAnimCount)
        return;
    uint16_t iFrameIndex = m_pAnims[iAnimation].frame;
    while(iFrame--)
    {
        iFrameIndex = m_pFrames[iFrameIndex].next;
    }

    th_frame_t* pFrame = m_pFrames + iFrameIndex;
    th_element_t* pElement;
    uint32_t iListIndex = pFrame->list_index;
    int iFarX = 0;
    int iFarY = 0;
    while((pElement = _getElement(iListIndex++)))
    {
        uint16_t iSpriteIndex = pElement->table_position / sizeof(th_sprite_t);
        th_sprite_t* pSprite = m_pSprites + iSpriteIndex;
        int iRight = pElement->offx + pSprite->width;
        int iBottom = pElement->offy + pSprite->height;
        if(iRight > iFarX)
            iFarX = iRight;
        if(iBottom > iFarY)
            iFarY = iBottom;
        if(pMask != NULL && !pMask->isSet(pElement->flags >> 4, pElement->layerid))
            continue;
        getSpriteBitmap(iSpriteIndex)->blit(imgCanvas, pElement->offx + iXOffset, pElement->offy + iYOffset, m_pGhostMaps + m_iGhostMapOffset, m_pColours, pElement->flags & 0xF);
    }
    size.x = iFarX;
    size.y = iFarY;
}

th_element_t* THAnimations::_getElement(uint32_t iListIndex)
{
    if(iListIndex >= m_iElementListCount)
        return NULL;
    uint16_t iElementIndex = m_pElementList[iListIndex];
    if(iElementIndex > m_iElementCount)
        return NULL;
    return m_pElements + iElementIndex;
}

Bitmap::Bitmap()
{
    m_iWidth = 0;
    m_iHeight = 0;
    m_pData = NULL;
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
