--[[ Copyright (c) 2013 Luís "Driver" Duarte

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

object.id = "gates_to_hell"
object.name = "Gates to Hell"
object.thob = 48
object.ticks = true
object.walk_in_to_use = true

object.idle_animations = {
  south = 1602,
  east = 1602
}

object.usage_animations = {
  south = {
    in_use = {
      ["Standard Male Patient"] = 4560,
    },
  },
  east = {
    in_use = {
      ["Standard Male Patient"] = 4560,
    },
  }
}

local anim_mgr = TheApp.animation_manager
anim_mgr:setMarker(object.usage_animations.south.in_use, 0, {0,0})
anim_mgr:setMarker(object.usage_animations.east.in_use,  0, {0,0})

-- Orientation directions are relative to the patient's death location:
object.orientations = {
  south = {
    use_position = {0, 0},
    footprint = { {1, 0, only_passable = true},
                  {0, 0, complete_cell = true},
                  {-1, 0, only_passable = true} },
    use_animate_from_use_position = false
  },
  east = {
    use_position = {0, 0},
    footprint = { {0, -1, only_passable = true}, {0, 0, complete_cell = true}, {0, 1, only_passable = true} },
    use_animate_from_use_position = false
  }
}

return object
