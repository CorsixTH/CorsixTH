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

#include "persist_lua.h"
#include <cstring>
#include <errno.h>
#include <cmath>
#include <cstdio>
#include <vector>
#include <cstdlib>
#include <string>
#ifdef _MSC_VER
#pragma warning(disable: 4996) // Disable "std::strcpy unsafe" warnings under MSVC
#endif

enum PersistTypes
{
    //  LUA_TNIL = 0,
    //  LUA_TBOOLEAN, // Used for false
    //  LUA_TLIGHTUSERDATA, // Not currently persisted
    //  LUA_TNUMBER,
    //  LUA_TSTRING,
    //  LUA_TTABLE, // Used for tables without metatables
    //  LUA_TFUNCTION, // Used for Lua closures
    //  LUA_TUSERDATA,
    //  LUA_TTHREAD, // Not currently persisted
    PERSIST_TPERMANENT = LUA_TTHREAD + 1,
    PERSIST_TTRUE,
    PERSIST_TTABLE_WITH_META,
    PERSIST_TINTEGER,
    PERSIST_TPROTOTYPE,
    PERSIST_TRESERVED1, // Not currently used
    PERSIST_TRESERVED2, // Not currently used
    PERSIST_TCOUNT, // must equal 16 (for compatibility)
};

static int l_writer_mt_index(lua_State *L);

template <class T> static int l_crude_gc(lua_State *L)
{
    // This __gc metamethod does not verify that the given value is the correct
    // type of userdata, or that the value is userdata at all.
    reinterpret_cast<T*>(lua_touserdata(L, 1))->~T();
    return 0;
};

//! Structure for loading multiple strings as a Lua chunk, avoiding concatenation
/*!
    luaL_loadbuffer() is a good way to load a string as a Lua chunk. If there are
    several strings which need to be concatenated before being loaded, then it
    can be more efficient to use this structure, which can load them without
    concatenating them. Sample usage is:

    LoadMultiBuffer_t ls;
    ls.s[0] = lua_tolstring(L, -2, &ls.i[0]);
    ls.s[1] = lua_tolstring(L, -1, &ls.i[1]);
    lua_load(L, LoadMultiBuffer_t::load_fn, &ls, "chunk name");
*/
struct LoadMultiBuffer_t
{
    const char *s[3];
    size_t i[3];
    int n;

    LoadMultiBuffer_t()
    {
        s[0] = s[1] = s[2] = nullptr;
        i[0] = i[1] = i[2] = 0;
        n = 0;
    }

    static const char* load_fn(lua_State *L, void *ud, size_t *size)
    {
        LoadMultiBuffer_t *pThis = reinterpret_cast<LoadMultiBuffer_t*>(ud);

        for( ; pThis->n < 3; ++pThis->n)
        {
            if(pThis->i[pThis->n] != 0)
            {
                *size = pThis->i[pThis->n];
                return pThis->s[pThis->n++];
            }
        }

        *size = 0;
        return nullptr;
    }
};

//! Basic implementation of persistance interface
/*!
    self - Instance of LuaPersistBasicWriter allocated as a Lua userdata
    self metatable:
      __gc - ~LuaPersistBasicWriter (via l_crude_gc)
      "<file>:<line>" - <index of function prototype in already written data>
      [1] - pre-populated prototype persistance names
        "<file>:<line>" - "<name>"
      err - an object which could not be persisted
    self environment:
      <object> - <index of object in already written data>
      [1] - permanents table
    self environment metatable:
      __index - writeObjectRaw (via l_writer_mt_index)
        upvalue 1 - permanents table
        upvalue 2 - self
*/
class LuaPersistBasicWriter : public LuaPersistWriter
{
public:
    LuaPersistBasicWriter(lua_State *L)
        : m_L(L),
        m_data()
    { }

    ~LuaPersistBasicWriter()
    { }

    lua_State* getStack() override
    {
        return m_L;
    }

    void init()
    {
        lua_State *L = m_L;
        lua_createtable(L, 1, 8); // Environment
        lua_pushvalue(L, 2); // Permanent objects
        lua_rawseti(L, -2, 1);
        lua_createtable(L, 1, 0); // Environment metatable
        lua_pushvalue(L, 2); // Permanent objects
        lua_pushvalue(L, 1); // self
        luaT_pushcclosure(L, l_writer_mt_index, 2);
        lua_setfield(L, -2, "__index");
        lua_setmetatable(L, -2);
        lua_setfenv(L, 1);
        lua_createtable(L, 1, 4); // Metatable
        luaT_pushcclosure(L, l_crude_gc<LuaPersistBasicWriter>, 0);
        lua_setfield(L, -2, "__gc");
        lua_pushvalue(L, luaT_upvalueindex(1)); // Prototype persistance names
        lua_rawseti(L, -2, 1);
        lua_setmetatable(L, 1);

        m_iNextIndex = 1;
        m_iDataLength = 0;
        m_bHadError = false;
    }

    int finish()
    {
        if(getError() != nullptr)
        {
            lua_pushnil(m_L);
            lua_pushstring(m_L, getError());
            lua_getmetatable(m_L, 1);
            lua_getfield(m_L, -1, "err");
            lua_replace(m_L, -2);
            return 3;
        }
        else
        {
            lua_pushlstring(m_L, m_data.c_str(), m_data.length());
            return 1;
        }
    }

    void fastWriteStackObject(int iIndex) override
    {
        lua_State *L = m_L;

        if(lua_type(L, iIndex) != LUA_TUSERDATA)
        {
            writeStackObject(iIndex);
            return;
        }

        // Convert index from relative to absolute
        if(iIndex < 0 && iIndex > LUA_REGISTRYINDEX)
            iIndex = lua_gettop(L) + 1 + iIndex;

        // Check for no cycle
        lua_getfenv(L, 1);
        lua_pushvalue(L, iIndex);
        lua_rawget(L, -2);
        lua_rawgeti(L, -2, 1);
        lua_pushvalue(L, iIndex);
        lua_gettable(L, -2);
        lua_replace(L, -2);
        if(!lua_isnil(L, -1) || !lua_isnil(L, -2))
        {
            lua_pop(L, 3);
            writeStackObject(iIndex);
            return;
        }
        lua_pop(L, 2);

        // Save the index to the cache
        lua_pushvalue(L, iIndex);
        lua_pushnumber(L, (lua_Number)(m_iNextIndex++));
        lua_settable(L, -3);

        if(!_checkThatUserdataCanBeDepersisted(iIndex))
            return;

        // Write type, metatable, and then environment
        uint8_t iType = LUA_TUSERDATA;
        writeByteStream(&iType, 1);
        writeStackObject(-1);
        lua_getfenv(L, iIndex);
        writeStackObject(-1);
        lua_pop(L, 1);

        // Write the raw data
        if(lua_type(L, -1) == LUA_TTABLE)
        {
            lua_getfield(L, -1, "__persist");
            if(lua_isnil(L, -1))
                lua_pop(L, 1);
            else
            {
                lua_pushvalue(L, iIndex);
                lua_checkstack(L, 20);
                lua_CFunction fn = lua_tocfunction(L, -2);
                fn(L);
                lua_pop(L, 2);
            }
        }
        writeVUInt((uint64_t)0x42); // sync marker
        lua_pop(L, 1);
    }

    void writeStackObject(int iIndex) override
    {
        lua_State *L = m_L;

        // Convert index from relative to absolute
        if(iIndex < 0 && iIndex > LUA_REGISTRYINDEX)
            iIndex = lua_gettop(L) + 1 + iIndex;

        // Basic types always have their value written
        int iType = lua_type(L, iIndex);
        if(iType == LUA_TNIL || iType == LUA_TNONE)
        {
            uint8_t iByte = LUA_TNIL;
            writeByteStream(&iByte, 1);
        }
        else if(iType == LUA_TBOOLEAN)
        {
            uint8_t iByte;
            if(lua_toboolean(L, iIndex))
                iByte = PERSIST_TTRUE;
            else
                iByte = LUA_TBOOLEAN;
            writeByteStream(&iByte, 1);
        }
        else if(iType == LUA_TNUMBER)
        {
            double fValue = lua_tonumber(L, iIndex);
            if(floor(fValue) == fValue && 0.0 <= fValue && fValue <= 16383.0)
            {
                // Small integers are written as just a few bytes
                // NB: 16383 = 2^14-1, which is the maximum value which
                // can fit into two bytes of VUInt.
                uint8_t iByte = PERSIST_TINTEGER;
                writeByteStream(&iByte, 1);
                uint16_t iValue = (uint16_t)fValue;
                writeVUInt(iValue);
            }
            else
            {
                // Other numbers are written as an 8 byte double
                uint8_t iByte = LUA_TNUMBER;
                writeByteStream(&iByte, 1);
                writeByteStream(reinterpret_cast<uint8_t*>(&fValue), sizeof(double));
            }
        }
        else
        {
            // Complex values are cached, and are only written once (if this weren't
            // done, then cycles in the object graph would break things).
            lua_getfenv(L, 1);
            lua_pushvalue(L, iIndex);
            lua_gettable(L, -2); // Might (indirectly) call writeObjectRaw
            uint64_t iValue = (uint64_t)lua_tonumber(L, -1);
            lua_pop(L, 2);
            if(iValue != 0)
            {
                // If the value has not previously been written, then writeObjectRaw
                // would have been called, and the appropriate data written, and 0
                // would be returned. Otherwise, the index would be returned, which
                // we offset by the number of types, and then write.
                writeVUInt(iValue + PERSIST_TCOUNT - 1);
            }
        }
    }

    int writeObjectRaw()
    {
        lua_State *L = m_L;
        uint8_t iType;

        // Save the index to the cache
        lua_pushvalue(L, 2);
        lua_pushnumber(L, (lua_Number)(m_iNextIndex++));
        lua_settable(L, 1);

        // Lookup the object in the permanents table
        lua_pushvalue(L, 2);
        lua_gettable(L, luaT_upvalueindex(1));
        if(lua_type(L, -1) != LUA_TNIL)
        {
            // Object is in the permanents table.

            uint8_t iType = PERSIST_TPERMANENT;
            writeByteStream(&iType, 1);

            // Replace self's environment with self (for call to writeStackObject)
            lua_pushvalue(L, luaT_upvalueindex(2));
            lua_replace(L, 1);

            // Write the key corresponding to the permanent object
            writeStackObject(-1);
        }
        else
        {
            // Object is not in the permanents table.
            lua_pop(L, 1);

            switch(lua_type(L, 2))
            {
            // LUA_TNIL handled in writeStackObject
            // LUA_TBOOLEAN handled in writeStackObject
            // LUA_TNUMBER handled in writeStackObject

            case LUA_TSTRING: {
                iType = LUA_TSTRING;
                writeByteStream(&iType, 1);
                // Strings are simple: length and then bytes (not null terminated)
                size_t iLength;
                const char *sString = lua_tolstring(L, 2, &iLength);
                writeVUInt(iLength);
                writeByteStream(reinterpret_cast<const uint8_t*>(sString), iLength);
                break; }

            case LUA_TTABLE: {
                // Replace self's environment with self (for calls to writeStackObject)
                lua_pushvalue(L, luaT_upvalueindex(2));
                lua_replace(L, 1);

                // Save env and insert prior to table
                lua_getfenv(L, 1);
                lua_insert(L, 2);

                int iTable = 3; table_reentry:

                // Handle the metatable
                if(lua_getmetatable(L, iTable))
                {
                    iType = PERSIST_TTABLE_WITH_META;
                    writeByteStream(&iType, 1);
                    writeStackObject(-1);
                    lua_pop(L, 1);
                }
                else
                {
                    iType = LUA_TTABLE;
                    writeByteStream(&iType, 1);
                }

                // Write the children as key, value pairs
                lua_pushnil(L);
                while(lua_next(L, iTable))
                {
                    writeStackObject(-2);
                    // The naive thing to do now would be writeStackObject(-1)
                    // but this can easily lead to Lua's C call stack limit
                    // being hit. To reduce the likelihood of this happening,
                    // we check to see if about to write another table.
                    if(lua_type(L, -1) == LUA_TTABLE)
                    {
                        lua_pushvalue(L, -1);
                        lua_rawget(L, 2);
                        lua_pushvalue(L, -2);
                        lua_gettable(L, luaT_upvalueindex(1));
                        if(lua_isnil(L, -1) && lua_isnil(L, -2))
                        {
                            lua_pop(L, 2);
                            lua_checkstack(L, 10);
                            iTable += 2;
                            lua_pushvalue(L, iTable);
                            lua_pushnumber(L, (lua_Number)(m_iNextIndex++));
                            lua_settable(L, 2);
                            goto table_reentry; table_resume:
                            iTable -= 2;
                        }
                        else
                        {
                            lua_pop(L, 2);
                            writeStackObject(-1);
                        }
                    }
                    else
                        writeStackObject(-1);
                    lua_pop(L, 1);
                }

                // Write a nil to mark the end of the children (as nil is the
                // only value which cannot be used as a key in a table).
                iType = LUA_TNIL;
                writeByteStream(&iType, 1);
                if(iTable != 3)
                    goto table_resume;
                break; }

            case LUA_TFUNCTION:
                if(lua_iscfunction(L, 2))
                {
                    setErrorObject(2);
                    setError("Cannot persist C functions");
                }
                else
                {
                    iType = LUA_TFUNCTION;
                    writeByteStream(&iType, 1);

                    // Replace self's environment with self (for calls to writeStackObject)
                    lua_pushvalue(L, luaT_upvalueindex(2));
                    lua_replace(L, 1);

                    // Write the prototype (the part of a function which is common across
                    // multiple closures - see LClosure / Proto in Lua's lobject.h).
                    lua_Debug proto_info;
                    lua_pushvalue(L, 2);
                    lua_getinfo(L, ">Su", &proto_info);
                    writePrototype(&proto_info, 2);

                    // Write the values of the upvalues
                    // If available, also write the upvalue IDs (so that in
                    // the future, we could hypothetically rejoin shared
                    // upvalues). An ID is just an opaque sequence of bytes.
                    writeVUInt(proto_info.nups);
#if LUA_VERSION_NUM >= 502
                    writeVUInt(sizeof(void*));
#else
                    writeVUInt(0);
#endif
                    for(int i = 1; i <= proto_info.nups; ++i)
                    {
                        lua_getupvalue(L, 2, i);
                        writeStackObject(-1);
#if LUA_VERSION_NUM >= 502
                        void *pUpvalueID = lua_upvalueid(L, 2, i);
                        writeByteStream((uint8_t*)&pUpvalueID, sizeof(void*));
#endif
                    }

                    // Write the environment table
                    lua_getfenv(L, 2);
                    writeStackObject(-1);
                    lua_pop(L, 1);
                }
                break;

            case LUA_TUSERDATA:
                if(!_checkThatUserdataCanBeDepersisted(2))
                    break;

                // Replace self's environment with self (for calls to writeStackObject)
                lua_pushvalue(L, luaT_upvalueindex(2));
                lua_replace(L, 1);

                // Write type, metatable, and then environment
                iType = LUA_TUSERDATA;
                writeByteStream(&iType, 1);
                writeStackObject(-1);
                lua_getfenv(L, 2);
                writeStackObject(-1);
                lua_pop(L, 1);

                // Write the raw data
                if(lua_type(L, -1) == LUA_TTABLE)
                {
                    lua_getfield(L, -1, "__persist");
                    if(lua_isnil(L, -1))
                        lua_pop(L, 1);
                    else
                    {
                        lua_pushvalue(L, 2);
                        lua_pushvalue(L, luaT_upvalueindex(2));
                        lua_call(L, 2, 0);
                    }
                }
                writeVUInt((uint64_t)0x42); // sync marker
                break;

            default:
                setError(lua_pushfstring(L, "Cannot persist %s values", luaL_typename(L, 2)));
                break;
            }
        }
        lua_pushnumber(L, 0);
        return 1;
    }

    bool _checkThatUserdataCanBeDepersisted(int iIndex)
    {
        lua_State *L = m_L;

        if(lua_getmetatable(L, iIndex))
        {
            lua_getfield(L, -1, "__depersist_size");
            if(lua_isnumber(L, -1))
            {
                if(static_cast<int>(lua_tointeger(L, -1))
                    != static_cast<int>(lua_objlen(L, iIndex)))
                {
                    setError(lua_pushfstring(L, "__depersist_size is "
                        "incorrect (%d vs. %d)", (int)lua_objlen(L, iIndex),
                        (int)lua_tointeger(L, -1)));
                    return false;
                }
                if(lua_objlen(L, iIndex) != 0)
                {
                    lua_getfield(L, -2, "__persist");
                    lua_getfield(L, -3, "__depersist");
                    if(lua_isnil(L, -1) || lua_isnil(L, -2))
                    {
                        setError("Can only persist non-empty userdata"
                            " if they have __persist and __depersist "
                            "metamethods");
                        return false;
                    }
                    lua_pop(L, 2);
                }
            }
            else
            {
                if(lua_objlen(L, iIndex) != 0)
                {
                    setError("Can only persist non-empty userdata if "
                        "they have a __depersist_size metafield");
                    return false;
                }
            }
            lua_pop(L, 1);
        }
        else
        {
            if(lua_objlen(L, iIndex) != 0)
            {
                setError("Can only persist userdata without a metatable"
                    " if their size is zero");
                return false;
            }
            lua_pushnil(L);
        }
        return true;
    }

    void writePrototype(lua_Debug *pProtoInfo, int iInstanceIndex)
    {
        lua_State *L = m_L;

        // Sanity checks
        if(pProtoInfo->source[0] != '@')
        {
            // @ denotes that the source was a file
            // (http://www.lua.org/manual/5.1/manual.html#lua_Debug)
            setError("Can only persist Lua functions defined in source files");
            return;
        }
        if(std::strcmp(pProtoInfo->what, "Lua") != 0)
        {
            // what == "C" should have been caught by writeObjectRaw().
            // what == "tail" should be impossible.
            // Hence "Lua" and "main" should be the only values seen.
            // NB: Chunks are not functions defined *in* source files, because
            // chunks *are* source files.
            setError(lua_pushfstring(L, "Cannot persist entire Lua chunks (%s)", pProtoInfo->source + 1));
            lua_pop(L, 1);
            return;
        }

        // Attempt cached lookup (prototypes are not publicly visible Lua objects,
        // and hence cannot be cached in the normal way of self's environment).
        lua_getmetatable(L, 1);
        lua_pushfstring(L, "%s:%d", pProtoInfo->source + 1, pProtoInfo->linedefined);
        lua_pushvalue(L, -1);
        lua_rawget(L, -3);
        if(!lua_isnil(L, -1))
        {
            uint64_t iValue = (uint64_t)lua_tonumber(L, -1);
            lua_pop(L, 3);
            writeVUInt(iValue + PERSIST_TCOUNT - 1);
            return;
        }
        lua_pop(L, 1);
        lua_pushvalue(L, -1);
        lua_pushnumber(L, (lua_Number)m_iNextIndex++);
        lua_rawset(L, -4);

        uint8_t iType = PERSIST_TPROTOTYPE;
        writeByteStream(&iType, 1);

        // Write upvalue names
        writeVUInt(pProtoInfo->nups);
        for(int i = 1; i <= pProtoInfo->nups; ++i)
        {
            lua_pushstring(L, lua_getupvalue(L, iInstanceIndex, i));
            writeStackObject(-1);
            lua_pop(L, 2);
        }

        // Write the function's persist name
        lua_rawgeti(L, -2, 1);
        lua_replace(L, -3);
        lua_rawget(L, -2);
        if(lua_isnil(L, -1))
        {
            setError(lua_pushfstring(L, "Lua functions must be given a unique "
                "persistable name in order to be persisted (attempt to persist"
                " %s:%d)", pProtoInfo->source + 1, pProtoInfo->linedefined));
            lua_pop(L, 2);
            return;
        }
        writeStackObject(-1);
        lua_pop(L, 2);
    }

    void writeByteStream(const uint8_t *pBytes, size_t iCount) override
    {
        if(m_bHadError)
        {
            // If an error occurred, then silently fail to write any
            // data.
            return;
        }

        m_data.append(reinterpret_cast<const char*>(pBytes), iCount);
    }

    void setError(const char *sError) override
    {
        // If multiple errors occur, only record the first.
        if (m_bHadError) {
            return;
        }
        m_bHadError = true;

        // Use the written data buffer to store the error message
        m_data.assign(sError);
    }

    void setErrorObject(int iStackObject)
    {
        if(m_bHadError)
            return;
        lua_State *L = m_L;

        lua_pushvalue(L, iStackObject);
        lua_getmetatable(L, luaT_upvalueindex(2));
        lua_insert(L, -2);
        lua_setfield(L, -2, "err");
        lua_pop(L, 1);
    }

    const char* getError()
    {
        if(m_bHadError)
            return m_data.c_str();
        else
            return nullptr;
    }

private:
    lua_State *m_L;
    uint64_t m_iNextIndex;
    std::string m_data;
    size_t m_iDataLength;
    bool m_bHadError;
};

static int l_writer_mt_index(lua_State *L)
{
    return reinterpret_cast<LuaPersistBasicWriter*>(
        lua_touserdata(L, luaT_upvalueindex(2)))->writeObjectRaw();
}

//! Basic implementation of depersistance interface
/*!
    self - Instance of LuaPersistBasicReader allocated as a Lua userdata
    self environment:
      [-3] - self
      [-2] - pre-populated prototype persistance code
        "<name>" - "<code>"
      [-1] - pre-populated prototype persistance filenames
        "<name>" - "<filename>"
      [ 0] - permanents table
      <index> - <object already depersisted>
    self metatable:
      __gc - ~LuaPersistBasicReader (via l_crude_gc)
      <N> - <userdata to have second __depersist call>
*/
class LuaPersistBasicReader : public LuaPersistReader
{
public:
    LuaPersistBasicReader(lua_State *L)
        : m_L(L),
        m_stringBuffer()
    { }

    ~LuaPersistBasicReader()
    { }

    lua_State* getStack() override
    {
        return m_L;
    }

    void setError(const char *sError) override
    {
        m_bHadError = true;
        m_stringBuffer.assign(sError);
    }

    void init(const uint8_t *pData, size_t iLength)
    {
        lua_State *L = m_L;
        m_pData = pData;
        m_iDataBufferLength = iLength;
        m_iNextIndex = 1;
        m_bHadError = false;
        lua_createtable(L, 32, 0); // Environment
        lua_pushvalue(L, 2);
        lua_rawseti(L, -2, 0);
        lua_pushvalue(L, luaT_upvalueindex(1));
        lua_rawseti(L, -2, -1);
        lua_pushvalue(L, luaT_upvalueindex(2));
        lua_rawseti(L, -2, -2);
        lua_pushvalue(L, 1);
        lua_rawseti(L, -2, -3);
        lua_setfenv(L, 1);
        lua_createtable(L, 0, 1); // Metatable
        luaT_pushcclosure(L, l_crude_gc<LuaPersistBasicReader>, 0);
        lua_setfield(L, -2, "__gc");
        lua_setmetatable(L, 1);
    }

    bool readStackObject() override
    {
        uint64_t iIndex;
        if(!readVUInt(iIndex))
        {
            setError("Expected stack object");
            return false;
        }
        lua_State *L = m_L;
        if(lua_type(L, 1) != LUA_TTABLE)
        {
            // Ensure that index #1 is self environment
            lua_getfenv(L, 1);
            lua_replace(L, 1);
        }
        if(iIndex >= PERSIST_TCOUNT)
        {
            iIndex += 1 - PERSIST_TCOUNT;
            if(iIndex < (uint64_t)INT_MAX)
                lua_rawgeti(L, 1, (int)iIndex);
            else
            {
                lua_pushnumber(L, (lua_Number)iIndex);
                lua_rawget(L, 1);
            }
            if(lua_isnil(L, -1))
            {
                setError("Cycle while depersisting permanent object key or userdata metatable");
                return false;
            }
        }
        else
        {
            uint8_t iType = (uint8_t)iIndex;
            switch(iType)
            {
            case LUA_TNIL:
                lua_pushnil(L);
                break;
            case PERSIST_TPERMANENT: {
                uint64_t iOldIndex = m_iNextIndex;
                ++m_iNextIndex; // Temporary marker
                lua_rawgeti(L, 1, 0); // Permanents table
                if(!readStackObject())
                    return false;
                lua_gettable(L, -2);
                lua_replace(L, -2);
                // Replace marker with actual object
                uint64_t iNewIndex = m_iNextIndex;
                m_iNextIndex = iOldIndex;
                saveStackObject();
                m_iNextIndex = iNewIndex;
                break; }
            case LUA_TBOOLEAN:
                lua_pushboolean(L, 0);
                break;
            case PERSIST_TTRUE:
                lua_pushboolean(L, 1);
                break;
            case LUA_TSTRING: {
                size_t iLength;
                if(!readVUInt(iLength))
                    return false;
                if(!readByteStream(m_stringBuffer, iLength))
                    return false;
                lua_pushlstring(L, m_stringBuffer.c_str(), m_stringBuffer.length());
                saveStackObject();
                break; }
            case LUA_TTABLE:
                lua_newtable(L);
                saveStackObject();
                if(!lua_checkstack(L, 8))
                    return false;
                if(!readTableContents())
                    return false;
                break;
            case PERSIST_TTABLE_WITH_META:
                lua_newtable(L);
                saveStackObject();
                if(!lua_checkstack(L, 8))
                    return false;
                if(!readStackObject())
                    return false;
                lua_setmetatable(L, -2);
                if(!readTableContents())
                    return false;
                break;
            case LUA_TNUMBER: {
                double fValue;
                if(!readByteStream(reinterpret_cast<uint8_t*>(&fValue), sizeof(double)))
                    return false;
                lua_pushnumber(L, fValue);
                break; }
            case LUA_TFUNCTION: {
                if(!lua_checkstack(L, 8))
                    return false;
                uint64_t iOldIndex = m_iNextIndex;
                ++m_iNextIndex; // Temporary marker
                if(!readStackObject())
                    return false;
                lua_call(L, 0, 2);
                // Replace marker with closure
                uint64_t iNewIndex = m_iNextIndex;
                m_iNextIndex = iOldIndex;
                saveStackObject();
                m_iNextIndex = iNewIndex;
                // Set upvalues
                lua_insert(L, -2);
                int iNups, i;
                if(!readVUInt(iNups))
                    return false;
                size_t iIDSize;
                if(!readVUInt(iIDSize))
                    return false;
                for(i = 0; i < iNups; ++i)
                {
                    if(!readStackObject())
                        return false;
                    // For now, just skip over the upvalue IDs. In the future,
                    // the ID may be used to rejoin shared upvalues.
                    if(!readByteStream(nullptr, iIDSize))
                        return false;
                }
                lua_call(L, iNups, 0);
                // Read environment
                if(!readStackObject())
                        return false;
                lua_setfenv(L, -2);
                break; }
            case PERSIST_TPROTOTYPE: {
                if(!lua_checkstack(L, 8))
                    return false;

                uint64_t iOldIndex = m_iNextIndex;
                ++m_iNextIndex; // Temporary marker
                int iNups;
                if(!readVUInt(iNups))
                    return false;
                if(iNups == 0)
                    lua_pushliteral(L, "return function() end,");
                else
                {
                    lua_pushliteral(L, "local ");
                    lua_checkstack(L, (iNups + 1) * 2);
                    for(int i = 0; i < iNups; ++i)
                    {
                        if(i != 0)
                            lua_pushliteral(L, ",");
                        if(!readStackObject())
                            return false;
                        if(lua_type(L, -1) != LUA_TSTRING)
                        {
                            setError("Upvalue name not a string");
                            return false;
                        }
                    }
                    lua_concat(L, iNups * 2 - 1);
                    lua_pushliteral(L, ";return function(...)");
                    lua_pushvalue(L, -2);
                    lua_pushliteral(L, "=...end,");
                    lua_concat(L, 5);
                }
                // Fetch name and then lookup filename and code
                if(!readStackObject())
                    return false;
                lua_pushliteral(L, "@");

                lua_rawgeti(L, 1, -1);
                lua_pushvalue(L, -3);
                lua_gettable(L, -2);
                lua_replace(L, -2);

                if(lua_isnil(L, -1))
                {
                    setError(lua_pushfstring(L, "Unable to depersist prototype"
                        " \'%s\'", lua_tostring(L, -3)));
                    return false;
                }
                lua_concat(L, 2); // Prepend the @ to the filename
                lua_rawgeti(L, 1, -2);
                lua_pushvalue(L, -3);

                lua_gettable(L, -2);
                lua_replace(L, -2);
                lua_remove(L, -3);
                // Construct the closure factory
                LoadMultiBuffer_t ls;
                ls.s[0] = lua_tolstring(L, -3, &ls.i[0]);
                ls.s[1] = lua_tolstring(L, -1, &ls.i[1]);
                if(luaT_load(L, LoadMultiBuffer_t::load_fn, &ls, lua_tostring(L, -2), "bt") != 0)
                {
                    // Should never happen
                    lua_error(L);
                    return false;
                }
                lua_replace(L, -4);
                lua_pop(L, 2);
                // Replace marker with closure factory
                uint64_t iNewIndex = m_iNextIndex;
                m_iNextIndex = iOldIndex;
                saveStackObject();
                m_iNextIndex = iNewIndex;
                break; }
            case LUA_TUSERDATA: {
                bool bHasSetMetatable = false;
                uint64_t iOldIndex = m_iNextIndex;
                ++m_iNextIndex; // Temporary marker
                // Read metatable
                if(!readStackObject())
                    return false;
                lua_getfield(L, -1, "__depersist_size");
                if(!lua_isnumber(L, -1))
                {
                    setError("Userdata missing __depersist_size metafield");
                    return false;
                }
                lua_newuserdata(L, (size_t)lua_tonumber(L, -1));
                lua_replace(L, -2);
                // Replace marker with userdata
                uint64_t iNewIndex = m_iNextIndex;
                m_iNextIndex = iOldIndex;
                saveStackObject();
                m_iNextIndex = iNewIndex;
                // Perform immediate initialisation
                lua_getfield(L, -2, "__pre_depersist");
                if(lua_isnil(L, -1))
                    lua_pop(L, 1);
                else
                {
                    // Set metatable now, as pre-depersister may expect it
                    // NB: Setting metatable if there isn't a pre-depersister
                    // is not a good idea, as if there is an error while the
                    // environment table is being de-persisted, then the __gc
                    // handler of the userdata will eventually be called with
                    // the userdata's contents still being uninitialised.
                    lua_pushvalue(L, -3);
                    lua_setmetatable(L, -3);
                    bHasSetMetatable = true;
                    lua_pushvalue(L, -2);
                    lua_call(L, 1, 0);
                }
                // Read environment
                if(!readStackObject())
                    return false;
                lua_setfenv(L, -2);
                // Set metatable and read the raw data
                if(!bHasSetMetatable)
                {
                    lua_pushvalue(L, -2);
                    lua_setmetatable(L, -2);
                }
                lua_getfield(L, -2, "__depersist");
                if(lua_isnil(L, -1))
                    lua_pop(L, 1);
                else
                {
                    lua_pushvalue(L, -2);
                    lua_rawgeti(L, 1, -3);
                    lua_call(L, 2, 1);
                    if(lua_toboolean(L, -1) != 0)
                    {
                        lua_pop(L, 1);
                        lua_rawgeti(L, 1, -3);
                        lua_getmetatable(L, -1);
                        lua_replace(L, -2);
                        lua_pushvalue(L, -2);
                        lua_rawseti(L, -2, (int)lua_objlen(L, -2) + 1);
                    }
                    lua_pop(L, 1);
                }
                lua_replace(L, -2);
                uint64_t iSyncMarker;
                if(!readVUInt(iSyncMarker))
                    return false;
                if(iSyncMarker != 0x42)
                {
                    setError("sync fail");
                    return false;
                }
                break; }
            case PERSIST_TINTEGER: {
                uint16_t iValue;
                if(!readVUInt(iValue))
                    return false;
                lua_pushinteger(L, iValue);
                break; }
            default:
                lua_pushliteral(L, "Unable to depersist values of type \'");
                if(iType <= LUA_TTHREAD)
                    lua_pushstring(L, lua_typename(L, iType));
                else
                {
                    switch(iType)
                    {
                    case PERSIST_TPERMANENT:
                        lua_pushliteral(L, "permanent"); break;
                    case PERSIST_TTRUE:
                        lua_pushliteral(L, "boolean-true"); break;
                    case PERSIST_TTABLE_WITH_META:
                        lua_pushliteral(L, "table-with-metatable"); break;
                    case PERSIST_TINTEGER:
                        lua_pushliteral(L, "integer"); break;
                    case PERSIST_TPROTOTYPE:
                        lua_pushliteral(L, "prototype"); break;
                    case PERSIST_TRESERVED1:
                        lua_pushliteral(L, "reserved1"); break;
                    case PERSIST_TRESERVED2:
                        lua_pushliteral(L, "reserved2"); break;
                    }
                }
                lua_pushliteral(L, "\'");
                lua_concat(L, 3);
                setError(lua_tostring(L, -1));
                lua_pop(L, 1);
                return false;
            }
        }
        return true;
    }

    void saveStackObject()
    {
        lua_State *L = m_L;
        if(m_iNextIndex < (uint64_t)INT_MAX)
        {
            lua_pushvalue(L, -1);
            lua_rawseti(L, 1, (int)m_iNextIndex);
        }
        else
        {
            lua_pushnumber(L, (lua_Number)m_iNextIndex);
            lua_pushvalue(L, -2);
            lua_rawset(L, 1);
        }
        ++m_iNextIndex;
    }

    bool readTableContents()
    {
        lua_State *L = m_L;
        while(true)
        {
            if(!readStackObject())
                return false;
            if(lua_type(L, -1) == LUA_TNIL)
            {
                lua_pop(L, 1);
                return true;
            }
            if(!readStackObject())
                return false;
            // NB: lua_rawset used rather than lua_settable to avoid invoking
            // any metamethods, as they may not have been designed to be called
            // during depersistance.
            lua_rawset(L, -3);
        }
    }

    bool finish()
    {
        lua_State *L = m_L;

        // Ensure that all data has been read
        if(m_iDataBufferLength != 0)
        {
            setError(lua_pushfstring(L, "%d bytes of data remain unpersisted", (int)m_iDataBufferLength));
            return false;
        }

        // Ensure that index #1 is self environment
        if(lua_type(L, 1) != LUA_TTABLE)
        {
            lua_getfenv(L, 1);
            lua_replace(L, 1);
        }
        // Ensure that index #1 is self metatable
        lua_rawgeti(L, 1, -3);
        lua_getmetatable(L, -1);
        lua_replace(L, 1);
        lua_pop(L, 1);

        // Call all the __depersist functions which need a 2nd call
        int iNumCalls = (int)lua_objlen(L, 1);
        for(int i = 1; i <= iNumCalls; ++i)
        {
            lua_rawgeti(L, 1, i);
            luaL_getmetafield(L, -1, "__depersist");
            lua_insert(L, -2);
            lua_call(L, 1, 0);
        }
        return true;
    }

    bool readByteStream(uint8_t *pBytes, size_t iCount) override
    {
        if(iCount > m_iDataBufferLength)
        {
            setError(lua_pushfstring(m_L,
                "End of input reached while attempting to read %d byte%s",
                (int)iCount, iCount == 1 ? "" : "s"));
            lua_pop(m_L, 1);
            return false;
        }

        if(pBytes != nullptr)
            std::memcpy(pBytes, m_pData, iCount);

        m_pData += iCount;
        m_iDataBufferLength -= iCount;
        return true;
    }

    bool readByteStream(std::string& bytes, size_t iCount)
    {
        if(iCount > m_iDataBufferLength) {
            setError(lua_pushfstring(m_L,
                "End of input reached while attempting to read %d byte%s",
                (int)iCount, iCount == 1 ? "" : "s"));
            lua_pop(m_L, 1);
            return false;
        }

        bytes.assign(reinterpret_cast<const char*>(m_pData), iCount);

        m_pData += iCount;
        m_iDataBufferLength -= iCount;
        return true;
    }

    const uint8_t* getPointer() {return m_pData;}
    uint64_t getObjectCount() {return m_iNextIndex;}

    const char* getError()
    {
        if(m_bHadError)
            return m_stringBuffer.c_str();
        else
            return nullptr;
    }

private:
    lua_State *m_L;
    uint64_t m_iNextIndex;
    const uint8_t* m_pData;
    size_t m_iDataBufferLength;
    std::string m_stringBuffer;
    bool m_bHadError;
};

static int l_dump_toplevel(lua_State *L)
{
    luaL_checktype(L, 2, LUA_TTABLE);
    lua_settop(L, 2);
    lua_pushvalue(L, 1);
    LuaPersistBasicWriter *pWriter = new (lua_newuserdata(L, sizeof(LuaPersistBasicWriter))) LuaPersistBasicWriter(L);
    lua_replace(L, 1);
    pWriter->init();
    pWriter->writeStackObject(3);
    return pWriter->finish();
}

static int l_load_toplevel(lua_State *L)
{
    size_t iDataLength;
    const uint8_t *pData = luaT_checkfile(L, 1, &iDataLength);
    luaL_checktype(L, 2, LUA_TTABLE);
    lua_settop(L, 2);
    lua_pushvalue(L, 1);
    LuaPersistBasicReader *pReader = new (lua_newuserdata(L, sizeof(LuaPersistBasicReader))) LuaPersistBasicReader(L);
    lua_replace(L, 1);
    pReader->init(pData, iDataLength);
    if(!pReader->readStackObject() || !pReader->finish())
    {
        int iNumObjects = (int)pReader->getObjectCount();
        int iNumBytes = (int)(pReader->getPointer() - pData);
        lua_pushnil(L);
        lua_pushfstring(L, "%s after %d objects (%d bytes)",
            pReader->getError() ? pReader->getError() : "Error while depersisting",
            iNumObjects, iNumBytes);
        return 2;
    }
    else
    {
        return 1;
    }
}

static int CalculateLineNumber(const char *sStart, const char *sPosition)
{
    int iLine = 1;
    for(; sStart != sPosition; ++sStart)
    {
        switch(sStart[0])
        {
        case '\0':
            return -1; // error return value
        case '\n':
            ++iLine;
            if(sStart[1] == '\r')
                ++sStart;
            break;
        case '\r':
            ++iLine;
            if(sStart[1] == '\n')
                ++sStart;
            break;
        }
    }
    return iLine;
}

static const char* FindFunctionEnd(lua_State *L, const char* sStart)
{
    const char* sEnd = sStart;
    while(sEnd)
    {
        sEnd = std::strstr(sEnd, "end");
        if(sEnd)
        {
            sEnd += 3;
            LoadMultiBuffer_t ls;
            ls.s[0] =        "return function";
            ls.i[0] = sizeof("return function") - 1;
            ls.s[1] = sStart;
            ls.i[1] = sEnd - sStart;
            if(luaT_load(L, LoadMultiBuffer_t::load_fn, &ls, "", "bt") == 0)
            {
                lua_pop(L, 1);
                return sEnd;
            }
            lua_pop(L, 1);
        }
    }
    return nullptr;
}

static int l_persist_dofile(lua_State *L)
{
    const char *sFilename = luaL_checkstring(L, 1);
    lua_settop(L, 1);

    // Read entire file into memory
    FILE *fFile = std::fopen(sFilename, "r");
    if(fFile == nullptr)
    {
        const char *sError =std::strerror(errno);
        return luaL_error(L, "cannot open %s: %s", sFilename, sError);
    }
    size_t iBufferSize = lua_objlen(L, luaT_upvalueindex(1));
    size_t iBufferUsed = 0;
    while(!std::feof(fFile))
    {
        iBufferUsed += std::fread(reinterpret_cast<char*>(lua_touserdata(L,
            luaT_upvalueindex(1))) + iBufferUsed, 1, iBufferSize - iBufferUsed, fFile);
        if(iBufferUsed == iBufferSize)
        {
            iBufferSize *= 2;
            std::memcpy(lua_newuserdata(L, iBufferSize), lua_touserdata(L, luaT_upvalueindex(1)), iBufferUsed);
            lua_replace(L, luaT_upvalueindex(1));
        }
        else
            break;
    }
    int iStatus = std::ferror(fFile);
    std::fclose(fFile);
    if(iStatus)
    {
        const char *sError =std::strerror(errno);
        return luaL_error(L, "cannot read %s: %s", sFilename, sError);
    }

    // Check file
    char *sFile = reinterpret_cast<char*>(lua_touserdata(L, luaT_upvalueindex(1)));
    sFile[iBufferUsed] = 0;
    if(sFile[0] == '#')
    {
        do
        {
          ++sFile;
          --iBufferUsed;
        } while(sFile[0] != 0 && sFile[0] != '\r' && sFile[0] != '\n');
    }
    if(sFile[0] == LUA_SIGNATURE[0])
    {
        return luaL_error(L, "cannot load %s: compiled files not permitted", sFilename);
    }

    // Load and do file
    lua_pushliteral(L, "@");
    lua_pushvalue(L, 1);
    lua_concat(L, 2);
    if(luaL_loadbuffer(L, sFile, iBufferUsed, lua_tostring(L, -1)) != 0)
        return lua_error(L);
    lua_remove(L, -2);
    int iBufferCopyIndex = lua_gettop(L);
    std::memcpy(lua_newuserdata(L, iBufferUsed + 1), sFile, iBufferUsed + 1);
    lua_insert(L, -2);
    lua_call(L, 0, LUA_MULTRET);
    sFile = reinterpret_cast<char*>(lua_touserdata(L, luaT_upvalueindex(1)));
    std::memcpy(sFile, lua_touserdata(L, iBufferCopyIndex), iBufferUsed + 1);
    lua_remove(L, iBufferCopyIndex);

    // Extract persistable functions
    const char *sPosition = sFile;
    while(true)
    {
        sPosition = std::strstr(sPosition, "--[[persistable:");
        if(!sPosition)
            break;
        sPosition += 16;
        const char *sNameEnd = std::strstr(sPosition, "]]");
        if(sNameEnd)
        {
            int iLineNumber = CalculateLineNumber(sFile, sNameEnd);
            const char *sFunctionArgs = std::strchr(sNameEnd + 2, '(');
            const char *sFunctionEnd = FindFunctionEnd(L, sFunctionArgs);
            if((sNameEnd - sPosition) == 1 && *sPosition == ':')
            {
                // --[[persistable::]] means take the existing name of the function
                sPosition = std::strstr(sNameEnd, "function") + 8;
                sPosition += std::strspn(sPosition, " \t");
                sNameEnd = sFunctionArgs;
                while(sNameEnd[-1] == ' ')
                    --sNameEnd;
            }
            if(iLineNumber != -1 && sFunctionArgs && sFunctionEnd)
            {
                // Save <filename>:<line> => <name>
                lua_pushfstring(L, "%s:%d", sFilename, iLineNumber);
                lua_pushvalue(L, -1);
                lua_gettable(L, luaT_upvalueindex(2));
                if(lua_isnil(L, -1))
                {
                    lua_pop(L, 1);
                    lua_pushlstring(L, sPosition, sNameEnd - sPosition);
                    lua_settable(L, luaT_upvalueindex(2));
                }
                else
                {
                    return luaL_error(L, "Multiple persistable functions defin"
                        "ed on the same line (%s:%d)", sFilename, iLineNumber);
                }

                // Save <name> => <filename>
                lua_pushlstring(L, sPosition, sNameEnd - sPosition);
                lua_pushvalue(L, -1);
                lua_gettable(L, luaT_upvalueindex(3));
                if(lua_isnil(L, -1))
                {
                    lua_pop(L, 1);
                    lua_pushvalue(L, 1);
                    lua_settable(L, luaT_upvalueindex(3));
                }
                else
                {
                    return luaL_error(L, "Persistable function name \'%s\' is"
                        " not unique (defined in both %s and %s)",
                        lua_tostring(L, -2), lua_tostring(L, -1), sFilename);
                }

                // Save <name> => <code>
                lua_pushlstring(L, sPosition, sNameEnd - sPosition);
                lua_pushliteral(L, "\n");
                lua_getfield(L, -1, "rep");
                lua_insert(L, -2);
                lua_pushinteger(L, iLineNumber - 1);
                lua_call(L, 2, 1);
                lua_pushliteral(L, "function");
                lua_pushlstring(L, sFunctionArgs, sFunctionEnd - sFunctionArgs);
                lua_concat(L, 3);
                lua_settable(L, luaT_upvalueindex(4));
            }
        }
    }

    // Finish
    return lua_gettop(L) - 1;
}

static int l_errcatch(lua_State *L)
{
    // Dummy function for debugging - place a breakpoint on the following
    // return statement to inspect the full C call stack when a Lua error
    // occurs (assuming that l_errcatch is used as the error catch handler).
    return 1;
}

static const std::vector<luaL_Reg> persist_lib = {
    // Due to the various required upvalues, functions are registered
    // manually, but we still need a dummy to pass to luaL_register.
    {"errcatch", l_errcatch},
    {nullptr, nullptr}
};

int luaopen_persist(lua_State *L)
{
    luaT_register(L, "persist", persist_lib);
    lua_newuserdata(L, 512); // buffer for dofile
    lua_newtable(L);
    lua_newtable(L);
    lua_newtable(L);
    lua_pushvalue(L, -3);
    luaT_pushcclosure(L, l_dump_toplevel, 1);
    lua_setfield(L, -6, "dump");
    lua_pushvalue(L, -2);
    lua_pushvalue(L, -2);
    luaT_pushcclosure(L, l_load_toplevel, 2);
    lua_setfield(L, -6, "load");
    luaT_pushcclosure(L, l_persist_dofile, 4);
    lua_setfield(L, -2, "dofile");
    return 1;
}
