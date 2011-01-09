--[[ Copyright (c) 2010 Manuel "Roujin" Wolf

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
object.id = "shower"
object.thob = 54
object.research_category = "cure"
object.research_fallback = 6
object.name = _S.object.shower
object.tooltip = _S.tooltip.objects.shower
object.ticks = true
object.build_cost = 6500
object.build_preview_animation = 5100
object.default_strength = 10
object.crashed_animation = 3380
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 2014,
}

object.usage_animations = copy_north_to_south {
  north = {
    begin_use  = {
      ["Standard Male Patient"] = 2018,
      ["Standard Female Patient"] = 2852,
      ["Handyman"] = 3534,
    },
    in_use  = {
      ["Standard Male Patient"] = 2150,
      ["Standard Female Patient"] = 2856,
      ["Handyman"] = 3538,
    },
    finish_use  = {
      ["Standard Male Patient"] = 2026,
      ["Standard Female Patient"] = 2860,
      ["Handyman"] = 3542,
    },
  },
}


object.orientations = {
  north = {
    use_position = {-1, 1},
    footprint = { {-2, -2}, {-1, -2}, {0, -2},
                  {-2, -1}, {-1, -1}, {0, -1},
                  {-2,  0}, {-1,  0}, {0,  0},
                  {-1,  1, only_passable = true}, },
    render_attach_position = {-1, 0},
  },
  east = {
    use_position = {1, -1},
    footprint = { {-2, -2}, {-1, -2}, {0, -2},
                  {-2, -1}, {-1, -1}, {0, -1}, {1, -1, only_passable = true},
                  {-2,  0}, {-1,  0}, {0,  0}, },
    render_attach_position = {-1, 0},
  },
}

return object
