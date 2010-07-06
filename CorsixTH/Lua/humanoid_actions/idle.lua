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

--! Instruct a `Humanoid` to stand in one place and not do anything.
class "IdleAction" {} (Action)

--!param ... Arguments for the base class constructor.
function IdleAction:IdleAction(...)
  self:Action(...)
end

local action_timer = permanent"action_idle_timer"( function(humanoid)
  local action = humanoid.action_queue[1]
  if action.after_use then
    action.after_use()
    action.must_happen = true
  end
  humanoid:finishAction()
end)

function IdleAction:truncate(high_priority)
  if not self.is_active then
    self.count = 1
  elseif self.count then
    self.humanoid:callTimer()
  else
    action_timer(self.humanoid)
  end
end

function IdleAction:setAnimation()
  local humanoid = self.humanoid
  
  local direction = self.direction or humanoid.last_move_direction
  local anims = humanoid.walk_anims
  if direction == "north" then
    humanoid:setAnimation(anims.idle_north, 0)
  elseif direction == "east" then
    humanoid:setAnimation(anims.idle_east, 0)
  elseif direction == "south" then
    humanoid:setAnimation(anims.idle_east, 1)
  elseif direction == "west" then
    humanoid:setAnimation(anims.idle_north, 1)
  end
  humanoid.th:setTile(humanoid.th:getTile())
  humanoid:setSpeed(0, 0)
end

function IdleAction:onStart()
  Action.onStart(self)
  
  local humanoid = self.humanoid
  local action = self
  
  self:setAnimation()
  if action.count then
    humanoid:setTimer(action.count, action_timer)
  end
  if action.loop_callback then
    action:loop_callback()
  end
end
