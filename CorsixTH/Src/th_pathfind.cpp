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
#include "persist_lua.h"
#include "lua.hpp"
#include <cstdlib>
#include <queue>
#include <cmath>
#include <vector>

BasePathing::BasePathing(THPathfinder *pf) : m_pPf(pf)
{ }

node_t *BasePathing::pathingInit(const THMap *pMap, int iStartX, int iStartY)
{
    int iWidth = pMap->getWidth();
    m_pPf->m_pDestination = nullptr;
    m_pPf->_allocNodeCache(iWidth, pMap->getHeight());
    node_t *pNode = m_pPf->m_pNodes + iStartY * iWidth + iStartX;
    pNode->prev = nullptr;
    pNode->distance = 0;
    pNode->guess = makeGuess(pNode);
    m_pPf->m_ppDirtyList[0] = pNode;
    m_pPf->m_iDirtyCount = 1;
    m_pPf->m_openHeap.clear();
    return pNode;
}

/*! No need to check for the node being on the map edge, as the N/E/S/W
    flags are set as to prevent travelling off the map (as well as to
    prevent walking through walls).
 */
bool BasePathing::pathingNeighbours(node_t *pNode, th_map_node_flags flags, int iWidth)
{
    if(flags.can_travel_w)
        if(tryNode(pNode, flags, pNode - 1, THTD_West)) return true;

    if(flags.can_travel_e)
        if (tryNode(pNode, flags, pNode + 1, THTD_East)) return true;

    if(flags.can_travel_n)
        if (tryNode(pNode, flags, pNode - iWidth, THTD_North)) return true;

    if(flags.can_travel_s)
        if (tryNode(pNode, flags, pNode + iWidth, THTD_South)) return true;

    return false;
}

void BasePathing::pathingTryNode(node_t *pNode, th_map_node_flags neighbour_flags, bool passable, node_t *pNeighbour)
{
    if(neighbour_flags.passable || !passable)
    {
        if(pNeighbour->prev == pNeighbour)
        {
            pNeighbour->prev = pNode;
            pNeighbour->distance = pNode->distance + 1;
            pNeighbour->guess = makeGuess(pNeighbour);
            m_pPf->m_ppDirtyList[m_pPf->m_iDirtyCount++] = pNeighbour;
            m_pPf->_openHeapPush(pNeighbour);
        }
        else if(pNode->distance + 1 < pNeighbour->distance)
        {
            pNeighbour->prev = pNode;
            pNeighbour->distance = pNode->distance + 1;
            /* guess doesn't change, and already in the dirty list */
            m_pPf->_openHeapPromote(pNeighbour);
        }
    }
}

int PathFinder::makeGuess(node_t *pNode)
{
    // As diagonal movement is not allowed, the minimum distance between two
    // points is the sum of the distance in X and the distance in Y.
    return abs(pNode->x - m_iEndX) + abs(pNode->y - m_iEndY);
}

bool PathFinder::tryNode(node_t *pNode, th_map_node_flags flags,
                         node_t *pNeighbour, int direction)
{
    th_map_node_flags neighbour_flags = m_pMap->getNodeUnchecked(pNeighbour->x, pNeighbour->y)->flags;
    pathingTryNode(pNode, neighbour_flags, flags.passable, pNeighbour);
    return false;
}

bool PathFinder::findPath(const THMap *pMap, int iStartX, int iStartY, int iEndX, int iEndY)
{
    if(pMap == nullptr)
        pMap = m_pPf->m_pDefaultMap;
    if(pMap == nullptr || pMap->getNode(iEndX, iEndY) == nullptr
        || !pMap->getNodeUnchecked(iEndX, iEndY)->flags.passable)
    {
        m_pPf->m_pDestination = nullptr;
        return false;
    }

    m_pMap = pMap;
    m_iEndX = iEndX;
    m_iEndY = iEndY;

    node_t *pNode = pathingInit(pMap, iStartX, iStartY);
    int iWidth = pMap->getWidth();
    node_t *pTarget = m_pPf->m_pNodes + iEndY * iWidth + iEndX;

    while(true)
    {
        if(pNode == pTarget)
        {
            m_pPf->m_pDestination = pTarget;
            return true;
        }

        th_map_node_flags flags = pMap->getNodeUnchecked(pNode->x, pNode->y)->flags;
        if (pathingNeighbours(pNode, flags, iWidth)) return true;

        if (m_pPf->m_openHeap.empty()) {
            m_pPf->m_pDestination = nullptr;
            break;
        } else {
            pNode = m_pPf->_openHeapPop();
        }
    }
    return false;
}

int HospitalFinder::makeGuess(node_t *pNode)
{
    return 0;
}

bool HospitalFinder::tryNode(node_t *pNode, th_map_node_flags flags,
                             node_t *pNeighbour, int direction)
{
    th_map_node_flags neighbour_flags = m_pMap->getNodeUnchecked(pNeighbour->x, pNeighbour->y)->flags;
    pathingTryNode(pNode, neighbour_flags, flags.passable, pNeighbour);
    return false;
}

bool HospitalFinder::findPathToHospital(const THMap *pMap, int iStartX, int iStartY)
{
    if(pMap == nullptr)
        pMap = m_pPf->m_pDefaultMap;
    if(pMap == nullptr || pMap->getNode(iStartX, iStartY) == nullptr
        || !pMap->getNodeUnchecked(iStartX, iStartY)->flags.passable)
    {
        m_pPf->m_pDestination = nullptr;
        return false;
    }

    m_pMap = pMap;

    node_t *pNode = pathingInit(pMap, iStartX, iStartY);
    int iWidth = pMap->getWidth();

    while(true)
    {
        th_map_node_flags flags = pMap->getNodeUnchecked(pNode->x, pNode->y)->flags;

        if(flags.hospital)
        {
            m_pPf->m_pDestination = pNode;
            return true;
        }

        if (pathingNeighbours(pNode, flags, iWidth)) return true;

        if (m_pPf->m_openHeap.empty()) {
            m_pPf->m_pDestination = nullptr;
            break;
        } else {
            pNode = m_pPf->_openHeapPop();
        }
    }
    return false;
}

int IdleTileFinder::makeGuess(node_t *pNode)
{
    return 0;
}

bool IdleTileFinder::tryNode(node_t *pNode, th_map_node_flags flags,
                             node_t *pNeighbour, int direction)
{
    th_map_node_flags neighbour_flags = m_pMap->getNodeUnchecked(pNeighbour->x, pNeighbour->y)->flags;
    /* When finding an idle tile, do not navigate through doors */
    switch(direction)
    {
    case THTD_North:
        if(!flags.door_north)
            pathingTryNode(pNode, neighbour_flags, flags.passable, pNeighbour);
        break;

    case THTD_East:
        if(!neighbour_flags.door_west)
            pathingTryNode(pNode, neighbour_flags, flags.passable, pNeighbour);
        break;

    case THTD_South:
        if(!neighbour_flags.door_north)
            pathingTryNode(pNode, neighbour_flags, flags.passable, pNeighbour);
        break;

    case THTD_West:
        if(!flags.door_west)
            pathingTryNode(pNode, neighbour_flags, flags.passable, pNeighbour);
        break;
    }

    /* Identify the neighbour in the open list nearest to the start */
    if(pNeighbour->prev != pNeighbour && pNeighbour->open_idx != -1)
    {
        int iDX = pNeighbour->x - m_iStartX;
        int iDY = pNeighbour->y - m_iStartY;
        double fDistance = sqrt((double)(iDX * iDX + iDY * iDY));
        if(m_pBestNext == nullptr || fDistance < m_fBestDistance)
        {
            m_pBestNext = pNeighbour; m_fBestDistance = fDistance;
        }
    }
    return false;
}

bool IdleTileFinder::findIdleTile(const THMap *pMap, int iStartX, int iStartY, int iN)
{
    if(pMap == nullptr)
        pMap = m_pPf->m_pDefaultMap;
    if(pMap == nullptr)
    {
        m_pPf->m_pDestination = nullptr;
        return false;
    }

    m_iStartX = iStartX;
    m_iStartY = iStartY;
    m_pMap = pMap;

    node_t *pNode = pathingInit(pMap, iStartX, iStartY);
    int iWidth = pMap->getWidth();
    node_t *pPossibleResult = nullptr;

    while(true)
    {
        pNode->open_idx = -1;
        th_map_node_flags flags = pMap->getNodeUnchecked(pNode->x, pNode->y)->flags;

        if(!flags.do_not_idle && flags.passable && flags.hospital)
        {
            if(iN == 0)
            {
                m_pPf->m_pDestination = pNode;
                return true;
            }
            else
            {
                pPossibleResult = pNode;
                --iN;
            }
        }

        m_pBestNext = nullptr;
        m_fBestDistance = 0.0;

        if (pathingNeighbours(pNode, flags, iWidth)) return true;

        if (m_pPf->m_openHeap.empty()) {
            m_pPf->m_pDestination = nullptr;
            break;
        }

        if(m_pBestNext)
        {
            // Promote the best neighbour to the front of the open list
            // This causes sequential iN to give neighbouring results for most iN
            m_pBestNext->guess = -m_pBestNext->distance;
            m_pPf->_openHeapPromote(m_pBestNext);
        }
        pNode = m_pPf->_openHeapPop();
    }
    if(pPossibleResult)
    {
        m_pPf->m_pDestination = pPossibleResult;
        return true;
    }
    return false;
}

int Objectsvisitor::makeGuess(node_t *pNode)
{
    return 0;
}

bool Objectsvisitor::tryNode(node_t *pNode, th_map_node_flags flags, node_t *pNeighbour, int direction)
{
    int iObjectNumber = 0;
    const THMapNode *pMapNode = m_pMap->getNodeUnchecked(pNeighbour->x, pNeighbour->y);
    th_map_node_flags neighbour_flags = m_pMap->getNodeUnchecked(pNeighbour->x, pNeighbour->y)->flags;
    for(auto thob : pMapNode->objects)
    {
        if(thob == m_eTHOB)
            iObjectNumber++;
    }
    if(m_bAnyObjectType)
        iObjectNumber = 1;
    bool bSucces = false;
    for(int i = 0; i < iObjectNumber; i++)
    {
        /* call the given Lua function, passing four arguments: */
        /* The x and y position of the object (Lua tile co-ords) */
        /* The direction which was last travelled in to reach (x,y); */
        /*   0 (north), 1 (east), 2 (south), 3 (west) */
        /* The distance to the object from the search starting point */
        lua_pushvalue(m_pL, m_iVisitFunction);
        lua_pushinteger(m_pL, pNeighbour->x + 1);
        lua_pushinteger(m_pL, pNeighbour->y + 1);
        lua_pushinteger(m_pL, direction);
        lua_pushinteger(m_pL, pNode->distance);
        lua_call(m_pL, 4, 1);
        if(lua_toboolean(m_pL, -1) != 0)
        {
            bSucces = true;
        }
        lua_pop(m_pL, 1);
    }
    if(bSucces)
        return true;

    if(pNode->distance < m_iMaxDistance)
    {
        switch(direction)
        {
        case THTD_North:
            if(!flags.door_north)
                pathingTryNode(pNode, neighbour_flags, flags.passable, pNeighbour);
            break;

        case THTD_East:
            if(!neighbour_flags.door_west)
                pathingTryNode(pNode, neighbour_flags, flags.passable, pNeighbour);
            break;

        case THTD_South:
            if(!neighbour_flags.door_north)
                pathingTryNode(pNode, neighbour_flags, flags.passable, pNeighbour);
            break;

        case THTD_West:
            if(!flags.door_west)
                pathingTryNode(pNode, neighbour_flags, flags.passable, pNeighbour);
            break;
        }
    }
    return false;
}

bool Objectsvisitor::visitObjects(const THMap *pMap, int iStartX, int iStartY,
                                  THObjectType eTHOB, int iMaxDistance,
                                  lua_State *L, int iVisitFunction, bool anyObjectType)
{
    if(pMap == nullptr)
        pMap = m_pPf->m_pDefaultMap;
    if(pMap == nullptr)
    {
        m_pPf->m_pDestination = nullptr;
        return false;
    }

    m_pL = L;
    m_iVisitFunction = iVisitFunction;
    m_iMaxDistance = iMaxDistance;
    m_bAnyObjectType = anyObjectType;
    m_eTHOB = eTHOB;
    m_pMap = pMap;

    node_t *pNode = pathingInit(pMap, iStartX, iStartY);
    int iWidth = pMap->getWidth();

    while(true)
    {
        th_map_node_flags flags = pMap->getNodeUnchecked(pNode->x, pNode->y)->flags;
        if (pathingNeighbours(pNode, flags, iWidth)) return true;

        if (m_pPf->m_openHeap.empty()) {
            m_pPf->m_pDestination = nullptr;
            break;
        } else {
            pNode = m_pPf->_openHeapPop();
        }
    }
    return false;
}

THPathfinder::THPathfinder() : m_oPathFinder(this), m_oHospitalFinder(this),
                               m_oIdleTileFinder(this), m_oObjectsvisitor(this),
                               m_openHeap()
{
    m_pNodes = nullptr;
    m_ppDirtyList = nullptr;
    m_pDestination = nullptr;
    m_pDefaultMap = nullptr;
    m_iNodeCacheWidth = 0;
    m_iNodeCacheHeight = 0;
    m_iDirtyCount = 0;
}

THPathfinder::~THPathfinder()
{
    delete[] m_pNodes;
    delete[] m_ppDirtyList;
}

void THPathfinder::setDefaultMap(const THMap *pMap)
{
    m_pDefaultMap = pMap;
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
    if(m_pDestination != nullptr)
        return m_pDestination->distance;
    else
        return -1;
}

bool THPathfinder::getPathEnd(int* pX, int* pY) const
{
    if(m_pDestination == nullptr)
    {
        if(pX)
            *pX = -1;
        if(pY)
            *pY = -1;
        return false;
    }
    if(pX)
        *pX = m_pDestination->x;
    if(pY)
        *pY = m_pDestination->y;
    return true;
}

void THPathfinder::pushResult(lua_State *L) const
{
    lua_checkstack(L, 3);

    if(m_pDestination == nullptr)
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

void THPathfinder::_openHeapPush(node_t* pNode)
{
    pNode->open_idx = m_openHeap.size();
    m_openHeap.push_back(pNode);
    _openHeapPromote(pNode);
}

void THPathfinder::_openHeapPromote(node_t* pNode)
{
    int i = pNode->open_idx;
    while(i > 0)
    {
        int parent = (i - 1) / 2;
        node_t *pParent = m_openHeap[parent];
        if(pParent->value() <= pNode->value())
            break;
        pParent->open_idx = i;
        m_openHeap[i] = pParent;
        m_openHeap[parent] = pNode;
        i = parent;
    }
    pNode->open_idx = i;
}

node_t* THPathfinder::_openHeapPop()
{
    node_t *pResult = m_openHeap[0];
    node_t *pNode = m_openHeap.back();
    m_openHeap.pop_back();

    if (m_openHeap.empty()) {
        return pResult;
    }

    m_openHeap[0] = pNode;
    int i = 0;
    int min = 0;
    int left = i * 2 + 1;
    const int value = pNode->value();
    while(left < m_openHeap.size())
    {
        min = i;
        const int right = (i + 1) * 2;
        int minvalue = value;
        node_t *pSwap = nullptr;
        node_t *pTest = m_openHeap[left];
        if(pTest->value() < minvalue)
            min = left, minvalue = pTest->value(), pSwap = pTest;
        if(right < m_openHeap.size())
        {
            pTest = m_openHeap[right];
            if(pTest->value() < minvalue)
                min = right, pSwap = pTest;
        }
        if(min == i)
            break;

        pSwap->open_idx = i;
        m_openHeap[i] = pSwap;
        m_openHeap[min] = pNode;
        i = min;
        left = i * 2 + 1;
    }
    pNode->open_idx = min;
    return pResult;
}

void THPathfinder::persist(LuaPersistWriter *pWriter) const
{
    if(m_pDestination == nullptr)
    {
        pWriter->writeVUInt(0);
        return;
    }
    pWriter->writeVUInt(getPathLength() + 1);
    pWriter->writeVUInt(m_iNodeCacheWidth);
    pWriter->writeVUInt(m_iNodeCacheHeight);
    for(const node_t* pNode = m_pDestination; pNode; pNode = pNode->prev)
    {
        pWriter->writeVUInt(pNode->x);
        pWriter->writeVUInt(pNode->y);
    }
}

void THPathfinder::depersist(LuaPersistReader *pReader)
{
    new (this) THPathfinder; // Call constructor

    int iLength;
    if(!pReader->readVUInt(iLength))
        return;
    if(iLength == 0)
        return;
    int iWidth, iHeight;
    if(!pReader->readVUInt(iWidth) || !pReader->readVUInt(iHeight))
        return;
    _allocNodeCache(iWidth, iHeight);
    int iX, iY;
    if(!pReader->readVUInt(iX) || !pReader->readVUInt(iY))
        return;
    node_t *pNode = m_pNodes + iY * iWidth + iX;
    m_pDestination = pNode;
    for(int i = 0; i <= iLength - 2; ++i)
    {
        if(!pReader->readVUInt(iX) || !pReader->readVUInt(iY))
            return;
        node_t *pPrevNode = m_pNodes + iY * iWidth + iX;
        pNode->distance = iLength - 1 - i;
        pNode->prev = pPrevNode;
        m_ppDirtyList[m_iDirtyCount++] = pNode;
        pNode = pPrevNode;
    }
    pNode->distance = 0;
    pNode->prev = nullptr;
    m_ppDirtyList[m_iDirtyCount++] = pNode;
}
