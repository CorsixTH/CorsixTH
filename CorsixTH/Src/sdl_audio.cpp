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
#pragma comment(lib, "SDL2_mixer")
#endif
#include <cstring>

class music
{
public:
    Mix_Music* pMusic;

    music()
    {
        pMusic = nullptr;
    }

    ~music()
    {
        if(pMusic)
        {
            Mix_FreeMusic(pMusic);
            pMusic = nullptr;
        }
    }
};

static void audio_music_over_callback()
{
    SDL_Event e;
    e.type = SDL_USEREVENT_MUSIC_OVER;
    SDL_PushEvent(&e);
}

static int l_init(lua_State *L)
{
    if(Mix_OpenAudio(static_cast<int>(luaL_optinteger(L, 1, MIX_DEFAULT_FREQUENCY)),
        MIX_DEFAULT_FORMAT,
        static_cast<int>(luaL_optinteger(L, 2, MIX_DEFAULT_CHANNELS)),
        static_cast<int>(luaL_optinteger(L, 3, 2048)) /* chunk size */) != 0)
    {
        lua_pushboolean(L, 0);
        lua_pushstring(L, Mix_GetError());
        return 2;
    }
    else
    {
        lua_pushboolean(L, 1);
        Mix_HookMusicFinished(audio_music_over_callback);
        return 1;
    }
}

struct load_music_async_data
{
    lua_State* L;
    Mix_Music* music;
    SDL_RWops* rwop;
    char* err;
    SDL_Thread* thread;
};

int l_load_music_async_callback(lua_State *L)
{
    load_music_async_data *async = (load_music_async_data*)lua_touserdata(L, 1);

    // Frees resources allocated to the thread
    SDL_WaitThread(async->thread, nullptr);

    // Replace light UD with full UD
    lua_pushvalue(L, 1);
    lua_gettable(L, LUA_REGISTRYINDEX);
    lua_insert(L, 1);
    lua_pushnil(L);
    lua_settable(L, LUA_REGISTRYINDEX);

    // Get CB function
    lua_pushvalue(L, 1);
    lua_gettable(L, LUA_REGISTRYINDEX);
    lua_rawgeti(L, -1, 1);

    // Push CB arguments
    int nargs = 1;
    if(async->music == nullptr)
    {
        lua_pushnil(L);
        if(async->err)
        {
            if(*async->err)
            {
                lua_pushstring(L, async->err);
                nargs = 2;
            }
            free(async->err);
        }
    }
    else
    {
        lua_rawgeti(L, 2, 2);
        music* pLMusic = (music*)lua_touserdata(L, -1);
        pLMusic->pMusic = async->music;
        async->music = nullptr;
    }

    // Finish cleanup
    lua_pushvalue(L, 1);
    lua_pushnil(L);
    lua_settable(L, LUA_REGISTRYINDEX);

    // Callback
    lua_call(L, nargs, 0);

    return 0;
}

static int load_music_async_thread(void* arg)
{
    load_music_async_data *async = (load_music_async_data*)arg;

    async->music = Mix_LoadMUS_RW(async->rwop, 1);
    async->rwop = nullptr;
    if(async->music == nullptr)
    {
        size_t iLen = std::strlen(Mix_GetError()) + 1;
        async->err = (char*)malloc(iLen);
        std::memcpy(async->err, Mix_GetError(), iLen);
    }
    SDL_Event e;
    e.type = SDL_USEREVENT_MUSIC_LOADED;
    e.user.data1 = arg;
    SDL_PushEvent(&e);
    return 0;
}

static int l_load_music_async(lua_State *L)
{
    size_t iLength;
    const uint8_t *pData = luaT_checkfile(L, 1, &iLength);
    luaL_checktype(L, 2, LUA_TFUNCTION);
    SDL_RWops* rwop = SDL_RWFromConstMem(pData, (int)iLength);
    lua_settop(L, 2);

    load_music_async_data *async = luaT_new(L, load_music_async_data);
    lua_pushlightuserdata(L, async);
    lua_pushvalue(L, -2);
    lua_settable(L, LUA_REGISTRYINDEX);
    async->L = L;
    async->music = nullptr;
    async->rwop = rwop;
    async->err = nullptr;
    lua_createtable(L, 2, 0);
    lua_pushvalue(L, 2);
    lua_rawseti(L, -2, 1);
    luaT_stdnew<music>(L, luaT_environindex, true);
    lua_pushvalue(L, 1);
    luaT_setenvfield(L, -2, "data");
    lua_rawseti(L, -2, 2);
    lua_settable(L, LUA_REGISTRYINDEX);

    /*
        In registry:
          [light userdata async] -> [full userdata async]
          [full userdata async] -> {
            [1] = callback_function,
            [2] = empty music_t userdata,
          }

        New thread will load music, and inform the main loop, which will then
        call the callback and remove the new entries from the registry.
    */

    async->thread = SDL_CreateThread(load_music_async_thread, "music_thread", async);

    return 0;
}

static int l_load_music(lua_State *L)
{
    size_t iLength;
    const uint8_t *pData = luaT_checkfile(L, 1, &iLength);
    SDL_RWops* rwop = SDL_RWFromConstMem(pData, (int)iLength);
    Mix_Music* pMusic = Mix_LoadMUS_RW(rwop, 1);
    if(pMusic == nullptr)
    {
        lua_pushnil(L);
        lua_pushstring(L, Mix_GetError());
        return 2;
    }
    music* pLMusic = luaT_stdnew<music>(L, luaT_environindex, true);
    pLMusic->pMusic = pMusic;
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
    music* pLMusic = luaT_testuserdata<music>(L, -1);
    if(Mix_PlayMusic(pLMusic->pMusic, static_cast<int>(luaL_optinteger(L, 2, 1))) != 0)
    {
        lua_pushnil(L);
        lua_pushstring(L, Mix_GetError());
        return 2;
    }
    lua_pushboolean(L, 1);
    return 1;
}

static int l_pause_music(lua_State *L)
{
    Mix_PauseMusic();
    lua_pushboolean(L, Mix_PausedMusic() != 0 ? 1 : 0);
    return 1;
}

static int l_resume_music(lua_State *L)
{
    Mix_ResumeMusic();
    lua_pushboolean(L, Mix_PausedMusic() == 0 ? 1 : 0);
    return 1;
}

static int l_stop_music(lua_State *L)
{
    Mix_HaltMusic();
    return 0;
}

static int l_transcode_xmi(lua_State *L)
{
    size_t iLength, iMidLength;
    const uint8_t *pData = luaT_checkfile(L, 1, &iLength);

    uint8_t *pMidData = transcode_xmi_to_midi(pData, iLength, &iMidLength);
    if(pMidData == nullptr)
    {
        lua_pushnil(L);
        lua_pushliteral(L, "Unable to transcode XMI to MIDI");
        return 2;
    }
    lua_pushlstring(L, (const char*)pMidData, iMidLength);
    delete[] pMidData;

    return 1;
}

static const struct luaL_Reg sdl_audiolib[] = {
    {"init", l_init},
    {"transcodeXmiToMid", l_transcode_xmi},
    {nullptr, nullptr}
};

static const struct luaL_Reg sdl_musiclib[] = {
    {"loadMusic", l_load_music},
    {"loadMusicAsync", l_load_music_async},
    {"playMusic", l_play_music},
    {"stopMusic", l_stop_music},
    {"pauseMusic", l_pause_music},
    {"resumeMusic", l_resume_music},
    {"setMusicVolume", l_music_volume},
    {nullptr, nullptr}
};

int luaopen_sdl_audio(lua_State *L)
{
    lua_newtable(L);
    luaT_setfuncs(L, sdl_audiolib);
    lua_pushboolean(L, 1);
    lua_setfield(L, -2, "loaded");

    lua_createtable(L, 0, 2);
    lua_pushvalue(L, -1);
    lua_replace(L, luaT_environindex);
    lua_pushvalue(L, luaT_environindex);
    luaT_pushcclosure(L, luaT_stdgc<music, luaT_environindex>, 1);
    lua_setfield(L, -2, "__gc");
    lua_pushvalue(L, 1);
    lua_setfield(L, -2, "__index");
    lua_pop(L, 1);
    luaT_setfuncs(L, sdl_musiclib);

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

int l_load_music_async_callback(lua_State *L)
{
    return 0;
}

#endif // CORSIX_TH_USE_SDL_MIXER
