/*
Copyright (c) 2010 Peter "Corsix" Cawley

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

#include "th_lua_internal.h"
#include "th_map.h"
#include "th_pathfind.h"
#include <cstring>
#include <string>
#include <exception>

static const int player_max = 4;

static int l_map_new(lua_State *L)
{
    luaT_stdnew<level_map>(L, luaT_environindex, true);
    return 1;
}

static int l_map_set_sheet(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    sprite_sheet* pSheet = luaT_testuserdata<sprite_sheet>(L, 2);
    lua_settop(L, 2);

    pMap->set_block_sheet(pSheet);
    luaT_setenvfield(L, 1, "sprites");
    return 1;
}

static int l_map_persist(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    pMap->persist((lua_persist_writer*)lua_touserdata(L, 1));
    return 0;
}

static int l_map_depersist(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    lua_persist_reader* pReader = (lua_persist_reader*)lua_touserdata(L, 1);

    pMap->depersist(pReader);
    luaT_getenvfield(L, 2, "sprites");
    pMap->set_block_sheet((sprite_sheet*)lua_touserdata(L, -1));
    lua_pop(L, 1);
    return 0;
}

static void l_map_load_obj_cb(void *pL, int iX, int iY, object_type eTHOB, uint8_t iFlags)
{
    lua_State *L = reinterpret_cast<lua_State*>(pL);
    lua_createtable(L, 4, 0);

    lua_pushinteger(L, 1 + (lua_Integer)iX);
    lua_rawseti(L, -2, 1);
    lua_pushinteger(L, 1 + (lua_Integer)iY);
    lua_rawseti(L, -2, 2);
    lua_pushinteger(L, (lua_Integer)eTHOB);
    lua_rawseti(L, -2, 3);
    lua_pushinteger(L, (lua_Integer)iFlags);
    lua_rawseti(L, -2, 4);

    lua_rawseti(L, 3, static_cast<int>(lua_objlen(L, 3)) + 1);
}

static int l_map_load(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    size_t iDataLen;
    const uint8_t* pData = luaT_checkfile(L, 2, &iDataLen);
    lua_settop(L, 2);
    lua_newtable(L);
    if(pMap->load_from_th_file(pData, iDataLen, l_map_load_obj_cb, (void*)L))
        lua_pushboolean(L, 1);
    else
        lua_pushboolean(L, 0);
    lua_insert(L, -2);
    return 2;
}

static int l_map_loadblank(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    if(pMap->load_blank())
        lua_pushboolean(L, 1);
    else
        lua_pushboolean(L, 0);
    lua_newtable(L);
    return 2;
}

static int l_map_save(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    std::string filename(luaL_checkstring(L, 2));
    pMap->save(filename);
    return 0;
}

static animation* l_map_updateblueprint_getnextanim(lua_State *L, int& iIndex)
{
    animation *pAnim;
    lua_rawgeti(L, 11, iIndex);
    if(lua_type(L, -1) == LUA_TNIL)
    {
        lua_pop(L, 1);
        pAnim = luaT_new(L, animation);
        lua_pushvalue(L, luaT_upvalueindex(2));
        lua_setmetatable(L, -2);
        lua_createtable(L, 0, 2);
        lua_pushvalue(L, 1);
        lua_setfield(L, -2, "map");
        lua_pushvalue(L, 12);
        lua_setfield(L, -2, "animator");
        lua_setfenv(L, -2);
        lua_rawseti(L, 11, iIndex);
    }
    else
    {
        pAnim = luaT_testuserdata<animation>(L, -1, luaT_upvalueindex(2));
        lua_pop(L, 1);
    }
    ++iIndex;
    return pAnim;
}

static uint16_t l_check_temp(lua_State *L, int iArg)
{
    lua_Number n = luaL_checknumber(L, iArg);
    if(n < static_cast<lua_Number>(0) || static_cast<lua_Number>(1) < n)
        luaL_argerror(L, iArg, "temperature (number in [0,1])");
    return static_cast<uint16_t>(n * static_cast<lua_Number>(65535));
}

static int l_map_settemperaturedisplay(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    lua_Integer iTD = luaL_checkinteger(L, 2);

    temperature_theme temperatureDisplay;
    switch(iTD) {
        case 1:
            temperatureDisplay = temperature_theme::red;
            break;
        case 2:
            temperatureDisplay = temperature_theme::multi_colour;
            break;
        case 3:
            temperatureDisplay = temperature_theme::yellow_red;
            break;
        default:
            return luaL_argerror(L, 2, "TemperatureDisplay index out of bounds");
    }

    pMap->set_temperature_display(temperatureDisplay);

    return 1;
}

static int l_map_updatetemperature(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    uint16_t iAir = l_check_temp(L, 2);
    uint16_t iRadiator = l_check_temp(L, 3);
    pMap->update_temperatures(iAir, iRadiator);
    lua_settop(L, 1);
    return 1;
}

static int l_map_gettemperature(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    int iX = static_cast<int>(luaL_checkinteger(L, 2)) - 1;
    int iY = static_cast<int>(luaL_checkinteger(L, 3)) - 1;
    const map_tile* pNode = pMap->get_tile(iX, iY);
    uint16_t iTemp = pMap->get_tile_temperature(pNode);
    lua_pushnumber(L, static_cast<lua_Number>(iTemp) / static_cast<lua_Number>(65535));
    return 1;
}

/**
 * Is the tile position valid for a new room?
 * @param entire_invalid Entire blueprint is invalid (eg wrong position or too small).
 * @param pNode Tile to examine.
 * @param pMap The world map.
 * @param player_id The player to check for.
 * @return Whether the tile position is valid for a new room.
 */
static inline bool is_valid(
    bool entire_invalid, const map_tile *pNode,
    const level_map* pMap, int player_id)
{
    return !entire_invalid && !pNode->flags.room && pNode->flags.buildable &&
        (player_id == 0 || pMap->get_tile_owner(pNode) == player_id);
}

static int l_map_updateblueprint(lua_State *L)
{
    // NB: This function can be implemented in Lua, but is implemented in C for
    // efficiency.
    const unsigned short iFloorTileGood = 24 + (thdf_alpha_50 << 8);
    const unsigned short iFloorTileGoodCenter = 37 + (thdf_alpha_50 << 8);
    const unsigned short iFloorTileBad  = 67 + (thdf_alpha_50 << 8);
    const unsigned int iWallAnimTopCorner = 124;
    const unsigned int iWallAnim = 120;

    level_map* pMap = luaT_testuserdata<level_map>(L);
    int iOldX = static_cast<int>(luaL_checkinteger(L, 2)) - 1;
    int iOldY = static_cast<int>(luaL_checkinteger(L, 3)) - 1;
    int iOldW = static_cast<int>(luaL_checkinteger(L, 4));
    int iOldH = static_cast<int>(luaL_checkinteger(L, 5));
    int iNewX = static_cast<int>(luaL_checkinteger(L, 6)) - 1;
    int iNewY = static_cast<int>(luaL_checkinteger(L, 7)) - 1;
    int iNewW = static_cast<int>(luaL_checkinteger(L, 8));
    int iNewH = static_cast<int>(luaL_checkinteger(L, 9));
    int player_id = static_cast<int>(luaL_checkinteger(L, 10));

    luaL_checktype(L, 11, LUA_TTABLE); // Animation list
    animation_manager* pAnims = luaT_testuserdata<animation_manager>(L, 12, luaT_upvalueindex(1));
    bool entire_invalid = lua_toboolean(L, 13) != 0;
    bool valid = !entire_invalid;

    if(iOldX < 0 || iOldY < 0 || (iOldX + iOldW) > pMap->get_width() || (iOldY + iOldH) > pMap->get_height())
        luaL_argerror(L, 2, "Old rectangle is out of bounds");
    if(iNewX < 0 || iNewY < 0 || (iNewX + iNewW) >= pMap->get_width() || (iNewY + iNewH) >= pMap->get_height())
        luaL_argerror(L, 6, "New rectangle is out of bounds");

    // Clear blueprint flag from previous selected floor tiles (copying it to the passable flag).
    for(int iY = iOldY; iY < iOldY + iOldH; ++iY)
    {
        for(int iX = iOldX; iX < iOldX + iOldW; ++iX)
        {
            map_tile *pNode = pMap->get_tile_unchecked(iX, iY);
            pNode->iBlock[3] = 0;
            pNode->flags.passable |= pNode->flags.passable_if_not_for_blueprint;
            pNode->flags.passable_if_not_for_blueprint = false;
        }
    }

    // Add blueprint flag to new floor tiles.
    for(int iY = iNewY; iY < iNewY + iNewH; ++iY)
    {
        for(int iX = iNewX; iX < iNewX + iNewW; ++iX)
        {
            map_tile *pNode = pMap->get_tile_unchecked(iX, iY);
            if(is_valid(entire_invalid, pNode, pMap, player_id))
                pNode->iBlock[3] = iFloorTileGood;
            else
            {
                pNode->iBlock[3] = iFloorTileBad;
                valid = false;
            }
            pNode->flags.passable_if_not_for_blueprint = pNode->flags.passable;
        }
    }

    // Set center floor tiles
    if(iNewW >= 2 && iNewH >= 2)
    {
        int iCenterX = iNewX + (iNewW - 2) / 2;
        int iCenterY = iNewY + (iNewH - 2) / 2;

        map_tile *pNode = pMap->get_tile_unchecked(iCenterX, iCenterY);
        if(pNode->iBlock[3] == iFloorTileGood)
            pNode->iBlock[3] = iFloorTileGoodCenter + 2;

        pNode = pMap->get_tile_unchecked(iCenterX + 1, iCenterY);
        if(pNode->iBlock[3] == iFloorTileGood)
            pNode->iBlock[3] = iFloorTileGoodCenter + 1;

        pNode = pMap->get_tile_unchecked(iCenterX, iCenterY + 1);
        if(pNode->iBlock[3] == iFloorTileGood)
            pNode->iBlock[3] = iFloorTileGoodCenter + 0;

        pNode = pMap->get_tile_unchecked(iCenterX + 1, iCenterY + 1);
        if(pNode->iBlock[3] == iFloorTileGood)
            pNode->iBlock[3] = iFloorTileGoodCenter + 3;
    }

    // Set wall animations
    int iNextAnim = 1;
    animation *pAnim = l_map_updateblueprint_getnextanim(L, iNextAnim);
    map_tile *pNode = pMap->get_tile_unchecked(iNewX, iNewY);
    pAnim->set_animation(pAnims, iWallAnimTopCorner);
    pAnim->set_flags(thdf_list_bottom | (is_valid(entire_invalid, pNode, pMap, player_id) ? 0 : thdf_alt_palette));
    pAnim->attach_to_tile(pNode, 0);

    for(int iX = iNewX; iX < iNewX + iNewW; ++iX)
    {
        if(iX != iNewX)
        {
            pAnim = l_map_updateblueprint_getnextanim(L, iNextAnim);
            pNode = pMap->get_tile_unchecked(iX, iNewY);
            pAnim->set_animation(pAnims, iWallAnim);
            pAnim->set_flags(thdf_list_bottom | (is_valid(entire_invalid, pNode, pMap, player_id) ? 0 : thdf_alt_palette));
            pAnim->attach_to_tile(pNode, 0);
            pAnim->set_position(0, 0);
        }
        pAnim = l_map_updateblueprint_getnextanim(L, iNextAnim);
        pNode = pMap->get_tile_unchecked(iX, iNewY + iNewH - 1);
        pAnim->set_animation(pAnims, iWallAnim);
        pAnim->set_flags(thdf_list_bottom | (is_valid(entire_invalid, pNode, pMap, player_id) ? 0 : thdf_alt_palette));
        pNode = pMap->get_tile_unchecked(iX, iNewY + iNewH);
        pAnim->attach_to_tile(pNode, 0);
        pAnim->set_position(0, -1);
    }
    for(int iY = iNewY; iY < iNewY + iNewH; ++iY)
    {
        if(iY != iNewY)
        {
            pAnim = l_map_updateblueprint_getnextanim(L, iNextAnim);
            pNode = pMap->get_tile_unchecked(iNewX, iY);
            pAnim->set_animation(pAnims, iWallAnim);
            pAnim->set_flags(thdf_list_bottom | thdf_flip_horizontal | (is_valid(entire_invalid, pNode, pMap, player_id) ? 0 : thdf_alt_palette));
            pAnim->attach_to_tile(pNode, 0);
            pAnim->set_position(2, 0);
        }
        pAnim = l_map_updateblueprint_getnextanim(L, iNextAnim);
        pNode = pMap->get_tile_unchecked(iNewX + iNewW - 1, iY);
        pAnim->set_animation(pAnims, iWallAnim);
        pAnim->set_flags(thdf_list_bottom | thdf_flip_horizontal | (is_valid(entire_invalid, pNode, pMap, player_id) ? 0 : thdf_alt_palette));
        pNode = pMap->get_tile_unchecked(iNewX + iNewW, iY);
        pAnim->attach_to_tile(pNode, 0);
        pAnim->set_position(2, -1);
    }

    // Clear away extra animations
    int iAnimCount = (int)lua_objlen(L, 11);
    if(iAnimCount >= iNextAnim)
    {
        for(int i = iNextAnim; i <= iAnimCount; ++i)
        {
            pAnim = l_map_updateblueprint_getnextanim(L, iNextAnim);
            pAnim->remove_from_tile();
            lua_pushnil(L);
            lua_rawseti(L, 11, i);
        }
    }

    lua_pushboolean(L, valid ? 1 : 0);
    return 1;
}

static int l_map_getsize(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    lua_pushinteger(L, pMap->get_width());
    lua_pushinteger(L, pMap->get_height());
    return 2;
}

static int l_map_get_player_count(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    lua_pushinteger(L, pMap->get_player_count());
    return 1;
}

static int l_map_set_player_count(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    int count = static_cast<int>(luaL_checkinteger(L, 2));

    try
    {
        pMap->set_player_count(count);
    }
    catch (std::out_of_range)
    {
        return luaL_error(L, "Player count out of range %d", count);
    }
    return 0;
}

static int l_map_get_player_camera(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    int iX, iY;
    int iPlayer = static_cast<int>(luaL_optinteger(L, 2, 1));
    bool bGood = pMap->get_player_camera_tile(iPlayer - 1, &iX, &iY);
    if(!bGood)
        return luaL_error(L, "Player index out of range: %d", iPlayer);
    lua_pushinteger(L, iX + 1);
    lua_pushinteger(L, iY + 1);
    return 2;
}

static int l_map_set_player_camera(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    int iX = static_cast<int>(luaL_checkinteger(L, 2) - 1);
    int iY = static_cast<int>(luaL_checkinteger(L, 3) - 1);
    int iPlayer = static_cast<int>(luaL_optinteger(L, 4, 1));

    if (iPlayer < 1 || iPlayer > player_max)
        return luaL_error(L, "Player index out of range: %i", iPlayer);

    pMap->set_player_camera_tile(iPlayer - 1, iX, iY);
    return 0;
}

static int l_map_get_player_heliport(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    int iX, iY;
    int iPlayer = static_cast<int>(luaL_optinteger(L, 2, 1));
    bool bGood = pMap->get_player_heliport_tile(iPlayer - 1, &iX, &iY);
    if(!bGood)
        return luaL_error(L, "Player index out of range: %d", iPlayer);
    lua_pushinteger(L, iX + 1);
    lua_pushinteger(L, iY + 1);
    return 2;
}

static int l_map_set_player_heliport(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    int iX = static_cast<int>(luaL_checkinteger(L, 2) - 1);
    int iY = static_cast<int>(luaL_checkinteger(L, 3) - 1);
    int iPlayer = static_cast<int>(luaL_optinteger(L, 4, 1));

    if (iPlayer < 1 || iPlayer > player_max)
        return luaL_error(L, "Player index out of range: %i", iPlayer);

    pMap->set_player_heliport_tile(iPlayer - 1, iX, iY);
    return 0;
}

static int l_map_getcell(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    int iX = static_cast<int>(luaL_checkinteger(L, 2) - 1); // Lua arrays start at 1 - pretend
    int iY = static_cast<int>(luaL_checkinteger(L, 3) - 1); // the map does too.
    map_tile* pNode = pMap->get_tile(iX, iY);
    if(pNode == nullptr)
    {
        return luaL_argerror(L, 2, lua_pushfstring(L, "Map co-ordinates out "
        "of bounds (%d, %d)", iX + 1, iY + 1));
    }
    if(lua_isnoneornil(L, 4))
    {
        lua_pushinteger(L, pNode->iBlock[0]);
        lua_pushinteger(L, pNode->iBlock[1]);
        lua_pushinteger(L, pNode->iBlock[2]);
        lua_pushinteger(L, pNode->iBlock[3]);
        return 4;
    }
    else
    {
        lua_Integer iLayer = luaL_checkinteger(L, 4) - 1;
        if(iLayer < 0 || iLayer >= 4)
            return luaL_argerror(L, 4, "Layer index is out of bounds (1-4)");
        lua_pushinteger(L, pNode->iBlock[iLayer]);
        return 1;
    }
}

/** Recognized tile flags by Lua. */
static const std::map<std::string, map_tile_flags::key> lua_tile_flag_map = {
    {"passable",       map_tile_flags::key::passable_mask},
    {"hospital",       map_tile_flags::key::hospital_mask},
    {"buildable",      map_tile_flags::key::buildable_mask},
    {"room",           map_tile_flags::key::room_mask},
    {"doorWest",       map_tile_flags::key::door_west_mask},
    {"doorNorth",      map_tile_flags::key::door_north_mask},
    {"tallWest",       map_tile_flags::key::tall_west_mask},
    {"tallNorth",      map_tile_flags::key::tall_north_mask},
    {"travelNorth",    map_tile_flags::key::can_travel_n_mask},
    {"travelEast",     map_tile_flags::key::can_travel_e_mask},
    {"travelSouth",    map_tile_flags::key::can_travel_s_mask},
    {"travelWest",     map_tile_flags::key::can_travel_w_mask},
    {"doNotIdle",      map_tile_flags::key::do_not_idle_mask},
    {"buildableNorth", map_tile_flags::key::buildable_n_mask},
    {"buildableEast",  map_tile_flags::key::buildable_e_mask},
    {"buildableSouth", map_tile_flags::key::buildable_s_mask},
    {"buildableWest",  map_tile_flags::key::buildable_w_mask},
};

/**
 * Add the current value of the \a flag in the \a tile to the output.
 * @param L Lua context.
 * @param tile Tile to inspect.
 * @param flag Flag of the tile to check (and report).
 * @param name Name of the flag in Lua code.
 */
static inline void add_cellflag(lua_State *L, const map_tile *tile,
                                map_tile_flags::key flag, const std::string &name)
{
    lua_pushlstring(L, name.c_str(), name.size());
    lua_pushboolean(L, tile->flags[flag] ? 1 : 0);
    lua_settable(L, 4);
}

/**
 * Add the current value of a tile field to the output.
 * @param L Lua context.
 * @param value Value of the tile field to add.
 * @param name Name of the field in Lua code.
 */
static inline void add_cellint(lua_State *L, int value, const std::string &name)
{
    lua_pushlstring(L, name.c_str(), name.size());
    lua_pushinteger(L, value);
    lua_settable(L, 4);
}

/**
 * Get the value of all cell flags at a position.
 * @param L Lua context.
 * @return Number of results of the call.
 */
static int l_map_getcellflags(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    int iX = static_cast<int>(luaL_checkinteger(L, 2) - 1); // Lua arrays start at 1 - pretend
    int iY = static_cast<int>(luaL_checkinteger(L, 3) - 1); // the map does too.
    map_tile* pNode = pMap->get_tile(iX, iY);
    if(pNode == nullptr)
        return luaL_argerror(L, 2, "Map co-ordinates out of bounds");
    if(lua_type(L, 4) != LUA_TTABLE)
    {
        lua_settop(L, 3);
        lua_createtable(L, 0, 1);
    }
    else
    {
        lua_settop(L, 4);
    }

    // Fill Lua table with the flags and numbers of the tile.
    for (auto val : lua_tile_flag_map)
    {
        add_cellflag(L, pNode, val.second, val.first);
    }
    add_cellint(L, pNode->iRoomId, "roomId");
    add_cellint(L, pNode->iParcelId, "parcelId");
    add_cellint(L, pMap->get_tile_owner(pNode), "owner");
    add_cellint(L, static_cast<int>(pNode->objects.empty() ? object_type::no_object : pNode->objects.front()), "thob");
    return 1;
}

/* because all the thobs are not retrieved when the map is loaded in c
  lua objects use the afterLoad function to be registered after a load,
  if the object list would not be cleared it would result in duplication
  of thobs in the object list. */
static int l_map_erase_thobs(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    int iX = static_cast<int>(luaL_checkinteger(L, 2) - 1); // Lua arrays start at 1 - pretend
    int iY = static_cast<int>(luaL_checkinteger(L, 3) - 1); // the map does too.
    map_tile* pNode = pMap->get_tile(iX, iY);
    if(pNode == nullptr)
        return luaL_argerror(L, 2, "Map co-ordinates out of bounds");
    pNode->objects.clear();
    return 1;
}

static int l_map_remove_cell_thob(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    int iX = static_cast<int>(luaL_checkinteger(L, 2) - 1); // Lua arrays start at 1 - pretend
    int iY = static_cast<int>(luaL_checkinteger(L, 3) - 1); // the map does too.
    map_tile* pNode = pMap->get_tile(iX, iY);
    if(pNode == nullptr)
        return luaL_argerror(L, 2, "Map co-ordinates out of bounds");
    auto thob = static_cast<object_type>(luaL_checkinteger(L, 4));
    for(auto iter = pNode->objects.begin(); iter != pNode->objects.end(); iter++)
    {
        if(*iter == thob)
        {
            pNode->objects.erase(iter);
            break;
        }
    }
    return 1;
}

static int l_map_setcellflags(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    int iX = static_cast<int>(luaL_checkinteger(L, 2) - 1); // Lua arrays start at 1 - pretend
    int iY = static_cast<int>(luaL_checkinteger(L, 3) - 1); // the map does too.
    map_tile* pNode = pMap->get_tile(iX, iY);
    if(pNode == nullptr)
        return luaL_argerror(L, 2, "Map co-ordinates out of bounds");
    luaL_checktype(L, 4, LUA_TTABLE);
    lua_settop(L, 4);

    lua_pushnil(L);

    while(lua_next(L, 4))
    {
        if(lua_type(L, 5) == LUA_TSTRING)
        {
            const char *field = lua_tostring(L, 5);

            auto iter = lua_tile_flag_map.find(field);
            if(iter != lua_tile_flag_map.end())
            {
                if (lua_toboolean(L, 6) == 0)
                    pNode->flags[(*iter).second] = false;
                else
                    pNode->flags[(*iter).second] = true;
            }
            else if (std::strcmp(field, "thob") == 0)
            {
                auto thob = static_cast<object_type>(lua_tointeger(L, 6));
                pNode->objects.push_back(thob);
            }
            else if(std::strcmp(field, "parcelId") == 0)
            {
                pNode->iParcelId = static_cast<uint16_t>(lua_tointeger(L, 6));
            }
            else if(std::strcmp(field, "roomId") == 0)
            {
                pNode->iRoomId = static_cast<uint16_t>(lua_tointeger(L,6));
            }
            else
            {
                luaL_error(L, "Invalid flag \'%s\'", field);
            }
        }
        lua_settop(L, 5);
    }
    return 0;
}

static int l_map_setwallflags(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    pMap->set_all_wall_draw_flags((uint8_t)luaL_checkinteger(L, 2));
    lua_settop(L, 1);
    return 1;
}

static int l_map_setcell(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    int iX = static_cast<int>(luaL_checkinteger(L, 2) - 1); // Lua arrays start at 1 - pretend
    int iY = static_cast<int>(luaL_checkinteger(L, 3) - 1); // the map does too.
    map_tile* pNode = pMap->get_tile(iX, iY);
    if(pNode == nullptr)
        return luaL_argerror(L, 2, "Map co-ordinates out of bounds");
    if(lua_gettop(L) >= 7)
    {
        pNode->iBlock[0] = (uint16_t)luaL_checkinteger(L, 4);
        pNode->iBlock[1] = (uint16_t)luaL_checkinteger(L, 5);
        pNode->iBlock[2] = (uint16_t)luaL_checkinteger(L, 6);
        pNode->iBlock[3] = (uint16_t)luaL_checkinteger(L, 7);
    }
    else
    {
        lua_Integer iLayer = luaL_checkinteger(L, 4) - 1;
        if(iLayer < 0 || iLayer >= 4)
            return luaL_argerror(L, 4, "Layer index is out of bounds (1-4)");
        uint16_t iBlock = static_cast<uint16_t>(luaL_checkinteger(L, 5));
        pNode->iBlock[iLayer] = iBlock;
    }

    lua_settop(L, 1);
    return 1;
}

static int l_map_updateshadows(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    pMap->update_shadows();
    lua_settop(L, 1);
    return 1;
}

static int l_map_updatepathfinding(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    pMap->update_pathfinding();
    lua_settop(L, 1);
    return 1;
}

static int l_map_mark_room(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    int iX_ = static_cast<int>(luaL_checkinteger(L, 2) - 1);
    int iY_ = static_cast<int>(luaL_checkinteger(L, 3) - 1);
    int iW = static_cast<int>(luaL_checkinteger(L, 4));
    int iH = static_cast<int>(luaL_checkinteger(L, 5));
    uint16_t iTile = static_cast<uint16_t>(luaL_checkinteger(L, 6));
    uint16_t iRoomId = static_cast<uint16_t>(luaL_optinteger(L, 7, 0));

    if(iX_ < 0 || iY_ < 0 || (iX_ + iW) > pMap->get_width() || (iY_ + iH) > pMap->get_height())
        luaL_argerror(L, 2, "Rectangle is out of bounds");

    for(int iY = iY_; iY < iY_ + iH; ++iY)
    {
        for(int iX = iX_; iX < iX_ + iW; ++iX)
        {
            map_tile *pNode = pMap->get_tile_unchecked(iX, iY);
            pNode->iBlock[0] = iTile;
            pNode->iBlock[3] = 0;
            pNode->flags.room = true;
            pNode->flags.passable |= pNode->flags.passable_if_not_for_blueprint;
            pNode->flags.passable_if_not_for_blueprint = false;
            pNode->iRoomId = iRoomId;
        }
    }

    pMap->update_pathfinding();
    pMap->update_shadows();
    lua_settop(L, 1);
    return 1;
}

static int l_map_unmark_room(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    int iX_ = static_cast<int>(luaL_checkinteger(L, 2) - 1);
    int iY_ = static_cast<int>(luaL_checkinteger(L, 3) - 1);
    int iW = static_cast<int>(luaL_checkinteger(L, 4));
    int iH = static_cast<int>(luaL_checkinteger(L, 5));

    if(iX_ < 0 || iY_ < 0 || (iX_ + iW) > pMap->get_width() || (iY_ + iH) > pMap->get_height())
        luaL_argerror(L, 2, "Rectangle is out of bounds");

    for(int iY = iY_; iY < iY_ + iH; ++iY)
    {
        for(int iX = iX_; iX < iX_ + iW; ++iX)
        {
            map_tile *pNode = pMap->get_tile_unchecked(iX, iY);
            pNode->iBlock[0] = pMap->get_original_tile_unchecked(iX, iY)->iBlock[0];
            pNode->flags.room = false;
            pNode->iRoomId = 0;
        }
    }

    pMap->update_pathfinding();
    pMap->update_shadows();

    lua_settop(L, 1);
    return 1;
}

static int l_map_draw(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    render_target* pCanvas = luaT_testuserdata<render_target>(L, 2);

    pMap->draw(pCanvas, static_cast<int>(luaL_checkinteger(L, 3)), static_cast<int>(luaL_checkinteger(L, 4)), static_cast<int>(luaL_checkinteger(L, 5)),
        static_cast<int>(luaL_checkinteger(L, 6)), static_cast<int>(luaL_optinteger(L, 7, 0)), static_cast<int>(luaL_optinteger(L, 8, 0)));

    lua_settop(L, 1);
    return 1;
}

static int l_map_hittest(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    drawable* pObject = pMap->hit_test(static_cast<int>(luaL_checkinteger(L, 2)), static_cast<int>(luaL_checkinteger(L, 3)));
    if(pObject == nullptr)
        return 0;
    lua_rawgeti(L, luaT_upvalueindex(1), 1);
    lua_pushlightuserdata(L, pObject);
    lua_gettable(L, -2);
    return 1;
}

static int l_map_get_parcel_tilecount(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    int iParcel = static_cast<int>(luaL_checkinteger(L, 2));
    lua_Integer iCount = pMap->get_parcel_tile_count(iParcel);
    lua_pushinteger(L, iCount);
    return 1;
}

static int l_map_get_parcel_count(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    lua_pushinteger(L, pMap->get_parcel_count());
    return 1;
}

static int l_map_set_parcel_owner(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    int parcelId = static_cast<int>(luaL_checkinteger(L, 2));
    int player = static_cast<int>(luaL_checkinteger(L, 3));
    if(lua_type(L, 4) != LUA_TTABLE)
    {
        lua_settop(L, 3);
        lua_newtable(L);
    }
    else
    {
        lua_settop(L, 4);
    }
    std::vector<std::pair<int, int>> vSplitTiles = pMap->set_parcel_owner(parcelId, player);
    for (std::vector<std::pair<int, int>>::size_type i = 0; i != vSplitTiles.size(); i++)
    {
      lua_pushinteger(L, i + 1);
      lua_createtable(L, 0, 2);
      lua_pushinteger(L, 1);
      lua_pushinteger(L, vSplitTiles[i].first + 1);
      lua_settable(L, 6);
      lua_pushinteger(L, 2);
      lua_pushinteger(L, vSplitTiles[i].second + 1);
      lua_settable(L, 6);
      lua_settable(L, 4);
    }
    return 1;
}

static int l_map_get_parcel_owner(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    lua_pushinteger(L, pMap->get_parcel_owner(static_cast<int>(luaL_checkinteger(L, 2))));
    return 1;
}

static int l_map_is_parcel_purchasable(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    lua_pushboolean(L, pMap->is_parcel_purchasable(static_cast<int>(luaL_checkinteger(L, 2)),
        static_cast<int>(luaL_checkinteger(L, 3))) ? 1 : 0);
    return 1;
}

/* Compute the fraction of corridor tiles with litter, of the parcels owned by the given player. */
static int l_map_get_litter_fraction(lua_State *L)
{
    level_map* pMap = luaT_testuserdata<level_map>(L);
    int owner = static_cast<int>(luaL_checkinteger(L, 2));
    if (owner == 0)
    {
        lua_pushnumber(L, 0.0); // Outside has no litter.
        return 1;
    }

    double tile_count = 0;
    double litter_count = 0;
    for (int x = 0; x < pMap->get_width(); x++)
    {
        for (int y = 0; y < pMap->get_height(); y++)
        {
            const map_tile* pNode = pMap->get_tile_unchecked(x, y);
            if (pNode->iParcelId == 0 || owner != pMap->get_parcel_owner(pNode->iParcelId) ||
                pNode->iRoomId != 0)
            {
                continue;
            }

            tile_count++;
            for(auto iter = pNode->objects.begin(); iter != pNode->objects.end(); iter++)
            {
                if(*iter == object_type::litter)
                {
                    litter_count++;
                    break;
                }
            }
        }
    }

    double fraction = (tile_count == 0) ? 0.0 : litter_count / tile_count;
    lua_pushnumber(L, fraction);
    return 1;
}

static int l_path_new(lua_State *L)
{
    luaT_stdnew<pathfinder>(L, luaT_environindex, true);
    return 1;
}

static int l_path_set_map(lua_State *L)
{
    pathfinder* pPathfinder = luaT_testuserdata<pathfinder>(L);
    level_map* pMap = luaT_testuserdata<level_map>(L, 2);
    lua_settop(L, 2);

    pPathfinder->set_default_map(pMap);
    luaT_setenvfield(L, 1, "map");
    return 1;
}

static int l_path_persist(lua_State *L)
{
    pathfinder* pPathfinder = luaT_testuserdata<pathfinder>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    pPathfinder->persist((lua_persist_writer*)lua_touserdata(L, 1));
    return 0;
}

static int l_path_depersist(lua_State *L)
{
    pathfinder* pPathfinder = luaT_testuserdata<pathfinder>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    lua_persist_reader* pReader = (lua_persist_reader*)lua_touserdata(L, 1);

    pPathfinder->depersist(pReader);
    luaT_getenvfield(L, 2, "map");
    pPathfinder->set_default_map(reinterpret_cast<level_map*>(lua_touserdata(L, -1)));
    return 0;
}

static int l_path_is_reachable_from_hospital(lua_State *L)
{
    pathfinder* pPathfinder = luaT_testuserdata<pathfinder>(L);
    if(pPathfinder->find_path_to_hospital(nullptr, static_cast<int>(luaL_checkinteger(L, 2) - 1),
        static_cast<int>(luaL_checkinteger(L, 3) - 1)))
    {
        lua_pushboolean(L, 1);
        int iX, iY;
        pPathfinder->get_path_end(&iX, &iY);
        lua_pushinteger(L, iX + 1);
        lua_pushinteger(L, iY + 1);
        return 3;
    }
    else
    {
        lua_pushboolean(L, 0);
        return 1;
    }
}

static int l_path_distance(lua_State *L)
{
    pathfinder* pPathfinder = luaT_testuserdata<pathfinder>(L);
    if(pPathfinder->find_path(nullptr, static_cast<int>(luaL_checkinteger(L, 2)) - 1, static_cast<int>(luaL_checkinteger(L, 3)) - 1,
        static_cast<int>(luaL_checkinteger(L, 4)) - 1, static_cast<int>(luaL_checkinteger(L, 5)) - 1))
    {
        lua_pushinteger(L, pPathfinder->get_path_length());
    }
    else
    {
        lua_pushboolean(L, 0);
    }
    return 1;
}

static int l_path_path(lua_State *L)
{
    pathfinder* pPathfinder = luaT_testuserdata<pathfinder>(L);
    pPathfinder->find_path(nullptr, static_cast<int>(luaL_checkinteger(L, 2)) - 1, static_cast<int>(luaL_checkinteger(L, 3)) - 1,
        static_cast<int>(luaL_checkinteger(L, 4)) - 1, static_cast<int>(luaL_checkinteger(L, 5)) - 1);
    pPathfinder->push_result(L);
    return 2;
}

static int l_path_idle(lua_State *L)
{
    pathfinder* pPathfinder = luaT_testuserdata<pathfinder>(L);
    if(!pPathfinder->find_idle_tile(nullptr, static_cast<int>(luaL_checkinteger(L, 2)) - 1,
        static_cast<int>(luaL_checkinteger(L, 3)) - 1, static_cast<int>(luaL_optinteger(L, 4, 0))))
    {
        return 0;
    }
    int iX, iY;
    pPathfinder->get_path_end(&iX, &iY);
    lua_pushinteger(L, iX + 1);
    lua_pushinteger(L, iY + 1);
    return 2;
}

static int l_path_visit(lua_State *L)
{
    pathfinder* pPathfinder = luaT_testuserdata<pathfinder>(L);
    luaL_checktype(L, 6, LUA_TFUNCTION);
    lua_pushboolean(L, pPathfinder->visit_objects(nullptr, static_cast<int>(luaL_checkinteger(L, 2)) - 1,
        static_cast<int>(luaL_checkinteger(L, 3)) - 1, static_cast<object_type>(luaL_checkinteger(L, 4)),
        static_cast<int>(luaL_checkinteger(L, 5)), L, 6, luaL_checkinteger(L, 4) == 0 ? true : false) ? 1 : 0);
    return 1;
}

void lua_register_map(const lua_register_state *pState)
{
    // Map
    luaT_class(level_map, l_map_new, "map", lua_metatable::map);
    luaT_setmetamethod(l_map_persist, "persist", lua_metatable::anim);
    luaT_setmetamethod(l_map_depersist, "depersist", lua_metatable::anim);
    luaT_setfunction(l_map_load, "load");
    luaT_setfunction(l_map_loadblank, "loadBlank");
    luaT_setfunction(l_map_save, "save");
    luaT_setfunction(l_map_getsize, "size");
    luaT_setfunction(l_map_get_player_count, "getPlayerCount");
    luaT_setfunction(l_map_set_player_count, "setPlayerCount");
    luaT_setfunction(l_map_get_player_camera, "getCameraTile");
    luaT_setfunction(l_map_set_player_camera, "setCameraTile");
    luaT_setfunction(l_map_get_player_heliport, "getHeliportTile");
    luaT_setfunction(l_map_set_player_heliport, "setHeliportTile");
    luaT_setfunction(l_map_getcell, "getCell");
    luaT_setfunction(l_map_gettemperature, "getCellTemperature");
    luaT_setfunction(l_map_getcellflags, "getCellFlags");
    luaT_setfunction(l_map_setcellflags, "setCellFlags");
    luaT_setfunction(l_map_setcell, "setCell");
    luaT_setfunction(l_map_setwallflags, "setWallDrawFlags");
    luaT_setfunction(l_map_settemperaturedisplay, "setTemperatureDisplay");
    luaT_setfunction(l_map_updatetemperature, "updateTemperatures");
    luaT_setfunction(l_map_updateblueprint, "updateRoomBlueprint", lua_metatable::anims, lua_metatable::anim);
    luaT_setfunction(l_map_updateshadows, "updateShadows");
    luaT_setfunction(l_map_updatepathfinding, "updatePathfinding");
    luaT_setfunction(l_map_mark_room, "markRoom");
    luaT_setfunction(l_map_unmark_room, "unmarkRoom");
    luaT_setfunction(l_map_set_sheet, "setSheet", lua_metatable::sheet);
    luaT_setfunction(l_map_draw, "draw", lua_metatable::surface);
    luaT_setfunction(l_map_hittest, "hitTestObjects", lua_metatable::anim);
    luaT_setfunction(l_map_get_parcel_tilecount, "getParcelTileCount");
    luaT_setfunction(l_map_get_parcel_count, "getPlotCount");
    luaT_setfunction(l_map_set_parcel_owner, "setPlotOwner");
    luaT_setfunction(l_map_get_parcel_owner, "getPlotOwner");
    luaT_setfunction(l_map_is_parcel_purchasable, "isParcelPurchasable");
    luaT_setfunction(l_map_erase_thobs, "eraseObjectTypes");
    luaT_setfunction(l_map_remove_cell_thob, "removeObjectType");
    luaT_setfunction(l_map_get_litter_fraction, "getLitterFraction");
    luaT_endclass();

    // Pathfinder
    luaT_class(pathfinder, l_path_new, "pathfinder", lua_metatable::pathfinder);
    luaT_setmetamethod(l_path_persist, "persist");
    luaT_setmetamethod(l_path_depersist, "depersist");
    luaT_setfunction(l_path_distance, "findDistance");
    luaT_setfunction(l_path_is_reachable_from_hospital, "isReachableFromHospital");
    luaT_setfunction(l_path_path, "findPath");
    luaT_setfunction(l_path_idle, "findIdleTile");
    luaT_setfunction(l_path_visit, "findObject");
    luaT_setfunction(l_path_set_map, "setMap", lua_metatable::map);
    luaT_endclass();
}
