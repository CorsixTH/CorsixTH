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
#include <SDL.h>
#include <string.h>
#ifndef _MSC_VER
#define stricmp strcasecmp
#else
#pragma warning(disable: 4996) // Deprecated CRT
#endif

struct l_surface_t
{
    SDL_Surface *surface;
    bool owned;
};

static int l_push_error(lua_State *L)
{
    lua_pushnil(L);
    lua_pushstring(L, SDL_GetError());
    return 2;
}

static void l_push_surface(lua_State *L, SDL_Surface *surface, bool owned = true)
{
    l_surface_t *s = luaT_new(L, l_surface_t);
    s->surface = surface;
    s->owned = owned;

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
        if(lua_equal(L, -1, LUA_ENVIRONINDEX) && s->surface != NULL)
        {
            lua_pop(L, 1);
            return s->surface;
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
    l_push_surface(L, surface, false);
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
    if(s->owned && s->surface != NULL)
    {
        SDL_FreeSurface(s->surface);
        s->surface = NULL;
        s->owned = false;
    }
    return 0;
}

/**
  @function sdl.video.ensureHardwareSurface
  @arguments SDL_Surface surface
  @return surface
  @return nil, error_string
*/
static int l_ensure_hw_surface(lua_State *L)
{
    l_surface_t *surf = l_check_surface_raw(L, 1);
    lua_settop(L, 1);
    if(surf->surface == NULL)
    {
        luaL_argerror(L, 1, "Expected SDL Surface");
    }
    if(surf->surface->flags & SDL_HWSURFACE)
    {
        // Already a HW surface
        return 1;
    }
    SDL_Surface *surface = SDL_CreateRGBSurface(
        SDL_HWSURFACE | (surf->surface->flags & (SDL_SRCCOLORKEY | SDL_SRCALPHA)),
        surf->surface->w, surf->surface->h, surf->surface->format->BitsPerPixel,
        surf->surface->format->Rmask, surf->surface->format->Gmask,
        surf->surface->format->Bmask, surf->surface->format->Amask);
    if(surface == NULL)
    {
        return l_push_error(L);
    }
    if((surface->flags & SDL_HWSURFACE) != SDL_HWSURFACE)
    {
        SDL_FreeSurface(surface);
        lua_pushnil(L);
        lua_pushliteral(L, "SDL could not create hardware surface");
        return 2;
    }
    if(surf->surface->format->BytesPerPixel == 1)
    {
        SDL_SetPalette(surface, SDL_LOGPAL | SDL_PHYSPAL, surf->surface->format->palette->colors,
            0, surf->surface->format->palette->ncolors);
    }
    if(surf->surface->flags & SDL_SRCCOLORKEY)
    {
        SDL_SetColorKey(surface, SDL_SRCCOLORKEY, surf->surface->format->colorkey);
    }
    if(SDL_BlitSurface(surf->surface, NULL, surface, NULL) != 0)
    {
        SDL_FreeSurface(surface);
        return l_push_error(L);
    }
    if(surf->owned)
    {
        SDL_FreeSurface(surf->surface);
    }
    surf->surface = surface;
    return 1;
}

/**
  @function sdl.video.endFrame
  @arguments SDL_Surface surface
  @return bool
*/
static int l_flip(lua_State *L)
{
    if(SDL_Flip(l_check_surface(L, 1)) == 0)
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

static int l_nop(lua_State *L)
{
    return 0;
}

static const struct luaL_reg sdl_videolib[] = {
    {"ensureHardwareSurface", l_ensure_hw_surface},
    {"setMode", l_set_mode},
    {"fillBlack", l_draw_black_rect},
    {"startFrame", l_nop},
    {"endFrame", l_flip},
    {"nonOverlapping", l_nop},
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
