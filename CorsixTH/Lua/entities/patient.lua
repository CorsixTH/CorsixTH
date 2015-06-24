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

--! A `Humanoid` who is in the hospital for diagnosis and/or treatment.
class "Patient" (Humanoid)

---@type Patient
local Patient = _G["Patient"]

function Patient:Patient(...)
  self:Humanoid(...)
  self.hover_cursor = TheApp.gfx:loadMainCursor("patient")
  self.should_knock_on_doors = true
  self.treatment_history = {}
  self.has_fallen = 1
  self.has_vomitted = 0
  self.action_string = ""
  self.cured = false
  self.infected = false
  -- To distingish between actually being dead and having a nil hospital
  self.dead = false
  -- Is the patient reserved for a particular nurse when being vaccinated
  self.reserved_for = false
  self.vaccinated = false
  -- Has the patient been sent to the wrong room and needs redirecting
  self.needs_redirecting = false
  self.attempted_to_infect= false
  -- Is the patient about to be vaccinated?
  self.vaccination_candidate = false
  -- Has the patient passed reception?
  self.has_passed_reception = false
end

function Patient:onClick(ui, button)
  if button == "left" then
    if self.message_callback then
      self:message_callback()
    else
      local hospital = self.hospital or self.world:getLocalPlayerHospital()
      local epidemic = hospital and hospital.epidemic
      if not epidemic or
        (not epidemic.coverup_in_progress
        or (not self.infected or self.marked_for_vaccination)
        and not epidemic.vaccination_mode_active) then
        ui:addWindow(UIPatient(ui, self))
      end
      if epidemic and epidemic.coverup_in_progress and
        self.infected and not self.marked_for_vaccination and
        -- Prevent further vaccinations when the timer ends
        not epidemic.timer.closed then
        epidemic:markForVaccination(self)
      end
    end
  elseif self.user_of then
    -- The object we're using is made invisible, as the animation contains both
    -- the humanoid and the object. Hence send the click onto the object.
    self.user_of:onClick(ui, button)
  end
  Humanoid.onClick(self, ui, button)
end

function Patient:setDisease(disease)
  self.disease = disease
  disease.initPatient(self)
  self.diagnosed = false
  self.diagnosis_progress = 0
  self.cure_rooms_visited = 0
  -- copy list of diagnosis rooms
  self.available_diagnosis_rooms = {}
  for i, room in ipairs(self.disease.diagnosis_rooms) do
    self.available_diagnosis_rooms[i] = room
  end
  -- Decide an insurance company, one out of four patients have one.
  -- TODO: May need some balancing, but it is roughly the same as in TH.
  local company = math.random(1,12)
  if company < 4 then
    self.insurance_company = company
  end
  -- Randomise thirst and the need to visit the loo soon.
  -- Alien patients do not have the needed animations for these things, so exclude them
  if not self.disease.only_emergency then
    self.attributes["thirst"] = math.random()*0.2
    self.attributes["toilet_need"] = math.random()*0.2
  end
  self:updateDynamicInfo()
end

function Patient:changeDisease(new_disease)
  assert(not self.diagnosed, "Cannot change the disease of a diagnosed patient")
  -- These assertions should hold until handling of visual diseases is implemented.
  assert(self.disease.contagious, "Cannot change the disease of a patient who has a non-contagious disease")
  assert(new_disease.contagious, "Cannot change a disease to a non-contagious disease")

  --[[ Go through the list of diagnosis rooms for the current disease
  -- and check if they are in the list of available rooms for the patient
  -- if they are not on there they must be visited already or unavailable
  -- @return visited_or_unavailable_rooms (table of strings) names of visited
  -- or unavailable rooms]]
  local function get_visited_or_unavailable_rooms()
    local visited = ""
    local visited_or_unavailable_rooms = {}
    for j, disease_room in ipairs(self.disease.diagnosis_rooms) do
      local found = false

      for i, room in ipairs(self.available_diagnosis_rooms) do
        if room == disease_room then
          found = true
        end
      end
      if not found then
        visited_or_unavailable_rooms[#visited_or_unavailable_rooms + 1] = disease_room
        visited = visited == "" and disease_room or visited .. "," .. disease_room
      end
    end
    return visited_or_unavailable_rooms
  end

  -- Copy the diagnosis rooms from the new disease
  local new_diagnosis_rooms = {}
  for i, new_diag_room in ipairs(new_disease.diagnosis_rooms) do
    new_diagnosis_rooms[#new_diagnosis_rooms+1] = new_diag_room
  end

  -- The set of new diagnosis rooms is the diagnosis rooms
  -- for the new disease MINUS the ones they have already visited or
  -- are unavailable.
  local visited_rooms = get_visited_or_unavailable_rooms()
  for i, new_diag_room in ipairs(new_diagnosis_rooms) do
    for _, visited_room in ipairs(visited_rooms) do
      if(new_diag_room == visited_room) then
        table.remove(new_diagnosis_rooms,i)
      end
    end
  end

  self.available_diagnosis_rooms = new_diagnosis_rooms
  self.disease = new_disease
end

function Patient:setdiagDiff()
  local disease = self.disease
  local difficulty = 0
  local expertise = self.world.map.level_config.expertise
  if expertise then
    difficulty = expertise[disease.expertise_id].MaxDiagDiff
    self.diagnosis_difficulty = difficulty / 1000
  end
  return self.diagnosis_difficulty
end

function Patient:setDiagnosed(diagnosed)
  self.diagnosed = diagnosed
  self.treatment_history[#self.treatment_history + 1] = self.disease.name
  local window = self.world.ui:getWindow(UIPatient)
  if window and window.patient == self then
    window:updateInformation()
  end
  self:updateDynamicInfo()
end

-- Sets the value of the diagnosis progress.
function Patient:setDiagnosisProgress(progress)
  self.diagnosis_progress = progress
  self:updateDynamicInfo()
end

-- Modifies the diagnosis progress of a patient.
-- incrementValue can be either positive or negative.
function Patient:modifyDiagnosisProgress(incrementValue)
  self.diagnosis_progress = math.min(self.hospital.policies["stop_procedure"],
    self.diagnosis_progress + incrementValue)
  self.diagnosis_progress = math.max(0.000, self.diagnosis_progress)
  local window = self.world.ui:getWindow(UIPatient)
  if window and window.patient == self then
    window:updateInformation()
  end
  self:updateDynamicInfo()
end

-- Updates the patients diagnostic progress based on the doctors skill
-- called when they are done using a diagnosis room
function Patient:completeDiagnosticStep(room)
  -- Base: depending on difficulty of disease as set in sam file
  -- tiredness reduces the chance of diagnosis if staff member is above 50% tired
  local multiplier = 1
  local diagnosis_difficulty = self:setdiagDiff()
  local diagnosis_base = (0.4 * (1 - diagnosis_difficulty))
  local diagnosis_bonus = 0.4

  -- Did the staff member manage to leave the room before the patient had
  -- a chance to get diagnosed? Then use a default middle value.
  if room.staff_member then
  local fatigue = room.staff_member.attributes["fatigue"] or 0
    -- Bonus: based on skill and attn to detail (with some randomness).
    -- additional bonus if the staff member is highly skilled / consultant
    -- tiredness reduces the chance of diagnosis if staff member is above 50% tired
    if room.staff_member.profile.skill >= 0.9 then
      multiplier = math.random(1, 5) * (1 - (fatigue -0.5))
    else
      multiplier = 1 * (1 - (fatigue -0.5))
    end
    local divisor = math.random(1, 3)
    local attn_detail = room.staff_member.profile.attention_to_detail / divisor
    local skill = room.staff_member.profile.skill / divisor
    local diagnosis_bonus = (attn_detail + 0.4) *  skill
  end
  self:modifyDiagnosisProgress(diagnosis_base + (diagnosis_bonus * multiplier))
end

function Patient:setHospital(hospital)
  if self.hospital then
    self.hospital:removePatient(self)
  end
  Humanoid.setHospital(self, hospital)
  if hospital then
    if hospital.is_in_world and not self.is_debug and not self.is_emergency then
      self:setNextAction{name = "seek_reception"}
    end
    hospital:addPatient(self)
  end
end

function Patient:treated() -- If a drug was used we also need to pay for this
  local hospital = self.hospital
  local amount = self.hospital.disease_casebook[self.disease.id].drug_cost or 0
  hospital:receiveMoneyForTreatment(self)
  if amount ~= 0 then
  local str = _S.drug_companies[math.random(1 , 5)]
  hospital:spendMoney(amount, _S.transactions.drug_cost .. ": " .. str)
  end

  -- Either the patient is no longer sick, or he/she dies.

  local cure_chance = hospital.disease_casebook[self.disease.id].cure_effectiveness
  cure_chance = cure_chance * self.diagnosis_progress
  if self.die_anims and math.random(1, 100) > cure_chance then
    self:die()
  else
    -- to guess the cure is risky and the patient could die
    if self.die_anims and math.random(1, 100) > (self.diagnosis_progress * 100) then
      self:die()
    else
      if hospital.num_cured < 1 then
        self.world.ui.adviser:say(_A.information.first_cure)
      end
      self.hospital.num_cured = hospital.num_cured + 1
      self.hospital.num_cured_ty = hospital.num_cured_ty + 1
      self.hospital:msgCured()
      local casebook = hospital.disease_casebook[self.disease.id]
      casebook.recoveries = casebook.recoveries + 1
      if self.is_emergency then
        self.hospital.emergency.cured_emergency_patients = hospital.emergency.cured_emergency_patients + 1
      end
      self.cured = true
      self.infected = false
      self:setMood("cured", "activate")
      self.world.ui:playSound "cheer.wav" -- This sound is always heard
      self.attributes["health"] = 1
      self:changeAttribute("happiness", 0.8)
      hospital:changeReputation("cured", self.disease)
      self.treatment_history[#self.treatment_history + 1] = _S.dynamic_info.patient.actions.cured
      self:goHome(self.cured)
      self:updateDynamicInfo(_S.dynamic_info.patient.actions.cured)
    end
  end

  hospital:updatePercentages()

  if self.is_emergency then
    local killed = hospital.emergency.killed_emergency_patients
    local cured = hospital.emergency.cured_emergency_patients
    if killed + cured >= hospital.emergency.victims then
      local window = hospital.world.ui:getWindow(UIWatch)
      if window then
        window:onCountdownEnd()
      end
    end
  end
end

function Patient:die()
  -- It may happen that this patient was just cured and then the room blew up.
  -- (Hospital not set when going home)
  local hospital = self.hospital or self.world:getLocalPlayerHospital()

  if hospital.num_deaths < 1 then
    self.world.ui.adviser:say(_A.information.first_death)
  end
  hospital:humanoidDeath(self)
  if not self.is_debug then
    local casebook = hospital.disease_casebook[self.disease.id]
    casebook.fatalities = casebook.fatalities + 1
  end
  hospital:msgKilled()
  self:setMood("dead", "activate")
  self.world.ui:playSound "boo.wav" -- this sound is always heard
  self.going_home = true
  if self:getRoom() then
    self:queueAction{name = "meander", count = 1}
  else
    self:setNextAction{name = "meander", count = 1}
  end
  if self.is_emergency then
    hospital.emergency.killed_emergency_patients = hospital.emergency.killed_emergency_patients + 1
  end
  self:queueAction{name = "die"}
  self:updateDynamicInfo(_S.dynamic_info.patient.actions.dying)
end

function Patient:canPeeOrPuke(current)
  return ((current.name == "walk" or current.name == "idle" or current.name == "seek_room" or current.name == "queue")
         and not self.going_home and self.world.map.th:getCellFlags(self.tile_x, self.tile_y).buildable)
end
  -- animations for when there is an earth quake
function Patient:falling()
  local current = self.action_queue[1]
  current.keep_reserved = true
  if self.falling_anim and self:canPeeOrPuke(current) and self.has_fallen == 1 then
    self:setNextAction({
      name = "falling",
      must_happen = true
      }, 0)
    self.has_fallen = 2
    if self.has_fallen == 2 then
      self:setNextAction{name = "on_ground"}
      self.on_ground = true
    end
      if self.on_ground then
        self:setNextAction{name = "get_up"}
      end
      if current.name == "idle" or current.name == "walk" then
        self:queueAction({
          name = current.name,
          x = current.x,
          y = current.y,
          must_happen = current.must_happen,
          is_entering = current.is_entering,
        }, 2)
      else
      self:queueAction({
        name = current.name,
        room_type = current.room_type,
        message_sent = true,
        diagnosis_room = current.diagnosis_room,
        treatment_room = current.treatment_room,
      }, 2)
      end
      if current.on_interrupt then
        current.on_interrupt(current, self)
      else
      self:finishAction()
      end
      self.on_ground = false
      if math.random(1, 5) == 3 then
        self:shake_fist()
      end
      self:fallingAnnounce()
      self:changeAttribute("happiness", -0.05) -- falling makes you very unhappy
  else
    return
  end
end

function Patient:fallingAnnounce()
  local msg = {
  (_A.warnings.falling_1),
  (_A.warnings.falling_2),
  (_A.warnings.falling_3),
  (_A.warnings.falling_4),
  (_A.warnings.falling_5),
  (_A.warnings.falling_6),
  }
  if msg then
    self.world.ui.adviser:say(msg[math.random(1, #msg)])
  end
end
function Patient:shake_fist()
  if self.shake_fist_anim then
    self:queueAction({
        name = "shake_fist",
        must_happen = true
        }, 1)
  end
end

function Patient:vomit()
  local current = self.action_queue[1]
  --Only vomit under these conditions. Maybe I should add a vomit for patients in queues too?
  if self:canPeeOrPuke(current) and self.has_vomitted == 0 then
    self:queueAction({
      name = "vomit",
      must_happen = true
      }, 1)
    if current.name == "idle" or current.name == "walk" then
      self:queueAction({
        name = current.name,
        x = current.x,
        y = current.y,
        must_happen = current.must_happen,
        is_entering = current.is_entering,
      }, 2)
    else
      self:queueAction({
        name = current.name,
        room_type = current.room_type,
        message_sent = true,
        diagnosis_room = current.diagnosis_room,
        treatment_room = current.treatment_room,
      }, 2)
    end
    if current.on_interrupt then
      current.on_interrupt(current, self)
    else
      self:finishAction()
    end
    self.has_vomitted = self.has_vomitted + 1
    self:changeAttribute("happiness", -0.02) -- being sick makes you unhappy
  else
    return
  end
end

function Patient:pee()
  local current = self.action_queue[1]
  --Only pee under these conditions. As with vomit, should they also pee if in a queue?
  if self:canPeeOrPuke(current) then
    self:queueAction({
      name = "pee",
      must_happen = true
      }, 1)
    if current.name == "idle" or current.name == "walk" then
      self:queueAction({
        name = current.name,
        x = current.x,
        y = current.y,
        must_happen = current.must_happen,
        is_entering = current.is_entering,
      }, 2)
    else
      self:queueAction({
        name = current.name,
        room_type = current.room_type,
        message_sent = true,
        diagnosis_room = current.diagnosis_room,
        treatment_room = current.treatment_room,
      }, 2)
    end
    if current.on_interrupt then
      current.on_interrupt(current, self)
    else
      self:finishAction()
    end
    self:setMood("poo", "deactivate")
    self:changeAttribute("happiness", -0.02)  -- not being able to find a loo and doing it in the corridor will make you sad too
    if not self.hospital.did_it_on_floor then
      self.hospital.did_it_on_floor = true
      self.world.ui.adviser:say(_A.warnings.people_did_it_on_the_floor)
    end
  else
    return
  end
end

function Patient:checkWatch()
  if self.check_watch_anim and not self.action_queue[1].is_leaving then
    self:queueAction({
      name = "check_watch",
      must_happen = true
      }, 0)
  end
end

function Patient:yawn()
  local action = self.action_queue[1]
  if self.yawn_anim and action.name == "idle" then
    self:queueAction({
      name = "yawn",
      must_happen = true
      }, 0)
  end
end

function Patient:tapFoot()
  if self.tap_foot_anim and not self.action_queue[1].is_leaving then
    self:queueAction({
      name = "tap_foot",
      must_happen = true
      }, 0)
  end
end

function Patient:goHome(cured)
  local hosp = self.hospital
  if not hosp and self.going_home then
    -- The patient should be going home already! Anything related to the hospital
    -- will not be updated correctly, but we still want to try to get the patient to go home.
    TheApp.world:gameLog("Warning: goHome called when the patient is already going home")
    self:setHospital(nil)
    return
  end
  if not cured then
    self:setMood("exit", "activate")
    if not self.is_debug then
      hosp:changeReputation("kicked", self.disease)
      self.hospital.not_cured = hosp.not_cured + 1
      self.hospital.not_cured_ty = hosp.not_cured_ty + 1
      local casebook = self.hospital.disease_casebook[self.disease.id]
      casebook.turned_away = casebook.turned_away + 1
    end
  end

  hosp:updatePercentages()

  if self.is_debug then
    hosp:removeDebugPatient(self)
  end
  -- Remove any messages and/or callbacks related to the patient.
  self:unregisterCallbacks()

  self.going_home = true
  self.waiting = nil

  -- Remove any vaccination calls from patient
  if not self.vaccinated then
    self.world.dispatcher:dropFromQueue(self)
  end

  local room = self:getRoom()
  if room then
    room:makeHumanoidLeave(self)
  end
  self:setHospital(nil)
end

-- This function handles changing of the different attributes of the patient.
-- For example if thirst gets over a certain level (now: 0.7), the patient
-- tries to find a drinks machine nearby.
function Patient:tickDay()
  -- First of all it may happen that this patient is tired of waiting and goes home.
  if self.waiting then
    self.waiting = self.waiting - 1
    if self.waiting == 0 then
      self:goHome()
      if self.diagnosed then
        -- No treatment rooms
        self:updateDynamicInfo(_S.dynamic_info.patient.actions.no_treatment_available)
      else
        -- No diagnosis rooms
        self:updateDynamicInfo(_S.dynamic_info.patient.actions.no_diagnoses_available)
      end
    elseif self.waiting == 10 then
      self:tapFoot()
    elseif self.waiting == 20 then
      self:yawn()
    elseif self.waiting == 30 then
      self:checkWatch()
    end

    if self.has_vomitted and self.has_vomitted > 0 then
      self.has_vomitted = 0
    end
  end

  -- if patients are getting unhappy, then maybe we should see this!
  if self.attributes["happiness"] < 0.3 then
    self:setMood("sad7", "activate")
  else
    self:setMood("sad7", "deactivate")
  end
  -- Now call the parent function - it checks
  -- if we're outside the hospital or on our way home.
  if not Humanoid.tickDay(self) then
    return
  end
  -- Die before we poo or drink
  -- patient has been in the hospital for over 6 months and is still not well, so will become sad and will either get fed up and leave
  -- or stay in the hope that you will cure them before they die
  -- strange, but in TH happiness does not go down, even when close to death IMO that is wrong as you would be unhappy if you waited too long.
  -- TODO death animation for slack female is missing its head.  For now the only option is for her to get fed up and leave
  -- this can be changed when the animation thing is resolved
  -- TODO clean up this block, nonmagical numbers
  if self.attributes["health"] >= 0.18 and self.attributes["health"] < 0.22 then
    self:setMood("sad2", "activate")
    self:changeAttribute("happiness", -0.0002)   -- waiting too long will make you sad
    -- There is a 1/3 chance that the patient will get fed up and leave
    -- note, this is potentially run 10 ((0.22-0.18)/0.004) times, hence the 1/30 chance.
    if math.random(1,30) == 1 then
      self:updateDynamicInfo(_S.dynamic_info.patient.actions.fed_up)
      self:setMood("sad2", "deactivate")
      self:goHome()
    end
  elseif self.attributes["health"] >= 0.14 and self.attributes["health"] < 0.18 then
    self:setMood("sad2", "deactivate")
    self:setMood("sad3", "activate")
  -- now wishes they had gone to that other hospital
  elseif self.attributes["health"] >= 0.10 and self.attributes["health"] < 0.14 then
    self:setMood("sad3", "deactivate")
    self:setMood("sad4", "activate")
  -- starts to take a turn for the worse and is slipping away
  elseif self.attributes["health"] >= 0.06 and self.attributes["health"] < 0.10 then
    self:setMood("sad4", "deactivate")
    self:setMood("sad5", "activate")
  -- fading fast
  elseif self.attributes["health"] >= 0.01 and self.attributes["health"] < 0.06 then
    self:setMood("sad5", "deactivate")
    self:setMood("sad6", "activate")
  -- its not looking good
  elseif self.attributes["health"] > 0.00 and self.attributes["health"] < 0.01 then
    self.attributes["health"] = 0.0
  -- is there time to say a prayer
  elseif self.attributes["health"] == 0.0 then
    -- people who are in a room should not die:
    -- 1. they are being cured in this moment. dying in the last few seconds
    --    before the cure makes only a subtle difference for gameplay
    -- 2. they will leave the room soon (toilets, diagnostics) and will die then
    if not self:getRoom() and not self.action_queue[1].is_leaving then
      self:setMood("sad6", "deactivate")
      self:die()
    end
    --dead people aren't thirsty
    return
  end
  -- Note: to avoid empty action queue error if the player spam clicks a patient at the same time as the day changes
  -- there is now an inbetween "neutal" stage.
  if self.has_fallen == 3 then
    self.has_fallen = 1
  elseif self.has_fallen == 2 then
    self.has_fallen = 3
  end
  -- Vomitings.
  if self.vomit_anim and not self:getRoom() and not self.action_queue[1].is_leaving and not self.action_queue[1].is_entering then
    --Nausea level is based on health then proximity to vomit is used as a multiplier.
    --Only a patient with a health value of less than 0.8 can be the inital vomiter, however :)
    local initialVomitMult = 0.002   --The initial chance of vomiting.
    local proximityVomitMult = 1.5  --The multiplier used when in proximity to vomit.
    local nausea = (1.0 - self.attributes["health"]) * initialVomitMult
    local foundVomit = {}
    local numVomit = 0

    self.world:findObjectNear(self, "litter", 2, function(x, y)
      local litter = self.world:getObject(x, y, "litter")
    if not litter then
    return
    end
      if litter:vomitInducing() then
        local alreadyFound = false
        for i=1,numVomit do
          if foundVomit[i] == litter then
            alreadyFound = true
            break
          end
        end

        if not alreadyFound then
          numVomit = numVomit + 1
          foundVomit[numVomit] = litter
        end
      end
      -- seeing litter will make you unhappy. If it is pee or puke it is worse
      if litter:anyLitter() then
        self:changeAttribute("happiness", -0.0002)
      else
        self:changeAttribute("happiness", -0.0004)
      end
    end) -- End of findObjectNear
    -- As we don't yet have rats, rat holes and dead rats the chances of vomitting are slim
    -- as a temp  fix for this I have added 0.5 to the < nausea equation,
    -- this may want adjusting or removing when the other factors are in the game MarkL
    if self.attributes["health"] <= 0.8 or numVomit > 0 or self.attributes["happiness"] < 0.6 then
      nausea = nausea * ((numVomit+1) * proximityVomitMult)
      if math.random() < nausea + 0.5 then
        self:vomit()
      end
    end
  end

  -- It is nice to see plants, but dead plants make you unhappy
  self.world:findObjectNear(self, "plant", 2, function(x, y)
    local plant = self.world:getObject(x, y, "plant")
  if not plant then
    return
  end
    if plant:isPleasing() then
      self:changeAttribute("happiness", 0.0002)
    else
      self:changeAttribute("happiness", -0.0002)
    end
  end)
  -- It always makes you happy to see you are in safe place
  self.world:findObjectNear(self, "extinguisher", 2, function(x, y)
    self:changeAttribute("happiness", 0.0002)
  end)
  -- sitting makes you happy whilst standing and walking does not
  if self:goingToUseObject("bench")  then
    self:changeAttribute("happiness", 0.00002)
  else
    self:changeAttribute("happiness", -0.00002)
  end

  -- Each tick both thirst, warmth and toilet_need changes and health decreases.
  self:changeAttribute("thirst", self.attributes["warmth"]*0.02+0.004*math.random() + 0.004)
  self:changeAttribute("health", - 0.004)
  if self.disease.more_loo_use then
    self:changeAttribute("toilet_need", 0.018*math.random() + 0.008)
  else
    self:changeAttribute("toilet_need", 0.006*math.random() + 0.002)
  end
  -- Maybe it's time to visit the loo?
  if self.attributes["toilet_need"] and self.attributes["toilet_need"] > 0.75 then
    if self.pee_anim and not self.action_queue[1].is_leaving
    and not self.action_queue[1].is_entering and not self.in_room then
      if math.random(1, 10) < 5 then
        self:pee()
        self:changeAttribute("toilet_need", -(0.5 + math.random()*0.15))
        self.going_to_toilet = false
      else
        -- If waiting for user response, do not send to toilets, as this messes
        -- things up.
        if not self.going_to_toilet and not self.waiting then
          self:setMood("poo", "activate")
          -- Check if any room exists.
          if not self.world:findRoomNear(self, "toilets") then
            self.going_to_toilet = true
            local callback
            callback = --[[persistable:patient_toilet_build_callback]] function(room)
              if room.room_info.id == "toilets" then
                self.going_to_toilet = false
                self:unregisterRoomBuildCallback(callback)
              end
            end
            self:registerRoomBuildCallback(callback)
          -- Otherwise we can queue the action, but only if not in any rooms right now.
          elseif not self:getRoom() and not self.action_queue[1].is_leaving and not self.action_queue[1].pee then
            self:setNextAction{
              name = "seek_toilets",
              must_happen = true,
              }
            self.going_to_toilet = true
          end
        end
      end
    end
  end
  if self.disease.yawn and math.random(1, 10) == 5 then
    self:yawn()
  end

  -- If thirsty enough a soda would be nice
  if self.attributes["thirst"] and self.attributes["thirst"] > 0.7 then
    self:changeAttribute("happiness", -0.002)
    self:setMood("thirsty", "activate")
    -- If there's already an action to buy a drink in the action queue, or
    -- if we're going to the loo, do nothing
    if self:goingToUseObject("drinks_machine") or self.going_to_toilet then
      return
    end
    -- Don't check for a drinks machine too often
    if self.timeout and self.timeout > 0 then
      self.timeout = self.timeout - 1
      return
    end
    -- The only allowed situations to grab a soda is when queueing
    -- or idling/walking in the corridors
    -- Also make sure the walk action when leaving a room has a chance to finish.
    if not self:getRoom() and not self.action_queue[1].is_leaving
    and not self.going_home then
      local machine, lx, ly = self.world:
          findObjectNear(self, "drinks_machine", 8)

      -- If no machine can be found, resume previous action and wait a
      -- while before trying again. To get a little randomness into the picture
      -- it's not certain we go for it right now.
      if not machine or not lx or not ly or math.random(1,10) < 3 then
        self.timeout = math.random(2,4)
        return
      end

      -- Callback function when the machine has been used
      local --[[persistable:patient_drinks_machine_after_use]] function after_use()
        self:changeAttribute("thirst", -(0.7 + math.random()*0.3))
        self:changeAttribute("toilet_need", 0.05 + math.random()*0.05)
        self:setMood("thirsty", "deactivate")
        -- The patient might be kicked while buying a drink
        if not self.going_home then
          self.hospital:receiveMoneyForProduct(self, 20, _S.transactions.drinks)
          -- Also increase the number of sodas sold this year.
          self.hospital.sodas_sold = self.hospital.sodas_sold + 1
        end
        -- The patient might also throw the can on the floor, bad patient!
        if math.random() < 0.6 then
          -- It will be dropped between 1 and 5 tiles away.
          self.litter_countdown = math.random(1, 5)
        end
      end

      -- If we are queueing, let the queue handle the situation.
      for i, current_action in ipairs(self.action_queue) do
        if current_action.name == "queue" then
          local callbacks = current_action.queue.callbacks[self]
          if callbacks then
            callbacks:onGetSoda(self, machine, lx, ly, after_use)
            return
          end
        end
      end

      -- Or, if walking or idling insert the needed actions in
      -- the beginning of the queue
      local current = self.action_queue[1]
      if current.name == "walk" or current.name == "idle" or current.name == "seek_room" then
        -- Go to the machine, use it, and then continue with
        -- whatever he/she was doing.
        current.keep_reserved = true
        self:queueAction({
          name = "walk",
          x = lx,
          y = ly,
          must_happen = true,
          no_truncate = true,
        }, 1)
        self:queueAction({
          name = "use_object",
          object = machine,
          after_use = after_use,
          must_happen = true,
        }, 2)
        machine:addReservedUser(self)
        -- Insert the old action again, a little differently depending on
        -- what the previous action was.
        if current.name == "idle" or current.name == "walk" then
          self:queueAction({
            name = current.name,
            x = current.x,
            y = current.y,
            must_happen = current.must_happen,
            is_entering = current.is_entering,
          }, 3)
          -- If we were idling, also go away a little before continuing with
          -- that important action.
          if current.name == "idle" then
            self:queueAction({
              name = "meander",
              count = 1,
            }, 3)
          end
        else -- We were seeking a room, start that action from the beginning
             -- i.e. do not set the must_happen flag.
          self:queueAction({
            name = current.name,
            room_type = current.room_type,
            message_sent = true,
            diagnosis_room = current.diagnosis_room,
            treatment_room = current.treatment_room,
          }, 3)
        end
        if current.on_interrupt then
          current.on_interrupt(current, self)
        else
          self:finishAction()
        end
      end
    end
  end

  -- If the patient is sitting on a bench or standing and queued,
  -- it may be a situation where he/she is not in the queue
  -- anymore, but should be. If this is the case for more than
  -- 2 ticks, go to reception
  if #self.action_queue > 1 and (self.action_queue[1].name == "use_object" or
    self.action_queue[1].name == "idle") and
    self.action_queue[2].name == "queue" then
    local found = false
    for _, humanoid in ipairs(self.action_queue[2].queue) do
      if humanoid == self then
        found = true
        break
      end
    end

    if not found then
      if not self.noqueue_ticks then
        self.noqueue_ticks = 1
      elseif self.noqueue_ticks > 2 then
        self.world:gameLog("A patient has a queue action, but is not in the corresponding queue")
        self:setNextAction{name = 'seek_reception'}
      else
        self.noqueue_ticks = self.noqueue_ticks + 1
      end
    else
      self.noqueue_ticks = 0
    end
  end
end

-- Called each time the patient moves to a new tile.
function Patient:setTile(x, y)
  -- Is the patient about to drop some litter?
  if self.litter_countdown then
    self.litter_countdown = self.litter_countdown - 1
    if self.litter_countdown == 0 and self.hospital then
      if x and not self:getRoom() and not self.world:getObjects(x, y)
      and self.world.map.th:getCellFlags(x, y).buildable then
        -- Drop some litter!
        local trash = math.random(1, 4)
        local litter = self.world:newObject("litter", x, y)
        litter:setLitterType(trash, math.random(0, 1))
        if not self.hospital.hospital_littered then
          self.hospital.hospital_littered = true
          -- A callout is only needed if there are no handymen employed
          if not self.hospital:hasStaffOfCategory("Handyman") then
            self.world.ui.adviser:say(_A.staff_advice.need_handyman_litter)
          end
        end
      end
      self.litter_countdown = nil
    end
  end
  Humanoid.setTile(self, x, y)
end

-- As of now each time a bench is placed the world notifies all patients
-- in the vicinity through this function.
function Patient:notifyNewObject(id)
  -- If currently queueing it would be nice to be able to sit down.
  assert(id == "bench", "Can only handle benches at the moment")
  -- Look for a queue action and tell this patient to look for a bench
  -- if currently standing up.
  for i, action in ipairs(self.action_queue) do
    if action.name == "queue" then
      local callbacks = action.queue.callbacks[self]
      if callbacks then
        assert(action.done_init, "Queue action was not yet initialized")
        if action:isStanding() then
          callbacks:onChangeQueuePosition(self)
          break
        end
      end
    end
  end
end

function Patient:addToTreatmentHistory(room)
  local should_add = true
  -- Do not add facility rooms such as toilets to the treatment history.
  for i, _ in pairs(room.categories) do
    if i == "facilities" then
      should_add = false
      break
    end
  end
  if should_add then
    self.treatment_history[#self.treatment_history + 1] = room.name
  end
end

function Patient:updateDynamicInfo(action_string)
  -- Retain the old text if only an update is wanted, i.e. no new string is supplied.
  if action_string == nil then
    if self.action_string then
      action_string = self.action_string
    else
      action_string = ""
    end
  else
    self.action_string = action_string
  end
  local info = ""
  if self.going_home then
    self:setDynamicInfo('progress', nil)
  elseif self.diagnosed then
    if self.diagnosis_progress < 1.0 then
      -- The cure was guessed
      info = _S.dynamic_info.patient.guessed_diagnosis:format(self.disease.name)
    else
      info = _S.dynamic_info.patient.diagnosed:format(self.disease.name)
    end
    self:setDynamicInfo('progress', nil)
  else
    info = _S.dynamic_info.patient.diagnosis_progress
    -- TODO: If the policy is changed this info will not be changed until the next
    -- diagnosis facility has been visited.
    local divider = 1
    if self.hospital then
      divider = self.hospital.policies["stop_procedure"]
    end
    if self.diagnosis_progress then
      self:setDynamicInfo('progress', self.diagnosis_progress*(1/divider))
    end
  end
  -- Set the centre line of dynamic info based on contagiousness, if appropriate
  local epidemic = self.hospital and self.hospital.epidemic
  if epidemic and epidemic.coverup_in_progress then
    if self.infected and not self.vaccinated then
      self:setDynamicInfo('text',
        {action_string, _S.dynamic_info.patient.actions.epidemic_contagious, info})
    elseif self.vaccinated then
      self:setDynamicInfo('text',
        {action_string, _S.dynamic_info.patient.actions.epidemic_vaccinated, info})
    end
  else
    self:setDynamicInfo('text', {action_string, "", info})
  end
end

--[[ Update availability of a choice in message owned by this patient, if any
!param choice (string) The choice that needs updating (currently "research" or "guess_cure").
]]
function Patient:updateMessage(choice)
  if self.message and self.message.choices then
    local enabled = false
    if choice == "research" then
      -- enable only if research department is built and a room in the treatment chain is undiscovered
      if self.hospital:hasRoomOfType("research") then
        local req = self.hospital:checkDiseaseRequirements(self.disease.id)
        if req then
          for _, room_id in ipairs(req.rooms) do
            local room = self.world.available_rooms[room_id]
            if room and self.hospital.undiscovered_rooms[room] then
              enabled = true
              break
            end
          end
        end
      end
    else -- if choice == "guess_cure" then
      -- TODO: implement
    end

    for _, c in ipairs(self.message.choices) do
      if c.choice == choice then
        c.enabled = enabled
      end
    end

    -- Update the fax window if it is open.
    local window = self.world.ui:getWindow(UIFax)
    if window then
      window:updateChoices()
    end

  end
end

--[[ Does the patient have a visual disease
--  @return result (boolean) true if so, false otherwise]]
function Patient:hasVisualDisease()
  -- Only patients with visual diseases have this field
  return (self.disease.visuals_id ~= nil)
end


--[[ If the patient is not a vaccination candidate then
  give them the arrow icon and candidate status ]]
function Patient:giveVaccinationCandidateStatus()
  self:setMood("epidemy2","deactivate")
  self:setMood("epidemy3","activate")
  self.vaccination_candidate = true
end

--[[Remove the vaccination candidate icon and status from the patient]]
function Patient:removeVaccinationCandidateStatus()
  if not self.vaccinated then
    self:setMood("epidemy3","deactivate")
    self:setMood("epidemy2","activate")
    self.vaccination_candidate = false
  end
end


function Patient:afterLoad(old, new)
  if old < 68 then
    if self.going_home then
      self.waiting = nil
    end
  end
  if old < 87 then
    if self.die_anims == nil then
      self.die_anims = {}
    end

    -- New humanoid animation: rise_hell_east:
    if self:isMalePatient() then
      if self.humanoid_class ~= "Alternate Male Patient" then
        self.die_anims.rise_hell_east = 384
      else
        self.die_anims.rise_hell_east = 3404
      end
    else
      self.die_anims.rise_hell_east = 580
    end
  end
  Humanoid.afterLoad(self, old, new)
end

function Patient:isMalePatient()
  if string.find(self.humanoid_class,"Female") then return false
  elseif string.find(self.humanoid_class,"Male") then return true
  else
    local male_patient_classes = {["Chewbacca Patient"] = true,["Elvis Patient"] = true,["Invisible Patient"] = true}
    return male_patient_classes[self.humanoid_class] ~= nil
  end
end
