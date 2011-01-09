--[[ Copyright (c) 2009 Peter "Corsix" Cawley

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
object.id = "inflator"
object.thob = 9
object.research_category = "cure"
object.research_fallback = 2
object.name = _S.object.inflator
object.tooltip = _S.tooltip.objects.inflator
object.ticks = false
object.build_cost = 2500
object.build_preview_animation = 908
object.default_strength = 10
object.crashed_animation = 3362
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 572,
}
object.multi_usage_animations = {
  ["Standard Male Patient - Doctor"] = copy_north_to_south {
    north = {
      begin_use   = 464, -- Patient invited onto machine
      begin_use_2 = 478, -- Doctor pops patient's head
      begin_use_3 = 482, -- Doctor moves to other side of machine
      in_use      = 496, -- Doctor re-inflates head (do not loop)
      finish_use  = 576, -- Patients walks off machine
    },
  },
}
object.usage_animations = copy_north_to_south {
  north = {in_use = {["Handyman"] = 3480}}
}

object.orientations = {
  north = {
    handyman_position = {1, -1},
    use_position = {0, 1},
    use_position_secondary = {-1, 1},
    finish_use_position = {1, 0},
    finish_use_position_secondary = {1, -1},
    footprint = { {-1, -1}, {0, -1}, {1, -1, only_passable = true},
                  {-1, 0}, {0, 0}, {1, 0, only_passable = true},
                  {-1, 1, only_passable = true}, {0, 1, only_passable = true}, {1, 1, only_passable = true} },
  },
  east = {
    handyman_position = {-1, 1},
    use_position = {1, 0},
    use_position_secondary = {1, -1},
    finish_use_position = {0, 1},
    finish_use_position_secondary = {-1, 1},
    footprint = { {-1, -1}, {0, -1}, {1, -1, only_passable = true},
                  {-1, 0}, {0, 0}, {1, 0, only_passable = true},
                  {-1, 1, only_passable = true}, {0, 1, only_passable = true}, {1, 1, only_passable = true} },
  },
}
local anim_mgr = TheApp.animation_manager
anim_mgr:setMarker(object.idle_animations.north, {-0.9, -1.0})

return object
