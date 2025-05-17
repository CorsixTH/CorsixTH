#include <catch2/catch_test_macros.hpp>

#include "../Src/lua.hpp"
#include "../Src/th_lua.h"

TEST_CASE("luaT_rotate works", "[luaT_rotate]") {
  lua_state_unique_ptr L(luaL_newstate());
  lua_pushnumber(L.get(), 1);
  lua_pushnumber(L.get(), 2);
  lua_pushnumber(L.get(), 3);
  lua_pushnumber(L.get(), 4);
  lua_pushnumber(L.get(), 5);
  lua_pushnumber(L.get(), 6);
  lua_pushnumber(L.get(), 7);

  REQUIRE(lua_gettop(L.get()) == 7);

  SECTION("rotate 0") {
    luaT_rotate(L.get(), 1, 0);

    REQUIRE(lua_tonumber(L.get(), 1) == 1);
    REQUIRE(lua_tonumber(L.get(), 2) == 2);
    REQUIRE(lua_tonumber(L.get(), 3) == 3);
    REQUIRE(lua_tonumber(L.get(), 4) == 4);
    REQUIRE(lua_tonumber(L.get(), 5) == 5);
    REQUIRE(lua_tonumber(L.get(), 6) == 6);
    REQUIRE(lua_tonumber(L.get(), 7) == 7);
  }

  SECTION("rotate all up 1") {
    luaT_rotate(L.get(), 1, 1);

    REQUIRE(lua_tonumber(L.get(), 1) == 7);
    REQUIRE(lua_tonumber(L.get(), 2) == 1);
    REQUIRE(lua_tonumber(L.get(), 3) == 2);
    REQUIRE(lua_tonumber(L.get(), 4) == 3);
    REQUIRE(lua_tonumber(L.get(), 5) == 4);
    REQUIRE(lua_tonumber(L.get(), 6) == 5);
    REQUIRE(lua_tonumber(L.get(), 7) == 6);
  }

  SECTION("rotate all down 1") {
    luaT_rotate(L.get(), 1, -1);

    REQUIRE(lua_tonumber(L.get(), 1) == 2);
    REQUIRE(lua_tonumber(L.get(), 2) == 3);
    REQUIRE(lua_tonumber(L.get(), 3) == 4);
    REQUIRE(lua_tonumber(L.get(), 4) == 5);
    REQUIRE(lua_tonumber(L.get(), 5) == 6);
    REQUIRE(lua_tonumber(L.get(), 6) == 7);
    REQUIRE(lua_tonumber(L.get(), 7) == 1);
  }

  SECTION("rotate all up 2") {
    luaT_rotate(L.get(), 1, 2);

    REQUIRE(lua_tonumber(L.get(), 1) == 6);
    REQUIRE(lua_tonumber(L.get(), 2) == 7);
    REQUIRE(lua_tonumber(L.get(), 3) == 1);
    REQUIRE(lua_tonumber(L.get(), 4) == 2);
    REQUIRE(lua_tonumber(L.get(), 5) == 3);
    REQUIRE(lua_tonumber(L.get(), 6) == 4);
    REQUIRE(lua_tonumber(L.get(), 7) == 5);
  }

  SECTION("rotate all down 2") {
    luaT_rotate(L.get(), 1, -2);

    REQUIRE(lua_tonumber(L.get(), 1) == 3);
    REQUIRE(lua_tonumber(L.get(), 2) == 4);
    REQUIRE(lua_tonumber(L.get(), 3) == 5);
    REQUIRE(lua_tonumber(L.get(), 4) == 6);
    REQUIRE(lua_tonumber(L.get(), 5) == 7);
    REQUIRE(lua_tonumber(L.get(), 6) == 1);
    REQUIRE(lua_tonumber(L.get(), 7) == 2);
  }

  SECTION("rotate from 3rd up 1") {
    luaT_rotate(L.get(), 3, 1);

    REQUIRE(lua_tonumber(L.get(), 1) == 1);
    REQUIRE(lua_tonumber(L.get(), 2) == 2);
    REQUIRE(lua_tonumber(L.get(), 3) == 7);
    REQUIRE(lua_tonumber(L.get(), 4) == 3);
    REQUIRE(lua_tonumber(L.get(), 5) == 4);
    REQUIRE(lua_tonumber(L.get(), 6) == 5);
    REQUIRE(lua_tonumber(L.get(), 7) == 6);
  }

  SECTION("rotate from -3rd up 1") {
    luaT_rotate(L.get(), -3, 1);

    REQUIRE(lua_tonumber(L.get(), 1) == 1);
    REQUIRE(lua_tonumber(L.get(), 2) == 2);
    REQUIRE(lua_tonumber(L.get(), 3) == 3);
    REQUIRE(lua_tonumber(L.get(), 4) == 4);
    REQUIRE(lua_tonumber(L.get(), 5) == 7);
    REQUIRE(lua_tonumber(L.get(), 6) == 5);
    REQUIRE(lua_tonumber(L.get(), 7) == 6);
  }

  SECTION("rotate from -5th down 2") {
    luaT_rotate(L.get(), -5, -2);

    REQUIRE(lua_tonumber(L.get(), 1) == 1);
    REQUIRE(lua_tonumber(L.get(), 2) == 2);
    REQUIRE(lua_tonumber(L.get(), 3) == 5);
    REQUIRE(lua_tonumber(L.get(), 4) == 6);
    REQUIRE(lua_tonumber(L.get(), 5) == 7);
    REQUIRE(lua_tonumber(L.get(), 6) == 3);
    REQUIRE(lua_tonumber(L.get(), 7) == 4);
  }
}
