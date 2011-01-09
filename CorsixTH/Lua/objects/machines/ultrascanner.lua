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
object.id = "ultrascanner"
object.thob = 22
object.research_category = "diagnosis"
object.research_fallback = 40
object.name = _S.object.ultrascanner
object.tooltip = _S.tooltip.objects.ultrascanner
object.ticks = false
object.build_cost = 6000
object.build_preview_animation = 5068
object.default_strength = 12
object.crashed_animation = 3396
local function copy_north_to_south(t)
  t.south = t.north
  return t
end

object.idle_animations = copy_north_to_south {
  north = 1556, --1556 or 3844?
}

object.usage_animations = copy_north_to_south {
  north = {
    in_use = {
      ["Handyman"] = 664,
    },
  },
}
object.multi_usage_animations = {
  ["Standard Male Patient - Doctor"] = copy_north_to_south {
    north = {
      begin_use     = 1560, -- Patient climbs to the bed
      begin_use_2   = 1568, -- Doctor takes the instrument
      in_use        = 1614, -- Doctor examines the patient
      finish_use    = 1574, -- Doctor puts away the instrument
      finish_use_2  = 1610, -- Patient climbs out of the bed
    },
  },
  ["Standard Female Patient - Doctor"] = copy_north_to_south {
    north = {
      begin_use     = 3084, -- Patient climbs to the bed
      begin_use_2   = 3092, -- Doctor takes the instrument
      in_use        = 3096, -- Doctor examines the patient
      finish_use    = 3100, -- Doctor puts away the instrument
      finish_use_2  = 1618, -- Patient climbs out of the bed
    },
  },
}

object.orientations = {
  north = {
    footprint = { {-1, -1}, {0, -1}, {1, -1, only_passable = true},
                  {-1, 0, only_passable =true}, {0, 0}, {1, 0, only_passable = true},
                  {-1, 1, only_passable = true}, {0, 1, only_passable = true} },
    use_position = {-1, 0},
    use_position_secondary = {1, -1},
    handyman_position = {2, 0},
  },
  east = {
    render_attach_position = { {0, 0}, {1, 0}, {-1, 1} },
    footprint = { {-1, -1}, {0, -1, only_passable = true}, {1, -1, only_passable = true},
                  {-1, 0}, {0, 0}, {1, 0, only_passable = true},
                  {-1, 1, only_passable = true}, {0, 1, only_passable = true} },
    use_position = {0, -1},
    use_position_secondary = {-1, 1},
    handyman_position = {0, 2},
    list_bottom = true,
  },
}
local anim_mgr = TheApp.animation_manager
anim_mgr:setMarker(object.idle_animations.north, {-0.9, -0.9})

return object
