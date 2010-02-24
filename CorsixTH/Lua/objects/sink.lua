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
object.id = "sink"
object.thob = 32
object.name = _S.object.toilet_sink
object.tooltip = _S.tooltip.objects.toilet_sink
object.ticks = false
object.build_cost = 30
object.build_preview_animation = 5082
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 1748,
}
object.usage_animations = copy_north_to_south {
  north = {
    begin_use = {
      ["Standard Male Patient"] = 1776,
      ["Standard Female Patient"] = 3160,
    },
    in_use = {
      ["Standard Male Patient"] = 1780,
      ["Standard Female Patient"] = 3164,
    },
    finish_use = {
      ["Standard Male Patient"] = 1784,
      ["Standard Female Patient"] = 3168,
    },
  },
}
local anim_mgr = TheApp.animation_manager
local kf1, kf2 = {0, 0}, {0, -0.7}
anim_mgr:setMarker({1776, 3160}, 0, kf1, 4, kf2)
anim_mgr:setMarker({1780, 3164}, kf2)
anim_mgr:setMarker({1784, 3168}, 0, kf2, 34, kf2, 39, kf1)
  
object.orientations = {
  north = {
    footprint = { {0, 0}, {0, 1, only_passable = true} },
    use_position = "passable",
    use_animate_from_use_position = true,
  },
  east = {
    footprint = { {0, 0}, {1, 0, only_passable = true} },
    use_position = "passable",
    use_animate_from_use_position = true,
    early_list_while_in_use = true,
  },
}

return object
