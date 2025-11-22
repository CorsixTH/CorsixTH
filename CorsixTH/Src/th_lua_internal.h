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

#ifndef CORSIX_TH_TH_LUA_INTERNAL_H_
#define CORSIX_TH_TH_LUA_INTERNAL_H_
#include "config.h"

#include <string>

#include "th_lua.h"

enum class lua_metatable {
  map,
  palette,
  sheet,
  font,
  bitmap_font,
  freetype_font,
  layers,
  anims,
  anim,
  pathfinder,
  surface,
  bitmap,
  cursor,
  lfs_ext,
  sound_archive,
  sound_fx,
  movie,
  string,
  window_base,
  sprite_list,
  string_proxy,
  line,
  iso_fs,
  midi_player,

  count
};

struct lua_register_state {
  lua_State* L;
  int metatables[static_cast<size_t>(lua_metatable::count)];
  int main_table;
  int top;
};

void luaT_setclosure(const lua_register_state* pState, lua_CFunction fn,
                     int iUps);

template <typename... Args>
void luaT_setclosure(const lua_register_state* pState, lua_CFunction fn,
                     int iUps, lua_metatable eMetatable1, Args... args) {
  lua_pushvalue(pState->L,
                pState->metatables[static_cast<size_t>(eMetatable1)]);
  luaT_setclosure(pState, fn, iUps + 1, args...);
}

template <typename... Args>
void luaT_setclosure(const lua_register_state* pState, lua_CFunction fn,
                     int iUps, const char* str, Args... args) {
  lua_pushstring(pState->L, str);
  luaT_setclosure(pState, fn, iUps + 1, args...);
}

/**
 * Add a c++ function to the lua state.
 *
 * @param pState Lua state for the game
 * @param fn The C/C++ function to register
 * @param name The name to use for the function in lua
 * @param args The upvalues to associate with the function in lua
 */
template <typename... Args>
void add_lua_function(const lua_register_state* pState, lua_CFunction fn,
                      const char* name, Args... args) {
  luaT_setclosure(pState, fn, 0, args...);
  lua_setfield(pState->L, -2, name);
}

/**
 * Create a lua 'class' bound to a C++ class.
 *
 * This class should be immediately destructed after adding all of it's
 * functions, metamethods and constants to complete the creation of the bind.
 */
template <typename T>
class lua_class_binding final {
 public:
  lua_class_binding() = delete;
  lua_class_binding(const lua_class_binding&) = delete;
  lua_class_binding(lua_class_binding&&) = delete;
  lua_class_binding& operator=(const lua_class_binding&) = delete;
  lua_class_binding operator=(lua_class_binding&&) = delete;

  /**
   * Initiate class bindings for lua.
   *
   * @param pState The lua environment to bind to.
   * @param name The name to give this lua 'class'.
   * @param new_fn The function to call when a new class is created.
   * @param mt The metatable id for the class
   */
  lua_class_binding(const lua_register_state* pState, const char* name,
                    lua_CFunction new_fn, lua_metatable mt)
      : pState(pState),
        class_name(name),
        class_metatable(pState->metatables[static_cast<size_t>(mt)]) {
    lua_settop(pState->L, pState->top);
    /* Make metatable the environment for registered functions */
    lua_pushvalue(pState->L, class_metatable);
    lua_replace(pState->L, luaT_environindex);
    /* Set the __gc metamethod to C++ destructor */
    luaT_pushcclosure(pState->L, luaT_stdgc<T, luaT_environindex>, 0);
    lua_setfield(pState->L, class_metatable, "__gc");
    /* Set the depersist size */
    lua_pushinteger(pState->L, sizeof(T));
    lua_setfield(pState->L, class_metatable, "__depersist_size");
    /* Create the methods table; call it -> new instance */
    luaT_pushcclosuretable(pState->L, new_fn, 0);
    /* Set __class_name on the methods metatable */
    lua_getmetatable(pState->L, -1);
    lua_pushstring(pState->L, class_name);
    lua_setfield(pState->L, -2, "__class_name");
    lua_pop(pState->L, 1);
    /* Set __index to the methods table */
    lua_pushvalue(pState->L, -1);
    lua_setfield(pState->L, class_metatable, "__index");
  }

  /**
   * Set another class as the superclass of this class.
   *
   * @param super_mt The metatable id of the super class.
   */
  void set_superclass(lua_metatable super_mt) {
    lua_getmetatable(pState->L, -1);
    lua_getfield(pState->L, pState->metatables[static_cast<size_t>(super_mt)],
                 "__index");
    lua_setfield(pState->L, -2, "__index");
    lua_pop(pState->L, 1);
    /* Set metatable[1] to super_mt */
    lua_pushvalue(pState->L, pState->metatables[static_cast<size_t>(super_mt)]);
    lua_rawseti(pState->L, class_metatable, 1);
  }

  /**
   * Add a named constant to the lua interface.
   *
   * @param name (string literal) Name of the constant.
   * @param value (tested with int) Value of the constant.
   */
  template <typename V>
  void add_constant(const char* name, V value) {
    luaT_push(pState->L, value);
    lua_setfield(pState->L, -2, name);
  }

  /**
   * Add a C++ metamethod to the lua class.
   *
   * @param fn The C++ function to call.
   * @param name The name of the metamethod (without the __ prefix).
   * @param args The upvalues for the function.
   */
  template <typename... Args>
  void add_metamethod(lua_CFunction fn, const char* name, Args... args) {
    luaT_setclosure(pState, fn, 0, args...);
    lua_setfield(pState->L, class_metatable,
                 std::string("__").append(name).c_str());
  }

  /**
   * Add a C++ function to the lua class.
   *
   * @param fn The C++ function.
   * @param name The name of the function in lua.
   * @param args The upvalues for the function
   */
  template <typename... Args>
  void add_function(lua_CFunction fn, const char* name, Args... args) {
    add_lua_function(pState, fn, name, args...);
  }

  /**
   * Destructor which finalizes the lua binding
   */
  ~lua_class_binding() {
    lua_setfield(pState->L, pState->main_table, class_name);
  }

 private:
  const lua_register_state* pState;
  const char* class_name;
  int class_metatable;
};

#endif
