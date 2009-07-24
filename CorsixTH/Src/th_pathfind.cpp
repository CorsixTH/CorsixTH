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
#include "th_pathfind.h"
#include "lua.hpp"
#include <queue>

THPathfinder::THPathfinder()
{
    m_pNodes = NULL;
    m_ppDirtyList = NULL;
    m_pDestination = NULL;
    m_pDefaultMap = NULL;
    m_iNodeCacheWidth = 0;
    m_iNodeCacheHeight = 0;
    m_iDirtyCount = 0;
}

THPathfinder::~THPathfinder()
{
    delete[] m_pNodes;
    delete[] m_ppDirtyList;
}

struct node_compare
{
    bool operator() (THPathfinder::node_t* a, THPathfinder::node_t* b)
    {
        return (b->distance + b->guess) < (a->distance + a->guess);
    }
};

void THPathfinder::setDefaultMap(const THMap *pMap)
{
    m_pDefaultMap = pMap;
}

bool THPathfinder::findPath(const THMap *pMap, int iStartX, int iStartY, int iEndX, int iEndY)
{
    std::priority_queue<node_t*, std::vector<node_t*>, node_compare> queOpen;

    if(pMap == NULL)
        pMap = m_pDefaultMap;
    if(pMap == NULL || pMap->getNode(iEndX, iEndY) == NULL
        || (pMap->getNodeUnchecked(iEndX, iEndY)->iFlags & THMN_Passable) == 0)
    {
        m_pDestination = NULL;
        return false;
    }

#define MakeGuess(pNode) \
    pNode->guess = 0 /*abs(pNode->x - iEndX) + abs(pNode->y - iEndY) */

    int iWidth = pMap->getWidth();
    int iHeight = pMap->getHeight();
    _allocNodeCache(iWidth, iHeight);
    node_t *pNode = m_pNodes + iStartY * iWidth + iStartX;
    node_t *pTarget = m_pNodes + iEndY * iWidth + iEndX;
    pNode->prev = NULL;
    pNode->distance = 0;
    MakeGuess(pNode);
    m_ppDirtyList[m_iDirtyCount++] = pNode;
    queOpen.push(pNode);

    while(!queOpen.empty())
    {
        pNode = queOpen.top();
        queOpen.pop();
        if(pNode == pTarget)
        {
            break;
        }

        unsigned long iFlags = pMap->getNodeUnchecked(pNode->x, pNode->y)->iFlags;
        unsigned long iPassable = iFlags & THMN_Passable;

#define TryNode(n) \
    { \
        node_t *pNeighbor = n; \
        if(pNeighbor->prev == pNeighbor) \
        { \
            int iNFlags = pMap->getNodeUnchecked(pNeighbor->x, pNeighbor->y)->iFlags; \
            if(iNFlags & THMN_Passable || iPassable == 0) \
            { \
                pNeighbor->prev = pNode; \
                pNeighbor->distance = pNode->distance + 1; \
                MakeGuess(pNeighbor); \
                m_ppDirtyList[m_iDirtyCount++] = pNeighbor; \
                queOpen.push(pNeighbor); \
            } \
        } \
    }

        if(iFlags & THMN_CanTravelN)
        {
            TryNode(pNode - 1);
        }
        if(iFlags & THMN_CanTravelS)
        {
            TryNode(pNode + 1);
        }
        if(iFlags & THMN_CanTravelE)
        {
            TryNode(pNode - iWidth);
        }
        if(iFlags & THMN_CanTravelW)
        {
            TryNode(pNode + iWidth);
        }
    }

    if(pNode == pTarget)
    {
        m_pDestination = pTarget;
        return true;
    }
    else
    {
        m_pDestination = NULL;
        return false;
    }

#undef MakeGuess
#undef TryNode
}

void THPathfinder::_allocNodeCache(int iWidth, int iHeight)
{
    if(m_iNodeCacheWidth != iWidth || m_iNodeCacheHeight != iHeight)
    {
        delete[] m_pNodes;
        m_pNodes = new node_t[iWidth * iHeight];
        node_t *pNode = m_pNodes;
        for(int iY = 0; iY < iHeight; ++iY)
        {
            for(int iX = 0; iX < iWidth; ++iX, ++pNode)
            {
                pNode->prev = pNode;
                pNode->x = iX;
                pNode->y = iY;
            }
        }
        delete[] m_ppDirtyList;
        m_ppDirtyList = new node_t*[iWidth * iHeight];
        m_iNodeCacheWidth = iWidth;
        m_iNodeCacheHeight = iHeight;
    }
    else
    {
        for(int i = 0; i < m_iDirtyCount; ++i)
        {
            m_ppDirtyList[i]->prev = m_ppDirtyList[i];
        }
    }
    m_iDirtyCount = 0;
}

int THPathfinder::getPathLength() const
{
    if(m_pDestination != NULL)
        return m_pDestination->distance;
    else
        return -1;
}

void THPathfinder::pushResult(lua_State *L) const
{
    lua_checkstack(L, 3);

    if(m_pDestination == NULL)
    {
        lua_pushnil(L);
        lua_pushliteral(L, "no path");
        return;
    }

    int iLength = m_pDestination->distance;
    lua_createtable(L, iLength + 1, 0);
    lua_createtable(L, iLength + 1, 0);

    for(node_t* pNode = m_pDestination; pNode; pNode = pNode->prev)
    {
        lua_pushinteger(L, pNode->x + 1);
        lua_rawseti(L, -3, pNode->distance + 1);
        lua_pushinteger(L, pNode->y + 1);
        lua_rawseti(L, -2, pNode->distance + 1);
    }
}
