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
#include "persist_lua.h"
#include <string.h>

/*
    This file implements a string proxy system. A string proxy is a userdata
    which behaves like a string or a table, but records how it was made, and
    is serialised as this list of instructions, rather than as the resulting
    value. The application for this lies in persisting localised strings, as
    the language in use at depersist-time may be different to the one in use
    at persist-time.

    First note that such a proxy must be a userdata (in order to have custom
    persistance behaviour and a full complement of metamethods). At the same
    time, there is no C data which the userdata needs to hold, so the C part
    of the userdata can be empty. The Lua part of the userdata needs to hold
    the current proxied value and the instructions for recreating the value.
    When the proxied value is a table, then in addition, the Lua part of the
    userdata needs to store a cache of proxies for its children to avoid the
    situation of regularly creating new proxies for children. Due to how the
    persistance library deals with userdata, the Lua parts of these userdata
    cannot be held in the userdata's environment table, so instead the idiom
    of inside-out objects needs to be used. The principle idea of inside-out
    objects is that environment(obj).field becomes metatable(obj).field[obj]
    The Value, ReconstructInfo, and Cache weak tables for inside-out objects
    are at MT_StringProxy[1], MT_StringProxy[2], and MT_StringProxy[3].
*/

struct THStringProxy_t {};

// Replace the value at the top of the stack with a userdata proxy
static int l_str_new_aux(lua_State *L)
{
    luaT_stdnew<THStringProxy_t>(L);
    lua_rawgeti(L, LUA_ENVIRONINDEX, 1);
    lua_pushvalue(L, -2);
    lua_pushvalue(L, -4);
    lua_rawset(L, -3);
    lua_pop(L, 1);
    lua_replace(L, -2);
    return 1;
}

// Create a new root-level userdata proxy
static int l_str_new(lua_State *L)
{
    lua_remove(L, 1); // Value inserted by __call
    luaL_checkany(L, 1); // Value to be proxied
    lua_settop(L, 1);
    return l_str_new_aux(L);
}

// Helper function to make an array in Lua
static void aux_mk_table(lua_State *L, int nliterals, int nvalues, ...)
{
    lua_createtable(L, nliterals + nvalues, 0);
    va_list args;
    va_start(args, nvalues);
    for(int i = 1; i <= nliterals; ++i)
    {
        const char *sStr = va_arg(args, const char*);
        lua_pushstring(L, sStr);
        lua_rawseti(L, -2, i);
    }
    for(int i = nliterals + 1; i <= nliterals + nvalues; ++i)
    {
        int iValue = va_arg(args, int);
        if(0 > iValue && iValue > LUA_REGISTRYINDEX)
            --iValue;
        lua_pushvalue(L, iValue);
        lua_rawseti(L, -2, i);
    }
    va_end(args);
}

// Helper function which pushes onto the stack a random key from the table
// (previously) on the top of the stack.
static void aux_push_random_key(lua_State *L)
{
    int iNKeys = 0;
    lua_newtable(L);
    lua_getglobal(L, "pairs");
    lua_pushvalue(L, -3);
    lua_call(L, 1, 3);
    while(true)
    {
        lua_pushvalue(L, -3);
        lua_pushvalue(L, -3);
        lua_pushvalue(L, -3);
        lua_remove(L, -4);
        lua_call(L, 2, 1);
        if(lua_isnil(L, -1))
            break;
        ++iNKeys;
        lua_pushvalue(L, -1);
        lua_rawseti(L, -5, iNKeys);
    }
    lua_pop(L, 3);
    lua_getglobal(L, "math");
    lua_getfield(L, -1, "random");
    lua_pushinteger(L, 1);
    lua_pushinteger(L, iNKeys);
    lua_call(L, 2, 1);
    lua_gettable(L, -3);
    lua_replace(L, -3);
    lua_pop(L, 1);
}

// __index metamethod handler.
// For proxied tables, return proxies of children, preferably cached
// For proxied strings, return methods
static int l_str_index(lua_State *L)
{
    // Look up cached value, and return it if present
    lua_rawgeti(L, LUA_ENVIRONINDEX, 3);
    lua_pushvalue(L, 1);
    lua_gettable(L, 3);
    lua_replace(L, 3);
    lua_pushvalue(L, 2);
    lua_rawget(L, 3);
    if(!lua_isnil(L, 4))
        return 1;
    lua_pop(L, 1);

    // Fetch the proxied value
    lua_rawgeti(L, LUA_ENVIRONINDEX, 1);
    lua_pushvalue(L, 1);
    lua_rawget(L, 4);
    lua_replace(L, 4);

    // Handle string methods
    if(lua_type(L, 4) == LUA_TSTRING)
    {
        lua_rawgeti(L, LUA_ENVIRONINDEX, 4);
        lua_pushvalue(L, 2);
        lua_gettable(L, 4);
        return 1;
    }

    // Handle __random, as it shouldn't be cached
    if(lua_type(L, 2) == LUA_TSTRING)
    {
        size_t iLen;
        const char* sKey = lua_tolstring(L, 2, &iLen);
        if(iLen == 8 && strcmp(sKey, "__random") == 0)
        {
            aux_push_random_key(L);
            lua_replace(L, 2);
            lua_settop(L, 2);
            return l_str_index(L);
        }
    }
    
    // Fetch desired value
    lua_pushvalue(L, 2);
    lua_gettable(L, 4);
    lua_replace(L, 4);

    // Create new userdata proxy
    l_str_new_aux(L);
    lua_rawgeti(L, LUA_ENVIRONINDEX, 2);
    lua_pushvalue(L, 4);
    aux_mk_table(L, 0, 2, 1, 2);
    lua_rawset(L, 5);
    lua_settop(L, 4);

    // Save to cache and return
    lua_pushvalue(L, 2);
    lua_pushvalue(L, 4);
    lua_rawset(L, 3);
    return 1;
}

// __newindex metamethod handler
static int l_str_newindex(lua_State *L)
{
    return luaL_error(L, "String tables are read-only");
}

// Generic string method handler
// The name of the method is stored at upvalue 1
static int l_str_func(lua_State *L)
{
    int iArgCount = lua_gettop(L);
    lua_checkstack(L, iArgCount + 10);

    int iUserdataCount = 0;

    // Construct the resulting value
    lua_rawgeti(L, LUA_ENVIRONINDEX, 1);
    for(int i = 1; i <= iArgCount; ++i)
    {
        lua_pushvalue(L, i);
        if(lua_type(L, i) == LUA_TUSERDATA)
        {
            lua_rawget(L, iArgCount + 1);
            ++iUserdataCount;
        }
    }
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_gettable(L, iArgCount + 2);
    lua_replace(L, iArgCount + 1);
    lua_call(L, iArgCount, 1);

    // Trivial case of result not depending upon any proxies
    if(iUserdataCount == 0)
        return 1;

    // Wrap result in a proxy
    l_str_new_aux(L);

    // Create and save reconstruction information
    lua_rawgeti(L, LUA_ENVIRONINDEX, 2);
    lua_pushvalue(L, -2);
    lua_createtable(L, iArgCount + 1, 0);
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_rawseti(L, -2, 1);
    for(int i = 1; i <= iArgCount; ++i)
    {
        lua_pushvalue(L, i);
        lua_rawseti(L, -2, i + 1);
    }
    lua_rawset(L, -3);
    lua_pop(L, 1);

    return 1;
}

// __concat metamethod handler
// Simple (but inefficient) handling by converting concat into format
static int l_str_concat(lua_State *L)
{
    int iParent = (lua_type(L, 1) == LUA_TUSERDATA) ? 1 : 2;
    lua_getfield(L, iParent, "format");
    lua_insert(L, 1);
    lua_pushliteral(L, "%s%s");
    lua_insert(L, 2);
    lua_call(L, 3, 1);
    return 1;
}

// pairs() metamethod handler
static int l_str_pairs(lua_State *L)
{
    lua_settop(L, 1);
    lua_getfield(L, LUA_ENVIRONINDEX, "__next");
    lua_pushvalue(L, 1);
    lua_pushnil(L);
    return 3;
}

// ipairs() metamethod handler
static int l_str_ipairs(lua_State *L)
{
    lua_settop(L, 1);
    lua_getfield(L, LUA_ENVIRONINDEX, "__inext");
    lua_pushvalue(L, 1);
    lua_pushinteger(L, 0);
    return 3;
}

// pairs() iterator function
static int l_str_next(lua_State *L)
{
    luaL_checktype(L, 1, LUA_TUSERDATA);
    lua_settop(L, 2);

    // Fetch proxied value
    lua_rawgeti(L, LUA_ENVIRONINDEX, 1);
    lua_pushvalue(L, 1);
    lua_rawget(L, 3);

    // Remove layer of proxying done in Lua
    // NB: Assumes that pairs(t) returns 3 values: next, t, nil
    // In our case, the returned t should be the raw (unproxied) one
    lua_getglobal(L, "pairs");
    lua_replace(L, 3);
    lua_call(L, 1, 2);

    // Get the next key
    lua_pushvalue(L, 2);
    lua_call(L, 2, 1);
    if(lua_isnil(L, -1))
        return 0;

    // Get the (proxied) value which goes with the key
    lua_pushvalue(L, -1);
    lua_gettable(L, 1);
    return 2;
}

// __len metamethod handler
static int l_str_len(lua_State *L)
{
    luaL_checktype(L, 1, LUA_TUSERDATA);

    // Fetch proxied value
    lua_rawgeti(L, LUA_ENVIRONINDEX, 1);
    lua_pushvalue(L, 1);
    lua_gettable(L, -2);

    // String tables are proxied in Lua, and Lua tables do not honour __len
    // so use ipairs to get the unproxied table to call __len on.
    if(lua_type(L, -1) == LUA_TTABLE)
    {
        lua_getglobal(L, "ipairs");
        lua_insert(L, -2);
        lua_call(L, 1, 2);
        lua_replace(L, -2);
    }

    lua_pushinteger(L, (lua_Integer)lua_objlen(L, -1));
    return 1;
}

// ipairs() iterator function
static int l_str_inext(lua_State *L)
{
    lua_Integer n = luaL_checkinteger(L, 2) + 1;
    lua_settop(L, 1);
    l_str_len(L);
    lua_Integer len = lua_tointeger(L, -1);

    if(n > len)
        return 0;

    // Fetch proxied value
    lua_settop(L, 2);
    lua_pushvalue(L, 1);
    lua_gettable(L, 2);

    // Return new N and the proxied value which goes it
    lua_pushinteger(L, n);
    lua_pushinteger(L, n);
    lua_gettable(L, 1);
    return 2;
}

// tostring() metamethod handler for debugging / diagnostics
static int l_str_tostring(lua_State *L)
{
    // Convert the proxy to a string
    luaT_checkstring(L, 1, NULL);

    // Prepend a nice message indicating that proxying is being done
    lua_settop(L, 1);
    lua_pushliteral(L, "<LocalisedString> Current value:");
    lua_insert(L, 1);
    lua_concat(L, 2);
    return 1;
}

// __call metamethod handler
// Required to support the compatibility hack for calling _S
static int l_str_call(lua_State *L)
{
    luaL_checkany(L, 1);
    
    // Fetch the proxied value
    lua_rawgeti(L, LUA_ENVIRONINDEX, 1);
    lua_pushvalue(L, 1);
    lua_rawget(L, -2);

    // Forward the call onto the proxied value
    lua_replace(L, 1);
    lua_call(L, lua_gettop(L) - 1, LUA_MULTRET);
    return lua_gettop(L);
}

// __lt (less-than) metamethod handler
// Provided so that a list of localised strings can be sorted, which is used
// to create nice user-interface listing of strings. Note that this will mean
// that persist->change language->depersist will result in a "random" ordering
// of the resulting list, but this is generally acceptable.
static int l_str_lt(lua_State *L)
{
    luaL_checkany(L, 1);
    luaL_checkany(L, 2);
    lua_settop(L, 2);
    lua_rawgeti(L, LUA_ENVIRONINDEX, 1);
    lua_pushvalue(L, 1);
    lua_rawget(L, 3);
    lua_pushvalue(L, 2);
    lua_rawget(L, 3);
    lua_pushboolean(L, lua_lessthan(L, 4, 5));
    return 1;
}

// __persist metamethod handler
static int l_str_persist(lua_State *L)
{
    lua_settop(L, 2);
    lua_insert(L, 1);
    LuaPersistWriter *pWriter = (LuaPersistWriter*)lua_touserdata(L, 1);

    // Write the instructions for re-creating the value
    lua_rawgeti(L, LUA_ENVIRONINDEX, 2);
    lua_pushvalue(L, 2);
    lua_rawget(L, 3);
    pWriter->writeStackObject(4);

    // If there were no instructions (i.e. for the root object) then write the
    // value as well.
    if(lua_isnil(L, -1))
    {
        lua_pop(L, 2);
        lua_rawgeti(L, LUA_ENVIRONINDEX, 1);
        lua_pushvalue(L, 2);
        lua_rawget(L, 3);
        pWriter->writeStackObject(4);
    }
    return 0;
}

// __depersist metamethod handler
static int l_str_depersist(lua_State *L)
{
    lua_settop(L, 2);
    lua_insert(L, 1);
    LuaPersistReader *pReader = (LuaPersistReader*)lua_touserdata(L, 1);

    // Read the instructions for re-creating the value
    if(!pReader->readStackObject())
        return 0;

    // Prepare t, k for saving the value
    lua_rawgeti(L, LUA_ENVIRONINDEX, 1);
    lua_pushvalue(L, 2);

    if(lua_isnil(L, 3))
    {
        // No instructions provided, so read the value itself
        if(!pReader->readStackObject())
            return 0;
    }
    else
    {
        // The instructions are a table of values; unpack them and replace
        // proxies with their values.
        bool bIsIndexOperation = false;
        int iCount = lua_objlen(L, 3);
        lua_checkstack(L, iCount + 1);
        for(int i = 1; i <= iCount; ++i)
        {
            lua_rawgeti(L, 3, i);
            if(lua_type(L, -1) == LUA_TUSERDATA)
            {
                if(i == 1)
                    bIsIndexOperation = true;
                lua_rawget(L, 4);
            }
        }

        if(iCount == 2 && bIsIndexOperation)
        {
            // If there were two values, and the first was a proxy, then the
            // instruction is to perform a table lookup.
            lua_gettable(L, -2);
            lua_replace(L, -2);
        }
        else
        {
            // Otherwise, the first value was a method name.
            lua_pushvalue(L, 6);
            lua_gettable(L, 7);
            lua_replace(L, 6);
            lua_call(L, iCount - 1, 1);
        }
    }

    // Save the value
    lua_rawset(L, 4);
    return 0;
}

const char* luaT_checkstring(lua_State *L, int idx, size_t* pLength)
{
    // NB: Cannot use LUA_ENVIRONINDEX, so use userdata metatable
    if(lua_isuserdata(L, idx) && lua_getmetatable(L, idx))
    {
        lua_rawgeti(L, -1, 1);
        if(!lua_isnil(L, -1))
        {
            bool bRel = (0 > idx && idx > LUA_REGISTRYINDEX);
            lua_pushvalue(L, bRel ? (idx - 2) : idx);
            lua_rawget(L, -2);
            lua_replace(L, bRel ? (idx - 3) : idx);
        }
        lua_pop(L, 2);
    }
    return luaL_checklstring(L, idx, pLength);
}

static int l_mk_cache(lua_State *L)
{
    lua_newtable(L);
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_setmetatable(L, -2);
    lua_pushvalue(L, 2);
    lua_pushvalue(L, 3);
    lua_settable(L, 1);
    return 1;
}

void THLuaRegisterStrings(const THLuaRegisterState_t *pState)
{
    lua_State *L = pState->L;

    // Create Value, ReconstructInfo, and Cache weak tables for inside-out
    // objects at MT_StringProxy[1], MT_StringProxy[2], and MT_StringProxy[3]
    for(int i = 1; i <= 3; ++i)
    {
        lua_newtable(L);
        lua_createtable(L, 0, 1);
        lua_pushliteral(L, "__mode");
        lua_pushliteral(L, "k");
        lua_rawset(L, -3);
        if(i == 3)
        {
            // Have the cache weak table automatically create caches on demand
            lua_pushliteral(L, "__index");
            lua_createtable(L, 0, 1);
            lua_pushliteral(L, "__mode");
            lua_pushliteral(L, "kv");
            lua_rawset(L, -3);
            lua_pushcclosure(L, l_mk_cache, 1);
            lua_rawset(L, -3);
        }
        lua_setmetatable(L, -2);
        lua_rawseti(L, pState->aiMetatables[MT_StringProxy], i);
    }

    luaT_class(THStringProxy_t, l_str_new, "stringProxy", MT_StringProxy);
    // As we overwrite __index, move methods to MT_StringProxy[4]
    lua_getfield(L, pState->aiMetatables[MT_StringProxy], "__index");
    lua_rawseti(L, pState->aiMetatables[MT_StringProxy], 4);
    luaT_setmetamethod(l_str_index, "index");
    luaT_setmetamethod(l_str_newindex, "newindex");
    luaT_setmetamethod(l_str_concat, "concat");
    luaT_setmetamethod(l_str_len, "len");
    luaT_setmetamethod(l_str_tostring, "tostring");
    luaT_setmetamethod(l_str_persist, "persist");
    luaT_setmetamethod(l_str_depersist, "depersist");
    luaT_setmetamethod(l_str_call, "call");
    luaT_setmetamethod(l_str_lt, "lt");
    luaT_setmetamethod(l_str_pairs, "pairs");
    luaT_setmetamethod(l_str_ipairs, "ipairs");
    luaT_setmetamethod(l_str_next, "next");
    luaT_setmetamethod(l_str_inext, "inext");
    luaT_setfunction(l_str_func, "format" , MT_DummyString, "format");
    luaT_setfunction(l_str_func, "gsub"   , MT_DummyString, "gsub");
    luaT_setfunction(l_str_func, "lower"  , MT_DummyString, "lower");
    luaT_setfunction(l_str_func, "rep"    , MT_DummyString, "rep");
    luaT_setfunction(l_str_func, "reverse", MT_DummyString, "reverse");
    luaT_setfunction(l_str_func, "upper"  , MT_DummyString, "upper");
    luaT_endclass();
}
