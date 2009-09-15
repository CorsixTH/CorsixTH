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
#include "th_gfx.h"
#include "th_map.h"
#include <new>
#include <memory.h>
#include <limits.h>

THFont::THFont()
{
    m_pSpriteSheet = NULL;
    m_iCharSep = 0;
    m_iLineSep = 0;
}

void THFont::setSpriteSheet(THSpriteSheet* pSpriteSheet)
{
    m_pSpriteSheet = pSpriteSheet;
}

void THFont::setSeparation(int iCharSep, int iLineSep)
{
    m_iCharSep = iCharSep;
    m_iLineSep = iLineSep;
}

void THFont::getTextSize(const char* sMessage, size_t iMessageLength, int* pX, int* pY) const
{
    int iX = 0;
    unsigned int iTallest = 0;
    if(iMessageLength != 0 && m_pSpriteSheet != NULL)
    {
        const unsigned int iFirstASCII = 31;
        unsigned int iLastASCII = m_pSpriteSheet->getSpriteCount() + iFirstASCII;
        iX = -m_iCharSep;

        while(iMessageLength > 0)
        {
            unsigned int iChar = *(const unsigned char*)sMessage;
            if(iFirstASCII <= iChar && iChar <= iLastASCII)
            {
                iChar -= iFirstASCII;
                unsigned int iWidth, iHeight;
                m_pSpriteSheet->getSpriteSizeUnchecked(iChar, &iWidth, &iHeight);
                iX += iWidth + m_iCharSep;
                if(iHeight > iTallest)
                    iTallest = iHeight;
            }
            --iMessageLength, ++sMessage;
        }
    }
    if(pX)
        *pX = iX;
    if(pY)
        *pY = (int)iTallest;
}

void THFont::drawText(THRenderTarget* pCanvas, const char* sMessage, size_t iMessageLength, int iX, int iY) const
{
    pCanvas->startNonOverlapping();
    if(iMessageLength != 0 && m_pSpriteSheet != NULL)
    {
        const unsigned int iFirstASCII = 31;
        unsigned int iLastASCII = m_pSpriteSheet->getSpriteCount() + iFirstASCII;

        while(iMessageLength > 0)
        {
            unsigned int iChar = *(const unsigned char*)sMessage;
            if(iFirstASCII <= iChar && iChar <= iLastASCII)
            {
                iChar -= iFirstASCII;
                unsigned int iWidth, iHeight;
                m_pSpriteSheet->drawSprite(pCanvas, iChar, iX, iY, 0);
                m_pSpriteSheet->getSpriteSizeUnchecked(iChar, &iWidth, &iHeight);
                iX += iWidth + m_iCharSep;
            }
            --iMessageLength, ++sMessage;
        }
    }
    pCanvas->finishNonOverlapping();
}

void THFont::drawTextWrapped(THRenderTarget* pCanvas, const char* sMessage, size_t iMessageLength, int iX, int iY, int iWidth) const
{
    if(iMessageLength != 0 && m_pSpriteSheet != NULL)
    {
        const unsigned int iFirstASCII = 31;
        unsigned int iLastASCII = m_pSpriteSheet->getSpriteCount() + iFirstASCII;

        while(iMessageLength > 0)
        {
            const char* sBreakPosition = sMessage + iMessageLength;
            const char* sLastGoodBreakPosition = sBreakPosition;
            int iMsgWidth = -m_iCharSep;
            unsigned int iTallest = 0;

            for(size_t i = 0; i < iMessageLength; ++i)
            {
                unsigned int iChar = (unsigned char)sMessage[i];
                unsigned int iCharWidth = 0, iCharHeight = 0;
                if(iFirstASCII <= iChar && iChar <= iLastASCII)
                {
                    m_pSpriteSheet->getSpriteSizeUnchecked(iChar - iFirstASCII, &iCharWidth, &iCharHeight);
                }
                iMsgWidth += m_iCharSep + iCharWidth;
                if(iChar == ' ')
                    sLastGoodBreakPosition = sMessage + i;
                if(iMsgWidth > iWidth)
                {
                    sBreakPosition = sLastGoodBreakPosition;
                    break;
                }
                if(iCharHeight > iTallest)
                    iTallest = iCharHeight;
            }

            drawText(pCanvas, sMessage, sBreakPosition - sMessage, iX, iY);
            iMessageLength += sMessage - sBreakPosition;
            sMessage = sBreakPosition;
            if(iMessageLength > 0)
            {
                --iMessageLength;
                ++sMessage;
            }
            iY += (int)iTallest + m_iLineSep;
        }
    }
}

THAnimationManager::THAnimationManager()
{
    m_pFirstFrames = NULL;
    m_pFrames = NULL;
    m_pElementList = NULL;
    m_pElements = NULL;
    m_pSpriteSheet = NULL;
    m_iAnimationCount = 0;
    m_iFrameCount = 0;
}

THAnimationManager::~THAnimationManager()
{
    delete[] m_pFirstFrames;
    delete[] m_pFrames;
    delete[] m_pElementList;
    delete[] m_pElements;
}

void THAnimationManager::setSpriteSheet(THSpriteSheet* pSpriteSheet)
{
    m_pSpriteSheet = pSpriteSheet;
}

inline static void _setmin(int& iLeft, int iRight)
{
    if(iRight < iLeft)
        iLeft = iRight;
}

inline static void _setmax(int& iLeft, int iRight)
{
    if(iRight > iLeft)
        iLeft = iRight;
}

bool THAnimationManager::loadFromTHFile(
                        const unsigned char* pStartData, size_t iStartDataLength,
                        const unsigned char* pFrameData, size_t iFrameDataLength,
                        const unsigned char* pListData, size_t iListDataLength,
                        const unsigned char* pElementData, size_t iElementDataLength)
{
    m_iAnimationCount = (unsigned int)(iStartDataLength / sizeof(th_anim_t));
    m_iFrameCount = (unsigned int)(iFrameDataLength / sizeof(th_frame_t));
    unsigned int iListCount = (unsigned int)(iListDataLength / 2);
    m_iElementCount = (unsigned int)(iElementDataLength / sizeof(th_element_t));

    if(m_iAnimationCount == 0 || m_iFrameCount == 0 || iListCount == 0 || m_iElementCount == 0)
    {
        m_iAnimationCount = 0;
        m_iFrameCount = 0;
        return false;
    }

    delete[] m_pFirstFrames; 
    delete[] m_pFrames;
    delete[] m_pElementList;
    delete[] m_pElements;

    m_pFirstFrames = NULL;
    m_pFrames = NULL;
    m_pElementList = NULL;
    m_pElements = NULL;

    m_pFirstFrames = new (std::nothrow) unsigned int[m_iAnimationCount];
    m_pFrames = new (std::nothrow) frame_t[m_iFrameCount];
    m_pElementList = new (std::nothrow) uint16_t[iListCount + 1];
    m_pElements = new (std::nothrow) element_t[m_iElementCount];

    if(m_pFirstFrames == NULL || m_pFrames == NULL || m_pElementList == NULL || m_pElements == NULL)
    {
        m_iAnimationCount = 0;
        m_iFrameCount = 0;
        return false;
    }

    for(unsigned int i = 0; i < m_iAnimationCount; ++i)
    {
        unsigned int iFirstFrame = reinterpret_cast<const th_anim_t*>(pStartData)[i].frame;
        if(iFirstFrame > m_iFrameCount)
            iFirstFrame = 0;
        m_pFirstFrames[i] = iFirstFrame;
    }

    for(unsigned int i = 0; i < m_iFrameCount; ++i)
    {
        const th_frame_t* pFrame = reinterpret_cast<const th_frame_t*>(pFrameData) + i;
        m_pFrames[i].iListIndex = pFrame->list_index < iListCount ? pFrame->list_index : 0;
        m_pFrames[i].iNextFrame = pFrame->next < m_iFrameCount ? pFrame->next : 0;
    }

    memcpy(m_pElementList, pListData, iListCount * 2);
    m_pElementList[iListCount] = 0xFFFF;

    for(unsigned int i = 0; i < m_iElementCount; ++i)
    {
        const th_element_t* pTHElement = reinterpret_cast<const th_element_t*>(pElementData) + i;
        element_t *pElement = m_pElements + i;
        pElement->iSprite = pTHElement->table_position / 6;
        pElement->iFlags = pTHElement->flags & 0xF;
        pElement->iX = static_cast<int>(pTHElement->offx) - 141;
        pElement->iY = static_cast<int>(pTHElement->offy) - 186;
        pElement->iLayer = pTHElement->flags >> 4;
        if(pElement->iLayer > 12)
            pElement->iLayer = 6; // Nothing lives on layer 6
        pElement->iLayerId = pTHElement->layerid;
    }

    unsigned int iSpriteCount = m_pSpriteSheet->getSpriteCount();
    for(unsigned int i = 0; i < m_iFrameCount; ++i)
    {
        frame_t* pFrame = m_pFrames + i;
        pFrame->iBoundingLeft   = INT_MAX;
        pFrame->iBoundingRight  = INT_MIN;
        pFrame->iBoundingTop    = INT_MAX;
        pFrame->iBoundingBottom = INT_MIN;
        unsigned int iListIndex = pFrame->iListIndex;
        for(; ; ++iListIndex)
        {
            uint16_t iElement = m_pElementList[iListIndex];
            if(iElement >= m_iElementCount)
                break;

            element_t* pElement = m_pElements + iElement;
            if(pElement->iSprite >= iSpriteCount)
            {
                continue;
            }

            unsigned int iWidth, iHeight;
            m_pSpriteSheet->getSpriteSizeUnchecked(pElement->iSprite, &iWidth, &iHeight);
            _setmin(pFrame->iBoundingLeft  , pElement->iX);
            _setmin(pFrame->iBoundingTop   , pElement->iY);
            _setmax(pFrame->iBoundingRight , pElement->iX - 1 + (int)iWidth);
            _setmax(pFrame->iBoundingBottom, pElement->iY - 1 + (int)iHeight);
        }
    }

    return true;
}

unsigned int THAnimationManager::getAnimationCount() const
{
    return m_iAnimationCount;
}

unsigned int THAnimationManager::getFrameCount() const
{
    return m_iFrameCount;
}

unsigned int THAnimationManager::getFirstFrame(unsigned int iAnimation) const
{
    if(iAnimation < m_iAnimationCount)
        return m_pFirstFrames[iAnimation];
    else
        return 0;
}

unsigned int THAnimationManager::getNextFrame(unsigned int iFrame) const
{
    if(iFrame < m_iFrameCount)
        return m_pFrames[iFrame].iNextFrame;
    else
        return iFrame;
}

void THAnimationManager::setAnimationAltPaletteMap(unsigned int iAnimation, const unsigned char* pMap)
{
    if(iAnimation >= m_iAnimationCount || m_pSpriteSheet == NULL)
        return;

    unsigned int iFrame = m_pFirstFrames[iAnimation];
    unsigned int iFirstFrame = iFrame;
    do
    {
        unsigned int iListIndex = m_pFrames[iFrame].iListIndex;
        for(; ; ++iListIndex)
        {
            uint16_t iElement = m_pElementList[iListIndex];
            if(iElement >= m_iElementCount)
                break;

            element_t* pElement = m_pElements + iElement;
            m_pSpriteSheet->setSpriteAltPaletteMap(pElement->iSprite, pMap);
        }
        iFrame = m_pFrames[iFrame].iNextFrame;
    } while(iFrame != iFirstFrame);
}

bool THAnimationManager::hitTest(unsigned int iFrame, const THLayers_t& oLayers, int iX, int iY, unsigned long iFlags, int iTestX, int iTestY) const
{
    if(iFrame >= m_iFrameCount)
        return false;

    const frame_t* pFrame = m_pFrames + iFrame;
    iTestX -= iX;
    iTestY -= iY;

    if(iFlags & THDF_FlipHorizontal)
        iTestX = -iTestX;
    if(iTestX < pFrame->iBoundingLeft || iTestX > pFrame->iBoundingRight)
        return false;

    if(iFlags & THDF_FlipVertical)
    {
        if(-iTestY < pFrame->iBoundingTop || -iTestY > pFrame->iBoundingBottom)
            return false;
    }
    else
    {
        if(iTestY < pFrame->iBoundingTop || iTestY > pFrame->iBoundingBottom)
            return false;
    }

    unsigned int iListIndex = pFrame->iListIndex;
    unsigned int iSpriteCount = m_pSpriteSheet->getSpriteCount();
    for(; ; ++iListIndex)
    {
        uint16_t iElement = m_pElementList[iListIndex];
        if(iElement >= m_iElementCount)
            break;

        element_t* pElement = m_pElements + iElement;
        if((pElement->iLayerId != 0 && oLayers.iLayerContents[pElement->iLayer] != pElement->iLayerId)
         || pElement->iSprite >= iSpriteCount)
        {
            continue;
        }

        if(iFlags & THDF_FlipHorizontal)
        {
            unsigned int iWidth, iHeight;
            m_pSpriteSheet->getSpriteSizeUnchecked(pElement->iSprite, &iWidth, &iHeight);
            if(m_pSpriteSheet->hitTestSprite(pElement->iSprite, pElement->iX + iWidth - iTestX,
                iTestY - pElement->iY, pElement->iFlags ^ THDF_FlipHorizontal))
            {
                return true;
            }
        }
        else
        {
            if(m_pSpriteSheet->hitTestSprite(pElement->iSprite, iTestX - pElement->iX,
                iTestY - pElement->iY, pElement->iFlags))
            {
                return true;
            }
        }
    }

    return false;
}

void THAnimationManager::drawFrame(THRenderTarget* pCanvas, unsigned int iFrame, const THLayers_t& oLayers, int iX, int iY, unsigned long iFlags) const
{
    if(iFrame >= m_iFrameCount || m_pSpriteSheet == NULL)
        return;

    unsigned int iSpriteCount = m_pSpriteSheet->getSpriteCount();
    unsigned int iPassOnFlags = iFlags & THDF_AltPalette;

    unsigned int iListIndex = m_pFrames[iFrame].iListIndex;
    for(; ; ++iListIndex)
    {
        uint16_t iElement = m_pElementList[iListIndex];
        if(iElement >= m_iElementCount)
            break;

        element_t* pElement = m_pElements + iElement;
        if((pElement->iLayerId != 0 && oLayers.iLayerContents[pElement->iLayer] != pElement->iLayerId)
         || pElement->iSprite >= iSpriteCount)
        {
            continue;
        }

        if(iFlags & THDF_FlipHorizontal)
        {
            unsigned int iWidth, iHeight;
            m_pSpriteSheet->getSpriteSizeUnchecked(pElement->iSprite, &iWidth, &iHeight);

            m_pSpriteSheet->drawSprite(pCanvas, pElement->iSprite, iX - pElement->iX - iWidth,
                iY + pElement->iY, iPassOnFlags | (pElement->iFlags ^ THDF_FlipHorizontal));
        }
        else
        {
            m_pSpriteSheet->drawSprite(pCanvas, pElement->iSprite,
                iX + pElement->iX, iY + pElement->iY, iPassOnFlags | pElement->iFlags);
        }
    }
}

THChunkRenderer::THChunkRenderer(int width, int height, unsigned char *buffer)
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

THChunkRenderer::~THChunkRenderer()
{
    delete[] m_data;
}

unsigned char* THChunkRenderer::takeData()
{
    unsigned char *buffer = m_data;
    m_data = 0;
    return buffer;
}

void THChunkRenderer::chunkFillToEndOfLine(unsigned char value)
{
    if(m_x != 0 || !m_skip_eol)
    {
        chunkFill(m_width - m_x, value);
    }
    m_skip_eol = false;
}

void THChunkRenderer::chunkFinish(unsigned char value)
{
    chunkFill(static_cast<int>(m_end - m_ptr), value);
}

void THChunkRenderer::chunkFill(int npixels, unsigned char value)
{
    _fixNpixels(npixels);
    if(npixels > 0)
    {
        memset(m_ptr, value, npixels);
        _incrementPosition(npixels);
    }
}

void THChunkRenderer::chunkCopy(int npixels, const unsigned char* data)
{
    _fixNpixels(npixels);
    if(npixels > 0)
    {
        memcpy(m_ptr, data, npixels);
        _incrementPosition(npixels);
    }
}


inline void THChunkRenderer::_fixNpixels(int& npixels) const
{
    if(m_ptr + npixels > m_end)
    {
        npixels = static_cast<int>(m_end - m_ptr);
    }
}

inline void THChunkRenderer::_incrementPosition(int npixels)
{
    m_ptr += npixels;
    m_x += npixels;
    m_y += m_x / m_width;
    m_x = m_x % m_width;
    m_skip_eol = true;
}

void THChunkRenderer::decodeChunks(const unsigned char* data, int datalen, bool complex)
{
    if(complex)
    {
        while(!_isDone() && datalen > 0)
        {
            unsigned char b = *data;
            --datalen;
            ++data;
            if(b == 0)
            {
                chunkFillToEndOfLine(0xFF);
            }
            else if(b < 0x40)
            {
                int amt = b;
                if(datalen < amt)
                    amt = datalen;
                chunkCopy(amt, data);
                data += amt;
                datalen -= amt;
            }
            else if((b & 0xC0) == 0x80)
            {
                chunkFill(b - 0x80, 0xFF);
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
                chunkFill(amt, colour);
            }
        }
    }
    else
    {
        while(!_isDone() && datalen > 0)
        {
            unsigned char b = *data;
            --datalen;
            ++data;
            if(b == 0)
            {
                chunkFillToEndOfLine(0xFF);
            }
            else if(b < 0x80)
            {
                int amt = b;
                if(datalen < amt)
                    amt = datalen;
                chunkCopy(amt, data);
                data += amt;
                datalen -= amt;
            }
            else
            {
                chunkFill(0x100 - b, 0xFF);
            }
        }
    }
    chunkFinish(0xFF);
}

void THAnimation::tick()
{
    m_iFrame = m_pManager->getNextFrame(m_iFrame);
    m_iX += m_iSpeedX;
    m_iY += m_iSpeedY;
}

void THAnimation::draw(THRenderTarget* pCanvas, int iDestX, int iDestY)
{
    if((iFlags & (THDF_Alpha50 | THDF_Alpha75)) == (THDF_Alpha50 | THDF_Alpha75))
        return;

    if(m_pManager)
        m_pManager->drawFrame(pCanvas, m_iFrame, m_oLayers, m_iX + iDestX, m_iY + iDestY, iFlags);
}

bool THAnimation::hitTest(int iDestX, int iDestY, int iTestX, int iTestY)
{
    if((iFlags & (THDF_Alpha50 | THDF_Alpha75)) == (THDF_Alpha50 | THDF_Alpha75))
        return false;
    if(m_pManager == NULL)
        return false;
    return m_pManager->hitTest(m_iFrame, m_oLayers, m_iX + iDestX,
        m_iY + iDestY, iFlags, iTestX, iTestY);
}

static bool THAnimation_HitTest(THDrawable* pSelf, int iDestX, int iDestY, int iTestX, int iTestY)
{
    return reinterpret_cast<THAnimation*>(pSelf)->hitTest(iDestX, iDestY, iTestX, iTestY);
}

static void THAnimation_Draw(THDrawable* pSelf, THRenderTarget* pCanvas, int iDestX, int iDestY)
{
    reinterpret_cast<THAnimation*>(pSelf)->draw(pCanvas, iDestX, iDestY);
}

THAnimation::THAnimation()
{
    fnDraw = THAnimation_Draw;
    fnHitTest = THAnimation_HitTest;
    m_pManager = NULL;
    iFlags = 0;
    m_iAnimation = 0;
    m_iFrame = 0;
    m_iX = 0;
    m_iY = 0;
    m_iSpeedX = 0;
    m_iSpeedY = 0;
    for(int i = 0; i < 13; ++i)
        m_oLayers.iLayerContents[i] = 0;
}

void THAnimation::removeFromTile()
{
    THLinkList::removeFromList();
}

void THAnimation::attachToTile(THLinkList *pMapNode)
{
    removeFromTile();

    if(iFlags & THDF_EarlyList)
    {
        pMapNode = &reinterpret_cast<THMapNode*>(pMapNode)->oEarlyEntities;
    }
    while(pMapNode->pNext && reinterpret_cast<THDrawable*>(pMapNode->pNext)->iFlags & THDF_ListBottom)
        pMapNode = pMapNode->pNext;

    pPrev = pMapNode;
    if(pMapNode->pNext != NULL)
    {
        pNext = pMapNode->pNext;
        pNext->pPrev = this;
    }
    else
    {
        pNext = NULL;
    }
    pMapNode->pNext = this;

}

void THAnimation::setAnimation(THAnimationManager* pManager, unsigned int iAnimation)
{
    m_pManager = pManager;
    m_iAnimation = iAnimation;
    m_iFrame = pManager->getFirstFrame(iAnimation);
}

void THAnimation::setFrame(unsigned int iFrame)
{
    m_iFrame = iFrame;
}

void THAnimation::setLayer(int iLayer, int iId)
{
    if(0 <= iLayer && iLayer <= 12)
    {
        m_oLayers.iLayerContents[iLayer] = (unsigned char)iId;
    }
}
