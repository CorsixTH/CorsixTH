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

local room = {}
room.id = "ultrascan"
room.level_config_id = 14
room.class = "UltrascanRoom"
room.name = _S.rooms_short.ultrascan
room.tooltip = _S.tooltip.rooms.ultrascan
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { ultrascanner = 1 }
room.build_preview_animation = 5068
room.categories = {
  diagnosis = 5,
}
room.minimum_size = 4
room.wall_type = "yellow"
room.floor_tile = 19
room.required_staff = {
  Doctor = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd007.wav"
room.handyman_call_sound = "maint016.wav"

class "UltrascanRoom" (Room)

function UltrascanRoom:UltrascanRoom(...)
  self:Room(...)
end

function UltrascanRoom:commandEnteringStaff(staff)
  self.staff_member = staff
  staff:setNextAction{name = "meander"}
  return Room.commandEnteringStaff(self, staff)
end

function UltrascanRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local ultrascan, pat_x, pat_y = self.world:findObjectNear(patient, "ultrascanner")
  local orientation = ultrascan.object_type.orientations[ultrascan.direction]
  local stf_x, stf_y = ultrascan:getSecondaryUsageTile()
  
  staff:setNextAction{name = "walk", x = stf_x, y = stf_y}
  staff:queueAction{name = "idle", direction = ultrascan.direction == "north" and "west" or "north"}
  patient:setNextAction{name = "walk", x = pat_x, y = pat_y}
  patient:queueAction{
    name = "multi_use_object",
    object = ultrascan,
    use_with = staff,
    after_use = --[[persistable:ultrascan_after_use]] function()
      staff:setNextAction{name = "meander"}
      self:dealtWithPatient(patient)
    end,
  }
  
  return Room.commandEnteringPatient(self, patient)
end

return room
