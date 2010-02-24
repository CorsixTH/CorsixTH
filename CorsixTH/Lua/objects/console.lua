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
object.id = "console"
object.thob = 15
object.name = _S.object.console
object.tooltip = _S.tooltip.objects.console
object.ticks = true
object.build_cost = 3000
object.build_preview_animation = 922
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 794,
}
object.usage_animations = copy_north_to_south {
  north = {
    begin_use   = {Doctor = 798}, -- Doctor sits down
    begin_use_2 = {Doctor = 806}, -- Pulls the handle
    in_use      = {Doctor = {
      810, -- Sits idle
      814, -- Pushing buttons
    }},
    finish_use  = {Doctor = 802}, -- Doctor stands up
  },
}

object.orientations = {
  north = {
    footprint = { {-1, -1}, {-1, 0}, {0, -1}, {0, 0, only_passable = true} },
    render_attach_position = {0, -1},
    use_position = "passable"
  },
  east = {
    footprint = { {-1, -1}, {-1, 0}, {0, -1}, {0, 0, only_passable = true} },
    render_attach_position = {-1, 0},
    use_position = "passable"
  },
}

return object
