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

local Room = _G['Room'] ---@type Room

---@type StaffRequirements
local needed_staff = { Nurse = 1 }

---@type RoomProperties
local room_properties = {
  id = "fracture_clinic",
  vip_must_visit = false,
  level_config_id = 21,
  class = "FractureRoom",
  name = _S.rooms_short.fracture_clinic,
  long_name = _S.rooms_long.fracture_clinic,
  tooltip = _S.tooltip.rooms.fracture_clinic,
  objects_additional = { "extinguisher", "radiator", "plant", "bin" },
  objects_needed = { cast_remover = 1 },
  build_preview_animation = 5072,
  categories = {
    clinics = 3,
  },
  minimum_size = 4,
  wall_type = "blue",
  floor_tile = 17,
  required_staff = needed_staff,
  maximum_staff = needed_staff,
  call_sound = "reqd004.wav",
  handyman_call_sound = "maint014.wav",
}

class "FractureRoom" (Room)

---@class FractureRoom: Room
---@operator call: FractureRoom
local FractureRoom = _G["FractureRoom"] ---@type FractureRoom

function FractureRoom:FractureRoom(...)
  self:Room(...)
end

function FractureRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local cast, pat_x, pat_y = self.world:findObjectNear(patient, "cast_remover")
  local stf_x, stf_y = cast:getSecondaryUsageTile()

  staff:walkTo(stf_x, stf_y)
  staff:queueAction(IdleAction():setDirection(cast.direction == "north" and "west" or "north"))

  patient:walkTo(pat_x, pat_y)

  local after_fracture = --[[persistable:fracture_clinic_after_use]] function()
    patient:setLayer(2, 0) -- Remove casts
    patient:setLayer(3, 0)
    patient:setLayer(4, 0)
    -- if no other actions for staff member meander in room
    if #staff.action_queue == 1 then
      staff:setNextAction(MeanderAction())
    else
      staff:finishAction(staff:getCurrentAction())
    end
    self:dealtWithPatient(patient)
  end

  patient:queueAction(MultiUseObjectAction(cast, staff):setAfterUse(after_fracture))
  return Room.commandEnteringPatient(self, patient)
end

return room_properties
