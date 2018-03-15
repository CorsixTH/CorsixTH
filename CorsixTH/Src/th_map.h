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

#ifndef CORSIX_TH_TH_MAP_H_
#define CORSIX_TH_TH_MAP_H_
#include "th_gfx.h"
#include <list>
#include <string>

/*
    Object type enumeration uses same values as original TH does.
    See game string table section 39 for proof. Section 1 also has
    names in this order.
*/
enum class object_type : uint8_t
{
    no_object = 0,
    desk = 1,
    cabinet = 2,
    door = 3,
    bench = 4,
    table = 5, // Not in game
    chair = 6,
    drinks_machine = 7,
    bed = 8,
    inflator = 9,
    pool_table = 10,
    reception_desk = 11,
    b_table = 12, // Not in game?
    cardio = 13,
    scanner = 14,
    scanner_console = 15,
    screen = 16,
    litter_bomb = 17,
    couch = 18,
    sofa = 19,
    crash = 20, // The trolley in general diagnosis
    tv = 21,
    ultrascan = 22,
    dna_fixer = 23,
    cast_remover = 24,
    hair_restorer = 25,
    slicer = 26,
    xray = 27,
    radiation_shield = 28,
    xray_viewer = 29,
    op_table = 30,
    lamp = 31, // Not in game?
    sink = 32,
    op_sink1 = 33,
    op_sink2 = 34,
    surgeon_screen = 35,
    lecture_chair = 36,
    projector = 37,
    // 38 is unused
    pharmacy = 39,
    computer = 40,
    chemical_mixer = 41,
    blood_machine = 42,
    extinguisher = 43,
    radiator = 44,
    plant = 45,
    electro = 46,
    jelly_vat = 47,
    hell = 48,
    // 49 is unused
    bin = 50,
    loo = 51,
    double_door1 = 52,
    double_door2 = 53,
    decon_shower = 54,
    autopsy = 55,
    bookcase = 56,
    video_game = 57,
    entrance_left_door = 58,
    entrance_right_door = 59,
    skeleton = 60,
    comfy_chair = 61,
    litter = 62,
    helicopter = 63,
    rathole = 64,
    // 65 through 255 are unused
};

//! Map flags and object type
//! The point of storing the object type here is to allow pathfinding code
//! to use object types as pathfinding goals.
struct map_tile_flags
{
    enum class key : uint32_t {
         passable_mask = 1 << 0,
         can_travel_n_mask = 1 << 1,
         can_travel_e_mask = 1 << 2,
         can_travel_s_mask = 1 << 3,
         can_travel_w_mask = 1 << 4,
         hospital_mask = 1 << 5,
         buildable_mask = 1 << 6,
         passable_if_not_for_blueprint_mask = 1 << 7,
         room_mask = 1 << 8,
         shadow_half_mask = 1 << 9,
         shadow_full_mask = 1 << 10,
         shadow_wall_mask = 1 << 11,
         door_north_mask = 1 << 12,
         door_west_mask = 1 << 13,
         do_not_idle_mask = 1 << 14,
         tall_north_mask = 1 << 15,
         tall_west_mask = 1 << 16,
         buildable_n_mask = 1 << 17,
         buildable_e_mask = 1 << 18,
         buildable_s_mask = 1 << 19,
         buildable_w_mask = 1 << 20,
    };

    bool passable;  //!< Pathfinding: Can walk on this tile
    bool can_travel_n; //!< Pathfinding: Can walk to the north
    bool can_travel_e; //!< Pathfinding: Can walk to the east
    bool can_travel_s; //!< Pathfinding: Can walk to the south
    bool can_travel_w; //!< Pathfinding: Can walk to the west
    bool hospital; //!< World: Tile is inside a hospital building
    bool buildable; //!< Player: Can build on this tile
    bool passable_if_not_for_blueprint;
    bool room; //!< World: Tile is inside a room
    bool shadow_half; //!< Rendering: Put block 75 over floor
    bool shadow_full; //!< Rendering: Put block 74 over floor
    bool shadow_wall; //!< Rendering: Put block 156 over east wall
    bool door_north; //!< World: Door on north wall of tile
    bool door_west; //!< World: Door on west wall of tile
    bool do_not_idle; //!< World: Humanoids should not idle on tile
    bool tall_north; //!< Shadows: Wall-like object on north wall
    bool tall_west; //!< Shadows: Wall-like object on west wall
    bool buildable_n; //!< Can build on the north side of the tile
    bool buildable_e; //!< Can build on the east side of the tile
    bool buildable_s; //!< Can build on the south side of the tile
    bool buildable_w; //!< Can build on the west side of the tile

    //! Convert the given uint32_t reprentation of the map_tile flags
    //! to a map_tile_flags instance.
    map_tile_flags& operator =(uint32_t raw);

    //! Get/set the flag with the given key
    bool& operator[] (map_tile_flags::key key);

    //! Get the flag with the given key
    const bool& operator[](map_tile_flags::key key) const;

    //! Convert map_tile_flags into it's uint32_t representation
    operator uint32_t() const;
};

enum class temperature_theme {
    red,         //!< Default warmth colouring (red gradients)
    multi_colour, //!< Different colours (blue, green, red)
    yellow_red    //!< Gradients of yellow, orange, and red
};

struct map_tile : public link_list
{
    map_tile();
    ~map_tile();

    // Linked list for entities rendered at this tile
    // THLinkList::pPrev (will always be nullptr)
    // THLinkList::pNext

    //! Linked list for entities rendered in an early (right-to-left) pass
    link_list oEarlyEntities;

    //! Block tiles for rendering
    //! For each tile, the lower byte is the index in the sprite sheet, and the
    //! upper byte is for the drawing flags.
    //! Layer 0 is for the floor
    //! Layer 1 is for the north wall
    //! Layer 2 is for the west wall
    //! Layer 3 is for the UI
    //! NB: In Lua, layers are numbered 1 - 4 rather than 0 - 3
    uint16_t iBlock[4];

    //! Parcels (plots) of land have an ID, with each tile in the plot having
    //! that ID. Parcel 0 is the outside.
    uint16_t iParcelId;

    //! Rooms have an ID, with room #0 being the corridor (and the outside).
    uint16_t iRoomId;

    //! A value between 0 (extreme cold) and 65535 (extreme heat) representing
    //! the temperature of the tile. To allow efficient calculation of a tile's
    //! heat based on the previous tick's heat of the surrounding tiles, the
    //! previous temperature is also stored, with the array indices switching
    //! every tick.
    uint16_t aiTemperature[2];

    //! Flags for information and object type
    map_tile_flags flags;

    //! objects in this tile
    std::list<object_type> objects;
};

class sprite_sheet;

//! Prototype for object callbacks from THMap::loadFromTHFile
/*!
    The callback function will receive 5 arguments:
      * The opaque pointer passed to THMap::loadFromTHFile (pCallbackToken).
      * The tile X/Y position of the object.
      * The object type.
      * The object flags present in the map data. The meaning of this
        value is left unspecified.
*/
typedef void (*map_load_object_callback_fn)(void*, int, int, object_type, uint8_t);

class map_overlay;

class level_map
{
public:
    level_map();
    ~level_map();

    bool set_size(int iWidth, int iHeight);
    bool load_blank();
    bool load_from_th_file(const uint8_t* pData, size_t iDataLength,
                        map_load_object_callback_fn fnObjectCallback,
                        void* pCallbackToken);

    void save(std::string filename);

    //! Set the sprite sheet to be used for drawing the map
    /*!
        The sprites for map floor tiles, wall tiles, and map decorators
        all come from the given sheet.
    */
    void set_block_sheet(sprite_sheet* pSheet);

    //! Set the draw flags on all wall blocks
    /*!
        This is typically called with THDF_Alpha50 to draw walls transparently,
        or with 0 to draw them opaque again.
    */
    void set_all_wall_draw_flags(uint8_t iFlags);

    void update_pathfinding();
    void update_shadows();
    void set_temperature_display(temperature_theme eTempDisplay);
    inline temperature_theme get_temperature_display() const {return current_temperature_theme;}
    void update_temperatures(uint16_t iAirTemperature,
                            uint16_t iRadiatorTemperature);

    //! Get the map width (in tiles)
    inline int get_width()  const {return width;}

    //! Get the map height (in tiles)
    inline int get_height() const {return height;}

    //! Get the number of plots of land in this map
    inline int get_parcel_count() const {return parcel_count - 1;}

    inline int get_player_count() const {return player_count;}

    void set_player_count(int count);

    bool get_player_camera_tile(int iPlayer, int* pX, int* pY) const;
    bool get_player_heliport_tile(int iPlayer, int* pX, int* pY) const;
    void set_player_camera_tile(int iPlayer, int iX, int iY);
    void set_player_heliport_tile(int iPlayer, int iX, int iY);

    //! Get the number of tiles inside a given parcel
    int get_parcel_tile_count(int iParcelId) const;

    //! Change the owner of a particular parcel
    /*!
        \param iParcelId The parcel of land to change ownership of. Should be
            an integer between 1 and getParcelCount() inclusive (parcel 0 is
            the outside, and should never have its ownership changed).
        \param iOwner The number of the player who should own the parcel, or
            zero if no player should own the parcel.
        \return vSplitTiles A vector that contains tile coordinates where
            iParcelId is adjacent to another part of the hospital.
    */
    std::vector<std::pair<int, int>> set_parcel_owner(int iParcelId, int iOwner);

    //! Get the owner of a particular parcel of land
    /*!
        \param iParcelId An integer between 0 and getParcelCount() inclusive.
        \return 0 if the parcel is unowned, otherwise the number of the owning
            player.
    */
    int get_parcel_owner(int iParcelId) const;

    //! Query if two parcels are directly connected
    /*!
        \param iParcel1 An integer between 0 and getParcelCount() inclusive.
        \param iParcel2 An integer between 0 and getParcelCount() inclusive.
        \return true if there is a path between the two parcels which does not
            go into any other parcels. false otherwise.
    */
    bool are_parcels_adjacent(int iParcel1, int iParcel2);

    //! Query if a given player is in a position to purchase a given parcel
    /*!
        \param iParcelId The parcel of land to query. Should be an integer
            between 1 and getParcelCount() inclusive.
        \param iPlayer The number of the player to perform the query on behalf
            of. Should be a strictly positive integer.
        \return true if the parcel has a door to the outside, or is directly
            connected to a parcel already owned by the given player. false
            otherwise.
    */
    bool is_parcel_purchasable(int iParcelId, int iPlayer);

    //! Draw the map (and any attached animations)
    /*!
        Draws the world pixel rectangle (iScreenX, iScreenY, iWidth, iHeight)
        to the rectangle (iCanvasX, iCanvasY, iWidth, iHeight) on pCanvas. Note
        that world pixel co-ordinates are also known as absolute screen
        co-ordinates - they are not world (tile) co-ordinates, nor (relative)
        screen co-ordinates.
    */
    void draw(render_target* pCanvas, int iScreenX, int iScreenY, int iWidth,
              int iHeight, int iCanvasX, int iCanvasY) const;

    //! Perform a hit-test against the animations attached to the map
    /*!
        If there is an animation at world pixel co-ordinates (iTestX, iTestY),
        then it is returned. Otherwise nullptr is returned.
        To perform a hit-test using world (tile) co-ordinates, get the tile
        itself and query the top 8 bits of map_tile::flags, or traverse the
        tile's animation lists.
    */
    drawable* hit_test(int iTestX, int iTestY) const;

    // When using the unchecked versions, the map co-ordinates MUST be valid.
    // When using the normal versions, nullptr is returned for invalid co-ords.
          map_tile* get_tile(int iX, int iY);
    const map_tile* get_tile(int iX, int iY) const;
    const map_tile* get_original_tile(int iX, int iY) const;
          map_tile* get_tile_unchecked(int iX, int iY);
    const map_tile* get_tile_unchecked(int iX, int iY) const;
    const map_tile* get_original_tile_unchecked(int iX, int iY) const;

    uint16_t get_tile_temperature(const map_tile* pNode) const;
    int get_tile_owner(const map_tile* pNode) const;

    //! Convert world (tile) co-ordinates to absolute screen co-ordinates
    template <typename T>
    static inline void world_to_screen(T& x, T& y)
    {
        T x_(x);
        x = (T)32 * (x_ - y);
        y = (T)16 * (x_ + y);
    }

    //! Convert absolute screen co-ordinates to world (tile) co-ordinates
    template <typename T>
    static inline void screen_to_world(T& x, T& y)
    {
        T x_(x);
        x = y / (T)32 + x_ / (T)64;
        y = y / (T)32 - x_ / (T)64;
    }

    void persist(lua_persist_writer *pWriter) const;
    void depersist(lua_persist_reader *pReader);

    void set_overlay(map_overlay *pOverlay, bool bTakeOwnership);

private:
    drawable* hit_test_drawables(link_list* pListStart, int iXs, int iYs,
                                 int iTestX, int iTestY) const;
    void read_tile_index(const uint8_t* pData, int& iX, int &iY) const;
    void write_tile_index(uint8_t* pData, int iX, int iY) const;

    //! Calculate a weighted impact of a neighbour tile on the temperature of the current tile.
    //! \param iNeighbourSum Incremented by the temperature of the tile multiplied by the weight of the connection.
    //! \param canTravel A tile flag indicating whether travel between this tile and it's neighbour is allowed.
    //! \param relative_idx The index of the neighbour tile, relative to this tile into cells.
    //! \param pNode A pointer to the current tile being tested.
    //! \param prevTemp The array index into map_tile::temperature that currently stores the temperature of the tile (prior to this calculation).
    //! \return The weight of the connection, 0 if there is no neighbour, 1 through walls, and 4 through air.
    uint32_t thermal_neighbour(uint32_t &iNeighbourSum, bool canTravel, std::ptrdiff_t relative_idx, map_tile* pNode, int prevTemp) const;

    //! Create the adjacency matrix if it doesn't already exist
    void make_adjacency_matrix();

    //! Create the purchasability matrix if it doesn't already exist
    void make_purchase_matrix();

    //! If it exists, update the purchasability matrix.
    void update_purchase_matrix();
    
    int count_parcel_tiles(int iParcelId) const;

    map_tile* cells;
    map_tile* original_cells; // Cells at map load time, before any changes
    sprite_sheet* blocks;
    map_overlay* overlay;
    bool owns_overlay;
    int* plot_owner; // 0 for unowned, 1 for player 1, etc.
    int width;
    int height;
    int player_count;
    int initial_camera_x[4];
    int initial_camera_y[4];
    int heliport_x[4];
    int heliport_y[4];
    int parcel_count;
    int current_temperature_index;
    temperature_theme current_temperature_theme;
    int* parcel_tile_counts;

    // 2D symmetric array giving true if there is a path between two parcels
    // which doesn't go into any other parcels.
    bool* parcel_adjacency_matrix;

    // 4 by N matrix giving true if player can purchase parcel.
    bool* purchasable_matrix;
};

enum class map_scanline_iterator_direction {
    forward = 2,
    backward = 0,
};

//! Utility class for iterating over map tiles within a screen rectangle
/*!
    To easily iterate over the map tiles which might draw something within a
    certain rectangle of screen space, an instance of this class can be used.

    By default, it iterates by scanline, top-to-bottom, and then left-to-right
    within each scanline. Alternatively, by passing ScanlineBackward to the
    constructor, it will iterate bottom-to-top. Within a scanline, to visit
    tiles right-to-left, wait until isLastOnScanline() returns true, then use
    an instance of THMapScanlineIterator.
*/
class map_tile_iterator
{
public:
    map_tile_iterator();

    /*!
        @arg pMap The map whose tiles should be iterated
        @arg iScreenX The X co-ordinate of the top-left corner of the
            screen-space rectangle to iterate.
        @arg iScreenY The Y co-ordinate of the top-left corner of the
            screen-space rectangle to iterate.
        @arg iWidth The width of the screen-space rectangle to iterate.
        @arg iHeight The width of the screen-space rectangle to iterate.
        @arg eScanlineDirection The direction in which to iterate scanlines;
            forward for top-to-bottom, backward for bottom-to-top.
    */
    map_tile_iterator(const level_map*pMap, int iScreenX, int iScreenY,
        int iWidth, int iHeight,
        map_scanline_iterator_direction eScanlineDirection = map_scanline_iterator_direction::forward);

    //! Returns false iff the iterator has exhausted its tiles
    inline operator bool () const {return tile != nullptr;}

    //! Advances the iterator to the next tile
    inline map_tile_iterator& operator ++ ();

    //! Accessor for the current tile
    inline const map_tile* operator -> () const {return tile;}

    //! Get the X position of the tile relative to the top-left corner of the screen-space rectangle
    inline int tile_x_position_on_screen() const {return x_relative_to_screen;}

    //! Get the Y position of the tile relative to the top-left corner of the screen-space rectangle
    inline int tile_y_position_on_screen() const {return y_relative_to_screen;}

    inline int tile_x() const {return world_x;}
    inline int tile_y() const {return world_y;}

    inline const level_map *get_map() {return container;}
    inline const map_tile *get_map_tile() {return tile;}
    inline int get_scanline_count() { return scanline_count;}
    inline int get_tile_step() {return (static_cast<int>(direction) - 1) * (1 - container->get_width());}

    //! Returns true iff the next tile will be on a different scanline
    /*!
        To visit a scanline in right-to-left order, or to revisit a scanline,
        wait until this method returns true, then use a THMapScanlineIterator.
    */
    inline bool is_last_on_scanline() const;

private:
    // Maximum extents of the visible parts of a tile (pixel distances relative
    // to the top-most corner of an isometric cell)
    // If set too low, things will disappear when near the screen edge
    // If set too high, rendering will slow down
    static const int margin_top = 150;
    static const int margin_left = 110;
    static const int margin_right = 110;
    static const int margin_bottom = 150;

    friend class map_scanline_iterator;

    const map_tile* tile;
    const level_map* container;

    // TODO: Consider removing these, they are trivial to calculate
    int x_relative_to_screen;
    int y_relative_to_screen;

    const int screen_offset_x;
    const int screen_offset_y;
    const int screen_width;
    const int screen_height;
    int base_x;
    int base_y;
    int world_x;
    int world_y;
    int scanline_count;
    map_scanline_iterator_direction direction;

    void advance_until_visible();
};

//! Utility class for re-iterating a scanline visited by a map_tile_iterator
class map_scanline_iterator
{
public:
    map_scanline_iterator();

    /*!
        @arg itrNodes A tile iterator which has reached the end of a scanline
        @arg eDirection The direction in which to iterate the scanline;
            forward for left-to-right, backward for right-to-left.
        @arg iXOffset If given, values returned by x() will be offset by this.
        @arg iYOffset If given, values returned by y() will be offset by this.
    */
    map_scanline_iterator(const map_tile_iterator& itrNodes,
                          map_scanline_iterator_direction eDirection,
                          int iXOffset = 0, int iYOffset = 0);

    inline operator bool () const {return tile != end_tile;}
    inline map_scanline_iterator& operator ++ ();

    inline const map_tile* operator -> () const {return tile;}
    inline int x() const {return x_relative_to_screen;}
    inline int y() const {return y_relative_to_screen;}
    inline const map_tile* get_next_tile()  {return tile + tile_step;}
    inline const map_tile* get_previous_tile() { return tile - tile_step;}
    map_scanline_iterator operator= (const map_scanline_iterator &iterator);
    inline const map_tile* get_tile() {return tile;}

private:
    const map_tile* tile;
    const map_tile* first_tile;
    const map_tile* end_tile;
    int tile_step;
    int x_step;
    int x_relative_to_screen;
    int y_relative_to_screen;
    int steps_taken;
};

#endif // CORSIX_TH_TH_MAP_H_
