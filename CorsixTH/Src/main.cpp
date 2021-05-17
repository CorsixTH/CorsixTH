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

#include <cstdio>
#include <cstring>
#include <string>

#include "iso_fs.h"
#include "lua.hpp"
#include "lua_rnc.h"
#include "lua_sdl.h"
#include "persist_lua.h"
#include "th_lua.h"

#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#endif

// Config file checking
#ifndef CORSIX_TH_USE_PACK_PRAGMAS
#error "config.h is out of date - please rerun CMake"
#endif
// End of config file checking

extern "C" {
int luaopen_random(lua_State* L);
}

namespace {

inline void preload_lua_package(lua_State* L, const char* name,
                                lua_CFunction fn) {
  luaT_execute(
      L, std::string("package.preload.").append(name).append(" = ...").c_str(),
      fn);
}

}  // namespace

int lua_main_no_eval(lua_State* L) {
  // assert(_VERSION == LUA_VERSION)
  size_t iLength;
  lua_getglobal(L, "_VERSION");
  const char* sVersion = lua_tolstring(L, -1, &iLength);
  if (iLength != std::strlen(LUA_VERSION) ||
      std::strcmp(sVersion, LUA_VERSION) != 0) {
    lua_pushliteral(
        L,
        "Linked against a version of Lua different to the one used "
        "when compiling.\nPlease recompile CorsixTH against the same "
        "Lua version it is linked against.");
    return lua_error(L);
  }
  lua_pop(L, 1);

  // math.random* = Mersenne twister variant
  luaT_cpcall(L, luaopen_random, nullptr);

  // Fill in package.preload table so that calls to require("X") from Lua
  // will call the appropriate luaopen_X function in C.
  preload_lua_package(L, "rnc", luaopen_rnc);
  preload_lua_package(L, "TH", luaopen_th);
  preload_lua_package(L, "persist", luaopen_persist);
  preload_lua_package(L, "sdl", luaopen_sdl);

  // require "debug" (Harmless in Lua 5.1, useful in 5.2 for compatibility)
  luaT_execute(L, "require \"debug\"");

  // Check for --interpreter and run that instead of CorsixTH.lua
  bool bGotScriptFile = false;
  int iNArgs = lua_gettop(L);
  for (int i = 1; i <= iNArgs; ++i) {
    if (lua_type(L, i) == LUA_TSTRING) {
      size_t iLen;
      const char* sCmd = lua_tolstring(L, i, &iLen);
      if (iLen > 14 && std::memcmp(sCmd, "--interpreter=", 14) == 0) {
        lua_getglobal(L, "assert");
        lua_getglobal(L, "loadfile");
        lua_pushlstring(L, sCmd + 14, iLen - 14);
        bGotScriptFile = true;
        break;
      }
    }
  }

  if (!bGotScriptFile) {
    lua_getglobal(L, "assert");
    lua_getglobal(L, "loadfile");
    lua_pushstring(L, CORSIX_TH_INTERPRETER_PATH);
  }

  lua_call(L, 1, 2);
  lua_call(L, 2, 1);
  lua_insert(L, 1);
  return lua_gettop(L);
}

#ifdef __EMSCRIPTEN__
EM_JS(void, js_load_lua_modules, (), {
  Asyncify.handleAsync(async () => {
    try {
      await loadDynamicLibrary('/var/empty/local/share/corsix-th/lfs.so', { loadAsync: true, global: true, nodelete: true, fs: FS });
      await loadDynamicLibrary('/var/empty/local/share/corsix-th/lpeg.so', { loadAsync: true, global: true, nodelete: true, fs: FS });
    }
    catch (error) {
      console.log(`CorsixTH ${error}`);
    }
  });
});

EMSCRIPTEN_KEEPALIVE
void lua_load_modules() {
  js_load_lua_modules();
}
#endif

int lua_main(lua_State* L) {
  #ifdef __EMSCRIPTEN__
  lua_load_modules();
  #endif

  lua_call(L, lua_main_no_eval(L) - 1, LUA_MULTRET);
  return lua_gettop(L);
}

int lua_stacktrace(lua_State* L) {
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

int lua_panic(lua_State* L) {
  std::fprintf(stderr,
               "A Lua error has occurred in CorsixTH outside of protected "
               "mode!\n");
  std::fflush(stderr);

  if (lua_type(L, -1) == LUA_TSTRING)
    std::fprintf(stderr, "%s\n", lua_tostring(L, -1));
  else
    std::fprintf(stderr, "%p\n", lua_topointer(L, -1));
  std::fflush(stderr);

  // A stack trace would be nice, but they cannot be done in a panic.

  return 0;
}
