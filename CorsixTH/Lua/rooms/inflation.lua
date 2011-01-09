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

local room = {}
room.id = "inflation"
room.level_config_id = 17
room.class = "InflationRoom"
room.name = _S.rooms_short.inflation
room.tooltip = _S.tooltip.rooms.inflation
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { inflator = 1 }
room.build_preview_animation = 908
room.categories = {
  clinics = 1,
}
room.minimum_size = 4
room.wall_type = "blue"
room.floor_tile = 17
room.required_staff = {
  Doctor = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd014.wav"
room.handyman_call_sound = "maint013.wav"

class "InflationRoom" (Room)

function InflationRoom:InflationRoom(...)
  self:Room(...)
end

function InflationRoom:commandEnteringStaff(staff)
  self.staff_member = staff
  staff:setNextAction{name = "meander"}
  return Room.commandEnteringStaff(self, staff)
end

function InflationRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local inflator, pat_x, pat_y = self.world:findObjectNear(patient, "inflator")
  local orientation = inflator.object_type.orientations[inflator.direction]
  local stf_x, stf_y = inflator:getSecondaryUsageTile()
  
  staff:setNextAction{name = "walk", x = stf_x, y = stf_y}
  staff:queueAction{name = "idle", direction = inflator.direction == "north" and "east" or "south"}
  patient:setNextAction{name = "walk", x = pat_x, y = pat_y}
  patient:queueAction{
    name = "multi_use_object",
    object = inflator,
    use_with = staff,
    after_use = --[[persistable:inflation_after_use]] function()
      patient:setLayer(0, patient.layers[0] - 10) -- Change to normal head
      staff:setNextAction{name = "meander"}
      self:dealtWithPatient(patient)
    end,
  }
  
  return Room.commandEnteringPatient(self, patient)
end

return room
