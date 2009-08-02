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
#include "lua_sdl.h"
#ifdef CORSIX_TH_USE_SDL_MIXER
#include "th_lua.h"
#include "xmi2mid.h"
#include <SDL_mixer.h>
#ifdef _MSC_VER
#pragma comment(lib, "SDL_mixer")
#endif

struct music_t
{
    Mix_Music* pMusic;
    SDL_RWops* pRWop;

    music_t()
    {
        pMusic = NULL;
        pRWop = NULL;
    }

    ~music_t()
    {
        if(pMusic)
            Mix_FreeMusic(pMusic);
        if(pRWop)
            SDL_FreeRW(pRWop);
    }
};

static int l_init(lua_State *L)
{
    if(Mix_OpenAudio(MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT, 1, 1024) != 0)
        lua_pushboolean(L, 0);
    else
    {
        lua_pushboolean(L, 1);
        luaT_addcleanup(L, Mix_CloseAudio);
    }
    return 1;
}

static int l_load_music(lua_State *L)
{
    size_t iLength;
    const unsigned char *pData = luaT_checkfile(L, 1, &iLength);
    SDL_RWops* rwop = SDL_RWFromConstMem(pData, (int)iLength);

    Mix_Music* pMusic = Mix_LoadMUS_RW(rwop);
    if(pMusic == NULL)
    {
        lua_pushnil(L);
        lua_pushstring(L, Mix_GetError());
        return 2;
    }
    music_t* pLMusic = luaT_stdnew<music_t>(L, LUA_ENVIRONINDEX, true);
    pLMusic->pMusic = pMusic;
    pLMusic->pRWop = rwop;
    lua_pushvalue(L, 1);
    luaT_setenvfield(L, -2, "data");
    return 1;
}

static int l_music_volume(lua_State *L)
{
    lua_Number fValue = luaL_checknumber(L, 1);
    fValue = fValue * (lua_Number)MIX_MAX_VOLUME;
    int iVolume = (int)(fValue + 0.5);
    if(iVolume < 0)
        iVolume = 0;
    else if(iVolume > MIX_MAX_VOLUME)
        iVolume = MIX_MAX_VOLUME;
    Mix_VolumeMusic(iVolume);
    return 0;
}

static int l_play_music(lua_State *L)
{
    music_t* pLMusic = luaT_testuserdata<music_t, false>(L, 1, LUA_ENVIRONINDEX, "Music");
    if(Mix_PlayMusic(pLMusic->pMusic, luaL_optint(L, 2, 1)) != 0)
    {
        lua_pushnil(L);
        lua_pushstring(L, Mix_GetError());
        return 2;
    }
    lua_pushboolean(L, 1);
    return 1;
}

static int l_transcode_xmi(lua_State *L)
{
    size_t iLength, iMidLength;
    const unsigned char *pData = luaT_checkfile(L, 1, &iLength);

    unsigned char *pMidData = TranscodeXmiToMid(pData, iLength, &iMidLength);
    if(pMidData == NULL)
    {
        lua_pushnil(L);
        lua_pushliteral(L, "Unable to transcode XMI to MIDI");
        return 2;
    }
    lua_pushlstring(L, (const char*)pMidData, iMidLength);
    delete[] pMidData;

    return 1;
}

static const struct luaL_reg sdl_audiolib[] = {
    {"init", l_init},
    {"transcodeXmiToMid", l_transcode_xmi},
    {NULL, NULL}
};

static const struct luaL_reg sdl_musiclib[] = {
    {"loadMusic", l_load_music},
    {"playMusic", l_play_music},
    {"setMusicVolume", l_music_volume},
    {NULL, NULL}
};

int luaopen_sdl_audio(lua_State *L)
{
    lua_newtable(L);
    luaL_register(L, NULL, sdl_audiolib);
    lua_pushboolean(L, 1);
    lua_setfield(L, -2, "loaded");

    lua_createtable(L, 0, 2);
    lua_pushvalue(L, -1);
    lua_replace(L, LUA_ENVIRONINDEX);
    lua_pushcclosure(L, luaT_stdgc<music_t, false, LUA_ENVIRONINDEX>, 0);
    lua_setfield(L, -2, "__gc");
    lua_pushvalue(L, 1);
    lua_setfield(L, -2, "__index");
    lua_pop(L, 1);
    luaL_register(L, NULL, sdl_musiclib);

    return 1;
}

#else // CORSIX_TH_USE_SDL_MIXER

int luaopen_sdl_audio(lua_State *L)
{
    lua_newtable(L);
    lua_pushboolean(L, 0);
    lua_setfield(L, -2, "loaded");

    return 1;
}

#endif // CORSIX_TH_USE_SDL_MIXER
