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
object.id = "jelly_moulder"
object.thob = 47
object.research_category = "cure"
object.research_fallback = 12
object.name = _S.object.jelly_moulder
object.tooltip = _S.tooltip.objects.jelly_moulder
object.ticks = false
object.build_cost = 6500
object.build_preview_animation = 928
object.default_strength = 7
object.crashed_animation = 3312
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 1302,
}

-- Animations in order:
--                                 male female
-- idle                            1302
-- patient enters room              ..
-- doctor goes to button, presses  1382
-- door opens                      1310
-- patient climbs stairs           1334  3958
-- patient stands on top           1338  3962 (repeatable) NYI
-- gets sucked in                  1342  3966
-- floor opens                     1314
-- floor stays open                1318       (repeatable) NYI
-- skeleton rises                  1322
-- door closes                     1326
-- door stays closed               1330       (repeatable) NYI
-- patient on skeleton             1346  3970
-- patient stands inside           1350  3974 (repeatable) NYI
-- door opens                      1354  3978
-- patient steps out               1358  3982
-- door closes                     1306

object.walk_in_to_use = true -- This is only considered by use_object, not multi_use_object. 
object.usage_animations = copy_north_to_south {
  north = {
    in_use  = {["Handyman"] = 3502}, -- (3508: duplicate with error?)
  },
}

-- Note that for this particular machine the staff is the primary user, not the patient
-- This was done in order to be able to let the patient be visible a while longer.
object.multi_usage_animations = {
  ["Doctor - Standard Male Patient"] = copy_north_to_south {
    north = {
      begin_use    = 1382,
      begin_use_2  = 1310,
      begin_use_3  = 1334,
      begin_use_4  = 1342,
      begin_use_5  = 1314,
      in_use       = 1322,
      finish_use   = 1326,
      finish_use_2 = 1346,
      finish_use_3 = 1354,
      finish_use_4 = 1358,
      finish_use_5 = 1306,
    },
  },
  ["Doctor - Standard Female Patient"] = copy_north_to_south {
    north = {
      begin_use    = 1382,
      begin_use_2  = 1310,
      begin_use_3  = 3958,
      begin_use_4  = 3966,
      begin_use_5  = 1314,
      in_use       = 1322,
      finish_use   = 1326,
      finish_use_2 = 3970,
      finish_use_3 = 3978,
      finish_use_4 = 3982,
      finish_use_5 = 1306,
    },
  },
}

object.orientations = {
  north = {
    handyman_position = {2, -1},
    walk_in_tile = {1, -1},
    use_position = {-1, 1},
    use_position_secondary = {1, -1},
    finish_use_position = {-1, 1},
    finish_use_position_secondary = {1, 0},
    finish_use_orientation_secondary = "east",
    footprint = { {-1, -1}, {0, -1}, {1, -1, only_passable = true},
                  {-1, 0}, {0, 0}, {1, 0, only_passable = true},
                  {-1, 1, only_passable = true}, },
    render_attach_position = {0, -1},
  },
  east = {
    handyman_position = {-1, 2},
    walk_in_tile = {-1, 1},
    use_position = {1, -1},
    use_position_secondary = {-1, 1},
    finish_use_position = {1, -1},
    finish_use_position_secondary = {0, 1},
    finish_use_orientation_secondary = "south",
    footprint = { {-1, -1}, {0, -1}, {1, -1, only_passable = true},
                  {-1, 0}, {0, 0},
                  {-1, 1, only_passable = true}, {0, 1, only_passable = true}, },
    render_attach_position = {-1, 0},
  },
}

return object
