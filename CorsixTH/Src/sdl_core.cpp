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

#include <array>
#include <cstdio>
#include <cstring>

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
    else if (std::strcmp(s, "*") == 0)
      flags |= SDL_INIT_VIDEO | SDL_INIT_AUDIO;
    else
      luaL_argerror(L, i, "Expected SDL part name");
  }
  if (!SDL_Init(flags)) {
    std::fprintf(stderr, "SDL_Init failed: %s\n", SDL_GetError());
    lua_pushboolean(L, 0);
    return 1;
  }

  lua_pushboolean(L, 1);
  return 1;
}

Uint32 timer_frame_callback(void* param, SDL_TimerID timerId, Uint32 interval) {
  SDL_Event e;
  e.type = SDL_USEREVENT_TICK;
  SDL_PushEvent(&e);
  return interval;
}

class fps_ctrl {
 public:
  bool limit_fps;
  bool track_fps;

  size_t q_front;
  size_t q_back;
  int frame_count;
  std::array<Uint32, 4096> frame_time;

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

void l_push_modifiers_table(lua_State* L, Uint16 mod) {
  lua_newtable(L);
  if ((mod & SDL_KMOD_SHIFT) != 0) {
    luaT_pushtablebool(L, "shift", true);
  }
  if ((mod & SDL_KMOD_ALT) != 0) {
    luaT_pushtablebool(L, "alt", true);
  }
  if ((mod & SDL_KMOD_CTRL) != 0) {
    luaT_pushtablebool(L, "ctrl", true);
  }
  if ((mod & SDL_KMOD_GUI) != 0) {
    luaT_pushtablebool(L, "gui", true);
  }
  if ((mod & SDL_KMOD_NUM) != 0) {
    luaT_pushtablebool(L, "numlockactive", true);
  }
}

int l_get_key_modifiers(lua_State* L) {
  l_push_modifiers_table(L, SDL_GetModState());
  return 1;
}

int l_mainloop(lua_State* L) {
  luaL_checktype(L, 1, LUA_TTHREAD);
  lua_State* dispatcher = lua_tothread(L, 1);
  int resume_stack_size = 0;

  fps_ctrl* fps_control = (fps_ctrl*)lua_touserdata(L, luaT_upvalueindex(1));
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
        case SDL_EVENT_QUIT:
          goto leave_loop;
        case SDL_EVENT_KEY_DOWN:
          lua_pushliteral(dispatcher, "keydown");
          lua_pushstring(dispatcher, SDL_GetKeyName(e.key.key));
          l_push_modifiers_table(dispatcher, e.key.mod);
          lua_pushboolean(dispatcher, e.key.repeat != 0);
          nargs = 4;
          break;
        case SDL_EVENT_KEY_UP:
          lua_pushliteral(dispatcher, "keyup");
          lua_pushstring(dispatcher, SDL_GetKeyName(e.key.key));
          nargs = 2;
          break;
        case SDL_EVENT_TEXT_INPUT:
          lua_pushliteral(dispatcher, "textinput");
          lua_pushstring(dispatcher, e.text.text);
          nargs = 2;
          break;
        case SDL_EVENT_TEXT_EDITING:
          lua_pushliteral(dispatcher, "textediting");
          lua_pushstring(dispatcher, e.edit.text);
          lua_pushinteger(dispatcher, e.edit.start);
          lua_pushinteger(dispatcher, e.edit.length);
          nargs = 4;
          break;
        case SDL_EVENT_MOUSE_BUTTON_DOWN:
          lua_pushliteral(dispatcher, "buttondown");
          lua_pushinteger(dispatcher, e.button.button);
          lua_pushinteger(dispatcher, e.button.x);
          lua_pushinteger(dispatcher, e.button.y);
          nargs = 4;
          break;
        case SDL_EVENT_MOUSE_BUTTON_UP:
          lua_pushliteral(dispatcher, "buttonup");
          lua_pushinteger(dispatcher, e.button.button);
          lua_pushinteger(dispatcher, e.button.x);
          lua_pushinteger(dispatcher, e.button.y);
          nargs = 4;
          break;
        case SDL_EVENT_MOUSE_WHEEL:
          lua_pushliteral(dispatcher, "mousewheel");
          lua_pushinteger(dispatcher, e.wheel.x);
          lua_pushinteger(dispatcher, e.wheel.y);
          nargs = 3;
          break;
        case SDL_EVENT_MOUSE_MOTION:
          lua_pushliteral(dispatcher, "motion");
          lua_pushinteger(dispatcher, e.motion.x);
          lua_pushinteger(dispatcher, e.motion.y);
          lua_pushinteger(dispatcher, e.motion.xrel);
          lua_pushinteger(dispatcher, e.motion.yrel);
          nargs = 5;
          break;
#ifdef CORSIX_TH_USE_GESTURES  // No longer supported SDL3. Compat lib
                               // available.
        case SDL_MULTIGESTURE:
          lua_pushliteral(dispatcher, "multigesture");
          lua_pushinteger(dispatcher, e.mgesture.numFingers);
          lua_pushnumber(dispatcher, e.mgesture.dTheta);
          lua_pushnumber(dispatcher, e.mgesture.dDist);
          lua_pushnumber(dispatcher, e.mgesture.x);
          lua_pushnumber(dispatcher, e.mgesture.y);
          nargs = 6;
          break;
#endif
        case SDL_EVENT_WINDOW_FOCUS_GAINED:
          lua_pushliteral(dispatcher, "active");
          lua_pushinteger(dispatcher, 1);
          nargs = 2;
          break;
        case SDL_EVENT_WINDOW_FOCUS_LOST:
          lua_pushliteral(dispatcher, "active");
          lua_pushinteger(dispatcher, 0);
          nargs = 2;
          break;
        case SDL_EVENT_WINDOW_RESIZED:
          lua_pushliteral(dispatcher, "window_resize");
          lua_pushinteger(dispatcher, e.window.data1);
          lua_pushinteger(dispatcher, e.window.data2);
          nargs = 3;
          break;
        case SDL_USEREVENT_MUSIC_OVER:
          lua_pushliteral(dispatcher, "music_over");
          nargs = 1;
          break;
        case SDL_USEREVENT_MUSIC_LOADED:
          if (luaT_cpcall(L, (lua_CFunction)l_load_music_async_callback,
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
          lua_pushliteral(dispatcher, "movie_over");
          nargs = 1;
          break;
        case SDL_USEREVENT_SOUND_OVER:
          lua_pushliteral(dispatcher, "sound_over");
          lua_pushinteger(dispatcher, *(static_cast<int*>(e.user.data1)));
          nargs = 2;
          break;
        default:
          nargs = 0;
          break;
      }
      if (nargs != 0) {
        if (luaT_resume(dispatcher, L, nargs, &resume_stack_size) !=
            LUA_YIELD) {
          goto leave_loop;
        }
        do_frame = do_frame || (lua_toboolean(dispatcher, 1) != 0);
        lua_pop(dispatcher, resume_stack_size);
      }
    } while (SDL_PollEvent(&e) != 0);
    if (do_timer) {
      lua_pushliteral(dispatcher, "timer");
      if (luaT_resume(dispatcher, L, 1, &resume_stack_size) != LUA_YIELD) {
        break;
      }
      do_frame = do_frame || (lua_toboolean(dispatcher, 1) != 0);
      lua_pop(dispatcher, resume_stack_size);
    }
    if (do_frame || !fps_control->limit_fps) {
      do {
        if (fps_control->track_fps) {
          fps_control->count_frame();
        }
        lua_pushliteral(dispatcher, "frame");
        if (luaT_resume(dispatcher, L, 1, &resume_stack_size) != LUA_YIELD) {
          goto leave_loop;
        }
        lua_pop(dispatcher, resume_stack_size);
      } while (fps_control->limit_fps == false && SDL_PollEvent(nullptr) == 0);
    }

    // No events pending - a good time to do a bit of garbage collection
    lua_gc(L, LUA_GCSTEP, 2);
  }

  if (wait_error != 0) {
    std::fprintf(stderr, "%s\n", SDL_GetError());
  }

leave_loop:
  SDL_RemoveTimer(timer);
  int n = lua_gettop(dispatcher);
  if (lua_status(dispatcher) >= LUA_ERRRUN) {
    n = 1;
  }
  lua_checkstack(L, n);
  lua_xmove(dispatcher, L, n);
  return n;
}

int l_track_fps(lua_State* L) {
  fps_ctrl* ctrl = (fps_ctrl*)lua_touserdata(L, luaT_upvalueindex(1));
  ctrl->track_fps = lua_isnone(L, 1) ? true : (lua_toboolean(L, 1) != 0);
  return 0;
}

int l_limit_fps(lua_State* L) {
  fps_ctrl* ctrl = (fps_ctrl*)lua_touserdata(L, luaT_upvalueindex(1));
  ctrl->limit_fps = lua_isnone(L, 1) ? true : (lua_toboolean(L, 1) != 0);
  return 0;
}

int l_get_fps(lua_State* L) {
  fps_ctrl* ctrl = (fps_ctrl*)lua_touserdata(L, luaT_upvalueindex(1));
  if (ctrl->track_fps) {
    lua_pushinteger(L, ctrl->frame_count);
  } else {
    lua_pushnil(L);
  }
  return 1;
}

int l_get_ticks(lua_State* L) {
  lua_pushinteger(L, (lua_Integer)SDL_GetTicks());
  return 1;
}

constexpr std::array<luaL_Reg, 4> sdllib{
    {{"init", l_init},
     {"getTicks", l_get_ticks},
     {"getKeyModifiers", l_get_key_modifiers},
     {nullptr, nullptr}}};

constexpr std::array<luaL_Reg, 5> sdllib_with_upvalue{
    {{"mainloop", l_mainloop},
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

int luaopen_sdl_audio(lua_State* L);
int luaopen_sdl_wm(lua_State* L);

int luaopen_sdl(lua_State* L) {
  fps_ctrl* ctrl = (fps_ctrl*)lua_newuserdata(L, sizeof(fps_ctrl));
  ctrl->init();
  luaT_register(L, "sdl", sdllib);
  for (auto reg = sdllib_with_upvalue.begin(); reg->name; ++reg) {
    lua_pushvalue(L, -2);
    luaT_pushcclosure(L, reg->func, 1);
    lua_setfield(L, -2, reg->name);
  }

  load_extra(L, "audio", luaopen_sdl_audio);
  load_extra(L, "wm", luaopen_sdl_wm);

  return 1;
}
