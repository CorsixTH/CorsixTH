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
object.id = "pharmacy_cabinet"
object.thob = 39
object.research_category = "cure"
object.research_fallback = 13 -- Sleeping illness
object.name = _S.object.pharmacy_cabinet
object.tooltip = _S.tooltip.objects.pharmacy_cabinet
object.ticks = false
object.build_cost = 1000
object.build_preview_animation = 5088
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 1578,
}
local function anim_set(begin,finish,idle,in_use,idle2)
  return {
    begin_use    = 1590, -- Nurse-only
    begin_use_2  = 1594, -- Nurse-only
    begin_use_3  = begin,
    in_use       = 1666, -- Nurse-only
    finish_use   = finish,
    finish_use_2 = 1598, -- Nurse-only
    secondary = {
      begin_use    = idle,
      begin_use_2  = idle,
      in_use       = in_use,
      finish_use_2 = idle2 or idle,
    },
  }
end
object.multi_usage_animations = {
  ["Nurse - Standard Male Patient"] = copy_north_to_south {
    north = anim_set(1630, 1638, 26, 1662),
  },
  ["Nurse - Standard Female Patient"] = copy_north_to_south {
    north = anim_set(3104, 3112, 10, 3108),
  },
  ["Nurse - Invisible Patient"] = copy_north_to_south {
    north = anim_set(1704, 1638, 1842, {"morph", 1700, 1662, layers = "cured_layers"}, 26),
  },
  ["Nurse - Transparent Male Patient"] = copy_north_to_south {
    north = anim_set(1686, 1638, 1074, {"morph", 1694, 1662}, 26),
  },
  ["Nurse - Transparent Female Patient"] = copy_north_to_south {
    north = anim_set(3120, 3112, 3022, {"morph", 3124, 3108}, 10),
  },
}
object.orientations = {
  north = {
    footprint = { {0, 0}, {0, 1, only_passable = true}, {-1, 1, only_passable = true} },
    use_position = {0, 1},
    use_position_secondary = {-1, 1},
    use_animate_from_use_position = true,
    early_list_while_in_use = true,
  },
  east = {
    footprint = { {0, 0}, {1, 0, only_passable = true}, {1, -1, only_passable = true} },
    use_position = {1, 0},
    use_position_secondary = {1, -1},
    use_animate_from_use_position = true,
    early_list_while_in_use = true,
  },
}

return object
