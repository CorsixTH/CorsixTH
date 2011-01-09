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
object.build_cost = 4000
object.build_preview_animation = 5076
object.default_strength = 12
object.crashed_animation = 3384
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
                  {-2, 0}, {-1, 0}, {0, 0} }
  },
  east = {
    use_position = {-1, 1},
    render_attach_position = {-1, -1},
    footprint = { {-2, -2}, {-1, -2}, {0, -2},
                  {-2, -1}, {-1, -1}, {0, -1},
                  {-1, 0}, {0, 0},
                  {-1, 1, only_passable = true} }
  },
}
local anim_mgr = TheApp.animation_manager
anim_mgr:setMarker(object.idle_animations.north, {-2, -2})

return object
