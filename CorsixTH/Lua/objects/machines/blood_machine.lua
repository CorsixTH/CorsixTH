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
object.id = "blood_machine"
object.thob = 42
object.name = _S.object.blood_machine
object.tooltip = _S.tooltip.objects.blood_machine
object.ticks = false
object.build_cost = 3000
object.build_preview_animation = 5094
object.default_strength = 12
object.crashed_animation = 3372
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 2228,
}
object.usage_animations = copy_north_to_south {
  north = {
    in_use = {
      ["Handyman"] = {3484, 3498},
    },
  },
}
object.orientations = {
  north = {
    footprint = { {-1, -1}, {0, -1, only_passable = true},
                  {-2, 0}, {-1, 0}, {0, 0}, {1, 0, only_passable = true},
                  {-1, 1} }
  },
  east = {
    footprint = { {0, -2},
                  {-1, -1}, {0, -1}, {1, -1},
                  {-1, 0, only_passable = true}, {0, 0},
                  {0, 1, only_passable = true} }
  },
}
local anim_mgr = TheApp.animation_manager
anim_mgr:setMarker(object.idle_animations.north, {-1.5, -0.8})

return object
