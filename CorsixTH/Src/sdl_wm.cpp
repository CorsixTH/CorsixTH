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
#include "th_lua.h"
#include "lua_sdl.h"
#ifdef CORSIX_TH_USE_WIN32_SDK
#include <windows.h>
#include <SDL_syswm.h>
#include "../resource.h"
#endif

static int l_set_icon_win32(lua_State *L)
{
    // Hack to set the window icon from the EXE resource under Windows.
    // Does nothing (and returns false) on other platforms.

    lua_pushboolean(L, 0);
#if 0
    // XXX: Doesn't work any more, since window is inside renderer. Move to renderer.
    SDL_SysWMinfo oWindowInfo;
    oWindowInfo.version.major = SDL_MAJOR_VERSION;
    oWindowInfo.version.minor = SDL_MINOR_VERSION;
    oWindowInfo.version.patch = SDL_PATCHLEVEL;
    if(SDL_GetWindowWMInfo(window,&oWindowInfo) == 1)
    {
        HWND hWindow = oWindowInfo.info.win.window;
        HICON hIcon = LoadIcon((HINSTANCE)GetModuleHandle(nullptr), (LPCTSTR)IDI_CORSIXTH);
        SetClassLongPtr(hWindow, GCLP_HICON, (LONG_PTR)hIcon);
        SetClassLongPtr(hWindow, GCLP_HICONSM, (LONG_PTR)hIcon);
        lua_pushboolean(L, 1);
    }
#endif
    return 1;
}

static int l_show_cursor(lua_State *L)
{
    SDL_ShowCursor(lua_toboolean(L, 1));
    return 0;
}

static const struct luaL_Reg sdl_wmlib[] = {
    {"setIconWin32", l_set_icon_win32},
    {"showCursor", l_show_cursor},
    {nullptr, nullptr}
};

int luaopen_sdl_wm(lua_State *L)
{
    lua_newtable(L);
    luaT_setfuncs(L, sdl_wmlib);

    return 1;
}
