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
room.id = "gp"
room.class = "GPRoom"
room.name = _S.rooms_short.gps_office
room.tooltip = _S.tooltip.rooms.gps_office
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
  local desk_use_time = math.random(7, 14)
  humanoid:queueAction{name = "use_object",
    object = obj,
    loop_callback = --[[persistable:gp_loop_callback]] function()
      desk_use_time = desk_use_time - 1
      if desk_use_time == 0 then
        self:doStaffUseCycle(humanoid)
        local patient = self:getPatient()
        if patient then
          if math.random() <= (0.6 + 0.4 * humanoid.profile.skill) or self.max_times <= 0 then
            if patient.user_of then
              self:dealtWithPatient(patient)
            end
          else
            self.max_times = self.max_times - 1
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
  self.max_times = 3
  return Room.commandEnteringPatient(self, humanoid)
end

function GPRoom:dealtWithPatient(patient)
  patient = patient or self:getPatient()
  patient:setNextAction(self:createLeaveAction())
  patient:addToTreatmentHistory(self.room_info)

  if patient.disease and not patient.diagnosed then
    self.hospital:receiveMoneyForTreatment(patient)
    
    -- Base: 0 .. 1 depending on difficulty of disease
    local diagnosis_base = 1 - patient.disease.diagnosis_difficulty
    if diagnosis_base < 0 then
      diagnosis_base = 0
    end
    -- Bonus: 0.3 .. 0.5 (random) for perfectly skilled doctor. Less for less skilled doctors.
    local diagnosis_bonus = (0.3 + 0.2 * math.random()) * self.staff_member.profile.skill
    
    patient:modifyDiagnosisProgress(diagnosis_base + diagnosis_bonus)
    if patient.diagnosis_progress >= self.hospital.policies["stop_procedure"]
    or #patient.available_diagnosis_rooms == 0 then
      patient:setDiagnosed(true)
      patient:queueAction{name = "seek_room", room_type = patient.disease.treatment_rooms[1]}

      self.staff_member:setMood("idea3", "activate") -- Show the light bulb over the doctor
      -- Check if this disease has just been discovered
      if not self.hospital.disease_casebook[patient.disease.id].discovered then
        -- Generate a message about the discovery
        local message = {
          {text = _S.fax.disease_discovered.discovered_name:format(patient.disease.name)},
          {text = patient.disease.cause, offset = 8},
          {text = patient.disease.symptoms},
          {text = patient.disease.cure}
        }
        self.world.ui.bottom_panel:queueMessage("disease", message)
        self.hospital.disease_casebook[patient.disease.id].discovered = true
        self.hospital.discovered_diseases[#self.hospital.discovered_diseases + 1] = patient.disease.id
        -- If the drug casebook is open, update it.
        local window = self.world.ui:getWindow(UICasebook)
        if window then
          window:updateDiseaseList()
        end
      end
    else
      self.staff_member:setMood("reflexion", "activate") -- Show the uncertainty mood over the doctor
      local next_room = math.random(1, #patient.available_diagnosis_rooms)
      patient:queueAction{
        name = "seek_room", 
        room_type = patient.available_diagnosis_rooms[next_room],
        diagnosis_room = next_room,
        next_to_try = math.random(1, #patient.available_diagnosis_rooms),
      }
    end
  else
    patient:queueAction{name = "meander", count = 2}
    patient:queueAction{name = "idle"}
  end
end

function GPRoom:onHumanoidLeave(humanoid)
  -- Reset moods when either the patient or the doctor leaves the room.
  if self.staff_member then
    self.staff_member:setMood("idea3", "deactivate")
    self.staff_member:setMood("reflexion", "deactivate")
  end
  if self.staff_member == humanoid then
    self.staff_member = nil
  end
  Room.onHumanoidLeave(self, humanoid)
end

return room
