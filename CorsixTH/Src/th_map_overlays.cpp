/*
Copyright (c) 2010 Peter "Corsix" Cawley

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

#include "th_map_overlays.h"
#include "th_gfx.h"
#include "th_map.h"
#include <sstream>

THMapOverlayPair::THMapOverlayPair()
{
    m_pFirst = nullptr;
    m_pSecond = nullptr;
    m_bOwnFirst = false;
    m_bOwnSecond = false;
}

THMapOverlayPair::~THMapOverlayPair()
{
    setFirst(nullptr, false);
    setSecond(nullptr, false);
}

void THMapOverlayPair::setFirst(THMapOverlay* pOverlay, bool bTakeOwnership)
{
    if(m_pFirst && m_bOwnFirst)
        delete m_pFirst;
    m_pFirst = pOverlay;
    m_bOwnFirst = bTakeOwnership;
}

void THMapOverlayPair::setSecond(THMapOverlay* pOverlay, bool bTakeOwnership)
{
    if(m_pSecond && m_bOwnSecond)
        delete m_pSecond;
    m_pSecond = pOverlay;
    m_bOwnSecond = bTakeOwnership;
}

void THMapOverlayPair::drawCell(THRenderTarget* pCanvas, int iCanvasX,
                                int iCanvasY, const THMap* pMap, int iNodeX,
                                int iNodeY)
{
    if(m_pFirst)
        m_pFirst->drawCell(pCanvas, iCanvasX, iCanvasY, pMap, iNodeX, iNodeY);
    if(m_pSecond)
        m_pSecond->drawCell(pCanvas, iCanvasX, iCanvasY, pMap, iNodeX, iNodeY);
}

THMapTextOverlay::THMapTextOverlay()
{
    m_iBackgroundSprite = 0;
}

void THMapTextOverlay::setBackgroundSprite(size_t iSprite)
{
    m_iBackgroundSprite = iSprite;
}

void THMapTextOverlay::drawCell(THRenderTarget* pCanvas, int iCanvasX,
                                int iCanvasY, const THMap* pMap, int iNodeX,
                                int iNodeY)
{
    if(m_pSprites && m_iBackgroundSprite)
    {
        m_pSprites->drawSprite(pCanvas, m_iBackgroundSprite, iCanvasX,
            iCanvasY, 0);
    }
    if(m_pFont)
    {
        _drawText(pCanvas, iCanvasX, iCanvasY, getText(pMap, iNodeX, iNodeY));
    }
}

const std::string THMapPositionsOverlay::getText(const THMap* pMap, int iNodeX, int iNodeY)
{
    std::ostringstream str;
    str << iNodeX + 1 << ',' << iNodeY + 1;
    return str.str();
}

THMapTypicalOverlay::THMapTypicalOverlay()
{
    m_pSprites = nullptr;
    m_pFont = nullptr;
    m_bOwnsSprites = false;
    m_bOwnsFont = false;
}

THMapTypicalOverlay::~THMapTypicalOverlay()
{
    setSprites(nullptr, false);
    setFont(nullptr, false);
}

void THMapFlagsOverlay::drawCell(THRenderTarget* pCanvas, int iCanvasX,
                                 int iCanvasY, const THMap* pMap, int iNodeX,
                                 int iNodeY)
{
    const THMapNode *pNode = pMap->getNode(iNodeX, iNodeY);
    if(!pNode)
        return;
    if(m_pSprites)
    {
        if(pNode->flags.passable)
            m_pSprites->drawSprite(pCanvas, 3, iCanvasX, iCanvasY, 0);
        if(pNode->flags.hospital)
            m_pSprites->drawSprite(pCanvas, 8, iCanvasX, iCanvasY, 0);
        if(pNode->flags.buildable)
            m_pSprites->drawSprite(pCanvas, 9, iCanvasX, iCanvasY, 0);
        if(pNode->flags.can_travel_n && pMap->getNode(iNodeX, iNodeY - 1)->flags.passable)
        {
            m_pSprites->drawSprite(pCanvas, 4, iCanvasX, iCanvasY, 0);
        }
        if(pNode->flags.can_travel_e && pMap->getNode(iNodeX + 1, iNodeY)->flags.passable)
        {
            m_pSprites->drawSprite(pCanvas, 5, iCanvasX, iCanvasY, 0);
        }
        if(pNode->flags.can_travel_s && pMap->getNode(iNodeX, iNodeY + 1)->flags.passable)
        {
            m_pSprites->drawSprite(pCanvas, 6, iCanvasX, iCanvasY, 0);
        }
        if(pNode->flags.can_travel_w && pMap->getNode(iNodeX - 1, iNodeY)->flags.passable)
        {
            m_pSprites->drawSprite(pCanvas, 7, iCanvasX, iCanvasY, 0);
        }
    }
    if(m_pFont)
    {
        if(!pNode->objects.empty())
        {
            std::ostringstream str;
            str << 'T' << static_cast<int>(pNode->objects.front());
            _drawText(pCanvas, iCanvasX, iCanvasY - 8, str.str());
        }
        if(pNode->iRoomId)
        {
            std::ostringstream str;
            str << 'R' << static_cast<int>(pNode->iRoomId);
            _drawText(pCanvas, iCanvasX, iCanvasY + 8, str.str());
        }
    }
}

void THMapParcelsOverlay::drawCell(THRenderTarget* pCanvas, int iCanvasX,
                                   int iCanvasY, const THMap* pMap, int iNodeX,
                                   int iNodeY)
{
    const THMapNode *pNode = pMap->getNode(iNodeX, iNodeY);
    if(!pNode)
        return;
    if(m_pFont)
        _drawText(pCanvas, iCanvasX, iCanvasY, std::to_string((int)pNode->iParcelId));
    if(m_pSprites)
    {
        uint16_t iParcel = pNode->iParcelId;
#define DIR(dx, dy, sprite) \
        pNode = pMap->getNode(iNodeX + dx, iNodeY + dy); \
        if(!pNode || pNode->iParcelId != iParcel) \
            m_pSprites->drawSprite(pCanvas, sprite, iCanvasX, iCanvasY, 0)
        DIR( 0, -1, 18);
        DIR( 1,  0, 19);
        DIR( 0,  1, 20);
        DIR(-1,  0, 21);
#undef DIR
    }
}


void THMapTypicalOverlay::_drawText(THRenderTarget* pCanvas, int iX, int iY,
        std::string str)
{
    THFontDrawArea oArea = m_pFont->getTextSize(str.c_str(), str.length());
    m_pFont->drawText(pCanvas, str.c_str(), str.length(), iX + (64 - oArea.iEndX) / 2,
        iY + (32 - oArea.iEndY) / 2);
}

void THMapTypicalOverlay::setSprites(THSpriteSheet* pSheet, bool bTakeOwnership)
{
    if(m_pSprites && m_bOwnsSprites)
        delete m_pSprites;
    m_pSprites = pSheet;
    m_bOwnsSprites = bTakeOwnership;
}

void THMapTypicalOverlay::setFont(THFont* pFont, bool bTakeOwnership)
{
    if(m_pFont && m_bOwnsFont)
        delete m_pFont;
    m_pFont = pFont;
    m_bOwnsFont = bTakeOwnership;
}
