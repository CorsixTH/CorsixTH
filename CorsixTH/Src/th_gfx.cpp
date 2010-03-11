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
#include "th_sound.h"
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

int THFont::drawTextWrapped(THRenderTarget* pCanvas, const char* sMessage, size_t iMessageLength, int iX, int iY, int iWidth, int iAddedRowDistance, int *iResultingWidth, bool bOnlyTest) const
{
    int iResultingWidthTemp = 0;
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
                {
                    sLastGoodBreakPosition = sMessage + i;
                    if (iMsgWidth > iResultingWidthTemp) iResultingWidthTemp = iMsgWidth;
                }
                if(iMsgWidth > iWidth)
                {
                    sBreakPosition = sLastGoodBreakPosition;
                    break;
                }
                if(iCharHeight > iTallest)
                    iTallest = iCharHeight;
                if (i == iMessageLength - 1)
                    if (iMsgWidth > iResultingWidthTemp) iResultingWidthTemp = iMsgWidth;
            }

            if (!bOnlyTest) drawText(pCanvas, sMessage, sBreakPosition - sMessage, iX, iY);
            iMessageLength += sMessage - sBreakPosition;
            sMessage = sBreakPosition;
            if(iMessageLength > 0)
            {
                --iMessageLength;
                ++sMessage;
            }
            iY += (int)iTallest + m_iLineSep + iAddedRowDistance;
        }
    }
    if (iResultingWidth != NULL) *iResultingWidth = iResultingWidthTemp;
    return iY;
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
        m_pFrames[i].iSound = pFrame->sound;
        m_pFrames[i].iFlags = pFrame->flags;
        // Bounding box fields initialised later
        m_pFrames[i].iMarkerX = 0;
        m_pFrames[i].iMarkerY = 0;
        m_pFrames[i].iSecondaryMarkerX = 0;
        m_pFrames[i].iSecondaryMarkerY = 0;
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

bool THAnimationManager::setFrameMarker(unsigned int iFrame, int iX, int iY)
{
    if(iFrame >= m_iFrameCount)
        return false;
    m_pFrames[iFrame].iMarkerX = iX;
    m_pFrames[iFrame].iMarkerY = iY;
    return true;
}

bool THAnimationManager::setFrameSecondaryMarker(unsigned int iFrame, int iX, int iY)
{
    if(iFrame >= m_iFrameCount)
        return false;
    m_pFrames[iFrame].iSecondaryMarkerX = iX;
    m_pFrames[iFrame].iSecondaryMarkerY = iY;
    return true;
}

bool THAnimationManager::getFrameMarker(unsigned int iFrame, int* pX, int* pY)
{
    if(iFrame >= m_iFrameCount)
        return false;
    *pX = m_pFrames[iFrame].iMarkerX;
    *pY = m_pFrames[iFrame].iMarkerY;
    return true;
}

bool THAnimationManager::getFrameSecondaryMarker(unsigned int iFrame, int* pX, int* pY)
{
    if(iFrame >= m_iFrameCount)
        return false;
    *pX = m_pFrames[iFrame].iSecondaryMarkerX;
    *pY = m_pFrames[iFrame].iSecondaryMarkerY;
    return true;
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

    if(iFlags & THDF_BoundBoxHitTest)
        return true;

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
            // Some animations involving doctors (i.e. #72, #74, maybe others)
            // only provide versions for heads W1 and B1, not W2 and B2. The
            // quickest way to fix this is this dirty hack here, which draws
            // the W1 layer as well as W2 if W2 is being used, and similarly
            // for B1 / B2. A better fix would be to go into each animation
            // which needs it, and duplicate the W1 / B1 layers to W2 / B2.
            if(pElement->iLayer == 5 && oLayers.iLayerContents[5] - 4 == pElement->iLayerId)
                /* don't skip */;
            else
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

unsigned int THAnimationManager::getFrameSound(unsigned int iFrame)
{
    if(iFrame < m_iFrameCount)
        return m_pFrames[iFrame].iSound;
    else
        return 0;
}

void THAnimationManager::getFrameExtent(unsigned int iFrame, const THLayers_t& oLayers, int* pMinX, int* pMaxX, int* pMinY, int* pMaxY, unsigned long iFlags) const
{
    int iMinX = INT_MAX;
    int iMaxX = INT_MIN;
    int iMinY = INT_MAX;
    int iMaxY = INT_MIN;
    if(iFrame < m_iFrameCount && m_pSpriteSheet != NULL)
    {
        unsigned int iSpriteCount = m_pSpriteSheet->getSpriteCount();
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

            int iX = pElement->iX;
            int iY = pElement->iY;
            unsigned int iWidth_, iHeight_;
            m_pSpriteSheet->getSpriteSizeUnchecked(pElement->iSprite, &iWidth_, &iHeight_);
            int iWidth = static_cast<int>(iWidth_);
            int iHeight = static_cast<int>(iHeight_);
            if(iFlags & THDF_FlipHorizontal)
                iX = -(iX + iWidth);
            if(iX < iMinX)
                iMinX = iX;
            if(iY < iMinY)
                iMinY = iY;
            if(iX + iWidth + 1 > iMaxX)
                iMaxX = iX + iWidth + 1;
            if(iY + iHeight + 1 > iMaxY)
                iMaxY = iY + iHeight + 1;
        }
    }
    if(pMinX)
        *pMinX = iMinX;
    if(pMaxX)
        *pMaxX = iMaxX;
    if(pMinY)
        *pMinY = iMinY;
    if(pMaxY)
        *pMaxY = iMaxY;
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

void THAnimation::draw(THRenderTarget* pCanvas, int iDestX, int iDestY)
{
    if((iFlags & (THDF_Alpha50 | THDF_Alpha75)) == (THDF_Alpha50 | THDF_Alpha75))
        return;

    m_iLastX = m_iX + iDestX;
    m_iLastY = m_iY + iDestY;
    if(m_pManager)
    {
        if(iFlags & THDF_Crop)
        {
            THClipRect rcOld, rcNew;
            pCanvas->getClipRect(&rcOld);
            rcNew.y = rcOld.y;
            rcNew.h = rcOld.h;
            if(m_iCropColumn == 0)
            {
                rcNew.x = m_iX + iDestX - 32;
                rcNew.w = 64;
            }
            else if(m_iCropColumn > 0)
            {
                rcNew.x = m_iX + iDestX + m_iCropColumn * 32;
                rcNew.w = 32;
            }
            else
            {
                rcNew.x = m_iX + iDestX + (m_iCropColumn - 1) * 32;
                rcNew.w = 32;
            }
            IntersectTHClipRect(rcNew, rcOld);
            pCanvas->setClipRect(&rcNew);
            m_pManager->drawFrame(pCanvas, m_iFrame, m_oLayers, m_iX + iDestX,
                                  m_iY + iDestY, iFlags);
            pCanvas->setClipRect(&rcOld);
        }
        else
            m_pManager->drawFrame(pCanvas, m_iFrame, m_oLayers, m_iX + iDestX,
                                  m_iY + iDestY, iFlags);
    }
}

void THAnimation::drawChild(THRenderTarget* pCanvas, int iDestX, int iDestY)
{
    if((iFlags & (THDF_Alpha50 | THDF_Alpha75)) == (THDF_Alpha50 | THDF_Alpha75))
        return;
    if((m_pParent->iFlags & (THDF_Alpha50 | THDF_Alpha75)) == (THDF_Alpha50 | THDF_Alpha75))
        return;
    if(!m_pParent->getMarker(&m_iLastX, &m_iLastY))
    {
        m_iLastX = 0;
        m_iLastY = 0;
    }
    m_iLastX += m_iX + iDestX;
    m_iLastY += m_iY + iDestY;
    if(m_pManager)
        m_pManager->drawFrame(pCanvas, m_iFrame, m_oLayers, m_iLastX, m_iLastY, iFlags);
}

bool THAnimation::hitTestChild(int iDestX, int iDestY, int iTestX, int iTestY)
{
    // TODO
    return false;
}

static void CalculateMorphRect(const THClipRect& rcOriginal, THClipRect& rcMorph, int iYLow, int iYHigh)
{
    rcMorph = rcOriginal;
    if(rcMorph.y < iYLow)
    {
        rcMorph.h += rcMorph.y - iYLow;
        rcMorph.y = iYLow;
    }
    if(rcMorph.y + rcMorph.h >= iYHigh)
    {
         rcMorph.h = iYHigh - rcMorph.y - 1;
    }
}

void THAnimation::drawMorph(THRenderTarget* pCanvas, int iDestX, int iDestY)
{
    if((iFlags & (THDF_Alpha50 | THDF_Alpha75)) == (THDF_Alpha50 | THDF_Alpha75))
        return;

    if(!m_pManager)
        return;

    THClipRect oClipRect;
    pCanvas->getClipRect(&oClipRect);
    THClipRect oMorphRect;
    CalculateMorphRect(oClipRect, oMorphRect, m_iY + iDestY + m_pMorphTarget->m_iX, m_iY + iDestY + m_pMorphTarget->m_iY + 1);
    pCanvas->setClipRect(&oMorphRect);
    m_pManager->drawFrame(pCanvas, m_iFrame, m_oLayers, m_iX + iDestX, m_iY + iDestY, iFlags);
    CalculateMorphRect(oClipRect, oMorphRect, m_iY + iDestY + m_pMorphTarget->m_iY, m_iY + iDestY + m_pMorphTarget->m_iSpeedX);
    pCanvas->setClipRect(&oMorphRect);
    m_pManager->drawFrame(pCanvas, m_pMorphTarget->m_iFrame, m_pMorphTarget->m_oLayers, m_iX + iDestX, m_iY + iDestY, m_pMorphTarget->iFlags);
    pCanvas->setClipRect(&oClipRect);
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

bool THAnimation::hitTestMorph(int iDestX, int iDestY, int iTestX, int iTestY)
{
    if((iFlags & (THDF_Alpha50 | THDF_Alpha75)) == (THDF_Alpha50 | THDF_Alpha75))
        return false;
    if(m_pManager == NULL)
        return false;
    return m_pManager->hitTest(m_iFrame, m_oLayers, m_iX + iDestX,
        m_iY + iDestY, iFlags, iTestX, iTestY) || m_pMorphTarget->hitTest(
        iDestX, iDestY, iTestX, iTestY);
}

static bool THAnimation_HitTestChild(THDrawable* pSelf, int iDestX, int iDestY, int iTestX, int iTestY)
{
    return reinterpret_cast<THAnimation*>(pSelf)->hitTestChild(iDestX, iDestY, iTestX, iTestY);
}

static void THAnimation_DrawChild(THDrawable* pSelf, THRenderTarget* pCanvas, int iDestX, int iDestY)
{
    reinterpret_cast<THAnimation*>(pSelf)->drawChild(pCanvas, iDestX, iDestY);
}

static bool THAnimation_HitTestMorph(THDrawable* pSelf, int iDestX, int iDestY, int iTestX, int iTestY)
{
    return reinterpret_cast<THAnimation*>(pSelf)->hitTestMorph(iDestX, iDestY, iTestX, iTestY);
}

static void THAnimation_DrawMorph(THDrawable* pSelf, THRenderTarget* pCanvas, int iDestX, int iDestY)
{
    reinterpret_cast<THAnimation*>(pSelf)->drawMorph(pCanvas, iDestX, iDestY);
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
    m_pMorphTarget = NULL;
    iFlags = 0;
    m_iAnimation = 0;
    m_iFrame = 0;
    m_iX = 0;
    m_iY = 0;
    m_iCropColumn = 0;
    m_iSpeedX = 0;
    m_iSpeedY = 0;
    m_iLastX = INT_MAX;
    m_iLastY = INT_MAX;
    for(int i = 0; i < 13; ++i)
        m_oLayers.iLayerContents[i] = 0;
}

void THAnimation::persist(LuaPersistWriter *pWriter) const
{
    lua_State *L = pWriter->getStack();

    // Write the next chained thing
    lua_rawgeti(L, LUA_ENVIRONINDEX, 2);
    lua_pushlightuserdata(L, pNext);
    lua_rawget(L, -2);
    pWriter->writeStackObject(-1);
    lua_pop(L, 2);

    // Write the THDrawable fields
    pWriter->writeVUInt(iFlags);
    if(fnDraw == THAnimation_Draw && fnHitTest == THAnimation_HitTest)
        pWriter->writeVUInt(1);
    else if(fnDraw == THAnimation_DrawChild && fnHitTest == THAnimation_HitTestChild)
        pWriter->writeVUInt(2);
    else if(fnDraw == THAnimation_DrawMorph && fnHitTest == THAnimation_HitTestMorph)
        pWriter->writeVUInt(3);
    else
        pWriter->writeVUInt(0);

    // Write the simple fields
    pWriter->writeVUInt(m_iAnimation);
    pWriter->writeVUInt(m_iFrame);
    pWriter->writeVInt(m_iX);
    pWriter->writeVInt(m_iY);
    pWriter->writeVInt(m_iLastX);
    pWriter->writeVInt(m_iLastY);
    if(iFlags & THDF_Crop)
        pWriter->writeVInt(m_iCropColumn);

    // Write the unioned fields
    if(fnDraw != THAnimation_DrawChild)
    {
        pWriter->writeVInt(m_iSpeedX);
        pWriter->writeVInt(m_iSpeedY);
    }
    else
    {
        lua_rawgeti(L, LUA_ENVIRONINDEX, 2);
        lua_pushlightuserdata(L, m_pParent);
        lua_rawget(L, -2);
        pWriter->writeStackObject(-1);
        lua_pop(L, 2);
    }

    // Write the layers
    int iNumLayers = 13;
    for( ; iNumLayers >= 1; --iNumLayers)
    {
        if(m_oLayers.iLayerContents[iNumLayers - 1] != 0)
            break;
    }
    pWriter->writeVUInt(iNumLayers);
    pWriter->writeByteStream(m_oLayers.iLayerContents, iNumLayers);
}

void THAnimation::depersist(LuaPersistReader *pReader)
{
    lua_State *L = pReader->getStack();

    do
    {
        // Read the chain
        if(!pReader->readStackObject())
            break;
        pNext = reinterpret_cast<THLinkList*>(lua_touserdata(L, -1));
        if(pNext)
            pNext->pPrev = this;
        lua_pop(L, 1);

        // Read THDrawable fields
        if(!pReader->readVUInt(iFlags))
            break;
        int iFunctionSet;
        if(!pReader->readVUInt(iFunctionSet))
            break;
        switch(iFunctionSet)
        {
        case 1:
            fnDraw = THAnimation_Draw;
            fnHitTest = THAnimation_HitTest;
            break;
        case 2:
            fnDraw = THAnimation_DrawChild;
            fnHitTest = THAnimation_HitTestChild;
            break;
        case 3:
            fnDraw = THAnimation_DrawMorph;
            fnHitTest = THAnimation_HitTestMorph;
            break;
        default:
            pReader->setError(lua_pushfstring(L, "Unknown animation function set #%i", iFunctionSet));
            return;
        }

        // Read the simple fields
        if(!pReader->readVUInt(m_iAnimation))
            break;
        if(!pReader->readVUInt(m_iFrame))
            break;
        if(!pReader->readVInt(m_iX))
            break;
        if(!pReader->readVInt(m_iY))
            break;
        if(!pReader->readVInt(m_iLastX))
            break;
        if(!pReader->readVInt(m_iLastY))
            break;
        if(iFlags & THDF_Crop)
        {
            if(!pReader->readVInt(m_iCropColumn))
                break;
        }
        else
            m_iCropColumn = 0;

        // Read the unioned fields
        if(fnDraw != THAnimation_DrawChild)
        {
            if(!pReader->readVInt(m_iSpeedX))
                break;
            if(!pReader->readVInt(m_iSpeedY))
                break;
        }
        else
        {
            if(!pReader->readStackObject())
                break;
            m_pParent = (THAnimation*)lua_touserdata(L, -1);
            lua_pop(L, 1);
        }

        // Read the layers
        memset(m_oLayers.iLayerContents, 0, sizeof(m_oLayers.iLayerContents));
        int iNumLayers;
        if(!pReader->readVUInt(iNumLayers))
            break;
        if(iNumLayers > 13)
        {
            if(!pReader->readByteStream(m_oLayers.iLayerContents, 13))
                break;
            if(!pReader->readByteStream(NULL, iNumLayers - 13))
                break;
        }
        else
        {
            if(!pReader->readByteStream(m_oLayers.iLayerContents, iNumLayers))
                break;
        }

        // Fix the m_pAnimator field
        luaT_getenvfield(L, 2, "animator");
        m_pManager = (THAnimationManager*)lua_touserdata(L, -1);
        lua_pop(L, 1);

        return;
    } while(false);

    pReader->setError("Cannot depersist THAnimation instance");
}

void THAnimation::tick()
{
    m_iFrame = m_pManager->getNextFrame(m_iFrame);
    if(fnDraw != THAnimation_DrawChild)
    {
        m_iX += m_iSpeedX;
        m_iY += m_iSpeedY;
    }
    if(m_pMorphTarget)
    {
        m_pMorphTarget->m_iY += m_pMorphTarget->m_iSpeedY;
        if(m_pMorphTarget->m_iY < m_pMorphTarget->m_iX)
            m_pMorphTarget->m_iY = m_pMorphTarget->m_iX;
    }

    if(m_iLastX != INT_MAX)
    {
        unsigned int iSound = m_pManager->getFrameSound(m_iFrame);
        if(iSound)
        {
            THSoundEffects *pSounds = THSoundEffects::getSingleton();
            if(pSounds)
                pSounds->playSoundAt(iSound, m_iLastX, m_iLastY);
        }
        m_iLastX = INT_MAX;
    }
}

void THAnimation::removeFromTile()
{
    THLinkList::removeFromList();
}

void THAnimation::attachToTile(THMapNode *pMapNode)
{
    removeFromTile();

    THLinkList *pList;
    if(iFlags & THDF_EarlyList)
        pList = &pMapNode->oEarlyEntities;
    else
        pList = pMapNode;
    while(pList->pNext && reinterpret_cast<THDrawable*>(pList->pNext)->iFlags & THDF_ListBottom)
        pList = pList->pNext;

    pPrev = pList;
    if(pList->pNext != NULL)
    {
        pNext = pList->pNext;
        pNext->pPrev = this;
    }
    else
    {
        pNext = NULL;
    }
    pList->pNext = this;
}

void THAnimation::setParent(THAnimation *pParent)
{
    removeFromTile();
    if(pParent == NULL)
    {
        fnDraw = THAnimation_Draw;
        fnHitTest = THAnimation_HitTest;
        m_iSpeedX = 0;
        m_iSpeedY = 0;
    }
    else
    {
        fnDraw = THAnimation_DrawChild;
        fnHitTest = THAnimation_HitTestChild;
        m_pParent = pParent;
        pNext = m_pParent->pNext;
        if(pNext)
            pNext->pPrev = this;
        pPrev = m_pParent;
        m_pParent->pNext = this;
    }
}

void THAnimation::setAnimation(THAnimationManager* pManager, unsigned int iAnimation)
{
    m_pManager = pManager;
    m_iAnimation = iAnimation;
    m_iFrame = pManager->getFirstFrame(iAnimation);
    if(m_pMorphTarget)
    {
        m_pMorphTarget = NULL;
        fnDraw = THAnimation_Draw;
        fnHitTest = THAnimation_HitTest;
    }
}

bool THAnimation::getMarker(int* pX, int* pY)
{
    if(!m_pManager || !m_pManager->getFrameMarker(m_iFrame, pX, pY))
        return false;
    if(iFlags & THDF_FlipHorizontal)
        *pX = -*pX;
    *pX += m_iX;
    *pY += m_iY + 16;
    return true;
}

bool THAnimation::getSecondaryMarker(int* pX, int* pY)
{
    if(!m_pManager || !m_pManager->getFrameSecondaryMarker(m_iFrame, pX, pY))
        return false;
    if(iFlags & THDF_FlipHorizontal)
        *pX = -*pX;
    *pX += m_iX;
    *pY += m_iY + 16;
    return true;
}

static int GetAnimationDurationAndExtent(THAnimationManager *pManager,
                                         unsigned int iFrame,
                                         const THLayers_t& oLayers,
                                         int* pMinY, int* pMaxY,
                                         unsigned long iFlags)
{
    int iMinY = INT_MAX;
    int iMaxY = INT_MIN;
    int iDuration = 0;
    unsigned int iCurFrame = iFrame;
    do
    {
        int iFrameMinY;
        int iFrameMaxY;
        pManager->getFrameExtent(iCurFrame, oLayers, NULL, NULL, &iFrameMinY, &iFrameMaxY, iFlags);
        if(iFrameMinY < iMinY)
            iMinY = iFrameMinY;
        if(iFrameMaxY > iMaxY)
            iMaxY = iFrameMaxY;
        iCurFrame = pManager->getNextFrame(iCurFrame);
        ++iDuration;
    } while(iCurFrame != iFrame);
    if(pMinY)
        *pMinY = iMinY;
    if(pMaxY)
        *pMaxY = iMaxY;
    return iDuration;
}

void THAnimation::setMorphTarget(THAnimation *pMorphTarget)
{
    m_pMorphTarget = pMorphTarget;
    fnDraw = THAnimation_DrawMorph;
    fnHitTest = THAnimation_HitTestMorph;

    /* Morphing is the process by which two animations are combined to give a
    single animation of one animation turning into another. At the moment,
    morphing is done by having a y value, above which the original animation is
    rendered, and below which the new animation is rendered, and having the y
    value move upward a bit each frame.
    One example of where this is used is when transparent or invisible patients
    are cured at the pharmacy cabinet.
    The process of morphing requires four state variables, which are stored in
    the morph target animation:
      * The y value top limit - m_pMorphTarget->m_iX
      * The y value threshold - m_pMorphTarget->m_iY
      * The y value bottom limit - m_pMorphTarget->m_iSpeedX
      * The y value increment per frame - m_pMorphTarget->m_iSpeedY
    This obviously means that the morph target should not be ticked or rendered
    as it's position and speed contain other values.
    */

    int iOrigMinY, iOrigMaxY;
    int iMorphMinY, iMorphMaxY;

    int iOriginalDuration = GetAnimationDurationAndExtent(m_pManager,
        m_iFrame, m_oLayers, &iOrigMinY, &iOrigMaxY, iFlags);
    int iMorphDuration = GetAnimationDurationAndExtent(m_pMorphTarget->m_pManager,
        m_pMorphTarget->m_iFrame, m_pMorphTarget->m_oLayers, &iMorphMinY, &iMorphMaxY, m_pMorphTarget->iFlags);
    if(iMorphDuration > iOriginalDuration)
        iMorphDuration = iOriginalDuration;

    if(iOrigMinY < iMorphMinY)
        m_pMorphTarget->m_iX = iOrigMinY;
    else
        m_pMorphTarget->m_iX = iMorphMinY;

    if(iOrigMaxY > iMorphMaxY)
        m_pMorphTarget->m_iSpeedX = iOrigMaxY;
    else
        m_pMorphTarget->m_iSpeedX = iMorphMaxY;

    m_pMorphTarget->m_iSpeedY = (m_pMorphTarget->m_iX - m_pMorphTarget->m_iSpeedX - iMorphDuration + 1) / iMorphDuration;
    m_pMorphTarget->m_iY = m_pMorphTarget->m_iSpeedX;
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
