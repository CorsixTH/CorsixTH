#include <catch2/catch_test_macros.hpp>
#include <catch2/matchers/catch_matchers.hpp>
#include <catch2/matchers/catch_matchers_string.hpp>
#include <string>

#include "../Src/th_strings.h"

TEST_CASE("skip whitespace", "[skip_utf8_whitespace]") {
  const char* str = " \t \n  1234";
  const char* end = str + 10;

  skip_utf8_whitespace(str, end);

  REQUIRE_THAT(str, Catch::Matchers::Equals("1234"));
}

TEST_CASE("leave non-whitespace", "[skip_utf8_whitespace]") {
  const char* str = "1234    ";
  const char* end = str + 8;

  skip_utf8_whitespace(str, end);

  REQUIRE_THAT(str, Catch::Matchers::Equals("1234    "));
}

TEST_CASE("remove entire string of whitespace", "[skip_utf8_whitespace]") {
  const char* str = "   \t  \n   ";
  const char* end = str + 10;

  skip_utf8_whitespace(str, end);

  REQUIRE_THAT(str, Catch::Matchers::Equals(""));
}
