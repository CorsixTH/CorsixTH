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
room.id = "pharmacy"
room.level_config_id = 11
room.class = "PharmacyRoom"
room.name = _S.rooms_short.pharmacy
room.tooltip = _S.tooltip.rooms.pharmacy
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { pharmacy_cabinet = 1 }
room.build_preview_animation = 5088
room.categories = {
  treatment = 4,
}
room.minimum_size = 4
room.wall_type = "white"
room.floor_tile = 19
room.required_staff = {
  Nurse = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd012.wav"

class "PharmacyRoom" (Room)

function PharmacyRoom:PharmacyRoom(...)
  self:Room(...)
end

function PharmacyRoom:roomFinished()
  if not self.hospital:hasStaffOfCategory("Nurse") then
    self.world.ui.adviser:say(_S.adviser.room_requirements.pharmacy_need_nurse)
  end
  return Room.roomFinished(self)
end

function PharmacyRoom:commandEnteringStaff(staff)
  self.staff_member = staff
  staff:setNextAction{name = "meander"}
  return Room.commandEnteringStaff(self, staff)
end

function PharmacyRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local cabinet, stf_x, stf_y = self.world:findObjectNear(patient, "pharmacy_cabinet")
  local pat_x, pat_y
  local orientation = cabinet.object_type.orientations[cabinet.direction]
  pat_x = stf_x - orientation.use_position[1] + orientation.use_position_secondary[1]
  pat_y = stf_y - orientation.use_position[2] + orientation.use_position_secondary[2]
  
  local layer3
  local patient_class = patient.humanoid_class
  if patient_class == "Standard Female Patient" or patient_class == "Transparent Female Patient" then
    -- Female patients cannot use flask colour 2, as in their idle animation,
    -- layer 3 item 2 is a bandage.
    layer3 = math.random(0, 1) * 4
  else
    layer3 = math.random(0, 2) * 2
  end
  
  patient:setNextAction{name = "walk", x = pat_x, y = pat_y}
  patient:queueAction{name = "idle", direction = cabinet.direction == "north" and "east" or "south"}
  staff:setNextAction{name = "walk", x = stf_x, y = stf_y}
  staff:queueAction{
    name = "multi_use_object",
    object = cabinet,
    use_with = patient,
    layer3 = layer3,
    after_use = --[[persistable:pharmacy_after_use]] function()
      staff:setNextAction{name = "meander"}
      if patient_class == "Invisible Patient" or patient_class == "Transparent Male Patient" then
        patient:setType "Standard Male Patient"
      elseif patient_class == "Transparent Female Patient" then
        patient:setType "Standard Female Patient"
      end
      self:dealtWithPatient(patient)
    end,
  }
  
  return Room.commandEnteringPatient(self, patient)
end

return room
