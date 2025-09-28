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
object.id = "cast_remover"
object.thob = 24
object.research_category = "cure"
object.research_fallback = 9
object.name = _S.object.cast_remover
object.tooltip = _S.tooltip.objects.cast_remover
object.ticks = false
object.build_preview_animation = 5072
object.default_strength = 10
object.crashed_animation = 3388
object.show_in_town_map = true
object.smoke_animation = 3468
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 2492,
}
object.walk_in_to_use = true -- This is only considered by use_object, not multi_use_object.
object.usage_animations = copy_north_to_south {
  north = {
    in_use  = {["Handyman"] = 3514},
  },
}

local anim_mgr = TheApp.animation_manager
anim_mgr:setStaffMarker(object.usage_animations.north.in_use.Handyman, {-1, -38, "px"})

object.multi_usage_animations = {
  ["Alternate Male Patient - Nurse"] = copy_north_to_south {
    north = {
      begin_use    = 2720, -- Patient invited onto machine
      begin_use_2  = 2696, -- Machine closes
      begin_use_3  = 2692, -- Nurse introduces the almighty black bucket
      in_use       = 2688, -- The machine spits in the bucket
      finish_use   = 3662, -- Nurse takes the bucket again (different tile than 3658!)
      finish_use_2 = 3658, -- The machine opens and the patient stands up
    },
  },
  ["Standard Female Patient - Nurse"] = copy_north_to_south {
    north = {
      begin_use    = 4658, -- Patient invited onto machine
      begin_use_2  = 4666, -- Machine closes
      begin_use_3  = 4670, -- Nurse introduces the almighty black bucket
      in_use       = 4674, -- The machine spits in the bucket
      finish_use   = 5112, -- Nurse takes the bucket again
      finish_use_2 = 4682, -- The machine opens up and patient leaves
    },
  },
}

local kf1, kf2, kf3 = {-10, -5, "px"}, {-11, -7, "px"}, {-15, -12, "px"}
local kf4, kf5, kf6 = {-20, -14, "px"}, {-26, -18, "px"}, {-31, -17, "px"}
local kf7 = {-35, -17, "px"}
anim_mgr:setPatientMarker({2720, 4658}, 0, kf1, 1, kf2, 2, kf3, 3, kf4, 4, kf5,
    5, kf6, 6, kf7, 7, kf7)
kf1 = {29, -18, "px"}
anim_mgr:setStaffMarker({2720, 4658}, kf1)

anim_mgr:setPatientMarker({2696, 4666}, kf7)
anim_mgr:setStaffMarker({2696, 4666}, kf1)

anim_mgr:setPatientMarker({2692, 4670}, kf7)
local kf8, kf9, kf10 = {19, -20, "px"}, {11, -18, "px"}, {5, -13, "px"}
local kf11, kf12, kf13 = {-4, -4, "px"}, {5, -4, "px"}, {14, -8, "px"}
local kf14, kf15, kf16 = {19, -10, "px"}, {27, -17, "px"}, {29, -17, "px"}
kf2, kf3, kf4, kf5 = {31, -19, "px"}, {22, -20, "px"}, {16, -23, "px"}, {11, -22, "px"}
kf6 = {16, -20, "px"}
anim_mgr:setStaffMarker({2692, 4670}, 0, kf2, 1, kf3, 2, kf4, 3, kf5, 6, kf5,
    7, kf6, 8, kf8, 9, kf9, 10, kf10, 11, kf10, 12, kf11, 15, kf11, 16, kf12,
    17, kf13, 18, kf14, 19, kf15, 20, kf16)

anim_mgr:setPatientMarker({2688, 4676}, kf7)
anim_mgr:setStaffMarker({2688, 4674}, kf1)

anim_mgr:setPatientMarker({3662, 5112}, kf7)
local kf17, kf18, kf19 = {17, -23, "px"}, {11, -21, "px"}, {15, -19, "px"}
local kf20, kf21, kf22 = {19, -21, "px"}, {27, -19, "px"}, {31, -17, "px"}
local kf23, kf24, kf25 = {38, -16, "px"}, {42, -13, "px"}, {49, -8, "px"}
local kf26, kf27, kf28 = {52, -8, "px"}, {55, -7, "px"}, {59, -4, "px"}
kf2, kf3, kf4, kf5 = {30, -17, "px"}, {27, -14, "px"}, {23, -15, "px"}, {20, -11, "px"}
kf6, kf8, kf9, kf10 = {15, -9, "px"}, {10, -7, "px"}, {-2, -5, "px"}, {3, -7, "px"}
kf11, kf12, kf13, kf14 = {8, -10, "px"}, {14, -13, "px"}, {22, -14, "px"}, {27, -16, "px"}
kf15, kf16, kf1 = {31, -14, "px"}, {27, -20, "px"}, {24, -20, "px"}
anim_mgr:setStaffMarker({3662, 5112}, 0, kf2, 1, kf3, 2, kf4, 3, kf5, 4, kf6,
    5, kf8, 6, kf9, 9, kf9, 10, kf10, 11, kf11, 12, kf12, 13, kf13, 14, kf14,
    15, kf15, 16, kf16, 17, kf1, 18, kf17, 20, kf18, 23, kf18, 24, kf19, 25,
    kf20, 26, kf1, 27, kf21, 28, kf22, 29, kf23, 30, kf24, 31, kf25, 32, kf26,
    33, kf27, 34, kf28)

kf2, kf3, kf4, kf5 = {-26, -16, "px"}, {-17, -11, "px"}, {-9, -10, "px"}, {-7, -9, "px"}
anim_mgr:setPatientMarker({3658, 4682}, 0, kf7, 11, kf7, 12, kf2, 13, kf3,
    14, kf4, 15, kf5)
kf6 = {62, 1, "px"}
anim_mgr:setStaffMarker({3658, 4682}, kf6)


object.orientations = {
  north = {
    use_position = {0, 0},
    handyman_position = {{0, -2}, {-1, -1}},
    walk_in_tile = {0, -1},
    use_position_secondary = {0, -1},
    finish_use_position_secondary = {1, -1},
    footprint = { {-1, -1, complete_cell = true}, {0, -1, only_passable = true}, {1, -1, only_passable = true},
                  {-1, 0, complete_cell = true}, {0, 0, only_passable = true, complete_cell = true},
                  {-1, 1, only_passable = true, need_west_side = true},
                  {-1, -2, only_passable = true, invisible = true, optional = true},
                  {-2, -1, only_passable = true, invisible = true, optional = true} },
    list_bottom = true,
    render_attach_position = {-1, 1},
    smoke_position = {0, 0},
  },
  east = {
    use_position = {0, 0},
    handyman_position = {{-1, -1}, {-2, 0}},
    walk_in_tile = {-1, 0},
    use_position_secondary = {-1, 0},
    finish_use_position_secondary = {-1, 1},
    footprint = { {-1, -1}, {0, -1, complete_cell = true}, {1, -1, only_passable = true, need_north_side = true},
                  {-1, 0, only_passable = true}, {0, 0, only_passable = true, complete_cell = true},
                  {-1, 1, only_passable = true},
                  {-2, -1, only_passable = true, invisible = true, optional = true},
                  {-1, -2, only_passable = true, invisible = true, optional = true} },
    early_list = true,
    list_bottom = true,
    smoke_position = {0, 0},
  },
}
anim_mgr:setPatientMarker(object.idle_animations.north, {-1.6, -0.8})

return object
