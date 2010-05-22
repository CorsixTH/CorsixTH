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

#ifdef LUA_RIDX_CPCALL
// NB: Lua 5.2 isn't officially released yet, and only "work" versions are
// available. Until 5.2 is officially released, this makes 5.2 a moving target
// and it only makes sense to target the most recent version.
// LUA_RIDX_CPCALL was defined in 5.2-work1 and 5.2-work2, but is not present
// in 5.2-work3 (there were many other changes, but this is the easiest to
// detect at compile-time)
#error Please update to the latest version of Lua 5.2
#endif

#ifndef lua_objlen
#define lua_objlen(L, i) lua_rawlen(L, (i))
#endif

#ifndef luaL_typerror
#define luaL_typerror luaL_typeerror
#endif

#ifndef lua_equal
#define lua_equal(L, idx1, idx2) lua_compare(L, (idx1), (idx2), LUA_OPEQ)
#endif

#ifndef lua_lessthan
#define lua_lessthan(L, idx1, idx2) lua_compare(L, (idx1), (idx1), LUA_OPLT)
#endif

// Use our own replacements for lua_[sg]etfenv
#ifndef lua_setfenv
#define lua_setfenv luaT_setfenv52
int luaT_setfenv52(lua_State*, int);
#endif

#ifndef lua_getfenv
#define lua_getfenv luaT_getfenv52
void luaT_getfenv52(lua_State*, int);
#endif

#endif // LUA_VERSION_NUM >= 502

#endif // CORSIX_TH_LUA_HPP_
