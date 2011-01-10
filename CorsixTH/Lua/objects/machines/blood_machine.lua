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
object.id = "blood_machine"
object.thob = 42
object.research_fallback = 37
object.research_category = "diagnosis"
object.name = _S.object.blood_machine
object.tooltip = _S.tooltip.objects.blood_machine
object.ticks = false
object.build_cost = 3000
object.build_preview_animation = 5094
object.default_strength = 12
object.crashed_animation = 3372
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 2228,
}
-- Note that for this particular machine the staff is the primary user, not the patient
-- This was done in order to be able to let the patient be visible a while longer.
object.multi_usage_animations = {
  ["Doctor - Standard Male Patient"] = copy_north_to_south {
    north = {
      begin_use    = 2232, -- empty door opened
      begin_use_2  = 2236, -- empty chair goes out
      begin_use_3  = 2554, -- Patient invited onto machine
      begin_use_4  = 2220, -- The chair goes in
      begin_use_5  = 2224, -- door closes
      in_use       = 2566, -- The machine does its work TODO: 2562, 2574
      finish_use   = 2252, -- The door is opened
      finish_use_2 = 2256, -- Patient comes out again
      finish_use_3 = 2558, -- Stands up
      finish_use_4 = 2204, -- empty chair in
      finish_use_5 = 2274, -- empty door closed
    },
  },
  ["Doctor - Standard Female Patient"] = copy_north_to_south {
    north = {
      begin_use    = 2232, -- empty door opened
      begin_use_2  = 2236, -- empty chair goes out
      begin_use_3  = 4614, -- Patient invited onto machine 3224
      begin_use_4 = 3232, -- The chair goes in
      begin_use_5  = 3236, -- door closes
      in_use       = 2566, -- The machine does its work TODO: 2562, 2574
      finish_use   = 1172, -- The door is opened
      finish_use_2 = 4738, -- Patient comes out again, 4734 with shadow
      finish_use_3 = 4618, -- Stands up 3228
      finish_use_4 = 2204, -- empty chair in
      finish_use_5 = 2274, -- empty door closed
    },
  },
  ["Doctor - Slack Male Patient"] = copy_north_to_south { -- Only for baldness
    north = {
      begin_use    = 2232, -- empty door opened
      begin_use_2  = 2236, -- empty chair goes out
      begin_use_3  = 5146, -- Patient invited onto machine
      begin_use_4  = 5150, -- The chair goes in
      begin_use_5  = 2224, -- door closes
      in_use       = 2566, -- The machine does its work TODO: 2562, 2574
      finish_use   = 2252, -- The door is opened
      finish_use_2 = 5154, -- Patient comes out again
      finish_use_3 = 622, -- Stands up
      finish_use_4 = 2204, -- empty chair in
      finish_use_5 = 2274, -- empty door closed
    },
  },
}
object.usage_animations = copy_north_to_south {
  north = {in_use = {["Handyman"] = {3498, 3484}}}
}

object.orientations = {
  north = {
    handyman_position = {0, -1},
    use_position_secondary = {1, 0},
    use_position = {0, -1},
    footprint = { {-1, -1, only_passable = true}, {0, -1, only_passable = true},
                  {-2, 0}, {-1, 0}, {0, 0}, {1, 0, only_passable = true},
                  {-1, 1} }
  },
  east = {
    handyman_position = {-1, 0},
    use_position_secondary = {0, 1},
    use_position = {-1, 0},
    footprint = { {0, -2},
                  {-1, -1, only_passable = true}, {0, -1}, {1, -1},
                  {-1, 0, only_passable = true}, {0, 0},
                  {0, 1, only_passable = true} }
  },
}
local anim_mgr = TheApp.animation_manager
anim_mgr:setMarker(object.idle_animations.north, {-1.5, -0.8})

return object
