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
object.id = "operating_table_b"
object.class = "OperatingTable"
object.thob = 12
object.name = _S.object.operating_table
object.tooltip = _S.tooltip.objects.operating_table
object.ticks = false
object.build_cost = 0
object.crashed_animation = 0
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 2310,
}
object.usage_animations = copy_north_to_south {
  north = {
    begin_use = { Surgeon = 2306 },
    begin_use_2 = { Surgeon = 2330 },
    in_use = { Surgeon = {4890, 2326} },
    finish_use = { Surgeon = 2334 },
    finish_use_2 = { Surgeon = 2342 },
  }
}

object.orientations = {
  north = {
    use_position = {0, 0},
    footprint = {},
  },
  east = {
    use_position = {0, 0},
    footprint = {},
  },
}

return object
