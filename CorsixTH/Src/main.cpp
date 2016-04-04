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

#include "config.h"
#include "lua.hpp"
extern "C" {
int luaopen_random(lua_State *L);
}
#include "rnc.h"
#include "th_lua.h"
#include "lua_sdl.h"
#include "jit_opt.h"
#include "persist_lua.h"
#include "iso_fs.h"
#include <cstring>
#include <cstdio>

// Config file checking
#ifndef CORSIX_TH_USE_PACK_PRAGMAS
#error "config.h is out of date - please rerun CMake"
#endif
// End of config file checking

int CorsixTH_lua_main_no_eval(lua_State *L)
{
    // assert(_VERSION == LUA_VERSION)
    size_t iLength;
    lua_getglobal(L, "_VERSION");
    const char* sVersion = lua_tolstring(L, -1, &iLength);
    if(iLength != std::strlen(LUA_VERSION) || std::strcmp(sVersion, LUA_VERSION) != 0)
    {
        lua_pushliteral(L, "Linked against a version of Lua different to the "
            "one used when compiling.\nPlease recompile CorsixTH against the "
            "same Lua version it is linked against.");
        return lua_error(L);
    }
    lua_pop(L, 1);

    // math.random* = Mersenne twister variant
    luaT_cpcall(L, luaopen_random, nullptr);

    // package.preload["jit.opt"] = load(jit_opt_lua)
    // package.preload["jit.opt_inline"] = load(jit_opt_inline_lua)
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "preload");
    luaL_loadbuffer(L, (const char*)jit_opt_lua, sizeof(jit_opt_lua),
        "jit/opt.luac");
    lua_setfield(L, -2, "jit.opt");
    luaL_loadbuffer(L, (const char*)jit_opt_inline_lua,
        sizeof(jit_opt_inline_lua), "jit/opt_inline.luac");
    lua_setfield(L, -2, "jit.opt_inline");
    lua_pop(L, 2);

    // if registry._LOADED.jit then
    // require"jit.opt".start()
    // else
    // print "Notice: ..."
    // end
    // (this could be done in Lua rather than here, but ideally the optimiser
    // should be turned on before any Lua code is loaded)
    lua_getfield(L, LUA_REGISTRYINDEX, "_LOADED");
    lua_getfield(L, -1, "jit");
    if(lua_type(L, -1) == LUA_TNIL)
    {
        lua_pop(L, 2);
    }
    else
    {
        lua_pop(L, 2);
        lua_getglobal(L, "require");
        lua_pushliteral(L, "jit.opt");
        lua_call(L, 1, 1);
        lua_getfield(L, -1, "start");
        lua_call(L, 0, 0);
        lua_pop(L, 1);
    }

    // Fill in package.preload table so that calls to require("X") from Lua
    // will call the appropriate luaopen_X function in C.
#define PRELOAD(name, fn) \
    luaT_execute(L, "package.preload." name " = ...", fn)
    PRELOAD("rnc", luaopen_rnc);
    PRELOAD("TH", luaopen_th);
    PRELOAD("ISO_FS", luaopen_iso_fs);
    PRELOAD("persist", luaopen_persist);
    PRELOAD("sdl", luaopen_sdl);
#undef PRELOAD

    // require "debug" (Harmless in Lua 5.1, useful in 5.2 for compatbility)
    luaT_execute(L, "require \"debug\"");

    // Check for --interpreter and run that instead of CorsixTH.lua
    bool bGotScriptFile = false;
    int iNArgs = lua_gettop(L);
    for(int i = 1; i <= iNArgs; ++i)
    {
        if(lua_type(L, i) == LUA_TSTRING)
        {
            size_t iLen;
            const char* sCmd = lua_tolstring(L, i, &iLen);
            if(iLen > 14 && std::memcmp(sCmd, "--interpreter=", 14) == 0)
            {
                lua_getglobal(L, "assert");
                lua_getglobal(L, "loadfile");
                lua_pushlstring(L, sCmd + 14, iLen - 14);
                bGotScriptFile = true;
                break;
            }
        }
    }

    // Code to try several variations on finding CorsixTH.lua:
    // CorsixTH.lua
    // CorsixTH/CorsixTH.lua
    // ../CorsixTH.lua
    // ../CorsixTH/CorsixTH.lua
    // ../../CorsixTH.lua
    // ../../CorsixTH/CorsixTH.lua
    // ../../../CorsixTH.lua
    // ../../../CorsixTH/CorsixTH.lua
    // It is simpler to write this in Lua than in C.
    const char sLuaCorsixTHLua[] =
    "local name, sep, code = \"CorsixTH.lua\", package.config:sub(1, 1)\n"
    "local root = (... or \"\"):match(\"^(.*[\"..sep..\"])\") or \"\"\n"
#ifdef __APPLE__ // Darrell: Search inside the bundle first.
                 // There's probably a better way of doing this.
#if defined(IS_CORSIXTH_APP)
    "code = loadfile(\"CorsixTH.app/Contents/Resources/\"..name)\n"
    "if code then return code end\n"
#endif
#endif
    "for num_dotdot = 0, 3 do\n"
    "  for num_dir = 0, 1 do\n"
    "    code = loadfile(root..(\"..\"..sep):rep(num_dotdot)..\n"
    "                    (\"CorsixTH\"..sep):rep(num_dir)..name)\n"
    "    if code then return code end \n"
    "  end \n"
    "end \n"
    "return loadfile(name)";

    // return assert(loadfile"CorsixTH.lua")(...)
    if(!bGotScriptFile)
    {
        lua_getglobal(L, "assert");
        luaL_loadbuffer(L, sLuaCorsixTHLua, std::strlen(sLuaCorsixTHLua),
            "@main.cpp (l_main bootstrap)");
        if(lua_gettop(L) == 2)
            lua_pushnil(L);
        else
            lua_pushvalue(L, 1);
    }
    lua_call(L, 1, 2);
    lua_call(L, 2, 1);
    lua_insert(L, 1);
    return lua_gettop(L);
}

int CorsixTH_lua_main(lua_State *L)
{
    lua_call(L, CorsixTH_lua_main_no_eval(L) - 1, LUA_MULTRET);
    return lua_gettop(L);
}

int CorsixTH_lua_stacktrace(lua_State *L)
{
    // err = tostring(err)
    lua_settop(L, 1);
    lua_getglobal(L, "tostring");
    lua_insert(L, 1);
    lua_call(L, 1, 1);

    // err = <description> .. err
    lua_pushliteral(L, "An error has occurred in CorsixTH:\n");
    lua_insert(L, 1);
    lua_concat(L, 2);

    // return debug.traceback(err, 2)
    lua_getglobal(L, "debug");
    lua_getfield(L, -1, "traceback");
    lua_pushvalue(L, 1);
    lua_pushinteger(L, 2);
    lua_call(L, 2, 1);

    return 1;
}

int CorsixTH_lua_panic(lua_State *L)
{
    std::fprintf(stderr, "A Lua error has occurred in CorsixTH outside of protected "
        "mode!!\n");
    std::fflush(stderr);

    if(lua_type(L, -1) == LUA_TSTRING)
        std::fprintf(stderr, "%s\n", lua_tostring(L, -1));
    else
        std::fprintf(stderr, "%p\n", lua_topointer(L, -1));
    std::fflush(stderr);

    // A stack trace would be nice, but they cannot be done in a panic.

    return 0;
}
