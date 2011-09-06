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

function Patient:Patient(...)
  self:Humanoid(...)
  self.hover_cursor = TheApp.gfx:loadMainCursor("patient")
  self.should_knock_on_doors = true
  self.treatment_history = {}
  
  self.action_string = ""
end              

function Patient:onClick(ui, button)
  if button == "left" then
    if self.message_callback then
      self:message_callback()
    else
      ui:addWindow(UIPatient(ui, self))
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
  local diagnosis_difficulty = self:setdiagDiff()
  local diagnosis_base = math.random() * (1 - diagnosis_difficulty)
  if diagnosis_base < 0 then
    diagnosis_base = 0
  end
  -- Bonus: based on skill and attn to detail (with some randomness).
  local divisor = math.random(1, 3)
  local attn_detail = room.staff_member.profile.attention_to_detail / divisor
  local skill = room.staff_member.profile.skill / divisor
  local diagnosis_bonus = (attn_detail * math.random()) *  skill
  
  self:modifyDiagnosisProgress(diagnosis_base + diagnosis_bonus)
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
    hospital:spendMoney(amount, _S.transactions.drug_cost)
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
        self.world.ui.adviser:say(_S.adviser.information.first_cure)
      end
      self.hospital.num_cured = hospital.num_cured + 1
      local casebook = hospital.disease_casebook[self.disease.id]
      casebook.recoveries = casebook.recoveries + 1
      if self.is_emergency then
        self.hospital.emergency.cured_emergency_patients = hospital.emergency.cured_emergency_patients + 1
      end
      self:setMood("cured", "activate")
      self:playSound "cheer.wav"
      self.attributes["health"] = 1
      self:changeAttribute("happiness", 0.8)
      hospital:changeReputation("cured", self.disease)
      self.treatment_history[#self.treatment_history + 1] = _S.dynamic_info.patient.actions.cured
      self:goHome(true)
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
  if self.hospital.num_deaths < 1 then
    self.world.ui.adviser:say(_S.adviser.information.first_death)
  end
  self.hospital:humanoidDeath(self)
  if not self.is_debug then
    local casebook = self.hospital.disease_casebook[self.disease.id]
    casebook.fatalities = casebook.fatalities + 1
  end
  self:setMood("dead", "activate")
  self:playSound "boo.wav"
  self.going_home = true
  if self:getRoom() then
    self:queueAction{name = "meander", count = 1}
  else
    self:setNextAction{name = "meander", count = 1}
  end  
  if self.is_emergency then
    self.hospital.emergency.killed_emergency_patients = self.hospital.emergency.killed_emergency_patients + 1
  end
  self:queueAction{name = "die"}
  self:updateDynamicInfo(_S.dynamic_info.patient.actions.dying)
end

function Patient:canPeeOrPuke(current)
  return ((current.name == "walk" or current.name == "idle" or current.name == "seek_room")
         and not self.going_home and self.world.map.th:getCellFlags(self.tile_x, self.tile_y).buildable)
end

function Patient:vomit()
  local current = self.action_queue[1]
  --Only vomit under these conditions. Maybe I should add a vomit for patients in queues too?
  if self:canPeeOrPuke(current) then
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
      self.world.ui.adviser:say(_S.adviser.warnings.people_did_it_on_the_floor)
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

function Patient:tapFoot()
  if self.tap_foot_anim and not self.action_queue[1].is_leaving then
    self:queueAction({
      name = "tap_foot",
      must_happen = true
      }, 0)  
  end     
end

function Patient:goHome(cured)
  if self.going_home then
    return
  end
  local hosp = self.hospital
  if not cured then
    self:setMood("exit", "activate")
    if not self.is_debug then
      hosp:changeReputation("kicked", self.disease)
      self.hospital.not_cured = hosp.not_cured + 1
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
  local room = self:getRoom()
  if room then
    room:makePatientLeave(self)
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
    elseif self.waiting == 30 then
      self:checkWatch()
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
    self:setMood("sad6", "deactivate")
    self:setMood("dead", "activate")
    self.attributes["health"] = 0.0
  -- is there time to say a prayer
  elseif self.attributes["health"] == 0.0 then
    if not self:getRoom() and not self.action_queue[1].is_leaving then
      self:die()
    end
    --dead people aren't thirsty
    return
  end 
       
  -- Vomitings.
  if self.vomit_anim and not self:getRoom() and not self.action_queue[1].is_leaving and not self.action_queue[1].is_entering then
    --Nausea level is based on health then proximity to vomit is used as a multiplier.
    --Only a patient with a health value of less than 0.7 can be the inital vomiter, however :)
    local initialVomitMult = 0.02   --The initial chance of vomiting.
    local proximityVomitMult = 1.5  --The multiplier used when in proximity to vomit.
    local nausea = (1.0 - self.attributes["health"]) * initialVomitMult
    local foundVomit = {}
    local numVomit = 0
    
    self.world:findObjectNear(self, "litter", 2, function(x, y)
      local litter = self.world:getObject(x, y, "litter")
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
    
    if self.attributes["health"] <= 0.7 or numVomit > 0 or self.attributes["happiness"] < 0.4 then
      nausea = nausea * ((numVomit+1) * proximityVomitMult)
      if math.random() < nausea then
        self:vomit()
      end
    end
  end

  -- It is nice to see plants, but dead plants make you unhappy
  self.world:findObjectNear(self, "plant", 2, function(x, y)
    local plant = self.world:getObject(x, y, "plant")
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
                self.world:unregisterRoomBuildCallback(callback)
              end
            end
            self.toilet_callback = callback
            self.world:registerRoomBuildCallback(callback)
          -- Otherwise we can queue the action, but only if not in any rooms right now.
          elseif not self:getRoom() and not self.action_queue[1].is_leaving then
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
end

-- Called each time the patients moves to a new tile.
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
          self.world.ui.adviser:say(_S.adviser.staff_advice.need_handyman_litter)
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
  self:setDynamicInfo('text', {action_string, "", info})
end
