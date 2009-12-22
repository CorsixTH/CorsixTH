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

class "Patient" (Humanoid)

function Patient:Patient(...)
  self:Humanoid(...)
  self.hover_cursor = TheApp.gfx:loadMainCursor("patient")
end

function Patient:onClick(ui, button)
  if button == "left" then
    ui:addWindow(UIPatient(ui, self))
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
end

function Patient:setHospital(hospital)
  if self.hospital then
    self.hospital:removePatient(self)
  end
  Humanoid.setHospital(self, hospital)
  if hospital then
    if hospital.is_in_world then
      self:setNextAction{name = "seek_reception", hospital = hospital}
    end
    hospital:addPatient(self)
  end
end

function Patient:goHome(cured)
  if self.going_home then
    return
  end
  if cured then
    self:setMood "happy"
    self:playSound "cheer.wav"
  else
    self:setMood "exit"
  end
  
  self.going_home = true
  self:setHospital(nil)
end

-- Calls to this function increases/decreases thirst. Thirst can 
-- be between 0 and 1, so amounts here should be appropriately small comma values.
function Patient:changeThirst(amount)
  if self.thirst then
    self.thirst = self.thirst + amount
    if self.thirst > 1 then
      self.thirst = 1
    elseif self.thirst < 0 then
      self.thirst = 0
    end
  end
end

-- If thirst gets over a certain level (now: 0.8),
-- try to find a drinks machine.
function Patient:tickDay()
  -- Start by calling the parent function - it checks
  -- if we're outside the hospital or on our way home.
  if not Humanoid.tickDay(self) then
    return
  end
  self:changeThirst(self.warmth*0.05)
  -- If thirsty enough a soda would be nice
  if self.thirst > 0.8 then
    self:changeHappiness(-0.02)
    self:setMood("coffee")
    -- If there's already an action to buy a drink in the action queue, do nothing
    if self.going_to_drinks_machine then
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
      -- while before trying again. TODO: (Is this needed?)
      if not machine then
        self.timeout = 3
        return
      end
      self.going_to_drinks_machine = true
      
      -- Callback function when the machine has been used
      local function after_use(old_action)
        self:changeThirst(-0.8)
        self.going_to_drinks_machine = nil
        self:setMood(nil)
        self.hospital:receiveMoney(15, _S(8, 14))
      end
        
      -- If we are queueing, let the queue handle the situation.
      for i, current_action in ipairs(self.action_queue) do
        if current_action.name == "queue" then
          local callbacks = current_action.queue.callbacks[self]
          if callbacks then
            callbacks:onGetSoda(self, machine, lx, ly)
            return
          end
        end
      end
      
      -- Or, if walking or idling insert the needed actions in 
      -- the beginning of the queue
      local current = self.action_queue[1]
      if current.name == "walk" or current.name == "idle" then
        -- Go to the machine, use it, and then continue with 
        -- whatever he/she was doing.
        self:queueAction({
          name = "walk", 
          x = lx, 
          y = ly,
          must_happen = true,
        }, 1)
        self:queueAction({
          name = "use_object", 
          object = machine, 
          after_use = after_use,
          must_happen = true,
        }, 2)
        -- Insert the old action again
        self:queueAction({
          name = current.name,
          x = current.x,
          y = current.y,
          must_happen = current.must_happen,
          is_entering = current.is_entering,
        }, 3)
        -- If we were idling, go away a little before continuing with
        -- that important action.
        if current.name == "idle" then
          self:queueAction({
            name = "meander", 
            count = 1,
          }, 3)
        end
        current.on_interrupt(current, self, nil)
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
      if callbacks and action:isStanding() then
        callbacks:onChangeQueuePosition(self)
        break
      end
    end
  end
end
