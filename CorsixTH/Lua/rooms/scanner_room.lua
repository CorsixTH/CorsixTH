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
room.id = "scanner"
room.level_config_id = 14
room.class = "ScannerRoom"
room.name = _S.rooms_short.scanner
room.tooltip = _S.tooltip.rooms.scanner
room.build_cost = 12000
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { scanner = 1, console = 1, screen = 1 }
room.build_preview_animation = 920
room.categories = {
  diagnosis = 4,
}
room.minimum_size = 5
room.wall_type = "yellow"
room.floor_tile = 19
room.required_staff = {
  Doctor = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd002.wav"
-- Handyman is called to "diagnosis machine", all other diagnosis rooms have
-- their own, more specific handyman call though
--room.handyman_call_sound = "maint011.wav"

class "ScannerRoom" (Room)

function ScannerRoom:ScannerRoom(...)
  self:Room(...)
end

function ScannerRoom:commandEnteringStaff(staff)
  self.staff_member = staff
  staff:setNextAction(MeanderAction)
  return Room.commandEnteringStaff(self, staff)
end

function ScannerRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local console, stf_x, stf_y = self.world:findObjectNear(staff, "console")
  local scanner, pat_x, pat_y = self.world:findObjectNear(patient, "scanner")
  local screen, sx, sy = self.world:findObjectNear(patient, "screen")
  local do_change = (patient.humanoid_class == "Standard Male Patient") or
    (patient.humanoid_class == "Standard Female Patient")
  
  staff:walkTo(stf_x, stf_y)
  local sync = staff:queueAction(SyncAction)
  local staff_usage = sync:addDependantAction(UseObjectAction{
    object = console,
  })

  local screen_action
  if do_change then
    screen_action = patient:setNextAction(UseScreenAction{
      object = screen,
    })
    patient:queueAction(WalkAction{x = pat_x, y = pat_y})
  else
    patient:walkTo(pat_x, pat_y)
  end
  sync = patient:queueAction(sync:duplicate())
  local length = math.random(10, 20) * (2 - staff.profile.skill)
  sync:addDependantAction(UseObjectAction{
    object = scanner,
    loop_callback = --[[persistable:scanner_loop_callback]] function(action)
      if length <= 0 then
        action.prolonged_usage = false
      end
      length = length - 1
    end,
    after_use = --[[persistable:scanner_after_use]] function()
      staff_usage.prolonged_usage = false
      self:dealtWithPatient(patient)
    end,
  })
  if screen_action then
    patient:queueAction(screen_action:makeUndoAction())
  end
  staff:queueAction(MeanderAction)
  patient:queueAction(LogicAction{self.makePatientRejoinQueue, self, patient})
  
  return Room.commandEnteringPatient(self, patient)
end

return room
