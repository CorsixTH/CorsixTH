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
object.id = "operating_table"
object.slave_id = "operating_table_b"
object.class = "OperatingTable"
object.thob = 30
object.research_category = "cure"
object.research_fallback = 19 -- Kidney beans
object.name = _S.object.operating_table
object.tooltip = _S.tooltip.objects.operating_table
object.ticks = false
object.build_cost = 5000
object.build_preview_animation = 5080
object.default_strength = 8
object.crashed_animation = 3392
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 2314,
}
object.usage_animations = copy_north_to_south {
  north = {
    in_use = {
      Handyman = 660,
    },
  },
}
object.multi_usage_animations = {
  ["Surgeon - Gowned Male Patient"] = copy_north_to_south {
    north = {
      begin_use = 2318,
      begin_use_2 = 2322,
      in_use = 2348,
      finish_use = 2346,
      finish_use_2 = 2338,
      secondary = {
        begin_use = 416,
        finish_use_2 = 416,
      },
    },
  },
  ["Surgeon - Gowned Female Patient"] = copy_north_to_south {
    north = {
      begin_use = 2318,
      begin_use_2 = 2932,
      in_use = 2938,
      finish_use = 2936,
      finish_use_2 = 2338,
      secondary = {
        begin_use = 2886,
        finish_use_2 = 2886,
      },
    },
  },
}

local anim_mgr = TheApp.animation_manager
-- Slight hack: there seems to be no animation for a patient just lying on the
-- table, so we take a duplicate of the animation for the patient leaving the
-- table, and force its length to be 1, hence causing just the first frame to
-- be used.
anim_mgr:setAnimLength(2348, 1)
anim_mgr:setAnimLength(2938, 1)

object.orientations = {
  north = {
    use_position = {-1, -2},
    use_position_secondary = {-2, -1},
    footprint = {
      {-2, -1, only_passable = true},
      {-1, -1}, {-1, -2, only_passable = true},
      {0, -1}, {0, -2},
      {1, 0}, {1, -2},  {1, -1, only_passable = true},
    },
    render_attach_position = {0, -1},
    slave_position = {1, -1},
  },
  east = {
    use_position = {-2, -1},
    use_position_secondary = {-1, -2},
    footprint = {
      {-1, -2, only_passable = true},
      {-1, -1}, {-2, -1, only_passable = true},
      {-1, 0}, {-2, 0},
      {0, 1}, {-2, 1},  {-1, 1, only_passable = true},
    },
    slave_position = {-1, 1},
    render_attach_position = {-1, 0},
  },
}

class "OperatingTable" (Machine)
OperatingTable:slaveMixinClass()

function OperatingTable:machineUsed(...)
  if self.master then
    -- Is slave. Do nothing.
  else
    return Machine.machineUsed(self, ...)
  end
end

return object
