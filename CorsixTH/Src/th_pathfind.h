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

#ifndef CORSIX_TH_TH_PATHFIND_H_
#define CORSIX_TH_TH_PATHFIND_H_
#include "th_map.h"

class LuaPersistReader;
class LuaPersistWriter;

//! Finds paths through maps
/*!
    A pathfinder is used for finding a path through a map. A single pathfinder
    instance is not reentrant, but separate instances are. Users of the class
    should call findPath() to test if there is a path between two points on a
    map, and then use getPathLength() and/or pushResult() to get the actual
    path.

    Internally, the A* search algorithm is used. The open set is implemented as
    a heap in m_ppOpenHeap, and there is no explicit closed set. For each cell
    of the map, a node_t structure is created (and cached between searches if
    the map size is constant), which holds information about said map cell in
    the current search. The algorithm is implemented in such a way that most
    path find operations do not need to allocate (or free) any memory.
*/
class THPathfinder
{
public:
    THPathfinder();
    ~THPathfinder();

    void setDefaultMap(const THMap *pMap);

    bool findPath(const THMap *pMap, int iStartX, int iStartY, int iEndX,
                  int iEndY);
    bool findIdleTile(const THMap *pMap, int iStartX, int iStartY, int iN);
    bool findPathToHospital(const THMap *pMap, int iStartX, int iStartY);
    bool visitObjects(const THMap *pMap, int iStartX, int iStartY,
                      THObjectType eTHOB, int iMaxDistance, lua_State *L,
                      int iVisitFunction, bool anyObjectType);

    int getPathLength() const;
    bool getPathEnd(int* pX, int* pY) const;
    void pushResult(lua_State *L) const;

    void persist(LuaPersistWriter *pWriter) const;
    void depersist(LuaPersistReader *pReader);

protected:
    struct node_t
    {
        //! Pointer to the previous node in the path to this cell.
        /*!
            Points to NULL if this is the first cell in the path, or points to
            itself if it is not part of a path.
        */
        const node_t* prev;

        //! X-position of this cell (constant)
        int x;

        //! Y-position of this cell (constant)
        int y;

        //! Current shortest distance to this cell
        /*!
            Defined as prev->distance + 1 (or 0 if prev == NULL).
            Value is undefined if not part of a path.
        */
        int distance;

        //! Minimum distance from this cell to the goal
        /*!
            Value is only dependant upon the cell position and the goal
            position, and is undefined if not part of a path.
        */
        int guess;

        //! Index of this cell in the open heap
        /*!
            If the cell is not in the open heap, then this value is undefined.
        */
        int open_idx;

        inline int value() const {return distance + guess;}
    };

    void _allocNodeCache(int iWidth, int iHeight);

    node_t* _openHeapPop();
    void _openHeapPush(node_t* pNode);
    void _openHeapPromote(node_t* pNode);

    const THMap *m_pDefaultMap;

    //! 2D array of nodes, one for each map cell
    node_t *m_pNodes;

    //! Array of "dirty" nodes which need to be reset before the next path find
    /*!
        This array is always large enough to hold every single node, and
        m_iDirtyCount holds the number of items currently in the array.
    */
    node_t **m_ppDirtyList;

    //! Heap of not yet evaluated nodes as a 0-based array
    /*!
        This array conforms to the conditions:
          value(i) <= value(i * 2 + 1)
          value(i) <= value(i * 2 + 2)
        This causes the array to be a minimum binary heap.

        Note that unlike the dirty list, there is only space for m_iOpenSize
        items (with m_iOpenCount being the current number of items).
    */
    node_t **m_ppOpenHeap;

    node_t *m_pDestination;
    int m_iNodeCacheWidth;
    int m_iNodeCacheHeight;
    int m_iDirtyCount;
    int m_iOpenCount;
    int m_iOpenSize;
};

#endif // CORSIX_TH_TH_PATHFIND_H_
