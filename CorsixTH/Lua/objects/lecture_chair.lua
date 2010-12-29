--[[ Copyright (c) 2010 Justin Pasher

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
object.id = "lecture_chair"
object.thob = 36
object.name = _S.object.lecture_chair
object.tooltip = _S.tooltip.objects.lecture_chair
object.ticks = false
object.build_cost = 50
object.build_preview_animation = 5084
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = {
  north = 2626,
  south = 2626,
}
object.usage_animations = copy_north_to_south {
  north = {
    begin_use   = { Doctor = 2632 },
    in_use      = { Doctor = 2622 },
    finish_use  = { Doctor = 2636 },
  },
}
local anim_mgr = TheApp.animation_manager
local kf1, kf2 = {0, 0}, {-1, -0.1}
anim_mgr:setMarker(object.usage_animations.north.begin_use, 0, kf1, 10, kf2)
anim_mgr:setMarker(object.usage_animations.north.in_use, kf2)
anim_mgr:setMarker(object.usage_animations.north.finish_use, 0, kf2, 11, kf2, 18, kf1)

object.orientations = {
  north = {
    footprint = { {0, 0}, {1, 0, only_passable = true} },
    use_position = "passable",
    use_animate_from_use_position = true,
    early_list = true,
  },
  east = {
    footprint = { {0, 0}, {0, 1, only_passable = true} },
    use_position = "passable",
    use_animate_from_use_position = true,
  },
}

return object
