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

static const unsigned char gs_iTHMapBlockLUT[256] = {
    0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10,
    0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20,
    0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x30,
    0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f, 0x40,
    0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f, 0x50,
    0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f, 0x60, 0x61,
    0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f, 0x70, 0x71,
    0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f, 0x80, 0x81,
    0x84, 0x85, 0x88, 0x89, 0x8c, 0x8d, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x8d, 0x8e, 0x51, 0x51,
    0x51, 0x51, 0x8e, 0x8f, 0xd5, 0xd6, 0x9c, 0xcc, 0xcd, 0xce, 0xcf, 0xd0, 0xd1, 0xd2, 0xd3, 0xd4,
    0xb3, 0xaf, 0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xb3, 0xb3, 0xb4, 0xb4,
    0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf, 0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9,
    0xca, 0xcb, 0x51, 0x82, 0x83, 0x86, 0x87, 0x8a, 0x8b, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98,
    0x99, 0x9a, 0x9b, 0x51, 0x9d, 0x9e, 0x9f, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xd7, 0xd8, 0xd9, 0xda,
    0xdb, 0xdc, 0xdd, 0xde, 0xdf, 0xe0, 0xe1, 0xe2,/***********************************************
    **********************************************/ 0xBA, 0xAD, 0xF0, 0x0D, 0xBA, 0xAD, 0xF0, 0x0D,
    0xBA, 0xAD, 0xF0, 0x0D, 0xBA, 0xAD, 0xF0, 0x0D, 0xBA, 0xAD, 0xF0, 0x0D, 0xBA, 0xAD, 0xF0, 0x0D,
};

bool THMap::loadFromTHFile(const unsigned char* pData, size_t iDataLength)
{
    if(iDataLength < (34 + 128 * 128 * 8) || !setSize(128, 128))
        return false;

    THMapNode *pNode = m_pCells;
    pData += 34;
    for(int iY = 0; iY < 128; ++iY)
    {
        for(int iX = 0; iX < 128; ++iX, ++pNode, pData += 8)
        {
            unsigned char iBaseTile = gs_iTHMapBlockLUT[pData[2]];
            pNode->iFlags = THMN_CanTravelN | THMN_CanTravelE | THMN_CanTravelS | THMN_CanTravelW;
            if(iX == 0)
                pNode->iFlags &= ~THMN_CanTravelW;
            else if(iX == 127)
                pNode->iFlags &= ~THMN_CanTravelE;
            if(iY == 0)
                pNode->iFlags &= ~THMN_CanTravelN;
            else if(iY == 127)
                pNode->iFlags &= ~THMN_CanTravelS;
            pNode->iBlock[0] = iBaseTile;
            if(pData[3] == 0)
                pNode->iBlock[1] = 0;
            else
            {
                pNode->iBlock[1] = gs_iTHMapBlockLUT[pData[3]];
                pNode->iFlags &= ~THMN_CanTravelN;
                if(iY != 0)
                {
                    pNode[-128].iFlags &= ~THMN_CanTravelS;
                }
            }
            if(pData[4] == 0)
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

void THMap::draw(THRenderTarget* pCanvas, int iScreenX, int iScreenY, int iWidth, int iHeight, int iCanvasX, int iCanvasY) const
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
        1) For each node, right to left, the east wall (1), then the early entities
        2) For each node, left to right, the north wall (2), then the late entities
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
                    m_pBlocks->drawSprite(pCanvas, iBlock & 0xFF, iXs + iCanvasX - 32,
                        iYs + iCanvasY - iH + 32, iBlock >> 8);
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
                for(; iNodeIndex < iNodeCount; ++iNodeIndex, pNode -= iNodeStep, iXs -= 64)
                {
                    unsigned int iH;
                    unsigned int iBlock = pNode->iBlock[1];
                    if(iBlock != 0 && m_pBlocks->getSpriteSize(iBlock & 0xFF, NULL, &iH) && iH > 0)
                    {
                        m_pBlocks->drawSprite(pCanvas, iBlock & 0xFF, iXs - 32, iYs - iH + 32, iBlock >> 8);
                        if(pNode->iFlags & THMN_ShadowWall)
                        {
                            THClipRect rcOldClip, rcNewClip;
                            THRenderTarget_GetClipRect(pCanvas, &rcOldClip);
                            rcNewClip.x = iXs - 32;
                            rcNewClip.y = iYs - iH + 32 + 4;
                            rcNewClip.w = 64;
                            rcNewClip.h = 86 - 4;
                            // Todo: Intersect new clip with old clip
                            THRenderTarget_SetClipRect(pCanvas, &rcNewClip);
                            m_pBlocks->drawSprite(pCanvas, 156, iXs - 32, iYs - 56, THDF_Alpha75);
                            THRenderTarget_SetClipRect(pCanvas, &rcOldClip);
                        }
                    }
                    if(pNode->oEarlyEntities.pNext != NULL)
                    {
                        THDrawable *pItem = (THDrawable*)(pNode->oEarlyEntities.pNext);
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
                    if(iBlock != 0 && m_pBlocks->getSpriteSize(iBlock & 0xFF, NULL, &iH) && iH > 0)
                    {
                        m_pBlocks->drawSprite(pCanvas, iBlock & 0xFF, iXs - 32, iYs - iH + 32, iBlock >> 8);
                    }
                    iBlock = pNode->iBlock[3];
                    if(iBlock != 0 && m_pBlocks->getSpriteSize(iBlock & 0xFF, NULL, &iH) && iH > 0)
                    {
                        m_pBlocks->drawSprite(pCanvas, iBlock & 0xFF, iXs - 32, iYs - iH + 32, iBlock >> 8);
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
            pNode->iFlags |= THMN_CanTravelN | THMN_CanTravelE | THMN_CanTravelS | THMN_CanTravelW;
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
#define IsWall(block, door) \
    ((door) != 0 || (82 <= (block) && (block) <= 155))

    THMapNode *pNode = m_pCells;
    for(int iY = 0; iY < 128; ++iY)
    {
        for(int iX = 0; iX < 128; ++iX, ++pNode)
        {
            pNode->iFlags &= ~(THMN_ShadowHalf | THMN_ShadowFull | THMN_ShadowWall);
            if(IsWall(pNode->iBlock[2], pNode->iFlags & THMN_DoorWest))
            {
                pNode->iFlags |= THMN_ShadowHalf;
                if(IsWall(pNode->iBlock[1], pNode->iFlags & THMN_DoorNorth))
                {
                    pNode->iFlags |= THMN_ShadowWall;
                }
                else if(iY != 0)
                {
                    THMapNode *pNeighbour = pNode - 128;
                    pNeighbour->iFlags |= THMN_ShadowFull;
                    if(iX != 0 && !IsWall(pNeighbour->iBlock[2], pNeighbour->iFlags & THMN_DoorWest))
                    {
                        pNeighbour[-1].iFlags |= THMN_ShadowFull;
                    }
                }
            }
        }
    }

#undef IsWall
}
