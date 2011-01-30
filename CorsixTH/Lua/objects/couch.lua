--[[ Copyright (c) 2009 Peter "Corsix" Cawley

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
object.id = "couch"
object.thob = 18
object.research_category = "diagnosis"
object.name = _S.object.couch
object.tooltip = _S.tooltip.objects.couch
object.ticks = false
object.build_cost = 100
object.build_preview_animation = 5064
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 2540,
}
object.usage_animations = copy_north_to_south {
  north = {
    begin_use = {
      ["Elvis Patient"          ] = 1014,
      ["Standard Male Patient"  ] = 2528,
      ["Standard Female Patient"] = 3180,
    },
    in_use = {
      ["Elvis Patient"          ] =  942,
      ["Standard Male Patient"  ] = 2536,
      ["Standard Female Patient"] = 3330,
    },
    finish_use = {
      ["Elvis Patient"          ] =  938,
      ["Standard Male Patient"  ] = 2532,
      ["Standard Female Patient"] = 3326,
    },
  },
}
object.orientations = {
  north = {
    footprint = { {-1, -1}, {-1, 0}, {0, -1}, {0, 0, only_passable = true} },
    render_attach_position = {-1, 0},
  },
  east = {
    footprint = { {-1, -1}, {-1, 0}, {0, -1}, {0, 0, only_passable = true} }
  },
}

return object
