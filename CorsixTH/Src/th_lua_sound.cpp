/*
Copyright (c) 2010 Peter "Corsix" Cawley

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
#include "th_sound.h"
#include "th_lua.h"
#include "lua_sdl.h"
#include <cstring>
#include <map>
#include <cctype>

static int played_sound_callback_ids[1000];
static int played_sound_callback_index = 0;
static std::map<int,SDL_TimerID> map_sound_timers;

static int l_soundarc_new(lua_State *L)
{
    luaT_stdnew<sound_archive>(L, luaT_environindex, true);
    return 1;
}

static int l_soundarc_load(lua_State *L)
{
    sound_archive* pArchive = luaT_testuserdata<sound_archive>(L);
    size_t iDataLen;
    const uint8_t* pData = luaT_checkfile(L, 2, &iDataLen);

    if(pArchive->load_from_th_file(pData, iDataLen))
        lua_pushboolean(L, 1);
    else
        lua_pushboolean(L, 0);
    return 1;
}

static int l_soundarc_count(lua_State *L)
{
    sound_archive* pArchive = luaT_testuserdata<sound_archive>(L);
    lua_pushnumber(L, (lua_Number)pArchive->get_number_of_sounds());
    return 1;
}

/**
 * Perform case-insensitive string compare.
 * @param s1 First string to compare.
 * @param s2 Second string to compare.
 * @return Negative number when \a s1 should be before \a s2, zero if both
 *      string are equal, else a positive number.
 */
static int ignorecase_cmp(const char *s1, const char *s2)
{
    while(*s1 && *s2)
    {
        if (std::tolower(*s1) != std::tolower(*s2))
            break;

        s1++;
        s2++;
    }
    return std::tolower(*s1) - std::tolower(*s2);
}

static size_t l_soundarc_checkidx(lua_State *L, int iArg, sound_archive* pArchive)
{
    if(lua_isnumber(L, iArg))
    {
        size_t iIndex = (size_t)lua_tonumber(L, iArg);
        if(iIndex >= pArchive->get_number_of_sounds())
        {
            lua_pushnil(L);
            lua_pushfstring(L, "Sound index out of "
                "bounds (%f is not in range [0, %d])", lua_tonumber(L, iArg),
                static_cast<int>(pArchive->get_number_of_sounds()) - 1);
            return pArchive->get_number_of_sounds();
        }
        return iIndex;
    }
    const char* sName = luaL_checkstring(L, iArg);
    lua_getfenv(L, 1);
    lua_pushvalue(L, iArg);
    lua_rawget(L, -2);
    if(lua_type(L, -1) == LUA_TLIGHTUSERDATA)
    {
        size_t iIndex = (size_t)lua_topointer(L, -1);
        lua_pop(L, 2);
        return iIndex;
    }
    lua_pop(L, 2);
    size_t iCount = pArchive->get_number_of_sounds();
    for(size_t i = 0; i < iCount; ++i)
    {
        if(ignorecase_cmp(sName, pArchive->get_sound_name(i)) == 0)
        {
            lua_getfenv(L, 1);
            lua_pushvalue(L, iArg);
            lua_pushlightuserdata(L, (void*)i);
            lua_settable(L, -3);
            lua_pop(L, 1);
            return i;
        }
    }
    lua_pushnil(L);
    lua_pushliteral(L, "File not found in sound archive: ");
    lua_pushvalue(L, iArg);
    lua_concat(L, 2);
    return pArchive->get_number_of_sounds();
}

static int l_soundarc_sound_name(lua_State *L)
{
    sound_archive* pArchive = luaT_testuserdata<sound_archive>(L);
    size_t iIndex = l_soundarc_checkidx(L, 2, pArchive);
    if(iIndex == pArchive->get_number_of_sounds())
        return 2;
    lua_pushstring(L, pArchive->get_sound_name(iIndex));
    return 1;
}

static int l_soundarc_duration(lua_State *L)
{
    sound_archive* pArchive = luaT_testuserdata<sound_archive>(L);
    size_t iIndex = l_soundarc_checkidx(L, 2, pArchive);
    if(iIndex == pArchive->get_number_of_sounds())
        return 2;
    size_t iDuration = pArchive->get_sound_duration(iIndex);
    lua_pushnumber(L, static_cast<lua_Number>(iDuration) / static_cast<lua_Number>(1000));
    return 1;
}

static int l_soundarc_data(lua_State *L)
{
    sound_archive* pArchive = luaT_testuserdata<sound_archive>(L);
    size_t iIndex = l_soundarc_checkidx(L, 2, pArchive);
    if(iIndex == pArchive->get_number_of_sounds())
        return 2;
    SDL_RWops *pRWops = pArchive->load_sound(iIndex);
    if(!pRWops)
        return 0;
    size_t iLength = SDL_RWseek(pRWops, 0, SEEK_END);
    SDL_RWseek(pRWops, 0, SEEK_SET);
    // There is a potential leak of pRWops if either of these Lua calls cause
    // a memory error, but it isn't very likely, and this a debugging function
    // anyway, so it isn't very important.
    void *pBuffer = lua_newuserdata(L, iLength);
    lua_pushlstring(L, (const char*)pBuffer,
        SDL_RWread(pRWops, pBuffer, 1, iLength));
    SDL_RWclose(pRWops);
    return 1;
}

static int l_soundarc_sound_exists(lua_State *L)
{
    sound_archive* pArchive = luaT_testuserdata<sound_archive>(L);
    size_t iIndex = l_soundarc_checkidx(L, 2, pArchive);
    if(iIndex == pArchive->get_number_of_sounds())
        lua_pushboolean(L, 0);
    else
        lua_pushboolean(L, 1);
    return 1;
}

static int l_soundfx_new(lua_State *L)
{
    luaT_stdnew<sound_player>(L, luaT_environindex, true);
    return 1;
}

static int l_soundfx_set_archive(lua_State *L)
{
    sound_player *pEffects = luaT_testuserdata<sound_player>(L);
    sound_archive *pArchive = luaT_testuserdata<sound_archive>(L, 2);
    pEffects->populate_from(pArchive);
    lua_settop(L, 2);
    luaT_setenvfield(L, 1, "archive");
    return 1;
}

static int l_soundfx_set_sound_volume(lua_State *L)
{
    sound_player *pEffects = luaT_testuserdata<sound_player>(L);
    pEffects->set_sound_effect_volume(luaL_checknumber(L, 2));
    return 1;
}

static int l_soundfx_set_sound_effects_on(lua_State *L)
{
    sound_player *pEffects = luaT_testuserdata<sound_player>(L);
    pEffects->set_sound_effects_enabled(lua_toboolean(L, 2) != 0);
    return 1;
}

static Uint32 played_sound_callback(Uint32 interval, void* param)
{
    SDL_Event e;
    e.type = SDL_USEREVENT_SOUND_OVER;
    e.user.data1 = param;
    int iSoundID = *(static_cast<int*>(param));
    SDL_RemoveTimer(map_sound_timers[iSoundID]);
    map_sound_timers.erase(iSoundID);
    SDL_PushEvent(&e);

    return interval;
}

static int l_soundfx_play(lua_State *L)
{
    sound_player *pEffects = luaT_testuserdata<sound_player>(L);
    lua_settop(L, 7);
    lua_getfenv(L, 1);
    lua_pushliteral(L, "archive");
    lua_rawget(L,8);
    sound_archive *pArchive = (sound_archive*)lua_touserdata(L, 9);
    if(pArchive == nullptr)
    {
        return 0;
    }
    // l_soundarc_checkidx requires the archive at the bottom of the stack
    lua_replace(L, 1);
    size_t iIndex = l_soundarc_checkidx(L, 2, pArchive);
    if(iIndex == pArchive->get_number_of_sounds())
        return 2;
    if(lua_isnil(L, 4))
    {
        pEffects->play(iIndex, luaL_checknumber(L, 3));
    }
    else
    {
        pEffects->play_at(iIndex, luaL_checknumber(L, 3), static_cast<int>(luaL_checkinteger(L, 4)), static_cast<int>(luaL_checkinteger(L, 5)));
    }
    //SDL SOUND_OVER Callback Timer:
    //6: unusedPlayedCallbackID
    if(!lua_isnil(L, 6))
    {
        //7: Callback delay
        int iPlayedCallbackDelay = 0; //ms
        if(!lua_isnil(L, 7))
            iPlayedCallbackDelay = static_cast<int>(luaL_checknumber(L, 7));

        if(played_sound_callback_index == sizeof(played_sound_callback_ids))
            played_sound_callback_index = 0;

        played_sound_callback_ids[played_sound_callback_index] = static_cast<int>(luaL_checkinteger(L, 6));
        size_t interval = pArchive->get_sound_duration(iIndex) + iPlayedCallbackDelay;
        SDL_TimerID timersID = SDL_AddTimer(static_cast<Uint32>(interval),
                                            played_sound_callback,
                                            &(played_sound_callback_ids[played_sound_callback_index]));
        map_sound_timers.insert(std::pair<int, SDL_TimerID>(played_sound_callback_ids[played_sound_callback_index], timersID));
        played_sound_callback_index++;
    }

    lua_pushboolean(L, 1);
    return 1;
}

static int l_soundfx_set_camera(lua_State *L)
{
    sound_player *pEffects = luaT_testuserdata<sound_player>(L);
    pEffects->set_camera(static_cast<int>(luaL_checkinteger(L, 2)), static_cast<int>(luaL_checkinteger(L, 3)), static_cast<int>(luaL_checkinteger(L, 4)));
    return 0;
}

static int l_soundfx_reserve_channel(lua_State *L)
{
    int iChannel;
    sound_player *pEffects = luaT_testuserdata<sound_player>(L);
    iChannel = pEffects->reserve_channel();
    lua_pushinteger(L, iChannel);
    return 1;
}

static int l_soundfx_release_channel(lua_State *L)
{
    sound_player *pEffects = luaT_testuserdata<sound_player>(L);
    pEffects->release_channel(static_cast<int>(luaL_checkinteger(L, 2)));
    return 1;
}

void lua_register_sound(const lua_register_state *pState)
{
    // Sound Archive
    luaT_class(sound_archive, l_soundarc_new, "soundArchive", lua_metatable::sound_archive);
    luaT_setmetamethod(l_soundarc_count, "len");
    luaT_setfunction(l_soundarc_load, "load");
    luaT_setfunction(l_soundarc_sound_name, "getFilename"); // Bad name, doesn't represent a file
    luaT_setfunction(l_soundarc_duration, "getDuration");
    luaT_setfunction(l_soundarc_data, "getFileData"); // Bad name, doesn't represent a file
    luaT_setfunction(l_soundarc_sound_exists, "soundExists");
    luaT_endclass();

    // Sound Effects
    luaT_class(sound_player, l_soundfx_new, "soundEffects", lua_metatable::sound_fx);
    luaT_setfunction(l_soundfx_set_archive, "setSoundArchive", lua_metatable::sound_archive);
    luaT_setfunction(l_soundfx_play, "play");
    luaT_setfunction(l_soundfx_set_sound_volume, "setSoundVolume");
    luaT_setfunction(l_soundfx_set_sound_effects_on, "setSoundEffectsOn");
    luaT_setfunction(l_soundfx_set_camera, "setCamera");
    luaT_setfunction(l_soundfx_reserve_channel, "reserveChannel");
    luaT_setfunction(l_soundfx_release_channel, "releaseChannel");
    luaT_endclass();
}
