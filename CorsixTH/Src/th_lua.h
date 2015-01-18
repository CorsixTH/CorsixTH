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
#include "lua.hpp"
#include <new>

int luaopen_th(lua_State *L);

// Compatibility layer for removal of environments in 5.2
#if LUA_VERSION_NUM >= 502
#define luaT_environindex lua_upvalueindex(1)
#define luaT_upvalueindex(i) lua_upvalueindex((i) + 1)
void luaT_pushcclosure(lua_State* L, lua_CFunction f, int nups);
#define luaT_register(L, n, p) (\
    lua_pushvalue(L, luaT_enrivonindex), \
    luaL_openlib(L, n, p, 1) )
#else
#define luaT_environindex LUA_ENVIRONINDEX
#define luaT_upvalueindex lua_upvalueindex
#define luaT_pushcclosure lua_pushcclosure
#define luaT_register luaL_register
#endif
#define luaT_pushcfunction(L, f) luaT_pushcclosure(L, f, 0)

// Compatibility layer for removal of cpcall in 5.2
#if LUA_VERSION_NUM >= 502
#define luaT_cpcall(L, f, u) (\
    lua_checkstack(L, 2), \
    lua_pushcfunction(L, f), \
    lua_pushlightuserdata(L, u), \
    lua_pcall(L, 1, 0, 0) )
#else
#define luaT_cpcall lua_cpcall
#endif

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

//! Register a function to be called after a lua_State is destroyed
void luaT_addcleanup(lua_State *L, void(*fnCleanup)(void));

//! Check that a Lua argument is a binary data blob
/*!
    If the given argument is a string or (full) userdata, then returns a
    pointer to the start of it, and the length of it. Otherwise, throws a
    Lua error.
*/
const unsigned char* luaT_checkfile(lua_State *L, int idx, size_t* pDataLen);

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

class THRenderTarget;
template <> struct luaT_classinfo<THRenderTarget> {
    static inline const char* name() {return "Surface";}
};

class THMap;
template <> struct luaT_classinfo<THMap> {
    static inline const char* name() {return "Map";}
};

class THSpriteSheet;
template <> struct luaT_classinfo<THSpriteSheet> {
    static inline const char* name() {return "SpriteSheet";}
};

class THAnimation;
template <> struct luaT_classinfo<THAnimation> {
    static inline const char* name() {return "Animation";}
};

class THAnimationManager;
template <> struct luaT_classinfo<THAnimationManager> {
    static inline const char* name() {return "Animator";}
};

class THPalette;
template <> struct luaT_classinfo<THPalette> {
    static inline const char* name() {return "Palette";}
};

class THRawBitmap;
template <> struct luaT_classinfo<THRawBitmap> {
    static inline const char* name() {return "RawBitmap";}
};

class THFont;
template <> struct luaT_classinfo<THFont> {
    static inline const char* name() {return "Font";}
};

class THBitmapFont;
template <> struct luaT_classinfo<THBitmapFont> {
    static inline const char* name() {return "BitmapFont";}
};

#ifdef CORSIX_TH_USE_FREETYPE2
class THFreeTypeFont;
template <> struct luaT_classinfo<THFreeTypeFont> {
    static inline const char* name() {return "FreeTypeFont";}
};
#endif

struct THLayers_t;
template <> struct luaT_classinfo<THLayers_t> {
    static inline const char* name() {return "Layers";}
};

class THPathfinder;
template <> struct luaT_classinfo<THPathfinder> {
    static inline const char* name() {return "Pathfinder";}
};

class THCursor;
template <> struct luaT_classinfo<THCursor> {
    static inline const char* name() {return "Cursor";}
};

class THLine;
template <> struct luaT_classinfo<THLine> {
    static inline const char* name() {return "Line";}
};

struct music_t;
template <> struct luaT_classinfo<music_t> {
    static inline const char* name() {return "Music";}
};

class THSoundArchive;
template <> struct luaT_classinfo<THSoundArchive> {
    static inline const char* name() {return "SoundArchive";}
};

class THSoundEffects;
template <> struct luaT_classinfo<THSoundEffects> {
    static inline const char* name() {return "SoundEffects";}
};

class THMovie;
template <> struct luaT_classinfo<THMovie> {
    static inline const char* name() {return "Movie";}
};

struct THWindowBase_t;
template <> struct luaT_classinfo<THWindowBase_t> {
    static inline const char* name() {return "WindowBase";}
};

class THSpriteRenderList;
template <> struct luaT_classinfo<THSpriteRenderList> {
    static inline const char* name() {return "SpriteRenderList";}
};

struct THStringProxy_t;
template <> struct luaT_classinfo<THStringProxy_t> {
    static inline const char* name() {return "StringProxy";}
};

struct THLfsExt;
template <> struct luaT_classinfo <THLfsExt> {
    static inline const char* name() {return "LfsExt";}
};

class IsoFilesystem;
template <> struct luaT_classinfo<IsoFilesystem> {
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
    if(ud != NULL && lua_getmetatable(L, idx) != 0)
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

    if(required)
        luaL_typerror(L, idx, luaT_classinfo<T>::name());
    return NULL;
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
    if(p != NULL)
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

#endif // CORSIX_TH_TH_LUA_H_
