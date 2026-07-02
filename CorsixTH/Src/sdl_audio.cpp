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

#include <SDL3/SDL.h>
#include <SDL3_mixer/SDL_mixer.h>

#include <array>
#include <cmath>
#include <cstdlib>
#include <cstring>

#include "lua.hpp"
#include "lua_sdl.h"
#include "th_lua.h"
#include "th_sound.h"
#include "xmi2mid.h"
#ifdef _MSC_VER
#pragma comment(lib, "SDL2_mixer")
#endif

class music {
 public:
  MIX_Audio* pMusic{nullptr};

  music() = default;

  ~music() {
    if (pMusic) {
      MIX_DestroyAudio(pMusic);
      pMusic = nullptr;
    }
  }
};

namespace {

th::sound::track_ptr music_track;

void audio_music_over_callback(void*, MIX_Track*) {
  SDL_Event e;
  e.type = SDL_USEREVENT_MUSIC_OVER;
  SDL_PushEvent(&e);
}

int l_init(lua_State* L) {
  size_t soundfont_path_len;
  const char* sound_font = luaL_optlstring(L, 4, nullptr, &soundfont_path_len);

  if (!th::sound::init(sound_font)) {
    lua_pushboolean(L, 0);
    lua_pushstring(L, SDL_GetError());
    return 2;
  }

  music_track.reset(MIX_CreateTrack(th::sound::get_mixer()));
  if (!music_track) {
    lua_pushboolean(L, 0);
    lua_pushstring(L, SDL_GetError());
    return 2;
  }

  lua_pushboolean(L, 1);

  MIX_SetTrackStoppedCallback(music_track.get(), audio_music_over_callback,
                              nullptr);
  return 1;
}

int l_destroy(lua_State* L) {
  th::sound::quit();
  return 0;
}

struct load_music_async_data {
  lua_State* L;
  MIX_Audio* music;
  SDL_IOStream* rwop;
  char* err;
  SDL_Thread* thread;
};

constexpr const char* mix_prop_soundfont_path_string =
    "SDL_mixer.decoder.fluidsynth.soundfont_path";

MIX_Audio* createMusicAudio(SDL_IOStream* stream) {
  SDL_PropertiesID audioProps = SDL_CreateProperties();
  SDL_SetPointerProperty(audioProps, MIX_PROP_AUDIO_LOAD_IOSTREAM_POINTER,
                         stream);
  SDL_SetBooleanProperty(audioProps, MIX_PROP_AUDIO_LOAD_CLOSEIO_BOOLEAN, true);
  SDL_SetPointerProperty(audioProps,
                         MIX_PROP_AUDIO_LOAD_PREFERRED_MIXER_POINTER,
                         th::sound::get_mixer());
  const char* sf = th::sound::get_soundfont();
  if (sf) {
    SDL_SetStringProperty(audioProps, mix_prop_soundfont_path_string, sf);
  }
  MIX_Audio* audio = MIX_LoadAudioWithProperties(audioProps);
  SDL_DestroyProperties(audioProps);

  return audio;
}

int load_music_async_thread(void* arg) {
  load_music_async_data* async = (load_music_async_data*)arg;

  async->music = createMusicAudio(async->rwop);
  async->rwop = nullptr;
  if (async->music == nullptr) {
    size_t iLen = std::strlen(SDL_GetError()) + 1;
    async->err = (char*)malloc(iLen);
    std::memcpy(async->err, SDL_GetError(), iLen);
  }
  SDL_Event e;
  e.type = SDL_USEREVENT_MUSIC_LOADED;
  e.user.data1 = arg;
  SDL_PushEvent(&e);
  return 0;
}

int l_load_music_async(lua_State* L) {
  size_t iLength;
  const uint8_t* pData = luaT_checkfile(L, 1, &iLength);
  luaL_checktype(L, 2, LUA_TFUNCTION);
  SDL_IOStream* rwop = SDL_IOFromConstMem(pData, (int)iLength);
  lua_settop(L, 2);

  load_music_async_data* async = luaT_new<load_music_async_data>(L);
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

  async->thread =
      SDL_CreateThread(load_music_async_thread, "music_thread", async);

  return 0;
}

int l_load_music(lua_State* L) {
  size_t iLength;
  const uint8_t* pData = luaT_checkfile(L, 1, &iLength);
  SDL_IOStream* rwop = SDL_IOFromConstMem(pData, (int)iLength);
  MIX_Audio* pMusic = createMusicAudio(rwop);
  if (pMusic == nullptr) {
    lua_pushnil(L);
    lua_pushstring(L, SDL_GetError());
    return 2;
  }
  music* pLMusic = luaT_stdnew<music>(L, luaT_environindex, true);
  pLMusic->pMusic = pMusic;
  lua_pushvalue(L, 1);
  luaT_setenvfield(L, -2, "data");
  return 1;
}

int l_music_volume(lua_State* L) {
  auto volume = static_cast<float>(luaL_checknumber(L, 1));
  if (volume < 0) {
    volume = 0;
  }
  MIX_SetTrackGain(music_track.get(), volume);
  return 0;
}

int l_play_music(lua_State* L) {
  music* pLMusic = luaT_testuserdata<music>(L, -1);
  int loops = static_cast<int>(luaL_optinteger(L, 2, 1));

  bool success = true;
  success &= MIX_SetTrackAudio(music_track.get(), pLMusic->pMusic);
  SDL_PropertiesID playProps = SDL_CreateProperties();
  SDL_SetNumberProperty(playProps, MIX_PROP_PLAY_LOOPS_NUMBER, loops);
  success &= MIX_PlayTrack(music_track.get(), playProps);
  SDL_DestroyProperties(playProps);

  if (!success) {
    lua_pushnil(L);
    lua_pushstring(L, SDL_GetError());
    return 2;
  }
  lua_pushboolean(L, 1);
  return 1;
}

int l_pause_music(lua_State* L) {
  MIX_PauseTrack(music_track.get());
  lua_pushboolean(L, MIX_TrackPaused(music_track.get()));
  return 1;
}

int l_resume_music(lua_State* L) {
  MIX_ResumeTrack(music_track.get());
  lua_pushboolean(L, !MIX_TrackPaused(music_track.get()));
  return 1;
}

int l_stop_music(lua_State* L) {
  MIX_StopTrack(music_track.get(), 0);
  return 0;
}

int l_transcode_xmi(lua_State* L) {
  size_t iLength;
  const uint8_t* pData = luaT_checkfile(L, 1, &iLength);

  try {
    size_t iMidLength;
    uint8_t* pMidData = transcode_xmi_to_midi(pData, iLength, &iMidLength);
    if (pMidData == nullptr) {
      lua_pushnil(L);
      lua_pushliteral(L, "Unable to transcode XMI to MIDI");
      return 2;
    }
    lua_pushlstring(L, reinterpret_cast<char*>(pMidData), iMidLength);
    delete[] pMidData;
  } catch (const std::exception& e) {
    luaL_error(L, "transcode_xmi exception: %s", e.what());
  }

  return 1;
}

constexpr std::array<struct luaL_Reg, 4> sdl_audiolib{
    {{"init", l_init},
     {"transcodeXmiToMid", l_transcode_xmi},
     {"destroy", l_destroy},
     {nullptr, nullptr}}};

constexpr std::array<struct luaL_Reg, 8> sdl_musiclib{
    {{"loadMusic", l_load_music},
     {"loadMusicAsync", l_load_music_async},
     {"playMusic", l_play_music},
     {"stopMusic", l_stop_music},
     {"pauseMusic", l_pause_music},
     {"resumeMusic", l_resume_music},
     {"setMusicVolume", l_music_volume},
     {nullptr, nullptr}}};

}  // namespace

int l_load_music_async_callback(lua_State* L) {
  load_music_async_data* async = (load_music_async_data*)lua_touserdata(L, 1);

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
  if (async->music == nullptr) {
    lua_pushnil(L);
    if (async->err) {
      if (*async->err) {
        lua_pushstring(L, async->err);
        nargs = 2;
      }
      free(async->err);
    }
  } else {
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

int luaopen_sdl_audio(lua_State* L) {
  lua_newtable(L);
  luaT_setfuncs(L, sdl_audiolib.data());
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
  luaT_setfuncs(L, sdl_musiclib.data());

  return 1;
}
