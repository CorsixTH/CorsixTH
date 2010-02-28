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
  
  -- Randomise thirst and the need to visit the loo soon.
  -- Alien patients can only come via helicopter, and therefore have no drink animation
  if self.humanoid_class ~= "Alien Patient" then
    self.attributes["thirst"] = math.random()*0.2
    self.attributes["toilet_need"] = math.random()*0.2
  end
  self.action_string = ""
end

function Patient:onClick(ui, button)
  if button == "left" then
    if self.message_callback then
      self:message_callback()
    else
      ui:addWindow(UIPatient(ui, self))
    end
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
  self:updateDynamicInfo()
end

function Patient:setDiagnosed(diagnosed)
  self.diagnosed = diagnosed
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
  self.diagnosis_progress = math.max(0.0, self.diagnosis_progress)
  self:updateDynamicInfo()
end

function Patient:setHospital(hospital)
  if self.hospital then
    self.hospital:removePatient(self)
  end
  Humanoid.setHospital(self, hospital)
  if hospital then
    if hospital.is_in_world and not self.is_debug and not self.is_emergency then
      self:setNextAction{name = "seek_reception", hospital = hospital}
    end
    hospital:addPatient(self)
  end
end

function Patient:treated()
  local hospital = self.hospital
  hospital:receiveMoneyForTreatment(self)
  -- Either the patient is no longer sick, or he/she dies.
  -- TODO: Add percentage that depends on illness and how effective the cure is.
  -- Should level also make a difference?
  if self.die_anims and math.random(1, 100) < 6 then
    patient:die()
  else 
    if hospital.num_cured < 1 then
      self.world.ui.adviser:say(_S.adviser.information.first_cure)
    end
    self.hospital.num_cured = hospital.num_cured + 1
    
    self:setMood("cured", "activate")
    self:playSound "cheer.wav"
    hospital:changeReputation("cured")
    self.treatment_history[#self.treatment_history + 1] = _S.dynamic_info.patient.actions.cured
    self:goHome(true)
    self:updateDynamicInfo(_S.dynamic_info.patient.actions.cured)
  end
end

function Patient:die()
  if self.hospital.num_deaths < 1 then
    self.world.ui.adviser:say(_S.adviser.information.first_death)
  end
  self.hospital.num_deaths = self.hospital.num_deaths + 1
  
  self:setMood("dead", "activate")
  self:playSound "boo.wav"
  self.going_home = true
  self:setNextAction{name = "meander", count = 1}
  self:queueAction{name = "die"}
  self.hospital:changeReputation("death")
  self:updateDynamicInfo(_S.dynamic_info.patient.actions.dying)
end

function Patient:goHome(cured)
  if self.going_home then
    return
  end
  if not cured then
    self:setMood("exit", "activate")
    self.hospital:changeReputation("kicked")
  end
  
  if self.is_debug then
    self.hospital:removeDebugPatient(self)
  end
  
  self.going_home = true
  self:setHospital(nil)
end

-- This function handles changing of the different attributes of the patient.
-- For example if thirst gets over a certain level (now: 0.8), the patient
-- tries to find a drinks machine nearby.
function Patient:tickDay()
  -- Start by calling the parent function - it checks
  -- if we're outside the hospital or on our way home.
  if not Humanoid.tickDay(self) then
    return
  end
  
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
    end
  end
  
  -- Each tick both thirst, warmth and toilet_need changes.
  self:changeAttribute("thirst", self.attributes["warmth"]*0.05+0.002)
  self:changeAttribute("toilet_need", 0.001)
  
  -- Maybe it's time to visit the loo?
  if self.attributes["toilet_need"] and self.attributes["toilet_need"] > 0.7 then
    if not self.going_to_toilet then
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
        self.world:registerRoomBuildCallback(callback)
        -- Otherwise we can queue the action, but only if not in any rooms right now.
      elseif not self:getRoom() then
        self:setNextAction{
          name = "seek_toilets",
          must_happen = true,
          }
        self.going_to_toilet = true
      end
    end
  end
  
  -- If thirsty enough a soda would be nice
  if self.attributes["thirst"] and self.attributes["thirst"] > 0.8 then
    self:changeAttribute("happiness", -0.02)
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
    if not self:getRoom() then
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
        self:changeAttribute("thirst", -0.7 + math.random()*0.2)
        self:changeAttribute("toilet_need", 0.1 + math.random()*0.3)
        self:setMood("thirsty", "deactivate")
        -- The patient might be kicked while buying a drink
        if not self.going_home then
          self.hospital:receiveMoneyForProduct(self, 15, _S.transactions.drinks)
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
          }, 3)
        end
        if current.on_interrupt then
          current.on_interrupt(current, self, true)
        else
          self:finishAction()
        end
      end
    end
  end
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

function Patient:updateDynamicInfo(helper_object)
  local action = self.action_queue[1]
  if self.going_home then
    -- We were sent home/are pissed for some reason
    self:setDynamicInfo('text', {helper_object})
    self:setDynamicInfo('progress', nil)
    return
  end
  -- TODO: Is this the best place to update like this? There are also more situations.
  if self:getRoom() then
    self.action_string = ""
  elseif action.name == "walk" and action.is_entering and self.next_room_to_visit then
    self.action_string = _S.dynamic_info.patient.actions.on_my_way_to
      :format(self.next_room_to_visit.room_info.name)
  elseif action.name == "seek_reception" then
    self.action_string = _S.dynamic_info.patient.actions.on_my_way_to
      :format(helper_object.object_type.name)
  elseif action.name == "queue" then
    self.action_string = _S.dynamic_info.patient.actions.queueing_for
      :format(helper_object.room.room_info.name)
  elseif action.name == "seek_toilets" then
    self.action_string = ""
  elseif action.name == "seek_room" then
    self.action_string = helper_object
  end
  if self.diagnosed then
    if self.diagnosis_progress < 1.0 then
      -- The cure was guessed
      self:setDynamicInfo('text', {self.action_string, "", 
        _S.dynamic_info.patient.guessed_diagnosis:format(self.disease.name)})
    else
      self:setDynamicInfo('text', {self.action_string, "", 
        _S.dynamic_info.patient.diagnosed:format(self.disease.name)})
    end
    self:setDynamicInfo('progress', nil)
  else
    self:setDynamicInfo('text', {
      self.action_string, "", 
      _S.dynamic_info.patient.diagnosis_progress
    })
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
end
