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

#include "sdl_core.h"

#include <SDL.h>

#include <array>
#include <cstdio>
#include <cstring>

#include "lua.hpp"
#include "lua_sdl.h"
#include "th_lua.h"

namespace {

int l_init(lua_State* L) {
  Uint32 flags = 0;
  int i;
  int argc = lua_gettop(L);
  for (i = 1; i <= argc; ++i) {
    const char* s = luaL_checkstring(L, i);
    if (std::strcmp(s, "video") == 0)
      flags |= SDL_INIT_VIDEO;
    else if (std::strcmp(s, "audio") == 0)
      flags |= SDL_INIT_AUDIO;
    else if (std::strcmp(s, "timer") == 0)
      flags |= SDL_INIT_TIMER;
    else if (std::strcmp(s, "*") == 0)
      flags |= SDL_INIT_EVERYTHING;
    else
      luaL_argerror(L, i, "Expected SDL part name");
  }
  if (SDL_Init(flags) != 0) {
    std::fprintf(stderr, "SDL_Init failed: %s\n", SDL_GetError());
    lua_pushboolean(L, 0);
    return 1;
  }

  lua_pushboolean(L, 1);
  return 1;
}

Uint32 timer_frame_callback(Uint32 interval, void* param) {
  SDL_Event e;
  e.type = SDL_USEREVENT_TICK;
  SDL_PushEvent(&e);
  return interval;
}

class fps_ctrl {
 public:
  bool limit_fps{true};
  bool track_fps{true};

  size_t q_front{0};
  size_t q_back{0};
  int frame_count{0};
  std::array<Uint32, 4096> frame_time{};

  void init() {
    limit_fps = true;
    track_fps = true;
    q_front = 0;
    q_back = 0;
    frame_count = 0;
  }

  void count_frame() {
    Uint32 now = SDL_GetTicks();
    frame_time[q_front] = now;
    q_front = (q_front + 1) % frame_time.size();
    if (q_front == q_back) {
      q_back = (q_back + 1) % frame_time.size();
    } else {
      ++frame_count;
    }

    if (now < 1000) {
      now = 0;
    } else {
      now -= 1000;
    }

    while (frame_time[q_back] < now) {
      --frame_count;
      q_back = (q_back + 1) % frame_time.size();
    }
  }
};

fps_ctrl fps;

void l_push_modifiers_table(lua_State* L, Uint16 mod) {
  lua_newtable(L);
  if ((mod & KMOD_SHIFT) != 0) {
    luaT_pushtablebool(L, "shift", true);
  }
  if ((mod & KMOD_ALT) != 0) {
    luaT_pushtablebool(L, "alt", true);
  }
  if ((mod & KMOD_CTRL) != 0) {
    luaT_pushtablebool(L, "ctrl", true);
  }
  if ((mod & KMOD_GUI) != 0) {
    luaT_pushtablebool(L, "gui", true);
  }
  if ((mod & KMOD_NUM) != 0) {
    luaT_pushtablebool(L, "numlockactive", true);
  }
}

int l_get_key_modifiers(lua_State* L) {
  l_push_modifiers_table(L, SDL_GetModState());
  return 1;
}

/// Add TheApp:dispatch to the lua stack
void push_app_dispatch(lua_State* L) {
  lua_getglobal(L, "TheApp");
  lua_getfield(L, -1, "dispatch");
  lua_pushvalue(L, -2);
}


int l_track_fps(lua_State* L) {
  fps.track_fps = lua_isnone(L, 1) ? true : (lua_toboolean(L, 1) != 0);
  return 0;
}

int l_limit_fps(lua_State* L) {
  fps.limit_fps = lua_isnone(L, 1) ? true : (lua_toboolean(L, 1) != 0);
  return 0;
}

int l_get_fps(lua_State* L) {
  if (fps.track_fps) {
    lua_pushinteger(L, fps.frame_count);
  } else {
    lua_pushnil(L);
  }
  return 1;
}

int l_get_ticks(lua_State* L) {
  lua_pushinteger(L, SDL_GetTicks());
  return 1;
}

constexpr std::array<luaL_Reg, 7> sdllib{
    {{"init", l_init},
     {"getTicks", l_get_ticks},
     {"getKeyModifiers", l_get_key_modifiers},
     {"getFPS", l_get_fps},
     {"trackFPS", l_track_fps},
     {"limitFPS", l_limit_fps},
     {nullptr, nullptr}}};

inline void load_extra(lua_State* L, const char* name, lua_CFunction fn) {
  luaT_pushcfunction(L, fn);
  lua_call(L, 0, 1);
  lua_setfield(L, -2, name);
}

}  // namespace

int mainloop(lua_State* L) {
  SDL_TimerID timer =
      SDL_AddTimer(usertick_period_ms, timer_frame_callback, nullptr);
  SDL_Event e;

  int wait_error = 0;
  while ((wait_error = SDL_WaitEvent(&e)) != 0) {
    bool do_frame = false;
    bool do_timer = false;
    do {
      int nargs;
      switch (e.type) {
        case SDL_QUIT:
          goto leave_loop;
        case SDL_KEYDOWN:
          push_app_dispatch(L);
          lua_pushliteral(L, "keydown");
          lua_pushstring(L, SDL_GetKeyName(e.key.keysym.sym));
          l_push_modifiers_table(L, e.key.keysym.mod);
          lua_pushboolean(L, e.key.repeat != 0);
          nargs = 4;
          break;
        case SDL_KEYUP:
          push_app_dispatch(L);
          lua_pushliteral(L, "keyup");
          lua_pushstring(L, SDL_GetKeyName(e.key.keysym.sym));
          nargs = 2;
          break;
        case SDL_TEXTINPUT:
          push_app_dispatch(L);
          lua_pushliteral(L, "textinput");
          lua_pushstring(L, e.text.text);
          nargs = 2;
          break;
        case SDL_TEXTEDITING:
          push_app_dispatch(L);
          lua_pushliteral(L, "textediting");
          lua_pushstring(L, e.edit.text);
          lua_pushinteger(L, e.edit.start);
          lua_pushinteger(L, e.edit.length);
          nargs = 4;
          break;
        case SDL_MOUSEBUTTONDOWN:
          push_app_dispatch(L);
          lua_pushliteral(L, "buttondown");
          lua_pushinteger(L, e.button.button);
          lua_pushinteger(L, e.button.x);
          lua_pushinteger(L, e.button.y);
          nargs = 4;
          break;
        case SDL_MOUSEBUTTONUP:
          push_app_dispatch(L);
          lua_pushliteral(L, "buttonup");
          lua_pushinteger(L, e.button.button);
          lua_pushinteger(L, e.button.x);
          lua_pushinteger(L, e.button.y);
          nargs = 4;
          break;
        case SDL_MOUSEWHEEL:
          push_app_dispatch(L);
          lua_pushliteral(L, "mousewheel");
          lua_pushinteger(L, e.wheel.x);
          lua_pushinteger(L, e.wheel.y);
          nargs = 3;
          break;
        case SDL_MOUSEMOTION:
          push_app_dispatch(L);
          lua_pushliteral(L, "motion");
          lua_pushinteger(L, e.motion.x);
          lua_pushinteger(L, e.motion.y);
          lua_pushinteger(L, e.motion.xrel);
          lua_pushinteger(L, e.motion.yrel);
          nargs = 5;
          break;
        case SDL_MULTIGESTURE:
          push_app_dispatch(L);
          lua_pushliteral(L, "multigesture");
          lua_pushinteger(L, e.mgesture.numFingers);
          lua_pushnumber(L, e.mgesture.dTheta);
          lua_pushnumber(L, e.mgesture.dDist);
          lua_pushnumber(L, e.mgesture.x);
          lua_pushnumber(L, e.mgesture.y);
          nargs = 6;
          break;
        case SDL_WINDOWEVENT:
          switch (e.window.event) {
            case SDL_WINDOWEVENT_FOCUS_GAINED:
              push_app_dispatch(L);
              lua_pushliteral(L, "active");
              lua_pushinteger(L, 1);
              nargs = 2;
              break;
            case SDL_WINDOWEVENT_FOCUS_LOST:
              push_app_dispatch(L);
              lua_pushliteral(L, "active");
              lua_pushinteger(L, 0);
              nargs = 2;
              break;
            case SDL_WINDOWEVENT_SIZE_CHANGED:
              push_app_dispatch(L);
              lua_pushliteral(L, "window_resize");
              lua_pushinteger(L, e.window.data1);
              lua_pushinteger(L, e.window.data2);
              nargs = 3;
              break;
            default:
              nargs = 0;
              break;
          }
          break;
        case SDL_USEREVENT_MUSIC_OVER:
          push_app_dispatch(L);
          lua_pushliteral(L, "music_over");
          nargs = 1;
          break;
        case SDL_USEREVENT_MUSIC_LOADED:
          if (luaT_cpcall(L, l_load_music_async_callback,
                          e.user.data1)) {
            SDL_RemoveTimer(timer);
            lua_pushliteral(L, "callback");
            return 2;
          }
          nargs = 0;
          break;
        case SDL_USEREVENT_TICK:
          do_timer = true;
          nargs = 0;
          break;
        case SDL_USEREVENT_MOVIE_OVER:
          push_app_dispatch(L);
          lua_pushliteral(L, "movie_over");
          nargs = 1;
          break;
        case SDL_USEREVENT_SOUND_OVER:
          push_app_dispatch(L);
          lua_pushliteral(L, "sound_over");
          lua_pushinteger(L, *(static_cast<int*>(e.user.data1)));
          nargs = 2;
          break;
        default:
          nargs = 0;
          break;
      }
      if (nargs != 0) {
        int res = lua_pcall(L, nargs + 1, 1, 0);
        // TODO: if res is not LUA_OK - log the error and maybe exit?
        do_frame = do_frame || (lua_toboolean(L, -1) != 0);
        lua_pop(L, 1);
      }
    } while (SDL_PollEvent(&e) != 0);
    if (do_timer) {
      push_app_dispatch(L);
      lua_pushliteral(L, "timer");
        int res = lua_pcall(L, 2, 1, 0);
        // TODO: if res is not LUA_OK - log the error and maybe exit?
        do_frame = do_frame || (lua_toboolean(L, -1) != 0);
        lua_pop(L, 1);
    }
    if (do_frame || !fps.limit_fps) {
      do {
        if (fps.track_fps) {
          fps.count_frame();
        }
        push_app_dispatch(L);
        lua_pushliteral(L, "frame");
        int res = lua_pcall(L, 2, 1, 0);
        if (res != LUA_OK) {
          std::fprintf(stderr, "Error in frame callback: %s\n", lua_tostring(L, -1));
        } else {
          do_frame = do_frame || (lua_toboolean(L, -1) != 0);
          lua_pop(L, 1);
        }
      } while (fps.limit_fps == false && SDL_PollEvent(nullptr) == 0);
    }

    // No events pending - a good time to do a bit of garbage collection
    lua_gc(L, LUA_GCSTEP, 2);
  }

  if (wait_error != 0) {
    std::fprintf(stderr, "%s\n", SDL_GetError());
  }

leave_loop:
  SDL_RemoveTimer(timer);
  int n = lua_gettop(L);
  if (lua_status(L) >= LUA_ERRRUN) {
    n = 1;
  }
  lua_checkstack(L, n);
  return n;
}

int luaopen_sdl(lua_State* L) {
  fps.init();
  luaT_register(L, "sdl", sdllib);
  load_extra(L, "audio", luaopen_sdl_audio);
  load_extra(L, "wm", luaopen_sdl_wm);

  return 1;
}
