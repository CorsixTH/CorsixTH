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
#ifdef CORSIX_TH_USE_SDL_RENDERER
#include "th_lua.h"
#include "th_gfx_sdl.h"
#include <SDL.h>
#include <string.h>
#ifndef _MSC_VER
#define stricmp strcasecmp
#else
#pragma warning(disable: 4996) // Deprecated CRT
#endif

struct l_surface_t
{
    THRenderTarget* pTarget;
};

static int l_push_error(lua_State *L)
{
    lua_pushnil(L);
    lua_pushstring(L, SDL_GetError());
    return 2;
}

static void l_push_surface(lua_State *L, SDL_Surface *surface)
{
    l_surface_t *s = luaT_new(L, l_surface_t);
    s->pTarget = new THRenderTarget(surface);

    lua_pushvalue(L, LUA_ENVIRONINDEX);
    lua_setmetatable(L, -2);
}

static l_surface_t* l_check_surface_raw(lua_State *L, int idx)
{
    l_surface_t* s = (l_surface_t*)lua_touserdata(L, idx);
    if(s != NULL)
    {
        lua_getmetatable(L, idx);
        if(lua_equal(L, -1, LUA_ENVIRONINDEX))
        {
            lua_pop(L, 1);
            return s;
        }
    }
    lua_pop(L, 1);
    luaL_typerror(L, idx, "SDL Surface");
    return NULL; // To prevent compiler warnings
}

static SDL_Surface* l_check_surface(lua_State *L, int idx)
{
    l_surface_t* s = (l_surface_t*)lua_touserdata(L, idx);
    if(s != NULL)
    {
        lua_getmetatable(L, idx);
        if(lua_equal(L, -1, LUA_ENVIRONINDEX) && s->pTarget != NULL)
        {
            lua_pop(L, 1);
            return s->pTarget->getRawSurface();
        }
    }
    lua_pop(L, 1);
    luaL_typerror(L, idx, "SDL Surface");
    return NULL; // To prevent compiler warnings
}

/**
  @function sdl.video.setMode
  @arguments int width, int height [, int bpp [, "hardware"] [, "doublebuf"]
                 [, "fullscreen"]]
  @return SDL_Surface
  @return nil, error_string
*/
static int l_set_mode(lua_State *L)
{
    int width, height, bpp, i, count;
    Uint32 flags = 0;

    width = luaL_checkint(L, 1);
    height = luaL_checkint(L, 2);
    if(lua_type(L, 3) == LUA_TNUMBER)
    {
        bpp = luaL_checkint(L, 3);
        i = 4;
    }
    else
    {
        bpp = 0;
        i = 3;
    }
    count = lua_gettop(L);

    for(; i <= count; ++i)
    {
        const char* option = luaL_checkstring(L, i);
        if(*option == 0)
            continue;
        else if(stricmp(option, "hardware") == 0)
            flags |= SDL_HWSURFACE;
        else if(stricmp(option, "doublebuf") == 0)
            flags |= SDL_DOUBLEBUF;
        else if(stricmp(option, "fullscreen") == 0)
            flags |= SDL_FULLSCREEN;
    }

    SDL_Surface *surface = SDL_SetVideoMode(width, height, bpp, flags);
    if(surface == NULL)
    {
        return l_push_error(L);
    }
    l_push_surface(L, surface);
    return 1;
}

/**
  @function sdl.video.freeSurface
  @arguments SDL_Surface surface
  @return
*/
static int l_free(lua_State *L)
{
    l_surface_t *s = l_check_surface_raw(L, 1);
	delete s->pTarget;
    s->pTarget = NULL;
    return 0;
}

/**
  @function sdl.video.endFrame
  @arguments SDL_Surface surface
  @return bool
*/
static int l_flip(lua_State *L)
{
	THRenderTarget *pTarget = l_check_surface_raw(L, 1)->pTarget;
    if(pTarget && (pTarget->drawCursor(), SDL_Flip(pTarget->getRawSurface()) == 0))
    {
        lua_pushboolean(L, 1);
    }
    else
    {
        lua_pushboolean(L, 0);
    }
    return 1;
}

/**
  @function sdl.video.fillBlack
  @arguments SDL_Surface surface
  @return surface
*/
static int l_draw_black_rect(lua_State *L)
{
    SDL_Surface *s = l_check_surface(L, 1);
    SDL_FillRect(s, NULL, SDL_MapRGB(s->format, 0, 0, 0));
    lua_settop(L, 1);
    return 1;
}

static int l_save_bitmap(lua_State *L)
{
	SDL_Surface *s = l_check_surface(L, 1);
	SDL_SaveBMP(s, luaL_checkstring(L, 2));
	return 0;
}

static int l_map_rgb(lua_State *L)
{
	SDL_Surface *s = l_check_surface(L, 1);
	lua_pushnumber(L, (lua_Number)SDL_MapRGB(s->format,
		(Uint8)luaL_checkinteger(L, 2),
		(Uint8)luaL_checkinteger(L, 3),
		(Uint8)luaL_checkinteger(L, 4)));
	return 1;
}

static int l_fill_rect(lua_State *L)
{
	SDL_Surface *s = l_check_surface(L, 1);
	Uint32 iColour = (Uint32)luaL_checknumber(L, 2);
	SDL_Rect rcRect;
	rcRect.x = (Sint16)luaL_checkint(L, 3);
	rcRect.y = (Sint16)luaL_checkint(L, 4);
	rcRect.w = (Uint16)luaL_checkint(L, 5);
	rcRect.h = (Uint16)luaL_checkint(L, 6);
	SDL_FillRect(s, &rcRect, iColour);
	return 0;
}

static int l_nop(lua_State *L)
{
    return 0;
}

static const struct luaL_reg sdl_videolib[] = {
    {"setMode", l_set_mode},
    {"fillBlack", l_draw_black_rect},
    {"startFrame", l_nop},
    {"endFrame", l_flip},
    {"nonOverlapping", l_nop},
	{"mapRGB", l_map_rgb},
	{"drawRect", l_fill_rect},
	{"debugDumpBitmap", l_save_bitmap},
    {NULL, NULL}
};

int luaopen_sdl_video(lua_State *L)
{
    lua_settop(L, 0);
    lua_newtable(L);
    lua_pushvalue(L, 1);
    lua_replace(L, LUA_ENVIRONINDEX);

    lua_pushliteral(L, "Surface_meta");
    lua_pushvalue(L, 1);
    lua_settable(L, LUA_REGISTRYINDEX);

    lua_pushliteral(L, "__gc");
    lua_pushcfunction(L, l_free);
    lua_settable(L, -3);

    lua_newtable(L);
    lua_pushliteral(L, "__index");
    lua_pushvalue(L, -2);
    lua_settable(L, 1);
    luaL_register(L, NULL, sdl_videolib);

    return 1;
}

#endif // CORSIX_TH_USE_SDL_RENDERER
