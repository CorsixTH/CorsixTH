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
#include "th_lua.h"
#include "th_map.h"
#include "th_gfx.h"
#include "th_sound.h"
#include "th_pathfind.h"
#include "persist_lua.h"
#include <new>
#include <SDL.h>
#include <string.h>
#ifndef _MSC_VER
#define stricmp strcasecmp
#else
#pragma warning(disable: 4996) // Deprecated CRT
#endif

//! Set a field on the environment table of an object
void luaT_setenvfield(lua_State *L, int index, const char *k)
{
    lua_getfenv(L, index);
    lua_pushstring(L, k);
    lua_pushvalue(L, -3);
    lua_settable(L, -3);
    lua_pop(L, 2);
}

//! Get a field from the environment table of an object
void luaT_getenvfield(lua_State *L, int index, const char *k)
{
    lua_getfenv(L, index);
    lua_getfield(L, -1, k);
    lua_replace(L, -2);
}

//! Push a C closure as a callable table
static void luaT_pushcclosuretable(lua_State *L, lua_CFunction fn, int n)
{
    lua_pushcclosure(L, fn, n); // .. fn <top
    lua_createtable(L, 0, 1); // .. fn mt <top
    lua_pushliteral(L, "__call"); // .. fn mt __call <top
    lua_pushvalue(L, -3); // .. fn mt __call fn <top
    lua_settable(L, -3); // .. fn mt <top
    lua_newtable(L); // .. fn mt t <top
    lua_replace(L, -3); // .. t mt <top
    lua_setmetatable(L, -2); // .. t <top
}

void luaT_addcleanup(lua_State *L, void(*fnCleanup)(void))
{
    lua_checkstack(L, 2);
    lua_getfield(L, LUA_REGISTRYINDEX, "_CLEANUP");
    int idx = 1 + (int)lua_objlen(L, -1);
    lua_pushlightuserdata(L, (void*)fnCleanup);
    lua_rawseti(L, -2, idx);
    lua_pop(L, 1);
}

//! Check for a string or userdata
const unsigned char* luaT_checkfile(lua_State *L, int idx, size_t* pDataLen)
{
    const unsigned char *pData;
    size_t iLength;
    if(lua_type(L, idx) == LUA_TUSERDATA)
    {
        pData = (const unsigned char*)lua_touserdata(L, idx);
        iLength = lua_objlen(L, idx);
    }
    else
    {
        pData = (const unsigned char*)luaL_checklstring(L, idx, &iLength);
    }
    if(pDataLen != 0)
        *pDataLen = iLength;
    return pData;
}

static int l_map_new(lua_State *L)
{
    THMap* pMap = luaT_stdnew<THMap>(L, LUA_ENVIRONINDEX, true);
    return 1;
}

static int l_map_set_sheet(lua_State *L)
{
    THMap* pMap = luaT_testuserdata<THMap>(L);
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L, 2);
    lua_settop(L, 2);

    pMap->setBlockSheet(pSheet);
    luaT_setenvfield(L, 1, "sprites");
    return 1;
}

static int l_map_persist(lua_State *L)
{
    THMap* pMap = luaT_testuserdata<THMap>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    pMap->persist((LuaPersistWriter*)lua_touserdata(L, 1));
    return 0;
}

static int l_map_depersist(lua_State *L)
{
    THMap* pMap = luaT_testuserdata<THMap>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    LuaPersistReader* pReader = (LuaPersistReader*)lua_touserdata(L, 1);

    pMap->depersist(pReader);
    luaT_getenvfield(L, 2, "sprites");
    pMap->setBlockSheet((THSpriteSheet*)lua_touserdata(L, -1));
    lua_pop(L, 1);
    return 0;
}

static void l_map_load_obj_cb(void *pL, int iX, int iY, THObjectType eTHOB, uint8_t iFlags)
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
    THMap* pMap = luaT_testuserdata<THMap>(L);
    size_t iDataLen;
    const unsigned char* pData = luaT_checkfile(L, 2, &iDataLen);
    lua_settop(L, 2);
    lua_newtable(L);
    if(pMap->loadFromTHFile(pData, iDataLen, l_map_load_obj_cb, (void*)L))
        lua_pushboolean(L, 1);
    else
        lua_pushboolean(L, 0);
    lua_insert(L, -2);
    return 2;
}

THAnimation* l_map_updateblueprint_getnextanim(lua_State *L, int& iIndex)
{
    THAnimation *pAnim;
    lua_rawgeti(L, 10, iIndex);
    if(lua_type(L, -1) == LUA_TNIL)
    {
        lua_pop(L, 1);
        pAnim = luaT_new(L, THAnimation);
        lua_pushvalue(L, lua_upvalueindex(2));
        lua_setmetatable(L, -2);
        lua_createtable(L, 0, 2);
        lua_pushvalue(L, 1);
        lua_setfield(L, -2, "map");
        lua_pushvalue(L, 11);
        lua_setfield(L, -2, "animator");
        lua_setfenv(L, -2);
        lua_rawseti(L, 10, iIndex);
    }
    else
    {
        pAnim = luaT_testuserdata<THAnimation>(L, -1, lua_upvalueindex(2));
        lua_pop(L, 1);
    }
    ++iIndex;
    return pAnim;
}

static int l_map_updateblueprint(lua_State *L)
{
    // NB: This function can be implemented in Lua, but is implemented in C for
    // efficiency.
    const unsigned short iFloorTileGood = 24 + (THDF_Alpha50 << 8);
    const unsigned short iFloorTileGoodCenter = 37 + (THDF_Alpha50 << 8);
    const unsigned short iFloorTileBad  = 67 + (THDF_Alpha50 << 8);
    const unsigned int iWallAnimTopCorner = 124;
    const unsigned int iWallAnim = 120;

    THMap* pMap = luaT_testuserdata<THMap>(L);
    int iOldX = luaL_checkint(L, 2) - 1;
    int iOldY = luaL_checkint(L, 3) - 1;
    int iOldW = luaL_checkint(L, 4);
    int iOldH = luaL_checkint(L, 5);
    int iNewX = luaL_checkint(L, 6) - 1;
    int iNewY = luaL_checkint(L, 7) - 1;
    int iNewW = luaL_checkint(L, 8);
    int iNewH = luaL_checkint(L, 9);
    luaL_checktype(L, 10, LUA_TTABLE); // Animation list
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L, 11, lua_upvalueindex(1));
    bool entire_invalid = lua_toboolean(L, 12) != 0;
    bool valid = !entire_invalid;

    if(iOldX < 0 || iOldY < 0 || (iOldX + iOldW) > pMap->getWidth() || (iOldY + iOldH) > pMap->getHeight())
        luaL_argerror(L, 2, "Old rectangle is out of bounds");
    if(iNewX < 0 || iNewY < 0 || (iNewX + iNewW) >= pMap->getWidth() || (iNewY + iNewH) >= pMap->getHeight())
        luaL_argerror(L, 6, "New rectangle is out of bounds");

    // Clear old floor tiles
    for(int iY = iOldY; iY < iOldY + iOldH; ++iY)
    {
        for(int iX = iOldX; iX < iOldX + iOldW; ++iX)
        {
            THMapNode *pNode = pMap->getNodeUnchecked(iX, iY);
            pNode->iBlock[3] = 0;
            pNode->iFlags |= (pNode->iFlags & THMN_PassableIfNotForBlueprint) >> THMN_PassableIfNotForBlueprint_ShiftDelta;
            pNode->iFlags &= ~THMN_PassableIfNotForBlueprint;
        }
    }

#define IsValid(node) \
    (!entire_invalid && (((node)->iFlags & (THMN_Buildable | THMN_Room)) == THMN_Buildable))

    // Set new floor tiles
    for(int iY = iNewY; iY < iNewY + iNewH; ++iY)
    {
        for(int iX = iNewX; iX < iNewX + iNewW; ++iX)
        {
            THMapNode *pNode = pMap->getNodeUnchecked(iX, iY);
            if(IsValid(pNode))
                pNode->iBlock[3] = iFloorTileGood;
            else
            {
                pNode->iBlock[3] = iFloorTileBad;
                valid = false;
            }
            pNode->iFlags |= (pNode->iFlags & THMN_Passable) << THMN_PassableIfNotForBlueprint_ShiftDelta;
        }
    }

    // Set center floor tiles
    if(iNewW >= 2 && iNewH >= 2)
    {
        int iCenterX = iNewX + (iNewW - 2) / 2;
        int iCenterY = iNewY + (iNewH - 2) / 2;

        THMapNode *pNode = pMap->getNodeUnchecked(iCenterX, iCenterY);
        if(pNode->iBlock[3] == iFloorTileGood)
            pNode->iBlock[3] = iFloorTileGoodCenter + 2;
        pNode = pMap->getNodeUnchecked(iCenterX + 1, iCenterY);
        if(pNode->iBlock[3] == iFloorTileGood)
            pNode->iBlock[3] = iFloorTileGoodCenter + 1;
        pNode = pMap->getNodeUnchecked(iCenterX, iCenterY + 1);
        if(pNode->iBlock[3] == iFloorTileGood)
            pNode->iBlock[3] = iFloorTileGoodCenter + 0;
        pNode = pMap->getNodeUnchecked(iCenterX + 1, iCenterY + 1);
        if(pNode->iBlock[3] == iFloorTileGood)
            pNode->iBlock[3] = iFloorTileGoodCenter + 3;
    }

    // Set wall animations
    int iNextAnim = 1;
    THAnimation *pAnim = l_map_updateblueprint_getnextanim(L, iNextAnim);
    THMapNode *pNode = pMap->getNodeUnchecked(iNewX, iNewY);
    pAnim->setAnimation(pAnims, iWallAnimTopCorner);
    pAnim->setFlags(THDF_ListBottom | (IsValid(pNode) ? 0 : THDF_AltPalette));
    pAnim->attachToTile(pNode);

    for(int iX = iNewX; iX < iNewX + iNewW; ++iX)
    {
        if(iX != iNewX)
        {
            pAnim = l_map_updateblueprint_getnextanim(L, iNextAnim);
            pNode = pMap->getNodeUnchecked(iX, iNewY);
            pAnim->setAnimation(pAnims, iWallAnim);
            pAnim->setFlags(THDF_ListBottom | (IsValid(pNode) ? 0 : THDF_AltPalette));
            pAnim->attachToTile(pNode);
            pAnim->setPosition(0, 0);
        }
        pAnim = l_map_updateblueprint_getnextanim(L, iNextAnim);
        pNode = pMap->getNodeUnchecked(iX, iNewY + iNewH - 1);
        pAnim->setAnimation(pAnims, iWallAnim);
        pAnim->setFlags(THDF_ListBottom | (IsValid(pNode) ? 0 : THDF_AltPalette));
        pNode = pMap->getNodeUnchecked(iX, iNewY + iNewH);
        pAnim->attachToTile(pNode);
        pAnim->setPosition(0, -1);
    }
    for(int iY = iNewY; iY < iNewY + iNewH; ++iY)
    {
        if(iY != iNewY)
        {
            pAnim = l_map_updateblueprint_getnextanim(L, iNextAnim);
            pNode = pMap->getNodeUnchecked(iNewX, iY);
            pAnim->setAnimation(pAnims, iWallAnim);
            pAnim->setFlags(THDF_ListBottom | THDF_FlipHorizontal | (IsValid(pNode) ? 0 : THDF_AltPalette));
            pAnim->attachToTile(pNode);
            pAnim->setPosition(2, 0);
        }
        pAnim = l_map_updateblueprint_getnextanim(L, iNextAnim);
        pNode = pMap->getNodeUnchecked(iNewX + iNewW - 1, iY);
        pAnim->setAnimation(pAnims, iWallAnim);
        pAnim->setFlags(THDF_ListBottom | THDF_FlipHorizontal | (IsValid(pNode) ? 0 : THDF_AltPalette));
        pNode = pMap->getNodeUnchecked(iNewX + iNewW, iY);
        pAnim->attachToTile(pNode);
        pAnim->setPosition(2, -1);
    }

#undef IsValid

    // Clear away extra animations
    int iAnimCount = (int)lua_objlen(L, 10);
    if(iAnimCount >= iNextAnim)
    {
        for(int i = iNextAnim; i <= iAnimCount; ++i)
        {
            pAnim = l_map_updateblueprint_getnextanim(L, iNextAnim);
            pAnim->removeFromTile();
            lua_pushnil(L);
            lua_rawseti(L, 10, i);
        }
    }

    lua_pushboolean(L, valid ? 1 : 0);
    return 1;
}

static int l_map_getsize(lua_State *L)
{
    THMap* pMap = luaT_testuserdata<THMap>(L);
    lua_pushinteger(L, pMap->getWidth());
    lua_pushinteger(L, pMap->getHeight());
    return 2;
}

static int l_map_getcell(lua_State *L)
{
    THMap* pMap = luaT_testuserdata<THMap>(L);
    int iX = luaL_checkint(L, 2) - 1; // Lua arrays start at 1 - pretend
    int iY = luaL_checkint(L, 3) - 1; // the map does too.
    THMapNode* pNode = pMap->getNode(iX, iY);
    if(pNode == NULL)
        return luaL_argerror(L, 2, "Map co-ordinates out of bounds");
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
        int iLayer = luaL_checkint(L, 4) - 1;
        if(iLayer < 0 || iLayer >= 4)
            return luaL_argerror(L, 4, "Layer index is out of bounds (1-4)");
        lua_pushinteger(L, pNode->iBlock[iLayer]);
        return 1;
    }
}

static int l_map_getcellflags(lua_State *L)
{
    THMap* pMap = luaT_testuserdata<THMap>(L);
    int iX = luaL_checkint(L, 2) - 1; // Lua arrays start at 1 - pretend
    int iY = luaL_checkint(L, 3) - 1; // the map does too.
    THMapNode* pNode = pMap->getNode(iX, iY);
    if(pNode == NULL)
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

#define Flag(CName, LName) \
    { \
        lua_pushliteral(L, LName); \
        lua_pushboolean(L, (pNode->iFlags & CName) ? 1 : 0); \
        lua_settable(L, 4); \
    }

#define FlagInt(CField, LName) \
    { \
        lua_pushliteral(L, LName); \
        lua_pushinteger(L, pNode->CField); \
        lua_settable(L, 4); \
    }

    Flag(THMN_Passable, "passable")
    Flag(THMN_Hospital, "hospital")
    Flag(THMN_Buildable, "buildable")
    Flag(THMN_Room, "room")
    Flag(THMN_DoorWest, "doorWest")
    Flag(THMN_DoorNorth, "doorNorth")
    Flag(THMN_TallWest, "tallWest")
    Flag(THMN_TallNorth, "tallNorth")
    Flag(THMN_CanTravelN, "travelNorth")
    Flag(THMN_CanTravelE, "travelEast")
    Flag(THMN_CanTravelS, "travelSouth")
    Flag(THMN_CanTravelW, "travelWest")
    Flag(THMN_DoNotIdle, "doNotIdle")

    FlagInt(iRoomId, "roomId")
    FlagInt(iFlags >> 24, "thob")

#undef FlagInt
#undef Flag

    return 1;
}

static int l_map_setcellflags(lua_State *L)
{
    THMap* pMap = luaT_testuserdata<THMap>(L);
    int iX = luaL_checkint(L, 2) - 1; // Lua arrays start at 1 - pretend
    int iY = luaL_checkint(L, 3) - 1; // the map does too.
    THMapNode* pNode = pMap->getNode(iX, iY);
    if(pNode == NULL)
        return luaL_argerror(L, 2, "Map co-ordinates out of bounds");
    luaL_checktype(L, 4, LUA_TTABLE);
    lua_settop(L, 4);

#define Flag(CName, LName) \
    if(strcmp(field, LName) == 0) \
    { \
        if(lua_toboolean(L, 6) == 0) \
            pNode->iFlags &= ~CName; \
        else \
            pNode->iFlags |= CName; \
    } else

    lua_pushnil(L);
    while(lua_next(L, 4))
    {
        if(lua_type(L, 5) == LUA_TSTRING)
        {
            const char *field = lua_tostring(L, 5);
            Flag(THMN_Passable, "passable")
            Flag(THMN_Hospital, "hospital")
            Flag(THMN_Buildable, "buildable")
            Flag(THMN_Room, "room")
            Flag(THMN_DoorWest, "doorWest")
            Flag(THMN_DoorNorth, "doorNorth")
            Flag(THMN_TallWest, "tallWest")
            Flag(THMN_TallNorth, "tallNorth")
            Flag(THMN_DoNotIdle, "doNotIdle")
            /* else */ if(strcmp(field, "thob") == 0)
            {
                pNode->iFlags &= 0x00FFFFFF;
                pNode->iFlags |= static_cast<uint32_t>(lua_tointeger(L, 6)) << 24;
            }
            else
            {
                luaL_error(L, "Invalid flag \'%s\'", field);
            }
        }
        lua_settop(L, 5);
    }

#undef Flag

    return 0;
}

static int l_map_setwallflags(lua_State *L)
{
    THMap* pMap = luaT_testuserdata<THMap>(L);
    pMap->setAllWallDrawFlags((unsigned char)luaL_checkint(L, 2));
    lua_settop(L, 1);
    return 1;
}

static int l_map_setcell(lua_State *L)
{
    THMap* pMap = luaT_testuserdata<THMap>(L);
    int iX = luaL_checkint(L, 2) - 1; // Lua arrays start at 1 - pretend
    int iY = luaL_checkint(L, 3) - 1; // the map does too.
    THMapNode* pNode = pMap->getNode(iX, iY);
    if(pNode == NULL)
        return luaL_argerror(L, 2, "Map co-ordinates out of bounds");
    if(lua_gettop(L) >= 7)
    {
        pNode->iBlock[0] = (uint16_t)luaL_checkint(L, 4);
        pNode->iBlock[1] = (uint16_t)luaL_checkint(L, 5);
        pNode->iBlock[2] = (uint16_t)luaL_checkint(L, 6);
        pNode->iBlock[3] = (uint16_t)luaL_checkint(L, 7);
    }
    else
    {
        int iLayer = luaL_checkint(L, 4) - 1;
        if(iLayer < 0 || iLayer >= 4)
            return luaL_argerror(L, 4, "Layer index is out of bounds (1-4)");
        int iBlock = luaL_checkint(L, 5);
        pNode->iBlock[iLayer] = (uint16_t)iBlock;
    }

    lua_settop(L, 1);
    return 1;
}

static int l_map_updateshadows(lua_State *L)
{
    THMap* pMap = luaT_testuserdata<THMap>(L);
    pMap->updateShadows();
    lua_settop(L, 1);
    return 1;
}

static int l_map_mark_room(lua_State *L)
{
    THMap* pMap = luaT_testuserdata<THMap>(L);
    int iX_ = luaL_checkint(L, 2) - 1;
    int iY_ = luaL_checkint(L, 3) - 1;
    int iW = luaL_checkint(L, 4);
    int iH = luaL_checkint(L, 5);
    int iTile = luaL_checkint(L, 6);
    int iRoomId = luaL_optint(L, 7, 0);

    if(iX_ < 0 || iY_ < 0 || (iX_ + iW) > pMap->getWidth() || (iY_ + iH) > pMap->getHeight())
        luaL_argerror(L, 2, "Rectangle is out of bounds");

    for(int iY = iY_; iY < iY_ + iH; ++iY)
    {
        for(int iX = iX_; iX < iX_ + iW; ++iX)
        {
            THMapNode *pNode = pMap->getNodeUnchecked(iX, iY);
            pNode->iBlock[0] = iTile;
            pNode->iBlock[3] = 0;
            uint32_t iFlags = pNode->iFlags;
            iFlags |= THMN_Room;
            iFlags |= (iFlags & THMN_PassableIfNotForBlueprint) >> THMN_PassableIfNotForBlueprint_ShiftDelta;
            iFlags &= ~THMN_PassableIfNotForBlueprint;
            pNode->iFlags = iFlags;
            pNode->iRoomId = iRoomId;
        }
    }

    pMap->updatePathfinding();
    pMap->updateShadows();

    lua_settop(L, 1);
    return 1;
}

static int l_map_unmark_room(lua_State *L)
{
    THMap* pMap = luaT_testuserdata<THMap>(L);
    int iX_ = luaL_checkint(L, 2) - 1;
    int iY_ = luaL_checkint(L, 3) - 1;
    int iW = luaL_checkint(L, 4);
    int iH = luaL_checkint(L, 5);

    if(iX_ < 0 || iY_ < 0 || (iX_ + iW) > pMap->getWidth() || (iY_ + iH) > pMap->getHeight())
        luaL_argerror(L, 2, "Rectangle is out of bounds");

    for(int iY = iY_; iY < iY_ + iH; ++iY)
    {
        for(int iX = iX_; iX < iX_ + iW; ++iX)
        {
            THMapNode *pNode = pMap->getNodeUnchecked(iX, iY);
            pNode->iBlock[0] = pMap->getOriginalNodeUnchecked(iX, iY)->iBlock[0];
            pNode->iFlags &= ~THMN_Room;
            pNode->iRoomId = 0;
        }
    }

    pMap->updatePathfinding();
    pMap->updateShadows();

    lua_settop(L, 1);
    return 1;
}

static int l_map_draw(lua_State *L)
{
    THMap* pMap = luaT_testuserdata<THMap>(L);
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L, 2);

    pMap->draw(pCanvas, luaL_checkint(L, 3), luaL_checkint(L, 4), luaL_checkint(L, 5),
        luaL_checkint(L, 6), luaL_optint(L, 7, 0), luaL_optint(L, 8, 0));

    lua_settop(L, 1);
    return 1;
}

static int l_map_hittest(lua_State *L)
{
    THMap* pMap = luaT_testuserdata<THMap>(L);
    THDrawable* pObject = pMap->hitTest(luaL_checkint(L, 2), luaL_checkint(L, 3));
    if(pObject == NULL)
        return 0;
    lua_rawgeti(L, lua_upvalueindex(1), 1);
    lua_pushlightuserdata(L, pObject);
    lua_gettable(L, -2);
    return 1;
}

static int l_palette_new(lua_State *L)
{
    THPalette* pPalette = luaT_stdnew<THPalette>(L);
    return 1;
}

static int l_palette_load(lua_State *L)
{
    THPalette* pPalette = luaT_testuserdata<THPalette>(L);
    size_t iDataLen;
    const unsigned char* pData = luaT_checkfile(L, 2, &iDataLen);

    if(pPalette->loadFromTHFile(pData, iDataLen))
        lua_pushboolean(L, 1);
    else
        lua_pushboolean(L, 0);
    return 1;
}

static int l_palette_set_entry(lua_State *L)
{
    THPalette* pPalette = luaT_testuserdata<THPalette>(L);
    lua_pushboolean(L, pPalette->setEntry(luaL_checkint(L, 2),
        static_cast<uint8_t>(luaL_checkinteger(L, 3)),
        static_cast<uint8_t>(luaL_checkinteger(L, 4)),
        static_cast<uint8_t>(luaL_checkinteger(L, 5)))
        ? 1 : 0);
    return 1;
}

static int l_rawbitmap_new(lua_State *L)
{
    THRawBitmap* pBitmap = luaT_stdnew<THRawBitmap>(L, LUA_ENVIRONINDEX, true);
    return 1;
}

static int l_rawbitmap_set_pal(lua_State *L)
{
    THRawBitmap* pBitmap = luaT_testuserdata<THRawBitmap>(L);
    THPalette* pPalette = luaT_testuserdata<THPalette>(L, 2);
    lua_settop(L, 2);

    pBitmap->setPalette(pPalette);
    luaT_setenvfield(L, 1, "palette");
    return 1;
}

static int l_rawbitmap_load(lua_State *L)
{
    THRawBitmap* pBitmap = luaT_testuserdata<THRawBitmap>(L);
    size_t iDataLen;
    const unsigned char* pData = luaT_checkfile(L, 2, &iDataLen);
    int iWidth = luaL_checkint(L, 3);
    THRenderTarget* pSurface = luaT_testuserdata<THRenderTarget>(L, 4, lua_upvalueindex(1), false);

    if(pBitmap->loadFromTHFile(pData, iDataLen, iWidth, pSurface))
        lua_pushboolean(L, 1);
    else
        lua_pushboolean(L, 0);

    return 1;
}

static int l_rawbitmap_draw(lua_State *L)
{
    THRawBitmap* pBitmap = luaT_testuserdata<THRawBitmap>(L);
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L, 2);

    if(lua_gettop(L) >= 8)
    {
        pBitmap->draw(pCanvas, luaL_checkint(L, 3), luaL_checkint(L, 4),
            luaL_checkint(L, 5), luaL_checkint(L, 6), luaL_checkint(L, 7),
            luaL_checkint(L, 8));
    }
    else
        pBitmap->draw(pCanvas, luaL_optint(L, 3, 0), luaL_optint(L, 4, 0));

    lua_settop(L, 1);
    return 1;
}

static int l_spritesheet_new(lua_State *L)
{
    THSpriteSheet* pSheet = luaT_stdnew<THSpriteSheet>(L, LUA_ENVIRONINDEX, true);
    return 1;
}

static int l_spritesheet_set_pal(lua_State *L)
{
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L);
    THPalette* pPalette = luaT_testuserdata<THPalette>(L, 2);
    lua_settop(L, 2);

    pSheet->setPalette(pPalette);
    luaT_setenvfield(L, 1, "palette");
    return 1;
}

static int l_spritesheet_load(lua_State *L)
{
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L);
    size_t iDataLenTable, iDataLenChunk;
    const unsigned char* pDataTable = luaT_checkfile(L, 2, &iDataLenTable);
    const unsigned char* pDataChunk = luaT_checkfile(L, 3, &iDataLenChunk);
    bool bComplex = lua_toboolean(L, 4) != 0;
    THRenderTarget* pSurface = luaT_testuserdata<THRenderTarget>(L, 5, lua_upvalueindex(1), false);

    if(pSheet->loadFromTHFile(pDataTable, iDataLenTable, pDataChunk, iDataLenChunk, bComplex, pSurface))
        lua_pushboolean(L, 1);
    else
        lua_pushboolean(L, 0);

    return 1;
}

static int l_spritesheet_count(lua_State *L)
{
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L);

    lua_pushinteger(L, pSheet->getSpriteCount());
    return 1;
}

static int l_spritesheet_size(lua_State *L)
{
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L);
    int iSprite = luaL_checkint(L, 2); // No array adjustment
    if(iSprite < 0 || (unsigned int)iSprite >= pSheet->getSpriteCount())
        return luaL_argerror(L, 2, "Sprite index out of bounds");

    unsigned int iWidth, iHeight;
    pSheet->getSpriteSizeUnchecked((unsigned int)iSprite, &iWidth, &iHeight);

    lua_pushinteger(L, iWidth);
    lua_pushinteger(L, iHeight);
    return 2;
}

static int l_spritesheet_draw(lua_State *L)
{
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L);
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L, 2);
    int iSprite = luaL_checkint(L, 3); // No array adjustment

    pSheet->drawSprite(pCanvas, iSprite, luaL_optint(L, 4, 0), luaL_optint(L, 5, 0), luaL_optint(L, 6, 0));

    lua_settop(L, 1);
    return 1;
}

static int l_spritesheet_hittest(lua_State *L)
{
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L);
    unsigned int iSprite = (unsigned int)luaL_checkinteger(L, 2);
    int iX = luaL_checkint(L, 3);
    int iY = luaL_checkint(L, 4);
    unsigned long iFlags = (unsigned long)luaL_optint(L, 5, 0);
    return pSheet->hitTestSprite(iSprite, iX, iY, iFlags);
}

static int l_font_new(lua_State *L)
{
    THFont* pFont = luaT_stdnew<THFont>(L, LUA_ENVIRONINDEX, true);
    return 1;
}

static int l_font_set_spritesheet(lua_State *L)
{
    THFont* pFont = luaT_testuserdata<THFont>(L);
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L, 2);
    lua_settop(L, 2);

    pFont->setSpriteSheet(pSheet);
    luaT_setenvfield(L, 1, "sprites");
    return 1;
}

static int l_font_set_sep(lua_State *L)
{
    THFont* pFont = luaT_testuserdata<THFont>(L);

    pFont->setSeparation(luaL_checkint(L, 2), luaL_optint(L, 3, 0));

    lua_settop(L, 1);
    return 1;
}

static int l_font_get_size(lua_State *L)
{
    THFont* pFont = luaT_testuserdata<THFont>(L);
    size_t iMsgLen;
    const char* sMsg = luaL_checklstring(L, 2, &iMsgLen);

    int iWidth, iHeight;
    pFont->getTextSize(sMsg, iMsgLen, &iWidth, &iHeight);

    lua_pushinteger(L, iWidth);
    lua_pushinteger(L, iHeight);
    return 2;
}

static int l_font_draw(lua_State *L)
{
    THFont* pFont = luaT_testuserdata<THFont>(L);
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L, 2);
    size_t iMsgLen;
    const char* sMsg = luaL_checklstring(L, 3, &iMsgLen);
    int iX = luaL_checkint(L, 4);
    int iY = luaL_checkint(L, 5);
    if(!lua_isnoneornil(L, 7))
    {
        int iW = luaL_checkint(L, 6);
        int iH = luaL_checkint(L, 7);
        int iWidth, iHeight;
        pFont->getTextSize(sMsg, iMsgLen, &iWidth, &iHeight);
        if(iW > iWidth)
            iX += (iW - iWidth) / 2;
        if(iH > iHeight)
            iY += (iH - iHeight) / 2;
    }
    pFont->drawText(pCanvas, sMsg, iMsgLen, iX, iY);

    lua_settop(L, 1);
    return 1;
}

static int l_font_draw_wrapped(lua_State *L)
{
    THFont* pFont = luaT_testuserdata<THFont>(L);
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L, 2);
    size_t iMsgLen;
    const char* sMsg = luaL_checklstring(L, 3, &iMsgLen);
    int iX = luaL_checkint(L, 4);
    int iY = luaL_checkint(L, 5);
    int iW = luaL_checkint(L, 6);
	int iH = 0;
	if (!lua_isnoneornil(L, 7))
	{
		iH = luaL_checkint(L, 7);
	}

	lua_settop(L, 1);

    lua_pushinteger(L, pFont->drawTextWrapped(pCanvas, sMsg, iMsgLen, iX, iY, iW, iH));

    return 1;
}

static int l_layers_new(lua_State *L)
{
    THLayers_t* pLayers = luaT_stdnew<THLayers_t>(L, LUA_ENVIRONINDEX, false);
    for(int i = 0; i < 13; ++i)
        pLayers->iLayerContents[i] = 0;
    return 1;
}

static int l_layers_get(lua_State *L)
{
    THLayers_t* pLayers = luaT_testuserdata<THLayers_t>(L);
    int iLayer = luaL_checkint(L, 2);
    if(0 <= iLayer && iLayer < 13)
        lua_pushinteger(L, pLayers->iLayerContents[iLayer]);
    else
        lua_pushnil(L);
    return 1;
}

static int l_layers_set(lua_State *L)
{
    THLayers_t* pLayers = luaT_testuserdata<THLayers_t>(L);
    int iLayer = luaL_checkint(L, 2);
    int iValue = luaL_checkint(L, 3);
    if(0 <= iLayer && iLayer < 13)
        pLayers->iLayerContents[iLayer] = (unsigned char)iValue;
    return 0;
}

static int l_layers_persist(lua_State *L)
{
    THLayers_t* pLayers = luaT_testuserdata<THLayers_t>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    LuaPersistWriter* pWriter = (LuaPersistWriter*)lua_touserdata(L, 1);

    int iNumLayers = 13;
    for( ; iNumLayers >= 1; --iNumLayers)
    {
        if(pLayers->iLayerContents[iNumLayers - 1] != 0)
            break;
    }
    pWriter->writeVUInt(iNumLayers);
    pWriter->writeByteStream(pLayers->iLayerContents, iNumLayers);
    return 0;
}

static int l_layers_depersist(lua_State *L)
{
    THLayers_t* pLayers = luaT_testuserdata<THLayers_t>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    LuaPersistReader* pReader = (LuaPersistReader*)lua_touserdata(L, 1);

    memset(pLayers->iLayerContents, 0, sizeof(pLayers->iLayerContents));
    int iNumLayers;
    if(!pReader->readVUInt(iNumLayers))
        return 0;
    if(iNumLayers > 13)
    {
        if(!pReader->readByteStream(pLayers->iLayerContents, 13))
            return 0;
        if(!pReader->readByteStream(NULL, iNumLayers - 13))
            return 0;
    }
    else
    {
        if(!pReader->readByteStream(pLayers->iLayerContents, iNumLayers))
            return 0;
    }
    return 0;
}

static int l_anims_new(lua_State *L)
{
    THAnimationManager* pAnims = luaT_stdnew<THAnimationManager>(L, LUA_ENVIRONINDEX, true);
    return 1;
}

static int l_anims_set_spritesheet(lua_State *L)
{
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L);
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L, 2);
    lua_settop(L, 2);

    pAnims->setSpriteSheet(pSheet);
    luaT_setenvfield(L, 1, "sprites");
    return 1;
}

static int l_anims_load(lua_State *L)
{
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L);
    size_t iStartDataLength, iFrameDataLength, iListDataLength, iElementDataLength;
    const unsigned char* pStartData = luaT_checkfile(L, 2, &iStartDataLength);
    const unsigned char* pFrameData = luaT_checkfile(L, 3, &iFrameDataLength);
    const unsigned char* pListData = luaT_checkfile(L, 4, &iListDataLength);
    const unsigned char* pElementData = luaT_checkfile(L, 5, &iElementDataLength);

    if(pAnims->loadFromTHFile(pStartData, iStartDataLength, pFrameData, iFrameDataLength,
        pListData, iListDataLength, pElementData, iElementDataLength))
    {
        lua_pushboolean(L, 1);
    }
    else
    {
        lua_pushboolean(L, 0);
    }

    return 1;
}

static int l_anims_getfirst(lua_State *L)
{
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L);
    int iAnim = luaL_checkint(L, 2);

    lua_pushinteger(L, pAnims->getFirstFrame((unsigned int)iAnim));
    return 1;
}

static int l_anims_getnext(lua_State *L)
{
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L);
    int iFrame = luaL_checkint(L, 2);

    lua_pushinteger(L, pAnims->getNextFrame((unsigned int)iFrame));
    return 1;
}

static int l_anims_set_alt_pal(lua_State *L)
{
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L);
    unsigned int iAnimation = luaL_checkint(L, 2);
    size_t iPalLen;
    const unsigned char *pPal = luaT_checkfile(L, 3, &iPalLen);
    if(iPalLen != 256)
        return luaL_typerror(L, 3, "GhostPalette string");

    pAnims->setAnimationAltPaletteMap(iAnimation, pPal);

    lua_getfenv(L, 1);
    lua_insert(L, 2);
    lua_settop(L, 4);
    lua_settable(L, 2);
    lua_settop(L, 1);
    return 1;
}

static int l_anims_set_marker(lua_State *L)
{
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L);
    lua_pushboolean(L, pAnims->setFrameMarker((unsigned int)luaL_checkinteger(L, 2),
        luaL_checkint(L, 3), luaL_checkint(L, 4)) ? 1 : 0);
    return 1;
}

static int l_anims_set_secondary_marker(lua_State *L)
{
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L);
    lua_pushboolean(L, pAnims->setFrameSecondaryMarker((unsigned int)luaL_checkinteger(L, 2),
        luaL_checkint(L, 3), luaL_checkint(L, 4)) ? 1 : 0);
    return 1;
}

static int l_anims_draw(lua_State *L)
{
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L);
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L, 2);
    int iFrame = luaL_checkint(L, 3);
    THLayers_t* pLayers = luaT_testuserdata<THLayers_t>(L, 4, lua_upvalueindex(2));
    int iX = luaL_checkint(L, 5);
    int iY = luaL_checkint(L, 6);
    int iFlags = luaL_optint(L, 7, 0);
    
    pAnims->drawFrame(pCanvas, (unsigned int)iFrame, *pLayers, iX, iY, iFlags);

    lua_settop(L, 1);
    return 1;
}

static int l_path_new(lua_State *L)
{
    THPathfinder* pPathfinder = luaT_stdnew<THPathfinder>(L, LUA_ENVIRONINDEX, true);
    return 1;
}

static int l_path_set_map(lua_State *L)
{
    THPathfinder* pPathfinder = luaT_testuserdata<THPathfinder>(L);
    THMap* pMap = luaT_testuserdata<THMap>(L, 2);
    lua_settop(L, 2);

    pPathfinder->setDefaultMap(pMap);
    luaT_setenvfield(L, 1, "map");
    return 1;
}

static int l_path_persist(lua_State *L)
{
    THPathfinder* pPathfinder = luaT_testuserdata<THPathfinder>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    pPathfinder->persist((LuaPersistWriter*)lua_touserdata(L, 1));
    return 0;
}

static int l_path_depersist(lua_State *L)
{
    THPathfinder* pPathfinder = luaT_testuserdata<THPathfinder>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    LuaPersistReader* pReader = (LuaPersistReader*)lua_touserdata(L, 1);

    pPathfinder->depersist(pReader);
    luaT_getenvfield(L, 2, "map");
    pPathfinder->setDefaultMap(reinterpret_cast<THMap*>(lua_touserdata(L, -1)));
    return 0;
}

static int l_path_is_reachable_from_hospital(lua_State *L)
{
    THPathfinder* pPathfinder = luaT_testuserdata<THPathfinder>(L);
    if(pPathfinder->findPathToHospital(NULL, luaL_checkint(L, 2) - 1,
        luaL_checkint(L, 3) - 1))
    {
        lua_pushboolean(L, 1);
        int iX, iY;
        pPathfinder->getPathEnd(&iX, &iY);
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
    THPathfinder* pPathfinder = luaT_testuserdata<THPathfinder>(L);
    if(pPathfinder->findPath(NULL, luaL_checkint(L, 2) - 1, luaL_checkint(L, 3) - 1,
        luaL_checkint(L, 4) - 1, luaL_checkint(L, 5) - 1))
    {
        lua_pushinteger(L, pPathfinder->getPathLength());
    }
    else
    {
        lua_pushboolean(L, 0);
    }
    return 1;
}

static int l_path_path(lua_State *L)
{
    THPathfinder* pPathfinder = luaT_testuserdata<THPathfinder>(L);
    pPathfinder->findPath(NULL, luaL_checkint(L, 2) - 1, luaL_checkint(L, 3) - 1,
        luaL_checkint(L, 4) - 1, luaL_checkint(L, 5) - 1);
    pPathfinder->pushResult(L);
    return 2;
}

static int l_path_idle(lua_State *L)
{
    THPathfinder* pPathfinder = luaT_testuserdata<THPathfinder>(L);
    if(!pPathfinder->findIdleTile(NULL, luaL_checkint(L, 2) - 1,
        luaL_checkint(L, 3) - 1, luaL_optint(L, 4, 0)))
    {
        return 0;
    }
    int iX, iY;
    pPathfinder->getPathEnd(&iX, &iY);
    lua_pushinteger(L, iX + 1);
    lua_pushinteger(L, iY + 1);
    return 2;
}

static int l_path_visit(lua_State *L)
{
    THPathfinder* pPathfinder = luaT_testuserdata<THPathfinder>(L);
    luaL_checktype(L, 6, LUA_TFUNCTION);
    lua_pushboolean(L, pPathfinder->visitObjects(NULL, luaL_checkint(L, 2) - 1,
        luaL_checkint(L, 3) - 1, static_cast<THObjectType>(luaL_checkint(L, 4)),
        luaL_checkint(L, 5), L, 6, luaL_checkint(L, 4) == 0 ? true : false) ? 1 : 0);
    return 1;
}

static int l_anim_new(lua_State *L)
{
    THAnimation* pAnimation = luaT_stdnew<THAnimation>(L, LUA_ENVIRONINDEX, true);
    lua_rawgeti(L, LUA_ENVIRONINDEX, 2);
    lua_pushlightuserdata(L, pAnimation);
    lua_pushvalue(L, -3);
    lua_rawset(L, -3);
    lua_pop(L, 1);
    return 1;
}

static int l_anim_persist(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    LuaPersistWriter* pWriter = (LuaPersistWriter*)lua_touserdata(L, 1);

    pAnimation->persist(pWriter);
    lua_rawgeti(L, LUA_ENVIRONINDEX, 1);
    lua_pushlightuserdata(L, pAnimation);
    lua_gettable(L, -2);
    pWriter->writeStackObject(-1);
    lua_pop(L, 2);
    return 0;
}

static int l_anim_depersist(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    LuaPersistReader* pReader = (LuaPersistReader*)lua_touserdata(L, 1);

    new (pAnimation) THAnimation; // Call constructor

    lua_rawgeti(L, LUA_ENVIRONINDEX, 2);
    lua_pushlightuserdata(L, pAnimation);
    lua_pushvalue(L, 2);
    lua_settable(L, -3);
    lua_pop(L, 1);
    pAnimation->depersist(pReader);
    lua_rawgeti(L, LUA_ENVIRONINDEX, 1);
    lua_pushlightuserdata(L, pAnimation);
    if(!pReader->readStackObject())
        return 0;
    lua_settable(L, -3);
    lua_pop(L, 1);
    return 0;
}

static int l_anim_set_hitresult(lua_State *L)
{
    luaL_checktype(L, 1, LUA_TUSERDATA);
    lua_settop(L, 2);
    lua_rawgeti(L, LUA_ENVIRONINDEX, 1);
    lua_pushlightuserdata(L, lua_touserdata(L, 1));
    lua_pushvalue(L, 2);
    lua_settable(L, 3);
    lua_settop(L, 1);
    return 1;
}

static int l_anim_set_frame(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    pAnimation->setFrame(luaL_checkint(L, 2));
    lua_settop(L, 1);
    return 1;
}

static int l_anim_set_anim(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    THAnimationManager* pManager = luaT_testuserdata<THAnimationManager>(L, 2);
    int iAnim = luaL_checkint(L, 3);
    if(iAnim < 0 || (unsigned int)iAnim >= pManager->getAnimationCount())
        luaL_argerror(L, 3, "Animation index out of bounds");

    if(lua_isnoneornil(L, 4))
        pAnimation->setFlags(0);
    else
        pAnimation->setFlags(luaL_checkint(L, 4));

    pAnimation->setAnimation(pManager, iAnim);
    lua_settop(L, 2);
    luaT_setenvfield(L, 1, "animator");
    lua_pushnil(L);
    luaT_setenvfield(L, 1, "morph_target");

    return 1;
}

static int l_anim_set_morph(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    THAnimation* pMorphTarget = luaT_testuserdata<THAnimation>(L, 2, LUA_ENVIRONINDEX);

    pAnimation->setMorphTarget(pMorphTarget);
    lua_settop(L, 2);
    luaT_setenvfield(L, 1, "morph_target");

    return 1;
}

static int l_anim_get_anim(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    lua_pushinteger(L, pAnimation->getAnimation());

    return 1;
}

static int l_anim_set_tile(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    if(lua_isnoneornil(L, 2))
    {
        pAnimation->removeFromTile();
        lua_pushnil(L);
        luaT_setenvfield(L, 1, "map");
        lua_settop(L, 1);
    }
    else
    {
        THMap* pMap = luaT_testuserdata<THMap>(L, 2);
        THMapNode* pNode = pMap->getNode(luaL_checkint(L, 3) - 1, luaL_checkint(L, 4) - 1);
        if(pNode)
            pAnimation->attachToTile(pNode);
        else
        {
            luaL_argerror(L, 3, lua_pushfstring(L, "Map index out of bounds ("
                LUA_NUMBER_FMT "," LUA_NUMBER_FMT ")", lua_tonumber(L, 3),
                lua_tonumber(L, 4)));
        }

        lua_settop(L, 2);
        luaT_setenvfield(L, 1, "map");
    }

    return 1;
}

static int l_anim_get_tile(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    lua_settop(L, 1);
    lua_getfenv(L, 1);
    lua_getfield(L, 2, "map");
    lua_replace(L, 2);
    if(lua_isnil(L, 2))
    {
        return 0;
    }
    THMap* pMap = (THMap*)lua_touserdata(L, 2);
    const THLinkList* pListNode = pAnimation->getPrevious();
    while(pListNode->pPrev)
    {
        pListNode = pListNode->pPrev;
    }
    // Casting pListNode to a THMapNode* is slightly dubious, but it should
    // work. If on the normal list, then pListNode will be a THMapNode*, and
    // all is fine. However, if on the early list, pListNode will be pointing
    // to a member of a THMapNode, so we're relying on pointer arithmetic
    // being a subtract and integer divide by sizeof(THMapNode) to yield the
    // correct map node.
    const THMapNode *pRootNode = pMap->getNodeUnchecked(0, 0);
    uintptr_t iDiff = reinterpret_cast<const char*>(pListNode) -
                      reinterpret_cast<const char*>(pRootNode);
    int iIndex = (int)(iDiff / sizeof(THMapNode));
    int iY = iIndex / pMap->getWidth();
    int iX = iIndex - (iY * pMap->getWidth());
    lua_pushinteger(L, iX + 1);
    lua_pushinteger(L, iY + 1);
    return 3; // map, x, y
}

static int l_anim_set_parent(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    THAnimation* pParent = luaT_testuserdata<THAnimation>(L, 2, LUA_ENVIRONINDEX, false);
    pAnimation->setParent(pParent);
    lua_settop(L, 1);
    return 1;
}

static int l_anim_set_flag(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    pAnimation->setFlags(luaL_checkint(L, 2));

    lua_settop(L, 1);
    return 1;
}

static int l_anim_set_flag_partial(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    int iFlags = luaL_checkint(L, 2);
    if(lua_isnone(L, 3) || lua_toboolean(L, 3))
    {
        pAnimation->setFlags(pAnimation->getFlags() | iFlags);
    }
    else
    {
        pAnimation->setFlags(pAnimation->getFlags() & ~iFlags);
    }
    lua_settop(L, 1);
    return 1;
}

static int l_anim_make_visible(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    pAnimation->setFlags(pAnimation->getFlags() & ~(THDF_Alpha50 | THDF_Alpha75));

    lua_settop(L, 1);
    return 1;
}

static int l_anim_make_invisible(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    pAnimation->setFlags(pAnimation->getFlags() | THDF_Alpha50 | THDF_Alpha75);

    lua_settop(L, 1);
    return 1;
}

static int l_anim_get_flag(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    lua_pushinteger(L, pAnimation->getFlags());

    return 1;
}

static int l_anim_set_position(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);

    pAnimation->setPosition(luaL_checkint(L, 2), luaL_checkint(L, 3));

    lua_settop(L, 1);
    return 1;
}

static int l_anim_get_position(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);

    lua_pushinteger(L, pAnimation->getX());
    lua_pushinteger(L, pAnimation->getY());

    return 2;
}

static int l_anim_set_speed(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);

    pAnimation->setSpeed(luaL_optint(L, 2, 0), luaL_optint(L, 3, 0));

    lua_settop(L, 1);
    return 1;
}

static int l_anim_set_layer(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);

    pAnimation->setLayer(luaL_checkint(L, 2), luaL_optint(L, 3, 0));

    lua_settop(L, 1);
    return 1;
}

static int l_anim_set_tag(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    lua_settop(L, 2);
    luaT_setenvfield(L, 1, "tag");
    return 1;
}

static int l_anim_get_tag(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    lua_settop(L, 1);
    lua_getfenv(L, 1);
    lua_getfield(L, 2, "tag");
    return 1;
}

static int l_anim_get_marker(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    int iX = 0;
    int iY = 0;
    pAnimation->getMarker(&iX, &iY);
    lua_pushinteger(L, iX);
    lua_pushinteger(L, iY);
    return 2;
}

static int l_anim_get_secondary_marker(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    int iX = 0;
    int iY = 0;
    pAnimation->getSecondaryMarker(&iX, &iY);
    lua_pushinteger(L, iX);
    lua_pushinteger(L, iY);
    return 2;
}

static int l_anim_tick(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    pAnimation->tick();
    lua_settop(L, 1);
    return 1;
}

static int l_anim_draw(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L, 2);
    pAnimation->draw(pCanvas, luaL_checkint(L, 3), luaL_checkint(L, 4));
    lua_settop(L, 1);
    return 1;
}

static int l_cursor_new(lua_State *L)
{
    THCursor* pCursor = luaT_stdnew<THCursor>(L, LUA_ENVIRONINDEX, false);
    return 1;
}

static int l_cursor_load(lua_State *L)
{
    THCursor* pCursor = luaT_testuserdata<THCursor>(L);
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L, 2);
    if(pCursor->createFromSprite(pSheet, (unsigned int)luaL_checkint(L, 3),
        luaL_optint(L, 4, 0), luaL_optint(L, 5, 0)))
    {
        lua_settop(L, 1);
        return 1;
    }
    else
    {
        lua_pushboolean(L, 0);
        return 1;
    }
}

static int l_cursor_use(lua_State *L)
{
    THCursor* pCursor = luaT_testuserdata<THCursor>(L);
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L, 2);
    pCursor->use(pCanvas);
    return 0;
}

static int l_cursor_position(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L, 1, lua_upvalueindex(1));
    THCursor::setPosition(pCanvas, luaL_checkint(L, 2), luaL_checkint(L, 3));
    return 0;
}

static int l_surface_new(lua_State *L)
{
    lua_remove(L, 1); // Value inserted by __call

    THRenderTargetCreationParams oParams;
    oParams.iWidth = luaL_checkint(L, 1);
    oParams.iHeight = luaL_checkint(L, 2);
    int iArg = 3;
    if(lua_type(L, iArg) == LUA_TNUMBER)
        oParams.iBPP = luaL_checkint(L, iArg++);
    else
        oParams.iBPP = 0;
    oParams.iSDLFlags = 0;
    oParams.bHardware = false;
    oParams.bDoubleBuffered = false;
    oParams.bFullscreen = false;
    oParams.bPresentImmediate = false;
    oParams.bReuseContext = false;

#define FLAG(name, field, flag) \
    else if(stricmp(sOption, name) == 0) \
        oParams.field = true, oParams.iSDLFlags |= flag
    
    for(int iArgCount = lua_gettop(L); iArg <= iArgCount; ++iArg)
    {
        const char* sOption = luaL_checkstring(L, iArg);
        if(sOption[0] == 0)
            continue;
        FLAG("hardware"         , bHardware        , SDL_HWSURFACE );
        FLAG("doublebuf"        , bDoubleBuffered  , SDL_DOUBLEBUF );
        FLAG("fullscreen"       , bFullscreen      , SDL_FULLSCREEN);
        FLAG("present immediate", bPresentImmediate, 0             );
        FLAG("reuse context"    , bReuseContext    , 0             );
    }

#undef FLAG

    THRenderTarget* pCanvas = luaT_stdnew<THRenderTarget>(L);
    if(pCanvas->create(&oParams))
        return 1;

    lua_pushnil(L);
    lua_pushstring(L, pCanvas->getLastError());
    return 2;
}

static int l_surface_fill_black(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    lua_settop(L, 1);
    if(pCanvas->fillBlack())
        return 1;
    lua_pushnil(L);
    lua_pushstring(L, pCanvas->getLastError());
    return 2;
}

static int l_surface_start_frame(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    lua_settop(L, 1);
    if(pCanvas->startFrame())
        return 1;
    lua_pushnil(L);
    lua_pushstring(L, pCanvas->getLastError());
    return 2;
}

static int l_surface_end_frame(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    lua_settop(L, 1);
    if(pCanvas->endFrame())
        return 1;
    lua_pushnil(L);
    lua_pushstring(L, pCanvas->getLastError());
    return 2;
}

static int l_surface_nonoverlapping(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    if(lua_isnone(L, 2) || lua_toboolean(L, 2) != 0)
        pCanvas->startNonOverlapping();
    else
        pCanvas->finishNonOverlapping();
    lua_settop(L, 1);
    return 1;
}

static int l_surface_map(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    lua_pushnumber(L, (lua_Number)pCanvas->mapColour(
        (Uint8)luaL_checkinteger(L, 2),
        (Uint8)luaL_checkinteger(L, 3),
        (Uint8)luaL_checkinteger(L, 4)));
    return 1;
}

static int l_surface_rect(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    if(pCanvas->fillRect((uint32_t)luaL_checknumber(L, 2),
        luaL_checkint(L, 3), luaL_checkint(L, 4), luaL_checkint(L, 5),
        luaL_checkint(L, 6)))
    {
        lua_settop(L, 1);
        return 1;
    }
    lua_pushnil(L);
    lua_pushstring(L, pCanvas->getLastError());
    return 2;
}

static int l_surface_screenshot(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    const char *sFile = luaL_checkstring(L, 2);
    if(pCanvas->takeScreenshot(sFile))
    {
        lua_settop(L, 1);
        return 1;
    }
    lua_pushnil(L);
    lua_pushstring(L, pCanvas->getLastError());
    return 2;
}

static int l_soundarc_new(lua_State *L)
{
    THSoundArchive* pArchive = luaT_stdnew<THSoundArchive>(L, LUA_ENVIRONINDEX, true);
    return 1;
}

static int l_soundarc_load(lua_State *L)
{
    THSoundArchive* pArchive = luaT_testuserdata<THSoundArchive>(L);
    size_t iDataLen;
    const unsigned char* pData = luaT_checkfile(L, 2, &iDataLen);

    if(pArchive->loadFromTHFile(pData, iDataLen))
        lua_pushboolean(L, 1);
    else
        lua_pushboolean(L, 0);
    return 1;
}

static int l_soundarc_count(lua_State *L)
{
    THSoundArchive* pArchive = luaT_testuserdata<THSoundArchive>(L);
    lua_pushnumber(L, (lua_Number)pArchive->getSoundCount());
    return 1;
}

static size_t l_soundarc_checkidx(lua_State *L, int iArg, THSoundArchive* pArchive)
{
    if(lua_isnumber(L, iArg))
    {
        size_t iIndex = (size_t)lua_tonumber(L, iArg);
        if(iIndex >= pArchive->getSoundCount())
        {
            lua_pushnil(L);
            lua_pushfstring(L, "Sound index out of "
                "bounds (%f is not in range [0, %d])", lua_tonumber(L, iArg),
                static_cast<int>(pArchive->getSoundCount()) - 1);
            return pArchive->getSoundCount();
        }
        return iIndex;
    }
    const char* sName = luaL_checkstring(L, iArg);
    lua_getfenv(L, 1);
    lua_pushvalue(L, iArg);
    lua_rawget(L, -2);
    if(lua_type(L, -1) == LUA_TLIGHTUSERDATA)
    {
        size_t iIndex = (size_t)lua_topointer(L, -1);
        lua_pop(L, 2);
        return iIndex;
    }
    lua_pop(L, 2);
    size_t iCount = pArchive->getSoundCount();
    for(size_t i = 0; i < iCount; ++i)
    {
        if(stricmp(sName, pArchive->getSoundFilename(i)) == 0)
        {
            lua_getfenv(L, 1);
            lua_pushvalue(L, iArg);
            lua_pushlightuserdata(L, (void*)i);
            lua_settable(L, -3);
            lua_pop(L, 1);
            return i;
        }
    }
    lua_pushnil(L);
    lua_pushliteral(L, "File not found in sound archive: ");
    lua_pushvalue(L, iArg);
    lua_concat(L, 2);
    return pArchive->getSoundCount();
}

static int l_soundarc_filename(lua_State *L)
{
    THSoundArchive* pArchive = luaT_testuserdata<THSoundArchive>(L);
    size_t iIndex = l_soundarc_checkidx(L, 2, pArchive);
    if(iIndex == pArchive->getSoundCount())
        return 2;
    lua_pushstring(L, pArchive->getSoundFilename(iIndex));
    return 1;
}

static int l_soundarc_duration(lua_State *L)
{
    THSoundArchive* pArchive = luaT_testuserdata<THSoundArchive>(L);
    size_t iIndex = l_soundarc_checkidx(L, 2, pArchive);
    if(iIndex == pArchive->getSoundCount())
        return 2;
    size_t iDuration = pArchive->getSoundDuration(iIndex);
    lua_pushnumber(L, static_cast<lua_Number>(iDuration) / static_cast<lua_Number>(1000));
    return 1;
}

static int l_soundarc_filedata(lua_State *L)
{
    THSoundArchive* pArchive = luaT_testuserdata<THSoundArchive>(L);
    size_t iIndex = l_soundarc_checkidx(L, 2, pArchive);
    if(iIndex == pArchive->getSoundCount())
        return 2;
    SDL_RWops *pRWops = pArchive->loadSound(iIndex);
    if(!pRWops)
        return 0;
    int iLength = SDL_RWseek(pRWops, 0, SEEK_END);
    SDL_RWseek(pRWops, 0, SEEK_SET);
    // There is a potential leak of pRWops if either of these Lua calls cause
    // a memory error, but it isn't very likely, and this a debugging function
    // anyway, so it isn't very important.
    void *pBuffer = lua_newuserdata(L, iLength);
    lua_pushlstring(L, (const char*)pBuffer,
        SDL_RWread(pRWops, pBuffer, 1, iLength));
    SDL_RWclose(pRWops);
    return 1;
}

static int l_soundfx_new(lua_State *L)
{
    THSoundEffects* pEffects = luaT_stdnew<THSoundEffects>(L, LUA_ENVIRONINDEX, true);
    return 1;
}

static int l_soundfx_set_archive(lua_State *L)
{
    THSoundEffects *pEffects = luaT_testuserdata<THSoundEffects>(L);
    THSoundArchive *pArchive = luaT_testuserdata<THSoundArchive>(L, 2);
    pEffects->setSoundArchive(pArchive);
    lua_settop(L, 2);
    luaT_setenvfield(L, 1, "archive");
    return 1;
}

static int l_soundfx_set_sound_volume(lua_State *L)
{
	THSoundEffects *pEffects = luaT_testuserdata<THSoundEffects>(L);
	pEffects->setSoundEffectsVolume(luaL_checknumber(L, 2));
	return 1;
}

static int l_soundfx_set_sound_effects_on(lua_State *L)
{
	THSoundEffects *pEffects = luaT_testuserdata<THSoundEffects>(L);
	pEffects->setSoundEffectsOn(lua_toboolean(L, 2));
	return 1;
}

static int l_soundfx_play(lua_State *L)
{
    THSoundEffects *pEffects = luaT_testuserdata<THSoundEffects>(L);
    lua_settop(L, 5);
    lua_getfenv(L, 1);
    lua_pushliteral(L, "archive");
    lua_rawget(L, 6);
    THSoundArchive *pArchive = (THSoundArchive*)lua_touserdata(L, 7);
    if(pArchive == NULL)
    {
        return 0;
    }
    // l_soundarc_checkidx requires the archive at the bottom of the stack
    lua_replace(L, 1);
    size_t iIndex = l_soundarc_checkidx(L, 2, pArchive);
    if(iIndex == pArchive->getSoundCount())
        return 2;
    if(lua_isnil(L, 4))
    {
        pEffects->playSound(iIndex, luaL_checknumber(L, 3));
    }
    else
    {
        pEffects->playSoundAt(iIndex, luaL_checknumber(L, 3), luaL_checkint(L, 4), luaL_checkint(L, 5));
    }
    lua_pushboolean(L, 1);
    return 1;
}

static int l_soundfx_set_camera(lua_State *L)
{
    THSoundEffects *pEffects = luaT_testuserdata<THSoundEffects>(L);
    pEffects->setCamera(luaL_checkint(L, 2), luaL_checkint(L, 3), luaL_checkint(L, 4));
    return 0;
}

static int l_load_strings(lua_State *L)
{
    size_t iDataLength;
    const unsigned char* pData = luaT_checkfile(L, 1, &iDataLength);

    THStringList oStrings;
    if(!oStrings.loadFromTHFile(pData, iDataLength))
    {
        lua_pushboolean(L, 0);
        return 1;
    }

    lua_settop(L, 0);
    lua_createtable(L, (int)oStrings.getSectionCount(), 0);
    for(unsigned int iSec = 0; iSec < oStrings.getSectionCount(); ++iSec)
    {
        unsigned int iCount = oStrings.getSectionSize(iSec);
        lua_createtable(L, (int)iCount, 0);
        for(unsigned int iStr = 0; iStr < iCount; ++iStr)
        {
            lua_pushstring(L, oStrings.getString(iSec, iStr));
            lua_rawseti(L, 2, (int)(iStr + 1));
        }
        lua_rawseti(L, 1, (int)(iSec + 1));
    }
    return 1;
}

template <typename T>
static int l_persist_loaderfn(lua_State *L)
{
    // Nothing to do - the loader function will have been persisted
    // automatically when the environment table was persisted.
    return 0;
}

template <typename T>
static int l_depersist_loaderfn(lua_State *L)
{
    if(lua_gettop(L) == 2)
    {
        // First pass - make the userdata valid
        T *pUserdata = luaT_testuserdata<T>(L);
        new (pUserdata) T; // Call the default constructor
        lua_pushboolean(L, 1);
        return 1;
    }
    else
    {
        // Second pass - make the userdata correct
        lua_getfenv(L, 1);
        lua_getfield(L, -1, "depersist");
        if(!lua_isnil(L, -1))
        {
            lua_pushvalue(L, 1);
            lua_call(L, 1, 0);
        }
        return 0;
    }
}

static int get_api_version()
{
#include "../Lua/api_version.lua"
}

static int l_get_compile_options(lua_State *L)
{
    lua_settop(L, 0);
    lua_newtable(L);

#ifdef CORSIX_TH_64BIT
    lua_pushboolean(L, 1);
#else
    lua_pushboolean(L, 0);
#endif
    lua_setfield(L, -2, "arch_64");

#if defined(CORSIX_TH_USE_OGL_RENDERER)
    lua_pushliteral(L, "OpenGL");
#elif defined(CORSIX_TH_USE_DX9_RENDERER)
    lua_pushliteral(L, "DirectX 9");
#elif defined(CORSIX_TH_USE_SDL_RENDERER)
    lua_pushliteral(L, "SDL");
#else
    lua_pushliteral(L, "Unknown");
#endif
    lua_setfield(L, -2, "renderer");

#ifdef CORSIX_TH_USE_SDL_MIXER
    lua_pushboolean(L, 1);
#else
    lua_pushboolean(L, 0);
#endif
    lua_setfield(L, -2, "audio");

    lua_getfield(L, LUA_REGISTRYINDEX, "_LOADED");
    lua_getfield(L, -1, "jit");
    if(lua_type(L, -1) == LUA_TNIL)
    {
        lua_replace(L, -2);
    }
    else
    {
        lua_getfield(L, -1, "version");
        lua_replace(L, -3);
        lua_pop(L, 1);
    }
    lua_setfield(L, -2, "jit");

    lua_pushinteger(L, get_api_version());
    lua_setfield(L, -2, "api_version");

    return 1;
}

static void luaT_setclosure(lua_State *L, lua_CFunction fn, int iUpIndex1, ...)
{
    int iUpCount = 0;
    va_list args;
    va_start(args, iUpIndex1);
    for(; iUpIndex1 != 0; iUpIndex1 = va_arg(args, int), ++iUpCount)
        lua_pushvalue(L, iUpIndex1);
    va_end(args);
    lua_pushcclosure(L, fn, iUpCount);
}

int luaopen_th(lua_State *L)
{
    lua_settop(L, 0);

    // Create metatables
    const int iMapMT     = 1; lua_createtable(L, 0, 4);
    const int iPaletteMT = 2; lua_createtable(L, 0, 4);
    const int iSheetMT   = 3; lua_createtable(L, 0, 5);
    const int iFontMT    = 4; lua_createtable(L, 0, 4);
    const int iLayersMT  = 5; lua_createtable(L, 0, 5);
    const int iAnimsMT   = 6; lua_createtable(L, 0, 4);
    const int iAnimMT    = 7; lua_createtable(L, 0, 4);
    const int iPathMT    = 8; lua_createtable(L, 0, 4);
    const int iSurfaceMT = 9; lua_createtable(L, 0, 2);
    const int iBitmapMT  =10; lua_createtable(L, 0, 4);
    const int iCursorMT  =11; lua_createtable(L, 0, 4);
    const int iSoundArcMT=12; lua_createtable(L, 0, 3);
    const int iSoundFxMT =13; lua_createtable(L, 0, 2);

    const int iTH        =14; lua_createtable(L, 0,13);
    const int iTop = iTH;

    lua_checkstack(L, 10);

#define luaT_class(typnam, new_fn, name, mt_idx) { \
    const char * sCurrentClassName = name; \
    int iCurrentClassMT = mt_idx; \
    lua_settop(L, iTop); \
    /* Make metatable the environment for registered functions */ \
    lua_pushvalue(L, mt_idx); \
    lua_replace(L, LUA_ENVIRONINDEX); \
    /* Set the __gc metamethod to C++ destructor */ \
    lua_pushcclosure(L, luaT_stdgc<typnam, LUA_ENVIRONINDEX>, 0); \
    lua_setfield(L, mt_idx, "__gc"); \
    /* Set the depersist size */ \
    lua_pushinteger(L, sizeof(typnam)); \
    lua_setfield(L, mt_idx, "__depersist_size"); \
    /* Create the methods table; call it -> new instance */ \
    luaT_pushcclosuretable(L, new_fn, 0); \
    /* Set __index to the methods table */ \
    lua_pushvalue(L, -1); \
    lua_setfield(L, mt_idx, "__index")

#define luaT_endclass() \
    lua_setfield(L, iTH, sCurrentClassName); }

#define luaT_setmetamethod(fn, name, ...) \
    luaT_setclosure(L, fn, ## __VA_ARGS__, 0); \
    lua_setfield(L, iCurrentClassMT, "__" name)

#define luaT_setfunction(fn, name, ...) \
    luaT_setclosure(L, fn, ## __VA_ARGS__, 0); \
    lua_setfield(L, -2, name)

    // Misc
    lua_settop(L, iTop);
    luaT_setfunction(l_load_strings, "LoadStrings");
    luaT_setfunction(l_get_compile_options, "GetCompileOptions");

    // Map
    luaT_class(THMap, l_map_new, "map", iMapMT);
    luaT_setmetamethod(l_map_persist, "persist", iAnimMT);
    luaT_setmetamethod(l_map_depersist, "depersist", iAnimMT);
    luaT_setfunction(l_map_load, "load");
    luaT_setfunction(l_map_getsize, "size");
    luaT_setfunction(l_map_getcell, "getCell");
    luaT_setfunction(l_map_getcellflags, "getCellFlags");
    luaT_setfunction(l_map_setcellflags, "setCellFlags");
    luaT_setfunction(l_map_setcell, "setCell");
    luaT_setfunction(l_map_setwallflags, "setWallDrawFlags");
    luaT_setfunction(l_map_updateblueprint, "updateRoomBlueprint", iAnimsMT, iAnimMT);
    luaT_setfunction(l_map_updateshadows, "updateShadows");
    luaT_setfunction(l_map_mark_room, "markRoom");
    luaT_setfunction(l_map_unmark_room, "unmarkRoom");
    luaT_setfunction(l_map_set_sheet, "setSheet", iSheetMT);
    luaT_setfunction(l_map_draw, "draw", iSurfaceMT);
    luaT_setfunction(l_map_hittest, "hitTestObjects", iAnimMT);
    luaT_endclass();

    // Palette
    luaT_class(THPalette, l_palette_new, "palette", iPaletteMT);
    luaT_setmetamethod(l_persist_loaderfn<THPalette>, "persist");
    luaT_setmetamethod(l_depersist_loaderfn<THPalette>, "depersist");
    luaT_setfunction(l_palette_load, "load");
    luaT_setfunction(l_palette_set_entry, "setEntry");
    luaT_endclass();

    // Raw bitmap
    luaT_class(THRawBitmap, l_rawbitmap_new, "bitmap", iBitmapMT);
    luaT_setmetamethod(l_persist_loaderfn<THRawBitmap>, "persist");
    luaT_setmetamethod(l_depersist_loaderfn<THRawBitmap>, "depersist");
    luaT_setfunction(l_rawbitmap_load, "load", iSurfaceMT);
    luaT_setfunction(l_rawbitmap_set_pal, "setPalette", iPaletteMT);
    luaT_setfunction(l_rawbitmap_draw, "draw", iSurfaceMT);
    luaT_endclass();

    // Sprite sheet
    luaT_class(THSpriteSheet, l_spritesheet_new, "sheet", iSheetMT);
    luaT_setmetamethod(l_spritesheet_count, "len");
    luaT_setmetamethod(l_persist_loaderfn<THSpriteSheet>, "persist");
    luaT_setmetamethod(l_depersist_loaderfn<THSpriteSheet>, "depersist");
    luaT_setfunction(l_spritesheet_load, "load", iSurfaceMT);
    luaT_setfunction(l_spritesheet_set_pal, "setPalette", iPaletteMT);
    luaT_setfunction(l_spritesheet_size, "size");
    luaT_setfunction(l_spritesheet_draw, "draw", iSurfaceMT);
    luaT_setfunction(l_spritesheet_hittest, "hitTest");
    luaT_endclass();

    // Font
    luaT_class(THFont, l_font_new, "font", iFontMT);
    luaT_setmetamethod(l_persist_loaderfn<THFont>, "persist");
    luaT_setmetamethod(l_depersist_loaderfn<THFont>, "depersist");
    luaT_setfunction(l_font_get_size, "sizeOf");
    luaT_setfunction(l_font_set_spritesheet, "setSheet", iSheetMT);
    luaT_setfunction(l_font_set_sep, "setSeparation");
    luaT_setfunction(l_font_draw, "draw", iSurfaceMT);
    luaT_setfunction(l_font_draw_wrapped, "drawWrapped", iSurfaceMT);
    luaT_endclass();

    // Layers
    luaT_class(THLayers_t, l_layers_new, "layers", iLayersMT);
    luaT_setmetamethod(l_layers_get, "index");
    luaT_setmetamethod(l_layers_set, "newindex");
    luaT_setmetamethod(l_layers_persist, "persist");
    luaT_setmetamethod(l_layers_depersist, "depersist");
    luaT_endclass();

    // Anims
    luaT_class(THAnimationManager, l_anims_new, "anims", iAnimsMT);
    luaT_setmetamethod(l_persist_loaderfn<THAnimationManager>, "persist");
    luaT_setmetamethod(l_depersist_loaderfn<THAnimationManager>, "depersist");
    luaT_setfunction(l_anims_load, "load");
    luaT_setfunction(l_anims_set_spritesheet, "setSheet", iSheetMT);
    luaT_setfunction(l_anims_getfirst, "getFirstFrame");
    luaT_setfunction(l_anims_getnext, "getNextFrame");
    luaT_setfunction(l_anims_set_alt_pal, "setAnimationGhostPalette");
    luaT_setfunction(l_anims_set_marker, "setFrameMarker");
    luaT_setfunction(l_anims_set_secondary_marker, "setFrameSecondaryMarker");
    luaT_setfunction(l_anims_draw, "draw", iSurfaceMT, iLayersMT);
    luaT_endclass();

    // Weak table at AnimMetatable[1] for light UD -> object lookup
    // For hitTest / setHitTestResult
    lua_newtable(L);
    lua_createtable(L, 0, 1);
    lua_pushliteral(L, "v");
    lua_setfield(L, -2, "__mode");
    lua_setmetatable(L, -2);
    lua_rawseti(L, iAnimMT, 1);

    // Weak table at AnimMetatable[2] for light UD -> full UD lookup
    // For persisting Map
    lua_newtable(L);
    lua_createtable(L, 0, 1);
    lua_pushliteral(L, "v");
    lua_setfield(L, -2, "__mode");
    lua_setmetatable(L, -2);
    lua_rawseti(L, iAnimMT, 2);

    // Anim
    luaT_class(THAnimation, l_anim_new, "animation", iAnimMT);
    luaT_setmetamethod(l_anim_persist, "persist");
    luaT_setmetamethod(l_anim_depersist, "depersist");
    luaT_setfunction(l_anim_set_anim, "setAnimation", iAnimsMT);
    luaT_setfunction(l_anim_set_morph, "setMorph");
    luaT_setfunction(l_anim_set_frame, "setFrame");
    luaT_setfunction(l_anim_get_anim, "getAnimation");
    luaT_setfunction(l_anim_set_tile, "setTile", iMapMT);
    luaT_setfunction(l_anim_get_tile, "getTile");
    luaT_setfunction(l_anim_set_parent, "setParent");
    luaT_setfunction(l_anim_set_flag, "setFlag");
    luaT_setfunction(l_anim_set_flag_partial, "setPartialFlag");
    luaT_setfunction(l_anim_get_flag, "getFlag");
    luaT_setfunction(l_anim_make_visible, "makeVisible");
    luaT_setfunction(l_anim_make_invisible, "makeInvisible");
    luaT_setfunction(l_anim_set_tag, "setTag");
    luaT_setfunction(l_anim_get_tag, "getTag");
    luaT_setfunction(l_anim_set_position, "setPosition");
    luaT_setfunction(l_anim_get_position, "getPosition");
    luaT_setfunction(l_anim_set_speed, "setSpeed");
    luaT_setfunction(l_anim_set_layer, "setLayer");
    luaT_setfunction(l_anim_set_hitresult, "setHitTestResult");
    luaT_setfunction(l_anim_get_marker, "getMarker");
    luaT_setfunction(l_anim_get_secondary_marker, "getSecondaryMarker");
    luaT_setfunction(l_anim_tick, "tick");
    luaT_setfunction(l_anim_draw, "draw", iSurfaceMT);
    luaT_endclass();

    // Path
    luaT_class(THPathfinder, l_path_new, "pathfinder", iPathMT);
    luaT_setmetamethod(l_path_persist, "persist");
    luaT_setmetamethod(l_path_depersist, "depersist");
    luaT_setfunction(l_path_distance, "findDistance");
    luaT_setfunction(l_path_is_reachable_from_hospital, "isReachableFromHospital");
    luaT_setfunction(l_path_path, "findPath");
    luaT_setfunction(l_path_idle, "findIdleTile");
    luaT_setfunction(l_path_visit, "findObject");
    luaT_setfunction(l_path_set_map, "setMap", iMapMT);
    luaT_endclass();

    // Cursor
    luaT_class(THCursor, l_cursor_new, "cursor", iCursorMT);
    luaT_setmetamethod(l_persist_loaderfn<THCursor>, "persist");
    luaT_setmetamethod(l_depersist_loaderfn<THCursor>, "depersist");
    luaT_setfunction(l_cursor_load, "load", iSheetMT);
    luaT_setfunction(l_cursor_use, "use", iSurfaceMT);
    luaT_setfunction(l_cursor_position, "setPosition", iSurfaceMT);
    luaT_endclass();

    // Surface
    luaT_class(THRenderTarget, l_surface_new, "surface", iSurfaceMT);
    luaT_setfunction(l_surface_fill_black, "fillBlack");
    luaT_setfunction(l_surface_start_frame, "startFrame");
    luaT_setfunction(l_surface_end_frame, "endFrame");
    luaT_setfunction(l_surface_nonoverlapping, "nonOverlapping");
    luaT_setfunction(l_surface_map, "mapRGB");
    luaT_setfunction(l_surface_rect, "drawRect");
    luaT_setfunction(l_surface_screenshot, "takeScreenshot");
    luaT_endclass();

    // Sound Archive
    luaT_class(THSoundArchive, l_soundarc_new, "soundArchive", iSoundArcMT);
    luaT_setmetamethod(l_soundarc_count, "len");
    luaT_setfunction(l_soundarc_load, "load");
    luaT_setfunction(l_soundarc_filename, "getFilename");
    luaT_setfunction(l_soundarc_duration, "getDuration");
    luaT_setfunction(l_soundarc_filedata, "getFileData");
    luaT_endclass();

    // Sound Effects
    luaT_class(THSoundEffects, l_soundfx_new, "soundEffects", iSoundFxMT);
    luaT_setfunction(l_soundfx_set_archive, "setSoundArchive", iSoundArcMT);
    luaT_setfunction(l_soundfx_play, "play");
	luaT_setfunction(l_soundfx_set_sound_volume, "setSoundVolume");
	luaT_setfunction(l_soundfx_set_sound_effects_on, "setSoundEffectsOn");
    luaT_setfunction(l_soundfx_set_camera, "setCamera");
    luaT_endclass();

#undef luaT_class
#undef luaT_endclass
#undef luaT_setmetamethod
#undef luaT_setfunction

    lua_settop(L, iTH);
    return 1;
}
