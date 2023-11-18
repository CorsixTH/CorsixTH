#include "../Src/th_lua.h"
#include <catch2/catch_test_macros.hpp>

TEST_CASE("luaT_rotate works", "[luaT_rotate]") {
  lua_State* L = luaL_newstate();
  lua_pushnumber(L, 1);
  lua_pushnumber(L, 2);
  lua_pushnumber(L, 3);
  lua_pushnumber(L, 4);
  lua_pushnumber(L, 5);
  lua_pushnumber(L, 6);
  lua_pushnumber(L, 7);

  REQUIRE(lua_gettop(L) == 7);

  SECTION("rotate 0") {
    luaT_rotate(L, 1, 0);

    REQUIRE(lua_tonumber(L, 1) == 1);
    REQUIRE(lua_tonumber(L, 2) == 2);
    REQUIRE(lua_tonumber(L, 3) == 3);
    REQUIRE(lua_tonumber(L, 4) == 4);
    REQUIRE(lua_tonumber(L, 5) == 5);
    REQUIRE(lua_tonumber(L, 6) == 6);
    REQUIRE(lua_tonumber(L, 7) == 7);
  }

  SECTION("rotate all up 1") {
    luaT_rotate(L, 1, 1);

    REQUIRE(lua_tonumber(L, 1) == 7);
    REQUIRE(lua_tonumber(L, 2) == 1);
    REQUIRE(lua_tonumber(L, 3) == 2);
    REQUIRE(lua_tonumber(L, 4) == 3);
    REQUIRE(lua_tonumber(L, 5) == 4);
    REQUIRE(lua_tonumber(L, 6) == 5);
    REQUIRE(lua_tonumber(L, 7) == 6);
  }

  SECTION("rotate all down 1") {
    luaT_rotate(L, 1, -1);

    REQUIRE(lua_tonumber(L, 1) == 2);
    REQUIRE(lua_tonumber(L, 2) == 3);
    REQUIRE(lua_tonumber(L, 3) == 4);
    REQUIRE(lua_tonumber(L, 4) == 5);
    REQUIRE(lua_tonumber(L, 5) == 6);
    REQUIRE(lua_tonumber(L, 6) == 7);
    REQUIRE(lua_tonumber(L, 7) == 1);
  }

  SECTION("rotate all up 2") {
    luaT_rotate(L, 1, 2);

    REQUIRE(lua_tonumber(L, 1) == 6);
    REQUIRE(lua_tonumber(L, 2) == 7);
    REQUIRE(lua_tonumber(L, 3) == 1);
    REQUIRE(lua_tonumber(L, 4) == 2);
    REQUIRE(lua_tonumber(L, 5) == 3);
    REQUIRE(lua_tonumber(L, 6) == 4);
    REQUIRE(lua_tonumber(L, 7) == 5);
  }

  SECTION("rotate all down 2") {
    luaT_rotate(L, 1, -2);

    REQUIRE(lua_tonumber(L, 1) == 3);
    REQUIRE(lua_tonumber(L, 2) == 4);
    REQUIRE(lua_tonumber(L, 3) == 5);
    REQUIRE(lua_tonumber(L, 4) == 6);
    REQUIRE(lua_tonumber(L, 5) == 7);
    REQUIRE(lua_tonumber(L, 6) == 1);
    REQUIRE(lua_tonumber(L, 7) == 2);
  }

  SECTION("rotate from 3rd up 1") {
    luaT_rotate(L, 3, 1);

    REQUIRE(lua_tonumber(L, 1) == 1);
    REQUIRE(lua_tonumber(L, 2) == 2);
    REQUIRE(lua_tonumber(L, 3) == 7);
    REQUIRE(lua_tonumber(L, 4) == 3);
    REQUIRE(lua_tonumber(L, 5) == 4);
    REQUIRE(lua_tonumber(L, 6) == 5);
    REQUIRE(lua_tonumber(L, 7) == 6);
  }

  SECTION("rotate from -3rd up 1") {
    luaT_rotate(L, -3, 1);

    REQUIRE(lua_tonumber(L, 1) == 1);
    REQUIRE(lua_tonumber(L, 2) == 2);
    REQUIRE(lua_tonumber(L, 3) == 3);
    REQUIRE(lua_tonumber(L, 4) == 4);
    REQUIRE(lua_tonumber(L, 5) == 7);
    REQUIRE(lua_tonumber(L, 6) == 5);
    REQUIRE(lua_tonumber(L, 7) == 6);
  }

  SECTION("rotate from -5th down 2") {
    luaT_rotate(L, -5, -2);

    REQUIRE(lua_tonumber(L, 1) == 1);
    REQUIRE(lua_tonumber(L, 2) == 2);
    REQUIRE(lua_tonumber(L, 3) == 5);
    REQUIRE(lua_tonumber(L, 4) == 6);
    REQUIRE(lua_tonumber(L, 5) == 7);
    REQUIRE(lua_tonumber(L, 6) == 3);
    REQUIRE(lua_tonumber(L, 7) == 4);
  }

  lua_close(L);
}
