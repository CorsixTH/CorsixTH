--[[ Copyright (c) 2009 Edvin "Lego3" Linge

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

corsixth.require("announcer")
local AnnouncementPriority = _G["AnnouncementPriority"]

local object = {}
object.id = "helicopter"
object.thob = 63
object.name = "helicopter" -- Not seen anywhere
object.class = "Helicopter"
object.ticks = true
object.idle_animations = {
  north = 2456,
}
object.orientations = {
  north = {
    -- Helicopter is outside the hospital, so does not need a footprint
    footprint = {}
  },
}

--! An `Object` which drops off emergency patients.
class "Helicopter" (Object)

---@type Helicopter
local Helicopter = _G["Helicopter"]

function Helicopter:Helicopter(hospital, object_type, direction, etc)
  local x, y = hospital:getHeliportPosition()
  -- Helicopter needs to land below tile to be positioned correctly
  y = y + 1
  self:Object(hospital, object_type, x, y, direction, etc)
  self.th:makeInvisible()
  self:setPosition(0, -600)
  self.phase = -120
  self.hospital = hospital
  -- TODO: Shadow: 3918
  hospital.emergency_patients = {}
end

function Helicopter:tick()
  local phase = self.phase
  local ui = TheApp.ui
  if phase == 0 then
    self.th:makeVisible()
    self:setSpeed(0, 10)
    ui:playAnnouncement(ui.hospital.emergency.disease.emergency_sound, AnnouncementPriority.Critical)
  elseif phase == 60 then
    self:setSpeed(0, 0)
    self.spawned_patients = 0
    ui.adviser:say(_A.information.emergency)
  elseif phase == 85 then
    if self.spawned_patients < self.hospital.emergency.victims then
      self:spawnPatient()
      phase = 60
    end
  elseif phase ==  87 then
    self:setSpeed(0, -10)
  elseif phase == 147 then
    self.world:destroyEntity(self)
  end
  self.phase = phase + 1
  Object.tick(self)
end

--! When the helicopter has landed this method is called each time a patient should spawn from it.
function Helicopter:spawnPatient()
  local hospital = self.hospital
  self.spawned_patients = self.spawned_patients + 1
  local patient = self.world:newEntity("Patient", 2, 1)
  patient:setDisease(hospital.emergency.disease)
  patient.diagnosis_progress = 1
  patient.is_emergency = self.spawned_patients
  patient:setDiagnosed()
  patient:setMood("emergency", "activate")
  hospital.emergency_patients[self.spawned_patients] = patient
  local x, y = hospital:getHeliportSpawnPosition()
  patient:setNextAction(SpawnAction("spawn", {x = x, y = y}):setOffset({y = 1}))
  patient:setHospital(hospital)
  -- TODO: If new combined diseases are added this will not work correctly anymore.
  patient.cure_rooms_visited = #patient.disease.treatment_rooms - 1
  local no_of_rooms = #patient.disease.treatment_rooms
  -- a spawning emergency patient might rather leave than pay
  if not patient:agreesToPay(patient.disease.id) then
    patient:goHome("over_priced", patient.disease.id)
  else
    patient:queueAction(SeekRoomAction(patient.disease.treatment_rooms[no_of_rooms]))
  end
end

return object
