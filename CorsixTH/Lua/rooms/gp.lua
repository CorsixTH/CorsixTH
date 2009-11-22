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
room.name = _S(14, 5)
room.class = "GPRoom"
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { "desk", "cabinet", "chair" }
room.build_cost = 2500
room.build_preview_animation = 900
room.categories = {
  diagnosis = 1,
}
room.minimum_size = 4
room.wall_type = "white"
room.floor_tile = 18
room.required_staff = {
  Doctor = 1,
}
room.maximum_staff = room.required_staff

class "GPRoom" (Room)

function GPRoom:GPRoom(...)
  self:Room(...)
end

function GPRoom:doStaffUseCycle(humanoid)
  local obj, ox, oy = self.world:findObjectNear(humanoid, "cabinet")
  humanoid:walkTo(ox, oy)
  humanoid:queueAction{name = "use_object", object = obj}
  obj, ox, oy = self.world:findObjectNear(humanoid, "desk")
  humanoid:queueAction{name = "walk", x = ox, y = oy}
  local desk_use_time = math.random(8, 20)
  humanoid:queueAction{name = "use_object",
    object = obj,
    loop_callback = function()
      desk_use_time = desk_use_time - 1
      if desk_use_time == 0 then
        self:doStaffUseCycle(humanoid)
        if math.random() <= (0.5 + 0.5 * humanoid.profile.skill) then
          local patient = self:getPatient()
          if patient and patient.user_of then
            self:dealtWithPatient(patient)
          end
        end
      end
    end,
  }
end

GPRoom.commandEnteringStaff = GPRoom.doStaffUseCycle

function GPRoom:commandEnteringPatient(humanoid)
  local obj, ox, oy = self.world:findObjectNear(humanoid, "chair")
  humanoid:walkTo(ox, oy)
  humanoid:queueAction{name = "use_object", object = obj}
end

return room
