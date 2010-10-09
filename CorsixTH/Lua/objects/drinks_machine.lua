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
object.id = "drinks_machine"
object.thob = 7
object.name = _S.object.drinks_machine
object.tooltip = _S.tooltip.objects.drinks_machine
object.ticks = false
object.corridor_object = 3
object.build_cost = 500
object.build_preview_animation = 906
object.multiple_users_allowed = true
object.dynamic_info = true
object.idle_animations = {
  south = 170,
  west  = 172,
  north = 174,
  east  = 176,
}
object.usage_animations = {
  south = {
    in_use = {
      ["Standard Male Patient"     ] =  190,
      ["Standard Female Patient"   ] =  250,
      ["Slack Female Patient"      ] =  250,
      ["Transparent Male Patient"  ] = 1112,
      ["Slack Male Patient"        ] = 1532,
      ["Invisible Patient"         ] = 1804,
      ["Alternate Male Patient"    ] = 2756,
      ["Transparent Female Patient"] = 3060, -- is 426 an initial try at this?
      ["Chewbacca Patient"         ] = 3768,
      ["Elvis Patient"             ] =  198,
    },
  },
  east = {
    in_use = {
      ["Standard Male Patient"     ] =  196,
      ["Standard Female Patient"   ] =  256,
      ["Slack Female Patient"      ] =  256,
      ["Transparent Male Patient"  ] = 1118,
      ["Slack Male Patient"        ] = 1538,
      ["Invisible Patient"         ] = 1810,
      ["Alternate Male Patient"    ] = 2762,
      ["Transparent Female Patient"] = 3066,
      ["Chewbacca Patient"         ] = 3774,
      ["Elvis Patient"             ] =  204,
    },
  },
  west = {
    in_use = {
      ["Standard Male Patient"     ] =  192,
      ["Standard Female Patient"   ] =  252,
      ["Slack Female Patient"      ] =  252,
      ["Transparent Male Patient"  ] = 1114,
      ["Slack Male Patient"        ] = 1534,
      ["Invisible Patient"         ] = 1806,
      ["Alternate Male Patient"    ] = 2758,
      ["Transparent Female Patient"] = 3062,
      ["Chewbacca Patient"         ] = 3770,
      ["Elvis Patient"             ] =  200,
    },
  },
}
object.orientations = {
  north = {
    footprint = { {0, 0}, {0, -1, only_passable = true} },
    use_position = "passable",
    added_animation_offset_while_in_use = {-1, 0},
  },
  east = {
    footprint = { {0, 0}, {1, 0, only_passable = true} },
    use_position = "passable",
    use_animate_from_use_position = true,
    early_list_while_in_use = true,
  },
  south = {
    footprint = { {0, 0}, {0, 1, only_passable = true} },
    use_position = "passable",
    use_animate_from_use_position = true,
  },
  west = {
    footprint = { {0, 0}, {-1, 0, only_passable = true} },
    use_position = "passable",
  },
}

return object
