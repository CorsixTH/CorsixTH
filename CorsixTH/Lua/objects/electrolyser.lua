--[[ Copyright (c) 2009 Edvin "Lego3" Linge

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
object.id = "electrolyser"
object.thob = 46
object.name = _S(2, 47)
object.ticks = false
object.build_cost = 3500
object.build_preview_animation = 930
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 1262,
}
object.usage_animations = copy_north_to_south {
  north = {
    begin_use   = {["Chewbacca Patient"] = 1266}, -- Patient invited onto machine
    begin_use_2 = {["Chewbacca Patient"] = 1274}, -- Patient gets electrocuted
    begin_use_3 = {["Chewbacca Patient"] = 1278}, -- Patient sparks
    in_use      = {["Chewbacca Patient"] = 1286}, -- Hair falls off
    finish_use  = {["Chewbacca Patient"] = 1294}, -- Patient leaves machine
  },
}

object.orientations = {
  north = {
    render_attach_position = {-1, -1},
    footprint = { {-2, -2}, {-1, -2},
                  {-2, -1}, {-1, -1}, {0, -1}, {0, -2},
                  {-2, 0}, {-1, 0}, {0, 0}, {-1, 1, only_passable = true} },
    use_position = "passable"
  },
  east = {
    render_attach_position = {-1, -1},
    footprint = { {-2, -2}, {-1, -2}, {0, -2},
                  {-2, -1}, {-1, -1}, {0, -1},
                  {-1, 0}, {0, 0},
                  {-2, 0}, {1, -1, only_passable = true} },
    use_position = "passable"
  },
}

return object
