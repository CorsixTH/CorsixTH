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
object.id = "chair"
object.thob = 6
object.name = _S.object.chair
object.tooltip = _S.tooltip.objects.chair
object.ticks = false
object.build_cost = 20
object.build_preview_animation = 5056
object.idle_animations = {
  north = 686,
  east = 688,
}
object.walk_in_to_use = true
local function make_list(not_talking, nodding, talking)
  local list = {}
  for i = 1, 16 do list[#list+1] = not_talking end
  if nodding then
    for i = 1, 3 do list[#list+1] = nodding end
  end
  if talking then
    for i = 1, 1 do list[#list+1] = talking end
  end
  return list
end
object.usage_animations = {
  north = {
    begin_use = {
      ["Standard Male Patient"     ] =  678,
      ["Slack Male Patient"        ] = 4580,
      ["Elvis Patient"             ] = 1054,
      ["Standard Female Patient"   ] = 2824,
      ["Slack Female Patient"      ] = 2824,
      ["Chewbacca Patient"         ] = 3792,
      ["Invisible Patient"         ] = 4228,
      ["Transparent Male Patient"  ] = 4360,
      ["Alternate Male Patient"    ] = 4480,
      ["Transparent Female Patient"] = 4816,
      ["Alien Male Patient"        ] =  678, -- TEMP
      ["Alien Female Patient"      ] = 2824, -- TEMP
    },
    in_use = {
      -- Note that patient mouth not visible in this orientation, so we only
      -- need one animation, and not the collection of animations.
      ["Standard Male Patient"     ] =  702,
      ["Slack Male Patient"        ] = 4588,
      ["Elvis Patient"             ] = 1038,
      ["Standard Female Patient"   ] = 2814,
      ["Slack Female Patient"      ] = 2814,
      ["Chewbacca Patient"         ] = 3784,
      ["Invisible Patient"         ] = 4236,
      ["Transparent Male Patient"  ] = 4344,
      ["Alternate Male Patient"    ] = 4488,
      ["Transparent Female Patient"] = 4808,
      ["Alien Male Patient"        ] =  702, -- TEMP
      ["Alien Female Patient"      ] = 2814, -- TEMP
    },
    finish_use = {
      ["Standard Male Patient"     ] =  694,
      ["Slack Male Patient"        ] = 4596,
      ["Standard Female Patient"   ] = 2832,
      ["Slack Female Patient"      ] = 2832,
      ["Chewbacca Patient"         ] = 3776,
      ["Elvis Patient"             ] = 4070,
      ["Invisible Patient"         ] = 4244,
      ["Transparent Male Patient"  ] = 4368,
      ["Alternate Male Patient"    ] = 4504,
      ["Transparent Female Patient"] = 4824,
      ["Alien Male Patient"        ] =  694, -- TEMP
      ["Alien Female Patient"      ] = 2832, -- TEMP
    }
  },
  east = {
    begin_use = {
      ["Standard Male Patient"     ] =  680,
      ["Elvis Patient"             ] = 1056,
      ["Slack Male Patient"        ] = 1540,
      ["Standard Female Patient"   ] = 2826,
      ["Slack Female Patient"      ] = 2826,
      ["Chewbacca Patient"         ] = 3794,
      ["Invisible Patient"         ] = 4230,
      ["Transparent Male Patient"  ] = 4362,
      ["Alternate Male Patient"    ] = 4482,
      ["Transparent Female Patient"] = 4818,
      ["Alien Male Patient"        ] =  680, -- TEMP
      ["Alien Female Patient"      ] = 2826, -- TEMP
    },
    in_use = { -- Not talking, head nodding, talking
      ["Standard Male Patient"     ] = make_list( 704,  736,  744),
      ["Elvis Patient"             ] = make_list(1040,  nil, 4080),
      ["Slack Male Patient"        ] = make_list(1544,  nil, 4606),
      ["Standard Female Patient"   ] = make_list(2818, 3002, 2994),
      ["Slack Female Patient"      ] = make_list(2818, 3002, 2994),
      ["Chewbacca Patient"         ] = make_list(3786,  nil, 4144),
      ["Invisible Patient"         ] = make_list(4238,  nil, 4250),
      ["Transparent Male Patient"  ] = make_list(4378, 4346, 4354),
      ["Alternate Male Patient"    ] = make_list(4490,  nil, 4498),
      -- NB: 4498 also seems to include big-head patients
      ["Transparent Female Patient"] = make_list(4810, 4842, 4834),
      ["Alien Male Patient"        ] = make_list( 704,  736,  744), -- TEMP
      ["Alien Female Patient"      ] = make_list(2818, 3002, 2994), -- TEMP
    },
    finish_use = {
      ["Standard Male Patient"     ] =  696,
      ["Slack Male Patient"        ] = 1552,
      ["Standard Female Patient"   ] = 2834,
      ["Slack Female Patient"      ] = 2834,
      ["Chewbacca Patient"         ] = 3778,
      ["Elvis Patient"             ] = 4072,
      ["Invisible Patient"         ] = 4246,
      ["Transparent Male Patient"  ] = 4370,
      ["Alternate Male Patient"    ] = 4506,
      ["Transparent Female Patient"] = 4826,
      ["Alien Male Patient"        ] =  696, -- TEMP
      ["Alien Female Patient"      ] = 2834, -- TEMP
    }
  },
}
object.orientations = {
  north = {
    footprint = { {0, 0}, {0, -1, only_passable = true} },
    use_position = "passable",
  },
  east = {
    footprint = { {0, 0}, {1, 0, only_passable = true} },
    use_position = "passable",
  },
  south = {
    footprint = { {0, 0}, {0, 1, only_passable = true} },
    use_position = "passable",
  },
  west = {
    footprint = { {0, 0}, {-1, 0, only_passable = true} },
    use_position = "passable",
  },
}

return object
