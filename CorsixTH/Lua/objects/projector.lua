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
object.id = "projector"
object.thob = 37
object.name = _S.object.projector
object.tooltip = _S.tooltip.objects.projector
object.ticks = false
object.build_cost = 100
object.build_preview_animation = 5086
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = {
  north = 2586,
  south = 2586,
}
object.usage_animations = copy_north_to_south {
  north = {
    begin_use    = { Doctor = 2594 },
    begin_use_2  = { Doctor = 2590 },   -- 2802 is probably better, but it's anchored differently
    begin_use_3  = { Doctor = 2598 },
    in_use       = { Doctor = 2602 },
    finish_use   = { Doctor = 2606 },
    finish_use_2 = { Doctor = 2610 },
    finish_use_3 = { Doctor = 2684 },
  },
}
local anim_mgr = TheApp.animation_manager
local kf1, kf2 = {0, 0}, {-0.4, 0.5}
anim_mgr:setMarker(object.usage_animations.north.begin_use_2, kf2)
anim_mgr:setMarker(object.usage_animations.north.begin_use_3, kf2)
anim_mgr:setMarker(object.usage_animations.north.in_use, kf2)
anim_mgr:setMarker(object.usage_animations.north.finish_use, kf2)
anim_mgr:setMarker(object.usage_animations.north.finish_use_2, 0, kf2, 11, kf2, 16, kf1)

object.orientations = {
  north = {
    footprint = { {0, 0, only_passable = true}, {0, 1}, {-1, 0}, {-1, 1} },
    use_position = "passable"
  },
  east = {
    footprint = { {0, 0, only_passable = true}, {0, -1}, {1, 0}, {1, -1} },
    use_position = "passable"
  },
}

return object
