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
#include "../../LFS/lfs.h"
int luaopen_random(lua_State *L);
}
#include "rnc.h"
#include "th_lua.h"
#include "lua_sdl.h"
#include "jit_opt.h"
#include "persist_lua.h"
#ifdef CORSIX_TH_USE_WIN32_SDK
#include <windows.h>
#endif
#include <stack>

#ifndef CORSIX_TH_MAP_EDITOR
static int l_main(lua_State *L);
static int l_stacktrace(lua_State *L);
static int l_panic(lua_State *L);

template <typename T1, typename T2>
struct types_equal{ enum{
    result = -1,
}; };

template <typename T1>
struct types_equal<T1, T1>{ enum{
    result = 1,
}; };

//! Program entry point
/*!
    Prepares a Lua state for, and catches errors from, l_main(). By executing
    in Lua mode as soon as possible, errors can be nicely caught sooner, hence
    this function does as little as possible and leaves the rest for l_main().
*/
int main(int argc, char** argv)
{
    struct compile_time_lua_check
    {
        // Lua 5.1, not 5.0, is required
        int lua_5_point_1_required[LUA_VERSION_NUM >= 501 ? 1 : -1];

        // Lua numbers must be doubles so that the mantissa has at least
        // 32 bits (floats only have 24 bits)
        int number_is_double[types_equal<lua_Number, double>::result];
    };

    bool bRun = true;

    while(bRun)
    {
        lua_State *L = NULL;

        L = luaL_newstate();
        lua_atpanic(L, l_panic);
        luaL_openlibs(L);
        lua_settop(L, 0);
        lua_pushcfunction(L, l_stacktrace);
        lua_pushcfunction(L, l_main);

        // Move command line parameters onto the Lua stack
        lua_checkstack(L, argc);
        for(int i = 0; i < argc; ++i)
        {
            lua_pushstring(L, argv[i]);
        }

        if(lua_pcall(L, argc, 0, 1) != 0)
        {
            const char* err = lua_tostring(L, -1);
            if(err != NULL)
            {
                fprintf(stderr, "%s\n", err);
            }
            else
            {
                fprintf(stderr, "An error has occured in CorsixTH:\n"
                    "Uncaught non-string Lua error\n");
            }
            lua_close(L);
#ifndef _DEBUG
#ifdef CORSIX_TH_USE_WIN32_SDK
            // As a Win32 command line application, the command prompt will
            // disappear when the application terminates (unless launched from
            // the command line, which is rare in Windows). Hence a message box
            // is thrown up to keep the command prompt open and make sure the
            // user is aware of what happened.
            // (Debug builds don't have this message box as they are only made
            // by developers, and developers know what a command prompt is)
            MessageBox(NULL, "CorsixTH encountered an error during startup - "
                "consult the log window for details.", "CorsixTH",
                MB_ICONERROR);
#endif
#endif
            return -1;
        }

        lua_getfield(L, LUA_REGISTRYINDEX, "_RESTART");
        bRun = lua_toboolean(L, -1) != 0;

        // Get cleanup functions out of the Lua state (but don't run them yet)
        std::stack<void(*)(void)> stkCleanup;
        lua_getfield(L, LUA_REGISTRYINDEX, "_CLEANUP");
        if(lua_type(L, -1) == LUA_TTABLE)
        {
            for(unsigned int i = 1; i <= lua_objlen(L, -1); ++i)
            {
                lua_rawgeti(L, -1, (int)i);
                stkCleanup.push((void(*)(void))lua_touserdata(L, -1));
                lua_pop(L, 1);
            }
        }

        lua_close(L);

        // The cleanup functions are executed _after_ the Lua state is fully
        // closed, and in reserve order to that in which they were registered.
        while(!stkCleanup.empty())
        {
            if(stkCleanup.top() != NULL)
                stkCleanup.top()();
            stkCleanup.pop();
        }

        if(bRun)
        {
            printf("Restarting...\n");
        }
    }
    return 0;
}

//! Lua mode entry point
/*!
    Performs the Lua initialisation tasks which have to be done in C, and then
    transfers control to CorsixTH.lua as soon as possible (so that as little as
    possible behaviour is hardcoded into C rather than Lua).
*/
static int l_main(lua_State *L)
#else // CORSIX_TH_MAP_EDITOR
int THMain_l_main(lua_State *L)
#endif // CORSIX_TH_MAP_EDITOR
{
    // assert(_VERSION == LUA_VERSION)
    size_t iLength;
    lua_getglobal(L, "_VERSION");
    const char* sVersion = lua_tolstring(L, -1, &iLength);
    if(iLength != strlen(LUA_VERSION) || strcmp(sVersion, LUA_VERSION) != 0)
    {
        lua_pushliteral(L, "Linked against a version of Lua different to the "
            "one used when compiling.\nPlease recompile CorsixTH against the "
            "same Lua version it is linked against.");
        return lua_error(L);
    }
    lua_pop(L, 1);

    // registry._CLEANUP = {}
    lua_newtable(L);
    lua_setfield(L, LUA_REGISTRYINDEX, "_CLEANUP");

    // math.random* = Mersenne twister variant
#ifdef LUA_RIDX_CPCALL
    lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_CPCALL);
    lua_CFunction fnCPCall = luaopen_random;
    lua_pushlightuserdata(L, &fnCPCall);
    lua_pcall(L, 1, 0, 0);
#else
    lua_cpcall(L, luaopen_random, NULL);
#endif

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
        lua_getglobal(L, "print");
        lua_pushliteral(L, "Notice: LuaJIT not being used.\nConsider replacing"
            " Lua with LuaJIT to improve performance.");
#ifdef CORSIX_TH_64BIT
        lua_pushliteral(L, " Note that there is not currently a 64 bit version"
            " of LuaJIT.");
        lua_concat(L, 2);
#endif
        lua_call(L, 1, 0);
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

    // package.preload.lfs = luaopen_lfs
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "preload");
    lua_pushliteral(L, "lfs");
    lua_pushcfunction(L, luaopen_lfs);
    lua_settable(L, -3);

    // package.preload.rnc = luaopen_rnc
    lua_pushliteral(L, "rnc");
    lua_pushcfunction(L, luaopen_rnc);
    lua_settable(L, -3);

    // package.preload.TH = luaopen_th
    lua_pushliteral(L, "TH");
    lua_pushcfunction(L, luaopen_th);
    lua_settable(L, -3);

    // package.preload.persist = luaopen_persist
    lua_pushliteral(L, "persist");
    lua_pushcfunction(L, luaopen_persist);
    lua_settable(L, -3);

    // package.preload.sdl = luaopen_sdl
    lua_pushliteral(L, "sdl");
    lua_pushcfunction(L, luaopen_sdl);
    lua_settable(L, -3);
    lua_pop(L, 2);

    // require "debug" (Harmless in Lua 5.1, useful in 5.2 for compatbility)
    lua_getglobal(L, "require");
    lua_pushliteral(L, "debug");
    lua_call(L, 1, 0);

    // Code to try several variations on finding CorsixTH.lua:
    // CorsixTH/CorsixTH.lua
    // CorsixTH.lua
    // ../CorsixTH.lua
    // ../../CorsixTH.lua
    // ../../../CorsixTH.lua
    // It is simpler to write this in Lua than in C.
    const char sLuaCorsixTHLua[] =
    "local name, sep, code = \"CorsixTH.lua\", package.config:sub(1, 1)"
    "local root = (...):match(\"^(.*[\"..sep..\"])\")"
    "code = loadfile(root..\"CorsixTH\"..sep..name)"
    "if code then return code end "
    "for i = 0, 3 do "
    "  code = loadfile(root..(\"..\"..sep):rep(i)..name)"
    "  if code then return code end "
    "end "
    "return loadfile(name)";

    // return assert(loadfile"CorsixTH.lua")(...)
    lua_getglobal(L, "assert");
    luaL_loadstring(L, sLuaCorsixTHLua);
    lua_pushvalue(L, 1);
    lua_call(L, 1, 2);
    lua_call(L, 2, 1);
    lua_insert(L, 1);
#ifndef CORSIX_TH_MAP_EDITOR
    lua_call(L, lua_gettop(L) - 1, LUA_MULTRET);
#endif

    return lua_gettop(L);
}

//! Process a caught error before returning it to main
/*!
    Processing of the error message is done here so that a stack trace can be
    added before the stack is unwound, and so that if an error occurs while
    processing the error, main() receives LUA_ERRERR rather than panicking
    while processing it itself.
*/
#ifdef CORSIX_TH_MAP_EDITOR
int THMain_l_stacktrace(lua_State *L)
#else
static int l_stacktrace(lua_State *L)
#endif
{
    // err = tostring(err)
    lua_settop(L, 1);
    lua_getglobal(L, "tostring");
    lua_insert(L, 1);
    lua_call(L, 1, 1);

    // err = <description> .. err
    lua_pushliteral(L, "An error has occured in CorsixTH:\n");
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

//! Process an uncaught Lua error before aborting
/*!
    Lua errors shouldn't occur outside of protected mode, and there isn't much
    which can be done when they do, but at least the user should be informed,
    and the error message printed.
*/
static int l_panic(lua_State *L)
{
    fprintf(stderr, "A Lua error has occured in CorsixTH outside of protected "
        "mode!!\n");
    fflush(stderr);

    if(lua_type(L, -1) == LUA_TSTRING)
        fprintf(stderr, "%s\n", lua_tostring(L, -1));
    else
        fprintf(stderr, "%p\n", lua_topointer(L, -1));
    fflush(stderr);

    // A stack trace would be nice, but they cannot be done in a panic.

    return 0;
}
