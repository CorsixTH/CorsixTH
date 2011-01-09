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

local room = {}
room.id = "jelly_vat"
room.level_config_id = 24
room.class = "JellyVatRoom"
room.name = _S.rooms_short.jelly_vat
room.tooltip = _S.tooltip.rooms.jelly_vat
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { jelly_moulder = 1 }
room.build_preview_animation = 928
room.categories = {
  clinics = 7,
}
room.minimum_size = 4
room.wall_type = "blue"
room.floor_tile = 17
room.required_staff = {
  Doctor = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd020.wav"
room.handyman_call_sound = "maint009.wav"

class "JellyVatRoom" (Room)

function JellyVatRoom:JellyVatRoom(...)
  self:Room(...)
end

function JellyVatRoom:commandEnteringStaff(staff)
  self.staff_member = staff
  staff:setNextAction{name = "meander"}
  return Room.commandEnteringStaff(self, staff)
end

function JellyVatRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local moulder, stf_x, stf_y = self.world:findObjectNear(patient, "jelly_moulder")
  local orientation = moulder.object_type.orientations[moulder.direction]
  local pat_x, pat_y = moulder:getSecondaryUsageTile()
  
  staff:setNextAction{name = "walk", x = stf_x, y = stf_y}
  staff:queueAction{
    name = "multi_use_object",
    object = moulder,
    use_with = patient,
    invisible_phase_span = {-3, 4},
    after_use = --[[persistable:jelly_vat_after_use]] function()
      staff:setNextAction{name = "meander"}
      self:dealtWithPatient(patient)
    end,
  }
  patient:setNextAction{name = "walk", x = pat_x, y = pat_y}
  patient:queueAction{name = "idle", direction = moulder.direction == "north" and "west" or "north"}
  
  return Room.commandEnteringPatient(self, patient)
end

return room
