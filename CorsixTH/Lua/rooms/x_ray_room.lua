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
room.id = "x_ray"
room.level_config_id = 27
room.class = "XRayRoom"
room.name = _S.rooms_short.x_ray
room.tooltip = _S.tooltip.rooms.x_ray
room.build_cost = 8000
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { x_ray = 1, radiation_shield = 1 }
room.build_preview_animation = 5076
room.categories = {
  diagnosis = 7,
}
room.minimum_size = 6
room.wall_type = "yellow"
room.floor_tile = 19
room.required_staff = {
  Doctor = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd013.wav"
room.handyman_call_sound = "maint005.wav"

class "XRayRoom" (Room)

function XRayRoom:XRayRoom(...)
  self:Room(...)
end

function XRayRoom:commandEnteringStaff(staff)
  self.staff_member = staff
  staff:setNextAction(MeanderAction)
  return Room.commandEnteringStaff(self, staff)
end

function XRayRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local x_ray, pat_x, pat_y = self.world:findObjectNear(patient, "x_ray")
  local console, stf_x, stf_y = self.world:findObjectNear(staff, "radiation_shield")

  patient:walkTo(pat_x, pat_y)
  staff:walkTo(stf_x, stf_y)
  local length = math.random(2, 4) * (2 - staff.profile.skill)
  local sync = staff:queueAction(SyncAction)
  local staff_usage = sync:addDependantAction(UseObjectAction{
    object = console,
  })
  patient:queueAction(SyncAction{
    master = sync,
    dependant_actions = UseObjectAction{
      object = x_ray,
      loop_callback = --[[persistable:x_ray_loop_callback]] function(action)
        if length <= 0 then
          action.prolonged_usage = false
        end
        length = length - 1
      end,
      after_use = --[[persistable:x_ray_after_use]] function()
        staff_usage.prolonged_usage = false
        self:dealtWithPatient(patient)
      end,
    }
  })
  
  staff:queueAction(MeanderAction)
  patient:queueAction(LogicAction{self.makePatientRejoinQueue, self, patient})

  return Room.commandEnteringPatient(self, patient)
end

return room
