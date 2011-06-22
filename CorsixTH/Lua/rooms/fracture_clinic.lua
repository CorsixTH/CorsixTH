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
room.id = "fracture_clinic"
room.level_config_id = 21
room.class = "FractureRoom"
room.name = _S.rooms_short.fracture_clinic
room.tooltip = _S.tooltip.rooms.fracture_clinic
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { cast_remover = 1 }
room.build_preview_animation = 5072
room.categories = {
  clinics = 3,
}
room.minimum_size = 4
room.wall_type = "blue"
room.floor_tile = 17
room.required_staff = {
  Nurse = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd004.wav"
room.handyman_call_sound = "maint014.wav"

class "FractureRoom" (Room)

function FractureRoom:FractureRoom(...)
  self:Room(...)
end

function FractureRoom:commandEnteringStaff(staff)
  self.staff_member = staff
  staff:setNextAction{name = "meander"}
  return Room.commandEnteringStaff(self, staff)
end

function FractureRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local cast, pat_x, pat_y = self.world:findObjectNear(patient, "cast_remover")
  local orientation = cast.object_type.orientations[cast.direction]
  local stf_x, stf_y = cast:getSecondaryUsageTile()
  
  staff:walkTo(stf_x, stf_y)
  staff:queueAction{name = "idle", direction = cast.direction == "north" and "west" or "north"}
  patient:walkTo(pat_x, pat_y)
  patient:queueAction{
    name = "multi_use_object",
    object = cast,
    use_with = staff,
    after_use = --[[persistable:fracture_clinic_after_use]] function()
      patient:setLayer(2, 0) -- Remove casts
      patient:setLayer(3, 0)
      patient:setLayer(4, 0)
      staff:setNextAction{name = "meander"}
      self:dealtWithPatient(patient)
    end,
  }
  
  return Room.commandEnteringPatient(self, patient)
end

return room
