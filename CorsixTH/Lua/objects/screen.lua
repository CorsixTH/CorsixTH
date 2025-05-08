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
object.id = "screen"
object.thob = 16
object.name = _S.object.screen
object.tooltip = _S.tooltip.objects.screen
object.ticks = false
object.build_preview_animation = 926
object.show_in_town_map = true
-- More than one idle animation exists, but we can only set one to the object
object.idle_animations = {
  north = 1022,
}
object.orientations = {
  north = {
    footprint = { {-1, -1, only_passable = true}, {-1, 0}, {0, -1}, {0, 0} },
    render_attach_position = {-1, 0},
    use_position = "passable",
  },
}

-- Animation numbers below correspond to non-operating theatre uses only
-- See surgeon_screen.lua for that room
object.usage_animations = {
  north = {
    in_use = {
      ["Elvis Patient"] = 946, -- specifically, transformation
      ["Standard Male Patient"] = {
        undress = 1048,
        dress   = 1052,
      },
      ["Standard Female Patient"] = {
        undress = 2848,
        dress   = 2844,
      },
    },
  },
}


local anim_mgr = TheApp.animation_manager
local kf1, kf2, kf3 = {-1, -1}, {-0.9, -0.8}, {-0.6, -0.6}
local anims = { object.idle_animations.north, 1204 } -- idle anims
anim_mgr:setPatientMarker(anims, kf1)
anim_mgr:setStaffMarker(anims, kf1)

anims = object.usage_animations.north.in_use
anim_mgr:setPatientMarker(anims["Elvis Patient"],
    0, kf1, 6, kf1, 7, kf2, 11, kf2, 12, kf1, 24, kf1, 28, kf3, 32, kf3, 36, kf1, 43, kf1)
anim_mgr:setPatientMarker(anims["Standard Male Patient"].undress,
    0, kf1, 7, kf1, 8, kf2, 12, kf2, 13, kf1)
anim_mgr:setPatientMarker(anims["Standard Male Patient"].dress,
    0, kf1, 10, kf1, 11, kf2, 21, kf2, 22, kf1)
anim_mgr:setPatientMarker(anims["Standard Female Patient"].undress,
    0, kf1, 2, kf2, 3, kf2, 9, kf2, 11, kf1, 17, kf1, 18, kf2, 25, kf2, 26, kf1)
anim_mgr:setPatientMarker(anims["Standard Female Patient"].dress,
    0, kf1, 2, kf1, 3, kf2, 12, kf2, 13, kf1)

return object
