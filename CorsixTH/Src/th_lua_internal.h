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

#ifndef CORSIX_TH_TH_LUA_INTERNAL_H_
#define CORSIX_TH_TH_LUA_INTERNAL_H_
#include "config.h"
#include "th_lua.h"

enum class lua_metatable {
    map,
    palette,
    sheet,
    font,
    bitmap_font,
#ifdef CORSIX_TH_USE_FREETYPE2
    freetype_font,
#endif
    layers,
    anims,
    anim,
    pathfinder,
    surface,
    bitmap,
    cursor,
    lfs_ext,
    sound_archive,
    sound_fx,
    movie,
    string,
    window_base,
    sprite_list,
    string_proxy,
    line,

    count
};

struct lua_register_state
{
    lua_State *L;
    int metatables[static_cast<size_t>(lua_metatable::count)];
    int main_table;
    int top;
};

void luaT_setclosure(const lua_register_state *pState, lua_CFunction fn, size_t iUps);

template<typename... Args>
void luaT_setclosure(const lua_register_state *pState, lua_CFunction fn, size_t iUps,
        lua_metatable eMetatable1, Args... args) {
    lua_pushvalue(pState->L, pState->metatables[static_cast<size_t>(eMetatable1)]);
    luaT_setclosure(pState, fn, iUps + 1, args...);
}

template<typename... Args>
void luaT_setclosure(const lua_register_state *pState, lua_CFunction fn, size_t iUps,
        const char* str, Args... args) {
    lua_pushstring(pState->L, str);
    luaT_setclosure(pState, fn, iUps + 1, args...);
}

#define luaT_class(typnam, new_fn, name, mt) { \
    const char * sCurrentClassName = name; \
    int iCurrentClassMT = pState->metatables[static_cast<size_t>(mt)]; \
    lua_settop(pState->L, pState->top); \
    /* Make metatable the environment for registered functions */ \
    lua_pushvalue(pState->L, iCurrentClassMT); \
    lua_replace(pState->L, luaT_environindex); \
    /* Set the __gc metamethod to C++ destructor */ \
    luaT_pushcclosure(pState->L, luaT_stdgc<typnam, luaT_environindex>, 0); \
    lua_setfield(pState->L, iCurrentClassMT, "__gc"); \
    /* Set the depersist size */ \
    lua_pushinteger(pState->L, sizeof(typnam)); \
    lua_setfield(pState->L, iCurrentClassMT, "__depersist_size"); \
    /* Create the methods table; call it -> new instance */ \
    luaT_pushcclosuretable(pState->L, new_fn, 0); \
    /* Set __class_name on the methods metatable */ \
    lua_getmetatable(pState->L, -1); \
    lua_pushstring(pState->L, sCurrentClassName); \
    lua_setfield(pState->L, -2, "__class_name"); \
    lua_pop(pState->L, 1); \
    /* Set __index to the methods table */ \
    lua_pushvalue(pState->L, -1); \
    lua_setfield(pState->L, iCurrentClassMT, "__index")

#define luaT_superclass(super_mt) \
    /* Set __index on the methods metatable to the superclass methods */ \
    lua_getmetatable(pState->L, -1); \
    lua_getfield(pState->L, pState->metatables[static_cast<size_t>(super_mt)], "__index"); \
    lua_setfield(pState->L, -2, "__index"); \
    lua_pop(pState->L, 1); \
    /* Set metatable[1] to super_mt */ \
    lua_pushvalue(pState->L, pState->metatables[static_cast<size_t>(super_mt)]); \
    lua_rawseti(pState->L, iCurrentClassMT, 1)

#define luaT_endclass() \
    lua_setfield(pState->L, pState->main_table, sCurrentClassName); }

#define luaT_setmetamethod(fn, name, ...) \
    luaT_setclosure(pState, fn, 0, ## __VA_ARGS__); \
    lua_setfield(pState->L, iCurrentClassMT, "__" name)

#define luaT_setfunction(fn, name, ...) \
    luaT_setclosure(pState, fn, 0, ## __VA_ARGS__); \
    lua_setfield(pState->L, -2, name)

/**
 * Add a named constant to the lua interface.
 * @param name (string literal) Name of the constant.
 * @param value (tested with int) Value of the constant.
 */
#define luaT_setconstant(name, value) \
    luaT_push(pState->L, value); \
    lua_setfield(pState->L, -2, name)

#endif
