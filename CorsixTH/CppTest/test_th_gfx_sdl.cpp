#include <SDL3/SDL.h>

#include <catch2/catch_test_macros.hpp>

#include "th_gfx.h"
#include "th_gfx_sdl.h"

namespace {

struct scoped_dummy_sdl_video {
  bool initialized{false};

  scoped_dummy_sdl_video() {
    SDL_SetHintWithPriority(SDL_HINT_VIDEO_DRIVER, "dummy", SDL_HINT_OVERRIDE);
    SDL_SetHintWithPriority(SDL_HINT_RENDER_DRIVER, "software",
                            SDL_HINT_OVERRIDE);
    initialized = SDL_InitSubSystem(SDL_INIT_VIDEO);
  }

  ~scoped_dummy_sdl_video() {
    if (initialized) {
      SDL_QuitSubSystem(SDL_INIT_VIDEO);
    }
    SDL_Quit();
  }
};

render_target_creation_params make_params(bool override_resolution,
                                          bool direct_zoom) {
  render_target_creation_params params{};
  params.size = {800, 600};
  params.min_size = {640, 480};
  params.fullscreen = false;
  params.direct_zoom = direct_zoom;
  params.override_resolution = override_resolution;
  params.resolution = {640, 480};
  params.present_immediate = true;
  return params;
}

}  // namespace

TEST_CASE("render_target 1.0x zoom buffer follows override_resolution",
          "[render_target][set_scale_factor]") {
  scoped_dummy_sdl_video sdl;
  REQUIRE(sdl.initialized);

  SECTION(
      "override_resolution uses offscreen buffer at 1.0x with direct_zoom") {
    render_target target(make_params(/*override_resolution=*/true,
                                     /*direct_zoom=*/true));
    REQUIRE(target.start_frame());
    REQUIRE(target.set_scale_factor(1.0, scaled_items::all));
    CHECK(SDL_GetRenderTarget(target.get_renderer()) != nullptr);
    const render_size sz = target.get_size();
    CHECK(sz.width == 640);
    CHECK(sz.height == 480);
    REQUIRE(target.end_frame());
    CHECK(SDL_GetRenderTarget(target.get_renderer()) == nullptr);
  }

  SECTION(
      "override_resolution uses offscreen buffer at 1.0x without direct_zoom") {
    render_target target(make_params(/*override_resolution=*/true,
                                     /*direct_zoom=*/false));
    REQUIRE(target.start_frame());
    REQUIRE(target.set_scale_factor(1.0, scaled_items::all));
    CHECK(SDL_GetRenderTarget(target.get_renderer()) != nullptr);
    REQUIRE(target.end_frame());
    CHECK(SDL_GetRenderTarget(target.get_renderer()) == nullptr);
  }

  SECTION("override_resolution off skips offscreen buffer at 1.0x") {
    render_target target(make_params(/*override_resolution=*/false,
                                     /*direct_zoom=*/true));
    REQUIRE(target.start_frame());
    REQUIRE(target.set_scale_factor(1.0, scaled_items::all));
    CHECK(SDL_GetRenderTarget(target.get_renderer()) == nullptr);
    REQUIRE(target.end_frame());
  }

  SECTION("bitmap scaling at 1.0x never enables offscreen target") {
    render_target target(make_params(/*override_resolution=*/true,
                                     /*direct_zoom=*/true));
    REQUIRE(target.start_frame());
    REQUIRE(target.set_scale_factor(1.0, scaled_items::bitmaps));
    CHECK(SDL_GetRenderTarget(target.get_renderer()) == nullptr);
    CHECK_FALSE(target.should_scale_bitmaps(nullptr));
    REQUIRE(target.end_frame());
  }

  SECTION("toggling override_resolution updates 1.0x buffering") {
    render_target target(make_params(/*override_resolution=*/false,
                                     /*direct_zoom=*/true));
    REQUIRE(target.start_frame());
    REQUIRE(target.set_scale_factor(1.0, scaled_items::all));
    CHECK(SDL_GetRenderTarget(target.get_renderer()) == nullptr);
    REQUIRE(target.end_frame());

    REQUIRE(target.update(make_params(/*override_resolution=*/true,
                                      /*direct_zoom=*/true)));
    REQUIRE(target.start_frame());
    REQUIRE(target.set_scale_factor(1.0, scaled_items::all));
    CHECK(SDL_GetRenderTarget(target.get_renderer()) != nullptr);
    REQUIRE(target.end_frame());

    REQUIRE(target.update(make_params(/*override_resolution=*/false,
                                      /*direct_zoom=*/true)));
    REQUIRE(target.start_frame());
    REQUIRE(target.set_scale_factor(1.0, scaled_items::all));
    CHECK(SDL_GetRenderTarget(target.get_renderer()) == nullptr);
    REQUIRE(target.end_frame());
  }
}
