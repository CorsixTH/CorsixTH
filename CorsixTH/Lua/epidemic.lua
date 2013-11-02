--[[ Copyright (c) 2013 William "sadger" Gatens

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

class "Epidemic"

--[[Manages the epidemics that occur in hospitals. Generally, any epidemic
logic that happens outside this class will call functions contained here.]]
function Epidemic:Epidemic(hospital, contagious_patient)
  print("Creating a new epidemic")
  self.hospital = hospital
  self.world = self.hospital.world

  self.infected_patients = {}

  --The contagious disease the epidemic is based around
  self.disease = contagious_patient.disease

  --Move the first patient closer (FOR TESTING ONLY) 
  local x,y = self.hospital:getHeliportSpawnPosition()
  contagious_patient:setTile(x,y)

  self:addContagiousPatient(contagious_patient)
end

--[[ The epidemic tick - currently the same rate as the hospital's tick but
not necessary dependent on it - could potentially be reduced for performance.]]
function Epidemic:tick()
  self:infectOtherPatients()
end

--[[ Adds a new patient to the epidemic who is actively contagious: infected but
not vaccinated or cured]]
function Epidemic:addContagiousPatient(patient)
  patient.infected = true
  -- This is conditional on cover up being active -- remove after testing
  patient:setMood("epidemy4","activate")
  patient:updateDynamicInfo()
  self.infected_patients[#self.infected_patients + 1] = patient
end

--[[ Goes through all infected patients checking if there are any other patients
 in adjacent squares that can be infected, and if so infects them turning
 them into an infected patient too. ]]
function Epidemic:infectOtherPatients()
  --[[ Can an infected patient infect another patient - taking into account
   spread factor as defined in the configuration.
   @param patient (Patient) already infected patient
   @param other (Patient) target to possibly infect
   @return true if patient can infect other, false otherwise (boolean) ]]
  local function canInfectOther(patient,other)
    local can_infect = false
    local spread_factor = self.config.gbv.ContagiousSpreadFactor or 25
    --Take into account how the spread factor how likely it is to infect someone else
    if spread_factor >= math.random(1,1000) then
      if (not other.infected) and (not other.cured) and (not other.vaccinated)
          and (not patient.cured) and (patient.disease == other.disease) and (not patient.vaccinated)
          -- Both patients are outside (nil rooms) or in the same room - don't infect through walls.
          and (patient:getRoom() == other:getRoom()) then
        can_infect=true
      end
    end
    return can_infect
  end

  -- Go through all infected patients making the check if they can infect
  -- and making any patient they can infect contagious too.
  local entity_map = self.world.entity_map
  if entity_map then
    for _, infected_patient in ipairs(self.infected_patients) do
      local adjacent_patients =
          entity_map:getPatientsInAdjacentSquares(infected_patient.tile_x, infected_patient.tile_y)
      for _, patient in ipairs(adjacent_patients) do
        if canInfectOther(infected_patient,patient) then
          self:addContagiousPatient(patient)
        end
      end
    end
  end
end

