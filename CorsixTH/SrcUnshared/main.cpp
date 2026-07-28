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
#include <cstdlib>
#include <memory>

#ifdef CORSIXTH_IOS
#include <algorithm>
#include <cctype>
#include <filesystem>
#include <fstream>
#include <optional>
#include <string>
#include <unistd.h>
#endif

#include "../Src/bootstrap.h"
#include "../Src/lua.hpp"
#include "../Src/sdl_core.h"
#include "../Src/th_lua.h"
#ifdef WITH_UPDATE_CHECK
#include <curl/curl.h>
#endif
#ifdef WITH_TRACY
#include <tracy/Tracy.hpp>
#include <tracy/TracyLua.hpp>
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

#ifdef WITH_TRACY

/// Replacement Lua Hook for Tracy Lua instrumentation
/**
 * As of this implementation the lua hook included in Tracy does not handle
 * errors caught by pcall, so we implement our own hook that does. See:
 * https://github.com/wolfpld/tracy/issues/1320
 */
void l_tracy_hook(lua_State* L, lua_Debug* ar) {
  using namespace tracy;
  static int depth = 0;
  if (ar->event == LUA_HOOKCALL) {
    lua_getinfo(L, "Snl", ar);
    depth++;

    char src[256];
    detail::LuaShortenSrc(src, ar->short_src);

    const auto srcloc = Profiler::AllocSourceLocation(
        ar->currentline, src, ar->name ? ar->name : ar->short_src);
    TracyQueuePrepare(QueueType::ZoneBeginAllocSrcLoc);
    MemWrite(&item->zoneBegin.time, Profiler::GetTime());
    MemWrite(&item->zoneBegin.srcloc, srcloc);
    TracyQueueCommit(zoneBeginThread);
  } else if (ar->event == LUA_HOOKRET) {
    do {
      depth--;
      TracyQueuePrepare(QueueType::ZoneEnd);
      MemWrite(&item->zoneEnd.time, Profiler::GetTime());
      TracyQueueCommit(zoneEndThread);
    } while (lua_getstack(L, depth, ar) == 0);
  }
}

#endif

#ifdef CORSIXTH_IOS

namespace {

namespace fs = std::filesystem;

std::string lowercase_ascii(std::string text) {
  std::transform(text.begin(), text.end(), text.begin(), [](unsigned char c) {
    return static_cast<char>(std::tolower(c));
  });
  return text;
}

std::optional<fs::path> find_child_case_insensitive(
    const fs::path& parent, const std::string& wanted_name,
    bool must_be_directory) {
  std::error_code error;
  if (!fs::is_directory(parent, error)) {
    return std::nullopt;
  }

  const std::string wanted_lower = lowercase_ascii(wanted_name);
  for (const fs::directory_entry& child :
       fs::directory_iterator(parent, error)) {
    if (error) {
      return std::nullopt;
    }
    if (lowercase_ascii(child.path().filename().string()) != wanted_lower) {
      continue;
    }
    if (must_be_directory ? child.is_directory(error)
                          : child.is_regular_file(error)) {
      return child.path();
    }
  }
  return std::nullopt;
}

bool has_theme_hospital_data(const fs::path& game_directory) {
  const auto data =
      find_child_case_insensitive(game_directory, "DATA", true);
  const auto levels =
      find_child_case_insensitive(game_directory, "LEVELS", true);
  const auto qdata =
      find_child_case_insensitive(game_directory, "QDATA", true);
  if (!data || !levels || !qdata) {
    return false;
  }

  return find_child_case_insensitive(*data, "VBLK-0.TAB", false) &&
         find_child_case_insensitive(*levels, "LEVEL.L1", false) &&
         find_child_case_insensitive(*qdata, "SPOINTER.DAT", false);
}

fs::path prepare_ios_game_directory() {
  const char* home = std::getenv("HOME");
  if (home == nullptr || *home == '\0') {
    return {};
  }

  const fs::path documents = fs::path(home) / "Documents";
  const fs::path game_directory = documents / "Theme Hospital";
  std::error_code error;
  fs::create_directories(game_directory, error);
  if (error) {
    return {};
  }

  setenv("CORSIXTH_IOS_DOCUMENTS", documents.c_str(), 1);

  if (!has_theme_hospital_data(game_directory)) {
    std::ofstream instructions(
        game_directory / "ADD THE GAME FILES HERE.txt",
        std::ios::out | std::ios::trunc);
    instructions
        << "Copy the DATA, LEVELS and QDATA folders from your original "
           "Theme Hospital installation directly into this folder.\n\n"
        << "The final layout must be:\n"
        << "Theme Hospital/DATA\n"
        << "Theme Hospital/LEVELS\n"
        << "Theme Hospital/QDATA\n\n"
        << "Then close and reopen CorsixTH.\n";
  }

  return game_directory;
}

void show_ios_data_instructions(bool files_folder_ready) {
  SDL_SetHint(SDL_HINT_ORIENTATIONS, "LandscapeLeft LandscapeRight");
  if (SDL_Init(SDL_INIT_VIDEO) != 0) {
    return;
  }

  const char* message =
      files_folder_ready
          ? "Open Files > On My iPhone > CorsixTH > Theme Hospital. "
            "Copy the DATA, LEVELS and QDATA folders directly into that "
            "folder, then close and reopen CorsixTH."
          : "CorsixTH could not create its folder in Files. Please reinstall "
            "the app and try again.";
  SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_INFORMATION,
                           "Theme Hospital files needed", message, nullptr);
  SDL_Quit();
}

}  // namespace

#endif

//! Program entry point
/*!
    Prepares a Lua state for, and catches errors from, lua_init(). By
    executing in Lua mode as soon as possible, errors can be nicely caught
    sooner, hence this function does as little as possible and leaves the rest
    for lua_init().
*/
int main(int argc, char** argv) {
  struct compile_time_lua_check {
    // Lua 5.1, not 5.0, is required
    int lua_5_point_1_required[LUA_VERSION_NUM >= 501 ? 1 : -1];

    // Lua numbers must be doubles so that the mantissa has at least
    // 32 bits (floats only have 24 bits)
    int number_is_double[types_equal<lua_Number, double>::result];
  };

#ifdef CORSIXTH_IOS
  const fs::path game_directory = prepare_ios_game_directory();
  if (game_directory.empty() || !has_theme_hospital_data(game_directory)) {
    show_ios_data_instructions(!game_directory.empty());
    return 0;
  }

  // SDL exposes the readable application-bundle directory here. Making it the
  // working directory allows the existing resource loader to find
  // CorsixTH.lua and the Lua/Bitmap/Campaigns/Levels directories unchanged.
  if (char* base_path = SDL_GetBasePath(); base_path != nullptr) {
    chdir(base_path);
    SDL_free(base_path);
  }

  // iOS has no windowed mode. Touch events should act as the game's primary
  // mouse while a connected Bluetooth/USB mouse remains a real mouse.
  setenv("CORSIXTH_IOS", "1", 1);
  SDL_SetHint(SDL_HINT_ORIENTATIONS, "LandscapeLeft LandscapeRight");
  SDL_SetHint(SDL_HINT_TOUCH_MOUSE_EVENTS, "1");
  SDL_SetHint(SDL_HINT_MOUSE_TOUCH_EVENTS, "0");
  SDL_SetHint(SDL_HINT_IOS_HIDE_HOME_INDICATOR, "2");
#endif

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
#ifdef WITH_TRACY
    tracy::LuaRegister(L.get());
#endif
#ifdef TRACY_ENABLE
    lua_sethook(L.get(), l_tracy_hook, LUA_MASKCALL | LUA_MASKRET, 0);
#endif
    lua_atpanic(L.get(), lua_panic);
    luaL_openlibs(L.get());
    lua_settop(L.get(), 0);
    lua_pushcfunction(L.get(), lua_stacktrace);
    lua_pushcfunction(L.get(), lua_init);

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
    mainloop(L.get());

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
