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
object.id = "x_ray_viewer"
object.thob = 29
object.name = _S.object.x_ray_viewer
object.tooltip = _S.tooltip.objects.x_ray_viewer
object.ticks = false
object.build_preview_animation = 5078
object.show_in_town_map = true
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
  north = 2390,
}

object.orientations = {
  north = {
    footprint = {
      {0, 0, need_west_side = true },
    },
    render_attach_position = {
      -1, -2, crop_base = 1, crop_width = 1,
      proxies = {{1, -1, crop_base = 1, crop_width = 1}, {-2, 0, crop_base = 0, crop_width = 4}}
    }
  },
  east = {
    footprint = {
      {0, 0, need_north_side = true},
    },
    render_attach_position = {
      0, -2, crop_base = 1, crop_width = 1,
      proxies = {
        {0, -1, crop_base = 1, crop_width = 1},
        {0, 0, crop_base = 1, crop_width = 1},
        {-1, 1, crop_base = 0, crop_width = 3}
      }
    }
  },
}

return object
