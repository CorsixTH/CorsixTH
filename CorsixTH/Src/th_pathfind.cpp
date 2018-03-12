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

abstract_pathfinder::abstract_pathfinder(pathfinder *pf) : parent(pf)
{ }

path_node *abstract_pathfinder::init(const level_map *pMap, int iStartX, int iStartY)
{
    int iWidth = pMap->get_width();
    parent->destination = nullptr;
    parent->allocate_node_cache(iWidth, pMap->get_height());
    path_node *pNode = parent->nodes + iStartY * iWidth + iStartX;
    pNode->prev = nullptr;
    pNode->distance = 0;
    pNode->guess = guess_distance(pNode);
    parent->dirty_node_list[0] = pNode;
    parent->dirty_node_count = 1;
    parent->open_heap.clear();
    return pNode;
}

/*! No need to check for the node being on the map edge, as the N/E/S/W
    flags are set as to prevent travelling off the map (as well as to
    prevent walking through walls).
 */
bool abstract_pathfinder::search_neighbours(path_node *pNode, map_tile_flags flags, int iWidth)
{
    if(flags.can_travel_w)
        if(try_node(pNode, flags, pNode - 1, travel_direction::west)) return true;

    if(flags.can_travel_e)
        if (try_node(pNode, flags, pNode + 1, travel_direction::east)) return true;

    if(flags.can_travel_n)
        if (try_node(pNode, flags, pNode - iWidth, travel_direction::north)) return true;

    if(flags.can_travel_s)
        if (try_node(pNode, flags, pNode + iWidth, travel_direction::south)) return true;

    return false;
}

void abstract_pathfinder::record_neighbour_if_passable(path_node *pNode, map_tile_flags neighbour_flags, bool passable, path_node *pNeighbour)
{
    if(neighbour_flags.passable || !passable)
    {
        if(pNeighbour->prev == pNeighbour)
        {
            pNeighbour->prev = pNode;
            pNeighbour->distance = pNode->distance + 1;
            pNeighbour->guess = guess_distance(pNeighbour);
            parent->dirty_node_list[parent->dirty_node_count++] = pNeighbour;
            parent->push_to_open_heap(pNeighbour);
        }
        else if(pNode->distance + 1 < pNeighbour->distance)
        {
            pNeighbour->prev = pNode;
            pNeighbour->distance = pNode->distance + 1;
            /* guess doesn't change, and already in the dirty list */
            parent->open_heap_promote(pNeighbour);
        }
    }
}

int basic_pathfinder::guess_distance(path_node *pNode)
{
    // As diagonal movement is not allowed, the minimum distance between two
    // points is the sum of the distance in X and the distance in Y.
    return abs(pNode->x - destination_x) + abs(pNode->y - destination_y);
}

bool basic_pathfinder::try_node(path_node *pNode, map_tile_flags flags,
                         path_node *pNeighbour, travel_direction direction)
{
    map_tile_flags neighbour_flags = map->get_tile_unchecked(pNeighbour->x, pNeighbour->y)->flags;
    record_neighbour_if_passable(pNode, neighbour_flags, flags.passable, pNeighbour);
    return false;
}

bool basic_pathfinder::find_path(const level_map *pMap, int iStartX, int iStartY, int iEndX, int iEndY)
{
    if(pMap == nullptr)
        pMap = parent->default_map;
    if(pMap == nullptr || pMap->get_tile(iEndX, iEndY) == nullptr
        || !pMap->get_tile_unchecked(iEndX, iEndY)->flags.passable)
    {
        parent->destination = nullptr;
        return false;
    }

    map = pMap;
    destination_x = iEndX;
    destination_y = iEndY;

    path_node *pNode = init(pMap, iStartX, iStartY);
    int iWidth = pMap->get_width();
    path_node *pTarget = parent->nodes + iEndY * iWidth + iEndX;

    while(true)
    {
        if(pNode == pTarget)
        {
            parent->destination = pTarget;
            return true;
        }

        map_tile_flags flags = pMap->get_tile_unchecked(pNode->x, pNode->y)->flags;
        if (search_neighbours(pNode, flags, iWidth)) return true;

        if (parent->open_heap.empty()) {
            parent->destination = nullptr;
            break;
        } else {
            pNode = parent->pop_from_open_heap();
        }
    }
    return false;
}

int hospital_finder::guess_distance(path_node *pNode)
{
    return 0;
}

bool hospital_finder::try_node(path_node *pNode, map_tile_flags flags,
                             path_node *pNeighbour, travel_direction direction)
{
    map_tile_flags neighbour_flags = map->get_tile_unchecked(pNeighbour->x, pNeighbour->y)->flags;
    record_neighbour_if_passable(pNode, neighbour_flags, flags.passable, pNeighbour);
    return false;
}

bool hospital_finder::find_path_to_hospital(const level_map *pMap, int iStartX, int iStartY)
{
    if(pMap == nullptr)
        pMap = parent->default_map;
    if(pMap == nullptr || pMap->get_tile(iStartX, iStartY) == nullptr
        || !pMap->get_tile_unchecked(iStartX, iStartY)->flags.passable)
    {
        parent->destination = nullptr;
        return false;
    }

    map = pMap;

    path_node *pNode = init(pMap, iStartX, iStartY);
    int iWidth = pMap->get_width();

    while(true)
    {
        map_tile_flags flags = pMap->get_tile_unchecked(pNode->x, pNode->y)->flags;

        if(flags.hospital)
        {
            parent->destination = pNode;
            return true;
        }

        if (search_neighbours(pNode, flags, iWidth)) return true;

        if (parent->open_heap.empty()) {
            parent->destination = nullptr;
            break;
        } else {
            pNode = parent->pop_from_open_heap();
        }
    }
    return false;
}

int idle_tile_finder::guess_distance(path_node *pNode)
{
    return 0;
}

bool idle_tile_finder::try_node(path_node *pNode, map_tile_flags flags,
                             path_node *pNeighbour, travel_direction direction)
{
    map_tile_flags neighbour_flags = map->get_tile_unchecked(pNeighbour->x, pNeighbour->y)->flags;
    /* When finding an idle tile, do not navigate through doors */
    switch(direction)
    {
    case travel_direction::north:
        if(!flags.door_north)
            record_neighbour_if_passable(pNode, neighbour_flags, flags.passable, pNeighbour);
        break;

    case travel_direction::east:
        if(!neighbour_flags.door_west)
            record_neighbour_if_passable(pNode, neighbour_flags, flags.passable, pNeighbour);
        break;

    case travel_direction::south:
        if(!neighbour_flags.door_north)
            record_neighbour_if_passable(pNode, neighbour_flags, flags.passable, pNeighbour);
        break;

    case travel_direction::west:
        if(!flags.door_west)
            record_neighbour_if_passable(pNode, neighbour_flags, flags.passable, pNeighbour);
        break;
    }

    /* Identify the neighbour in the open list nearest to the start */
    if(pNeighbour->prev != pNeighbour && pNeighbour->open_idx != -1)
    {
        int iDX = pNeighbour->x - start_x;
        int iDY = pNeighbour->y - start_y;
        double fDistance = sqrt((double)(iDX * iDX + iDY * iDY));
        if(best_next_node == nullptr || fDistance < best_distance)
        {
            best_next_node = pNeighbour; best_distance = fDistance;
        }
    }
    return false;
}

bool idle_tile_finder::find_idle_tile(const level_map *pMap, int iStartX, int iStartY, int iN)
{
    if(pMap == nullptr)
        pMap = parent->default_map;
    if(pMap == nullptr)
    {
        parent->destination = nullptr;
        return false;
    }

    start_x = iStartX;
    start_y = iStartY;
    map = pMap;

    path_node *pNode = init(pMap, iStartX, iStartY);
    int iWidth = pMap->get_width();
    path_node *pPossibleResult = nullptr;

    while(true)
    {
        pNode->open_idx = -1;
        map_tile_flags flags = pMap->get_tile_unchecked(pNode->x, pNode->y)->flags;

        if(!flags.do_not_idle && flags.passable && flags.hospital)
        {
            if(iN == 0)
            {
                parent->destination = pNode;
                return true;
            }
            else
            {
                pPossibleResult = pNode;
                --iN;
            }
        }

        best_next_node = nullptr;
        best_distance = 0.0;

        if (search_neighbours(pNode, flags, iWidth)) return true;

        if (parent->open_heap.empty()) {
            parent->destination = nullptr;
            break;
        }

        if(best_next_node)
        {
            // Promote the best neighbour to the front of the open list
            // This causes sequential iN to give neighbouring results for most iN
            best_next_node->guess = -best_next_node->distance;
            parent->open_heap_promote(best_next_node);
        }
        pNode = parent->pop_from_open_heap();
    }
    if(pPossibleResult)
    {
        parent->destination = pPossibleResult;
        return true;
    }
    return false;
}

int object_visitor::guess_distance(path_node *pNode)
{
    return 0;
}

bool object_visitor::try_node(path_node *pNode, map_tile_flags flags, path_node *pNeighbour, travel_direction direction)
{
    int iObjectNumber = 0;
    const map_tile *pMapNode = map->get_tile_unchecked(pNeighbour->x, pNeighbour->y);
    map_tile_flags neighbour_flags = map->get_tile_unchecked(pNeighbour->x, pNeighbour->y)->flags;
    for(auto thob : pMapNode->objects)
    {
        if(thob == target)
            iObjectNumber++;
    }
    if(target_any_object_type)
        iObjectNumber = 1;
    bool bSucces = false;
    for(int i = 0; i < iObjectNumber; i++)
    {
        /* call the given Lua function, passing four arguments: */
        /* The x and y position of the object (Lua tile co-ords) */
        /* The direction which was last travelled in to reach (x,y); */
        /*   0 (north), 1 (east), 2 (south), 3 (west) */
        /* The distance to the object from the search starting point */
        lua_pushvalue(L, visit_function_index);
        lua_pushinteger(L, pNeighbour->x + 1);
        lua_pushinteger(L, pNeighbour->y + 1);
        lua_pushinteger(L, static_cast<int>(direction));
        lua_pushinteger(L, pNode->distance);
        lua_call(L, 4, 1);
        if(lua_toboolean(L, -1) != 0)
        {
            bSucces = true;
        }
        lua_pop(L, 1);
    }
    if(bSucces)
        return true;

    if(pNode->distance < max_distance)
    {
        switch(direction)
        {
        case travel_direction::north:
            if(!flags.door_north)
                record_neighbour_if_passable(pNode, neighbour_flags, flags.passable, pNeighbour);
            break;

        case travel_direction::east:
            if(!neighbour_flags.door_west)
                record_neighbour_if_passable(pNode, neighbour_flags, flags.passable, pNeighbour);
            break;

        case travel_direction::south:
            if(!neighbour_flags.door_north)
                record_neighbour_if_passable(pNode, neighbour_flags, flags.passable, pNeighbour);
            break;

        case travel_direction::west:
            if(!flags.door_west)
                record_neighbour_if_passable(pNode, neighbour_flags, flags.passable, pNeighbour);
            break;
        }
    }
    return false;
}

bool object_visitor::visit_objects(const level_map *pMap, int iStartX, int iStartY,
                                  object_type eTHOB, int iMaxDistance,
                                  lua_State *L, int iVisitFunction, bool anyObjectType)
{
    if(pMap == nullptr)
        pMap = parent->default_map;
    if(pMap == nullptr)
    {
        parent->destination = nullptr;
        return false;
    }

    this->L = L;
    visit_function_index = iVisitFunction;
    max_distance = iMaxDistance;
    target_any_object_type = anyObjectType;
    target = eTHOB;
    map = pMap;

    path_node *pNode = init(pMap, iStartX, iStartY);
    int iWidth = pMap->get_width();

    while(true)
    {
        map_tile_flags flags = pMap->get_tile_unchecked(pNode->x, pNode->y)->flags;
        if (search_neighbours(pNode, flags, iWidth)) return true;

        if (parent->open_heap.empty()) {
            parent->destination = nullptr;
            break;
        } else {
            pNode = parent->pop_from_open_heap();
        }
    }
    return false;
}

pathfinder::pathfinder() : basic_pathfinder(this), hospital_finder(this),
                               idle_tile_finder(this), object_visitor(this),
                               open_heap()
{
    nodes = nullptr;
    dirty_node_list = nullptr;
    destination = nullptr;
    default_map = nullptr;
    node_cache_width = 0;
    node_cache_height = 0;
    dirty_node_count = 0;
}

pathfinder::~pathfinder()
{
    delete[] nodes;
    delete[] dirty_node_list;
}

void pathfinder::set_default_map(const level_map *pMap)
{
    default_map = pMap;
}



void pathfinder::allocate_node_cache(int iWidth, int iHeight)
{
    if(node_cache_width != iWidth || node_cache_height != iHeight)
    {
        delete[] nodes;
        nodes = new path_node[iWidth * iHeight];
        path_node *pNode = nodes;
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
        delete[] dirty_node_list;
        dirty_node_list = new path_node*[iWidth * iHeight];
        node_cache_width = iWidth;
        node_cache_height = iHeight;
    }
    else
    {
        for(int i = 0; i < dirty_node_count; ++i)
        {
            dirty_node_list[i]->prev = dirty_node_list[i];
            // Other fields are undefined as the node is not part of a path,
            // and thus can keep their old values.
        }
    }
    dirty_node_count = 0;
}

int pathfinder::get_path_length() const
{
    if(destination != nullptr)
        return destination->distance;
    else
        return -1;
}

bool pathfinder::get_path_end(int* pX, int* pY) const
{
    if(destination == nullptr)
    {
        if(pX)
            *pX = -1;
        if(pY)
            *pY = -1;
        return false;
    }
    if(pX)
        *pX = destination->x;
    if(pY)
        *pY = destination->y;
    return true;
}

void pathfinder::push_result(lua_State *L) const
{
    lua_checkstack(L, 3);

    if(destination == nullptr)
    {
        lua_pushnil(L);
        lua_pushliteral(L, "no path");
        return;
    }

    int iLength = destination->distance;
    lua_createtable(L, iLength + 1, 0);
    lua_createtable(L, iLength + 1, 0);

    for(const path_node* pNode = destination; pNode; pNode = pNode->prev)
    {
        lua_pushinteger(L, pNode->x + 1);
        lua_rawseti(L, -3, pNode->distance + 1);
        lua_pushinteger(L, pNode->y + 1);
        lua_rawseti(L, -2, pNode->distance + 1);
    }
}

void pathfinder::push_to_open_heap(path_node* pNode)
{
    pNode->open_idx = open_heap.size();
    open_heap.push_back(pNode);
    open_heap_promote(pNode);
}

void pathfinder::open_heap_promote(path_node* pNode)
{
    int i = pNode->open_idx;
    while(i > 0)
    {
        int parent = (i - 1) / 2;
        path_node *pParent = open_heap[parent];
        if(pParent->value() <= pNode->value())
            break;
        pParent->open_idx = i;
        open_heap[i] = pParent;
        open_heap[parent] = pNode;
        i = parent;
    }
    pNode->open_idx = i;
}

path_node* pathfinder::pop_from_open_heap()
{
    path_node *pResult = open_heap[0];
    path_node *pNode = open_heap.back();
    open_heap.pop_back();

    if (open_heap.empty()) {
        return pResult;
    }

    open_heap[0] = pNode;
    int i = 0;
    int min = 0;
    int left = i * 2 + 1;
    const int value = pNode->value();
    while(left < open_heap.size())
    {
        min = i;
        const int right = (i + 1) * 2;
        int minvalue = value;
        path_node *pSwap = nullptr;
        path_node *pTest = open_heap[left];
        if(pTest->value() < minvalue)
            min = left, minvalue = pTest->value(), pSwap = pTest;
        if(right < open_heap.size())
        {
            pTest = open_heap[right];
            if(pTest->value() < minvalue)
                min = right, pSwap = pTest;
        }
        if(min == i)
            break;

        pSwap->open_idx = i;
        open_heap[i] = pSwap;
        open_heap[min] = pNode;
        i = min;
        left = i * 2 + 1;
    }
    pNode->open_idx = min;
    return pResult;
}

void pathfinder::persist(lua_persist_writer *pWriter) const
{
    if(destination == nullptr)
    {
        pWriter->write_uint(0);
        return;
    }
    pWriter->write_uint(get_path_length() + 1);
    pWriter->write_uint(node_cache_width);
    pWriter->write_uint(node_cache_height);
    for(const path_node* pNode = destination; pNode; pNode = pNode->prev)
    {
        pWriter->write_uint(pNode->x);
        pWriter->write_uint(pNode->y);
    }
}

void pathfinder::depersist(lua_persist_reader *pReader)
{
    new (this) pathfinder; // Call constructor

    int iLength;
    if(!pReader->read_uint(iLength))
        return;
    if(iLength == 0)
        return;
    int iWidth, iHeight;
    if(!pReader->read_uint(iWidth) || !pReader->read_uint(iHeight))
        return;
    allocate_node_cache(iWidth, iHeight);
    int iX, iY;
    if(!pReader->read_uint(iX) || !pReader->read_uint(iY))
        return;
    path_node *pNode = nodes + iY * iWidth + iX;
    destination = pNode;
    for(int i = 0; i <= iLength - 2; ++i)
    {
        if(!pReader->read_uint(iX) || !pReader->read_uint(iY))
            return;
        path_node *pPrevNode = nodes + iY * iWidth + iX;
        pNode->distance = iLength - 1 - i;
        pNode->prev = pPrevNode;
        dirty_node_list[dirty_node_count++] = pNode;
        pNode = pPrevNode;
    }
    pNode->distance = 0;
    pNode->prev = nullptr;
    dirty_node_list[dirty_node_count++] = pNode;
}
