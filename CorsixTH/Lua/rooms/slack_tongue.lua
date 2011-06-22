--[[ Copyright (c) 2009 Edvin "Lego3" Linge

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
room.id = "slack_tongue"
room.level_config_id = 20
room.class = "SlackTongueRoom"
room.name = _S.rooms_short.tongue_clinic
room.tooltip = _S.tooltip.rooms.tongue_clinic
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { slicer = 1 }
room.build_preview_animation = 932
room.categories = {
  clinics = 2,
}
room.minimum_size = 4
room.wall_type = "blue"
room.floor_tile = 17
room.required_staff = {
  Doctor = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd005.wav"
room.handyman_call_sound = "maint004.wav"

class "SlackTongueRoom" (Room)

function SlackTongueRoom:SlackTongueRoom(...)
  self:Room(...)
end

function SlackTongueRoom:commandEnteringStaff(staff)
  self.staff_member = staff
  staff:setNextAction{name = "meander"}
  return Room.commandEnteringStaff(self, staff)
end

function SlackTongueRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local slicer, pat_x, pat_y = self.world:findObjectNear(patient, "slicer")
  local orientation = slicer.object_type.orientations[slicer.direction]
  local stf_x, stf_y = slicer:getSecondaryUsageTile()

  staff:setNextAction{name = "walk", x = stf_x, y = stf_y}
  staff:queueAction{name = "idle", direction = slicer.direction == "north" and "east" or "south"}
  patient:setNextAction{name = "walk", x = pat_x, y = pat_y}
  patient:queueAction{
    name = "multi_use_object",
    object = slicer,
    use_with = staff,
    after_use = --[[persistable:slack_tongue_after_use]] function()
      if patient.humanoid_class == "Slack Male Patient" then
        patient:setType "Standard Male Patient" -- Change to normal head
      else
        patient:setLayer(0, patient.layers[0] - 8) -- Change to normal head
      end
      staff:setNextAction{name = "meander"}
      self:dealtWithPatient(patient)
    end,
  }

  return Room.commandEnteringPatient(self, patient)
end

return room
