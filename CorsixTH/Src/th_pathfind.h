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

class THPath
{
public:
    unsigned short getLength();
    int getX(unsigned short iIndex);
    int getY(unsigned short iIndex);
};

struct lua_State;

class THPathfinder
{
public:
    THPathfinder();
    ~THPathfinder();

    void setDefaultMap(const THMap *pMap);

    bool findPath(const THMap *pMap, int iStartX, int iStartY, int iEndX, int iEndY);

    int getPathLength() const;
    void pushResult(lua_State *L) const;

protected:
    friend struct node_compare;

    struct node_t
    {
        node_t* prev;
        int x;
        int y;
        int distance;
        int guess;
    };

    void _allocNodeCache(int iWidth, int iHeight);

    const THMap *m_pDefaultMap;
    node_t *m_pNodes;
    node_t **m_ppDirtyList;
    node_t *m_pDestination;
    int m_iNodeCacheWidth;
    int m_iNodeCacheHeight;
    int m_iDirtyCount;
};

#endif // CORSIX_TH_TH_PATHFIND_H_
