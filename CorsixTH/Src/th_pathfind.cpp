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
#include <malloc.h>
#include <stdlib.h>
#include <queue>

THPathfinder::THPathfinder()
{
    m_pNodes = NULL;
    m_ppDirtyList = NULL;
    m_ppOpenHeap = (node_t**)malloc(sizeof(node_t*) * 8);
    m_pDestination = NULL;
    m_pDefaultMap = NULL;
    m_iNodeCacheWidth = 0;
    m_iNodeCacheHeight = 0;
    m_iDirtyCount = 0;
    m_iOpenCount = 0;
    m_iOpenSize = 8;
}

THPathfinder::~THPathfinder()
{
    free(m_ppOpenHeap);
    delete[] m_pNodes;
    delete[] m_ppDirtyList;
}

void THPathfinder::setDefaultMap(const THMap *pMap)
{
    m_pDefaultMap = pMap;
}

bool THPathfinder::findPath(const THMap *pMap, int iStartX, int iStartY, int iEndX, int iEndY)
{
    if(pMap == NULL)
        pMap = m_pDefaultMap;
    if(pMap == NULL || pMap->getNode(iEndX, iEndY) == NULL
        || (pMap->getNodeUnchecked(iEndX, iEndY)->iFlags & THMN_Passable) == 0)
    {
        m_pDestination = NULL;
        return false;
    }

    // As diagonal movement is not allowed, the minimum distance between two
    // points is the sum of the distance in X and the distance in Y. Provided
    // that the compiler generates clever assembly for abs(), this means that
    // guesses can be calculated without branching and without sqrt().
#define MakeGuess(pNode) \
    pNode->guess = abs(pNode->x - iEndX) + abs(pNode->y - iEndY)

    int iWidth = pMap->getWidth();
    _allocNodeCache(iWidth, pMap->getHeight());
    node_t *pNode = m_pNodes + iStartY * iWidth + iStartX;
    node_t *pTarget = m_pNodes + iEndY * iWidth + iEndX;
    pNode->prev = NULL;
    pNode->distance = 0;
    MakeGuess(pNode);
    m_ppDirtyList[0] = pNode;
    m_iDirtyCount = 1;
    m_iOpenCount = 0;

    while(true)
    {
        if(pNode == pTarget)
        {
            m_pDestination = pTarget;
            return true;
        }

        unsigned long iFlags = pMap->getNodeUnchecked(pNode->x, pNode->y)->iFlags;
        unsigned long iPassable = iFlags & THMN_Passable;

#define TryNode(n) \
    node_t *pNeighbour = n; \
    int iNFlags = pMap->getNodeUnchecked(pNeighbour->x, pNeighbour->y)->iFlags; \
    if(iNFlags & THMN_Passable || iPassable == 0) \
    { \
        if(pNeighbour->prev == pNeighbour) \
        { \
            pNeighbour->prev = pNode; \
            pNeighbour->distance = pNode->distance + 1; \
            MakeGuess(pNeighbour); \
            m_ppDirtyList[m_iDirtyCount++] = pNeighbour; \
            _openHeapPush(pNeighbour); \
        } \
        else if((pNode->distance + 1) < pNeighbour->distance) \
        { \
            pNeighbour->prev = pNode; \
            pNeighbour->distance = pNode->distance + 1; \
            /* guess doesn't change, and already in the dirty list */ \
            _openHeapPromote(pNeighbour); \
        } \
    }

        // No need to check for the node being on the map edge, as the N/E/S/W
        // flags are set as to prevent travelling off the map (as well as to
        // prevent walking through walls).
        if(iFlags & THMN_CanTravelW)
        {
            TryNode(pNode - 1);
        }
        if(iFlags & THMN_CanTravelE)
        {
            TryNode(pNode + 1);
        }
        if(iFlags & THMN_CanTravelN)
        {
            TryNode(pNode - iWidth);
        }
        if(iFlags & THMN_CanTravelS)
        {
            TryNode(pNode + iWidth);
        }

        if(m_iOpenCount == 0)
        {
            m_pDestination = NULL;
            return false;
        }
        else
            pNode = _openHeapPop();
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
                // Other fields are undefined as the node is not part of a
                // path, and thus can be left uninitialised.
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
            // Other fields are undefined as the node is not part of a path,
            // and thus can keep their old values.
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

    for(const node_t* pNode = m_pDestination; pNode; pNode = pNode->prev)
    {
        lua_pushinteger(L, pNode->x + 1);
        lua_rawseti(L, -3, pNode->distance + 1);
        lua_pushinteger(L, pNode->y + 1);
        lua_rawseti(L, -2, pNode->distance + 1);
    }
}

void THPathfinder::_openHeapPush(THPathfinder::node_t* pNode)
{
    if(m_iOpenCount == m_iOpenSize)
    {
        m_iOpenSize = (m_iOpenSize + 1) * 2;
        m_ppOpenHeap = (node_t**)realloc(m_ppOpenHeap, sizeof(node_t*) * m_iOpenSize);
    }
    int i = m_iOpenCount++;
    m_ppOpenHeap[i] = pNode;
    pNode->open_idx = i;
    _openHeapPromote(pNode);
}

void THPathfinder::_openHeapPromote(THPathfinder::node_t* pNode)
{
    int i = pNode->open_idx;
    while(i > 0)
    {
        int parent = (i - 1) / 2;
        node_t *pParent = m_ppOpenHeap[parent];
        if(pParent->value() <= pNode->value())
            break;
        pParent->open_idx = i;
        m_ppOpenHeap[i] = pParent;
        m_ppOpenHeap[parent] = pNode;
        i = parent;
    }
    pNode->open_idx = i;
}

THPathfinder::node_t* THPathfinder::_openHeapPop()
{
    node_t *pResult = m_ppOpenHeap[0];
    node_t *pNode = m_ppOpenHeap[--m_iOpenCount];
    m_ppOpenHeap[0] = pNode;
    int i = 0;
    int min = 0;
    int left = i * 2 + 1;
    const int value = pNode->value();
    while(left < m_iOpenCount)
    {
        min = i;
        const int right = (i + 1) * 2;
        int minvalue = value;
        node_t *pSwap;
        node_t *pTest = m_ppOpenHeap[left];
        if(pTest->value() < minvalue)
            min = left, minvalue = pTest->value(), pSwap = pTest;
        if(right < m_iOpenCount)
        {
            pTest = m_ppOpenHeap[right];
            if(pTest->value() < minvalue)
                min = right, pSwap = pTest;
        }
        if(min == i)
            break;

        pSwap->open_idx = i;
        m_ppOpenHeap[i] = pSwap;
        m_ppOpenHeap[min] = pNode;
        i = min;
        left = i * 2 + 1;
    }
    pNode->open_idx = min;
    return pResult;
}
