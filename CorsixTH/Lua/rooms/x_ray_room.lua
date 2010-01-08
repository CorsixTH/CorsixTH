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
room.name = _S(14, 14)
room.id = "x_ray"
room.class = "XRayRoom"
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

class "XRayRoom" (Room)

function XRayRoom:XRayRoom(...)
  self:Room(...)
end

function XRayRoom:commandEnteringStaff(staff)
  self.staff_member = staff
  staff:setNextAction{name = "meander"}
  return Room.commandEnteringStaff(self, staff)
end

function XRayRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local x_ray, pat_x, pat_y = self.world:findObjectNear(patient, "x_ray")
  local console, stf_x, stf_y = self.world:findObjectNear(staff, "radiation_shield")

  local function loop_callback()
    if staff.action_queue[1].name == "idle" and patient.action_queue[1].name == "idle" then
      patient:setNextAction{
        name = "use_object",
        object = x_ray,
        loop_callback = function(action)
          action.prolonged_usage = false
        end,
        after_use = function()
          staff:setNextAction{name = "meander"}
          self:dealtWithPatient(patient)
        end,
      }
      staff:setNextAction{
        name = "use_object",
        object = console,
      }
    end
  end

  patient:walkTo(pat_x, pat_y)
  patient:queueAction{
    name = "idle", 
    direction = x_ray.direction == "north" and "east" or "south",
    loop_callback = loop_callback,
  }
  staff:walkTo(stf_x, stf_y)
  staff:queueAction{
    name = "idle", 
    direction = console.direction == "north" and "east" or "south",
    loop_callback = loop_callback,
  }

  return Room.commandEnteringPatient(self, patient)
end

return room
