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
#ifdef CORSIX_TH_USE_OGL_RENDERER
#include "th_lua.h"
#include "th_gfx_ogl.h"
#include <string.h>
#include <SDL.h>
#ifndef _MSC_VER
#define stricmp strcasecmp
#else
#pragma warning(disable: 4996) // Deprecated CRT
#endif

static int l_set_mode(lua_State *L)
{
    int iWidth, iHeight, iBPP, iArg, iArgCount;
    Uint32 iSDLFlags = SDL_OPENGL;

    iWidth = luaL_checkint(L, 1);
    iHeight = luaL_checkint(L, 2);
    if(lua_type(L, 3) == LUA_TNUMBER)
    {
        iBPP = luaL_checkint(L, 3);
        iArg = 4;
    }
    else
    {
        iBPP = 0;
        iArg = 3;
    }
    iArgCount = lua_gettop(L);

    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 0);

    for(; iArg <= iArgCount; ++iArg)
    {
        const char* option = luaL_checkstring(L, iArg);
        if(*option == 0)
            continue;
        else if(stricmp(option, "hardware") == 0)
            iSDLFlags |= SDL_HWSURFACE;
        else if(stricmp(option, "doublebuf") == 0)
        {
            iSDLFlags |= SDL_DOUBLEBUF;
            SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
        }
        else if(stricmp(option, "fullscreen") == 0)
            iSDLFlags |= SDL_FULLSCREEN;
    }

    if(iBPP == 0)
    {
        iBPP = SDL_GetVideoInfo()->vfmt->BitsPerPixel;
    }

    switch(iBPP)
    {
    case 8:
        SDL_GL_SetAttribute(SDL_GL_RED_SIZE,   3);
	    SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 3);
	    SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE,  2);
        break;
    case 15:
    case 16:
        SDL_GL_SetAttribute(SDL_GL_RED_SIZE,   5);
	    SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 5);
	    SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE,  5);
        break;
    default:
        SDL_GL_SetAttribute(SDL_GL_RED_SIZE,   8);
	    SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
	    SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE,  8);
        break;
    }
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 0);
    SDL_GL_SetAttribute(SDL_GL_SWAP_CONTROL, 1);

    SDL_Surface *surface = SDL_SetVideoMode(iWidth, iHeight, iBPP, iSDLFlags);
    if(surface == NULL)
    {
        return l_push_error(L);
    }

    glDisable(GL_DEPTH_TEST);
	glDisable(GL_CULL_FACE);
	glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glViewport(0, 0, iWidth, iHeight);
    glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
    glOrtho(0.0, (GLdouble)iWidth, (GLDouble)iHeight, 0.0, 0.0, 0.0);
    glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

    l_push_surface(L, surface, false);
    return 1;
}

static const struct luaL_reg sdl_videolib[] = {
    //{"newSurface", l_new_surface},
    //{"ensureHardwareSurface", l_ensure_hw_surface},
    //{"getHeight", l_get_height},
    {"setMode", l_set_mode},
    //{"freeSurface", l_free},
    //{"draw", l_blit_surface},
    //{"fillBlack", l_draw_black_rect},
    //{"startFrame", l_nop},
    //{"endFrame", l_flip},
    //{"saveBitmap", l_save_bmp},
    //{"loadBitmap", l_load_bmp},
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

#endif // CORSIX_TH_USE_OGL_RENDERER
