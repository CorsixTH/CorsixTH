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

#include "config.h"

#include <errno.h>

#include <array>
#include <climits>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <new>
#include <string>

#include "lua.hpp"
#include "th_lua.h"
#ifdef _MSC_VER
#pragma warning( \
    disable : 4996)  // Disable "std::strcpy unsafe" warnings under MSVC
#endif

namespace {

enum persist_type {
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
  PERSIST_TRESERVED1,  // Not currently used
  PERSIST_TRESERVED2,  // Not currently used
  PERSIST_TCOUNT,      // must equal 16 (for compatibility)
};

template <class T>
int l_crude_gc(lua_State* L) {
  // This __gc metamethod does not verify that the given value is the correct
  // type of userdata, or that the value is userdata at all.
  static_cast<T*>(lua_touserdata(L, 1))->~T();
  return 0;
}

}  // namespace

constexpr size_t load_multi_buffer_capacity = 3;

//! Structure for loading multiple strings as a Lua chunk, avoiding
//! concatenation
/*!
   luaL_loadbuffer() is a good way to load a string as a Lua chunk. If there
   are several strings which need to be concatenated before being loaded, then
   it can be more efficient to call lua_load with a callback function for
   loading the strings one at a time than to concatenate the strings into a
   single buffer.

   This class provides the data structure and callback function to do this.

    ```
    load_multi_buffer ls;
    ls.piece[0] = lua_tolstring(L, -2, &ls.piece_size[0]);
    ls.piece[1] = lua_tolstring(L, -1, &ls.piece_size[1]);
    luaT_load(L, load_multi_buffer::load_fn, &ls, "chunk name", "bt");
    ```

    Because of the api of lua_tolstring the API of this class allows direct
    and independent assignment of the chunk pieces and their sizes.

    It is up to the caller to keep track of how many pieces are used and to
    ensure that no more than load_multi_buffer_capacity pieces are used.
*/
class load_multi_buffer {
 public:
  /// lua_Reader callback function for lua_load or luaT_load
  /*!
   Called repeatedly by lua to get the next piece of data to load until a
   null pointer is returned.

   \param L The Lua state
   \param ud Pointer to the load_multi_buffer instance
   \param size Pointer to size_t to receive the size of the returned string

   \see https://www.lua.org/manual/5.4/manual.html#lua_Reader
  */
  static const char* load_fn(lua_State* L, void* ud, size_t* size) {
    auto* me = static_cast<load_multi_buffer*>(ud);

    // Skip empty chunks if any which would cause lua_load to stop early
    while (me->n < load_multi_buffer_capacity && me->piece_size[me->n] == 0) {
      ++me->n;
    }

    if (me->n < load_multi_buffer_capacity) {
      *size = me->piece_size[me->n];
      return me->piece[me->n++];
    }

    *size = 0;
    return nullptr;
  }

  /// Insert the given chunk at the given index in the buffer
  void insert(std::string_view piece, size_t index) {
    this->piece[index] = piece.data();
    this->piece_size[index] = piece.size();
  }

  /// Pieces of the lua code chunk to be loaded.
  const char* piece[load_multi_buffer_capacity]{nullptr};

  /// Lengths of the pieces.
  size_t piece_size[load_multi_buffer_capacity]{};

 private:
  /// The next piece index to be loaded
  int n{};
};

//! Basic implementation of persistence interface
/*!
    self - Instance of lua_persist_basic_writer allocated as a Lua userdata
    self metatable:
      `__gc` - ~lua_persist_basic_writer (via l_crude_gc)
      `<file>:<line>` - index of function prototype in already written data
      [1] - pre-populated prototype persistence names
        `<file>:<line>` - `<name>`
      err - an object which could not be persisted
    self environment:
      `<object>` - index of object in already written data
      [1] - permanents table
    self environment metatable
*/
class lua_persist_basic_writer : public lua_persist_writer {
 public:
  explicit lua_persist_basic_writer(lua_State* L) : L(L) {}

  ~lua_persist_basic_writer() override = default;

  lua_State* get_stack() override { return L; }

  void init() {
    lua_createtable(L, 1, 8);  // Environment
    lua_pushvalue(L, 2);       // Permanent objects
    lua_rawseti(L, -2, 1);
    lua_createtable(L, 1, 0);  // Environment metatable
    lua_setmetatable(L, -2);
    lua_setfenv(L, 1);
    lua_createtable(L, 1, 4);  // Metatable
    luaT_pushcclosure(L, l_crude_gc<lua_persist_basic_writer>, 0);
    lua_setfield(L, -2, "__gc");
    lua_pushvalue(L, luaT_upvalueindex(1));  // Prototype persistence names
    lua_rawseti(L, -2, 1);
    lua_setmetatable(L, 1);
  }

  int finish() {
    if (get_error() != nullptr) {
      lua_pushnil(L);
      lua_pushstring(L, get_error());
      lua_getmetatable(L, 1);
      lua_getfield(L, -1, "err");
      lua_replace(L, -2);
      return 3;
    } else {
      lua_pushlstring(L, data.c_str(), data.length());
      return 1;
    }
  }

  void fast_write_stack_object(int iIndex) override {
    if (lua_type(L, iIndex) != LUA_TUSERDATA) {
      write_stack_object(iIndex);
      return;
    }

    // Convert index from relative to absolute
    if (iIndex < 0 && iIndex > LUA_REGISTRYINDEX)
      iIndex = lua_gettop(L) + 1 + iIndex;

    // Check for no cycle
    lua_getfenv(L, 1);
    lua_pushvalue(L, iIndex);
    lua_rawget(L, -2);
    lua_rawgeti(L, -2, 1);
    lua_pushvalue(L, iIndex);
    lua_gettable(L, -2);
    lua_replace(L, -2);
    if (!lua_isnil(L, -1) || !lua_isnil(L, -2)) {
      lua_pop(L, 3);
      write_stack_object(iIndex);
      return;
    }
    lua_pop(L, 2);

    // Save the index to the cache
    lua_pushvalue(L, iIndex);
    lua_pushnumber(L, (lua_Number)(next_index++));
    lua_settable(L, -3);

    if (!check_that_userdata_can_be_depersisted(iIndex)) return;

    // Write type, metatable, and then environment
    uint8_t iType = LUA_TUSERDATA;
    write_byte_stream(&iType, 1);
    write_stack_object(-1);
    lua_getfenv(L, iIndex);
    write_stack_object(-1);
    lua_pop(L, 1);

    // Write the raw data
    if (lua_type(L, -1) == LUA_TTABLE) {
      lua_getfield(L, -1, "__persist");
      if (lua_isnil(L, -1))
        lua_pop(L, 1);
      else {
        lua_pushvalue(L, iIndex);
        lua_checkstack(L, 20);
        lua_CFunction fn = lua_tocfunction(L, -2);
        fn(L);
        lua_pop(L, 2);
      }
    }
    write_uint((uint64_t)0x42);  // sync marker
    lua_pop(L, 1);
  }

  void write_stack_object(int iIndex) override {
    // Convert index from relative to absolute
    if (iIndex < 0 && iIndex > LUA_REGISTRYINDEX)
      iIndex = lua_gettop(L) + 1 + iIndex;

    if (lua_type(L, 2) != LUA_TTABLE) {
      luaL_error(L, "Permanents table was lost!");
    }

    // Basic types always have their value written
    int iType = lua_type(L, iIndex);
    if (iType == LUA_TNIL || iType == LUA_TNONE) {
      uint8_t iByte = LUA_TNIL;
      write_byte_stream(&iByte, 1);
    } else if (iType == LUA_TBOOLEAN) {
      uint8_t iByte;
      if (lua_toboolean(L, iIndex))
        iByte = PERSIST_TTRUE;
      else
        iByte = LUA_TBOOLEAN;
      write_byte_stream(&iByte, 1);
    } else if (iType == LUA_TNUMBER) {
      double fValue = lua_tonumber(L, iIndex);
      if (floor(fValue) == fValue && 0.0 <= fValue && fValue <= 16383.0) {
        // Small integers are written as just a few bytes
        // NB: 16383 = 2^14-1, which is the maximum value which
        // can fit into two bytes of VUInt.
        uint8_t iByte = PERSIST_TINTEGER;
        write_byte_stream(&iByte, 1);
        uint16_t iValue = (uint16_t)fValue;
        write_uint(iValue);
      } else {
        // Other numbers are written as an 8 byte double
        uint8_t iByte = LUA_TNUMBER;
        write_byte_stream(&iByte, 1);
        write_byte_stream(reinterpret_cast<uint8_t*>(&fValue), sizeof(double));
      }
    } else {
      // Complex values are cached, and are only written once (if this
      // weren't done, then cycles in the object graph would break
      // things).
      lua_getfenv(L, 1);
      lua_pushvalue(L, iIndex);

      lua_rawget(L, -2);
      uint64_t iValue = static_cast<uint64_t>(lua_tonumber(L, -1));
      if (iValue != 0) {
        lua_pop(L, 2);
        // If the value has not previously been written, then
        // write_object_raw would have been called, and the appropriate
        // data written, and 0 would be returned. Otherwise, the index
        // would be returned, which we offset by the number of types,
        // and then write.
        write_uint(iValue + PERSIST_TCOUNT - 1);
      } else {
        lua_pop(L, 1);

        // Save the index to the cache
        lua_pushvalue(L, iIndex);
        lua_pushnumber(L, static_cast<lua_Number>(next_index++));
        lua_rawset(L, -3);

        // Remove the fenv and add the item back to the top
        lua_pop(L, 1);
        lua_pushvalue(L, iIndex);

        // write the item and restore the stack to the start state
        write_object_raw();
        lua_pop(L, 1);
      }
    }
  }

  void write_object_raw() {
    int top = lua_gettop(L);
    int item_index = top;      // same position in write_stack_object
    int self_index = 1;        // index 1 in write_stack_object
    int permanents_index = 2;  // also in fenv self [1]
    uint8_t item_type = lua_type(L, item_index);

    lua_checkstack(L, top + 5);

    // Lookup the object in the permanents table
    lua_pushvalue(L, item_index);
    lua_gettable(L, permanents_index);
    if (lua_type(L, -1) != LUA_TNIL) {
      // Object is in the permanents table.
      uint8_t item_type = PERSIST_TPERMANENT;
      write_byte_stream(&item_type, 1);

      // Write the key corresponding to the permanent object
      write_stack_object(-1);
      lua_pop(L, 1);
    } else {
      // Object is not in the permanents table.
      lua_pop(L, 1);

      switch (item_type) {
          // LUA_TNIL handled in write_stack_object
          // LUA_TBOOLEAN handled in write_stack_object
          // LUA_TNUMBER handled in write_stack_object

        case LUA_TSTRING: {
          write_byte_stream(&item_type, 1);
          // Strings are simple: length and then bytes (not null
          // terminated)
          size_t iLength;
          const char* sString = lua_tolstring(L, item_index, &iLength);
          write_uint(iLength);
          write_byte_stream(reinterpret_cast<const uint8_t*>(sString), iLength);
          break;
        }

        case LUA_TTABLE: {
          // Save env and insert prior to table
          lua_getfenv(L, self_index);
          lua_insert(L, item_index);
          int table_env_index = item_index;
          item_index += 1;

          // Handle the metatable
          if (lua_getmetatable(L, item_index)) {
            item_type = PERSIST_TTABLE_WITH_META;
            write_byte_stream(&item_type, 1);
            write_stack_object(-1);
            lua_pop(L, 1);
          } else {
            write_byte_stream(&item_type, 1);
          }

          // Write the children as key, value pairs
          lua_pushnil(L);
          while (lua_next(L, item_index)) {
            write_stack_object(-2);  // write the key
            write_stack_object(-1);  // write the value
            lua_pop(L, 1);           // remove the value
            // key is passed back to lua_next
          }

          // Write a nil to mark the end of the children (as nil is
          // the only value which cannot be used as a key in a table).
          uint8_t nil_type = LUA_TNIL;
          write_byte_stream(&nil_type, 1);

          lua_remove(L, table_env_index);
        } break;

        case LUA_TFUNCTION:
          if (lua_iscfunction(L, item_index)) {
            set_error_object(item_index, self_index);
            set_error("Cannot persist C functions");
            break;
          }
          write_byte_stream(&item_type, 1);

          // Write the prototype (the part of a function which is
          // common across multiple closures - see LClosure /
          // Proto in Lua's lobject.h).
          lua_Debug proto_info;
          lua_pushvalue(L, item_index);
          lua_getinfo(L, ">Su", &proto_info);
          write_prototype(&proto_info, item_index);

          // Write the values of the upvalues
          // If available, also write the upvalue IDs (so that in
          // the future, we could hypothetically rejoin shared
          // upvalues). An ID is just an opaque sequence of bytes.
          write_uint(proto_info.nups);
#if LUA_VERSION_NUM >= 502
          write_uint(sizeof(void*));
#else
          write_uint(0);
#endif
          for (int i = 1; i <= proto_info.nups; ++i) {
            lua_getupvalue(L, item_index, i);
            write_stack_object(-1);
#if LUA_VERSION_NUM >= 502
            void* pUpvalueID = lua_upvalueid(L, item_index, i);
            write_byte_stream((uint8_t*)&pUpvalueID, sizeof(void*));
#endif
            lua_pop(L, 1);
          }

          // Write the environment table
          lua_getfenv(L, item_index);
          write_stack_object(-1);
          lua_pop(L, 1);
          break;

        case LUA_TUSERDATA:
          if (!check_that_userdata_can_be_depersisted(item_index)) {
            break;
          }

          // Write type, metatable, and then environment
          write_byte_stream(&item_type, 1);
          write_stack_object(-1);
          lua_getfenv(L, item_index);
          write_stack_object(-1);
          lua_pop(L, 1);

          // Write the raw data
          if (lua_type(L, -1) == LUA_TTABLE) {
            lua_getfield(L, -1, "__persist");
            if (lua_isnil(L, -1)) {
              lua_pop(L, 1);
            } else {
              lua_pushvalue(L, item_index);
              lua_pushvalue(L, self_index);
              lua_pushvalue(L, permanents_index);
              lua_call(L, 3, 0);
            }
          }
          lua_pop(L, 1);               // remove userdata metatable
          write_uint((uint64_t)0x42);  // sync marker
          break;

        default:
          set_error(lua_pushfstring(L, "Cannot persist %s values",
                                    luaL_typename(L, item_type)));
      }
    }

    if (had_error) {
      luaL_error(L, get_error());
    }
  }

  // Checks if userdata can be persisted to file, that is if it has a size
  // of zero, or has a metatable with a __depersist_size, __persist, and
  // __depersist function. The metatable is pushed to the top of the stack.
  bool check_that_userdata_can_be_depersisted(int iIndex) {
    if (lua_getmetatable(L, iIndex)) {
      lua_getfield(L, -1, "__depersist_size");
      if (lua_isnumber(L, -1)) {
        if (static_cast<int>(lua_tointeger(L, -1)) !=
            static_cast<int>(lua_objlen(L, iIndex))) {
          set_error(lua_pushfstring(L,
                                    "__depersist_size is "
                                    "incorrect (%d vs. %d)",
                                    (int)lua_objlen(L, iIndex),
                                    (int)lua_tointeger(L, -1)));
          return false;
        }
        if (lua_objlen(L, iIndex) != 0) {
          lua_getfield(L, -2, "__persist");
          lua_getfield(L, -3, "__depersist");
          if (lua_isnil(L, -1) || lua_isnil(L, -2)) {
            set_error(
                "Can only persist non-empty userdata"
                " if they have __persist and __depersist "
                "metamethods");
            return false;
          }
          lua_pop(L, 2);
        }
      } else {
        if (lua_objlen(L, iIndex) != 0) {
          set_error(
              "Can only persist non-empty userdata if "
              "they have a __depersist_size metafield");
          return false;
        }
      }
      lua_pop(L, 1);
    } else {
      if (lua_objlen(L, iIndex) != 0) {
        set_error(
            "Can only persist userdata without a metatable"
            " if their size is zero");
        return false;
      }
      lua_pushnil(L);
    }
    return true;
  }

  void write_prototype(lua_Debug* pProtoInfo, int iInstanceIndex) {
    // Sanity checks
    if (pProtoInfo->source[0] != '@') {
      // @ denotes that the source was a file
      // (http://www.lua.org/manual/5.1/manual.html#lua_Debug)
      set_error("Can only persist Lua functions defined in source files");
      return;
    }
    if (std::strcmp(pProtoInfo->what, "Lua") != 0) {
      // what == "C" should have been caught by write_object_raw().
      // what == "tail" should be impossible.
      // Hence "Lua" and "main" should be the only values seen.
      // NB: Chunks are not functions defined *in* source files, because
      // chunks *are* source files.
      set_error(lua_pushfstring(L, "Cannot persist entire Lua chunks (%s)",
                                pProtoInfo->source + 1));
      lua_pop(L, 1);
      return;
    }

    // Attempt cached lookup (prototypes are not publicly visible Lua
    // objects, and hence cannot be cached in the normal way of self's
    // environment).
    lua_getmetatable(L, 1);
    lua_pushfstring(L, "%s:%d", pProtoInfo->source + 1,
                    pProtoInfo->linedefined);
    lua_pushvalue(L, -1);
    lua_rawget(L, -3);
    if (!lua_isnil(L, -1)) {
      uint64_t iValue = (uint64_t)lua_tonumber(L, -1);
      lua_pop(L, 3);
      write_uint(iValue + PERSIST_TCOUNT - 1);
      return;
    }
    lua_pop(L, 1);
    lua_pushvalue(L, -1);
    lua_pushnumber(L, (lua_Number)next_index++);
    lua_rawset(L, -4);

    uint8_t iType = PERSIST_TPROTOTYPE;
    write_byte_stream(&iType, 1);

    // Write upvalue names
    write_uint(pProtoInfo->nups);
    for (int i = 1; i <= pProtoInfo->nups; ++i) {
      lua_pushstring(L, lua_getupvalue(L, iInstanceIndex, i));
      write_stack_object(-1);
      lua_pop(L, 2);
    }

    // Write the function's persist name
    lua_rawgeti(L, -2, 1);
    lua_replace(L, -3);
    lua_rawget(L, -2);
    if (lua_isnil(L, -1)) {
      set_error(lua_pushfstring(
          L,
          "Lua functions must be given a unique "
          "persistable name in order to be persisted (attempt to "
          "persist"
          " %s:%d)",
          pProtoInfo->source + 1, pProtoInfo->linedefined));
      lua_pop(L, 2);
      return;
    }
    write_stack_object(-1);
    lua_pop(L, 2);
  }

  void write_byte_stream(const uint8_t* pBytes, size_t iCount) override {
    if (had_error) {
      // If an error occurred, then silently fail to write any
      // data.
      return;
    }

    data.append(reinterpret_cast<const char*>(pBytes), iCount);
  }

  void set_error(const char* sError) override {
    // If multiple errors occur, only record the first.
    if (had_error) {
      return;
    }
    had_error = true;

    // Use the written data buffer to store the error message
    data.assign(sError);
  }

  void set_error_object(int iStackObject, int self_index) {
    if (had_error) return;

    lua_pushvalue(L, iStackObject);
    lua_getmetatable(L, self_index);
    lua_insert(L, -2);
    lua_setfield(L, -2, "err");
    lua_pop(L, 1);
  }

  const char* get_error() {
    if (had_error)
      return data.c_str();
    else
      return nullptr;
  }

 private:
  lua_State* L;
  uint64_t next_index{1};
  std::string data;
  size_t data_size{0};
  bool had_error{false};
};

//! Basic implementation of depersistence interface
/*!
    self - Instance of lua_persist_basic_reader allocated as a Lua userdata
    self environment:
      [-3] - self
      [-2] - pre-populated prototype persistence code
        `<name>` - `<code>`
      [-1] - pre-populated prototype persistence filenames
        `<name>` - `<filename>`
      [ 0] - permanents table
      `<index>` - object already depersisted
    self metatable:
      `__gc` - ~lua_persist_basic_reader (via l_crude_gc)
      `<N>` - userdata to have second `__depersist` call
*/
class lua_persist_basic_reader : public lua_persist_reader {
 public:
  lua_persist_basic_reader(lua_State* L, const uint8_t* pData, size_t iLength)
      : L(L), data(pData), data_buffer_size(iLength) {}

  ~lua_persist_basic_reader() override = default;

  lua_State* get_stack() override { return L; }

  void set_error(const char* sError) override {
    had_error = true;
    string_buffer.assign(sError);
  }

  void init() {
    lua_createtable(L, 32, 0);  // Environment
    lua_pushvalue(L, 2);
    lua_rawseti(L, -2, 0);
    lua_pushvalue(L, luaT_upvalueindex(1));
    lua_rawseti(L, -2, -1);
    lua_pushvalue(L, luaT_upvalueindex(2));
    lua_rawseti(L, -2, -2);
    lua_pushvalue(L, 1);
    lua_rawseti(L, -2, -3);
    lua_setfenv(L, 1);
    lua_createtable(L, 0, 1);  // Metatable
    luaT_pushcclosure(L, l_crude_gc<lua_persist_basic_reader>, 0);
    lua_setfield(L, -2, "__gc");
    lua_setmetatable(L, 1);
  }

  bool read_stack_object() override {
    uint64_t iIndex;
    if (!read_uint(iIndex)) {
      set_error("Expected stack object");
      return false;
    }
    if (lua_type(L, 1) != LUA_TTABLE) {
      // Ensure that index #1 is self environment
      lua_getfenv(L, 1);
      lua_replace(L, 1);
    }
    if (iIndex >= PERSIST_TCOUNT) {
      iIndex += 1 - PERSIST_TCOUNT;
      if (iIndex < (uint64_t)INT_MAX)
        lua_rawgeti(L, 1, (int)iIndex);
      else {
        lua_pushnumber(L, (lua_Number)iIndex);
        lua_rawget(L, 1);
      }
      if (lua_isnil(L, -1)) {
        set_error(
            "Cycle while depersisting permanent object key or "
            "userdata metatable");
        return false;
      }
    } else {
      uint8_t iType = (uint8_t)iIndex;
      switch (iType) {
        case LUA_TNIL:
          lua_pushnil(L);
          break;
        case PERSIST_TPERMANENT: {
          uint64_t iOldIndex = next_index;
          ++next_index;          // Temporary marker
          lua_rawgeti(L, 1, 0);  // Permanents table
          if (!read_stack_object()) return false;
          lua_gettable(L, -2);
          lua_replace(L, -2);
          // Replace marker with actual object
          uint64_t iNewIndex = next_index;
          next_index = iOldIndex;
          save_stack_object();
          next_index = iNewIndex;
          break;
        }
        case LUA_TBOOLEAN:
          lua_pushboolean(L, 0);
          break;
        case PERSIST_TTRUE:
          lua_pushboolean(L, 1);
          break;
        case LUA_TSTRING: {
          size_t iLength;
          if (!read_uint(iLength)) return false;
          if (!read_byte_stream(string_buffer, iLength)) return false;
          lua_pushlstring(L, string_buffer.c_str(), string_buffer.length());
          save_stack_object();
          break;
        }
        case LUA_TTABLE:
          lua_newtable(L);
          save_stack_object();
          if (!lua_checkstack(L, 8)) return false;
          if (!read_table_contents()) return false;
          break;
        case PERSIST_TTABLE_WITH_META:
          lua_newtable(L);
          save_stack_object();
          if (!lua_checkstack(L, 8)) return false;
          if (!read_stack_object()) return false;
          lua_setmetatable(L, -2);
          if (!read_table_contents()) return false;
          break;
        case LUA_TNUMBER: {
          double fValue;
          if (!read_byte_stream(reinterpret_cast<uint8_t*>(&fValue),
                                sizeof(double)))
            return false;
          lua_pushnumber(L, fValue);
          break;
        }
        case LUA_TFUNCTION: {
          if (!lua_checkstack(L, 8)) return false;
          uint64_t iOldIndex = next_index;
          ++next_index;  // Temporary marker
          if (!read_stack_object()) return false;
          lua_call(L, 0, 2);
          // Replace marker with closure
          uint64_t iNewIndex = next_index;
          next_index = iOldIndex;
          save_stack_object();
          next_index = iNewIndex;
          // Set upvalues
          lua_insert(L, -2);
          int iNups, i;
          if (!read_uint(iNups)) return false;
          size_t iIDSize;
          if (!read_uint(iIDSize)) return false;
          for (i = 0; i < iNups; ++i) {
            if (!read_stack_object()) return false;
            // For now, just skip over the upvalue IDs. In the
            // future, the ID may be used to rejoin shared upvalues.
            if (!read_byte_stream(nullptr, iIDSize)) return false;
          }
          lua_call(L, iNups, 0);
          // Read environment
          if (!read_stack_object()) return false;
          lua_setfenv(L, -2);
          break;
        }
        case PERSIST_TPROTOTYPE: {
          if (!lua_checkstack(L, 8)) return false;

          uint64_t iOldIndex = next_index;
          ++next_index;  // Temporary marker
          int iNups;
          if (!read_uint(iNups)) return false;
          if (iNups == 0)
            lua_pushliteral(L, "return function() end,");
          else {
            lua_pushliteral(L, "local ");
            lua_checkstack(L, (iNups + 1) * 2);
            for (int i = 0; i < iNups; ++i) {
              if (i != 0) lua_pushliteral(L, ",");
              if (!read_stack_object()) return false;
              if (lua_type(L, -1) != LUA_TSTRING) {
                set_error("Upvalue name not a string");
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
          if (!read_stack_object()) return false;
          lua_pushliteral(L, "@");

          lua_rawgeti(L, 1, -1);
          lua_pushvalue(L, -3);
          lua_gettable(L, -2);
          lua_replace(L, -2);

          if (lua_isnil(L, -1)) {
            set_error(lua_pushfstring(L,
                                      "Unable to depersist prototype"
                                      " \'%s\'",
                                      lua_tostring(L, -3)));
            return false;
          }
          lua_concat(L, 2);  // Prepend the @ to the filename
          lua_rawgeti(L, 1, -2);
          lua_pushvalue(L, -3);

          lua_gettable(L, -2);
          lua_replace(L, -2);
          lua_remove(L, -3);
          // Construct the closure factory
          load_multi_buffer ls;
          ls.piece[0] = lua_tolstring(L, -3, &ls.piece_size[0]);
          ls.piece[1] = lua_tolstring(L, -1, &ls.piece_size[1]);
          if (luaT_load(L, load_multi_buffer::load_fn, &ls, lua_tostring(L, -2),
                        "bt") != 0) {
            // Should never happen
            lua_error(L);
            return false;
          }
          lua_replace(L, -4);
          lua_pop(L, 2);
          // Replace marker with closure factory
          uint64_t iNewIndex = next_index;
          next_index = iOldIndex;
          save_stack_object();
          next_index = iNewIndex;
          break;
        }
        case LUA_TUSERDATA: {
          bool bHasSetMetatable = false;
          uint64_t iOldIndex = next_index;
          ++next_index;  // Temporary marker
          // Read metatable
          if (!read_stack_object()) return false;
          lua_getfield(L, -1, "__depersist_size");
          if (!lua_isnumber(L, -1)) {
            set_error("Userdata missing __depersist_size metafield");
            return false;
          }
          lua_newuserdata(L, (size_t)lua_tonumber(L, -1));
          lua_replace(L, -2);
          // Replace marker with userdata
          uint64_t iNewIndex = next_index;
          next_index = iOldIndex;
          save_stack_object();
          next_index = iNewIndex;
          // Perform immediate initialisation
          lua_getfield(L, -2, "__pre_depersist");
          if (lua_isnil(L, -1))
            lua_pop(L, 1);
          else {
            // Set metatable now, as pre-depersister may expect it
            // NB: Setting metatable if there isn't a
            // pre-depersister is not a good idea, as if there is an
            // error while the environment table is being
            // de-persisted, then the __gc handler of the userdata
            // will eventually be called with the userdata's
            // contents still being uninitialised.
            lua_pushvalue(L, -3);
            lua_setmetatable(L, -3);
            bHasSetMetatable = true;
            lua_pushvalue(L, -2);
            lua_call(L, 1, 0);
          }
          // Read environment
          if (!read_stack_object()) return false;
          lua_setfenv(L, -2);
          // Set metatable and read the raw data
          if (!bHasSetMetatable) {
            lua_pushvalue(L, -2);
            lua_setmetatable(L, -2);
          }
          lua_getfield(L, -2, "__depersist");
          if (lua_isnil(L, -1))
            lua_pop(L, 1);
          else {
            // Call the __depersist function with the userdata.
            // Note: Unless the __pre_depersist method was called above the
            // new userdata has been created but any initialization such as
            // the constructor normally called by luaT_stdnew has not yet been
            // run. If the object is a C++ class, call the placement new
            // constructor before performing any other operations on the object.
            lua_pushvalue(L, -2);
            lua_rawgeti(L, 1, -3);
            lua_call(L, 2, 1);
            if (lua_toboolean(L, -1) != 0) {
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
          if (!read_uint(iSyncMarker)) return false;
          if (iSyncMarker != 0x42) {
            set_error("sync fail");
            return false;
          }
          break;
        }
        case PERSIST_TINTEGER: {
          uint16_t iValue;
          if (!read_uint(iValue)) return false;
          lua_pushinteger(L, iValue);
          break;
        }
        default:
          lua_pushliteral(L, "Unable to depersist values of type \'");
          if (iType <= LUA_TTHREAD)
            lua_pushstring(L, lua_typename(L, iType));
          else {
            switch (iType) {
              case PERSIST_TPERMANENT:
                lua_pushliteral(L, "permanent");
                break;
              case PERSIST_TTRUE:
                lua_pushliteral(L, "boolean-true");
                break;
              case PERSIST_TTABLE_WITH_META:
                lua_pushliteral(L, "table-with-metatable");
                break;
              case PERSIST_TINTEGER:
                lua_pushliteral(L, "integer");
                break;
              case PERSIST_TPROTOTYPE:
                lua_pushliteral(L, "prototype");
                break;
              case PERSIST_TRESERVED1:
                lua_pushliteral(L, "reserved1");
                break;
              case PERSIST_TRESERVED2:
                lua_pushliteral(L, "reserved2");
                break;
            }
          }
          lua_pushliteral(L, "\'");
          lua_concat(L, 3);
          set_error(lua_tostring(L, -1));
          lua_pop(L, 1);
          return false;
      }
    }
    return true;
  }

  void save_stack_object() {
    if (next_index < (uint64_t)INT_MAX) {
      lua_pushvalue(L, -1);
      lua_rawseti(L, 1, (int)next_index);
    } else {
      lua_pushnumber(L, (lua_Number)next_index);
      lua_pushvalue(L, -2);
      lua_rawset(L, 1);
    }
    ++next_index;
  }

  bool read_table_contents() {
    while (true) {
      if (!read_stack_object()) return false;
      if (lua_type(L, -1) == LUA_TNIL) {
        lua_pop(L, 1);
        return true;
      }
      if (!read_stack_object()) return false;
      // NB: lua_rawset used rather than lua_settable to avoid invoking
      // any metamethods, as they may not have been designed to be called
      // during depersistence.
      lua_rawset(L, -3);
    }
  }

  bool finish() {
    // Ensure that all data has been read
    if (data_buffer_size != 0) {
      set_error(lua_pushfstring(L, "%d bytes of data remain unpersisted",
                                (int)data_buffer_size));
      return false;
    }

    // Ensure that index #1 is self environment
    if (lua_type(L, 1) != LUA_TTABLE) {
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
    for (int i = 1; i <= iNumCalls; ++i) {
      lua_rawgeti(L, 1, i);
      luaL_getmetafield(L, -1, "__depersist");
      lua_insert(L, -2);
      lua_call(L, 1, 0);
    }
    return true;
  }

  bool read_byte_stream(uint8_t* pBytes, size_t iCount) override {
    if (iCount > data_buffer_size) {
      set_error(lua_pushfstring(
          L, "End of input reached while attempting to read %d byte%s",
          (int)iCount, iCount == 1 ? "" : "s"));
      lua_pop(L, 1);
      return false;
    }

    if (pBytes != nullptr) std::memcpy(pBytes, data, iCount);

    data += iCount;
    data_buffer_size -= iCount;
    return true;
  }

  bool read_byte_stream(std::string& bytes, size_t iCount) {
    if (iCount > data_buffer_size) {
      set_error(lua_pushfstring(
          L, "End of input reached while attempting to read %d byte%s",
          (int)iCount, iCount == 1 ? "" : "s"));
      lua_pop(L, 1);
      return false;
    }

    bytes.assign(reinterpret_cast<const char*>(data), iCount);

    data += iCount;
    data_buffer_size -= iCount;
    return true;
  }

  const uint8_t* get_pointer() { return data; }
  uint64_t get_object_count() { return next_index; }

  const char* get_error() {
    if (had_error)
      return string_buffer.c_str();
    else
      return nullptr;
  }

 private:
  lua_State* L;
  uint64_t next_index{1};
  const uint8_t* data;
  size_t data_buffer_size;
  std::string string_buffer;
  bool had_error{false};
};

namespace {

int l_dump_toplevel(lua_State* L) {
  luaL_checktype(L, 2, LUA_TTABLE);
  lua_settop(L, 2);
  lua_pushvalue(L, 1);
  lua_persist_basic_writer* pWriter =
      new (lua_newuserdata(L, sizeof(lua_persist_basic_writer)))
          lua_persist_basic_writer(L);
  lua_replace(L, 1);
  pWriter->init();
  pWriter->write_stack_object(3);
  return pWriter->finish();
}

int l_load_toplevel(lua_State* L) {
  size_t iDataLength;
  const uint8_t* pData = luaT_checkfile(L, 1, &iDataLength);
  luaL_checktype(L, 2, LUA_TTABLE);
  lua_settop(L, 2);
  lua_pushvalue(L, 1);
  lua_persist_basic_reader* pReader =
      new (lua_newuserdata(L, sizeof(lua_persist_basic_reader)))
          lua_persist_basic_reader(L, pData, iDataLength);
  lua_replace(L, 1);
  pReader->init();
  if (!pReader->read_stack_object() || !pReader->finish()) {
    int iNumObjects = (int)pReader->get_object_count();
    int iNumBytes = (int)(pReader->get_pointer() - pData);
    lua_pushnil(L);
    lua_pushfstring(L, "%s after %d objects (%d bytes)",
                    pReader->get_error() ? pReader->get_error()
                                         : "Error while depersisting",
                    iNumObjects, iNumBytes);
    return 2;
  } else {
    return 1;
  }
}

int calculate_line_number(const char* sStart, const char* sPosition) {
  int iLine = 1;
  for (; sStart != sPosition; ++sStart) {
    switch (sStart[0]) {
      case '\0':
        return -1;  // error return value
      case '\n':
        ++iLine;
        if (sStart[1] == '\r') ++sStart;
        break;
      case '\r':
        ++iLine;
        if (sStart[1] == '\n') ++sStart;
        break;
    }
  }
  return iLine;
}

const char* find_function_end(lua_State* L, const char* sStart) {
  const char* sEnd = sStart;
  while (sEnd) {
    sEnd = std::strstr(sEnd, "end");
    if (sEnd) {
      sEnd += 3;
      load_multi_buffer ls;
      ls.insert("return function", 0);
      ls.piece[1] = sStart;
      ls.piece_size[1] = sEnd - sStart;
      if (luaT_load(L, load_multi_buffer::load_fn, &ls, "", "bt") == 0) {
        lua_pop(L, 1);
        return sEnd;
      }
      lua_pop(L, 1);
    }
  }
  return nullptr;
}

int l_persist_dofile(lua_State* L) {
  const char* sFilename = luaL_checkstring(L, 1);
  lua_settop(L, 1);

  // Read entire file into memory
  std::FILE* fFile = std::fopen(sFilename, "r");
  if (fFile == nullptr) {
    const char* sError = std::strerror(errno);
    return luaL_error(L, "cannot open %s: %s", sFilename, sError);
  }
  size_t iBufferSize = lua_objlen(L, luaT_upvalueindex(1));
  size_t iBufferUsed = 0;
  while (!std::ferror(fFile) && !std::feof(fFile)) {
    iBufferUsed +=
        std::fread(static_cast<char*>(lua_touserdata(L, luaT_upvalueindex(1))) +
                       iBufferUsed,
                   1, iBufferSize - iBufferUsed, fFile);
    if (iBufferUsed == iBufferSize) {
      iBufferSize *= 2;
      std::memcpy(lua_newuserdata(L, iBufferSize),
                  lua_touserdata(L, luaT_upvalueindex(1)), iBufferUsed);
      lua_replace(L, luaT_upvalueindex(1));
    } else
      break;
  }
  int iStatus = std::ferror(fFile);
  std::fclose(fFile);
  if (iStatus) {
    const char* sError = std::strerror(errno);
    return luaL_error(L, "cannot read %s: %s", sFilename, sError);
  }

  // Check file
  char* sFile = static_cast<char*>(lua_touserdata(L, luaT_upvalueindex(1)));
  sFile[iBufferUsed] = 0;
  if (sFile[0] == '#') {
    do {
      ++sFile;
      --iBufferUsed;
    } while (sFile[0] != 0 && sFile[0] != '\r' && sFile[0] != '\n');
  }
  if (sFile[0] == LUA_SIGNATURE[0]) {
    return luaL_error(L, "cannot load %s: compiled files not permitted",
                      sFilename);
  }

  // Load and do file
  lua_pushliteral(L, "@");
  lua_pushvalue(L, 1);
  lua_concat(L, 2);
  if (luaL_loadbuffer(L, sFile, iBufferUsed, lua_tostring(L, -1)) != 0)
    return lua_error(L);
  lua_remove(L, -2);
  int iBufferCopyIndex = lua_gettop(L);
  std::memcpy(lua_newuserdata(L, iBufferUsed + 1), sFile, iBufferUsed + 1);
  lua_insert(L, -2);
  lua_call(L, 0, LUA_MULTRET);
  sFile = static_cast<char*>(lua_touserdata(L, luaT_upvalueindex(1)));
  std::memcpy(sFile, lua_touserdata(L, iBufferCopyIndex), iBufferUsed + 1);
  lua_remove(L, iBufferCopyIndex);

  // Extract persistable functions
  const char* sPosition = sFile;
  while (true) {
    sPosition = std::strstr(sPosition, "--[[persistable:");
    if (!sPosition) break;
    sPosition += 16;
    const char* sNameEnd = std::strstr(sPosition, "]]");
    if (sNameEnd) {
      int iLineNumber = calculate_line_number(sFile, sNameEnd);
      const char* sFunctionArgs = std::strchr(sNameEnd + 2, '(');
      const char* sFunctionEnd = find_function_end(L, sFunctionArgs);
      if ((sNameEnd - sPosition) == 1 && *sPosition == ':') {
        // --[[persistable::]] means take the existing name of the
        // function
        sPosition = std::strstr(sNameEnd, "function") + 8;
        sPosition += std::strspn(sPosition, " \t");
        sNameEnd = sFunctionArgs;
        while (sNameEnd[-1] == ' ') --sNameEnd;
      }
      if (iLineNumber != -1 && sFunctionArgs && sFunctionEnd) {
        // Save <filename>:<line> => <name>
        lua_pushfstring(L, "%s:%d", sFilename, iLineNumber);
        lua_pushvalue(L, -1);
        lua_gettable(L, luaT_upvalueindex(2));
        if (lua_isnil(L, -1)) {
          lua_pop(L, 1);
          lua_pushlstring(L, sPosition, sNameEnd - sPosition);
          lua_settable(L, luaT_upvalueindex(2));
        } else {
          return luaL_error(L,
                            "Multiple persistable functions defined"
                            "on the same line (%s:%d)",
                            sFilename, iLineNumber);
        }

        // Save <name> => <filename>
        lua_pushlstring(L, sPosition, sNameEnd - sPosition);
        lua_pushvalue(L, -1);
        lua_gettable(L, luaT_upvalueindex(3));
        if (lua_isnil(L, -1)) {
          lua_pop(L, 1);
          lua_pushvalue(L, 1);
          lua_settable(L, luaT_upvalueindex(3));
        } else {
          return luaL_error(L,
                            "Persistable function name \'%s\' is"
                            " not unique (defined in both %s and %s)",
                            lua_tostring(L, -2), lua_tostring(L, -1),
                            sFilename);
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

int l_errcatch(lua_State* L) {
  // Dummy function for debugging - place a breakpoint on the following
  // return statement to inspect the full C call stack when a Lua error
  // occurs (assuming that l_errcatch is used as the error catch handler).
  return 1;
}

// Due to the various required upvalues, functions are registered manually, but
// we still need a dummy to pass to luaL_register.
constexpr std::array<luaL_Reg, 2> persist_lib{
    {{"errcatch", l_errcatch}, {nullptr, nullptr}}};

}  // namespace

int luaopen_persist(lua_State* L) {
  luaT_register(L, "persist", persist_lib);
  lua_newuserdata(L, 512);  // buffer for dofile
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
