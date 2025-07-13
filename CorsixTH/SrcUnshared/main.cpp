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

#include "../Src/main.h"

#include "config.h"

#include <SDL.h>
#include <SDL_mixer.h>

#include <cstdio>

#include "../Src/bootstrap.h"
#include "../Src/lua.hpp"
#include "../Src/th_lua.h"
#ifdef WITH_UPDATE_CHECK
#include <curl/curl.h>
#endif

// Template magic for checking type equality
template <typename T1, typename T2>
struct types_equal {
  enum {
    result = -1,
  };
};

template <typename T1>
struct types_equal<T1, T1> {
  enum {
    result = 1,
  };
};

//! Program entry point
/*!
    Prepares a Lua state for, and catches errors from, lua_main(). By
    executing in Lua mode as soon as possible, errors can be nicely caught
    sooner, hence this function does as little as possible and leaves the rest
    for lua_main().
*/
int main(int argc, char** argv) {
  struct compile_time_lua_check {
    // Lua 5.1, not 5.0, is required
    int lua_5_point_1_required[LUA_VERSION_NUM >= 501 ? 1 : -1];

    // Lua numbers must be doubles so that the mantissa has at least
    // 32 bits (floats only have 24 bits)
    int number_is_double[types_equal<lua_Number, double>::result];
  };

#ifdef WITH_UPDATE_CHECK
  curl_global_init(CURL_GLOBAL_DEFAULT);
#endif

  bool bRun = true;

  while (bRun) {
    lua_state_unique_ptr L(luaL_newstate());
    if (L == nullptr) {
      std::fprintf(stderr,
                   "Fatal error starting CorsixTH: "
                   "Cannot open Lua state.\n");
      return 0;
    }
    lua_atpanic(L.get(), lua_panic);
    luaL_openlibs(L.get());
    lua_settop(L.get(), 0);
    lua_pushcfunction(L.get(), lua_stacktrace);
    lua_pushcfunction(L.get(), lua_main);

    // Move command line parameters onto the Lua stack
    lua_checkstack(L.get(), argc);
    for (int i = 0; i < argc; ++i) {
      lua_pushstring(L.get(), argv[i]);
    }

    if (lua_pcall(L.get(), argc, 0, 1) != 0) {
      const char* err = lua_tostring(L.get(), -1);
      if (err != nullptr) {
        std::fprintf(stderr, "%s\n", err);
      } else {
        std::fprintf(stderr,
                     "An error has occurred in CorsixTH:\n"
                     "Uncaught non-string Lua error\n");
      }
      lua_pushcfunction(L.get(), bootstrap_lua_error_report);
      lua_insert(L.get(), -2);
      if (lua_pcall(L.get(), 1, 0, 0) != 0) {
        std::fprintf(stderr, "%s\n", lua_tostring(L.get(), -1));
      }
    }

    lua_getfield(L.get(), LUA_REGISTRYINDEX, "_RESTART");
    bRun = lua_toboolean(L.get(), -1) != 0;

    // Destroy the lua_State before SDL so that any SDL resource owned by
    // Lua can be freed first.
    L.reset(nullptr);
    while (Mix_QuerySpec(nullptr, nullptr, nullptr)) {
      Mix_CloseAudio();
    }
    SDL_Quit();

    if (bRun) {
      std::printf("\n\nRestarting...\n\n\n");
    }
  }
#ifdef WITH_UPDATE_CHECK
  curl_global_cleanup();
#endif
  return 0;
}
