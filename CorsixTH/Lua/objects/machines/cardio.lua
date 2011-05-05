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
object.id = "cardio"
object.thob = 13
object.research_fallback = 38
object.research_category = "diagnosis"
object.name = _S.object.cardio
object.tooltip = _S.tooltip.objects.cardio
object.ticks = false
object.build_cost = 1000
object.build_preview_animation = 918
object.default_strength = 12
object.crashed_animation = 3308
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 648,
}
object.usage_animations = copy_north_to_south {
  north = {
    in_use = {
      ["Handyman"] = 890
    },
    finish_use = {
      ["Handyman"] = 894
    },
  },
}
object.multi_usage_animations = {
  ["Stripped Male Patient - Doctor"] = copy_north_to_south {
    north = {
      begin_use   = 1018,
      in_use      =  652,
      finish_use  = 3282,
      secondary = {
        begin_use  = 1030,
        in_use     =  656,
        finish_use = 1030,
      },
    },
  },
  ["Stripped Female Patient - Doctor"] = copy_north_to_south {
    north = {
      begin_use   = 3008,
      in_use      = 2840,
      finish_use  = 4556,
      secondary = {
        begin_use  = 1030,
        in_use     =  656,
        finish_use = 1030,
      },
    },
  },
  ["Stripped Male Patient 2 - Doctor"] = copy_north_to_south {
    north = {
      begin_use   = 1018,
      in_use      =  652,
      finish_use  = 3282,
      secondary = {
        begin_use  = 1030,
        in_use     =  656,
        finish_use = 1030,
      },
    },
  },
  ["Stripped Female Patient 2 - Doctor"] = copy_north_to_south {
    north = {
      begin_use   = 3008,
      in_use      = 2840,
      finish_use  = 4556,
      secondary = {
        begin_use  = 1030,
        in_use     =  656,
        finish_use = 1030,
      },
    },
  },
  ["Stripped Male Patient 3 - Doctor"] = copy_north_to_south {
    north = {
      begin_use   = 1018,
      in_use      =  652,
      finish_use  = 3282,
      secondary = {
        begin_use  = 1030,
        in_use     =  656,
        finish_use = 1030,
      },
    },
  },
  ["Stripped Female Patient 3 - Doctor"] = copy_north_to_south {
    north = {
      begin_use   = 3008,
      in_use      = 2840,
      finish_use  = 4556,
      secondary = {
        begin_use  = 1030,
        in_use     =  656,
        finish_use = 1030,
      },
    },
  },
}
object.orientations = {
  north = {
    footprint = { {-1, -1}, {-1, 0}, {1, -1, only_passable = true}, {0, -1}, {0, 0, only_passable = true} },
    render_attach_position = {-1, 0},
    use_position = {1, -1},
    use_position_secondary = {0, 0},
    added_handyman_animate_offset_while_in_use = {1, -1},
  },
  east = {
    footprint = { {-1, -1}, {-1, 0}, {0, -1}, {0, 0, only_passable = true}, {-1, 1, only_passable = true} },
    render_attach_position = {0, -1},
    use_position = {-1, 1},
    use_position_secondary = {0, 0},
    added_handyman_animate_offset_while_in_use = {-1, 1},
  },
}
local anim_mgr = TheApp.animation_manager
anim_mgr:setMarker(object.idle_animations.north, {-0.9, -0.9})

return object
