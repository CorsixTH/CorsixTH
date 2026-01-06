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

#include "config.h"

#include <algorithm>
#include <list>

#include "lua.hpp"
#include "th_gfx_sdl.h"
#include "th_lua.h"
#include "th_lua_internal.h"
#include "th_map.h"

class abstract_window {};

namespace {

int l_abstract_window_new(lua_State* L) {
  return luaL_error(L,
                    "windowBase can only be used a base class - "
                    " do not create a windowBase directly.");
}

//! Scale val in [low, high] to [start, end]
uint8_t range_scale(uint16_t low, uint16_t high, uint16_t val, uint16_t start,
                    uint16_t end) {
  return static_cast<uint8_t>(
      std::clamp(start + (end - start) * (val - low) / (high - low), 0, 0xFF));
}

inline bool is_wall(uint16_t blk) {
  return 82 <= (blk & 0xFF) && (blk & 0xFF) <= 164;
}

inline bool is_wall_drawn(const level_map& map, const map_tile& node,
                          const map_tile& original_node, tile_layer n) {
  return map.get_tile_owner(&node) != 0 ? is_wall(node.tile_layers[n])
                                        : is_wall(original_node.tile_layers[n]);
}

int l_town_map_draw(lua_State* L) {
  luaL_checktype(L, 1, LUA_TTABLE);
  level_map* pMap = luaT_testuserdata<level_map>(L, 2);
  render_target* pCanvas = luaT_testuserdata<render_target>(L, 3);
  int iCanvasXBase = static_cast<int>(luaL_checkinteger(L, 4));
  int iCanvasYBase = static_cast<int>(luaL_checkinteger(L, 5));
  bool bShowHeat = lua_toboolean(L, 6) != 0;
  int scale = static_cast<int>(luaL_optinteger(L, 7, 1));

  uint32_t iColourMyHosp = render_target::map_colour(0, 0, 70);
  uint32_t iColourWall = render_target::map_colour(255, 255, 255);
  uint32_t iColourDoor = render_target::map_colour(200, 200, 200);
  uint32_t iColourPurchasable = render_target::map_colour(255, 0, 0);

  const map_tile* pNode = pMap->get_tile_unchecked(0, 0);
  const map_tile* pOriginalNode = pMap->get_original_tile_unchecked(0, 0);
  int iCanvasY = iCanvasYBase + 3 * scale;
  int iMapWidth = pMap->get_width();
  for (int iY = 0; iY < pMap->get_height(); ++iY, iCanvasY += 3 * scale) {
    int iCanvasX = iCanvasXBase;
    for (int iX = 0; iX < iMapWidth;
         ++iX, ++pNode, ++pOriginalNode, iCanvasX += 3 * scale) {
      if (pOriginalNode->flags.hospital) {
        uint32_t iColour = iColourMyHosp;
        if (!(pNode->flags.hospital)) {
          // TODO: Replace 1 with player number
          if (pMap->is_parcel_purchasable(pNode->iParcelId, 1))
            iColour = iColourPurchasable;
          else
            goto dont_paint_tile;
        } else if (bShowHeat) {
          uint16_t iTemp = pMap->get_tile_temperature(pNode);
          if (iTemp < 5200)  // Less than 4 degrees
            iTemp = 0;
          else if (iTemp > 32767)  // More than 25 degrees
            iTemp = 255;
          else  // NB: 108 == (32767 - 5200) / 255
            iTemp = static_cast<uint16_t>((iTemp - 5200) / 108);

          const uint16_t minOkTemp = 140;
          const uint16_t maxOkTemp = 180;

          uint8_t iR = 0;
          uint8_t iG = 0;
          uint8_t iB = 0;
          switch (pMap->get_temperature_display()) {
            case temperature_theme::multi_colour:
              iB = 70;
              if (iTemp < minOkTemp) {
                iB = range_scale(0, minOkTemp - 1, iTemp, 200, 60);
              } else if (iTemp < maxOkTemp) {
                iG = range_scale(minOkTemp, maxOkTemp - 1, iTemp, 140, 224);
              } else {
                iR = range_scale(maxOkTemp, 255, iTemp, 224, 255);
              }
              break;
            case temperature_theme::yellow_red:
              if (iTemp < minOkTemp) {  // Below 11 degrees
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

          iColour = render_target::map_colour(iR, iG, iB);
        }
        pCanvas->fill_rect(iColour, iCanvasX, iCanvasY, 3 * scale, 3 * scale);
      }
    dont_paint_tile:
      if (is_wall_drawn(*pMap, *pNode, *pOriginalNode,
                        tile_layer::north_wall)) {
        pCanvas->fill_rect(iColourWall, iCanvasX, iCanvasY, 3 * scale, scale);

        // Draw entrance door
        auto l = (pNode - 1)->objects;
        if (!l.empty() && l.front() == object_type::entrance_right_door) {
          if (pNode->flags.hospital) {
            pCanvas->fill_rect(iColourDoor, iCanvasX - 6 * scale,
                               iCanvasY - 2 * scale, 9 * scale, 3 * scale);
          } else {
            pCanvas->fill_rect(iColourDoor, iCanvasX - 6 * scale, iCanvasY,
                               9 * scale, 3 * scale);
          }
        }
      }
      if (is_wall_drawn(*pMap, *pNode, *pOriginalNode, tile_layer::west_wall)) {
        pCanvas->fill_rect(iColourWall, iCanvasX, iCanvasY, scale, 3 * scale);

        // Draw entrance door
        auto l = (pNode - iMapWidth)->objects;
        if (!l.empty() && l.front() == object_type::entrance_right_door) {
          if (pNode->flags.hospital) {
            pCanvas->fill_rect(iColourDoor, iCanvasX - 2 * scale,
                               iCanvasY - 6 * scale, 3 * scale, 9 * scale);
          } else {
            pCanvas->fill_rect(iColourDoor, iCanvasX, iCanvasY - 6 * scale,
                               3 * scale, 9 * scale);
          }
        }
      }
    }
  }

  return 0;
}

}  // namespace

void lua_register_ui(const lua_register_state* pState) {
  // WindowBase
  lua_class_binding<abstract_window> lcb(pState, "windowHelpers",
                                         l_abstract_window_new,
                                         lua_metatable::window_base);
  lcb.add_function(l_town_map_draw, "townMapDraw", lua_metatable::map,
                   lua_metatable::surface);
}
