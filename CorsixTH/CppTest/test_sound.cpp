#include <catch2/catch_test_macros.hpp>
#include <catch2/matchers/catch_matchers_floating_point.hpp>


#include "../Src/th_sound.h"

TEST_CASE("volume scales as expected for 40dB", "[linear_to_logarithmic_volume]") {
  // No tolerance for 0, we want silence.
  REQUIRE_THAT(
    th::sound::linear_to_logarithmic_volume(0.0),
    Catch::Matchers::WithinRel(0.0, 0));

  REQUIRE_THAT(
    th::sound::linear_to_logarithmic_volume(0.3),
    Catch::Matchers::WithinRel(0.0398, 0.05));
  REQUIRE_THAT(
    th::sound::linear_to_logarithmic_volume(0.5),
    Catch::Matchers::WithinRel(0.1, 0.05));
  REQUIRE_THAT(
    th::sound::linear_to_logarithmic_volume(0.7),
    Catch::Matchers::WithinRel(0.2512, 0.05));
  REQUIRE_THAT(
    th::sound::linear_to_logarithmic_volume(1.0),
    Catch::Matchers::WithinRel(1.0, 0.05));
}
