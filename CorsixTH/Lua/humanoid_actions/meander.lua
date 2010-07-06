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

--! Have a `Humanoid` walk around aimlessly.
class "MeanderAction" {} (Action)

--!param ... Arguments for the base class constructor.
function MeanderAction:MeanderAction(...)
  self:Action(...)
end

function MeanderAction:onStart()
  Action.onStart(self)
  
  local humanoid = self.humanoid
  local action = self
  -- Just wandering around
  if humanoid.humanoid_class == "Doctor" or humanoid.humanoid_class == "Nurse" then
    if not humanoid:getRoom() then
      humanoid:setDynamicInfoText(_S.dynamic_info.staff.actions.wandering)
    end
  end
  local x, y = humanoid.world.pathfinder:findIdleTile(humanoid.tile_x,
    humanoid.tile_y, math.random(1, 24))
  if x == humanoid.tile_x and y == humanoid.tile_y then
    -- Nowhere to walk to - go idle instead, or go onto the next action
    if #humanoid.action_queue == 1 then
      humanoid:queueAction(IdleAction)
    end
    humanoid:finishAction()
    return
  end
  if action.count then
    if action.count == 0 then
      humanoid:finishAction()
      return
    else
      action.count = action.count - 1
    end
  elseif action.loop_callback then
    action.loop_callback()
    -- Loop callback may have started some other action
    if not self.is_active then
      return
    end
  end
  local procrastination
  if action.can_idle and math.random(1, 3) == 1 then
    procrastination = IdleAction{count = math.random(25, 40)}
  else
    action.can_idle = true
    procrastination = WalkAction{x = x, y = y}
  end
  self.procrastination = procrastination
  humanoid:queueAction(procrastination, 0)
end

function MeanderAction:postponeFor(action, index_in_queue)
  self.humanoid:queueAction(action, index_in_queue - 1)
  local procrastination = self.procrastination
  if index_in_queue == 2 and procrastination and procrastination.is_active then
    procrastination:truncate()
  end
  return true
end

function MeanderAction:nudge()
  local procrastination = self.procrastination
  if not procrastination or not self.humanoid then
    return
  end
  if self.count == 0 then
    self.count = 1
  end
  procrastination:truncate()
end
