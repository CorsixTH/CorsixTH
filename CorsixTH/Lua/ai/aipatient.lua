--[[ Copyright (c) 2018 Justin Mugford

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

class "AIPatient" (Patient)

---@type AIPatient
local AIPatient = _G["AIPatient"]

function AIPatient:AIPatient(...)
  Patient.Patient(self,...)
  self.ticks = false
  self.next_move_date = 0
  self.phase = 'gp'
end

-- nilled functions just for discovery purposes
function AIPatient:onClick(ui, button)

end

function AIPatient:isTreatmentEffective()
  local cure_chance = self.hospital.disease_casebook[self.disease.id].cure_effectiveness
  --cure_chance = cure_chance * self.diagnosis_progress

  local die = math.random(0, 99) > cure_chance
  return not die
end

function AIPatient:die()
  -- It may happen that this patient was just cured and then the room blew up.
  local hospital = self.hospital
  hospital:humanoidDeath(self)
  self.going_home = true
end

function AIPatient:goHome(reason, disease_id)
  local hosp = self.hospital
  if self.going_home then
    -- The patient should be going home already! Anything related to the hospital
    -- will not be updated correctly, but we still want to try to get the patient to go home.
    TheApp.world:gameLog("AIWarning: goHome called when the patient is already going home")
    self:despawn()
    return
  end
  if reason == "cured" then
    hosp:updateCuredCounts(self)
  elseif reason == "kicked" then
    hosp:updateNotCuredCounts(self, reason)
  elseif reason == "over_priced" then
    hosp:updateNotCuredCounts(self, reason)
  else
    TheApp.world:gameLog("AIError: unknown reason " .. reason .. "!")
  end

  hosp:updatePercentages()

  self.going_home = true
  self.waiting = nil

  self:despawn()
end

function AIPatient:tickDay()
  -- will be written to process AIpatients
  local canusedrinks = true
  if self.next_move_date == 0 or self.next_move_date < self.hospital.world.game_date then
    if self.phase == 'gp' then
      self.in_room = {room_info = self.hospital:getRoomInfo("gp")} -- corsix doesn't send patients to unopened hospital where as th counts all spawned opportunities
      self.hospital:dealtWithPatient(self)
      -- if hospital has purchased a drinks machine, allow patients to get a drink
      if canusedrinks and math.random(1,5) == 1 then
        self.phase = 'drinks' -- drinks machine provides opportunity for more income
      else
        self.phase = 'diagnosis'
      end
    elseif self.phase == 'drinks' then
      self.hospital:sellSodaToPatient(self) -- grab a drink and delay again 5 days
      self.phase = 'diagnosis'
    elseif self.phase == "diagnosis" then
      -- do we put some random checks in for fed up and leaving/death
      self.hospital:dealtWithPatient(self)
      self.phase = "gp"
    elseif self.phase == "treatment" then
      if not self.hospital:hasRequiredStaff(self) then
        self:goHome("kicked", self.disease.id)
        self.hospital:updatePercentages()
      else
        self.in_room = {room_info = self.hospital:getRoomInfo(self.disease.treatment_rooms[1])}
        self.hospital:dealtWithPatient(self)
      end
    else
      self:goHome("kicked", self.disease.id)
    end
    self.next_move_date = self.hospital.world.game_date:plusDays(5)
  end
end

--[[ Comment this out to have patients spawn on the edge of the main map ]]--
function AIPatient:setAnimation(animation, flags)
  return self
end

--[[ Never set the position ]]--
function AIPatient:setTile(x, y)

end
