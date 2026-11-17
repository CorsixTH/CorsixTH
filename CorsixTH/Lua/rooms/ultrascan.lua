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

local Room = _G['Room'] ---@type Room

---@type StaffRequirements
local needed_staff = { Doctor = 1, }

---@type RoomProperties
local room_properties = {
  id = "ultrascan",
  vip_must_visit = false,
  level_config_id = 14,
  class = "UltrascanRoom",
  name = _S.rooms_short.ultrascan,
  long_name = _S.rooms_long.ultrascan,
  tooltip = _S.tooltip.rooms.ultrascan,
  objects_additional = { "extinguisher", "radiator", "plant", "bin" },
  objects_needed = { ultrascanner = 1 },
  build_preview_animation = 5068,
  categories = {
    diagnosis = 5,
  },
  minimum_size = 4,
  wall_type = "yellow",
  floor_tile = 19,
  required_staff = needed_staff,
  maximum_staff = needed_staff,
  call_sound = "reqd007.wav",
  handyman_call_sound = "maint016.wav",
}

class "UltrascanRoom" (Room)

---@class UltrascanRoom: Room
---@operator call: UltrascanRoom
local UltrascanRoom = _G["UltrascanRoom"] ---@type UltrascanRoom

function UltrascanRoom:UltrascanRoom(...)
  self:Room(...)
end

function UltrascanRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local ultrascan, pat_x, pat_y = self.world:findObjectNear(patient, "ultrascanner")
  local stf_x, stf_y = ultrascan:getSecondaryUsageTile()

  staff:setNextAction(WalkAction(stf_x, stf_y))
  staff:queueAction(IdleAction():setDirection(ultrascan.direction == "north" and "west" or "north"))

  patient:setNextAction(WalkAction(pat_x, pat_y))

  local after_use_scan = --[[persistable:ultrascan_after_use]] function()
    -- if no other actions for staff member meander in room
    if #staff.action_queue == 1 then
      staff:setNextAction(MeanderAction())
    else
      staff:finishAction(staff:getCurrentAction())
    end
    self:dealtWithPatient(patient)
  end

  patient:queueAction(MultiUseObjectAction(ultrascan, staff):setAfterUse(after_use_scan))
  return Room.commandEnteringPatient(self, patient)
end

return room_properties
