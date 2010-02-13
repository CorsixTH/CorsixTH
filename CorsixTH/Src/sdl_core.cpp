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
#include "th_lua.h"
#include <string.h>
#ifndef _MSC_VER
#define stricmp strcasecmp
#else
#pragma warning (disable: 4996) // CRT deprecation
#endif

static int l_init(lua_State *L)
{
    Uint32 flags = 0;
    int i;
    int argc = lua_gettop(L);
    for(i = 1; i <= argc; ++i)
    {
        const char* s = luaL_checkstring(L, i);
        if(stricmp(s, "video") == 0)
            flags |= SDL_INIT_VIDEO;
        else if(stricmp(s, "audio") == 0)
            flags |= SDL_INIT_AUDIO;
        else if(stricmp(s, "timer") == 0)
            flags |= SDL_INIT_TIMER;
        else if(stricmp(s, "*") == 0)
            flags |= SDL_INIT_EVERYTHING;
        else
            luaL_argerror(L, i, "Expected SDL part name");
    }
    if(SDL_Init(flags) != 0)
    {
        lua_pushboolean(L, 0);
        return 1;
    }
    luaT_addcleanup(L, SDL_Quit);
    lua_pushboolean(L, 1);
    return 1;
}

static Uint32 timer_frame_callback(Uint32 interval, void *param)
{
    SDL_Event e;
    e.type = SDL_USEREVENT_TICK;
    SDL_PushEvent(&e);
    return interval;
}

struct fps_ctrl
{
    bool limit_fps;
    bool track_fps;

    int q_front;
    int q_back;
    int frame_count;
    Uint32 frame_time[4096];

    void init()
    {
        limit_fps = true;
        track_fps = true;
        q_front = 0;
        q_back = 0;
        frame_count = 0;
    }

    void count_frame()
    {
        Uint32 now = SDL_GetTicks();
        frame_time[q_front] = now;
        q_front = (q_front + 1) % (sizeof(frame_time) / sizeof(*frame_time));
        if(q_front == q_back)
            q_back = (q_back + 1) % (sizeof(frame_time) / sizeof(*frame_time));
        else
            ++frame_count;
        if(now < 1000)
            now = 0;
        else
            now -= 1000;
        while(frame_time[q_back] < now)
        {
            --frame_count;
            q_back = (q_back + 1) % (sizeof(frame_time) / sizeof(*frame_time));
        }
    }
};

static int l_mainloop(lua_State *L)
{
    luaL_checktype(L, 1, LUA_TTHREAD);
    lua_State *dispatcher = lua_tothread(L, 1);

    fps_ctrl *fps_control = (fps_ctrl*)lua_touserdata(L, lua_upvalueindex(1));
    SDL_TimerID timer = SDL_AddTimer(30, timer_frame_callback, NULL);
    SDL_Event e;
    
    while(SDL_WaitEvent(&e) != 0)
    {
        bool do_frame = false;
        bool do_timer = false;
        do
        {
            int nargs;
            switch(e.type)
            {
            case SDL_QUIT:
                goto leave_loop;
            case SDL_KEYDOWN:
                lua_pushliteral(dispatcher, "keydown");
                lua_pushinteger(dispatcher, e.key.keysym.sym);
                nargs = 2;
                break;
            case SDL_KEYUP:
                lua_pushliteral(dispatcher, "keyup");
                lua_pushinteger(dispatcher, e.key.keysym.sym);
                nargs = 2;
                break;
            case SDL_MOUSEBUTTONDOWN:
                lua_pushliteral(dispatcher, "buttondown");
                lua_pushinteger(dispatcher, e.button.button);
                lua_pushinteger(dispatcher, e.button.x);
                lua_pushinteger(dispatcher, e.button.y);
                nargs = 4;
                break;
            case SDL_MOUSEBUTTONUP:
                lua_pushliteral(dispatcher, "buttonup");
                lua_pushinteger(dispatcher, e.button.button);
                lua_pushinteger(dispatcher, e.button.x);
                lua_pushinteger(dispatcher, e.button.y);
                nargs = 4;
                break;
            case SDL_MOUSEMOTION:
                lua_pushliteral(dispatcher, "motion");
                lua_pushinteger(dispatcher, e.motion.x);
                lua_pushinteger(dispatcher, e.motion.y);
                lua_pushinteger(dispatcher, e.motion.xrel);
                lua_pushinteger(dispatcher, e.motion.yrel);
                nargs = 5;
                break;
            case SDL_USEREVENT_MUSIC_OVER:
                lua_pushliteral(dispatcher, "music_over");
                nargs = 1;
                break;
            case SDL_USEREVENT_CPCALL:
#ifdef LUA_RIDX_CPCALL
                lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_CPCALL);
                lua_pushlightuserdata(L, &e.user.data1);
                lua_pushlightuserdata(L, e.user.data2);
                if(lua_pcall(L, 2, 0, 0))
#else
                if(lua_cpcall(L, (lua_CFunction)e.user.data1, e.user.data2))
#endif
                {
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
            default:
                nargs = 0;
                break;
            }
            if(nargs != 0)
            {
                if(lua_resume(dispatcher, nargs) != LUA_YIELD)
                {
                    goto leave_loop;
                }
                do_frame = do_frame || (lua_toboolean(dispatcher, 1) != 0);
                lua_settop(dispatcher, 0);
            }
        } while(SDL_PollEvent(&e) != 0);
        if(do_timer)
        {
            lua_pushliteral(dispatcher, "timer");
            if(lua_resume(dispatcher, 1) != LUA_YIELD)
            {
                break;
            }
            do_frame = do_frame || (lua_toboolean(dispatcher, 1) != 0);
            lua_settop(dispatcher, 0);
        }
        if(do_frame || !fps_control->limit_fps)
        {
            do
            {
                if(fps_control->track_fps)
                {
                    fps_control->count_frame();
                }
                lua_pushliteral(dispatcher, "frame");
                if(lua_resume(dispatcher, 1) != LUA_YIELD)
                {
                    goto leave_loop;
                }
                lua_settop(dispatcher, 0);
            } while(fps_control->limit_fps == false && SDL_PollEvent(NULL) == 0);
        }

        // No events pending - a good time to do a bit of garbage collection
        lua_gc(L, LUA_GCSTEP, 2);
    }

leave_loop:
    SDL_RemoveTimer(timer);
    int n = lua_gettop(dispatcher);
    if(lua_status(dispatcher) >= LUA_ERRRUN)
    {
        n = 1;
    }
    lua_checkstack(L, n);
    lua_xmove(dispatcher, L, n);
    return n;
}

static int l_track_fps(lua_State *L)
{
    fps_ctrl *ctrl = (fps_ctrl*)lua_touserdata(L, lua_upvalueindex(1));
    ctrl->track_fps = lua_isnone(L, 1) ? true : (lua_toboolean(L, 1) != 0);
    return 0;
}

static int l_limit_fps(lua_State *L)
{
    fps_ctrl *ctrl = (fps_ctrl*)lua_touserdata(L, lua_upvalueindex(1));
    ctrl->limit_fps = lua_isnone(L, 1) ? true : (lua_toboolean(L, 1) != 0);
    return 0;
}

static int l_get_fps(lua_State *L)
{
    fps_ctrl *ctrl = (fps_ctrl*)lua_touserdata(L, lua_upvalueindex(1));
    if(ctrl->track_fps)
    {
        lua_pushinteger(L, ctrl->frame_count);
    }
    else
    {
        lua_pushnil(L);
    }
    return 1;
}

static int l_get_ticks(lua_State *L)
{
    lua_pushinteger(L, (lua_Integer)SDL_GetTicks());
    return 1;
}

/**
	Enable or disable the keyboard modifier.
	
	Takes two parameters: delay and interval.
	
	If the delay == -1, then defaults are assumed.
	If the delay == 0, keyboard repeat is disabled.
*/
static int l_modify_keyboardrepeat(lua_State *L)
{
	int delay = (int)lua_tointeger(L, -1);
	lua_pop(L, 1);
	int interval = (int)lua_tointeger(L, -1);
	
	// Should we assume default values?
	if (interval == -1)
		interval = SDL_DEFAULT_REPEAT_INTERVAL; 
	if (delay == -1)
		delay  = SDL_DEFAULT_REPEAT_DELAY; 
	
    SDL_EnableKeyRepeat(delay, interval);
}

static const struct luaL_reg sdllib[] = {
    {"init", l_init},
    {"getTicks", l_get_ticks},
    {"modifyKeyboardRepeat", l_modify_keyboardrepeat},
    {NULL, NULL}
};
static const struct luaL_reg sdllib_with_upvalue[] = {
    {"mainloop", l_mainloop},
    {"getFPS", l_get_fps},
    {"trackFPS", l_track_fps},
    {"limitFPS", l_limit_fps},
    {NULL, NULL}
};

int luaopen_sdl_audio(lua_State *L);
int luaopen_sdl_wm(lua_State *L);

int luaopen_sdl(lua_State *L)
{
    fps_ctrl* ctrl = (fps_ctrl*)lua_newuserdata(L, sizeof(fps_ctrl));
    ctrl->init();
    luaL_register(L, "sdl", sdllib);
    const luaL_Reg *pUpvaluedFunctions = sdllib_with_upvalue;
    for(; pUpvaluedFunctions->name; ++pUpvaluedFunctions)
    {
        lua_pushvalue(L, -2);
        lua_pushcclosure(L, pUpvaluedFunctions->func, 1);
        lua_setfield(L, -2, pUpvaluedFunctions->name);
    }

    lua_pushcfunction(L, luaopen_sdl_audio);
    lua_call(L, 0, 1);
    lua_setfield(L, -2, "audio");

    lua_pushcfunction(L, luaopen_sdl_wm);
    lua_call(L, 0, 1);
    lua_setfield(L, -2, "wm");

    return 1;
}
