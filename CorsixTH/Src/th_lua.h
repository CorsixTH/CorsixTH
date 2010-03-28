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
#include "th.h"
#include <new>

int luaopen_th(lua_State *L);

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

void luaT_setenvfield(lua_State *L, int index, const char *k);
void luaT_getenvfield(lua_State *L, int index, const char *k);

template <class T>
inline T* luaT_stdnew(lua_State *L, int mt_idx = LUA_ENVIRONINDEX, bool env = false)
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
    if(mt_idx > LUA_REGISTRYINDEX && mt_idx < 0)
        mt_idx = lua_gettop(L) + mt_idx + 1;

    void *ud = lua_touserdata(L, idx);
    if(ud != NULL && lua_getmetatable(L, idx) != 0)
    {
        if(lua_equal(L, mt_idx, -1) != 0)
        {
            lua_pop(L, 1);
            return (T*)ud;
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
    int iMetaIndex = LUA_ENVIRONINDEX;
    if(idx > 1)
        iMetaIndex = lua_upvalueindex(idx - 1);
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

#endif // CORSIX_TH_TH_LUA_H_
