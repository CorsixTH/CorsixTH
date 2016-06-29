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
room.level_config_id = 16
room.class = "XRayRoom"
room.name = _S.rooms_short.x_ray
room.long_name = _S.rooms_long.x_ray
room.tooltip = _S.tooltip.rooms.x_ray
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

---@type XRayRoom
local XRayRoom = _G["XRayRoom"]

function XRayRoom:XRayRoom(...)
  self:Room(...)
end

function XRayRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local x_ray, pat_x, pat_y = self.world:findObjectNear(patient, "x_ray")
  local console, stf_x, stf_y = self.world:findObjectNear(staff, "radiation_shield")

  local --[[persistable:x_ray_shared_loop_callback]] function loop_callback()
    if staff.action_queue[1].name == "idle" and patient.action_queue[1].name == "idle" then

      local length = math.random(2, 4) * (2 - staff.profile.skill)
      local loop_callback_xray = --[[persistable:x_ray_loop_callback]] function(action)
        if length <= 0 then
          action.prolonged_usage = false
        end
        length = length - 1
      end

      local after_use_xray = --[[persistable:x_ray_after_use]] function()
        staff:setNextAction(MeanderAction())
        self:dealtWithPatient(patient)
      end

      patient:setNextAction(UseObjectAction(x_ray):setLoopCallback(loop_callback_xray)
          :setAfterUse(after_use_xray))
      staff:setNextAction(UseObjectAction(console))
    end
  end

  patient:walkTo(pat_x, pat_y)
  patient:queueAction(IdleAction():setDirection(x_ray.direction == "north" and "east" or "south")
      :setLoopCallback(loop_callback))

  staff:walkTo(stf_x, stf_y)
  staff:queueAction(IdleAction():setDirection(console.direction == "north" and "east" or "south")
      :setLoopCallback(loop_callback))

  return Room.commandEnteringPatient(self, patient)
end

return room
