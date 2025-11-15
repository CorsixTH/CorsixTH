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

#include <new>

#include "lua.hpp"
#include "persist_lua.h"
#include "th.h"
#include "th_gfx.h"
#include "th_lua.h"
#include "th_lua_internal.h"
#include "th_map.h"

class render_target;
class sprite_sheet;
enum class animation_effect;

namespace {

int l_anims_new(lua_State* L) {
  luaT_stdnew<animation_manager>(L, luaT_environindex, true);
  return 1;
}

int l_anims_set_spritesheet(lua_State* L) {
  animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
  sprite_sheet* pSheet = luaT_testuserdata<sprite_sheet>(L, 2);
  lua_settop(L, 2);

  pAnims->set_sprite_sheet(pSheet);
  luaT_setenvfield(L, 1, "sprites");
  return 1;
}

//! Set the video target for the sprites.
/*!
 *  setCanvas(<video-surface>)
 */
int l_anims_set_canvas(lua_State* L) {
  animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
  render_target* pCanvas = luaT_testuserdata<render_target>(L, 2);
  lua_settop(L, 2);

  pAnims->set_canvas(pCanvas);
  luaT_setenvfield(L, 1, "target");
  return 1;
}

int l_anims_load(lua_State* L) {
  animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
  size_t iStartDataLength, iFrameDataLength, iListDataLength,
      iElementDataLength;
  const uint8_t* pStartData = luaT_checkfile(L, 2, &iStartDataLength);
  const uint8_t* pFrameData = luaT_checkfile(L, 3, &iFrameDataLength);
  const uint8_t* pListData = luaT_checkfile(L, 4, &iListDataLength);
  const uint8_t* pElementData = luaT_checkfile(L, 5, &iElementDataLength);

  if (pAnims->load_from_th_file(pStartData, iStartDataLength, pFrameData,
                                iFrameDataLength, pListData, iListDataLength,
                                pElementData, iElementDataLength)) {
    lua_pushboolean(L, 1);
  } else {
    lua_pushboolean(L, 0);
  }

  return 1;
}

//! Load custom animations.
/*!
 *  Anims:loadCustom(<data-of-an-animation-file>) -> true/false
 */
int l_anims_loadcustom(lua_State* L) {
  animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
  size_t iDataLength;
  const uint8_t* pData = luaT_checkfile(L, 2, &iDataLength);

  if (pAnims->load_custom_animations(pData, iDataLength)) {
    lua_pushboolean(L, 1);
  } else {
    lua_pushboolean(L, 0);
  }

  return 1;
}

//! Lua interface for getting a set of animations by name and tile size (one for
//! each view direction, 'nil' if no animation is available for a direction).
/*!
 *  Anims:getAnimations(<tile-size>, <animation-name>)
 *      -> (<anim-north>, <anim-east>, <anim-south>, <anim-west>)
 */
int l_anims_getanims(lua_State* L) {
  animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
  int iTileSize = static_cast<int>(luaL_checkinteger(L, 2));
  const char* pName = luaL_checkstring(L, 3);

  const animation_start_frames& oFrames =
      pAnims->get_named_animations(pName, iTileSize);
  if (oFrames.north < 0) {
    lua_pushnil(L);
  } else {
    lua_pushnumber(L, static_cast<double>(oFrames.north));
  }
  if (oFrames.east < 0) {
    lua_pushnil(L);
  } else {
    lua_pushnumber(L, static_cast<double>(oFrames.east));
  }
  if (oFrames.south < 0) {
    lua_pushnil(L);
  } else {
    lua_pushnumber(L, static_cast<double>(oFrames.south));
  }
  if (oFrames.west < 0) {
    lua_pushnil(L);
  } else {
    lua_pushnumber(L, static_cast<double>(oFrames.west));
  }
  return 4;
}

//! Get the first frame of an animation.
/*!
 *  Anims:getFirstFrame(<anim-number>) -> <frame-number>
 */
int l_anims_getfirst(lua_State* L) {
  animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
  int iAnim = static_cast<int>(luaL_checkinteger(L, 2));

  lua_pushinteger(L, pAnims->get_first_frame(iAnim));
  return 1;
}

//! Get the next frame of an animation.
/*!
 *  Anims:getNextFrame(<frame-number>) -> <frame-number>
 */
int l_anims_getnext(lua_State* L) {
  animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
  int iFrame = static_cast<int>(luaL_checkinteger(L, 2));

  lua_pushinteger(L, pAnims->get_next_frame(iFrame));
  return 1;
}

int l_anims_set_alt_pal(lua_State* L) {
  animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
  size_t iAnimation = luaL_checkinteger(L, 2);
  size_t iPalLen;
  const uint8_t* pPal = luaT_checkfile(L, 3, &iPalLen);
  if (iPalLen != 256) {
    return luaL_argerror(L, 3, "GhostPalette string is not a valid palette");
  }
  uint32_t iAlt32 = static_cast<uint32_t>(luaL_checkinteger(L, 4));

  pAnims->set_animation_alt_palette_map(iAnimation, pPal, iAlt32);

  lua_getfenv(L, 1);
  lua_insert(L, 2);
  lua_settop(L, 4);
  lua_settable(L, 2);
  lua_settop(L, 1);
  return 1;
}

//! Set the primary (often patient) marker of an animation.
/*!
 *  Anims:setFramePrimaryMarker(<frame-num>, <x-pos>, <y-pos>) -> Anims
 *  with x and y positions in pixels relative to tile-centre at floor level.
 */
int l_anims_set_primary_marker(lua_State* L) {
  animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
  lua_pushboolean(
      L, pAnims->set_frame_primary_marker(
             luaL_checkinteger(L, 2), static_cast<int>(luaL_checkinteger(L, 3)),
             static_cast<int>(luaL_checkinteger(L, 4)))
             ? 1
             : 0);
  return 1;
}

//! Set the secondary (often staff) marker of an animation.
/*!
 *  Anims:setFrameSecondaryMarker(<frame-num>, <x-pos>, <y-pos>) -> Anims
 *  with x and y positions in pixels relative to tile-centre at floor level.
 */
int l_anims_set_secondary_marker(lua_State* L) {
  animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
  lua_pushboolean(
      L, pAnims->set_frame_secondary_marker(
             luaL_checkinteger(L, 2), static_cast<int>(luaL_checkinteger(L, 3)),
             static_cast<int>(luaL_checkinteger(L, 4)))
             ? 1
             : 0);
  return 1;
}

//! Update the global patients effects counter for the next frame.
/*!
 * Anims:tick()
 */
int l_anims_tick(lua_State* L) {
  animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
  pAnims->tick();
  return 0;
}

int l_anims_draw(lua_State* L) {
  animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
  render_target* pCanvas = luaT_testuserdata<render_target>(L, 2);
  size_t iFrame = luaL_checkinteger(L, 3);
  layers* pLayers = luaT_testuserdata<layers>(L, 4, luaT_upvalueindex(2));
  int iX = static_cast<int>(luaL_checkinteger(L, 5));
  int iY = static_cast<int>(luaL_checkinteger(L, 6));
  int iFlags = static_cast<int>(luaL_optinteger(L, 7, 0));

  pAnims->draw_frame(pCanvas, iFrame, *pLayers, iX, iY, iFlags);

  lua_settop(L, 1);
  return 1;
}

template <typename T>
int l_anim_new(lua_State* L) {
  T* pAnimation = luaT_stdnew<T>(L, luaT_environindex, true);
  lua_rawgeti(L, luaT_environindex, 2);
  lua_pushlightuserdata(L, pAnimation);
  lua_pushvalue(L, -3);
  lua_rawset(L, -3);
  lua_pop(L, 1);
  return 1;
}

template <typename T>
int l_anim_persist(lua_State* L) {
  T* pAnimation;
  if (lua_gettop(L) == 3) {
    pAnimation = luaT_testuserdata<T>(L, 1, luaT_environindex, false);
    luaT_rotate(L, 1, -1);
  } else {
    // Fast __persist call
    pAnimation = (T*)lua_touserdata(L, -1);
  }
  lua_persist_writer* pWriter = (lua_persist_writer*)lua_touserdata(L, 1);

  pAnimation->persist(pWriter);
  lua_rawgeti(L, luaT_environindex, 1);
  lua_pushlightuserdata(L, pAnimation);
  lua_gettable(L, -2);
  pWriter->write_stack_object(-1);
  lua_pop(L, 2);
  return 0;
}

template <typename T>
int l_anim_pre_depersist(lua_State* L) {
  // Note that anims and the map have nice reference cycles between them
  // and hence we cannot be sure which is depersisted first. To ensure that
  // things work nicely, we initialise all the fields of a THAnimation as
  // soon as possible, thus preventing issues like an anim -> map -> anim
  // reference chain whereby l_anim_depersist is called after l_map_depersist
  // (as anim references map in its environment table) causing the prev
  // field to be set during map depersistence, then cleared to nullptr by the
  // constructor during l_anim_depersist.
  T* pAnimation = luaT_testuserdata<T>(L);
  new (pAnimation) T;  // Call constructor
  return 0;
}

template <typename T>
int l_anim_depersist(lua_State* L) {
  // Because anim has a pre_depersist function the userdata is already
  // initialized as a T.
  T* pAnimation = luaT_testuserdata<T>(L);
  lua_settop(L, 2);
  lua_insert(L, 1);
  lua_persist_reader* pReader = (lua_persist_reader*)lua_touserdata(L, 1);

  lua_rawgeti(L, luaT_environindex, 2);
  lua_pushlightuserdata(L, pAnimation);
  lua_pushvalue(L, 2);
  lua_settable(L, -3);
  lua_pop(L, 1);
  pAnimation->depersist(pReader);
  lua_rawgeti(L, luaT_environindex, 1);
  lua_pushlightuserdata(L, pAnimation);
  if (!pReader->read_stack_object()) return 0;
  lua_settable(L, -3);
  lua_pop(L, 1);
  return 0;
}

int l_anim_set_hitresult(lua_State* L) {
  luaL_checktype(L, 1, LUA_TUSERDATA);
  lua_settop(L, 2);
  lua_rawgeti(L, luaT_environindex, 1);
  lua_pushlightuserdata(L, lua_touserdata(L, 1));
  lua_pushvalue(L, 2);
  lua_settable(L, 3);
  lua_settop(L, 1);
  return 1;
}

//! Set the frame of an animation.
/*!
 *  Animation:setFrame(<frame number>) -> Animation
 */
int l_anim_set_frame(lua_State* L) {
  animation* pAnimation = luaT_testuserdata<animation>(L);
  pAnimation->set_frame(luaL_checkinteger(L, 2));
  lua_settop(L, 1);
  return 1;
}

//! Get the current frame of an animation.
/*!
 *  Animation:getFrame(<frame number>) -> <current-frame-num>
 */
int l_anim_get_frame(lua_State* L) {
  animation* pAnimation = luaT_testuserdata<animation>(L);
  lua_pushinteger(L, pAnimation->get_frame());
  return 1;
}

//! Set the tile column to draw.
/*!
 *  Anim:setCrop(<half-tile-offsets>) -> Anim
 *
 *  Tile column is specified as number of half-tile offsets relative to the
 *  center of the center tile of the animation. Width of the column is always a
 *  full tile.
 *  Enabling cropping is controlled by the \c thdf_crop draw flag.
 */
int l_anim_set_crop(lua_State* L) {
  animation* pAnimation = luaT_testuserdata<animation>(L);
  pAnimation->set_crop_column(static_cast<int>(luaL_checkinteger(L, 2)));
  lua_settop(L, 1);
  return 1;
}

//! Get the tile column to draw.
/*!
 *  Anim:getCrop(<half-tile-offsets>) -> <column>
 *
 *  Tile column is specified as number of half-tile offsets relative to the
 *  center of the center tile of the animation. Width of the column is always a
 *  full tile.
 *  Enabling cropping is controlled by the \c thdf_crop draw flag.
 */
int l_anim_get_crop(lua_State* L) {
  animation* pAnimation = luaT_testuserdata<animation>(L);
  lua_pushinteger(L, pAnimation->get_crop_column());
  return 1;
}

int l_anim_set_anim(lua_State* L) {
  animation* pAnimation = luaT_testuserdata<animation>(L);
  animation_manager* pManager = luaT_testuserdata<animation_manager>(L, 2);
  lua_Integer iAnim = luaL_checkinteger(L, 3);
  if (iAnim < 0 ||
      iAnim >= static_cast<lua_Integer>(pManager->get_animation_count()))
    luaL_argerror(L, 3, "Animation index out of bounds");

  if (lua_isnoneornil(L, 4)) {
    pAnimation->set_flags(0);
  } else {
    pAnimation->set_flags(static_cast<uint32_t>(luaL_checkinteger(L, 4)));
  }

  pAnimation->set_animation(pManager, static_cast<size_t>(iAnim));
  lua_settop(L, 2);
  luaT_setenvfield(L, 1, "animator");
  lua_pushnil(L);
  luaT_setenvfield(L, 1, "morph_target");

  return 1;
}

int l_anim_set_morph(lua_State* L) {
  animation* pAnimation = luaT_testuserdata<animation>(L);
  animation* pMorphTarget =
      luaT_testuserdata<animation>(L, 2, luaT_environindex);

  int iDurationFactor = 1;
  if (!lua_isnoneornil(L, 3) && luaL_checkinteger(L, 3) > 0) {
    iDurationFactor = static_cast<int>(luaL_checkinteger(L, 3));
  }

  pAnimation->set_morph_target(pMorphTarget, iDurationFactor);
  lua_settop(L, 2);
  luaT_setenvfield(L, 1, "morph_target");

  return 1;
}

//! Get the current animation.
/*!
 * Anim:getAnimation() -> <animation-number>
 */
int l_anim_get_anim(lua_State* L) {
  animation* pAnimation = luaT_testuserdata<animation>(L);
  lua_pushinteger(L, pAnimation->get_animation());

  return 1;
}

//! Set the base tile of the animation.
/*!
 * <animation/sprite-render-list>:setTile(<map>, <x>, <y>, <drawing_layer>)
 * If map is 'nil', remove the animation from the tile.
 */
template <typename T>
int l_anim_set_tile(lua_State* L) {
  T* pAnimation = luaT_testuserdata<T>(L);

  if (lua_isnoneornil(L, 2)) {
    pAnimation->remove_from_tile();
    lua_pushnil(L);
    luaT_setenvfield(L, 1, "map");
    lua_settop(L, 1);
  } else {
    level_map* pMap = luaT_testuserdata<level_map>(L, 2);
    int x = static_cast<int>(luaL_checkinteger(L, 3));
    int y = static_cast<int>(luaL_checkinteger(L, 4));
    int drawing_layer = static_cast<int>(luaL_checkinteger(L, 5));

    if (pMap->is_on_map(x - 1, y - 1)) {
      pAnimation->attach_to_map(pMap, x - 1, y - 1, drawing_layer);
    } else {
      // Off-map, report an error.
      std::string msg = "Map index out of bounds (" + std::to_string(x) + ", " +
                        std::to_string(y) + ")";
      luaL_argerror(L, 3, lua_pushfstring(L, msg.c_str()));
    }

    lua_settop(L, 2);
    luaT_setenvfield(L, 1, "map");
  }

  return 1;
}

int l_anim_get_tile(lua_State* L) {
  animation* pAnimation = luaT_testuserdata<animation>(L);
  lua_settop(L, 1);
  lua_getfenv(L, 1);
  lua_getfield(L, 2, "map");
  lua_replace(L, 2);
  if (lua_isnil(L, 2)) {
    return 0;  // No map supplied.
  }

  const xy_pair& tile = pAnimation->get_tile();
  if (tile.x >= 0 && tile.y >= 0) {
    lua_pushinteger(L, tile.x + 1);
    lua_pushinteger(L, tile.y + 1);
  } else {
    lua_pushnil(L);
    lua_pushnil(L);
  }
  return 3;  // map, x, y
}

int l_anim_set_parent(lua_State* L) {
  animation* pAnimation = luaT_testuserdata<animation>(L);
  animation* pParent =
      luaT_testuserdata<animation>(L, 2, luaT_environindex, false);
  bool use_primary = lua_isnone(L, 3);  // No number means '1'.
  if (!use_primary) {
    lua_Integer value = luaL_checkinteger(L, 3);
    if (value < 1 || value > 2)
      luaL_argerror(
          L, 3, "Marker index out of bounds (only values 1 and 2 are allowed)");
    use_primary = (value == 1);
  }
  pAnimation->set_parent(pParent, use_primary);
  lua_settop(L, 1);
  return 1;
}

template <typename T>
int l_anim_set_flag(lua_State* L) {
  T* pAnimation = luaT_testuserdata<T>(L);
  pAnimation->set_flags(static_cast<uint32_t>(luaL_checkinteger(L, 2)));

  lua_settop(L, 1);
  return 1;
}

template <typename T>
int l_anim_set_flag_partial(lua_State* L) {
  T* pAnimation = luaT_testuserdata<T>(L);
  uint32_t iFlags = static_cast<uint32_t>(luaL_checkinteger(L, 2));
  if (lua_isnone(L, 3) || lua_toboolean(L, 3)) {
    pAnimation->set_flags(pAnimation->get_flags() | iFlags);
  } else {
    pAnimation->set_flags(pAnimation->get_flags() & ~iFlags);
  }
  lua_settop(L, 1);
  return 1;
}

template <typename T>
int l_anim_make_visible(lua_State* L) {
  T* pAnimation = luaT_testuserdata<T>(L);
  pAnimation->set_flags(pAnimation->get_flags() &
                        ~static_cast<uint32_t>(thdf_alpha_50 | thdf_alpha_75));

  lua_settop(L, 1);
  return 1;
}

template <typename T>
int l_anim_make_invisible(lua_State* L) {
  T* pAnimation = luaT_testuserdata<T>(L);
  pAnimation->set_flags(pAnimation->get_flags() |
                        static_cast<uint32_t>(thdf_alpha_50 | thdf_alpha_75));

  lua_settop(L, 1);
  return 1;
}

template <typename T>
int l_anim_get_flag(lua_State* L) {
  T* pAnimation = luaT_testuserdata<T>(L);
  lua_pushinteger(L, pAnimation->get_flags());

  return 1;
}

template <typename T>
int l_anim_set_pixel_offset(lua_State* L) {
  T* pAnimation = luaT_testuserdata<T>(L);

  int x = static_cast<int>(luaL_checkinteger(L, 2));
  int y = static_cast<int>(luaL_checkinteger(L, 3));
  pAnimation->set_pixel_offset(x, y);

  lua_settop(L, 1);
  return 1;
}

int l_anim_get_pixel_offset(lua_State* L) {
  animation* pAnimation = luaT_testuserdata<animation>(L);

  const xy_pair& offset = pAnimation->get_pixel_offset();
  lua_pushinteger(L, offset.x);
  lua_pushinteger(L, offset.y);

  return 2;
}

template <typename T>
int l_anim_set_speed(lua_State* L) {
  T* pAnimation = luaT_testuserdata<T>(L);

  int x = static_cast<int>(luaL_optinteger(L, 2, 0));
  int y = static_cast<int>(luaL_optinteger(L, 3, 0));
  pAnimation->set_speed(x, y);

  lua_settop(L, 1);
  return 1;
}

template <typename T>
int l_anim_set_layer(lua_State* L) {
  T* pAnimation = luaT_testuserdata<T>(L);

  pAnimation->set_layer(static_cast<int>(luaL_checkinteger(L, 2)),
                        static_cast<int>(luaL_optinteger(L, 3, 0)));

  lua_settop(L, 1);
  return 1;
}

int l_anim_set_layers_from(lua_State* L) {
  animation* pAnimation = luaT_testuserdata<animation>(L);
  const animation* pAnimationSrc =
      luaT_testuserdata<animation>(L, 2, luaT_environindex);

  pAnimation->set_layers_from(pAnimationSrc);

  lua_settop(L, 1);
  return 1;
}

//! Add a description to an animation.
/*!
 * Anim:setTag(<string/nil>) -> Anim
 */
int l_anim_set_tag(lua_State* L) {
  luaT_testuserdata<animation>(L);
  lua_settop(L, 2);
  luaT_setenvfield(L, 1, "tag");
  return 1;
}

//! Get a description from an animation.
/*!
 * Anim:getTag() -> <string>
 */
int l_anim_get_tag(lua_State* L) {
  luaT_testuserdata<animation>(L);
  lua_settop(L, 1);
  lua_getfenv(L, 1);
  lua_getfield(L, 2, "tag");
  return 1;
}

//! Get the position of the primary marker (often for patients).
/*!
 * Anim:getPrimaryMarker() -> x, y
 */
int l_anim_get_primary_marker(lua_State* L) {
  animation* pAnimation = luaT_testuserdata<animation>(L);
  int iX = 0;
  int iY = 0;
  pAnimation->get_primary_marker(&iX, &iY);
  lua_pushinteger(L, iX);
  lua_pushinteger(L, iY);
  return 2;
}

//! Get the position of the secondary marker (often for staff).
/*!
 * Anim:getSecondaryMarker() -> x, y
 */
int l_anim_get_secondary_marker(lua_State* L) {
  animation* pAnimation = luaT_testuserdata<animation>(L);
  int iX = 0;
  int iY = 0;
  pAnimation->get_secondary_marker(&iX, &iY);
  lua_pushinteger(L, iX);
  lua_pushinteger(L, iY);
  return 2;
}

//! Advance the animation to the next frame.
/*!
 * Anim/SpriteRenderList:tick() -> Anim/SpriteRenderList
 */
template <typename T>
int l_anim_tick(lua_State* L) {
  T* pAnimation = luaT_testuserdata<T>(L);
  pAnimation->tick();
  lua_settop(L, 1);
  return 1;
}

//! Draw the animation.
/*!
 * Anim/SpriteRenderList:draw() -> Anim/SpriteRenderList
 */
template <typename T>
int l_anim_draw(lua_State* L) {
  T* pAnimation = luaT_testuserdata<T>(L);
  render_target* pCanvas = luaT_testuserdata<render_target>(L, 2);
  pAnimation->draw(pCanvas, static_cast<int>(luaL_checkinteger(L, 3)),
                   static_cast<int>(luaL_checkinteger(L, 4)));
  lua_settop(L, 1);
  return 1;
}

//! Add a proxy to an animation.
/*!
 * Anim:addProxy(<dx>, <dy>, opt-crop-column>, <opt-crop-width>)
 */
int l_anim_add_proxy(lua_State* L) {
  animation* pAnimation = luaT_testuserdata<animation>(L);
  std::int8_t dx = static_cast<std::int8_t>(luaL_checkinteger(L, 2));
  std::int8_t dy = static_cast<std::int8_t>(luaL_checkinteger(L, 3));
  if (lua_isnoneornil(L, 4) || lua_isnoneornil(L, 5)) {
    pAnimation->add_proxy(dx, dy, 0, -1);
  } else {
    std::int8_t crop_base = static_cast<std::int8_t>(luaL_checkinteger(L, 4));
    std::int8_t crop_width = static_cast<std::int8_t>(luaL_checkinteger(L, 5));
    if (crop_width <= 0) {
      return luaL_argerror(L, 5, "Crop width must be at least 1");
    }
    pAnimation->add_proxy(dx, dy, crop_base, crop_width);
  }

  lua_settop(L, 1);
  return 1;
}

//! Remove all proxies from the animation.
/*!
 * Anim:removeAllProxies() -> Anim
 */
int l_anim_remove_all_proxies(lua_State* L) {
  animation* pAnimation = luaT_testuserdata<animation>(L);
  pAnimation->remove_all_proxies();

  lua_settop(L, 1);
  return 1;
}

int l_anim_set_patient_effect(lua_State* L) {
  animation* pAnimation = luaT_testuserdata<animation>(L);
  animation_effect flags =
      static_cast<animation_effect>(luaL_checkinteger(L, 2));
  pAnimation->set_patient_effect(flags);

  lua_settop(L, 1);
  return 1;
}

int l_srl_set_sheet(lua_State* L) {
  sprite_render_list* pSrl = luaT_testuserdata<sprite_render_list>(L);
  sprite_sheet* pSheet = luaT_testuserdata<sprite_sheet>(L, 2);
  pSrl->set_sheet(pSheet);

  lua_settop(L, 2);
  luaT_setenvfield(L, 1, "sheet");
  return 1;
}

int l_srl_append(lua_State* L) {
  sprite_render_list* pSrl = luaT_testuserdata<sprite_render_list>(L);
  pSrl->append_sprite(luaL_checkinteger(L, 2),
                      static_cast<int>(luaL_checkinteger(L, 3)),
                      static_cast<int>(luaL_checkinteger(L, 4)));
  lua_settop(L, 1);
  return 1;
}

int l_srl_set_lifetime(lua_State* L) {
  sprite_render_list* pSrl = luaT_testuserdata<sprite_render_list>(L);
  pSrl->set_lifetime(static_cast<int>(luaL_checkinteger(L, 2)));
  lua_settop(L, 1);
  return 1;
}

int l_srl_set_use_intermediate_buffer(lua_State* L) {
  sprite_render_list* pSrl = luaT_testuserdata<sprite_render_list>(L);
  pSrl->set_use_intermediate_buffer();
  return 0;
}

int l_srl_is_dead(lua_State* L) {
  sprite_render_list* pSrl = luaT_testuserdata<sprite_render_list>(L);
  lua_pushboolean(L, pSrl->is_dead() ? 1 : 0);
  return 1;
}

}  // namespace

void lua_register_anims(const lua_register_state* pState) {
  // Anims
  {
    lua_class_binding<animation_manager> lcb(pState, "anims", l_anims_new,
                                             lua_metatable::anims);
    lcb.add_function(l_anims_load, "load");
    lcb.add_function(l_anims_loadcustom, "loadCustom");
    lcb.add_function(l_anims_set_spritesheet, "setSheet", lua_metatable::sheet);
    lcb.add_function(l_anims_set_canvas, "setCanvas", lua_metatable::surface);
    lcb.add_function(l_anims_getanims, "getAnimations");
    lcb.add_function(l_anims_getfirst, "getFirstFrame");
    lcb.add_function(l_anims_getnext, "getNextFrame");
    lcb.add_function(l_anims_set_alt_pal, "setAnimationGhostPalette");
    lcb.add_function(l_anims_set_primary_marker, "setFramePrimaryMarker");
    lcb.add_function(l_anims_set_secondary_marker, "setFrameSecondaryMarker");
    lcb.add_function(l_anims_draw, "draw", lua_metatable::surface,
                     lua_metatable::layers);
    lcb.add_function(l_anims_tick, "tick");
    lcb.add_constant("Alt32_GreyScale", thdf_alt32_grey_scale);
    lcb.add_constant("Alt32_BlueRedSwap", thdf_alt32_blue_red_swap);
  }

  // Weak table at AnimMetatable[1] for light UD -> object lookup
  // For hitTest / setHitTestResult
  lua_newtable(pState->L);
  lua_createtable(pState->L, 0, 1);
  lua_pushliteral(pState->L, "v");
  lua_setfield(pState->L, -2, "__mode");
  lua_setmetatable(pState->L, -2);
  lua_rawseti(pState->L,
              pState->metatables[static_cast<size_t>(lua_metatable::anim)], 1);

  // Weak table at AnimMetatable[2] for light UD -> full UD lookup
  // For persisting Map
  lua_newtable(pState->L);
  lua_createtable(pState->L, 0, 1);
  lua_pushliteral(pState->L, "v");
  lua_setfield(pState->L, -2, "__mode");
  lua_setmetatable(pState->L, -2);
  lua_rawseti(pState->L,
              pState->metatables[static_cast<size_t>(lua_metatable::anim)], 2);

  // Anim
  {
    lua_class_binding<animation> lcb(pState, "animation", l_anim_new<animation>,
                                     lua_metatable::anim);
    lcb.add_metamethod(l_anim_persist<animation>, "persist");
    lcb.add_metamethod(l_anim_pre_depersist<animation>, "pre_depersist");
    lcb.add_metamethod(l_anim_depersist<animation>, "depersist");
    lcb.add_function(l_anim_set_anim, "setAnimation", lua_metatable::anims);
    lcb.add_function(l_anim_set_crop, "setCrop");
    lcb.add_function(l_anim_get_crop, "getCrop");
    lcb.add_function(l_anim_set_morph, "setMorph");
    lcb.add_function(l_anim_set_frame, "setFrame");
    lcb.add_function(l_anim_get_frame, "getFrame");
    lcb.add_function(l_anim_get_anim, "getAnimation");
    lcb.add_function(l_anim_set_tile<animation>, "setTile", lua_metatable::map);
    lcb.add_function(l_anim_get_tile, "getTile");
    lcb.add_function(l_anim_set_parent, "setParent");
    lcb.add_function(l_anim_set_flag<animation>, "setFlag");
    lcb.add_function(l_anim_set_flag_partial<animation>, "setPartialFlag");
    lcb.add_function(l_anim_get_flag<animation>, "getFlag");
    lcb.add_function(l_anim_make_visible<animation>, "makeVisible");
    lcb.add_function(l_anim_make_invisible<animation>, "makeInvisible");
    lcb.add_function(l_anim_set_tag, "setTag");
    lcb.add_function(l_anim_get_tag, "getTag");
    lcb.add_function(l_anim_set_pixel_offset<animation>, "setPosition");
    lcb.add_function(l_anim_get_pixel_offset, "getPosition");
    lcb.add_function(l_anim_set_speed<animation>, "setSpeed");
    lcb.add_function(l_anim_set_layer<animation>, "setLayer");
    lcb.add_function(l_anim_set_layers_from, "setLayersFrom");
    lcb.add_function(l_anim_set_hitresult, "setHitTestResult");
    lcb.add_function(l_anim_get_primary_marker, "getPrimaryMarker");
    lcb.add_function(l_anim_get_secondary_marker, "getSecondaryMarker");
    lcb.add_function(l_anim_tick<animation>, "tick");
    lcb.add_function(l_anim_draw<animation>, "draw", lua_metatable::surface);
    lcb.add_function(l_anim_add_proxy, "addProxy");
    lcb.add_function(l_anim_remove_all_proxies, "removeAllProxies");
    lcb.add_function(l_anim_set_patient_effect, "setPatientEffect");
  }

  // Duplicate AnimMetatable[1,2] to SpriteListMetatable[1,2]
  lua_rawgeti(pState->L,
              pState->metatables[static_cast<size_t>(lua_metatable::anim)], 1);
  lua_rawseti(
      pState->L,
      pState->metatables[static_cast<size_t>(lua_metatable::sprite_list)], 1);
  lua_rawgeti(pState->L,
              pState->metatables[static_cast<size_t>(lua_metatable::anim)], 2);
  lua_rawseti(
      pState->L,
      pState->metatables[static_cast<size_t>(lua_metatable::sprite_list)], 2);

  // SpriteList
  {
    lua_class_binding<sprite_render_list> lcb(pState, "spriteList",
                                              l_anim_new<sprite_render_list>,
                                              lua_metatable::sprite_list);
    lcb.add_metamethod(l_anim_persist<sprite_render_list>, "persist");
    lcb.add_metamethod(l_anim_pre_depersist<sprite_render_list>,
                       "pre_depersist");
    lcb.add_metamethod(l_anim_depersist<sprite_render_list>, "depersist");
    lcb.add_function(l_srl_set_sheet, "setSheet", lua_metatable::sheet);
    lcb.add_function(l_srl_append, "append");
    lcb.add_function(l_srl_set_lifetime, "setLifetime");
    lcb.add_function(l_srl_set_use_intermediate_buffer,
                     "setUseIntermediateBuffer");
    lcb.add_function(l_srl_is_dead, "isDead");
    lcb.add_function(l_anim_set_tile<sprite_render_list>, "setTile",
                     lua_metatable::map);
    lcb.add_function(l_anim_set_flag<sprite_render_list>, "setFlag");
    lcb.add_function(l_anim_set_flag_partial<sprite_render_list>,
                     "setPartialFlag");
    lcb.add_function(l_anim_get_flag<sprite_render_list>, "getFlag");
    lcb.add_function(l_anim_make_visible<sprite_render_list>, "makeVisible");
    lcb.add_function(l_anim_make_invisible<sprite_render_list>,
                     "makeInvisible");
    lcb.add_function(l_anim_set_pixel_offset<sprite_render_list>,
                     "setPosition");
    lcb.add_function(l_anim_set_speed<sprite_render_list>, "setSpeed");
    lcb.add_function(l_anim_set_layer<sprite_render_list>, "setLayer");
    lcb.add_function(l_anim_tick<sprite_render_list>, "tick");
    lcb.add_function(l_anim_draw<sprite_render_list>, "draw",
                     lua_metatable::surface);
  }
}
