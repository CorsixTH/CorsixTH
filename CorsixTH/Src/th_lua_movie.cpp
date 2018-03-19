/*
Copyright (c) 2012 Stephen Baker

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

#include "th_lua_internal.h"
#include "th_movie.h"
#include "th_gfx.h"

static int l_movie_new(lua_State *L)
{
    luaT_stdnew<movie_player>(L, luaT_environindex, true);
    return 1;
}

static int l_movie_set_renderer(lua_State *L)
{
    movie_player *pMovie = luaT_testuserdata<movie_player>(L);
    render_target *pRenderTarget = luaT_testuserdata<render_target>(L, 2);
    pMovie->set_renderer(pRenderTarget->get_renderer());
    return 0;
}

static int l_movie_enabled(lua_State *L)
{
    movie_player *pMovie = luaT_testuserdata<movie_player>(L);
    lua_pushboolean(L, pMovie->movies_enabled());
    return 1;
}

static int l_movie_load(lua_State *L)
{
    bool loaded;
    const char* warning;
    movie_player *pMovie = luaT_testuserdata<movie_player>(L);
    const char* filepath = lua_tolstring(L, 2, nullptr);
    pMovie->clear_last_error();
    loaded = pMovie->load(filepath);
    warning = pMovie->get_last_error();
    lua_pushboolean(L, loaded);
    lua_pushstring(L, warning);
    return 2;
}

static int l_movie_unload(lua_State *L)
{
    movie_player *pMovie = luaT_testuserdata<movie_player>(L);
    pMovie->unload();
    return 0;
}

static int l_movie_play(lua_State *L)
{
    const char* warning;
    movie_player *pMovie = luaT_testuserdata<movie_player>(L);
    pMovie->clear_last_error();
    pMovie->play(
        static_cast<int>(luaL_checkinteger(L, 2)));
    warning = pMovie->get_last_error();
    lua_pushstring(L, warning);
    return 1;
}

static int l_movie_stop(lua_State *L)
{
    movie_player *pVideo = luaT_testuserdata<movie_player>(L);
    pVideo->stop();
    return 0;
}

static int l_movie_get_native_height(lua_State *L)
{
    movie_player *pMovie = luaT_testuserdata<movie_player>(L);
    lua_pushinteger(L, pMovie->get_native_height());
    return 1;
}

static int l_movie_get_native_width(lua_State *L)
{
    movie_player *pMovie = luaT_testuserdata<movie_player>(L);
    lua_pushinteger(L, pMovie->get_native_width());
    return 1;
}

static int l_movie_has_audio_track(lua_State *L)
{
    movie_player *pMovie = luaT_testuserdata<movie_player>(L);
    lua_pushboolean(L, pMovie->has_audio_track());
    return 1;
}

static int l_movie_refresh(lua_State *L)
{
    movie_player *pMovie = luaT_testuserdata<movie_player>(L);
    pMovie->refresh(SDL_Rect{
            static_cast<int>(luaL_checkinteger(L, 2)),
            static_cast<int>(luaL_checkinteger(L, 3)),
            static_cast<int>(luaL_checkinteger(L, 4)),
            static_cast<int>(luaL_checkinteger(L, 5)) });
    return 0;
}

static int l_movie_allocate_picture_buffer(lua_State *L)
{
    movie_player *pMovie = luaT_testuserdata<movie_player>(L);
    pMovie->allocate_picture_buffer();
    return 0;
}

static int l_movie_deallocate_picture_buffer(lua_State *L)
{
    movie_player *pMovie = luaT_testuserdata<movie_player>(L);
    pMovie->deallocate_picture_buffer();
    return 0;
}

void lua_register_movie(const lua_register_state *pState)
{
    luaT_class(movie_player, l_movie_new, "moviePlayer", lua_metatable::movie);
    luaT_setfunction(l_movie_set_renderer, "setRenderer", lua_metatable::surface);
    luaT_setfunction(l_movie_enabled, "getEnabled");
    luaT_setfunction(l_movie_load, "load");
    luaT_setfunction(l_movie_unload, "unload");
    luaT_setfunction(l_movie_play, "play");
    luaT_setfunction(l_movie_stop, "stop");
    luaT_setfunction(l_movie_get_native_height, "getNativeHeight");
    luaT_setfunction(l_movie_get_native_width, "getNativeWidth");
    luaT_setfunction(l_movie_has_audio_track, "hasAudioTrack");
    luaT_setfunction(l_movie_refresh, "refresh");
    luaT_setfunction(l_movie_allocate_picture_buffer, "allocatePictureBuffer");
    luaT_setfunction(l_movie_deallocate_picture_buffer, "deallocatePictureBuffer");
    luaT_endclass();
}
