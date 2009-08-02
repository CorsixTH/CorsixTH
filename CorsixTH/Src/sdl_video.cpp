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
  @function sdl.video.loadBitmap
  @arguments string filename
  @return SDL_Surface
  @return nil, error_string
*/
static int l_load_bmp(lua_State *L)
{
    const char* filename = luaL_checkstring(L, 1);
    SDL_Surface* surface = SDL_LoadBMP(filename);
    if(surface == NULL)
    {
        return l_push_error(L);
    }
    else
    {
        SDL_SetColorKey(surface, SDL_SRCCOLORKEY, SDL_MapRGB(surface->format, 255, 0, 255));
        l_push_surface(L, surface);
        return 1;
    }
}

/**
  @function sdl.video.newSurface
  @arguments {}
  @arg[opt, string] data
  @arg[opt, int] data_offset
  @arg[int] width
  @arg[int] height
  @arg[int] depth
  @arg[opt, int] pitch
  @arg[opt, int] Rmask
  @arg[opt, int] Gmask
  @arg[opt, int] Bmask
  @arg[opt, int] Amask
  @arg[opt, bool] hardware
  @arg[opt, bool] software
  @arg[opt, bool] colorkey
  @arg[opt, bool] alpha
  @arg[opt, THPalette] palette
  @return SDL_Surface
  @return nil, error_string
*/
static int l_new_surface(lua_State *L)
{
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_settop(L, 1);

    lua_pushnil(L); // stack position (2) for data string

    char* pixels = NULL;
    Uint32 flags = 0;
    int data_offset = 0;
    int width = -1;
    int height = -1;
    int depth = -1;
    int pitch = -1;
    Uint32 Rmask = 0;
    Uint32 Gmask = 0;
    Uint32 Bmask = 0;
    Uint32 Amask = 0;
    bool has_palette = false;
    bool transparent = true;

    lua_pushnil(L);
    while(lua_next(L, 1) != 0)
    {
        if(lua_type(L, 3) == LUA_TSTRING)
        {
            const char* key = lua_tostring(L, 3);
            if(stricmp(key, "width") == 0)
                width = (int)lua_tointeger(L, 4);
            else if(stricmp(key, "height") == 0)
                height = (int)lua_tointeger(L, 4);
            else if(stricmp(key, "depth") == 0)
                depth = (int)lua_tointeger(L, 4);
            else if(stricmp(key, "pitch") == 0)
                pitch = (int)lua_tointeger(L, 4);
            else if(stricmp(key, "data_offset") == 0)
                data_offset = (int)lua_tointeger(L, 4);
            else if(stricmp(key, "Rmask") == 0)
                Rmask = (Uint32)lua_tointeger(L, 4);
            else if(stricmp(key, "Gmask") == 0)
                Gmask = (Uint32)lua_tointeger(L, 4);
            else if(stricmp(key, "Bmask") == 0)
                Bmask = (Uint32)lua_tointeger(L, 4);
            else if(stricmp(key, "Amask") == 0)
                Amask = (Uint32)lua_tointeger(L, 4);
            else if(stricmp(key, "data") == 0)
            {
                pixels = (char*)lua_tostring(L, 4);
                lua_pushvalue(L, 4);
                lua_replace(L, 2);
            }
            else if(stricmp(key, "hardware") == 0)
                flags |= lua_toboolean(L, 4) * SDL_HWSURFACE;
            else if(stricmp(key, "software") == 0)
                flags |= lua_toboolean(L, 4) * SDL_SWSURFACE;
            else if(stricmp(key, "colorkey") == 0)
                flags |= lua_toboolean(L, 4) * SDL_SRCCOLORKEY;
            else if(stricmp(key, "alpha") == 0)
                flags |= lua_toboolean(L, 4) * SDL_SRCALPHA;
            else if(stricmp(key, "palette") == 0)
                has_palette = true;
            else if(stricmp(key, "transparent") == 0)
                transparent = lua_toboolean(L, 4) != 0;
        }
        lua_pop(L, 1);
    }

#define err(L, msg) lua_pushnil(L), lua_pushstring(L, msg), 2

    if(width == -1)
        return err(L, "Named width argument required");
    else if(height == -1)
        return err(L, "Named height argument required");
    else if(depth == -1)
        return err(L, "Named depth argument required");

    if(pitch == -1)
    {
        pitch = width * (depth / 8);
    }

    if(pixels == NULL)
    {
        SDL_Surface *surf = SDL_CreateRGBSurface(flags, width, height, depth, Rmask, Gmask, Bmask, Amask);
        if(surf == NULL)
        {
            return l_push_error(L);
        }
        else
        {
            l_push_surface(L, surf);
            return 1;
        }
    }
    else
    {
        size_t datalen;
        lua_tolstring(L, 2, &datalen);
        if(data_offset < 0)
        {
            data_offset += (int)datalen;
        }
        if((size_t)data_offset >= datalen && width != 0 && height != 0)
        {
            return err(L, "Invalid data_offset value");
        }
        datalen -= (size_t)data_offset;
        if(datalen < (size_t)(pitch * height * (depth / 8)))
        {
            return err(L, "Not enough data for the given size");
        }

        SDL_Surface *surf = SDL_CreateRGBSurfaceFrom(pixels + data_offset, width, height, depth, pitch, Rmask, Gmask, Bmask, Amask);
        if(surf == NULL)
        {
            return l_push_error(L);
        }
        else
        {
            l_push_surface(L, surf);
            if(has_palette)
            {
                lua_getfield(L, 1, "palette");
                lua_getfield(L, -1, "assign");
                lua_insert(L, -2);
                lua_pushvalue(L, -3);
                lua_pushboolean(L, transparent ? 1 : 0);
                lua_call(L, 3, 0);
            }
            lua_createtable(L, 0, 1);
            lua_pushliteral(L, "data");
            lua_pushvalue(L, 2);
            lua_settable(L, -3);
            lua_setfenv(L, -2);
            return 1;
        }
    }

#undef err
}

/**
  @function sdl.video.draw
  @arguments SDL_Surface src, SDL_Surface dest [, int x, int y [, int srcx, int srcy, int srcw, int srch]]
  @return bool
*/
static int l_blit_surface(lua_State *L)
{
    SDL_Rect srcrect;
    SDL_Rect* srcrect_p = NULL;
    SDL_Rect dstrect;
    SDL_Rect* dstrect_p = NULL;

    SDL_Surface *src = l_check_surface(L, 1);
    SDL_Surface *dst = l_check_surface(L, 2);

    switch(lua_gettop(L))
    {
    case 8:
        srcrect.x = (Sint16)luaL_checkint(L, 5);
        srcrect.y = (Sint16)luaL_checkint(L, 6);
        srcrect.w = (Uint16)luaL_checkint(L, 7);
        srcrect.h = (Uint16)luaL_checkint(L, 8);
        srcrect_p = &srcrect;
    case 4:
        dstrect.x = (Sint16)luaL_checkint(L, 3);
        dstrect.y = (Sint16)luaL_checkint(L, 4);
        dstrect_p = &dstrect;
    default:
        break;
    }

    if(SDL_BlitSurface(src, srcrect_p, dst, dstrect_p) == 0)
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
  @function sdl.video.saveBitmap
  @arguments SDL_Surface surface, string filename
  @return true
  @return nil, error_string
*/
static int l_save_bmp(lua_State *L)
{
    if(SDL_SaveBMP(l_check_surface(L, 1), luaL_checkstring(L, 2)) == 0)
    {
        lua_pushboolean(L, 1);
        return 1;
    }
    else
    {
        return l_push_error(L);
    }
}

/**
  @function sdl.video.getHeight
  @arguments SDL_Surface surface
  @return int
*/
static int l_get_height(lua_State *L)
{
    lua_pushinteger(L, l_check_surface(L, 1)->h);
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
    {"newSurface", l_new_surface},
    {"ensureHardwareSurface", l_ensure_hw_surface},
    {"getHeight", l_get_height},
    {"setMode", l_set_mode},
    {"freeSurface", l_free},
    {"draw", l_blit_surface},
    {"fillBlack", l_draw_black_rect},
    {"startFrame", l_nop},
    {"endFrame", l_flip},
    {"saveBitmap", l_save_bmp},
    {"loadBitmap", l_load_bmp},
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
