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

#define luaT_new(L, T) new ((T*)lua_newuserdata(L, sizeof(T))) T

template <class T>
static T* luaT_stdnew(lua_State *L, int mt_idx = LUA_ENVIRONINDEX, bool env = false)
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

template <class T, bool dethunk>
static T* luaT_testuserdata(lua_State *L, int idx, int mt_idx, const char* name)
{
    if(mt_idx < 0 && mt_idx > LUA_REGISTRYINDEX)
        mt_idx = lua_gettop(L) + mt_idx + 1;

    void *ud = lua_touserdata(L, idx);
    if(ud != NULL && lua_getmetatable(L, idx) != 0)
    {
        if(lua_equal(L, mt_idx, -1) != 0)
        {
            lua_pop(L, 1);
            if(dethunk)
            {
                T* t = *(T**)ud;
                if(t != NULL)
                    return t;
            }
            else
            {
                return (T*)ud;
            }
        }
        lua_pop(L, 1);
    }

    if(name != NULL)
        luaL_typerror(L, idx, name);
    return NULL;
}

template <class T, bool dethunk, int mt>
static int luaT_stdgc(lua_State *L)
{
    T* p = luaT_testuserdata<T, false>(L, 1, mt, NULL);
    if(p != NULL)
    {
        if(dethunk)
        {
            delete *(T**)p;
            *(T**)p = (T*)NULL;
        }
        else
        {
            p->~T();
        }
    }
    return 0;
}

#endif // CORSIX_TH_TH_LUA_H_
