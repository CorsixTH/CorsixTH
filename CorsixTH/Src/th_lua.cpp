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

#include "th.h"
#include "th_lua_internal.h"
#include "bootstrap.h"
#include <string.h>

void THLuaRegisterAnims(const THLuaRegisterState_t *pState);
void THLuaRegisterGfx(const THLuaRegisterState_t *pState);
void THLuaRegisterMap(const THLuaRegisterState_t *pState);
void THLuaRegisterSound(const THLuaRegisterState_t *pState);
void THLuaRegisterMovie(const THLuaRegisterState_t *pState);
void THLuaRegisterStrings(const THLuaRegisterState_t *pState);
void THLuaRegisterUI(const THLuaRegisterState_t *pState);

//! Set a field on the environment table of an object
void luaT_setenvfield(lua_State *L, int index, const char *k)
{
    lua_getfenv(L, index);
    lua_pushstring(L, k);
    lua_pushvalue(L, -3);
    lua_settable(L, -3);
    lua_pop(L, 2);
}

//! Get a field from the environment table of an object
void luaT_getenvfield(lua_State *L, int index, const char *k)
{
    lua_getfenv(L, index);
    lua_getfield(L, -1, k);
    lua_replace(L, -2);
}

#if LUA_VERSION_NUM >= 502
void luaT_getfenv52(lua_State *L, int iIndex)
{
    int iType = lua_type(L, iIndex);
    switch(iType)
    {
    case LUA_TUSERDATA:
        lua_getenv(L, iIndex);
        break;
    case LUA_TFUNCTION:
        if(lua_iscfunction(L, iIndex))
        {
            // Our convention: upvalue at #1 is environment
            if(lua_getupvalue(L, iIndex, 1) == NULL)
                lua_pushglobaltable(L);
        }
        else
        {
            // Language convention: upvalue called _ENV is environment
            const char* sUpName = NULL;
            for(int i = 1; (sUpName = lua_getupvalue(L, iIndex, i)) ; ++i)
            {
                if(strcmp(sUpName, "_ENV") == 0)
                    return;
                else
                    lua_pop(L, 1);
            }
            lua_pushglobaltable(L);
        }
        break;
    default:
        luaL_error(L, "Unable to get environment of a %s in 5.2", lua_typename(L, iType));
        break;
    }
}

int luaT_setfenv52(lua_State *L, int iIndex)
{
    int iType = lua_type(L, iIndex);
    switch(iType)
    {
    case LUA_TUSERDATA:
        lua_setenv(L, iIndex);
        return 1;
    case LUA_TFUNCTION:
        if(lua_iscfunction(L, iIndex))
        {
            // Our convention: upvalue at #1 is environment
            if(lua_setupvalue(L, iIndex, 1) == NULL)
            {
                lua_pop(L, 1);
                return 0;
            }
            return 1;
        }
        else
        {
            // Language convention: upvalue called _ENV is environment, which
            // might be shared with other functions.
            const char* sUpName = NULL;
            for(int i = 1; (sUpName = lua_getupvalue(L, iIndex, i)) ; ++i)
            {
                if(strcmp(sUpName, "_ENV") == 0)
                {
                    luaL_loadstring(L, "local upv = ... return function() return upv end");
                    lua_insert(L, -2);
                    lua_call(L, 1, 1);
                    lua_upvaluejoin(L, iIndex, i, -1, 1);
                    lua_pop(L, 1);
                    return 1;
                }
                else
                    lua_pop(L, 1);
            }
            return 0;
        }
    default:
        return 0;
    }
}

void luaT_pushcclosure(lua_State* L, lua_CFunction f, int nups)
{
    ++nups;
    lua_pushvalue(L, luaT_environindex);
    lua_insert(L, -nups);
    lua_pushcclosure(L, f, nups);
}

#endif

//! Push a C closure as a callable table
void luaT_pushcclosuretable(lua_State *L, lua_CFunction fn, int n)
{
    luaT_pushcclosure(L, fn, n); // .. fn <top
    lua_createtable(L, 0, 1); // .. fn mt <top
    lua_pushliteral(L, "__call"); // .. fn mt __call <top
    lua_pushvalue(L, -3); // .. fn mt __call fn <top
    lua_settable(L, -3); // .. fn mt <top
    lua_newtable(L); // .. fn mt t <top
    lua_replace(L, -3); // .. t mt <top
    lua_setmetatable(L, -2); // .. t <top
}

void luaT_addcleanup(lua_State *L, void(*fnCleanup)(void))
{
    lua_checkstack(L, 2);
    lua_getfield(L, LUA_REGISTRYINDEX, "_CLEANUP");
    int idx = 1 + (int)lua_objlen(L, -1);
    lua_pushlightuserdata(L, (void*)fnCleanup);
    lua_rawseti(L, -2, idx);
    lua_pop(L, 1);
}

//! Check for a string or userdata
const unsigned char* luaT_checkfile(lua_State *L, int idx, size_t* pDataLen)
{
    const unsigned char *pData;
    size_t iLength;
    if(lua_type(L, idx) == LUA_TUSERDATA)
    {
        pData = (const unsigned char*)lua_touserdata(L, idx);
        iLength = lua_objlen(L, idx);
    }
    else
    {
        pData = (const unsigned char*)luaL_checklstring(L, idx, &iLength);
    }
    if(pDataLen != 0)
        *pDataLen = iLength;
    return pData;
}

static int l_load_strings(lua_State *L)
{
    size_t iDataLength;
    const unsigned char* pData = luaT_checkfile(L, 1, &iDataLength);

    THStringList oStrings;
    if(!oStrings.loadFromTHFile(pData, iDataLength))
    {
        lua_pushboolean(L, 0);
        return 1;
    }

    lua_settop(L, 0);
    lua_createtable(L, (int)oStrings.getSectionCount(), 0);
    for(unsigned int iSec = 0; iSec < oStrings.getSectionCount(); ++iSec)
    {
        unsigned int iCount = oStrings.getSectionSize(iSec);
        lua_createtable(L, (int)iCount, 0);
        for(unsigned int iStr = 0; iStr < iCount; ++iStr)
        {
            lua_pushstring(L, oStrings.getString(iSec, iStr));
            lua_rawseti(L, 2, (int)(iStr + 1));
        }
        lua_rawseti(L, 1, (int)(iSec + 1));
    }
    return 1;
}

static int get_api_version()
{
#include "../Lua/api_version.lua"
}

static int l_get_compile_options(lua_State *L)
{
    lua_settop(L, 0);
    lua_newtable(L);

#ifdef CORSIX_TH_64BIT
    lua_pushboolean(L, 1);
#else
    lua_pushboolean(L, 0);
#endif
    lua_setfield(L, -2, "arch_64");

    lua_pushliteral(L, "SDL");
    lua_setfield(L, -2, "renderer");

#ifdef CORSIX_TH_USE_SDL_MIXER
    lua_pushboolean(L, 1);
#else
    lua_pushboolean(L, 0);
#endif
    lua_setfield(L, -2, "audio");

    lua_getfield(L, LUA_REGISTRYINDEX, "_LOADED");
    lua_getfield(L, -1, "jit");
    if(lua_type(L, -1) == LUA_TNIL)
    {
        lua_replace(L, -2);
    }
    else
    {
        lua_getfield(L, -1, "version");
        lua_replace(L, -3);
        lua_pop(L, 1);
    }
    lua_setfield(L, -2, "jit");

    lua_pushinteger(L, get_api_version());
    lua_setfield(L, -2, "api_version");

    return 1;
}

void luaT_setclosure(const THLuaRegisterState_t *pState, lua_CFunction fn,
                     eTHLuaMetatable eMetatable1, ...)
{
    int iUpCount = 0;
    va_list args;
    for(va_start(args, eMetatable1);
        eMetatable1 != MT_Count;
        eMetatable1 = static_cast<eTHLuaMetatable>(va_arg(args, int)))
    {
        if(eMetatable1 == MT_DummyString)
            lua_pushstring(pState->L, va_arg(args, char*));
        else
            lua_pushvalue(pState->L, pState->aiMetatables[eMetatable1]);
        ++iUpCount;
    }
    va_end(args);
    luaT_pushcclosure(pState->L, fn, iUpCount);
}

int luaopen_th(lua_State *L)
{
    lua_settop(L, 0);
    lua_checkstack(L, 16 + static_cast<int>(MT_Count));

    THLuaRegisterState_t oState;
    const THLuaRegisterState_t *pState = &oState;
    oState.L = L;
    for(int i = 0; i < static_cast<int>(MT_Count); ++i)
    {
        lua_createtable(L, 0, 5);
        oState.aiMetatables[i] = lua_gettop(L);
    }
    lua_createtable(L, 0, lua_gettop(L));
    oState.iMainTable = lua_gettop(L);
    oState.iTop = lua_gettop(L);

    // Misc. functions
    lua_settop(L, oState.iTop);
    luaT_setfunction(l_load_strings, "LoadStrings");
    luaT_setfunction(l_get_compile_options, "GetCompileOptions");
    luaT_setfunction(Bootstrap_lua_resources, "GetBuiltinFont");

    // Classes
    THLuaRegisterMap(pState);
    THLuaRegisterGfx(pState);
    THLuaRegisterAnims(pState);
    THLuaRegisterSound(pState);
    THLuaRegisterMovie(pState);
    THLuaRegisterStrings(pState);
    THLuaRegisterUI(pState);

    lua_settop(L, oState.iMainTable);
    return 1;
}

void luaT_execute_loadstring(lua_State *L, const char* sLuaString)
{
    static const int iRegistryCacheIndex = 7;
    lua_rawgeti(L, LUA_REGISTRYINDEX, iRegistryCacheIndex);
    if(lua_isnil(L, -1))
    {
        // Cache not yet created - create it.
        lua_pop(L, 1);
        lua_getglobal(L, "setmetatable");
        if(lua_isnil(L, -1))
        {
            // Base library not yet loaded - fallback to simple
            // uncached loadstring
            lua_pop(L, 1);
            if(luaL_loadstring(L, sLuaString))
                lua_error(L);
        }
        lua_pop(L, 1);
        luaL_loadstring(L, "local assert, loadstring = assert, loadstring\n"
            "return setmetatable({}, {__mode = [[v]], \n"
            "__index = function(t, k)\n"
                "local v = assert(loadstring(k))\n"
                "t[k] = v\n"
                "return v\n"
            "end})");
        lua_call(L, 0, 1);
        lua_pushvalue(L, -1);
        lua_rawseti(L, LUA_REGISTRYINDEX, iRegistryCacheIndex);
    }
    lua_getfield(L, -1, sLuaString);
    lua_replace(L, -2);
}

void luaT_execute(lua_State *L, const char* sLuaString)
{
    luaT_execute_loadstring(L, sLuaString);
    lua_call(L, 0, LUA_MULTRET);
}

void luaT_push(lua_State *L, lua_CFunction f)
{
    luaT_pushcfunction(L, f);
}

void luaT_push(lua_State *L, int i)
{
    lua_pushinteger(L, (lua_Integer)i);
}

void luaT_push(lua_State *L, const char* s)
{
    lua_pushstring(L, s);
}

void luaT_pushtablebool(lua_State *L, const char *k, bool v)
{
    lua_pushstring(L, k);
    lua_pushboolean(L, v);
    lua_settable(L, -3);
}
