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
object.id = "loo"
object.thob = 51
object.name = _S(2, 52)
object.ticks = false
object.build_cost = 300
object.build_preview_animation = 5098
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 1760,
}
object.usage_animations = copy_north_to_south {
  north = {
    begin_use = {
      ["Standard Male Patient"     ] = 1712,
      ["Standard Female Patient"   ] = 3132,
      ["Transparent Male Patient"  ] = 4388,
      ["Slack Male Patient"        ] = 4292,
      ["Invisible Patient"         ] = 4256,
      ["Alternate Male Patient"    ] = 4520,
      ["Transparent Female Patient"] = 4432,
      ["Chewbacca Patient"         ] = 4158,
      ["Elvis Patient"             ] =  950,
    },
    begin_use_2 = {
      ["Standard Male Patient"     ] = 1716,
      ["Standard Female Patient"   ] = 3136,
      ["Transparent Male Patient"  ] = 4392,
      ["Slack Male Patient"        ] = 4296,
      ["Invisible Patient"         ] = 4260,
      ["Alternate Male Patient"    ] = 4524,
      ["Transparent Female Patient"] = 4436,
      ["Chewbacca Patient"         ] = 4162,
      ["Elvis Patient"             ] =  954,
    },
    in_use = {
      ["Standard Male Patient"     ] = {1728, 1732},
      ["Standard Female Patient"   ] = 3144,
      ["Transparent Male Patient"  ] = 4400,
      ["Slack Male Patient"        ] = 4308, -- 4304 is bugged for layer 0, 6
      ["Invisible Patient"         ] = 4272,
      ["Alternate Male Patient"    ] = 4528,
      ["Transparent Female Patient"] = 4440,
      ["Chewbacca Patient"         ] = 4170,
      ["Elvis Patient"             ] =  962,
    },
    finish_use = {
      ["Standard Male Patient"     ] = 1740,
      ["Standard Female Patient"   ] = 3152, -- No bandages, but there are no females with fractured bones anyway
      ["Transparent Male Patient"  ] = 4404,
      ["Slack Male Patient"        ] = 4316,
      ["Invisible Patient"         ] = 4280,
      ["Alternate Male Patient"    ] = 4536,
      ["Transparent Female Patient"] = 4444,
      ["Chewbacca Patient"         ] = 4174,
      ["Elvis Patient"             ] =  966,
    },
    finish_use_2 = {
      ["Standard Male Patient"     ] = 1744,
      ["Standard Female Patient"   ] = 3156,
      ["Transparent Male Patient"  ] = 4408,
      ["Slack Male Patient"        ] = 4320,
      ["Invisible Patient"         ] = 4284,
      ["Alternate Male Patient"    ] = 4540,
      ["Transparent Female Patient"] = 4448,
      ["Chewbacca Patient"         ] = 4740,
      ["Elvis Patient"             ] = 1158,
    },
  },
}
local anim_mgr = TheApp.animation_manager
local kf1, kf2 = {0, 0}, {-0.1, -0.9}
anim_mgr:setMultipleMarkers({
  1712, 3132, 4388, 4292, 4256, 4520, 4432, 4158, 950}, 
  1, kf1, 6, kf2)
kf1 = {-0.1, -0.9}
anim_mgr:setMultipleMarkers({
  1716, 3136, 4392, 4296, 4260, 4524, 4436, 4162, 954},
  kf1)
anim_mgr:setMultipleMarkers({
  1728, 1732, 3144, 4400, 4308, 4272, 4528, 4440, 4170, 962},
  kf1)
anim_mgr:setMultipleMarkers({
  1740, 3152, 4404, 4316, 4280, 4536, 4444, 4174, 966},
  kf1)
kf1, kf2 = {-0.1, -0.9}, {0, 0}
anim_mgr:setMultipleMarkers({
  1744, 3156, 4408, 4320, 4284, 4540, 4448, 4740, 1158},
  0, kf1, 1, kf1, 6, kf2)

object.orientations = {
  north = {
    footprint = { {0, 0}, {0, 1, only_passable = true} },
    use_position = "passable",
    use_animate_from_use_position = true,
  },
  east = {
    footprint = { {0, 0}, {1, 0, only_passable = true} },
    use_position = "passable",
    use_animate_from_use_position = true,
    early_list_while_in_use = true,
  },
}

return object
