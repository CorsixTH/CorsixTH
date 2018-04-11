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

class lua_persist_reader;
class lua_persist_writer;
class pathfinder;

/** Directions of movement. */
enum class travel_direction {
    north = 0, ///< Move to the north.
    east = 1, ///< Move to the east.
    south = 2, ///< Move to the south.
    west = 3 ///< Move to the west.
};

/** Node in the path finder routines. */
struct path_node
{
    //! Pointer to the previous node in the path to this cell.
    /*!
        Points to nullptr if this is the first cell in the path, or points to
        itself if it is not part of a path.
    */
    const path_node* prev;

    //! X-position of this cell (constant)
    int x;

    //! Y-position of this cell (constant)
    int y;

    //! Current shortest distance to this cell
    /*!
        Defined as prev->distance + 1 (or 0 if prev == nullptr).
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

    //! Total cost of this node.
    /*!
        @return Total cost of the node, traveled distance and guess to the destination.
     */
    inline int value() const { return distance + guess; }
};

/** Base class of the path finders. */
class abstract_pathfinder
{
public:
    abstract_pathfinder(pathfinder *pf);
    virtual ~abstract_pathfinder() = default;

    //! Initialize the path finder.
    /*!
        @param pMap Map to search on.
        @param iStartX X coordinate of the start position.
        @param iStarty Y coordinate of the start position.
        @return The initial node to expand.
     */
    path_node *init(const level_map *pMap, int iStartX, int iStarty);

    //! Expand the \a pNode to its neighbours.
    /*!
        @param pNode Node to expand.
        @param iFlags Flags of the node.
        @param iWidth Width of the map.
        @return Whether the search is done.
     */
    bool search_neighbours(path_node *pNode, map_tile_flags flags, int iWidth);

    void record_neighbour_if_passable(path_node *pNode, map_tile_flags neighbour_flags,
        bool passable, path_node *pNeighbour);

    //! Guess distance to the destination for \a pNode.
    /*!
        @param pNode Node to fill.
     */
    virtual int guess_distance(path_node *pNode) = 0;

    //! Try the \a pNeighbour node.
    /*!
        @param pNode Source node.
        @param flags Flags of the node.
        @param pNeighbour Neighbour of \a pNode to try.
        @param direction Direction of travel.
        @return Whether the search is done.
     */
    virtual bool try_node(path_node *pNode, map_tile_flags flags,
            path_node *pNeighbour, travel_direction direction) = 0;

protected:
    pathfinder *parent; ///< Path finder parent object, containing shared data.
    const level_map *map; ///< Map being searched.
};

class basic_pathfinder : public abstract_pathfinder
{
public:
    basic_pathfinder(pathfinder *pf) : abstract_pathfinder(pf) { }

    int guess_distance(path_node *pNode) override;
    bool try_node(path_node *pNode, map_tile_flags flags,
            path_node *pNeighbour, travel_direction direction) override;

    bool find_path(const level_map *pMap, int iStartX, int iStartY, int iEndX, int iEndY);

    int destination_x; ///< X coordinate of the destination of the path.
    int destination_y; ///< Y coordinate of the destination of the path.
};

class hospital_finder : public abstract_pathfinder
{
public:
    hospital_finder(pathfinder *pf) : abstract_pathfinder(pf) { }

    int guess_distance(path_node *pNode) override;
    bool try_node(path_node *pNode, map_tile_flags flags,
            path_node *pNeighbour, travel_direction direction) override;

    bool find_path_to_hospital(const level_map *pMap, int iStartX, int iStartY);
};

class idle_tile_finder : public abstract_pathfinder
{
public:
    idle_tile_finder(pathfinder *pf) : abstract_pathfinder(pf) { }

    int guess_distance(path_node *pNode) override;
    bool try_node(path_node *pNode, map_tile_flags flags,
            path_node *pNeighbour, travel_direction direction) override;

    bool find_idle_tile(const level_map *pMap, int iStartX, int iStartY, int iN);

    path_node *best_next_node;
    double best_distance;
    int start_x;       ///< X coordinate of the start position.
    int start_y;       ///< Y coordinate of the start position.
};

class object_visitor : public abstract_pathfinder
{
public:
    object_visitor(pathfinder *pf) : abstract_pathfinder(pf) { }

    int guess_distance(path_node *pNode) override;
    bool try_node(path_node *pNode, map_tile_flags flags,
            path_node *pNeighbour, travel_direction direction) override;

    bool visit_objects(const level_map *pMap, int iStartX, int iStartY,
                      object_type eTHOB, int iMaxDistance,
                      lua_State *L, int iVisitFunction, bool anyObjectType);

    lua_State *L;
    int visit_function_index;
    int max_distance;
    bool target_any_object_type;
    object_type target;
};

//! Finds paths through maps
/*!
    A pathfinder is used for finding a path through a map. A single pathfinder
    instance is not reentrant, but separate instances are. Users of the class
    should call find_path() to test if there is a path between two points on a
    map, and then use get_path_length() and/or push_result() to get the actual
    path.

    Internally, the A* search algorithm is used. The open set is implemented as
    a heap in open_heap, and there is no explicit closed set. For each cell
    of the map, a path_node structure is created (and cached between searches if
    the map size is constant), which holds information about said map cell in
    the current search. The algorithm is implemented in such a way that most
    path find operations do not need to allocate (or free) any memory.
*/
class pathfinder
{
public:
    pathfinder();
    ~pathfinder();

    void set_default_map(const level_map *pMap);

    inline bool find_path(const level_map *pMap, int iStartX, int iStartY, int iEndX,
                         int iEndY)
    {
        return basic_pathfinder.find_path(pMap, iStartX, iStartY, iEndX, iEndY);
    }

    inline bool find_idle_tile(const level_map *pMap, int iStartX, int iStartY, int iN)
    {
        return idle_tile_finder.find_idle_tile(pMap, iStartX, iStartY, iN);
    }

    inline bool find_path_to_hospital(const level_map *pMap, int iStartX, int iStartY)
    {
        return hospital_finder.find_path_to_hospital(pMap, iStartX, iStartY);
    }

    inline bool visit_objects(const level_map *pMap, int iStartX, int iStartY,
                      object_type eTHOB, int iMaxDistance, lua_State *L,
                      int iVisitFunction, bool anyObjectType)
    {
        return object_visitor.visit_objects(
                            pMap, iStartX, iStartY, eTHOB, iMaxDistance,
                            L, iVisitFunction, anyObjectType);
    }

    int get_path_length() const;
    bool get_path_end(int* pX, int* pY) const;
    void push_result(lua_State *L) const;

    void persist(lua_persist_writer *pWriter) const;
    void depersist(lua_persist_reader *pReader);

    //! Allocate node cache for all tiles of the map.
    /*!
        @param iWidth Width of the map.
        @param iHeight Height of the map.
     */
    void allocate_node_cache(int iWidth, int iHeight);

    path_node* pop_from_open_heap();
    void push_to_open_heap(path_node* pNode);
    void open_heap_promote(path_node* pNode);

    const level_map *default_map;

    //! 2D array of nodes, one for each map cell
    path_node *nodes;

    //! Array of "dirty" nodes which need to be reset before the next path find
    /*!
        This array is always large enough to hold every single node, and
        #dirty_node_count holds the number of items currently in the array.
    */
    path_node **dirty_node_list;

    //! Heap of not yet evaluated nodes as a 0-based array
    /*!
        This array conforms to the conditions:
          value(i) <= value(i * 2 + 1)
          value(i) <= value(i * 2 + 2)
        This causes the array to be a minimum binary heap.
    */
    std::vector<path_node*> open_heap;

    path_node *destination;
    int node_cache_width;
    int node_cache_height;
    int dirty_node_count;

private:
    ::basic_pathfinder basic_pathfinder;
    ::hospital_finder hospital_finder;
    ::idle_tile_finder idle_tile_finder;
    ::object_visitor object_visitor;
};

#endif // CORSIX_TH_TH_PATHFIND_H_
