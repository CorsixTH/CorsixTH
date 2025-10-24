/*
Copyright (c) 2019,2025 Stephen "TheCycoONE" Baker

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

#include <stdexcept>
#include <string_view>

#include "iso_fs.h"
#include "lua.hpp"
#include "th_lua.h"
#include "th_lua_internal.h"

namespace {

/**
 * Lua binding to construct a new iso_filesystem object.
 *
 * Expects the lua stack to contain:
 *   -# metatable for iso_fs
 *   -# path to .iso file
 *   -# (optional) path separator, defaults to '/'
 *
 * Returns on the lua stack:
 *   -# userdata (iso_filesystem) or nil on failure
 *   -# string (path) or nil on failure
 *   -# error message if the first return value is nil
 *
 * @param L Lua stack
 * @return Number of return values
 */
int l_isofs_new(lua_State* L) {
  const char* path = luaL_checkstring(L, 2);
  std::string_view sep = luaL_optstring(L, 3, "/");
  if (sep.length() != 1) {
    luaL_argerror(L, 3, "Path separator must be a single character");
  }

  try {
    luaT_stdnew<iso_filesystem>(L, luaT_environindex, true, path, sep.at(0));
  } catch (std::runtime_error& e) {
    lua_pushnil(L);
    lua_pushnil(L);
    lua_pushfstring(L, "%s", e.what());
    return 3;
  }

  // L
  // 1 - table (metatable)
  // 2 - path
  // 3 - separator
  // 4 - userdata (iso_filesystem)

  lua_pushvalue(L, 2);
  luaT_setenvfield(L, 4, "string");
  lua_pushvalue(L, 2);
  return 2;
}

int l_isofs_is_valid_root(lua_State* L) {
  // Static method so we don't need an instance
  try {
    iso_filesystem fs(luaL_checkstring(L, 1));
    lua_pushboolean(L, true);
  } catch (std::runtime_error&) {
    lua_pushboolean(L, false);
  }
  return 1;
}

int l_isofs_file_exists(lua_State* L) {
  iso_filesystem* pSelf = luaT_testuserdata<iso_filesystem>(L);
  const char* sFilename = luaL_checkstring(L, 2);
  iso_filesystem::file_handle iFile = pSelf->find_file(sFilename);
  if (!iso_filesystem::is_handle_good(iFile)) {
    lua_pushnil(L);
    lua_pushfstring(L, "Could not find \'%s\' in .iso image", sFilename);
    return 2;
  }
  lua_pushboolean(L, true);
  return 1;
}

int l_isofs_file_size(lua_State* L) {
  iso_filesystem* pSelf = luaT_testuserdata<iso_filesystem>(L);
  const char* sFilename = luaL_checkstring(L, 2);
  iso_filesystem::file_handle iFile = pSelf->find_file(sFilename);
  if (!iso_filesystem::is_handle_good(iFile)) {
    lua_pushnil(L);
    lua_pushfstring(L, "Could not find \'%s\' in .iso image", sFilename);
    return 2;
  }
  lua_pushinteger(L, pSelf->get_file_size(iFile));
  return 1;
}

//! Get the start and end bytes of a given file.
/*!
    Called on an iso_filesystem, passing in a filename. If the file exists in
    the iso then the byte position of the start of the file inclusive and the
    end of the file exclusive is returned to the caller.

    If the file is not found then an error is passed as the third return value.

    \param L The Lua State
*/
int l_isofs_file_offsets(lua_State* L) {
  iso_filesystem* pSelf = luaT_testuserdata<iso_filesystem>(L);
  const char* sFilename = luaL_checkstring(L, 2);
  iso_filesystem::file_handle iFile = pSelf->find_file(sFilename);
  if (!iso_filesystem::is_handle_good(iFile)) {
    lua_pushnil(L);
    lua_pushnil(L);
    lua_pushfstring(L, "Could not find \'%s\' in .iso image", sFilename);
    return 3;
  }
  uint32_t start = pSelf->get_file_start(iFile);
  lua_pushinteger(L, start);
  lua_pushinteger(L, start + pSelf->get_file_size(iFile));
  return 2;
}

int l_isofs_read_contents(lua_State* L) {
  iso_filesystem* pSelf = luaT_testuserdata<iso_filesystem>(L);
  const char* sFilename = luaL_checkstring(L, 2);
  iso_filesystem::file_handle iFile = pSelf->find_file(sFilename);
  if (!iso_filesystem::is_handle_good(iFile)) {
    lua_pushnil(L);
    lua_pushfstring(L, "Could not find \'%s\' in .iso image", sFilename);
    return 2;
  }
  void* pBuffer = lua_newuserdata(L, pSelf->get_file_size(iFile));
  if (!pSelf->get_file_data(iFile, reinterpret_cast<uint8_t*>(pBuffer))) {
    lua_pushnil(L);
    lua_pushlstring(L, pSelf->get_error().data(), pSelf->get_error().size());
    return 2;
  }
  lua_pushlstring(L, reinterpret_cast<char*>(pBuffer),
                  pSelf->get_file_size(iFile));
  return 1;
}

void l_isofs_list_files_callback(void* p, const char* name, const char* path) {
  lua_State* L = reinterpret_cast<lua_State*>(p);
  lua_pushstring(L, name);
  lua_pushstring(L, path);
  lua_settable(L, 3);
}

int l_isofs_list_files(lua_State* L) {
  iso_filesystem* pSelf = luaT_testuserdata<iso_filesystem>(L);
  const char* sPath = luaL_checkstring(L, 2);
  lua_settop(L, 2);
  lua_newtable(L);
  pSelf->visit_directory_files(sPath, l_isofs_list_files_callback, L);
  return 1;
}

}  // namespace

void lua_register_iso_fs(const lua_register_state* pState) {
  lua_class_binding<iso_filesystem> lcb(pState, "iso_fs", l_isofs_new,
                                        lua_metatable::iso_fs);
  lcb.add_function(l_isofs_file_exists, "fileExists");
  lcb.add_function(l_isofs_file_size, "fileSize");
  lcb.add_function(l_isofs_file_offsets, "fileOffsets");
  lcb.add_function(l_isofs_read_contents, "readContents");
  lcb.add_function(l_isofs_list_files, "listFiles");
  lcb.add_function(l_isofs_is_valid_root, "isValidRoot");
}
