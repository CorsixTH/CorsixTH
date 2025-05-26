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
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <string>

#include "lua.hpp"
#include "lua_rnc.h"
#include "lua_sdl.h"
#include "persist_lua.h"
#include "th_lua.h"

#ifdef CORSIX_TH_SEARCH_LOCAL_DATADIRS
#include "../../libs/whereami/whereami.h"
#endif

// Config file checking
#ifndef CORSIX_TH_USE_PACK_PRAGMAS
#error "config.h is out of date - please rerun CMake"
#endif
// End of config file checking

extern "C" {
int luaopen_random(lua_State* L);
#ifdef CORSIX_TH_LINK_LUA_MODULES
int luaopen_lfs(lua_State* L);
int luaopen_lpeg(lua_State* L);
#endif
int luaopen_lfs(lua_State* L);
int luaopen_lpeg(lua_State* L);
}

namespace {

// relace me with C++17 std::filesystem::exists
inline bool file_exists(const char* f) {
  std::ifstream file(f);
  return file.is_open();
}

inline bool file_exists(const std::string& f) { return file_exists(f.c_str()); }

std::string search_script_file(lua_State* L) {
  // 1. Check for --interpreter
  int iNArgs = lua_gettop(L);
  for (int i = 1; i <= iNArgs; ++i) {
    if (lua_type(L, i) == LUA_TSTRING) {
      size_t iLen;
      const char* sCmd = lua_tolstring(L, i, &iLen);
      if (iLen > 14 && std::memcmp(sCmd, "--interpreter=", 14) == 0)
        return sCmd + 14;
    }
  }

#ifdef CORSIX_TH_SEARCH_LOCAL_DATADIRS
  // 2. Find CorsixTH.lua in working dir and program dir
  static constexpr std::array<const char*, 5> asSearchDirs{
      "./",
      "CorsixTH/",
      "Contents/Resources/",
      "../Resources/",
      "../share/corsix-th/",
  };
  std::string strProgramDir = "";
  {
    int iProgramPathLength = wai_getExecutablePath(nullptr, 0, nullptr);
    if (iProgramPathLength != 0) {
      char* sProgramDir = new char[iProgramPathLength + 1];
      int iProgramDirLength;
      int iProgramPathLengthReal = wai_getExecutablePath(
          sProgramDir, iProgramPathLength, &iProgramDirLength);
      if (iProgramPathLengthReal != iProgramPathLength ||
          iProgramPathLength <= iProgramDirLength) {
        if (iProgramPathLengthReal != iProgramPathLength)
          std::fprintf(stderr,
                       "Path length of CorsixTH binary changed?!?! "
                       "Old: %d, new: %d.\n",
                       iProgramPathLength, iProgramPathLengthReal);
        else
          std::fprintf(stderr,
                       "Path to CorsixTH looks like a directory?!?! "
                       "Path is: '%s'.\n",
                       sProgramDir);
        std::fprintf(stderr, "Please report this incident!\n");
        std::fflush(stderr);
        exit(255);
      }
      // replace me with C++17 std::filesystem::path::preferred_separator
      sProgramDir[iProgramDirLength] = '/';
      sProgramDir[iProgramDirLength + 1] = '\0';
      strProgramDir = sProgramDir;
      delete[] sProgramDir;
    }
  }
  for (auto sSearchDir : asSearchDirs) {
    std::string strPathInWorkingDir =
        std::string(sSearchDir) + CORSIX_TH_INTERPRETER_NAME;
    if (file_exists(strPathInWorkingDir)) return strPathInWorkingDir;
    if (!strProgramDir.empty()) {
      std::string strPathInProgramDir = strProgramDir + strPathInWorkingDir;
      if (file_exists(strPathInProgramDir)) return strPathInProgramDir;
    }
  }
#endif

  // 3. Check CORSIX_TH_INTERPRETER_PATH
  if (file_exists(CORSIX_TH_INTERPRETER_PATH))
    return CORSIX_TH_INTERPRETER_PATH;

  return "";
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
  preload_lua_package(L, "lfs", luaopen_lfs);
  preload_lua_package(L, "lpeg", luaopen_lpeg);

  preload_lua_package(L, "rnc", luaopen_rnc);
  preload_lua_package(L, "TH", luaopen_th);
  preload_lua_package(L, "persist", luaopen_persist);
  preload_lua_package(L, "sdl", luaopen_sdl);

#ifdef CORSIX_TH_LINK_LUA_MODULES
  preload_lua_package(L, "lfs", luaopen_lfs);
  preload_lua_package(L, "lpeg", luaopen_lpeg);
#endif

  // require "debug" (Harmless in Lua 5.1, useful in 5.2 for compatibility)
  luaT_execute(L, "require \"debug\"");

  auto scriptFilePath = search_script_file(L);
  if (scriptFilePath.empty()) {
    std::fprintf(stderr,
                 "CorsixTH cannot find CorsixTH.lua. If you want use a custom "
                 "location, specify it by --interpreter=FILE\n");
    std::fflush(stderr);
    exit(1);
  }

  lua_getglobal(L, "assert");
  lua_getglobal(L, "loadfile");
  lua_pushstring(L, scriptFilePath.c_str());

  lua_call(L, 1, 2);
  lua_call(L, 2, 1);
  lua_insert(L, 1);
  return lua_gettop(L);
}

int lua_main(lua_State* L) {
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
