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
#include <stdexcept>
#include <string>

#ifdef WITH_UPDATE_CHECK
#include <curl/curl.h>
#endif

#include "bootstrap.h"
#include "lua.hpp"
#include "th.h"
#include "th_lua.h"
#include "th_lua_internal.h"

const char* update_check_url =
    "https://corsixth.com/CorsixTH/check-for-updates";

void lua_register_anims(const lua_register_state* pState);
void lua_register_gfx(const lua_register_state* pState);
void lua_register_map(const lua_register_state* pState);
void lua_register_sound(const lua_register_state* pState);
void lua_register_movie(const lua_register_state* pState);
void lua_register_strings(const lua_register_state* pState);
void lua_register_ui(const lua_register_state* pState);
void lua_register_lfs_ext(const lua_register_state* pState);
void lua_register_iso_fs(const lua_register_state* pState);
void lua_register_midi(const lua_register_state* pState);

//! Set a field on the environment table of an object
void luaT_setenvfield(lua_State* L, int index, const char* k) {
  lua_getfenv(L, index);
  lua_pushstring(L, k);
  lua_pushvalue(L, -3);
  lua_settable(L, -3);
  lua_pop(L, 2);
}

//! Get a field from the environment table of an object
void luaT_getenvfield(lua_State* L, int index, const char* k) {
  lua_getfenv(L, index);
  lua_getfield(L, -1, k);
  lua_replace(L, -2);
}

#if LUA_VERSION_NUM >= 502
void luaT_getfenv52(lua_State* L, int iIndex) {
  int iType = lua_type(L, iIndex);
  switch (iType) {
    case LUA_TUSERDATA:
      lua_getuservalue(L, iIndex);
      break;
    case LUA_TFUNCTION:
      if (lua_iscfunction(L, iIndex)) {
        // Our convention: upvalue at #1 is environment
        if (lua_getupvalue(L, iIndex, 1) == nullptr) lua_pushglobaltable(L);
      } else {
        // Language convention: upvalue called _ENV is environment
        const char* sUpName = nullptr;
        for (int i = 1; (sUpName = lua_getupvalue(L, iIndex, i)); ++i) {
          if (std::strcmp(sUpName, "_ENV") == 0)
            return;
          else
            lua_pop(L, 1);
        }
        lua_pushglobaltable(L);
      }
      break;
    default:
      luaL_error(L, "Unable to get environment of a %s in 5.2",
                 lua_typename(L, iType));
      break;
  }
}

int luaT_setfenv52(lua_State* L, int iIndex) {
  int iType = lua_type(L, iIndex);
  switch (iType) {
    case LUA_TUSERDATA:
      lua_setuservalue(L, iIndex);
      return 1;
    case LUA_TFUNCTION:
      if (lua_iscfunction(L, iIndex)) {
        // Our convention: upvalue at #1 is environment
        if (lua_setupvalue(L, iIndex, 1) == nullptr) {
          lua_pop(L, 1);
          return 0;
        }
        return 1;
      } else {
        // Language convention: upvalue called _ENV is environment,
        // which might be shared with other functions.
        const char* sUpName = nullptr;
        for (int i = 1; (sUpName = lua_getupvalue(L, iIndex, i)); ++i) {
          lua_pop(L, 1);  // lua_getupvalue puts the value on the
                          // stack, but we just want to replace it
          if (std::strcmp(sUpName, "_ENV") == 0) {
            luaL_loadstring(L,
                            "local upv = ... return function() return upv "
                            "end");
            lua_insert(L, -2);
            lua_call(L, 1, 1);
            lua_upvaluejoin(L, iIndex, i, -1, 1);
            lua_pop(L, 1);
            return 1;
          }
        }
        lua_pop(L, 1);
        return 0;
      }
    default:
      return 0;
  }
}
#endif

//! Push a C closure as a callable table
void luaT_pushcclosuretable(lua_State* L, lua_CFunction fn, int n) {
  luaT_pushcclosure(L, fn, n);   // .. fn <top
  lua_createtable(L, 0, 1);      // .. fn mt <top
  lua_pushliteral(L, "__call");  // .. fn mt __call <top
  lua_pushvalue(L, -3);          // .. fn mt __call fn <top
  lua_settable(L, -3);           // .. fn mt <top
  lua_newtable(L);               // .. fn mt t <top
  lua_replace(L, -3);            // .. t mt <top
  lua_setmetatable(L, -2);       // .. t <top
}

//! Check for a string or userdata
const uint8_t* luaT_checkfile(lua_State* L, int idx, size_t* pDataLen) {
  const uint8_t* pData;
  size_t iLength;
  if (lua_type(L, idx) == LUA_TUSERDATA) {
    pData = reinterpret_cast<const uint8_t*>(lua_touserdata(L, idx));
    iLength = lua_objlen(L, idx);
  } else {
    pData =
        reinterpret_cast<const uint8_t*>(luaL_checklstring(L, idx, &iLength));
  }
  if (pDataLen != nullptr) *pDataLen = iLength;
  return pData;
}

namespace {

#ifdef WITH_UPDATE_CHECK
// https://everything.curl.dev/transfers/callbacks/write.html
size_t version_info_write_callback(char* ptr, size_t size, size_t nmemb,
                                   void* userdata) {
  size_t realsize = size * nmemb;
  std::string* resp = static_cast<std::string*>(userdata);
  resp->append(ptr, realsize);
  return realsize;
}
#endif

int l_fetch_latest_version_info(lua_State* L) {
#ifdef WITH_UPDATE_CHECK
  CURL* curl = curl_easy_init();

  if (curl == nullptr) {
    lua_pushnil(L);
    lua_pushliteral(L, "Could not initialize curl");
    return 2;
  }

  curl_easy_setopt(curl, CURLOPT_URL, update_check_url);
  curl_easy_setopt(curl, CURLOPT_HTTPGET, 1);
  curl_easy_setopt(curl, CURLOPT_TIMEOUT, 5L);
  curl_easy_setopt(curl, CURLOPT_MAXFILESIZE, 4096L);

  std::string response;
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, version_info_write_callback);
  curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void*)&response);
  CURLcode res = curl_easy_perform(curl);

  curl_easy_cleanup(curl);

  if (res != CURLE_OK) {
    lua_pushnil(L);
    lua_pushstring(L, curl_easy_strerror(res));
    return 2;
  }

  lua_pushstring(L, response.c_str());
  lua_pushnil(L);
  return 2;
#else
  lua_pushnil(L);
  lua_pushliteral(L, "Update check was not enabled at compile time.");
  return 2;
#endif
}

int l_load_strings(lua_State* L) {
  size_t iDataLength;
  const uint8_t* pData = luaT_checkfile(L, 1, &iDataLength);

  try {
    th_string_list oStrings(pData, iDataLength);
    lua_settop(L, 0);
    lua_createtable(L, static_cast<int>(oStrings.get_section_count()), 0);
    for (size_t iSec = 0; iSec < oStrings.get_section_count(); ++iSec) {
      size_t iCount = oStrings.get_section_size(iSec);
      lua_createtable(L, static_cast<int>(iCount), 0);
      for (size_t iStr = 0; iStr < iCount; ++iStr) {
        lua_pushstring(L, oStrings.get_string(iSec, iStr));
        lua_rawseti(L, 2, static_cast<int>(iStr + 1));
      }
      lua_rawseti(L, 1, static_cast<int>(iSec + 1));
    }
  } catch (std::invalid_argument&) {
    lua_pushboolean(L, 0);
  }
  return 1;
}

int get_api_version() {
#include "../Lua/api_version.lua"  // IWYU pragma: keep
}

int l_get_compile_options(lua_State* L) {
  lua_settop(L, 0);
  lua_newtable(L);

  // Report architecture
  lua_pushliteral(L, CORSIX_TH_ARCH);
  lua_setfield(L, -2, "arch");

#ifdef WITH_UPDATE_CHECK
  lua_pushboolean(L, 1);
#else
  lua_pushboolean(L, 0);
#endif
  lua_setfield(L, -2, "update_check");

#ifdef CORSIX_TH_USE_FFMPEG
  lua_pushboolean(L, 1);
#else
  lua_pushboolean(L, 0);
#endif
  lua_setfield(L, -2, "movies");

#ifdef WITH_MIDI_DEVICE
  lua_pushboolean(L, 1);
#else
  lua_pushboolean(L, 0);
#endif
  lua_setfield(L, -2, "midi_device");

  lua_getfield(L, LUA_REGISTRYINDEX, "_LOADED");
  lua_getfield(L, -1, "jit");
  if (lua_type(L, -1) == LUA_TNIL) {
    lua_replace(L, -2);
  } else {
    lua_getfield(L, -1, "version");
    lua_replace(L, -3);
    lua_pop(L, 1);
  }
  lua_setfield(L, -2, "jit");

  // Report operating system
  lua_pushliteral(L, CORSIX_TH_OS);
  lua_setfield(L, -2, "os");

  lua_pushinteger(L, get_api_version());
  lua_setfield(L, -2, "api_version");

#ifdef CORSIX_TH_FONT
  // Set default value of font file
  lua_pushliteral(L, CORSIX_TH_FONT);
  lua_setfield(L, -2, "font");
#endif

  return 1;
}

}  // namespace

void luaT_setclosure(const lua_register_state* pState, lua_CFunction fn,
                     int iUps) {
  luaT_pushcclosure(pState->L, fn, iUps);
}

int luaopen_th(lua_State* L) {
  lua_settop(L, 0);
  lua_checkstack(L, 16 + static_cast<int>(lua_metatable::count));

  lua_register_state oState;
  const lua_register_state* pState = &oState;
  oState.L = L;
  for (int i = 0; i < static_cast<int>(lua_metatable::count); ++i) {
    lua_createtable(L, 0, 5);
    oState.metatables[i] = lua_gettop(L);
  }
  lua_createtable(L, 0, lua_gettop(L));
  oState.main_table = lua_gettop(L);
  oState.top = lua_gettop(L);

  // Misc. functions
  lua_settop(L, oState.top);
  add_lua_function(pState, l_load_strings, "LoadStrings");
  add_lua_function(pState, l_get_compile_options, "GetCompileOptions");
  add_lua_function(pState, bootstrap_lua_resources, "GetBuiltinFont");
  add_lua_function(pState, l_fetch_latest_version_info,
                   "FetchLatestVersionInfo");

  // Classes
  lua_register_map(pState);
  lua_register_gfx(pState);
  lua_register_anims(pState);
  lua_register_sound(pState);
  lua_register_movie(pState);
  lua_register_strings(pState);
  lua_register_ui(pState);
  lua_register_lfs_ext(pState);
  lua_register_iso_fs(pState);
  lua_register_midi(pState);

  lua_settop(L, oState.main_table);
  return 1;
}

void luaT_execute_loadstring(lua_State* L, const char* sLuaString) {
  static const int iRegistryCacheIndex = 7;
  lua_rawgeti(L, LUA_REGISTRYINDEX, iRegistryCacheIndex);
  if (lua_isnil(L, -1)) {
    // Cache not yet created - create it.
    lua_pop(L, 1);
    lua_getglobal(L, "setmetatable");
    if (lua_isnil(L, -1)) {
      // Base library not yet loaded - fallback to simple
      // uncached loadstring
      lua_pop(L, 1);
      if (luaL_loadstring(L, sLuaString)) lua_error(L);
    }
    lua_pop(L, 1);
#if LUA_VERSION_NUM >= 502
    luaL_loadstring(L,
                    "local assert, load = assert, load\n"
                    "return setmetatable({}, {__mode = [[v]], \n"
                    "__index = function(t, k)\n"
                    "local v = assert(load(k))\n"
                    "t[k] = v\n"
                    "return v\n"
                    "end})");
#else
    luaL_loadstring(L,
                    "local assert, loadstring = assert, loadstring\n"
                    "return setmetatable({}, {__mode = [[v]], \n"
                    "__index = function(t, k)\n"
                    "local v = assert(loadstring(k))\n"
                    "t[k] = v\n"
                    "return v\n"
                    "end})");
#endif
    lua_call(L, 0, 1);
    lua_pushvalue(L, -1);
    lua_rawseti(L, LUA_REGISTRYINDEX, iRegistryCacheIndex);
  }
  lua_getfield(L, -1, sLuaString);
  lua_replace(L, -2);
}

void luaT_execute(lua_State* L, const char* sLuaString) {
  luaT_execute_loadstring(L, sLuaString);
  lua_call(L, 0, LUA_MULTRET);
}

void preload_lua_package(lua_State* L, const char* name, lua_CFunction fn) {
  luaT_execute(
      L, std::string("package.preload.").append(name).append(" = ...").c_str(),
      fn);
}

void luaT_push(lua_State* L, lua_CFunction f) { luaT_pushcfunction(L, f); }

void luaT_push(lua_State* L, int i) { lua_pushinteger(L, (lua_Integer)i); }

void luaT_push(lua_State* L, const char* s) { lua_pushstring(L, s); }

void luaT_pushtablebool(lua_State* L, const char* k, bool v) {
  lua_pushstring(L, k);
  lua_pushboolean(L, v);
  lua_settable(L, -3);
}

void luaT_printvalue(lua_State* L, int idx) {
  int t = lua_type(L, idx);
  switch (t) {
    case LUA_TSTRING: /* strings */
      std::printf("string: '%s'\n", lua_tostring(L, idx));
      break;
    case LUA_TBOOLEAN: /* booleans */
      std::printf("boolean %s\n", lua_toboolean(L, idx) ? "true" : "false");
      break;
    case LUA_TNUMBER: /* numbers */
      std::printf("number: %g\n", lua_tonumber(L, idx));
      break;
    default: /* other values */
      std::printf("%s: %p\n", lua_typename(L, t), lua_topointer(L, idx));
      break;
  }
}

void luaT_printstack(lua_State* L) {
  int i;
  int top = lua_gettop(L);

  std::printf("total items in stack %d\n", top);

  for (i = 1; i <= top; i++) { /* repeat for each level */
    std::printf("(%d) ", i);
    luaT_printvalue(L, i);
  }
  std::printf("\n"); /* end the listing */
}

void luaT_printrawtable(lua_State* L, int idx) {
  /* table is in the stack at index 't' */
  lua_pushnil(L); /* first key */
  while (lua_next(L, idx) != 0) {
    /* uses 'key' (at index -2) and 'value' (at index -1) */
    std::printf("key: ");
    luaT_printvalue(L, -2);
    std::printf("value: ");
    luaT_printvalue(L, -1);
    /* removes 'value'; keeps 'key' for next iteration */
    lua_pop(L, 1);
  }
}
