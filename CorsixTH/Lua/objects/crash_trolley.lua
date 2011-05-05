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
object.id = "crash_trolley"
object.thob = 20
object.research_category = "diagnosis"
object.name = _S.object.crash_trolley
object.tooltip = _S.tooltip.objects.crash_trolley
object.ticks = false
object.build_cost = 250
object.build_preview_animation = 916
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 3838 --1134, there's also a back view (1132), but animation is missing for that
}
object.multi_usage_animations = {
  ["Stripped Male Patient - Doctor"] = copy_north_to_south {
    north = {
      begin_use   = {3740, 3736, 3818}, 
      -- Also possibly 548, 556 and 560 for a more smooth animation?
      in_use      = {540, 544, 552},
      finish_use  = {3802, 3806, 3826},
    },
  },
  ["Stripped Female Patient - Doctor"] = copy_north_to_south {
    north = {
      begin_use   = {3732, 3728, 3822}, -- 532
      in_use      = {524, 528, 536},
      finish_use  = {3810, 3814, 3830},
    },
  },
  ["Stripped Male Patient 2 - Doctor"] = copy_north_to_south {
    north = {
      begin_use   = {3740, 3736, 3818}, 
      -- Also possibly 548, 556 and 560 for a more smooth animation?
      in_use      = {540, 544, 552},
      finish_use  = {3802, 3806, 3826},
    },
  },
  ["Stripped Female Patient 2 - Doctor"] = copy_north_to_south {
    north = {
      begin_use   = {3732, 3728, 3822}, -- 532
      in_use      = {524, 528, 536},
      finish_use  = {3810, 3814, 3830},
    },
  },
  ["Stripped Male Patient 3 - Doctor"] = copy_north_to_south {
    north = {
      begin_use   = {3740, 3736, 3818}, 
      -- Also possibly 548, 556 and 560 for a more smooth animation?
      in_use      = {540, 544, 552},
      finish_use  = {3802, 3806, 3826},
    },
  },
  ["Stripped Female Patient 3 - Doctor"] = copy_north_to_south {
    north = {
      begin_use   = {3732, 3728, 3822}, -- 532
      in_use      = {524, 528, 536},
      finish_use  = {3810, 3814, 3830},
    },
  },
}
object.orientations = {
  north = {
    render_attach_position = { {0, 0}, {-1, 1} },
    footprint = { {-1, 0}, {-1, 1, only_passable = true}, 
      {0, 0, only_passable = true}, {0, 1, only_passable = true} },
    use_position = {-1, 1},
    use_position_secondary = {0, 0},
    list_bottom = true,
  },
  east = {
    render_attach_position = { {0, 0}, {1, -1} },
    footprint = { {0, -1}, {0, 0, only_passable = true}, 
      {1, -1, only_passable = true}, {1, 0, only_passable = true} },
    use_position = {1, -1},
    use_position_secondary = {0, 0},
    list_bottom = true,
  },
}

return object
