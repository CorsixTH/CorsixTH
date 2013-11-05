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

  -- Various values for the different outcomes - used when result fax is sent
  self.declare_fine = 0
  self.reputation_hit = 0
  self.coverup_fine = 0
  self.compensation = 0

  -- Is the epidemic bad enough to deserve the whole hospital to be evacuated
  self.will_be_evacuated = false

  -- Fax sent when the result of the cover up is revealed to the player
  self.cover_up_result_fax = {}

  -- Set if the user choses the cover up option instead of declaring
  self.coverup_in_progress = false

  --Cover up timer and amount of intervals the timer has
  self.timer = nil
  self.countdown_intervals = 0

  -- Set when we know if the player has passed/failed the epidemic
  -- generally used to test if infected patients can still infect others
  self.result_determined = false

  -- Vaccination mode is activated when the icon on the timer
  -- is clicked - used to determine what the cursor should look like
  self.vaccination_mode_active = false

  -- During a cover up the infected patient who is marked for
  -- vaccination that has been chosen to be vaccinated
  self.vaccination_candidate = nil

  -- For Cheat - Show the contagious icon even before the epidemic is revealed?
  self.cheat_always_show_mood = false

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
  if self.coverup_in_progress and not self.result_determined then
    self:checkNoInfectedPlayerHasLeft()
    self:determineNextVaccinationCandidate()
    self:makeVaccinationCandidateCallForNurse()
    self:showAppropriateAdviceMessages()
  end
  self:checkPatientsForRemoval()
end

--[[ Adds a new patient to the epidemic who is actively contagious: infected but
  not vaccinated or cured]]
function Epidemic:addContagiousPatient(patient)
  patient.infected = true
  patient:updateDynamicInfo()
  self.infected_patients[#self.infected_patients + 1] = patient
  if self.coverup_in_progress or self.cheat_always_show_mood then
    patient:setMood("epidemy4","activate")
  end
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

--[[ The epidemic is ready to be revealed to the player if any infected patient
 is fully diagnosed. N.B. because multiple epidemics are queued to become
 the "active" one, being ready to reveal does NOT guarantee an epidemic
 WILL be revealed to the player and may even terminate before they are even
 aware it existed. ]]
function Epidemic:checkIfReadyToReveal()
  for _, infected_patient in ipairs(self.infected_patients) do
    if infected_patient.diagnosed then
      print(tostring(self) .. " ready to reveal")
      self.ready_to_reveal = true
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

--[[ Checks for conditions that could end the epidemic earlier than
 the length of the timer. If an infected patient leaves the
 hospital it's discovered instantly and will result in a fail.]]
function Epidemic:checkNoInfectedPlayerHasLeft()
  local function infected_patient_left()
    for _, infected_patient in ipairs(self.infected_patients) do
      local px, py = infected_patient.tile_x, infected_patient.tile_y
      -- If leaving and longer in the hospital
      if infected_patient.going_home
          and not infected_patient.cured
          and px and py and (not self.hospital:isInHospital(px,py)) then
        return true
      end
    end
    return false
  end

  if infected_patient_left() then
    self.result_determined = true
    self:spawnInspector()
    self:finishCoverUp()
  end
end

--[[Remove any patients which were already on their way out or died before the
epidemic was started to be fair on the players so they don't instantly fail.
Additionally if any patients die during an epidemic we also remove them,
otherwise a player may never win the epidemic in such a case.]]
function Epidemic:checkPatientsForRemoval()
    for i, infected_patient in ipairs(self.infected_patients) do
      if (not self.coverup_in_progress and infected_patient.going_home)
          or infected_patient.dead then
        print("Removing patient from epidemic")
        table.remove(self.infected_patients,i)
      end
    end
end

--[[ Toggle the vaccination mode changes how the cursor interacts with
 the hospital. Toggled by pressing the button on the watch
(@see UIWatch:UIWatch) ]]
function Epidemic:toggleVaccinationMode()
  self.vaccination_mode_active = not self.vaccination_mode_active
  print("Vacc Mode: " .. tostring(self.vaccination_mode_active))
  local cursor = self.vaccination_mode_active and "epidemic_hover" or "default"
  self.world.ui:setCursor(self.world.ui.app.gfx:loadMainCursor(cursor))
end

--[[ Show a patient is able to be vaccinated, this is shown to the player by
 changing the icon, once a player has been marked for vaccination they may
 possibly become the vaccination candidate. Marking is done by clicking
 the player and can only happen during a cover up. ]]
function Epidemic:markForVaccination(patient)
  if patient.infected and not patient.vaccinated
    and not patient.marked_for_vaccination then
    print("Clicked and epidemic is active")
    patient.marked_for_vaccination = true
    patient:setMood("epidemy4","deactivate")
    patient:setMood("epidemy2","activate")
  end
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

--[[Counts the number of patients that have been infected that are now cured.
@return cured_count (Integer) the number of cured patients that were once
infected]]
function Epidemic:countCuredPatients()
  local cured_count = 0
  for _, infected_patient in ipairs(self.infected_patients) do
    if infected_patient.cured then
      cured_count = cured_count + 1
    end
  end
  return cured_count
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
  self.timer = UIWatch(self.world.ui, "epidemic")
  self.countdown_intervals = self.timer.open_timer
  self.world.ui:addWindow(self.timer)
  self.coverup_in_progress = true
  --Set the mood icon for all infected patients
  for _, infected_patient in ipairs(self.infected_patients) do
    infected_patient:updateDynamicInfo()
    infected_patient:setMood("epidemy4","activate")
  end
end

--[[ Ends the cover up of the epidemic with the result to be applied
later (@see applyOutcome) ]]
function Epidemic:finishCoverUp()
  self.result_determined = true

  local watch = self.world.ui:getWindow(UIWatch)
  if watch then
    watch:close()
  end

  -- Turn vaccination mode off
  if self.vaccination_mode_active then
    self:toggleVaccinationMode()
  end

  local total_infected = #self.infected_patients
  local still_infected = self:countInfectedPatients()
  local total_cured = self:countCuredPatients()

  print("Total infected " .. total_infected)
  print("Still infected patient count: " .. still_infected)
  print("Cured patient count: " .. total_cured)

  self:determineFaxAndFines(still_infected)
  self:clearAllInfectedPatients()
end

--[[ Calculates the contents of the fax and the appropriate fines based on the
result of a cover up, results are stored globally to the class to be applied later.
 @param still_infected (Integer) the number of patients still infected]]
function Epidemic:determineFaxAndFines(still_infected)
  -- Losing text
  local fail_text_1 = _S.fax.epidemic_result.failed.part_1_name:format(self.disease.name)
  local fail_text_2 = _S.fax.epidemic_result.failed.part_2
  local close_option = {text = _S.fax.epidemic_result.close_text, choice = "close"}

  -- Losing fine (if epidemic is "lost")
  self.coverup_fine = self:calculateInfectedFine(still_infected)

  if still_infected == 0 then
    -- Compensation fine (if epidemic is "won")
    local compensation_low_value = self.config.gbv.EpidemicCompLo or 1000
    local compensation_high_value = self.config.gbv.EpidemicCompHi or 5000
    self.compensation = math.random(compensation_low_value,compensation_high_value)

    self.cover_up_result_fax = {
      {text = _S.fax.epidemic_result.succeeded.part_1_name:format(self.disease.name)},
      {text = _S.fax.epidemic_result.succeeded.part_2},
      {text = _S.fax.epidemic_result.compensation_amount:format(self.compensation)},
      choices = {close_option}
    }
  elseif still_infected < 5 then
    self.cover_up_result_fax = {
      {text = fail_text_1},
      {text = fail_text_2},
      {text = _S.fax.epidemic_result.fine_amount:format(self.coverup_fine)},
      choices = {close_option}
    }
  elseif still_infected >=5 and still_infected < 10 then
    self.cover_up_result_fax = {
      {text = fail_text_1},
      {text = fail_text_2},
      {text = _S.fax.epidemic_result.rep_loss_fine_amount:format(self.coverup_fine)},
      choices = {close_option}
    }
  else
    self.will_be_evacuated = true
    self.cover_up_result_fax = {
      {text = fail_text_1},
      {text = fail_text_2},
      {text = _S.fax.epidemic_result.hospital_evacuated},
      choices = {close_option}
    }
    -- The reputation hit will be 1/3 of the total reputation
    self.reputation_hit = self.reputation_hit + math.round(self.hospital.reputation * (1/3))
  end
end

--[[ Apply the compensation or fines where appropriate to the player as
determined when the cover up was completed (@see finishCoverUp) ]]
function Epidemic:applyOutcome()
  -- If there is no compensation to apply the epidemic has been failed
  if self.compensation == 0 then
    -- Apply fine and reputation hit
    self.hospital:spendMoney(self.coverup_fine,_S.transactions.epidemy_coverup_fine)
    self.reputation_hit = self.reputation_hit + self:getBaseReputationFromFine(self.coverup_fine)
    self.hospital.reputation =  self.hospital.reputation - self.reputation_hit

    print("Reputation hit :" .. tostring(self.reputation_hit))
    print("Cover up fine :" .. tostring(self.coverup_fine))

    if self.will_be_evacuated then
      self:evacuateHospital()
    end
  else
    self.hospital:receiveMoney(self.compensation, _S.transactions.compensation)
    print("Compensation: " .. tostring(self.compensation))
  end
  -- Finally send the fax confirming the outcome
  self:sendResultFax()
  --Remove epidemic from hospital so another epidemic may be assigned
  self.hospital.epidemic = nil
end

--[[ Forces evacuation of the hospital - it makes ALL patients leave and storm out. ]]
function Epidemic:evacuateHospital()
  print("Evacuating hospital")
  for _, patient in ipairs(self.hospital.patients) do
    patient:clearDynamicInfo()
    patient:setDynamicInfo('text', {_S.dynamic_info.patient.actions.epidemic_sent_home})
    patient:setMood("exit","activate")
    patient:setNextAction{
      name = "spawn",
      mode = "despawn",
      point = self.world.spawn_points[math.random(1, #self.world.spawn_points)],
      must_happen = true,
    }
  end
end

--[[ Send the results of the cover up to the player - will be a
success/compensation or fail/fines + reputation hit]]
function Epidemic:sendResultFax()
  print("Sending result fax")
  self.world.ui.bottom_panel:queueMessage("report", self.cover_up_result_fax, nil, 24*20, 1)
end

--[[ Spawns the inspector who will walk to the reception desk. ]]
function Epidemic:spawnInspector()
  self.world.ui.adviser:say(_A.information.epidemic_health_inspector)
  print("Spawning Inspector")
  local inspector = self.world:newEntity("Inspector", 2)
  inspector:setType "VIP"

  local spawn_point = self.world.spawn_points[math.random(1, #self.world.spawn_points)]
  inspector:setNextAction{name = "spawn", mode = "spawn", point = spawn_point}
  inspector:setHospital(self.hospital)
  inspector:queueAction{name = "seek_reception"}
end

--[[ Is the patient "still" either idle queuing or sitting on a bench
  Typically this is used to determine if a patient can be vaccinated
  @param patient (Patient) the patient we wish to determine if they are static.]]
local function is_static(patient)
  local patient_action = patient.action_queue[1]
  return patient_action.name == "queue" or patient_action.name == "idle" or
  (patient_action.name == "use_object" and
  patient_action.object.object_type.id == "bench")
end

--[[ Determine if the current vaccination candidate (if exists) should
  remain the vaccination candidate and deselect if not.
  Then determine which infected patient will be chosen to be vaccinated
  next, hence becoming the new vaccination candidate.]]
function Epidemic:determineNextVaccinationCandidate()
    local function violates_candidate_criteria(patient)
      -- A vaccination candidate shouldn't be in a room,
      -- already vaccinated or walking anywhere
      return patient:getRoom() or patient.vaccinated
      or patient.going_home or not is_static(patient)
    end

    local vacc_candidate = self.vaccination_candidate
    if vacc_candidate then
      if violates_candidate_criteria(vacc_candidate) then
        --Restore normal epidemic mood icon
        vacc_candidate:setMood("epidemy3","deactivate")
        local restore_mood = vacc_candidate.vaccinated and "epidemy1" or "epidemy2"
        self.vaccination_candidate:setMood(restore_mood,"activate")
        self.vaccination_candidate = nil
      end
    else
      -- Choose a new vaccination_candidate
      for i, infected_patient in ipairs(self.infected_patients) do
        if infected_patient.marked_for_vaccination and
          not violates_candidate_criteria(infected_patient) then
          -- Give selected patient the cursor with the arrow
          infected_patient:setMood("epidemy2","deactivate")
          infected_patient:setMood("epidemy3","activate")
          self.vaccination_candidate = infected_patient
          -- We've found one - no need to search for another
          break
        end
      end
    end
end

--[[ When someone is suitable for vaccination we create a call
  calling the nurse to come vaccinate.]]
function Epidemic:makeVaccinationCandidateCallForNurse()
  if self.vaccination_candidate and not self.vaccination_candidate.reserved_for
      and is_static(self.vaccination_candidate) then
    local call = self.world.
    dispatcher:callNurseForVaccination(self.vaccination_candidate)
  end
end

--[[ In response to a vaccination call by the vaccination candidate
  (@see makeVaccinationCandidateCallForNurse) perform the vaccination
  actions or deal with call if unable to vaccinate.
  @param patient (Patient) the patient who make the original call
  @param nurse (Nurse) the nurse attempting to vaccinate the patient]]
function Epidemic:createVaccinationActions(patient,nurse)
  patient.reserved_for=nurse
  -- Check square is reachable first
  local x,y = self:getBestVaccinationTile(nurse,patient)
  -- If unreachable patient keep the call open for now
  if not x or not y then
    print("Vaccination unsuccessful")
    nurse:setCallCompleted()
    patient.reserved_for = nil
    nurse:queueAction({name="meander"})
    -- If the patient isn't the current vaccination candidate just
    -- end the call - the nurse may be answering the call when they
    -- were the vaccination candidate
  elseif not (patient == self.vaccination_candidate) then
    print("Not vacc candidate")
    CallsDispatcher.queueCallCheckpointAction(nurse)
    nurse:queueAction{name = "answer_call"}
    nurse:finishAction()
    patient.reserved_for = nil
    -- Otherwise send the nurse to vaccinate
  else
    local vaccination_fee = self.config.gbv.VacCost or 50
    nurse:setNextAction({name="walk", x=x, y=y,
                        must_happen=true,
                        walking_to_vaccinate = true})
   nurse:queueAction({name="vaccinate",
                      vaccination_fee=vaccination_fee,
                      patient=patient, must_happen=true})
  end
end

--[[Find the best tile to stand on to vaccinate a patient
 @param nurse (Nurse) the nurse performing the vaccination
 @param patient (Patient) the patient to be vaccinated
 @return best_x,best_y (Integer,nil) the best tiles to vaccinate from.]]
function Epidemic:getBestVaccinationTile(nurse, patient)
  -- General usage tile finder, used in the other cases
  -- when the patient isn't sitting on a bench
  local function get_best_usage_no_bench(nurse,patient)
    -- Tile patient is standing on
    local px, py = patient.tile_x, patient.tile_y
    -- Location of the nurse
    local nx, ny = nurse.tile_x, nurse.tile_y

    local best_x, best_y = nil
    local shortest_distance = nil
    local free_tiles = self.world.entity_map:getAdjacentFreeTiles(px,py)

    for _, coord in ipairs(free_tiles) do
      local x = coord['x']
      local y = coord['y']

      local distance = self.world:getPathDistance(nx,ny,x,y)
      -- If the tile is reachable for the nurse
      if distance then
        -- If the tile is closer then it's a better choice
        if not shortest_distance or distance < shortest_distance then
          shortest_distance = distance
          best_x, best_y = x, y
        end
      end
    end
    return best_x, best_y
  end

  local action = patient.action_queue[1]
  local px, py = patient.tile_x, patient.tile_y
  -- If the patient is using a bench the best tile to use is
  -- directly in front of them
  if action.name == "use_object" then
    local object_in_use = action.object
    if object_in_use.object_type.id == "bench" then
      local direction = object_in_use.direction
       if direction == "north" then
         return px, py-1
       elseif direction == "south" then
         return px, py+1
       elseif direction == "east" then
         return px+1, py
       elseif direction == "west" then
         return px-1, py
       end
    end
  end
  return get_best_usage_no_bench(nurse, patient)
end

--[[When the nurse is interrupted unreserve the patient and unassign the call.
  @param nurse (Nurse) the nurse whose vaccination actions we are interrupting]]
function Epidemic:interruptVaccinationActions(nurse)
  assert(nurse.humanoid_class == "Nurse")
  if nurse.on_call then
    nurse.on_call.assigned = nil
    nurse.on_call.object.reserved_for = nil
    nurse.on_call = nil
  end
end

--[[ Make the advisor show appropriate messages under certain
  conditions of the epidemic.]]
function Epidemic:showAppropriateAdviceMessages()
  if self.countdown_intervals then
    if not self.has_said_hurry_up and
      -- If only 1/4 of the countdown_intervals remaining on the timer
      self.timer.open_timer == math.floor(self.countdown_intervals * 1/4) then
      self.world.ui.adviser:say(_A.epidemic.hurry_up)
      self.has_said_hurry_up = true
      -- Wait until at least 1/4 of the countdown_intervals has expired before giving
      -- this warning so it doesn't happen straight away
    elseif self.timer.open_timer <= math.floor(self.countdown_intervals * 3/4)
      and not self.has_said_serious
      and self:countInfectedPatients() > 10 then
      self.world.ui.adviser:say(_A.epidemic.serious_warning)
      self.has_said_serious = true
    end
  end
end

--[[ Are no infected patients, cured or still infected in the hospital?
@returns true if so, false otherwise. (boolean) ]]
function Epidemic:hasNoInfectedPatients()
  return #self.infected_patients == 0
end

