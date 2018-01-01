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

#ifndef CORSIX_TH_LUA_HPP_
#define CORSIX_TH_LUA_HPP_

extern "C" {
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}

#if LUA_VERSION_NUM >= 502
// Quick preprocessor fixes to improve compatibility with Lua 5.2
// These definitions will already have been made if Lua 5.2 was compiled
// with LUA_COMPAT_ALL defined, but we have no control over this.

#ifndef lua_objlen
inline size_t lua_objlen(lua_State *L, int idx)
{
    return lua_rawlen(L, idx);
}
#endif

#ifndef lua_equal
inline int lua_equal(lua_State *L, int idx1, int idx2)
{
    return lua_compare(L, idx1, idx2, LUA_OPEQ);
}
#endif

#ifndef lua_lessthan
inline int lua_lessthan(lua_State *L, int idx1, int idx2)
{
    return lua_compare(L, idx1, idx2, LUA_OPLT);
}
#endif

// Use our own replacements for lua_[sg]etfenv
#ifndef lua_setfenv
int luaT_setfenv52(lua_State*, int);
inline int lua_setfenv(lua_State *L, int n)
{
    return luaT_setfenv52(L, n);
}
#endif

#ifndef lua_getfenv
void luaT_getfenv52(lua_State*, int);
inline void lua_getfenv(lua_State *L, int n)
{
    luaT_getfenv52(L, n);
}
#endif

#endif // LUA_VERSION_NUM >= 502

#endif // CORSIX_TH_LUA_HPP_
