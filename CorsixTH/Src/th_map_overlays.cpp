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

THMapOverlay::~THMapOverlay()
{
}

THMapOverlayPair::THMapOverlayPair()
{
    m_pFirst = NULL;
    m_pSecond = NULL;
    m_bOwnFirst = false;
    m_bOwnSecond = false;
}

THMapOverlayPair::~THMapOverlayPair()
{
    setFirst(NULL, false);
    setSecond(NULL, false);
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

void THMapTextOverlay::setBackgroundSprite(unsigned int iSprite)
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
        _drawText(pCanvas, iCanvasX, iCanvasY, "%s",
            getText(pMap, iNodeX, iNodeY));
    }
}

const char* THMapPositionsOverlay::getText(const THMap* pMap, int iNodeX, int iNodeY)
{
    sprintf(m_sBuffer, "%i,%i", iNodeX + 1, iNodeY + 1);
    return m_sBuffer;
}

THMapTypicalOverlay::THMapTypicalOverlay()
{
    m_pSprites = NULL;
    m_pFont = NULL;
    m_bOwnsSprites = false;
    m_bOwnsFont = false;
}

THMapTypicalOverlay::~THMapTypicalOverlay()
{
    setSprites(NULL, false);
    setFont(NULL, false);
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
        if(pNode->iFlags & THMN_Passable)
            m_pSprites->drawSprite(pCanvas, 3, iCanvasX, iCanvasY, 0);
        if(pNode->iFlags & THMN_Hospital)
            m_pSprites->drawSprite(pCanvas, 8, iCanvasX, iCanvasY, 0);
        if(pNode->iFlags & THMN_Buildable)
            m_pSprites->drawSprite(pCanvas, 9, iCanvasX, iCanvasY, 0);
#define TRAVEL(flag, dx, dy, sprite) \
        if(pNode->iFlags & flag && pMap->getNode(iNodeX + dx, iNodeY + dy)-> \
            iFlags & THMN_Passable) \
        { \
            m_pSprites->drawSprite(pCanvas, sprite, iCanvasX, iCanvasY, 0); \
        }
        TRAVEL(THMN_CanTravelN,  0, -1, 4);
        TRAVEL(THMN_CanTravelE,  1,  0, 5);
        TRAVEL(THMN_CanTravelS,  0,  1, 6);
        TRAVEL(THMN_CanTravelW, -1,  0, 7);
#undef TRAVEL
    }
    if(m_pFont)
    {
        if(pNode->iFlags >> 24)
            _drawText(pCanvas, iCanvasX, iCanvasY - 8, "T%i", (int)(pNode->iFlags >> 24));
        if(pNode->iRoomId)
            _drawText(pCanvas, iCanvasX, iCanvasY + 8, "R%i", (int)pNode->iRoomId);
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
        _drawText(pCanvas, iCanvasX, iCanvasY, "%i", (int)pNode->iParcelId);
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
        const char* sFormat, ...)
{
    char sBuffer[64];
    va_list args;
    va_start(args, sFormat);
    size_t iLen = (int)vsprintf(sBuffer, sFormat, args);
    va_end(args);
    int iW, iH;
    m_pFont->getTextSize(sBuffer, iLen, &iW, &iH);
    m_pFont->drawText(pCanvas, sBuffer, iLen, iX + (64 - iW) / 2,
        iY + (32 - iH) / 2);
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
