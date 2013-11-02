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

  -- The contagious disease the epidemic is based around
  self.disease = contagious_patient.disease

  -- Config to retrieve the custom fines (if they exist)
  self.config = self.world.map.level_config

  -- Can the epidemic be revealed to the player
  self.ready_to_reveal = false

  self.declare_fine = 0


  -- Set when we know if the player has passed/failed the epidemic
  -- generally used to test if infected patients can still infect others
  self.result_determined = false


  --Move the first patient closer (FOR TESTING ONLY)
  local x,y = self.hospital:getHeliportSpawnPosition()
  contagious_patient:setTile(x,y)

  self:addContagiousPatient(contagious_patient)
end

--[[ The epidemic tick - currently the same rate as the hospital's tick but
not necessary dependent on it - could potentially be reduced for performance.]]
function Epidemic:tick()
  if not self.ready_to_reveal then
    self:checkIfReadyToReveal()
  end
  if not self.result_determined then
    self:infectOtherPatients()
  end
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

function Epidemic:checkIfReadyToReveal()
  for _, infected_patient in ipairs(self.infected_patients) do
    if infected_patient.diagnosed then
      print(tostring(self) .. " ready to reveal")
      self.ready_to_reveal = true
      self:revealEpidemic()
      break
    end
  end
end

--[[ Show the player the have an epidemic - send a fax
 This happens when the epidemic is chosen to the be
 the "active" epidemic out of all the queued ones.]]
function Epidemic:revealEpidemic()
  assert(self.ready_to_reveal)
  print("Epidemic " .. tostring(self) .. " revealed " ..
    self:countInfectedPatients() .. " patients infected")
  self:sendInitialFax()
end


--[[ Counts the number of patients that have been infected that are still
-- infected
-- @return infected_count (Integer) the number of patients still infected.]]
function Epidemic:countInfectedPatients()
  local infected_count = 0
  for _, patient in pairs(self.infected_patients) do
    if patient.infected and not patient.cured then
      infected_count = infected_count + 1
    end
  end
  return infected_count
end

--[[ Sends the initial fax to the player when the epidemic is revealed.]]
function Epidemic:sendInitialFax()
  local num_infected = self:countInfectedPatients()
  print("Number infected: " .. tostring(num_infected))
  --Save it in a global variable so we can apply the fine in the declare function
  self.declare_fine = self:calculateInfectedFine(num_infected)
  print("Declaration fine: " .. tostring(self.declare_fine))

  local message = {
    {text = _S.fax.epidemic.disease_name:format(self.disease.name)},
    {text = _S.fax.epidemic.declare_explanation_fine:format(self.declare_fine)},
    {text = _S.fax.epidemic.cover_up_explanation_1},
    {text = _S.fax.epidemic.cover_up_explanation_2},
    choices = {
      {text = _S.fax.epidemic.choices.declare, choice = "declare_epidemic"},
      {text = _S.fax.epidemic.choices.cover_up, choice = "cover_up_epidemic"},
    },
  }
  self.world.ui.bottom_panel:queueMessage("epidemy", message, nil, 24*20,2)
end

--[[ Calculate the fine for having a given number of infected patients
--Used to determine the initial declaration fine as the cover up fine.
--@param infected_count (Integer) number of patients still infected
--@return fine (Integer) the fine amount ]]
function Epidemic:calculateInfectedFine(infected_count)
  local fine_per_infected = self.config.gbv.EpidemicFine or 2000
  return math.max(2000,math.min(infected_count * fine_per_infected, 20000))
end


--[[ When the player chooses to declare the epidemic instead of trying
 to cover up it from the initial faxs - ends the epidemic immediately
 after applying fine.]]
function Epidemic:resolveDeclaration()
  self.result_determined = true
  self:clearAllInfectedPatients()

  --No fax for declaration just apply fines and rep hit
  self.hospital:spendMoney(self.declare_fine, _S.transactions.epidemy_fine)
  local reputation_hit = self:getBaseReputationFromFine(self.declare_fine)
  print("Reputation hit " .. tostring(reputation_hit))
  self.hospital.reputation = self.hospital.reputation - reputation_hit
  self.hospital.epidemic = nil
end

--[[ Gets the amount of reputation to add/remove from the player
 based on a given fine. Reputation gain/loss isn't specified
 in the configs so we use a percentage of the fine as a base
 value with extra being gained/lost for specific circumstances.
 @param fine_amount (Integer) amount the player will be fined
 @return reputation hit (Integer) reputation to be deducted relative to fine]]
function Epidemic:getBaseReputationFromFine(fine_amount)
  return math.round(fine_amount/100)
end

--[[ Remove all infected patients by vaccinating from the hospital and clear
 any epidemic-specific icons from their heads.]]
function Epidemic:clearAllInfectedPatients()
  for _, infected_patient in ipairs(self.infected_patients) do
    infected_patient.vaccinated = true
    infected_patient:setMood("epidemy1","deactivate")
    infected_patient:setMood("epidemy2","deactivate")
    infected_patient:setMood("epidemy3","deactivate")
    infected_patient:setMood("epidemy4","deactivate")
  end
end


--[[ When the player chooses to begin the cover up over declaring from the
 initial fax (@see sendInitialFax) ]]
function Epidemic:startCoverUp()
  print("Starting cover up")
end


