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
object.id = "surgeon_screen"
object.class = "SurgeonScreen"
object.thob = 35
object.name = _S.object.surgeon_screen
object.tooltip = _S.tooltip.objects.surgeon_screen
object.ticks = false
object.build_preview_animation = 926
object.show_in_town_map = true
-- More than one idle animation exists, but we can only set one to the object
object.idle_animations = {
  north = 2772,
}
object.orientations = {
  north = {
    footprint = { {-1, -1, only_passable = true}, {-1, 0}, {0, -1}, {0, 0} },
    render_attach_position = {-1, 0},
    use_position = "passable",
  },
}

-- Animation numbers below correspond to operating theatre uses only.
-- See screen.lua for everything else.
object.usage_animations = {
  north = {
    --[[ unused
    begin_use = {
      scrubs_on  = 2786,
      scrubs_off = 2788
    },
    ]]--
    in_use = {
      Surgeon = {
        scrubs_on_t1 =  2780,
        scrubs_on_t2 =  2782,
        scrubs_on_t3 =  2784,
        scrubs_off_t1 = 2790,
        scrubs_off_t2 = 2792,
        scrubs_off_t3 = 2794,
        scrubs_off_t4 = 2796,
      },
      ["Standard Male Patient"] = {
        gown_on  = 4760,
        gown_off = 4768,
      },
      ["Standard Female Patient"] = {
        gown_on  = 4762,
        gown_off = 4770,
      },
    },
  },
}

local anim_mgr = TheApp.animation_manager
local kf1, kf2, kf3 = {-1.23, -1.14}, {-0.9, -0.8}, {-0.7, -0.6}
local anims = { object.idle_animations.north, 2774, 2776 } -- idle anims
anim_mgr:setPatientMarker(anims, kf1)
anim_mgr:setStaffMarker(anims, kf1)

anims = object.usage_animations.north.in_use
anim_mgr:setStaffMarker(anims.Surgeon.scrubs_on_t1,
    0, kf1, 2, kf1, 7, kf3, 22, kf3, 25, kf1, 26, kf1)
anim_mgr:setStaffMarker(anims.Surgeon.scrubs_on_t2,
    0, kf1, 3, kf1, 6, kf2, 8, kf2, 9, kf3, 14, kf3, 18, kf1, 22, kf1, 27, kf3, 34, kf3, 37, kf1)
anim_mgr:setStaffMarker(anims.Surgeon.scrubs_on_t3,
    0, kf1, 3, kf1, 6, kf3, 14, kf3, 18, kf1, 23, kf1, 28, kf3, 33, kf3, 36, kf1)
anim_mgr:setStaffMarker(anims.Surgeon.scrubs_off_t1, 0, kf1, 4, kf3, 12, kf3, 17,
    kf1, 24, kf1, 28, kf3, 35, kf3, 39, kf1)
anim_mgr:setStaffMarker(anims.Surgeon.scrubs_off_t2, 0, kf1, 4, kf1, 8, kf3, 16,
    kf3, 21, kf1, 31, kf1, 34, kf3, 42, kf3, 46, kf1)
anim_mgr:setStaffMarker(anims.Surgeon.scrubs_off_t3, 0, kf1, 5, kf3, 15, kf3, 21, kf1)
anim_mgr:setStaffMarker(anims.Surgeon.scrubs_off_t4, 0, kf1, 4, kf3, 17, kf3, 21, kf1)
kf1, kf2 = {-1, -1}, {-0.6, -0.6}
anim_mgr:setPatientMarker(anims["Standard Male Patient"].gown_on, 0, kf1, 4, kf2, 16,
    kf2, 19, kf1)
anim_mgr:setPatientMarker(anims["Standard Male Patient"].gown_off, 0, kf1, 2, kf1, 5,
    kf2, 11, kf2, 15, kf1)
anim_mgr:setPatientMarker(anims["Standard Female Patient"].gown_on, 0, kf1, 5, kf2, 16,
    kf2, 19, kf1)
anim_mgr:setPatientMarker(anims["Standard Female Patient"].gown_off, 0, kf1, 3, kf1, 10,
    kf2, 15, kf1)

class "SurgeonScreen" (Object)

---@type SurgeonScreen
local SurgeonScreen = _G["SurgeonScreen"]

function SurgeonScreen:SurgeonScreen(...)
  self:Object(...)
  self.num_green_outfits = 2
  self.num_white_outfits = 0
end

return object
