/*
Copyright (c) 2010 Peter "Corsix" Cawley
Copyright (c) 2014 Stephen E. Baker

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

#include "lua.hpp"
#include "th_lua.h"
#include "th_lua_internal.h"
#ifdef CORSIX_TH_USE_WIN32_SDK
#include <windows.h>
#endif

class lfs_ext {};

namespace {

int l_lfs_ext_new(lua_State* L) {
  luaT_stdnew<lfs_ext>(L, luaT_environindex, true);
  return 1;
}

#ifdef _WIN32
#ifdef CORSIX_TH_USE_WIN32_SDK
int l_volume_list(lua_State* L) {
  /* Windows, using the Win32 API. */
  DWORD iDriveMask = GetLogicalDrives();
  int iNDrives = 0;
  char cDrive;
  lua_settop(L, 0);
  lua_newtable(L);
  for (cDrive = 'A'; cDrive <= 'Z'; ++cDrive) {
    if (iDriveMask & (1 << (cDrive - 'A'))) {
      char sName[4] = {cDrive, ':', '\\', 0};
      if (GetDriveTypeA(sName) > DRIVE_NO_ROOT_DIR) {
        lua_pushlstring(L, sName, 2);
        lua_rawseti(L, 1, ++iNDrives);
      }
    }
  }
  return 1;
}
#else
int l_volume_list(lua_State* L) {
  /* Windows, without the Win32 API. */
  int iNDrives = 0;
  char cDrive;
  lua_settop(L, 0);
  lua_newtable(L);
  lua_getfield(L, luaT_upvalueindex(1), "attributes");
  for (cDrive = 'A'; cDrive <= 'Z'; ++cDrive) {
    lua_pushvalue(L, 2);
    lua_pushfstring(L, "%c:\\", cDrive);
    lua_pushliteral(L, "mode");
    lua_call(L, 2, 1);
    if (lua_toboolean(L, 3) != 0) {
      lua_pushfstring(L, "%c:", cDrive);
      lua_rawseti(L, 1, ++iNDrives);
    }
    lua_pop(L, 1);
  }
  return 1;
}
#endif
#else
int l_volume_list(lua_State* L) {
  /* Non-Windows systems. Assume that / is the root of the filesystem. */
  lua_settop(L, 0);
  lua_newtable(L);
  lua_pushliteral(L, "/");
  lua_rawseti(L, 1, 1);
  return 1;
}
#endif

}  // namespace

void lua_register_lfs_ext(const lua_register_state* pState) {
  lua_class_binding<lfs_ext> lcb(pState, "lfsExt", l_lfs_ext_new,
                                 lua_metatable::lfs_ext);
  lcb.add_function(l_volume_list, "volumes");
}
