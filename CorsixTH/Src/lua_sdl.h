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

#ifndef CORSIX_TH_LUA_SDL_H_
#define CORSIX_TH_LUA_SDL_H_

#include "lua.hpp"
#include <SDL.h>

// SDL event codes used for delivering custom events to l_mainloop in
// sdl_core.cpp
// SDL_USEREVENT_TICK - informs script of a timer tick
#define SDL_USEREVENT_TICK (SDL_USEREVENT + 0)
// SDL_USEREVENT_MUSIC_OVER - informs script of SDL_Mixer music finishing
#define SDL_USEREVENT_MUSIC_OVER (SDL_USEREVENT + 1)
// SDL_USEREVENT_MUSIC_LOADED - informs script that async music is loaded
#define SDL_USEREVENT_MUSIC_LOADED (SDL_USEREVENT + 2)
// SDL USEREVENT_MOVIE_OVER - informs script of THMovie movie finishing
#define SDL_USEREVENT_MOVIE_OVER (SDL_USEREVENT + 3)
// SDL_USEREVENT_SOUND_OVER - informs script of a played sound finishing.
#define SDL_USEREVENT_SOUND_OVER (SDL_USEREVENT + 4)

int luaopen_sdl(lua_State *L);

int l_load_music_async_callback(lua_State *L);

#endif // CORSIX_TH_LUA_SDL_H_
