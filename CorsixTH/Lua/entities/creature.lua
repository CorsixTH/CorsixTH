--[[ Copyright (c) 2009 Benoît "benckx" Vleminckx

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

--! An `Entity` which occupies a single tile and is capable of moving around the map.
class "Creature" (Entity)

local TH = require "TH"

--!param ... Arguments for base class constructor.
function Creature:Creature(...)
  self:Entity(...)
  self.action_queue = {}
  self.last_move_direction = "east"
end

local function Creature_startAction(self)
  local action = self.action_queue[1]

  -- Handle an empty action queue in some way instead of crashing.
  if not action then
    -- if this is a patient that is going home, an empty
    -- action queue is not a problem
    if class.is(self, Patient) and self.going_home then
      return
    end

    ---- Empty action queue! ----
    -- First find out if this humanoid is in a room.
    local room = self:getRoom()
    if room then
      room:makeHumanoidLeave(self)
    end
    -- Is it a member of staff, grim or a patient?
    if class.is(self, Staff) then
      self:queueAction({name = "meander"})
    elseif class.is(self,GrimReaper) then
      self:queueAction({name = "idle"})
    else
      self:queueAction({name = "seek_reception"})
    end
    -- Open the dialog of the humanoid.
    local ui = self.world.ui
    if class.is(self, Patient) then
      ui:addWindow(UIPatient(ui, self))
    elseif class.is(self, Staff) then
      ui:addWindow(UIStaff(ui, self))
    end
    -- Pause the game.
    self.world:setSpeed("Pause")

    -- Tell the player what just happened.
    self.world:gameLog("")
    self.world:gameLog("Empty action queue!")
    self.world:gameLog("Last action: " .. self.previous_action.name)
    self.world:gameLog(debug.traceback())

    ui:addWindow(UIConfirmDialog(ui,
      "Sorry, a humanoid just had an empty action queue,"..
      " which means that he or she didn't know what to do next."..
      " Please consult the command window for more detailed information. "..
      "A dialog with "..
      "the offending humanoid has been opened. "..
      "Would you like him/her to leave the hospital?",
      --[[persistable:humanoid_leave_hospital]] function()
        self.world:gameLog("The humanoid was told to leave the hospital...")
        if class.is(self, Staff) then
          self:fire()
        else
          -- Set these variables to increase the likelihood of the humanoid managing to get out of the hospital.
          self.going_home = false
          self.hospital = self.world:getLocalPlayerHospital()
          self:goHome()
        end
        if TheApp.world:isCurrentSpeed("Pause") then
        TheApp.world:setSpeed(TheApp.world.prev_speed)
      end
      end,
      --[[persistable:humanoid_stay_in_hospital]] function()
        if TheApp.world:isCurrentSpeed("Pause") then
          TheApp.world:setSpeed(TheApp.world.prev_speed)
        end
      end
    ))
    action = self.action_queue[1]

  end
  ---- There is an action to start ----
  -- Call the action start handler
  TheApp.humanoid_actions[action.name](action, self)

  if action == self.action_queue[1] and action.todo_interrupt then
    local high_priority = action.todo_interrupt == "high"
    action.todo_interrupt = nil
    local on_interrupt = action.on_interrupt
    if on_interrupt then
      action.on_interrupt = nil
      on_interrupt(action, self, high_priority)
    end
  end
end

function Creature:setNextAction(action, high_priority)
  -- Aim: Cleanly finish the current action (along with any subsequent actions
  -- which must happen), then replace all the remaining actions with the given
  -- one.
  local i = 1
  local queue = self.action_queue
  local interrupted = false

  -- Skip over any actions which must happen
  while queue[i] and queue[i].must_happen do
    interrupted = true
    i = i + 1
  end

  -- Remove actions which are no longer going to happen
  local done_set = {}
  for j = #queue, i, -1 do
    local removed = queue[j]
    queue[j] = nil
    if not removed then
      -- A bug (rare) that removed could be nil.
      --   but as it's being removed anyway...it could be ignored
      print("Warning: Action to be removed was nil")
    else
      if removed.on_remove then
        removed.on_remove(removed, self)
      end
      if removed.until_leave_queue and not done_set[removed.until_leave_queue] then
        removed.until_leave_queue:removeValue(self)
        done_set[removed.until_leave_queue] = true
      end
      if removed.object and removed.object:isReservedFor(self) then
        removed.object:removeReservedUser(self)
      end
    end
  end

  -- Add the new action to the queue
  queue[i] = action

  -- Interrupt the current action and queue other actions to be interrupted
  -- when they start.
  if interrupted then
    interrupted = queue[1]
    for j = 1, i - 1 do
      queue[j].todo_interrupt = high_priority and "high" or true
    end
    local on_interrupt = interrupted.on_interrupt
    if on_interrupt then
      interrupted.on_interrupt = nil
      on_interrupt(interrupted, self, high_priority or false)
    end
  else
    -- Start the action if it has become the current action
    Creature_startAction(self)
  end
  return self
end

function Creature:queueAction(action, pos)
  if pos then
    table.insert(self.action_queue, pos + 1, action)
    if pos == 0 then
      Creature_startAction(self)
    end
  else
    self.action_queue[#self.action_queue + 1] = action
  end
  return self
end

function Creature:finishAction(action)
  if action ~= nil then
    assert(action == self.action_queue[1], "Can only finish current action")
  end
  -- Save the previous action just a while longer.
  self.previous_action = self.action_queue[1]
  table.remove(self.action_queue, 1)
  Creature_startAction(self)
end

function Creature:updateSpeed()
  self.speed = "normal"
end
