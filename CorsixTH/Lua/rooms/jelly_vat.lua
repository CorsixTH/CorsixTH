--[[ Copyright (c) 2010 Manuel "Roujin" Wolf

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

local Room = _G['Room'] ---@type Room

---@type StaffRequirements
local needed_staff = { Doctor = 1, }

---@type RoomProperties
local room_properties = {
  id = "jelly_vat",
  vip_must_visit = false,
  level_config_id = 24,
  class = "JellyVatRoom",
  name = _S.rooms_short.jelly_vat,
  long_name = _S.rooms_long.jelly_vat,
  tooltip = _S.tooltip.rooms.jelly_vat,
  objects_additional = { "extinguisher", "radiator", "plant", "bin" },
  objects_needed = { jelly_moulder = 1 },
  build_preview_animation = 928,
  categories = {
    clinics = 7,
  },
  minimum_size = 4,
  wall_type = "blue",
  floor_tile = 17,
  required_staff = needed_staff,
  maximum_staff = needed_staff,
  call_sound = "reqd020.wav",
  handyman_call_sound = "maint009.wav",
}

class "JellyVatRoom" (Room)

---@class JellyVatRoom: Room
---@operator call: JellyVatRoom
local JellyVatRoom = _G["JellyVatRoom"] ---@type JellyVatRoom

function JellyVatRoom:JellyVatRoom(...)
  self:Room(...)
end

function JellyVatRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local moulder, stf_x, stf_y = self.world:findObjectNear(patient, "jelly_moulder")
  local pat_x, pat_y = moulder:getSecondaryUsageTile()

  staff:setNextAction(WalkAction(stf_x, stf_y))

  local jellyvat_after_use = --[[persistable:jelly_vat_after_use]] function()
    staff:setNextAction(MeanderAction())
    self:dealtWithPatient(patient)
  end

  staff:queueAction(MultiUseObjectAction(moulder, patient):setInvisiblePhaseSpan({-3, 4})
      :setAfterUse(jellyvat_after_use))

  patient:setNextAction(WalkAction(pat_x, pat_y))
  patient:queueAction(IdleAction():setDirection(moulder.direction == "north" and "west" or "north"))

  return Room.commandEnteringPatient(self, patient)
end

return room_properties
