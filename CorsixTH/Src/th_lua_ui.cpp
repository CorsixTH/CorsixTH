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
#include "th_gfx.h"
#include "th_map.h"

struct THWindowBase_t {};

static int l_window_base_new(lua_State *L)
{
    return luaL_error(L, "windowBase can only be used a base class - "
        " do not create a windowBase directly.");
}

static int l_town_map_draw(lua_State *L)
{
    luaL_checktype(L, 1, LUA_TTABLE);
    THMap *pMap = luaT_testuserdata<THMap>(L, 2);
    THRenderTarget *pCanvas = luaT_testuserdata<THRenderTarget>(L, 3);
    int iCanvasXBase = luaL_checkint(L, 4);
    int iCanvasYBase = luaL_checkint(L, 5);

    uint32_t iColourMyHosp = pCanvas->mapColour(0, 0, 70);
    uint32_t iColourWall = pCanvas->mapColour(255, 255, 255);
    uint32_t iColourDoor = pCanvas->mapColour(200, 200, 200);

    THMapNode *pNode = pMap->getNodeUnchecked(0, 0);
    int iCanvasY = iCanvasYBase + 3;
    for(int iY = 0; iY < pMap->getHeight(); ++iY, iCanvasY += 3)
    {
        int iCanvasX = iCanvasXBase;
        for(int iX = 0; iX < pMap->getWidth(); ++iX, ++pNode, iCanvasX += 3)
        {
            if(pNode->iFlags & THMN_Hospital)
                pCanvas->fillRect(iColourMyHosp, iCanvasX, iCanvasY, 3, 3);
            int iNorth = pNode->iBlock[1] & 0xFF;
            if(82 <= iNorth && iNorth <= 164)
                pCanvas->fillRect(iColourWall, iCanvasX, iCanvasY, 3, 1);
            int iWest = pNode->iBlock[2] & 0xFF;
            if(82 <= iWest && iWest <= 164)
                pCanvas->fillRect(iColourWall, iCanvasX, iCanvasY, 1, 3);
            if(pNode->iFlags & THMN_DoorNorth)
                pCanvas->fillRect(iColourDoor, iCanvasX, iCanvasY - 2, 2, 3);
            if(pNode->iFlags & THMN_DoorWest)
                pCanvas->fillRect(iColourDoor, iCanvasX - 3, iCanvasY, 3, 2);
        }
    }

    return 0;
}

void THLuaRegisterUI(const THLuaRegisterState_t *pState)
{
    // WindowBase
    luaT_class(THWindowBase_t, l_window_base_new, "windowHelpers", MT_WindowBase);
    luaT_setfunction(l_town_map_draw, "townMapDraw", MT_Map, MT_Surface);
    luaT_endclass();
}
