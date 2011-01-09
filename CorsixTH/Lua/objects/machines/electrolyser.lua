--[[ Copyright (c) 2009 Edvin "Lego3" Linge

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
object.id = "electrolyser"
object.thob = 46
object.research_category = "cure"
object.research_fallback = 3
object.name = _S.object.electrolyser
object.tooltip = _S.tooltip.objects.electrolyser
object.ticks = false
object.build_cost = 3500
object.build_preview_animation = 930
object.default_strength = 10
object.crashed_animation = 3300
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 1262,
}
object.usage_animations = copy_north_to_south {
  north = {
    begin_use    = { -- Patient invited onto machine
      ["Standard Female Patient"] = 1266,
      ["Standard Male Patient"  ] = 1266,
      ["Handyman"               ] = 3546,
    },
    in_use       = { -- Patient gets electrocuted
      ["Standard Female Patient"] = 1274,
      ["Standard Male Patient"  ] = 1274,
      ["Handyman"               ] = 3550,
    },
    finish_use   = { -- Patient sparks
      ["Standard Female Patient"] = 1278,
      ["Standard Male Patient"  ] = 1278,
      ["Handyman"               ] = 3554,
    }, 
    finish_use_2 = { -- Hair falls off 
      ["Standard Female Patient"] = 2940,
      ["Standard Male Patient"  ] = 1286,
    },
    finish_use_3 = { -- Patient leaves machine
      ["Standard Female Patient"] = 2944,
      ["Standard Male Patient"  ] = 1294,
    },
  },
}

object.orientations = {
  north = {
    render_attach_position = {-1, -1},
    footprint = { {-2, -2}, {-1, -2}, {0, -2},
                  {-2, -1}, {-1, -1}, {0, -1},
                  {-2,  0}, {-1,  0}, {0,  0},
                  {-1, 1, only_passable = true} },
    use_position = "passable"
  },
  east = {
    render_attach_position = {-1, -1},
    footprint = { {-2, -2}, {-1, -2}, {0, -2},
                  {-2, -1}, {-1, -1}, {0, -1},
                  {-2,  0}, {-1,  0}, {0,  0},
                  {1, -1, only_passable = true} },
    use_position = "passable"
  },
}
local anim_mgr = TheApp.animation_manager
anim_mgr:setMarker(object.idle_animations.north, {-1.3, -1.2})

return object
