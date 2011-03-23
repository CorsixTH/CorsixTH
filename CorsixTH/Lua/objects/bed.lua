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
object.id = "bed"
object.thob = 8
object.research_category = "diagnosis"
object.name = _S.object.bed
object.tooltip = _S.tooltip.objects.bed
object.ticks = false
object.build_cost = 200
object.build_preview_animation = 910
object.idle_animations = {
  north = 2644,
  east = 2646,
}

object.usage_animations = {
  north = {
    begin_use = { -- Patient lies down
      ["Standard Male Patient"] = 4686,
      ["Standard Female Patient"] = 4710,
    },
    in_use = { -- Use "animation"
      ["Standard Male Patient"] = 4694,
      ["Standard Female Patient"] = 4718,
    },
    finish_use = { -- Patient stands up again
      ["Standard Male Patient"] = 4702,
      ["Standard Female Patient"] = 4726,
    },
  },
  east = {
    begin_use = { -- Patient lies down
      ["Standard Male Patient"] = 4688,
      ["Standard Female Patient"] = 4712,
    },
    in_use = { -- Use "animation"
      ["Standard Male Patient"] = 4696,
      ["Standard Female Patient"] = 4720,
    },
    finish_use = { -- Patient stands up again
      ["Standard Male Patient"] = 4704,
      ["Standard Female Patient"] = 4728,
    },
  },
}

local anim_mgr = TheApp.animation_manager
local kf1, kf2, kf3 = {1, -1}, {0.4, -1}, {-0.3, -1}
anim_mgr:setMarker(object.usage_animations.north.begin_use, 0, kf1, 4, kf2, 12, kf2, 18, kf3)
anim_mgr:setMarker(object.usage_animations.north.in_use, kf3)
anim_mgr:setMarker(object.usage_animations.north.finish_use, 0, kf3, 6, kf3, 12, kf2, 14, kf1)
-- TODO: The other direction

object.orientations = {
  north = {
    footprint = { {1, -1, only_passable = true}, {-1, -1}, {0, -1}, {-1, 0}, {0, 0} },
    use_position = {1, -1},
    early_list = true,
  },
  east = {
    footprint = { {0, 1, only_passable = true}, {-1, -1}, {0, -1}, {-1, 0}, {0, 0} },
    use_position = {0, 1},
    early_list = true,
  },
  south = {
    footprint = { {1, 0, only_passable = true}, {-1, -1}, {0, -1}, {-1, 0}, {0, 0} },
    use_position = {1, 0},
    render_attach_position = {{-2,0},{-1,0},{0,0},{0,-1,}},
  },
  west = {
    footprint = { {-1, 1, only_passable = true}, {-1, -1}, {0, -1}, {-1, 0}, {0, 0} },
    use_position = {-1, 1},
  },
}

return object
