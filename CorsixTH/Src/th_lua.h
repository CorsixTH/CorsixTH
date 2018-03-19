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

#ifndef CORSIX_TH_TH_LUA_H_
#define CORSIX_TH_TH_LUA_H_
#include "config.h"
#include "lua.hpp"
#include <new>
#include <vector>

int luaopen_th(lua_State *L);

// Compatibility layer for removal of environments in 5.2
#if LUA_VERSION_NUM >= 502
const int luaT_environindex = lua_upvalueindex(1);
#else
const int luaT_environindex = LUA_ENVIRONINDEX;
#endif

inline int luaT_upvalueindex(int i)
{
#if LUA_VERSION_NUM >= 502
    return lua_upvalueindex(i + 1);
#else
    return lua_upvalueindex(i);
#endif
}

inline void luaT_register(lua_State *L, const char *n, const std::vector<luaL_Reg> &l)
{
#if LUA_VERSION_NUM >= 502
    lua_createtable(L, 0, static_cast<int>(l.size()));
    lua_pushvalue(L, luaT_environindex);
    luaL_setfuncs(L, l.data(), 1);
    lua_pushvalue(L, -1);
    lua_setglobal(L, n);
#else
    luaL_register(L, n, l.data());
#endif
}

inline void luaT_setfuncs(lua_State *L, const luaL_Reg *R)
{
#if LUA_VERSION_NUM >= 502
    lua_pushvalue(L, luaT_environindex);
    luaL_setfuncs(L, R, 1);
#else
    luaL_register(L, nullptr, R);
#endif
}

inline void luaT_pushcclosure(lua_State* L, lua_CFunction f, int nups)
{
#if LUA_VERSION_NUM >= 502
    ++nups;
    lua_pushvalue(L, luaT_environindex);
    lua_insert(L, -nups);
    lua_pushcclosure(L, f, nups);
#else
    lua_pushcclosure(L, f, nups);
#endif
}

inline void luaT_pushcfunction(lua_State *L, lua_CFunction f)
{
    luaT_pushcclosure(L, f, 0);
}

inline int luaT_cpcall(lua_State *L, lua_CFunction f, void *u)
{
#if LUA_VERSION_NUM >= 502
    lua_checkstack(L, 2);
    lua_pushcfunction(L, f);
    lua_pushlightuserdata(L, u);
    return lua_pcall(L, 1, 0, 0);
#else
    return lua_cpcall(L, f, u);
#endif
}

// Compatibility for missing mode argument on lua_load in 5.1
inline int luaT_load(lua_State *L, lua_Reader r, void *d, const char *s, const char *m)
{
#if LUA_VERSION_NUM >= 502
    return lua_load(L, r, d, s, m);
#else
    return lua_load(L, r, d, s);
#endif
}

// Compatibility for missing from argument on lua_resume in 5.1
inline int luaT_resume(lua_State *L, lua_State *f, int n)
{
#if LUA_VERSION_NUM >= 502
    return lua_resume(L, f, n);
#else
    return lua_resume(L, n);
#endif
}

//! Version of operator new which allocates into a Lua userdata
/*!
    If a specific constructor of T is required, then call like:
      T* variable = luaT_new(L, T)(constructor arguments);
    If the default constructor is wanted, it can be called like:
      T* variable = luaT_new(L, T);
    See also luaT_stdnew() which allocates, and also sets up the environment
    table and metatable for the userdata.
*/
#define luaT_new(L, T) new ((T*)lua_newuserdata(L, sizeof(T))) T

//! Check that a Lua argument is a binary data blob
/*!
    If the given argument is a string or (full) userdata, then returns a
    pointer to the start of it, and the length of it. Otherwise, throws a
    Lua error.
*/
const uint8_t* luaT_checkfile(lua_State *L, int idx, size_t* pDataLen);

//! Check that a Lua argument is a string or a proxied string
const char* luaT_checkstring(lua_State *L, int idx, size_t* pLength);

//! Push a C closure as a callable table
void luaT_pushcclosuretable(lua_State *L, lua_CFunction fn, int n);

//! Set a field on the environment table of a value
/*!
    Performs: env(stack[index])[k] = top; pop()
*/
void luaT_setenvfield(lua_State *L, int index, const char *k);

//! Get a field from the environment table of a value
/*!
    Performs: push(env(stack[index])[k])
*/
void luaT_getenvfield(lua_State *L, int index, const char *k);

template <class T>
inline T* luaT_stdnew(lua_State *L, int mt_idx = luaT_environindex, bool env = false)
{
    T* p = luaT_new(L, T);
    lua_pushvalue(L, mt_idx);
    lua_setmetatable(L, -2);
    if(env)
    {
        lua_newtable(L);
        lua_setfenv(L, -2);
    }
    return p;
}

template <typename T> struct luaT_classinfo {};

class render_target;
template <> struct luaT_classinfo<render_target> {
    static inline const char* name() {return "Surface";}
};

class level_map;
template <> struct luaT_classinfo<level_map> {
    static inline const char* name() {return "Map";}
};

class sprite_sheet;
template <> struct luaT_classinfo<sprite_sheet> {
    static inline const char* name() {return "SpriteSheet";}
};

class animation;
template <> struct luaT_classinfo<animation> {
    static inline const char* name() {return "Animation";}
};

class animation_manager;
template <> struct luaT_classinfo<animation_manager> {
    static inline const char* name() {return "Animator";}
};

class palette;
template <> struct luaT_classinfo<palette> {
    static inline const char* name() {return "Palette";}
};

class raw_bitmap;
template <> struct luaT_classinfo<raw_bitmap> {
    static inline const char* name() {return "RawBitmap";}
};

class font;
template <> struct luaT_classinfo<font> {
    static inline const char* name() {return "Font";}
};

class bitmap_font;
template <> struct luaT_classinfo<bitmap_font> {
    static inline const char* name() {return "BitmapFont";}
};

#ifdef CORSIX_TH_USE_FREETYPE2
class freetype_font;
template <> struct luaT_classinfo<freetype_font> {
    static inline const char* name() {return "FreeTypeFont";}
};
#endif

struct layers;
template <> struct luaT_classinfo<layers> {
    static inline const char* name() {return "Layers";}
};

class pathfinder;
template <> struct luaT_classinfo<pathfinder> {
    static inline const char* name() {return "Pathfinder";}
};

class cursor;
template <> struct luaT_classinfo<cursor> {
    static inline const char* name() {return "Cursor";}
};

class line;
template <> struct luaT_classinfo<line> {
    static inline const char* name() {return "Line";}
};

class music;
template <> struct luaT_classinfo<music> {
    static inline const char* name() {return "Music";}
};

class sound_archive;
template <> struct luaT_classinfo<sound_archive> {
    static inline const char* name() {return "SoundArchive";}
};

class sound_player;
template <> struct luaT_classinfo<sound_player> {
    static inline const char* name() {return "SoundEffects";}
};

class movie_player;
template <> struct luaT_classinfo<movie_player> {
    static inline const char* name() {return "Movie";}
};

class abstract_window;
template <> struct luaT_classinfo<abstract_window> {
    static inline const char* name() {return "WindowBase";}
};

class sprite_render_list;
template <> struct luaT_classinfo<sprite_render_list> {
    static inline const char* name() {return "SpriteRenderList";}
};

class string_proxy;
template <> struct luaT_classinfo<string_proxy> {
    static inline const char* name() {return "StringProxy";}
};

class lfs_ext;
template <> struct luaT_classinfo <lfs_ext> {
    static inline const char* name() {return "LfsExt";}
};

class iso_filesystem;
template <> struct luaT_classinfo<iso_filesystem> {
    static inline const char* name() {return "ISO Filesystem";}
};

template <> struct luaT_classinfo<FILE*> {
    static inline const char* name() {return "file";}
};

template <class T>
static T* luaT_testuserdata(lua_State *L, int idx, int mt_idx, bool required = true)
{
    // Turn mt_idx into an absolute index, as the stack size changes.
    if(mt_idx > LUA_REGISTRYINDEX && mt_idx < 0)
        mt_idx = lua_gettop(L) + mt_idx + 1;

    void *ud = lua_touserdata(L, idx);
    if(ud != nullptr && lua_getmetatable(L, idx) != 0)
    {
        while(true)
        {
            if(lua_equal(L, mt_idx, -1) != 0)
            {
                lua_pop(L, 1);
                return (T*)ud;
            }
            // Go up one inheritance level, if there is one.
            if(lua_type(L, -1) != LUA_TTABLE)
                break;
            lua_rawgeti(L, -1, 1);
            lua_replace(L, -2);
        }
        lua_pop(L, 1);
    }

    if (required)
    {
        const char *msg = lua_pushfstring(L, "%s expected, got %s", luaT_classinfo<T>::name(), luaL_typename(L, idx));
        luaL_argerror(L, idx, msg);
    }
    return nullptr;
}

template <class T>
static T* luaT_testuserdata(lua_State *L, int idx = 1)
{
    int iMetaIndex = luaT_environindex;
    if(idx > 1)
        iMetaIndex = luaT_upvalueindex(idx - 1);
    return luaT_testuserdata<T>(L, idx, iMetaIndex);
}

template <class T, int mt>
static int luaT_stdgc(lua_State *L)
{
    T* p = luaT_testuserdata<T>(L, 1, mt, false);
    if(p != nullptr)
    {
        p->~T();
    }
    return 0;
}

void luaT_execute(lua_State *L, const char* sLuaString);
void luaT_execute_loadstring(lua_State *L, const char* sLuaString);

void luaT_push(lua_State *L, lua_CFunction f);
void luaT_push(lua_State *L, int i);
void luaT_push(lua_State *L, const char* s);

template <class T>
static void luaT_execute(lua_State *L, const char* sLuaString, T arg)
{
    luaT_execute_loadstring(L, sLuaString);
    luaT_push(L, arg);
    lua_call(L, 1, LUA_MULTRET);
}

template <class T1, class T2>
static void luaT_execute(lua_State *L, const char* sLuaString,
                         T1 arg1, T2 arg2)
{
    luaT_execute_loadstring(L, sLuaString);
    luaT_push(L, arg1);
    luaT_push(L, arg2);
    lua_call(L, 2, LUA_MULTRET);
}

template <class T1, class T2, class T3>
static void luaT_execute(lua_State *L, const char* sLuaString,
                         T1 arg1, T2 arg2, T3 arg3)
{
    luaT_execute_loadstring(L, sLuaString);
    luaT_push(L, arg1);
    luaT_push(L, arg2);
    luaT_push(L, arg3);
    lua_call(L, 3, LUA_MULTRET);
}

template <class T1, class T2, class T3, class T4>
static void luaT_execute(lua_State *L, const char* sLuaString,
                         T1 arg1, T2 arg2, T3 arg3, T4 arg4)
{
    luaT_execute_loadstring(L, sLuaString);
    luaT_push(L, arg1);
    luaT_push(L, arg2);
    luaT_push(L, arg3);
    luaT_push(L, arg4);
    lua_call(L, 4, LUA_MULTRET);
}

void luaT_pushtablebool(lua_State *L, const char *k, bool v);

void luaT_printstack(lua_State *L);

void luaT_printrawtable(lua_State *L, int idx);

#endif // CORSIX_TH_TH_LUA_H_
