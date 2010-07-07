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

--! Have a receptionist stand behind a reception desk and service `Patient`s.
class "StaffReceptionAction" {} (Action)

--!param ... Arguments for the base class constructor.
function StaffReceptionAction:StaffReceptionAction(...)
  self:Action(...)
end

function StaffReceptionAction:canRemoveFromQueue(is_high_priority)
  return (is_high_priority or not self.is_active) and
    Action.canRemoveFromQueue(self, is_high_priority)
end

local action_staff_reception_interrupt = permanent"action_staff_reception_interrupt"( function(action, humanoid, high_priority)
  local dx, dy = action.orig_x, action.orig_y
  if high_priority then
    humanoid:setTilePositionSpeed(dx, dy)
    humanoid:finishAction()
  else
    action:cleanup()
    HumanoidRawWalk(humanoid, humanoid.tile_x, humanoid.tile_y, dx, dy, nil,
    --[[persistable:staff_reception_action_after_walk_out]] function()
      humanoid:setTilePositionSpeed(dx, dy)
      humanoid:finishAction()
    end)
  end
end)

function StaffReceptionAction:truncate(is_high_priority)
  self.truncated = true
  self.truncated_high_priority = self.truncated_high_priority or is_high_priority
  if self.can_truncate_now then
    self.can_truncate_now = nil
    action_staff_reception_interrupt(self, self.humanoid, self.truncated_high_priority)
  end
end

local action_staff_reception_idle_phase = permanent"action_staff_reception_idle_phase"( function(humanoid)
  local action = humanoid.action_queue[1]
  local self = action
  local direction = humanoid.last_move_direction
  local object = action.object
  IdleAction.setAnimation(self)
  humanoid:setTilePositionSpeed(self.use_x, self.use_y)
  object.receptionist = humanoid
  object.reserved_for = nil
  object.th:makeVisible()
  if direction == "north" or direction == "west" then
    -- Place desk behind receptionist in render order (they are on the same tile)
    object.th:setTile(object.th:getTile())
  end
  if action.truncated then
    action_staff_reception_interrupt(self, self.humanoid, self.truncated_high_priority)
  else
    action.can_truncate_now = true
  end
end)

function StaffReceptionAction:handleRemovedObject(index_in_queue)
  if index_in_queue == #self.humanoid.action_queue then
    self.humanoid:queueAction(MeanderAction)
  end
  self.humanoid:cancelActions(index_in_queue, index_in_queue)
end

function StaffReceptionAction:cleanup()
  local humanoid = self.humanoid
  local desk = self.object
  
  if desk.receptionist == humanoid then
    desk.receptionist = nil
  end
  if desk.reserved_for == humanoid then
    desk.reserved_for = nil
  end
  desk:checkForNearbyStaff()
  if humanoid.associated_desk == desk then
    humanoid.associated_desk = nil
  end
end

function StaffReceptionAction:onAddToQueue(humanoid)
  Action.onAddToQueue(self, humanoid)
  self.object.reserved_for = humanoid
  humanoid.associated_desk = self.object
end

function StaffReceptionAction:onRemoveFromQueue()
  self:cleanup()
  Action.onRemoveFromQueue(self)
end

function StaffReceptionAction:onStart()
  local action = self
  local humanoid = self.humanoid
  local object = action.object
  Action.onStart(self)
  
  -- Just in case the desk is picked up while the action is active, remember
  -- the important tiles at this moment in time.
  self.orig_x, self.orig_y = object:getSecondaryUsageTile()
  self.use_x, self.use_y = object.tile_x, object.tile_y
  
  HumanoidRawWalk(humanoid, self.orig_x, self.orig_y, self.use_x, self.use_y,
    nil, action_staff_reception_idle_phase)
end
