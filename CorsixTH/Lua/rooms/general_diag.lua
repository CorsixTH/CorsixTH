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
room.id = "general_diag"
room.class = "GeneralDiagRoom"
room.name = _S.rooms_short.general_diag
room.tooltip = _S.tooltip.rooms.general_diag
room.build_cost = 1000
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { screen = 1, crash_trolley = 1 }
room.build_preview_animation = 916
room.categories = {
  diagnosis = 2,
}
room.minimum_size = 5
room.wall_type = "green"
room.floor_tile = 21
room.required_staff = {
  Doctor = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd021.wav"

class "GeneralDiagRoom" (Room)

function GeneralDiagRoom:GeneralDiagRoom(...)
  self:Room(...)
end

function GeneralDiagRoom:commandEnteringStaff(staff)
  self.staff_member = staff
  staff:setNextAction(MeanderAction)
  return Room.commandEnteringStaff(self, staff)
end

function GeneralDiagRoom:commandEnteringPatient(patient)
  local screen = self.world:findObjectNear(patient, "screen")
  local screen_action = patient:setNextAction(UseScreenAction{
    object = screen,
  })
  local staff = self.staff_member
  local trolley, cx, cy = self.world:findObjectNear(patient, "crash_trolley")
  staff:walkTo(trolley:getSecondaryUsageTile())
  patient:queueAction(WalkAction{x = cx, y = cy})
  staff:queueAction(patient:queueAction(MultiUseObjectAction{
    object = trolley,
    after_use = --[[persistable:general_diag_screen_after_use]] function()
      self:dealtWithPatient(patient)
    end,
  }):createSecondaryUserAction())
  patient:queueAction(screen_action:makeUndoAction())
  staff:queueAction(MeanderAction)
  patient:queueAction(LogicAction{self.makePatientRejoinQueue, self, patient})

  return Room.commandEnteringPatient(self, patient)
end

return room
