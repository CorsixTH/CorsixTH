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

static uint8_t Clamp8(uint16_t iVal)
{
    return (iVal > 255) ? 255 : static_cast<uint8_t>(iVal);
}

static int l_town_map_draw(lua_State *L)
{
    luaL_checktype(L, 1, LUA_TTABLE);
    THMap *pMap = luaT_testuserdata<THMap>(L, 2);
    THRenderTarget *pCanvas = luaT_testuserdata<THRenderTarget>(L, 3);
    int iCanvasXBase = static_cast<int>(luaL_checkinteger(L, 4));
    int iCanvasYBase = static_cast<int>(luaL_checkinteger(L, 5));
    bool bShowHeat = lua_toboolean(L, 6) != 0;

    uint32_t iColourMyHosp = pCanvas->mapColour(0, 0, 70);
    uint32_t iColourWall = pCanvas->mapColour(255, 255, 255);
    uint32_t iColourDoor = pCanvas->mapColour(200, 200, 200);
    uint32_t iColourPurchasable = pCanvas->mapColour(255, 0, 0);

    const THMapNode *pNode = pMap->getNodeUnchecked(0, 0);
    const THMapNode *pOriginalNode = pMap->getOriginalNodeUnchecked(0, 0);
    int iCanvasY = iCanvasYBase + 3;
    int iMapWidth = pMap->getWidth();
    for(int iY = 0; iY < pMap->getHeight(); ++iY, iCanvasY += 3)
    {
        int iCanvasX = iCanvasXBase;
        for(int iX = 0; iX < iMapWidth; ++iX, ++pNode, ++pOriginalNode, iCanvasX += 3)
        {
            if(pOriginalNode->iFlags & THMN_Hospital)
            {
                uint32_t iColour = iColourMyHosp;
                if(!(pNode->iFlags & THMN_Hospital))
                {
                    // TODO: Replace 1 with player number
                    if(pMap->isParcelPurchasable(pNode->iParcelId, 1))
                        iColour = iColourPurchasable;
                    else
                        goto dont_paint_tile;
                }
                else if(bShowHeat)
                {
                    uint16_t iTemp = pMap->getNodeTemperature(pNode);
                    if(iTemp < 5200) // Less than 4 degrees
                        iTemp = 0;
                    else if(iTemp > 32767) // More than 25 degrees
                        iTemp = 255;
                    else // NB: 108 == (32767 - 5200) / 255
                        iTemp = static_cast<uint16_t>((iTemp - 5200) / 108);

#define MIN_OK_TEMP 140
#define MAX_OK_TEMP 180
#define RangeScale(low, high, val, start, end) \
    Clamp8(static_cast<uint16_t>(start + (end - start) * (val - low) / (high - low)))
                    switch(pMap->getTemperatureDisplay())
                    {
                    case THMT_MultiColour:
                    {
                        uint8_t iR = 0;
                        uint8_t iG = 0;
                        uint8_t iB = 70;
                        if(iTemp < MIN_OK_TEMP)
                            iB = RangeScale(0, MIN_OK_TEMP - 1, iTemp, 200, 60);
                        else if(iTemp < MAX_OK_TEMP)
                            iG = RangeScale(MIN_OK_TEMP, MAX_OK_TEMP - 1, iTemp, 140, 224);
                        else
                            iR = RangeScale(MAX_OK_TEMP, 255, iTemp, 224, 255);
                        iColour = pCanvas->mapColour(iR, iG, iB);
                        break;
                    }
                    case THMT_YellowRed:
                        if(iTemp < MIN_OK_TEMP) // Below 11 degrees
                        {
                            uint8_t iR = RangeScale(0, MIN_OK_TEMP - 1, iTemp, 100, 213);
                            uint8_t iG = RangeScale(0, MIN_OK_TEMP - 1, iTemp, 80, 180);
                            iColour = pCanvas->mapColour(iR, iG, 0);
                        }
                        else
                        {
                            uint8_t iR = RangeScale(MIN_OK_TEMP, 255, iTemp, 223, 235);
                            uint8_t iG = RangeScale(MIN_OK_TEMP, 255, iTemp, 184, 104);
                            uint8_t iB = RangeScale(MIN_OK_TEMP, 255, iTemp, 0, 53);
                            iColour = pCanvas->mapColour(iR, iG, iB);
                        }
                        break;
                    default:
                    case THMT_Red:
                        iColour = pCanvas->mapColour(static_cast<uint8_t>(iTemp), 0, 70);
                        break;
                    }
#undef RangeScale
                }
                pCanvas->fillRect(iColour, iCanvasX, iCanvasY, 3, 3);
            }
            dont_paint_tile:
#define IsWall(blk) ((82 <= ((blk) & 0xFF)) && (((blk) & 0xFF) <= 164))
#define IsWallDrawn(n) pMap->getNodeOwner(pNode) != 0 ? \
    IsWall(pNode->iBlock[n]) : IsWall(pOriginalNode->iBlock[n])
            if(IsWallDrawn(1)) {
                pCanvas->fillRect(iColourWall, iCanvasX, iCanvasY, 3, 1);

                // Draw entrance door
                if((pNode-1)->iFlags >> 24 == THOB_EntranceRightDoor) {
                    if (pNode->iFlags & THMN_Hospital) {
                        pCanvas->fillRect(iColourDoor, iCanvasX-6, iCanvasY-2, 9, 3);
                    } else {
                        pCanvas->fillRect(iColourDoor, iCanvasX-6, iCanvasY, 9, 3);
                    }
                }
            }
            if(IsWallDrawn(2)) {
                pCanvas->fillRect(iColourWall, iCanvasX, iCanvasY, 1, 3);

                // Draw entrance door
                if((pNode-iMapWidth)->iFlags >> 24 == THOB_EntranceRightDoor) {
                    if (pNode->iFlags & THMN_Hospital) {
                        pCanvas->fillRect(iColourDoor, iCanvasX-2, iCanvasY-6, 3, 9);
                    } else {
                        pCanvas->fillRect(iColourDoor, iCanvasX, iCanvasY-6, 3, 9);
                    }
                }
            }
#undef IsWallDrawn
#undef IsWall
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
