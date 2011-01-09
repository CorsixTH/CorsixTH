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
room.id = "decontamination"
room.level_config_id = 30
room.class = "DecontaminationRoom"
room.name = _S.rooms_short.decontamination
room.tooltip = _S.tooltip.rooms.decontamination
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { shower = 1, console = 1 }
room.build_preview_animation = 5100
room.categories = {
  clinics = 8,
}
room.minimum_size = 5
room.wall_type = "blue"
room.floor_tile = 19
room.required_staff = {
  Doctor = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd024.wav"
room.handyman_call_sound = "maint012.wav"

class "DecontaminationRoom" (Room)

function DecontaminationRoom:DecontaminationRoom(...)
  self:Room(...)
end

function DecontaminationRoom:commandEnteringStaff(staff)
  self.staff_member = staff
  staff:setNextAction{name = "meander"}
  return Room.commandEnteringStaff(self, staff)
end

function DecontaminationRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local shower, pat_x, pat_y = self.world:findObjectNear(patient, "shower")
  local console, stf_x, stf_y = self.world:findObjectNear(staff, "console")
  
  local --[[persistable:decontamination_shared_loop_callback]] function loop_callback()
    if staff.action_queue[1].shower_ready and patient.action_queue[1].shower_ready then
      staff:finishAction()
      patient:finishAction()
    end
  end
  
  staff:walkTo(stf_x, stf_y)
  staff:queueAction{
    name = "idle",
    direction = console.direction == "north" and "west" or "north",
    loop_callback = loop_callback,
    shower_ready = true,
  }
  staff:queueAction{
    name = "use_object",
    object = console,
  }
  
  patient:walkTo(pat_x, pat_y)
  patient:queueAction{
    name = "idle",
    direction = shower.direction == "north" and "north" or "west",
    loop_callback = loop_callback,
    shower_ready = true,
  }
  
  local prolonged = true
  local length = math.random() * 3 - staff.profile.skill
  if length < 1 then
    prolonged = false -- Really short usage
  else
    length = length - 1
  end
  patient:queueAction{
    name = "use_object",
    object = shower,
    prolonged_usage = prolonged,
    loop_callback = --[[persistable:shower_loop_callback]] function(action)
      length = length - 1
      if length <= 0 then
        action.prolonged_usage = false
      end
    end,
    after_use = --[[persistable:shower_after_use]] function()
      if not self.staff_member then
        return
      end
      self.staff_member:setNextAction{name = "meander"}
      if not patient.going_home then
        self:dealtWithPatient(patient)
      end
    end,
  }
  
  return Room.commandEnteringPatient(self, patient)
end

function DecontaminationRoom:onHumanoidLeave(humanoid)
  if self.staff_member == humanoid then
    self.staff_member = nil
  end
  Room.onHumanoidLeave(self, humanoid)
end

return room
