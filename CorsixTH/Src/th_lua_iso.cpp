/*
Copyright (c) 2019 Stephen "TheCycoONE" Baker

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

#include <cstdio>

#include "iso_fs.h"
#include "th_lua_internal.h"

namespace {

int l_isofs_new(lua_State* L) {
  luaT_stdnew<iso_filesystem>(L, luaT_environindex, true);
  return 1;
}

int l_isofs_set_path_separator(lua_State* L) {
  iso_filesystem* pSelf = luaT_testuserdata<iso_filesystem>(L);
  pSelf->set_path_separator(luaL_checkstring(L, 2)[0]);
  lua_settop(L, 1);
  return 1;
}

int l_isofs_set_root(lua_State* L) {
  iso_filesystem* pSelf = luaT_testuserdata<iso_filesystem>(L);
  const char* path = luaL_checkstring(L, 2);
  if (pSelf->initialise(path)) {
    lua_pushvalue(L, 2);
    luaT_setenvfield(L, 1, "file");
    lua_settop(L, 1);
    return 1;
  } else {
    lua_pushnil(L);
    lua_pushstring(L, pSelf->get_error());
    return 2;
  }
}

int l_isofs_file_exists(lua_State* L) {
  iso_filesystem* pSelf = luaT_testuserdata<iso_filesystem>(L);
  const char* sFilename = luaL_checkstring(L, 2);
  iso_filesystem::file_handle iFile = pSelf->find_file(sFilename);
  if (!iso_filesystem::isHandleGood(iFile)) {
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
  if (!iso_filesystem::isHandleGood(iFile)) {
    lua_pushnil(L);
    lua_pushfstring(L, "Could not find \'%s\' in .iso image", sFilename);
    return 2;
  }
  lua_pushinteger(L, pSelf->get_file_size(iFile));
  return 1;
}

int l_isofs_read_contents(lua_State* L) {
  iso_filesystem* pSelf = luaT_testuserdata<iso_filesystem>(L);
  const char* sFilename = luaL_checkstring(L, 2);
  iso_filesystem::file_handle iFile = pSelf->find_file(sFilename);
  if (!iso_filesystem::isHandleGood(iFile)) {
    lua_pushnil(L);
    lua_pushfstring(L, "Could not find \'%s\' in .iso image", sFilename);
    return 2;
  }
  void* pBuffer = lua_newuserdata(L, pSelf->get_file_size(iFile));
  if (!pSelf->get_file_data(iFile, reinterpret_cast<uint8_t*>(pBuffer))) {
    lua_pushnil(L);
    lua_pushstring(L, pSelf->get_error());
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
  lcb.add_function(l_isofs_set_path_separator, "setPathSeparator");
  lcb.add_function(l_isofs_set_root, "setRoot");
  lcb.add_function(l_isofs_file_exists, "fileExists");
  lcb.add_function(l_isofs_file_size, "fileSize");
  lcb.add_function(l_isofs_read_contents, "readContents");
  lcb.add_function(l_isofs_list_files, "listFiles");
}
