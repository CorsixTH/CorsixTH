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

#include "th_lua_internal.h"

void THLuaRegisterAnims(const THLuaRegisterState_t *pState);
void THLuaRegisterGfx(const THLuaRegisterState_t *pState);
void THLuaRegisterMap(const THLuaRegisterState_t *pState);
void THLuaRegisterSound(const THLuaRegisterState_t *pState);
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

//! Push a C closure as a callable table
void luaT_pushcclosuretable(lua_State *L, lua_CFunction fn, int n)
{
    lua_pushcclosure(L, fn, n); // .. fn <top
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

#if defined(CORSIX_TH_USE_OGL_RENDERER)
    lua_pushliteral(L, "OpenGL");
#elif defined(CORSIX_TH_USE_DX9_RENDERER)
    lua_pushliteral(L, "DirectX 9");
#elif defined(CORSIX_TH_USE_SDL_RENDERER)
    lua_pushliteral(L, "SDL");
#else
    lua_pushliteral(L, "Unknown");
#endif
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
    lua_pushcclosure(pState->L, fn, iUpCount);
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

    // Classes
    THLuaRegisterMap(pState);
    THLuaRegisterGfx(pState);
    THLuaRegisterAnims(pState);
    THLuaRegisterSound(pState);
    THLuaRegisterStrings(pState);
    THLuaRegisterUI(pState);

    lua_settop(L, oState.iMainTable);
    return 1;
}
