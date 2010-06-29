--[[ Copyright (c) 2010 Peter "Corsix" Cawley

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
object.id = "op_sink1"
object.slave_id = "op_sink2"
object.class = "OperatingSink"
object.thob = 33
object.name = _S.object.op_sink1
object.tooltip = _S.tooltip.objects.op_sink1
object.ticks = false
object.walk_in_to_use = true
object.build_cost = 100
object.locked_to_wall = {
  -- permittable wall -> orientation
  north = "east",
  west = "north",
}
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 2354,
}
object.usage_animations = copy_north_to_south {
  north = { in_use = { Surgeon = 2362 } },
}

object.orientations = {
  north = {
    footprint = {
      {0, 0}, {0, -1},
      {1, 0, only_passable = true, invisible = true},
    },
    use_position = {1, 0},
    slave_position = {0, -1},
  },
  east = {
    footprint = {
      {0, 0}, {-1, 0},
      {0, 1, only_passable = true, invisible = true},
    },
    use_position = {0, 1},
    slave_position = {-1, 0},
  },
}

class "OperatingSink" (Object)
OperatingSink:slaveMixinClass()

return object
