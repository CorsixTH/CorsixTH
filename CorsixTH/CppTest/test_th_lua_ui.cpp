#include <catch2/catch_test_macros.hpp>

#include "../Src/th_lua_ui.cpp"  // NOLINT(bugprone-suspicious-include)

TEST_CASE("range_scale scales correctly", "[range_scale]") {
  REQUIRE(range_scale(0, 100, 0, 10, 20) == 10);
  REQUIRE(range_scale(0, 100, 50, 10, 20) == 15);
  REQUIRE(range_scale(0, 100, 100, 10, 20) == 20);
  REQUIRE(range_scale(0, 200, 100, 0, 100) == 50);
  REQUIRE(range_scale(50, 150, 100, 0, 100) == 50);
  REQUIRE(range_scale(0, 100, 25, 200, 100) == 175);
}

TEST_CASE("range_scale clamps to 0-255", "[range_scale]") {
  REQUIRE(range_scale(0, 100, 100, 0, 300) == 255);
}
