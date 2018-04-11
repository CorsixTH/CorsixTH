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
#include <algorithm>

class abstract_window {};

static int l_abstract_window_new(lua_State *L)
{
    return luaL_error(L, "windowBase can only be used a base class - "
        " do not create a windowBase directly.");
}

static uint8_t range_scale(uint16_t low, uint16_t high, uint16_t val, uint16_t start, uint16_t end)
{
    return static_cast<uint8_t>(std::max(start + (end - start) * (val - low) / (high - low), 0xFF));
}

static int l_town_map_draw(lua_State *L)
{
    luaL_checktype(L, 1, LUA_TTABLE);
    level_map* pMap = luaT_testuserdata<level_map>(L, 2);
    render_target *pCanvas = luaT_testuserdata<render_target>(L, 3);
    int iCanvasXBase = static_cast<int>(luaL_checkinteger(L, 4));
    int iCanvasYBase = static_cast<int>(luaL_checkinteger(L, 5));
    bool bShowHeat = lua_toboolean(L, 6) != 0;

    uint32_t iColourMyHosp = pCanvas->map_colour(0, 0, 70);
    uint32_t iColourWall = pCanvas->map_colour(255, 255, 255);
    uint32_t iColourDoor = pCanvas->map_colour(200, 200, 200);
    uint32_t iColourPurchasable = pCanvas->map_colour(255, 0, 0);

    const map_tile *pNode = pMap->get_tile_unchecked(0, 0);
    const map_tile *pOriginalNode = pMap->get_original_tile_unchecked(0, 0);
    int iCanvasY = iCanvasYBase + 3;
    int iMapWidth = pMap->get_width();
    for(int iY = 0; iY < pMap->get_height(); ++iY, iCanvasY += 3)
    {
        int iCanvasX = iCanvasXBase;
        for(int iX = 0; iX < iMapWidth; ++iX, ++pNode, ++pOriginalNode, iCanvasX += 3)
        {
            if(pOriginalNode->flags.hospital)
            {
                uint32_t iColour = iColourMyHosp;
                if(!(pNode->flags.hospital))
                {
                    // TODO: Replace 1 with player number
                    if(pMap->is_parcel_purchasable(pNode->iParcelId, 1))
                        iColour = iColourPurchasable;
                    else
                        goto dont_paint_tile;
                }
                else if(bShowHeat)
                {
                    uint16_t iTemp = pMap->get_tile_temperature(pNode);
                    if(iTemp < 5200) // Less than 4 degrees
                        iTemp = 0;
                    else if(iTemp > 32767) // More than 25 degrees
                        iTemp = 255;
                    else // NB: 108 == (32767 - 5200) / 255
                        iTemp = static_cast<uint16_t>((iTemp - 5200) / 108);

                    const uint16_t minOkTemp = 140;
                    const uint16_t maxOkTemp = 180;

                    uint8_t iR = 0;
                    uint8_t iG = 0;
                    uint8_t iB = 0;
                    switch(pMap->get_temperature_display())
                    {
                    case temperature_theme::multi_colour:
                        iB = 70;
                        if(iTemp < minOkTemp) {
                            iB = range_scale(0, minOkTemp - 1, iTemp, 200, 60);
                        } else if(iTemp < maxOkTemp) {
                            iG = range_scale(minOkTemp, maxOkTemp - 1, iTemp, 140, 224);
                        } else {
                            iR = range_scale(maxOkTemp, 255, iTemp, 224, 255);
                        }
                        break;
                    case temperature_theme::yellow_red:
                        if(iTemp < minOkTemp) { // Below 11 degrees
                            iR = range_scale(0, minOkTemp - 1, iTemp, 100, 213);
                            iG = range_scale(0, minOkTemp - 1, iTemp, 80, 180);
                        } else {
                            iR = range_scale(minOkTemp, 255, iTemp, 223, 235);
                            iG = range_scale(minOkTemp, 255, iTemp, 184, 104);
                            iB = range_scale(minOkTemp, 255, iTemp, 0, 53);
                        }
                        break;
                    case temperature_theme::red:
                        iR = static_cast<uint8_t>(iTemp);
                        iB = 70;
                        break;
                    }

                    iColour = pCanvas->map_colour(iR, iG, iB);
                }
                pCanvas->fill_rect(iColour, iCanvasX, iCanvasY, 3, 3);
            }
            dont_paint_tile:
#define IsWall(blk) ((82 <= ((blk) & 0xFF)) && (((blk) & 0xFF) <= 164))
#define IsWallDrawn(n) pMap->get_tile_owner(pNode) != 0 ? \
    IsWall(pNode->iBlock[n]) : IsWall(pOriginalNode->iBlock[n])
            if(IsWallDrawn(1)) {
                pCanvas->fill_rect(iColourWall, iCanvasX, iCanvasY, 3, 1);

                // Draw entrance door
                auto l = (pNode - 1)->objects;
                if(!l.empty() && l.front() == object_type::entrance_right_door) {
                    if (pNode->flags.hospital) {
                        pCanvas->fill_rect(iColourDoor, iCanvasX-6, iCanvasY-2, 9, 3);
                    } else {
                        pCanvas->fill_rect(iColourDoor, iCanvasX-6, iCanvasY, 9, 3);
                    }
                }
            }
            if(IsWallDrawn(2)) {
                pCanvas->fill_rect(iColourWall, iCanvasX, iCanvasY, 1, 3);

                // Draw entrance door
                auto l = (pNode - iMapWidth)->objects;
                if(!l.empty() && l.front() == object_type::entrance_right_door) {
                    if (pNode->flags.hospital) {
                        pCanvas->fill_rect(iColourDoor, iCanvasX-2, iCanvasY-6, 3, 9);
                    } else {
                        pCanvas->fill_rect(iColourDoor, iCanvasX, iCanvasY-6, 3, 9);
                    }
                }
            }
#undef IsWallDrawn
#undef IsWall
        }
    }

    return 0;
}

void lua_register_ui(const lua_register_state *pState)
{
    // WindowBase
    luaT_class(abstract_window, l_abstract_window_new, "windowHelpers", lua_metatable::window_base);
    luaT_setfunction(l_town_map_draw, "townMapDraw", lua_metatable::map, lua_metatable::surface);
    luaT_endclass();
}
