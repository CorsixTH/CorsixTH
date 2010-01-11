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
room.name = _S(14, 7)
room.id = "ward"
room.class = "WardRoom"
room.build_cost = 2000
room.objects_additional = { "extinguisher", "radiator", "plant", "bin", "bed" }
room.objects_needed = { desk = 1, bed = 1 }
room.build_preview_animation = 910
room.categories = {
  treatment = 2,
  diagnosis = 9,
}
room.minimum_size = 6
room.wall_type = "white"
room.floor_tile = 21
room.required_staff = {
  Nurse = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd009.wav"

class "WardRoom" (Room)

function WardRoom:WardRoom(...)
  self:Room(...)
end

function WardRoom:doStaffUseCycle(humanoid)
  local meander_time = math.random(4, 10)
  local desk_use_time = math.random(8, 16)
  
  humanoid:setNextAction{
    name = "meander",
    count = meander_time,
  }
  local obj, ox, oy = self.world:findObjectNear(humanoid, "desk")
  humanoid:queueAction{name = "walk", x = ox, y = oy}
  humanoid:queueAction{name = "use_object",
    object = obj,
    loop_callback = --[[persistable:ward_desk_loop_callback]] function()
      desk_use_time = desk_use_time - 1
      if desk_use_time == 0 then
        self:doStaffUseCycle(humanoid)
      end
    end,
  }
end

WardRoom.commandEnteringStaff = WardRoom.doStaffUseCycle

return room
