#include <catch2/catch_test_macros.hpp>

#include "../Src/lua.hpp"
#include "../Src/th_lua.h"
#include "../Src/th_map.h"

TEST_CASE("test l_map_setcellflags", "[l_map_setcellflags]") {
  // Prepare lua bindings
  const lua_state_unique_ptr L(luaL_newstate());
  luaL_openlibs(L.get());
  preload_lua_package(L.get(), "TH", luaopen_th);
  luaT_execute(L.get(), "return require \"TH\"");
  lua_settop(L.get(), 1);

  // Create a map
  lua_getfield(L.get(), -1, "map");
  lua_call(L.get(), 0, 1);
  auto* map = static_cast<level_map*>(lua_touserdata(L.get(), -1));

  // Default map is 0,0, increase size so we can set flags
  map->set_size(128, 128);

  lua_getfield(L.get(), -1, "setCellFlags");

  lua_pushvalue(L.get(), -2);  // Copy the map to the top of the stack

  lua_pushinteger(L.get(), 5);   // X
  lua_pushinteger(L.get(), 10);  // Y

  // flags
  lua_newtable(L.get());
  lua_pushstring(L.get(), "buildable");
  lua_pushboolean(L.get(), true);
  lua_settable(L.get(), -3);

  lua_pushstring(L.get(), "doorNorth");
  lua_pushboolean(L.get(), true);
  lua_settable(L.get(), -3);

  lua_pushstring(L.get(), "parcelId");
  lua_pushnumber(L.get(), 3);
  lua_settable(L.get(), -3);

  lua_call(L.get(), 4, 0);

  const map_tile* tile = map->get_tile(4, 9);

  REQUIRE(tile->flags.buildable == true);
  REQUIRE(tile->flags.do_not_idle == false);
  REQUIRE(tile->flags.door_north == true);
  REQUIRE(tile->iParcelId == 3);
}
