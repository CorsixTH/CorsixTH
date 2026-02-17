--[[ Copyright (c) 2009 Manuel König

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
SOFTWARE. --]]

local object = {}
object.id = "x_ray"
object.thob = 27
object.research_category = "diagnosis"
object.research_fallback = 39
object.name = _S.object.x_ray
object.tooltip = _S.tooltip.objects.x_ray
object.ticks = false
object.build_preview_animation = 5076
object.default_strength = 12
object.crashed_animation = 3384
object.show_in_town_map = true
object.smoke_animation = 3440
local function copy_north_to_south(t)
  t.south = t.north
  return t
end

object.idle_animations = copy_north_to_south {
  north = 1988,
}

object.usage_animations = copy_north_to_south {
  north = {
    begin_use = { -- Patient walks into X-ray
      ["Standard Male Patient"] = 1964,
      ["Standard Female Patient"] = 2948,
      ["Slack Female Patient"] = 2948,
      ["Slack Male Patient"] = 5178,
      ["Elvis Patient"] = 5120,
      ["Chewbacca Patient"] = 5132,
      ["Invisible Patient"] = 614,
      ["Handyman"] = 3558,
    },
    in_use = { -- Radiation
      ["Standard Male Patient"] = 1960,
      ["Standard Female Patient"] = 2952,
      ["Slack Female Patient"] = 2952,
      ["Slack Male Patient"] = 5174,
      ["Elvis Patient"] = 5128,
      ["Chewbacca Patient"] = 610,
      ["Invisible Patient"] = 5140,
      ["Handyman"] = 3562,
    },
    finish_use = { -- Patient walks away
      ["Standard Male Patient"] = 1992,
      ["Standard Female Patient"] = 2956,
      ["Slack Female Patient"] = 2956,
      ["Slack Male Patient"] = 5182,
      ["Elvis Patient"] = 5124,
      ["Chewbacca Patient"] = 5136, -- or 5138?
      ["Invisible Patient"] = 618,
      ["Handyman"] = 3562, -- TODO: Another glitch in the original. This sprite is missing.
    },
  },
}

object.orientations = {
  north = {
    use_position = {1, -1},
    render_attach_position = {-1, -1},
    footprint = { {-2, -2}, {-1, -2},
                  {-2, -1}, {-1, -1}, {0, -1}, {1, -1, only_passable = true},
                  {-2, 0}, {-1, 0}, {0, 0} },
    smoke_position = {0, 0},
  },
  east = {
    use_position = {-1, 1},
    render_attach_position = {-1, -1},
    footprint = { {-2, -2}, {-1, -2}, {0, -2},
                  {-2, -1}, {-1, -1}, {0, -1},
                  {-1, 0}, {0, 0},
                  {-1, 1, only_passable = true} },
    smoke_position = {0, 0},
  },
}
local anim_mgr = TheApp.animation_manager
anim_mgr:setPatientMarker(object.idle_animations.north, {-2, -2})

local kf0 = {59, -4, "px"}
local kf1 = {55, -8, "px"}
local kf2 = {54, -8, "px"}
local kf2 = {51, -8, "px"}
local kf3 = {47, -11, "px"}
local kf4 = {43, -12, "px"}
local kf5 = {43, -13, "px"}
local kf6 = {39, -15, "px"}
local kf7 = {34, -18, "px"}
local kf8 = {31, -20, "px"}
local kf9 = {29, -21, "px"}
local kf10 = {24, -23, "px"}
local kf11 = {18, -27, "px"}
local kf12 = {15, -33, "px"}
local kf13 = {14, -34, "px"}
local kf14 = {6, -36, "px"}

anim_mgr:setStaffMarker(3558, 0, kf0, 1, kf1, 2, kf2, 3, kf3, 4, kf4, 5, kf5,
    6, kf6, 7, kf7, 8, kf8, 9, kf9, 10, kf10, 11, kf11, 12, kf12, 13, kf13,
    14, kf14)
anim_mgr:setStaffMarker(3562, kf14)

return object
