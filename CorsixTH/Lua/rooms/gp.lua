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
room.id = "gp"
room.class = "GPRoom"
room.build_cost = 2500
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { desk = 1, cabinet = 1, chair = 1 }
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
room.call_sound = "reqd008.wav"

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

function GPRoom:commandEnteringStaff(humanoid)
  self.staff_member = humanoid
  self:doStaffUseCycle(humanoid)
  return Room.commandEnteringStaff(self, humanoid)
end

function GPRoom:commandEnteringPatient(humanoid)
  local obj, ox, oy = self.world:findObjectNear(humanoid, "chair")
  humanoid:walkTo(ox, oy)
  humanoid:queueAction{name = "use_object", object = obj}
  return Room.commandEnteringPatient(self, humanoid)
end

function GPRoom:dealtWithPatient(patient)
  patient = patient or self:getPatient()
  patient:setNextAction(self:createLeaveAction())
  if patient.disease and not patient.diagnosed then
    self.hospital:receiveMoneyForTreatment(patient)
    
    -- Base: 0 .. 1 depending on difficulty of disease
    local diagnosis_base = 1 - patient.disease.diagnosis_difficulty
    if diagnosis_base < 0 then
      diagnosis_base = 0
    end
    -- Bonus: 0.3 .. 0.5 (random) for perfectly skilled doctor. Less for less skilled doctors.
    local diagnosis_bonus = (0.3 + 0.2 * math.random()) * self.staff_member.profile.skill
    
    patient.diagnosis_progress = patient.diagnosis_progress + diagnosis_base + diagnosis_bonus
    if patient.diagnosis_progress >= 1.0 or #patient.available_diagnosis_rooms == 0 then
      patient.diagnosed = true
      patient.diagnosis_progress = 1.0
      patient:queueAction{name = "seek_room", room_type = patient.disease.treatment_rooms[1]}
    else
      local next_room = math.random(1, #patient.available_diagnosis_rooms)
      patient:queueAction{name = "seek_room", room_type = patient.available_diagnosis_rooms[next_room]}
      table.remove(patient.available_diagnosis_rooms, next_room)
    end
  else
    patient:queueAction{name = "meander", count = 2}
    patient:queueAction{name = "idle"}
  end
end

function GPRoom:onHumanoidLeave(humanoid)
  if self.staff_member == humanoid then
    self.staff_member = nil
  end
  Room.onHumanoidLeave(self, humanoid)
end

return room
