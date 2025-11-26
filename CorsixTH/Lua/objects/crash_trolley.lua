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
object.id = "crash_trolley"
object.thob = 20
object.research_category = "diagnosis"
object.name = _S.object.crash_trolley
object.tooltip = _S.tooltip.objects.crash_trolley
object.ticks = false
object.build_preview_animation = 916
object.show_in_town_map = true
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 3838 --1134, there's also a back view (1132), but animation is missing for that
}
object.multi_usage_animations = {
  ["Stripped Male Patient - Doctor"] = copy_north_to_south {
    north = {
      begin_use   = {3740, 3736, 3818},
      -- Also possibly 548, 556 and 560 for a more smooth animation?
      in_use      = {540, 544, 552},
      finish_use  = {3802, 3806, 3826},
    },
  },
  ["Stripped Female Patient - Doctor"] = copy_north_to_south {
    north = {
      begin_use   = {3732, 3728, 3822}, -- 532
      in_use      = {524, 528, 536},
      finish_use  = {3810, 3814, 3830},
    },
  },
  ["Stripped Male Patient 2 - Doctor"] = copy_north_to_south {
    north = {
      begin_use   = {3740, 3736, 3818},
      -- Also possibly 548, 556 and 560 for a more smooth animation?
      in_use      = {540, 544, 552},
      finish_use  = {3802, 3806, 3826},
    },
  },
  ["Stripped Female Patient 2 - Doctor"] = copy_north_to_south {
    north = {
      begin_use   = {3732, 3728, 3822}, -- 532
      in_use      = {524, 528, 536},
      finish_use  = {3810, 3814, 3830},
    },
  },
  ["Stripped Male Patient 3 - Doctor"] = copy_north_to_south {
    north = {
      begin_use   = {3740, 3736, 3818},
      -- Also possibly 548, 556 and 560 for a more smooth animation?
      in_use      = {540, 544, 552},
      finish_use  = {3802, 3806, 3826},
    },
  },
  ["Stripped Female Patient 3 - Doctor"] = copy_north_to_south {
    north = {
      begin_use   = {3732, 3728, 3822}, -- 532
      in_use      = {524, 528, 536},
      finish_use  = {3810, 3814, 3830},
    },
  },
}
object.orientations = {
  north = {
    -- render_attach_position = { {0, 0}, {-1, 1} },
    footprint = { {-1, 0, complete_cell = true}, {-1, 1, only_passable = true},
      {0, 0, only_passable = true}, {0, 1, only_passable = true} },
    use_position = {-1, 1},
    use_position_secondary = {0, 0},
    list_bottom = true,
  },
  east = {
    -- render_attach_position = { {0, 0}, {1, -1} },
    footprint = { {0, -1, complete_cell = true}, {0, 0, only_passable = true},
      {1, -1, only_passable = true}, {1, 0, only_passable = true} },
    use_position = {1, -1},
    use_position_secondary = {0, 0},
    list_bottom = true,
  },
}

local anim_mgr = TheApp.animation_manager
local kf1 = {-39, 11, "px"}
anim_mgr:setStaffMarker(524, kf1)

kf1 = {-63, -2, "px"}
anim_mgr:setPatientMarker(524, kf1)

local kf2 = {-34, 7, "px"}
anim_mgr:setStaffMarker(528, kf2)
anim_mgr:setPatientMarker(528, kf1)

local kf3, kf4, kf5 = {-25, 7, "px"}, {-22, 8, "px"}, {-29, 10, "px"}
local kf6, kf7 = {-31, 11, "px"}, {-36, 10, "px"}
kf2 = {-35, 11, "px"}
anim_mgr:setStaffMarker({536, 552}, 0, kf2, 1, kf3, 2, kf4, 17, kf4, 18, kf5,
    19, kf6, 20, kf7)
anim_mgr:setPatientMarker({536, 552}, kf1)
anim_mgr:setStaffMarker(540, kf7)
anim_mgr:setPatientMarker(540, kf1)

local kf8, kf9, kf10 = {-38, 13, "px"}, {-34, 10, "px"}, {-31, 14, "px"}
local kf11 = {-33, 11, "px"}
anim_mgr:setStaffMarker(544, 0, kf8, 36, kf8, 37, kf9, 38, kf10, 40, kf11)
anim_mgr:setPatientMarker(544, kf1)

kf8, kf9, kf10, kf11 = {0, 0, "px"}, {-1, 0, "px"}, {-9, 2, "px"}, {-10, 4, "px"}
kf2, kf3, kf5, kf6 = {-12, 7, "px"}, {-17, 5, "px"}, {-22, 10, "px"}, {-25, 11, "px"}
kf7 = {-31, 15, "px"}
anim_mgr:setStaffMarker({3728, 3732, 3736, 3740}, 0, kf8, 4, kf8, 5, kf9, 6, kf10,
    7, kf11, 8, kf2, 9, kf3, 10, kf5, 11, kf6, 12, kf7)
anim_mgr:setPatientMarker({3728, 3732, 3736, 3740}, kf1)

local kf12 = {3, 4, "px"}
kf9, kf10, kf2, kf3 = {-30, 17, "px"}, {-22, 12, "px"}, {-17, 11, "px"}, {-13, 9, "px"}
kf5, kf6 = {-8, 9, "px"}, {-1, 8, "px"}
anim_mgr:setStaffMarker({3802, 3806, 3810, 3814}, 0, kf9, 1, kf10, 2, kf2, 3, kf3,
    4, kf5, 5, kf6, 6, kf12, 7, kf8)
anim_mgr:setPatientMarker({3802, 3806, 3810, 3814}, kf1)

local kf13, kf14, kf15 = {-10, 7, "px"}, {-12, 6, "px"}, {-17, 8, "px"}
local kf16, kf17 = {-25, 10, "px"}, {-31, 17, "px"}
kf12 = {-1, 2, "px"}
anim_mgr:setStaffMarker({3818, 3822}, 0, kf8, 1, kf8, 2, kf12, 3, kf11, 4, kf13,
    5, kf14, 6, kf15, 7, kf4, 8, kf16, 9, kf17, 10, kf7)
anim_mgr:setPatientMarker({3818, 3822}, kf1)

anim_mgr:setStaffMarker({3826, 3830}, 0, kf9, 1, kf10, 2, kf2, 3, kf3, 4, kf5, 5, kf6)
anim_mgr:setPatientMarker({3826, 3830}, kf1)

return object
