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
#include <spdlog/common.h>
#include <spdlog/sinks/rotating_file_sink.h>
#include <spdlog/sinks/stdout_color_sinks.h>
#include <spdlog/spdlog.h>

#include <cstdio>
#include <cstdlib>

#include "../Src/bootstrap.h"
#ifdef CORSIX_TH_USE_SDL_MIXER
#include <SDL_mixer.h>
#endif
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

static void cleanup(lua_State* L) {
  lua_close(L);
#ifdef CORSIX_TH_USE_SDL_MIXER
  while (Mix_QuerySpec(nullptr, nullptr, nullptr)) {
    Mix_CloseAudio();
  }
#endif
  SDL_Quit();
}

static std::string get_log_dir() {
#ifdef _WIN32
  const char* appDir = std::getenv("AppData");
  if (appDir == nullptr) {
    return std::string(".");
  }
  return std::string(appDir).append("/CorsixTH");
#else
  const char* xdgConfigDir = std::getenv("XDG_STATE_HOME");
  if (xdgConfigDir != nullptr) {
    return std::string(xdgConfigDir).append("/CorsixTH");
  }
  const char* homeDir = std::getenv("HOME");
  if (homeDir == nullptr) {
    homeDir = "~";
  }
  return std::string(homeDir).append("/.local/state/CorsixTH");
#endif
}

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

  try {
    auto consoleSink = std::make_shared<spdlog::sinks::stdout_color_sink_mt>();
    consoleSink->set_level(spdlog::level::warn);

    constexpr size_t maxLogSize = 1024 * 1024 * 5;  // 5MB
    constexpr size_t maxFiles = 10;
    std::string logFile = get_log_dir().append("/gamelog.txt");

    auto fileSink = std::make_shared<spdlog::sinks::rotating_file_sink_mt>(
        logFile.c_str(), maxLogSize, maxFiles, true);
    fileSink->set_level(spdlog::level::trace);

    spdlog::sinks_init_list sinkList{consoleSink, fileSink};
    auto gameLog = std::make_shared<spdlog::logger>("gamelog", sinkList.begin(),
                                                    sinkList.end());
    gameLog->set_level(spdlog::level::info);

    spdlog::set_default_logger(gameLog);
  } catch (const spdlog::spdlog_ex& ex) {
    spdlog::error("Failed to register gamelog: {}", ex.what());
  }

#ifdef WITH_UPDATE_CHECK
  curl_global_init(CURL_GLOBAL_DEFAULT);
#endif

  bool bRun = true;

  while (bRun) {
    lua_State* L = nullptr;

    L = luaL_newstate();
    if (L == nullptr) {
      spdlog::error("Fatal error starting CorsixTH: Cannot open Lua state.");
      return 0;
    }
    lua_atpanic(L, lua_panic);
    luaL_openlibs(L);
    lua_settop(L, 0);
    lua_pushcfunction(L, lua_stacktrace);
    lua_pushcfunction(L, lua_main);

    // Move command line parameters onto the Lua stack
    lua_checkstack(L, argc);
    for (int i = 0; i < argc; ++i) {
      lua_pushstring(L, argv[i]);
    }

    if (lua_pcall(L, argc, 0, 1) != 0) {
      const char* err = lua_tostring(L, -1);
      if (err != nullptr) {
        spdlog::error("{}", err);
      } else {
        spdlog::error(
            "An error has occurred in CorsixTH:\n"
            "Uncaught non-string Lua error\n");
      }
      lua_pushcfunction(L, bootstrap_lua_error_report);
      lua_insert(L, -2);
      if (lua_pcall(L, 1, 0, 0) != 0) {
        std::fprintf(stderr, "%s\n", lua_tostring(L, -1));
      }
    }

    lua_getfield(L, LUA_REGISTRYINDEX, "_RESTART");
    bRun = lua_toboolean(L, -1) != 0;

    cleanup(L);

    if (bRun) {
      spdlog::info("Restarting...");
    }
  }
#ifdef WITH_UPDATE_CHECK
  curl_global_cleanup();
#endif
  spdlog::shutdown();

  return 0;
}
