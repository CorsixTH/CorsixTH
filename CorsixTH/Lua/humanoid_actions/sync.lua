--[[ Copyright (c) 2010 Peter "Corsix" Cawley

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

dofile "humanoid_actions/idle"

--! Multi-`Humanoid` synchronisation helper.
--! A set of "related" synchronisation actions is created by creating one
-- `SyncAction`, then calling duplicate() on it. Each action in the set must
-- end up in the action queue of a different `Humanoid`. If all of a set of
-- `SyncAction`s become active, then they all finish, and any dependant actions
-- are allowed to happen. Otherwise, if any `SyncAction` is removed from an
-- action queue, then all related `SyncAction`s are also removed from their
-- queues, and all dependant actions are cancelled. Note that dependant actions
-- are not synchronised between `Humanoid`s; if a dependant action of one
-- `SyncAction` is removed from an action queue, then no other dependant
-- actions are affected.
class "SyncAction" {} (IdleAction)

--!param ... Arguments for the base class constructor.
function SyncAction:SyncAction(...)
  self:IdleAction(...)
  
  -- Ensure that the dependant_actions array is present
  if not self.dependant_actions then
    self.dependant_actions = {}
  elseif class.is(self.dependant_actions, Action)
  or class.name(self.dependant_actions) then
    -- If dependant_actions is a single action, then turn it into an array
    self.dependant_actions = {self.dependant_actions}
  end
  
  -- sync_info is shared between all the members of a set of sychronisation
  -- actions.
  local existing = self.master
  if not existing then
    existing = self
    self.sync_info = {
      num_active = 0,
      num_actions = 0,
      humanoid_set = {},
    }
  end
  self.sync_info = existing.sync_info
end

function SyncAction:duplicate()
  return SyncAction{master = self.master or self}
end

local function indexof(t, v)
  for k, v2 in pairs(t) do
    if v == v2 then
      return k
    end
  end
end

local function cancel_action_by_value(humanoid, action)
  if action.humanoid == humanoid then
    local queue = humanoid.action_queue
    local i = 1
    while true do
      if queue[i] == action then
        humanoid:cancelActions(i, i)
        break
      end
      i = i + 1
    end
  end
end

function SyncAction:onAddToQueue(humanoid)
  IdleAction.onAddToQueue(self, humanoid)
  local sync_info = self.sync_info
  sync_info.num_actions = sync_info.num_actions + 1
  sync_info.humanoid_set[humanoid] = self
end

--! Register an action to happen if and only if the `SyncAction` and all
-- related `SyncAction`s correctly finish.
--!param action (Action) An action which should depend upon the `SyncAction`.
-- This action can already be in an action queue, in which case it must be in
-- the same queue as the `SyncAction`, and not be before it. If this action is
-- not in a queue, then it will be inserted immediately after the `SyncAction`,
-- provided that the `SyncAction` has a chance of succeeding. Either way, the
-- dependant action will be removed from the action queue if the `SyncAction`
-- is cancelled.
--!return (Action)
function SyncAction:addDependantAction(action)
  -- Catch the case of being passed the name of an Action rather than an
  -- instance (only needed because we want to always return an Action).
  if class.name(action) then
    action = action()
  end
  
  self.dependant_actions[#self.dependant_actions + 1] = action
  return action
end

function SyncAction:onRemoveFromQueue()
  local sync_info = self.sync_info
  sync_info.num_actions = sync_info.num_actions - 1
  sync_info.humanoid_set[self.humanoid] = nil
  for humanoid, action in pairs(sync_info.humanoid_set) do
    cancel_action_by_value(humanoid, action)
  end
  if not sync_info.done then
    for _, action in ipairs(self.dependant_actions) do
      cancel_action_by_value(self.humanoid, action)
    end
  end
  IdleAction.onRemoveFromQueue(self)
end

function SyncAction:onFinish()
  local sync_info = self.sync_info
  sync_info.num_active = sync_info.num_active - 1
  IdleAction.onFinish(self)
end

function SyncAction:onStart()
  IdleAction.onStart(self)
  local sync_info = self.sync_info
  sync_info.num_active = sync_info.num_active + 1
  local queue_at = 1
  for k, action in ipairs(self.dependant_actions) do
    if not action.humanoid then
      self.dependant_actions[k] = self.humanoid:queueAction(action, queue_at)
      queue_at = queue_at + 1
    end
  end
  if sync_info.num_active == sync_info.num_actions then
    sync_info.done = true
    self.humanoid:finishAction(self)
  end
end
