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
room.level_config_id = 13
room.class = "ScannerRoom"
room.name = _S.rooms_short.scanner
room.tooltip = _S.tooltip.rooms.scanner
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
  staff:setNextAction{name = "meander"}
  return Room.commandEnteringStaff(self, staff)
end

function ScannerRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local console, stf_x, stf_y = self.world:findObjectNear(staff, "console")
  local scanner, pat_x, pat_y = self.world:findObjectNear(patient, "scanner")
  local screen, sx, sy = self.world:findObjectNear(patient, "screen")
  local do_change = (patient.humanoid_class == "Standard Male Patient") or
    (patient.humanoid_class == "Standard Female Patient")
  
  local --[[persistable:scanner_shared_loop_callback]] function loop_callback()
    if staff.action_queue[1].scanner_ready and patient.action_queue[1].scanner_ready then
      staff:finishAction()
      patient:finishAction()
    end
  end
  
  staff:walkTo(stf_x, stf_y)
  staff:queueAction{
    name = "idle",
    direction = console.direction == "north" and "west" or "north",
    loop_callback = loop_callback,
    scanner_ready = true,
  }
  staff:queueAction{
    name = "use_object",
    object = console,
  }
  
  if do_change then
    patient:walkTo(sx, sy)
    patient:queueAction{
      name = "use_screen",
      object = screen,
    }
    patient:queueAction{
      name = "walk",
      x = pat_x,
      y = pat_y,
    }
  else
    patient:walkTo(pat_x, pat_y)
  end
  patient:queueAction{
    name = "idle",
    direction = scanner.direction == "north" and "east" or "south",
    loop_callback = loop_callback,
    scanner_ready = true,
  }
  local length = math.random(10, 20) * (2 - staff.profile.skill)
  patient:queueAction{
    name = "use_object",
    object = scanner,
    loop_callback = --[[persistable:scanner_loop_callback]] function(action)
      if length <= 0 then
        action.prolonged_usage = false
      end
      length = length - 1
    end,
    after_use = --[[persistable:scanner_after_use]] function()
      if not self.staff_member or patient.going_home then
        -- If we aborted somehow, don't do anything here.
        -- The patient already has orders to change back if necessary and leave.
        return
      end
      self.staff_member:setNextAction{name = "meander"}
      self:dealtWithPatient(patient)
    end,
  }
  return Room.commandEnteringPatient(self, patient)
end

function ScannerRoom:onHumanoidLeave(humanoid)
  if self.staff_member == humanoid then
    self.staff_member = nil
  end
  Room.onHumanoidLeave(self, humanoid)
end

function ScannerRoom:makePatientLeave(patient)
  local screen, sx, sy = self.world:findObjectNear(patient, "screen")
  
  if (patient.humanoid_class == "Stripped Male Patient" or
    patient.humanoid_class == "Stripped Male Patient 2" or
    patient.humanoid_class == "Stripped Female Patient" or
    patient.humanoid_class == "Stripped Male Patient 3" or
    patient.humanoid_class == "Stripped Female Patient 2" or
    patient.humanoid_class == "Stripped Female Patient 3") and
    not patient.action_queue[1].is_leaving then
    
    patient:setNextAction{
      name = "walk",
      x = sx,
      y = sy,
      must_happen = true,
      no_truncate = true,
      is_leaving = true,
    }
    patient:queueAction{
      name = "use_screen",
      object = screen,
      must_happen = true,
      is_leaving = true,
    }
    local leave = self:createLeaveAction()
    leave.must_happen = true
    patient:queueAction(leave)
  else
    local leave = self:createLeaveAction()
    leave.must_happen = true
    patient:setNextAction(leave)
  end
end

function ScannerRoom:dealtWithPatient(patient)
  local screen, sx, sy = self.world:findObjectNear(patient, "screen")
  if patient.humanoid_class == "Stripped Male Patient" or
    patient.humanoid_class == "Stripped Female Patient" or
    patient.humanoid_class == "Stripped Male Patient 2" or
    patient.humanoid_class == "Stripped Female Patient 2" or
    patient.humanoid_class == "Stripped Male Patient 3" or
    patient.humanoid_class == "Stripped Female Patient 3" then
    
    patient:setNextAction{
      name = "walk",
      x = sx,
      y = sy,
      must_happen = true,
      no_truncate = true,
      is_leaving = true,
    }
    patient:queueAction{
      name = "use_screen",
      object = screen,
      must_happen = true,
      is_leaving = true,
      after_use = --[[persistable:scanner_exit]] function() Room.dealtWithPatient(self, patient) end,
    }
    patient:queueAction(self:createLeaveAction())
  else
    Room.dealtWithPatient(self, patient)
  end
end

return room
