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
#include "th_map.h"
#include "th_gfx.h"
#include <SDL.h>
#include <new>

THMapNode::THMapNode()
{
    iBlock[0] = 0;
    iBlock[1] = 0;
    iBlock[2] = 0;
    iBlock[3] = 0;
    iFlags = 0;
}

THMap::THMap()
{
    m_iWidth = 0;
    m_iHeight = 0;
    m_pCells = NULL;
    m_pBlocks = NULL;
}

THMap::~THMap()
{
    delete[] m_pCells;
}

bool THMap::setSize(int iWidth, int iHeight)
{
    if(iWidth <= 0 || iHeight <= 0)
        return false;

    delete[] m_pCells;
    m_iWidth = iWidth;
    m_iHeight = iHeight;
    m_pCells = new (std::nothrow) THMapNode[iWidth * iHeight];

    if(m_pCells == NULL)
    {
        m_iWidth = 0;
        m_iHeight = 0;
        return false;
    }

    return true;
}

// NB: http://connection-endpoint.de/wiki/doku.php?id=format_specification#map
// gives a (slightly) incorrect array, which is why it differs from this one.
static const unsigned char gs_iTHMapBlockLUT[256] = {
    0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C,
    0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18,
    0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20, 0x21, 0x22, 0x23, 0x24,
    0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30,
    0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C,
    0x3D, 0x3E, 0x3F, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48,
    0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x50, 0x52, 0x53, 0x54, 0x55,
    0x56, 0x57, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F, 0x60, 0x61,
    0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D,
    0x6E, 0x6F, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79,
    0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F, 0x80, 0x81, 0x84, 0x85, 0x88, 0x89,
    0x8C, 0x8D, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x8E, 0x8F, 0x00, 0x00,
    0x00, 0x00, 0x8E, 0x8F, 0xD5, 0xD6, 0x9C, 0xCC, 0xCD, 0xCE, 0xCF, 0xD0,
    0xD1, 0xD2, 0xD3, 0xD4, 0xB3, 0xAF, 0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5,
    0xB6, 0xB7, 0xB8, 0xB9, 0xB3, 0xB3, 0xB4, 0xB4, 0xBA, 0xBB, 0xBC, 0xBD,
    0xBE, 0xBF, 0xC0, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xC9,
    0xCA, 0xCB, 0x00, 0x82, 0x83, 0x86, 0x87, 0x8A, 0x8B, 0x92, 0x93, 0x94,
    0x95, 0x96, 0x97, 0x98, 0x99, 0x9A, 0x9B, 0x00, 0x9D, 0x9E, 0x9F, 0xA0,
    0xA1, 0xA2, 0xA3, 0xA4, 0xD7, 0xD8, 0xD9, 0xDA, 0xDB, 0xDC, 0xDD, 0xDE,
    0xDF, 0xE0, 0xE1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00
};

bool THMap::loadFromTHFile(const unsigned char* pData, size_t iDataLength)
{
    if(iDataLength < 163948 || !setSize(128, 128))
        return false;

    THMapNode *pNode = m_pCells;
    const uint16_t *pParcel = reinterpret_cast<const uint16_t*>(pData + 131106);
    pData += 34;
    for(int iY = 0; iY < 128; ++iY)
    {
        for(int iX = 0; iX < 128; ++iX, ++pNode, pData += 8, ++pParcel)
        {
            unsigned char iBaseTile = gs_iTHMapBlockLUT[pData[2]];
            pNode->iFlags = THMN_CanTravelN | THMN_CanTravelE | THMN_CanTravelS
                | THMN_CanTravelW;
            if(iX == 0)
                pNode->iFlags &= ~THMN_CanTravelW;
            else if(iX == 127)
                pNode->iFlags &= ~THMN_CanTravelE;
            if(iY == 0)
                pNode->iFlags &= ~THMN_CanTravelN;
            else if(iY == 127)
                pNode->iFlags &= ~THMN_CanTravelS;
            pNode->iBlock[0] = iBaseTile;
            if(pData[3] == 0 || pData[3] == /* Parcel divider wall */ 140)
            {
                // Tiles 71, 72 and 73 (pond foliage) are used as floor tiles,
                // but are too tall to be floor tiles, so move them to a wall,
                // and replace the floor with something similar (pond base).
                if(71 <= iBaseTile && iBaseTile <= 73)
                {
                    pNode->iBlock[1] = iBaseTile;
                    pNode->iBlock[0] = iBaseTile = 69;
                }
                else
                    pNode->iBlock[1] = 0;
            }
            else
            {
                pNode->iBlock[1] = gs_iTHMapBlockLUT[pData[3]];
                pNode->iFlags &= ~THMN_CanTravelN;
                if(iY != 0)
                {
                    pNode[-128].iFlags &= ~THMN_CanTravelS;
                }
            }
            if(pData[4] == 0 || pData[4] == /* Parcel divider wall */ 141)
                pNode->iBlock[2] = 0;
            else
            {
                pNode->iBlock[2] = gs_iTHMapBlockLUT[pData[4]];
                pNode->iFlags &= ~THMN_CanTravelW;
                if(iX != 0)
                {
                    pNode[-1].iFlags &= ~THMN_CanTravelE;
                }
            }

            if(!(pData[5] & 1))
            {
                pNode->iFlags |= THMN_Passable;
                if(*pParcel && !(pData[7] & 16))
                {
                    pNode->iFlags |= THMN_Hospital;
                    if(!(pData[5] & 2))
                        pNode->iFlags |= THMN_Buildable;
                }
            }

            /*
            // This code now done from map file data rather than tile numbers,
            // but kept here incase it is required to do it by tile again.
            switch(iBaseTile)
            {
            case 0x10: case 0x11: case 0x12: case 0x13: case 0x14:
            case 0x15: case 0x16: case 0x17: case 0x42: case 0x4C:
                pNode->iFlags |= THMN_Hospital | THMN_Buildable;
                // fall-through
            case 0x0F: case 0x04: case 0x05: case 0x32: case 0x3A:
                pNode->iFlags |= THMN_Passable;
                break;
            }
            */
        }
    }

    updateShadows();
    return true;
}

THMapNode* THMap::getNode(int iX, int iY)
{
    if(0 <= iX && iX < m_iWidth && 0 <= iY && iY < m_iHeight)
        return getNodeUnchecked(iX, iY);
    else
        return NULL;
}

const THMapNode* THMap::getNode(int iX, int iY) const
{
    if(0 <= iX && iX < m_iWidth && 0 <= iY && iY < m_iHeight)
        return getNodeUnchecked(iX, iY);
    else
        return NULL;
}

THMapNode* THMap::getNodeUnchecked(int iX, int iY)
{
    return m_pCells + iY * m_iWidth + iX;
}

const THMapNode* THMap::getNodeUnchecked(int iX, int iY) const
{
    return m_pCells + iY * m_iWidth + iX;
}

void THMap::setBlockSheet(THSpriteSheet* pSheet)
{
    m_pBlocks = pSheet;
}

void THMap::setAllWallDrawFlags(unsigned char iFlags)
{
    uint16_t iBlockOr = static_cast<uint16_t>(iFlags) << 8;
    THMapNode *pNode = m_pCells;
    for(int i = 0; i < m_iWidth * m_iHeight; ++i, ++pNode)
    {
        pNode->iBlock[1] = (pNode->iBlock[1] & 0xFF) | iBlockOr;
        pNode->iBlock[2] = (pNode->iBlock[2] & 0xFF) | iBlockOr;
    }
}

static void IntersectClipRect(THClipRect& rcClip,const THClipRect& rcIntersect)
{
    if(rcClip.x < rcIntersect.x)
    {
        if(rcClip.x + static_cast<int16_t>(rcClip.w) <= rcIntersect.x)
        {
            rcClip.w = 0;
            rcClip.h = 0;
            return;
        }
        rcClip.w = rcClip.x - rcIntersect.x + rcClip.w;
        rcClip.x = rcIntersect.x;
    }
    if(rcClip.y < rcIntersect.y)
    {
        if(rcClip.y + static_cast<int16_t>(rcClip.h) <= rcIntersect.y)
        {
            rcClip.w = 0;
            rcClip.h = 0;
            return;
        }
        rcClip.h = rcClip.y - rcIntersect.y + rcClip.h;
        rcClip.y = rcIntersect.y;
    }
    if(rcClip.x + rcClip.w > rcIntersect.x + rcIntersect.w)
    {
        if(rcIntersect.x + static_cast<int16_t>(rcIntersect.w) <= rcClip.x)
        {
            rcClip.w = 0;
            rcClip.h = 0;
            return;
        }
        rcClip.w = rcIntersect.x + rcIntersect.w - rcClip.x;
    }
    if(rcClip.y + rcClip.h > rcIntersect.y + rcIntersect.h)
    {
        if(rcIntersect.y + static_cast<int16_t>(rcIntersect.h) <= rcClip.y)
        {
            rcClip.w = 0;
            rcClip.h = 0;
            return;
        }
        rcClip.h = rcIntersect.y + rcIntersect.h - rcClip.y;
    }
}

void THMap::draw(THRenderTarget* pCanvas, int iScreenX, int iScreenY,
                 int iWidth, int iHeight, int iCanvasX, int iCanvasY) const
{
    /*
       The map is drawn in two passes, with each pass done one scanline at a
       time (a scanline is a list of nodes with the same screen Y co-ordinate).
       The first pass does floor tiles, as the entire floor needs to be painted
       below anything else (for example, see the walking north through a door
       animation, which needs to paint over the floor of the scanline below the
       animation). On the second pass, walls and entities are drawn, with the
       order controlled such that entites appear in the right order relative to
       the walls around them. For each scanline, the following is done:

       1st pass:
        1) For each node, left to right, the floor tile (layer 0)
       2nd pass:
        1) For each node, right to left, the east wall, then the early entities
        2) For each node, left to right, the north wall, then the late entities
    */

    if(m_pBlocks == NULL || m_pCells == NULL)
        return;

    THClipRect rcClip;
    rcClip.x = iCanvasX;
    rcClip.y = iCanvasY;
    rcClip.w = iWidth;
    rcClip.h = iHeight;
    THRenderTarget_SetClipRect(pCanvas, &rcClip);

    int iStartX = 0;
    int iStartY = (iScreenY - 32) / 16;
    if(iStartY < 0)
        iStartY = 0;
    else if(iStartY >= m_iHeight)
    {
        iStartX = iStartY - m_iHeight + 1;
        iStartY = m_iHeight - 1;
        if(iStartX >= m_iWidth)
            iStartX = m_iWidth - 1;
    }
    int iBaseX = iStartX;
    int iBaseY = iStartY;

    // 1st pass
    THRenderTarget_StartNonOverlapping(pCanvas);
    while(true)
    {
        int iX = iBaseX;
        int iY = iBaseY;
        int iXs = iX, iYs = iY;
        worldToScreen(iXs, iYs);
        iXs -= iScreenX;
        iYs -= iScreenY;
        if(iYs >= iHeight + 70)
            break;
        else if(iYs > -32)
        {
            const THMapNode *pLastNode = NULL;

            do
            {
                if(iXs < -32)
                {
                    // Nothing to do
                }
                else if(iXs < iWidth + 32)
                {
                    pLastNode = getNodeUnchecked(iX, iY);

                    unsigned int iH = 32;
                    unsigned int iBlock = pLastNode->iBlock[0];
                    m_pBlocks->getSpriteSize(iBlock & 0xFF, NULL, &iH);
                    m_pBlocks->drawSprite(pCanvas, iBlock & 0xFF,
                        iXs + iCanvasX - 32,
                        iYs + iCanvasY - iH + 32, iBlock >> 8);
                    // Shadow for floor done in 2nd pass as it overlaps with
                    // the floor.
                }
                else
                    break;
                --iY;
                ++iX;
                iXs += 64;
            } while (iY >= 0 && iX < m_iWidth);
        }
        if(iBaseY == m_iHeight - 1)
        {
            if(++iBaseX == m_iWidth)
                break;
        }
        else
            ++iBaseY;
    }
    THRenderTarget_FinishNonOverlapping(pCanvas);

    // 2nd pass
    iBaseX = iStartX;
    iBaseY = iStartY;
    int iNodeStep = 1 - m_iWidth;
    while(true)
    {
        int iX = iBaseX;
        int iY = iBaseY;
        int iXs = iX, iYs = iY;
        worldToScreen(iXs, iYs);
        iXs -= iScreenX;
        iYs -= iScreenY;
        if(iYs >= iHeight + 70)
            break;
        else if(iYs > -32)
        {
            const THMapNode *pLastNode = NULL;
            int iNodeCount = 0;

            do
            {
                if(iXs < -32)
                {
                    // Nothing to do
                }
                else if(iXs < iWidth + 32)
                {
                    pLastNode = getNodeUnchecked(iX, iY);
                    ++iNodeCount;

                    if(pLastNode->iFlags & THMN_ShadowFull)
                    {
                        m_pBlocks->drawSprite(pCanvas, 74, iXs + iCanvasX - 32,
                            iYs + iCanvasY, THDF_Alpha75);
                    }
                    else if(pLastNode->iFlags & THMN_ShadowHalf)
                    {
                        m_pBlocks->drawSprite(pCanvas, 75, iXs + iCanvasX - 32,
                            iYs + iCanvasY, THDF_Alpha75);
                    }
                }
                else
                    break;
                --iY;
                ++iX;
                iXs += 64;
            } while (iY >= 0 && iX < m_iWidth);

            if(iNodeCount != 0)
            {
                iXs += iCanvasX;
                iYs += iCanvasY;
                iXs -= 64;
                const THMapNode *pNode = pLastNode;
                int iNodeIndex = 0;
                for(; iNodeIndex < iNodeCount; ++iNodeIndex,
                    pNode -= iNodeStep, iXs -= 64)
                {
                    unsigned int iH;
                    unsigned int iBlock = pNode->iBlock[1];
                    if(iBlock != 0 && m_pBlocks->getSpriteSize(iBlock & 0xFF,
                        NULL, &iH) && iH > 0)
                    {
                        m_pBlocks->drawSprite(pCanvas, iBlock & 0xFF, iXs - 32,
                            iYs - iH + 32, iBlock >> 8);
                        if(pNode->iFlags & THMN_ShadowWall)
                        {
                            THClipRect rcOldClip, rcNewClip;
                            THRenderTarget_GetClipRect(pCanvas, &rcOldClip);
                            rcNewClip.x = iXs - 32;
                            rcNewClip.y = iYs - iH + 32 + 4;
                            rcNewClip.w = 64;
                            rcNewClip.h = 86 - 4;
                            IntersectClipRect(rcNewClip, rcOldClip);
                            THRenderTarget_SetClipRect(pCanvas, &rcNewClip);
                            m_pBlocks->drawSprite(pCanvas, 156, iXs - 32,
                                iYs - 56, THDF_Alpha75);
                            THRenderTarget_SetClipRect(pCanvas, &rcOldClip);
                        }
                    }
                    if(pNode->oEarlyEntities.pNext != NULL)
                    {
                        THDrawable *pItem = (THDrawable*)
                            (pNode->oEarlyEntities.pNext);
                        do
                        {
                            pItem->fnDraw(pItem, pCanvas, iXs, iYs);
                            pItem = (THDrawable*)(pItem->pNext);
                        } while(pItem);
                    }
                }
                pNode += iNodeStep;
                iXs += 64;
                for(; iNodeCount; --iNodeCount, pNode += iNodeStep, iXs += 64)
                {
                    unsigned int iH;
                    unsigned int iBlock = pNode->iBlock[2];
                    if(iBlock != 0 && m_pBlocks->getSpriteSize(iBlock & 0xFF,
                        NULL, &iH) && iH > 0)
                    {
                        m_pBlocks->drawSprite(pCanvas, iBlock & 0xFF, iXs - 32,
                            iYs - iH + 32, iBlock >> 8);
                    }
                    iBlock = pNode->iBlock[3];
                    if(iBlock != 0 && m_pBlocks->getSpriteSize(iBlock & 0xFF,
                        NULL, &iH) && iH > 0)
                    {
                        m_pBlocks->drawSprite(pCanvas, iBlock & 0xFF, iXs - 32,
                            iYs - iH + 32, iBlock >> 8);
                    }
                    if(pNode->pNext != NULL)
                    {
                        THDrawable *pItem = (THDrawable*)(pNode->pNext);
                        do
                        {
                            pItem->fnDraw(pItem, pCanvas, iXs, iYs);
                            pItem = (THDrawable*)(pItem->pNext);
                        } while(pItem);
                    }
                }
            }
        }
        if(iBaseY == m_iHeight - 1)
        {
            if(++iBaseX == m_iWidth)
                break;
        }
        else
            ++iBaseY;
    }

    THRenderTarget_SetClipRect(pCanvas, NULL);
}

void THMap::updatePathfinding()
{
    THMapNode *pNode = m_pCells;
    for(int iY = 0; iY < 128; ++iY)
    {
        for(int iX = 0; iX < 128; ++iX, ++pNode)
        {
            pNode->iFlags |= THMN_CanTravelN | THMN_CanTravelE |
                THMN_CanTravelS | THMN_CanTravelW;
            if(iX == 0)
                pNode->iFlags &= ~THMN_CanTravelW;
            else if(iX == 127)
                pNode->iFlags &= ~THMN_CanTravelE;
            if(iY == 0)
                pNode->iFlags &= ~THMN_CanTravelN;
            else if(iY == 127)
                pNode->iFlags &= ~THMN_CanTravelS;
            if(pNode->iBlock[1])
            {
                pNode->iFlags &= ~THMN_CanTravelN;
                if(iY != 0)
                {
                    pNode[-128].iFlags &= ~THMN_CanTravelS;
                }
            }
            if(pNode->iBlock[2])
            {
                pNode->iFlags &= ~THMN_CanTravelW;
                if(iX != 0)
                {
                    pNode[-1].iFlags &= ~THMN_CanTravelE;
                }
            }
        }
    }
}

void THMap::updateShadows()
{
#define IsWall(node, block, door) \
    (((node)->iFlags & (door)) != 0 || \
    (82 <= ((node)->iBlock[(block)]) && ((node)->iBlock[(block)]) <= 155))

    THMapNode *pNode = m_pCells;
    for(int iY = 0; iY < 128; ++iY)
    {
        for(int iX = 0; iX < 128; ++iX, ++pNode)
        {
            pNode->iFlags &= ~(THMN_ShadowHalf | THMN_ShadowFull |
                THMN_ShadowWall);
            if(IsWall(pNode, 2, THMN_DoorWest))
            {
                pNode->iFlags |= THMN_ShadowHalf;
                if(IsWall(pNode, 1, THMN_DoorNorth))
                {
                    pNode->iFlags |= THMN_ShadowWall;
                }
                else if(iY != 0)
                {
                    THMapNode *pNeighbour = pNode - 128;
                    pNeighbour->iFlags |= THMN_ShadowFull;
                    if(iX != 0 && !IsWall(pNeighbour, 2, THMN_DoorWest))
                    {
                        pNeighbour[-1].iFlags |= THMN_ShadowFull;
                    }
                }
            }
        }
    }

#undef IsWall
}
