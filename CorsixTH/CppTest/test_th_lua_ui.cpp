#include <catch2/catch_test_macros.hpp>

#include "../Src/th_lua_ui.h"

TEST_CASE("map_color_channel scales correctly", "[map_color_channel]") {
  REQUIRE(map_color_channel(0, 100, 0, 10, 20) == 10);
  REQUIRE(map_color_channel(0, 100, 50, 10, 20) == 15);
  REQUIRE(map_color_channel(0, 100, 100, 10, 20) == 20);
  REQUIRE(map_color_channel(0, 200, 100, 0, 100) == 50);
  REQUIRE(map_color_channel(50, 150, 100, 0, 100) == 50);
  REQUIRE(map_color_channel(0, 100, 25, 200, 100) == 175);
}

TEST_CASE("map_color_channel clamps to [start-end]", "[map_color_channel]") {
  REQUIRE(map_color_channel(0, 100, 120, 0, 200) == 200);
  REQUIRE(map_color_channel(100, 200, 50, 25, 75) == 25);
}
