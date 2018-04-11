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

/* this variable is used to determine the layer of the animation, it should be rewriten at some
  point so that the it is passed as an argument in the function l_anim_set_tile */
static int last_layer = 2;

static int l_anims_new(lua_State *L)
{
    luaT_stdnew<animation_manager>(L, luaT_environindex, true);
    return 1;
}

static int l_anims_set_spritesheet(lua_State *L)
{
    animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
    sprite_sheet* pSheet = luaT_testuserdata<sprite_sheet>(L, 2);
    lua_settop(L, 2);

    pAnims->set_sprite_sheet(pSheet);
    luaT_setenvfield(L, 1, "sprites");
    return 1;
}

//! Set the video target for the sprites.
/*!
    setCanvas(<video-surface>)
 */
static int l_anims_set_canvas(lua_State *L)
{
    animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
    render_target* pCanvas = luaT_testuserdata<render_target>(L, 2);
    lua_settop(L, 2);

    pAnims->set_canvas(pCanvas);
    luaT_setenvfield(L, 1, "target");
    return 1;
}

static int l_anims_load(lua_State *L)
{
    animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
    size_t iStartDataLength, iFrameDataLength, iListDataLength, iElementDataLength;
    const uint8_t* pStartData = luaT_checkfile(L, 2, &iStartDataLength);
    const uint8_t* pFrameData = luaT_checkfile(L, 3, &iFrameDataLength);
    const uint8_t* pListData = luaT_checkfile(L, 4, &iListDataLength);
    const uint8_t* pElementData = luaT_checkfile(L, 5, &iElementDataLength);

    if(pAnims->load_from_th_file(pStartData, iStartDataLength, pFrameData, iFrameDataLength,
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

//! Load custom animations.
/*!
    loadCustom(<data-of-an-animation-file>) -> true/false
 */
static int l_anims_loadcustom(lua_State *L)
{
    animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
    size_t iDataLength;
    const uint8_t* pData = luaT_checkfile(L, 2, &iDataLength);

    if (pAnims->load_custom_animations(pData, iDataLength))
    {
        lua_pushboolean(L, 1);
    }
    else
    {
        lua_pushboolean(L, 0);
    }

    return 1;
}

//! Lua interface for getting a set of animations by name and tile size (one for
//! each view direction, 'nil' if no animation is available for a direction).
/*!
    getAnimations(<tile-size>, <animation-name>) -> (<anim-north>, <anim-east>,  <anim-south>, <anim-west>)
 */
static int l_anims_getanims(lua_State *L)
{
    animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
    int iTileSize = static_cast<int>(luaL_checkinteger(L, 2));
    const char *pName = luaL_checkstring(L, 3);

    const animation_start_frames &oFrames = pAnims->get_named_animations(pName, iTileSize);
    if (oFrames.north < 0) { lua_pushnil(L); } else { lua_pushnumber(L, static_cast<double>(oFrames.north)); }
    if (oFrames.east  < 0) { lua_pushnil(L); } else { lua_pushnumber(L, static_cast<double>(oFrames.east));  }
    if (oFrames.south < 0) { lua_pushnil(L); } else { lua_pushnumber(L, static_cast<double>(oFrames.south)); }
    if (oFrames.west  < 0) { lua_pushnil(L); } else { lua_pushnumber(L, static_cast<double>(oFrames.west));  }
    return 4;
}


static int l_anims_getfirst(lua_State *L)
{
    animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
    int iAnim = static_cast<int>(luaL_checkinteger(L, 2));

    lua_pushinteger(L, pAnims->get_first_frame(iAnim));
    return 1;
}

static int l_anims_getnext(lua_State *L)
{
    animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
    int iFrame = static_cast<int>(luaL_checkinteger(L, 2));

    lua_pushinteger(L, pAnims->get_next_frame(iFrame));
    return 1;
}

static int l_anims_set_alt_pal(lua_State *L)
{
    animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
    size_t iAnimation = luaL_checkinteger(L, 2);
    size_t iPalLen;
    const uint8_t *pPal = luaT_checkfile(L, 3, &iPalLen);
    if(iPalLen != 256)
    {
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

static int l_anims_set_marker(lua_State *L)
{
    animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
    lua_pushboolean(L, pAnims->set_frame_marker(luaL_checkinteger(L, 2),
        static_cast<int>(luaL_checkinteger(L, 3)), static_cast<int>(luaL_checkinteger(L, 4))) ? 1 : 0);
    return 1;
}

static int l_anims_set_secondary_marker(lua_State *L)
{
    animation_manager* pAnims = luaT_testuserdata<animation_manager>(L);
    lua_pushboolean(L, pAnims->set_frame_secondary_marker(luaL_checkinteger(L, 2),
        static_cast<int>(luaL_checkinteger(L, 3)), static_cast<int>(luaL_checkinteger(L, 4))) ? 1 : 0);
    return 1;
}

static int l_anims_draw(lua_State *L)
{
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
static int l_anim_new(lua_State *L)
{
    T* pAnimation = luaT_stdnew<T>(L, luaT_environindex, true);
    lua_rawgeti(L, luaT_environindex, 2);
    lua_pushlightuserdata(L, pAnimation);
    lua_pushvalue(L, -3);
    lua_rawset(L, -3);
    lua_pop(L, 1);
    return 1;
}

template <typename T>
static int l_anim_persist(lua_State *L)
{
    T* pAnimation;
    if(lua_gettop(L) == 2)
    {
        pAnimation = luaT_testuserdata<T>(L, 1, luaT_environindex, false);
        lua_insert(L, 1);
    }
    else
    {
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
static int l_anim_pre_depersist(lua_State *L)
{
    // Note that anims and the map have nice reference cycles between them
    // and hence we cannot be sure which is depersisted first. To ensure that
    // things work nicely, we initialise all the fields of a THAnimation as
    // soon as possible, thus preventing issues like an anim -> map -> anim
    // reference chain whereby l_anim_depersist is called after l_map_depersist
    // (as anim references map in its environment table) causing the prev
    // field to be set during map depersistence, then cleared to nullptr by the
    // constructor during l_anim_depersist.
    T* pAnimation = luaT_testuserdata<T>(L);
    new (pAnimation) T; // Call constructor
    return 0;
}

template <typename T>
static int l_anim_depersist(lua_State *L)
{
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
    if(!pReader->read_stack_object())
        return 0;
    lua_settable(L, -3);
    lua_pop(L, 1);
    return 0;
}

static int l_anim_set_hitresult(lua_State *L)
{
    luaL_checktype(L, 1, LUA_TUSERDATA);
    lua_settop(L, 2);
    lua_rawgeti(L, luaT_environindex, 1);
    lua_pushlightuserdata(L, lua_touserdata(L, 1));
    lua_pushvalue(L, 2);
    lua_settable(L, 3);
    lua_settop(L, 1);
    return 1;
}

static int l_anim_set_frame(lua_State *L)
{
    animation* pAnimation = luaT_testuserdata<animation>(L);
    pAnimation->set_frame(luaL_checkinteger(L, 2));
    lua_settop(L, 1);
    return 1;
}

static int l_anim_get_frame(lua_State *L)
{
    animation* pAnimation = luaT_testuserdata<animation>(L);
    lua_pushinteger(L, pAnimation->get_frame());
    return 1;
}

static int l_anim_set_crop(lua_State *L)
{
    animation* pAnimation = luaT_testuserdata<animation>(L);
    pAnimation->set_crop_column(static_cast<int>(luaL_checkinteger(L, 2)));
    lua_settop(L, 1);
    return 1;
}

static int l_anim_get_crop(lua_State *L)
{
    animation* pAnimation = luaT_testuserdata<animation>(L);
    lua_pushinteger(L, pAnimation->get_crop_column());
    return 1;
}

static int l_anim_set_anim(lua_State *L)
{
    animation* pAnimation = luaT_testuserdata<animation>(L);
    animation_manager* pManager = luaT_testuserdata<animation_manager>(L, 2);
    size_t iAnim = luaL_checkinteger(L, 3);
    if(iAnim < 0 || iAnim >= pManager->get_animation_count())
        luaL_argerror(L, 3, "Animation index out of bounds");

    if(lua_isnoneornil(L, 4))
        pAnimation->set_flags(0);
    else
        pAnimation->set_flags(static_cast<uint32_t>(luaL_checkinteger(L, 4)));

    pAnimation->set_animation(pManager, iAnim);
    lua_settop(L, 2);
    luaT_setenvfield(L, 1, "animator");
    lua_pushnil(L);
    luaT_setenvfield(L, 1, "morph_target");

    return 1;
}

static int l_anim_set_morph(lua_State *L)
{
    animation* pAnimation = luaT_testuserdata<animation>(L);
    animation* pMorphTarget = luaT_testuserdata<animation>(L, 2, luaT_environindex);

    unsigned int iDurationFactor = 1;
    if(!lua_isnoneornil(L, 3) && luaL_checkinteger(L, 3) > 0)
        iDurationFactor = static_cast<unsigned int>(luaL_checkinteger(L, 3));

    pAnimation->set_morph_target(pMorphTarget, iDurationFactor);
    lua_settop(L, 2);
    luaT_setenvfield(L, 1, "morph_target");

    return 1;
}

static int l_anim_set_drawable_layer(lua_State *L)
{
    last_layer = static_cast<int>(luaL_checkinteger(L, 2));
    return 1;
}

static int l_anim_get_anim(lua_State *L)
{
    animation* pAnimation = luaT_testuserdata<animation>(L);
    lua_pushinteger(L, pAnimation->get_animation());

    return 1;
}

template <typename T>
static int l_anim_set_tile(lua_State *L)
{

    T* pAnimation = luaT_testuserdata<T>(L);
    if(lua_isnoneornil(L, 2))
    {
        pAnimation->remove_from_tile();
        lua_pushnil(L);
        luaT_setenvfield(L, 1, "map");
        lua_settop(L, 1);
    }
    else
    {
        level_map* pMap = luaT_testuserdata<level_map>(L, 2);
        map_tile* pNode = pMap->get_tile(static_cast<int>(luaL_checkinteger(L, 3) - 1), static_cast<int>(luaL_checkinteger(L, 4) - 1));
        if(pNode)
            pAnimation->attach_to_tile(pNode, last_layer);

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
    animation* pAnimation = luaT_testuserdata<animation>(L);
    lua_settop(L, 1);
    lua_getfenv(L, 1);
    lua_getfield(L, 2, "map");
    lua_replace(L, 2);
    if(lua_isnil(L, 2))
    {
        return 0;
    }
    level_map* pMap = (level_map*)lua_touserdata(L, 2);
    const link_list* pListNode = pAnimation->get_previous();
    while(pListNode->prev)
    {
        pListNode = pListNode->prev;
    }
    // Casting pListNode to a map_tile* is slightly dubious, but it should
    // work. If on the normal list, then pListNode will be a map_tile*, and
    // all is fine. However, if on the early list, pListNode will be pointing
    // to a member of a map_tile, so we're relying on pointer arithmetic
    // being a subtract and integer divide by sizeof(map_tile) to yield the
    // correct map_tile.
    const map_tile *pRootNode = pMap->get_tile_unchecked(0, 0);
    uintptr_t iDiff = reinterpret_cast<const char*>(pListNode) -
                      reinterpret_cast<const char*>(pRootNode);
    int iIndex = (int)(iDiff / sizeof(map_tile));
    int iY = iIndex / pMap->get_width();
    int iX = iIndex - (iY * pMap->get_width());
    lua_pushinteger(L, iX + 1);
    lua_pushinteger(L, iY + 1);
    return 3; // map, x, y
}

static int l_anim_set_parent(lua_State *L)
{
    animation* pAnimation = luaT_testuserdata<animation>(L);
    animation* pParent = luaT_testuserdata<animation>(L, 2, luaT_environindex, false);
    pAnimation->set_parent(pParent);
    lua_settop(L, 1);
    return 1;
}

template <typename T>
static int l_anim_set_flag(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);
    pAnimation->set_flags(static_cast<uint32_t>(luaL_checkinteger(L, 2)));

    lua_settop(L, 1);
    return 1;
}

template <typename T>
static int l_anim_set_flag_partial(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);
    uint32_t iFlags = static_cast<uint32_t>(luaL_checkinteger(L, 2));
    if(lua_isnone(L, 3) || lua_toboolean(L, 3))
    {
        pAnimation->set_flags(pAnimation->get_flags() | iFlags);
    }
    else
    {
        pAnimation->set_flags(pAnimation->get_flags() & ~iFlags);
    }
    lua_settop(L, 1);
    return 1;
}

template <typename T>
static int l_anim_make_visible(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);
    pAnimation->set_flags(pAnimation->get_flags() & ~static_cast<uint32_t>(thdf_alpha_50 | thdf_alpha_75));

    lua_settop(L, 1);
    return 1;
}

template <typename T>
static int l_anim_make_invisible(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);
    pAnimation->set_flags(pAnimation->get_flags() | static_cast<uint32_t>(thdf_alpha_50 | thdf_alpha_75));

    lua_settop(L, 1);
    return 1;
}

template <typename T>
static int l_anim_get_flag(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);
    lua_pushinteger(L, pAnimation->get_flags());

    return 1;
}

template <typename T>
static int l_anim_set_position(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);

    pAnimation->set_position(static_cast<int>(luaL_checkinteger(L, 2)), static_cast<int>(luaL_checkinteger(L, 3)));

    lua_settop(L, 1);
    return 1;
}

static int l_anim_get_position(lua_State *L)
{
    animation* pAnimation = luaT_testuserdata<animation>(L);

    lua_pushinteger(L, pAnimation->get_x());
    lua_pushinteger(L, pAnimation->get_y());

    return 2;
}

template <typename T>
static int l_anim_set_speed(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);

    pAnimation->set_speed(static_cast<int>(luaL_optinteger(L, 2, 0)), static_cast<int>(luaL_optinteger(L, 3, 0)));

    lua_settop(L, 1);
    return 1;
}

template <typename T>
static int l_anim_set_layer(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);

    pAnimation->set_layer(static_cast<int>(luaL_checkinteger(L, 2)), static_cast<int>(luaL_optinteger(L, 3, 0)));

    lua_settop(L, 1);
    return 1;
}

static int l_anim_set_layers_from(lua_State *L)
{
    animation* pAnimation = luaT_testuserdata<animation>(L);
    const animation* pAnimationSrc = luaT_testuserdata<animation>(L, 2, luaT_environindex);

    pAnimation->set_layers_from(pAnimationSrc);

    lua_settop(L, 1);
    return 1;
}

static int l_anim_set_tag(lua_State *L)
{
    luaT_testuserdata<animation>(L);
    lua_settop(L, 2);
    luaT_setenvfield(L, 1, "tag");
    return 1;
}

static int l_anim_get_tag(lua_State *L)
{
    luaT_testuserdata<animation>(L);
    lua_settop(L, 1);
    lua_getfenv(L, 1);
    lua_getfield(L, 2, "tag");
    return 1;
}

static int l_anim_get_marker(lua_State *L)
{
    animation* pAnimation = luaT_testuserdata<animation>(L);
    int iX = 0;
    int iY = 0;
    pAnimation->get_marker(&iX, &iY);
    lua_pushinteger(L, iX);
    lua_pushinteger(L, iY);
    return 2;
}

static int l_anim_get_secondary_marker(lua_State *L)
{
    animation* pAnimation = luaT_testuserdata<animation>(L);
    int iX = 0;
    int iY = 0;
    pAnimation->get_secondary_marker(&iX, &iY);
    lua_pushinteger(L, iX);
    lua_pushinteger(L, iY);
    return 2;
}

template <typename T>
static int l_anim_tick(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);
    pAnimation->tick();
    lua_settop(L, 1);
    return 1;
}

template <typename T>
static int l_anim_draw(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);
    render_target* pCanvas = luaT_testuserdata<render_target>(L, 2);
    pAnimation->draw(pCanvas, static_cast<int>(luaL_checkinteger(L, 3)), static_cast<int>(luaL_checkinteger(L, 4)));
    lua_settop(L, 1);
    return 1;
}

static int l_srl_set_sheet(lua_State *L)
{
    sprite_render_list *pSrl = luaT_testuserdata<sprite_render_list>(L);
    sprite_sheet *pSheet = luaT_testuserdata<sprite_sheet>(L, 2);
    pSrl->set_sheet(pSheet);

    lua_settop(L, 2);
    luaT_setenvfield(L, 1, "sheet");
    return 1;
}

static int l_srl_append(lua_State *L)
{
    sprite_render_list *pSrl = luaT_testuserdata<sprite_render_list>(L);
    pSrl->append_sprite(luaL_checkinteger(L, 2),
                       static_cast<int>(luaL_checkinteger(L, 3)), static_cast<int>(luaL_checkinteger(L, 4)));
    lua_settop(L, 1);
    return 1;
}

static int l_srl_set_lifetime(lua_State *L)
{
    sprite_render_list *pSrl = luaT_testuserdata<sprite_render_list>(L);
    pSrl->set_lifetime(static_cast<int>(luaL_checkinteger(L, 2)));
    lua_settop(L, 1);
    return 1;
}

static int l_srl_is_dead(lua_State *L)
{
    sprite_render_list *pSrl = luaT_testuserdata<sprite_render_list>(L);
    lua_pushboolean(L, pSrl->is_dead() ? 1 : 0);
    return 1;
}

void lua_register_anims(const lua_register_state *pState)
{
    // Anims
    luaT_class(animation_manager, l_anims_new, "anims", lua_metatable::anims);
    luaT_setfunction(l_anims_load, "load");
    luaT_setfunction(l_anims_loadcustom, "loadCustom");
    luaT_setfunction(l_anims_set_spritesheet, "setSheet", lua_metatable::sheet);
    luaT_setfunction(l_anims_set_canvas, "setCanvas", lua_metatable::surface);
    luaT_setfunction(l_anims_getanims, "getAnimations");
    luaT_setfunction(l_anims_getfirst, "getFirstFrame");
    luaT_setfunction(l_anims_getnext, "getNextFrame");
    luaT_setfunction(l_anims_set_alt_pal, "setAnimationGhostPalette");
    luaT_setfunction(l_anims_set_marker, "setFrameMarker");
    luaT_setfunction(l_anims_set_secondary_marker, "setFrameSecondaryMarker");
    luaT_setfunction(l_anims_draw, "draw", lua_metatable::surface, lua_metatable::layers);
    luaT_setconstant("Alt32_GreyScale",   thdf_alt32_grey_scale);
    luaT_setconstant("Alt32_BlueRedSwap", thdf_alt32_blue_red_swap);
    luaT_endclass();

    // Weak table at AnimMetatable[1] for light UD -> object lookup
    // For hitTest / setHitTestResult
    lua_newtable(pState->L);
    lua_createtable(pState->L, 0, 1);
    lua_pushliteral(pState->L, "v");
    lua_setfield(pState->L, -2, "__mode");
    lua_setmetatable(pState->L, -2);
    lua_rawseti(pState->L, pState->metatables[static_cast<size_t>(lua_metatable::anim)], 1);

    // Weak table at AnimMetatable[2] for light UD -> full UD lookup
    // For persisting Map
    lua_newtable(pState->L);
    lua_createtable(pState->L, 0, 1);
    lua_pushliteral(pState->L, "v");
    lua_setfield(pState->L, -2, "__mode");
    lua_setmetatable(pState->L, -2);
    lua_rawseti(pState->L, pState->metatables[static_cast<size_t>(lua_metatable::anim)], 2);

    // Anim
    luaT_class(animation, l_anim_new<animation>, "animation", lua_metatable::anim);
    luaT_setmetamethod(l_anim_persist<animation>, "persist");
    luaT_setmetamethod(l_anim_pre_depersist<animation>, "pre_depersist");
    luaT_setmetamethod(l_anim_depersist<animation>, "depersist");
    luaT_setfunction(l_anim_set_anim, "setAnimation", lua_metatable::anims);
    luaT_setfunction(l_anim_set_crop, "setCrop");
    luaT_setfunction(l_anim_get_crop, "getCrop");
    luaT_setfunction(l_anim_set_morph, "setMorph");
    luaT_setfunction(l_anim_set_frame, "setFrame");
    luaT_setfunction(l_anim_get_frame, "getFrame");
    luaT_setfunction(l_anim_get_anim, "getAnimation");
    luaT_setfunction(l_anim_set_tile<animation>, "setTile", lua_metatable::map);
    luaT_setfunction(l_anim_get_tile, "getTile");
    luaT_setfunction(l_anim_set_parent, "setParent");
    luaT_setfunction(l_anim_set_flag<animation>, "setFlag");
    luaT_setfunction(l_anim_set_flag_partial<animation>, "setPartialFlag");
    luaT_setfunction(l_anim_get_flag<animation>, "getFlag");
    luaT_setfunction(l_anim_make_visible<animation>, "makeVisible");
    luaT_setfunction(l_anim_make_invisible<animation>, "makeInvisible");
    luaT_setfunction(l_anim_set_tag, "setTag");
    luaT_setfunction(l_anim_get_tag, "getTag");
    luaT_setfunction(l_anim_set_position<animation>, "setPosition");
    luaT_setfunction(l_anim_get_position, "getPosition");
    luaT_setfunction(l_anim_set_speed<animation>, "setSpeed");
    luaT_setfunction(l_anim_set_layer<animation>, "setLayer");
    luaT_setfunction(l_anim_set_layers_from, "setLayersFrom");
    luaT_setfunction(l_anim_set_hitresult, "setHitTestResult");
    luaT_setfunction(l_anim_get_marker, "getMarker");
    luaT_setfunction(l_anim_get_secondary_marker, "getSecondaryMarker");
    luaT_setfunction(l_anim_tick<animation>, "tick");
    luaT_setfunction(l_anim_draw<animation>, "draw", lua_metatable::surface);
    luaT_setfunction(l_anim_set_drawable_layer, "setDrawingLayer");
    luaT_endclass();

    // Duplicate AnimMetatable[1,2] to SpriteListMetatable[1,2]
    lua_rawgeti(pState->L, pState->metatables[static_cast<size_t>(lua_metatable::anim)], 1);
    lua_rawseti(pState->L, pState->metatables[static_cast<size_t>(lua_metatable::sprite_list)], 1);
    lua_rawgeti(pState->L, pState->metatables[static_cast<size_t>(lua_metatable::anim)], 2);
    lua_rawseti(pState->L, pState->metatables[static_cast<size_t>(lua_metatable::sprite_list)], 2);

    // SpriteList
    luaT_class(sprite_render_list, l_anim_new<sprite_render_list>, "spriteList", lua_metatable::sprite_list);
    luaT_setmetamethod(l_anim_persist<sprite_render_list>, "persist");
    luaT_setmetamethod(l_anim_pre_depersist<sprite_render_list>, "pre_depersist");
    luaT_setmetamethod(l_anim_depersist<sprite_render_list>, "depersist");
    luaT_setfunction(l_srl_set_sheet, "setSheet", lua_metatable::sheet);
    luaT_setfunction(l_srl_append, "append");
    luaT_setfunction(l_srl_set_lifetime, "setLifetime");
    luaT_setfunction(l_srl_is_dead, "isDead");
    luaT_setfunction(l_anim_set_tile<sprite_render_list>, "setTile", lua_metatable::map);
    luaT_setfunction(l_anim_set_flag<sprite_render_list>, "setFlag");
    luaT_setfunction(l_anim_set_flag_partial<sprite_render_list>, "setPartialFlag");
    luaT_setfunction(l_anim_get_flag<sprite_render_list>, "getFlag");
    luaT_setfunction(l_anim_make_visible<sprite_render_list>, "makeVisible");
    luaT_setfunction(l_anim_make_invisible<sprite_render_list>, "makeInvisible");
    luaT_setfunction(l_anim_set_position<sprite_render_list>, "setPosition");
    luaT_setfunction(l_anim_set_speed<sprite_render_list>, "setSpeed");
    luaT_setfunction(l_anim_set_layer<sprite_render_list>, "setLayer");
    luaT_setfunction(l_anim_tick<sprite_render_list>, "tick");
    luaT_setfunction(l_anim_draw<sprite_render_list>, "draw", lua_metatable::surface);
    luaT_endclass();
}
