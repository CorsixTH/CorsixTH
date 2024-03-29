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

class "IdleAction" (HumanoidAction)

---@type IdleAction
local IdleAction = _G["IdleAction"]

function IdleAction:IdleAction()
  self:HumanoidAction("idle")
  self.direction = nil -- Direction of standing idle.
  self.on_interrupt = nil -- Function to call at an interrupt.
end

--! Set the direction of facing while standing idle.
--!param direction (string) Direction of facing.
--!return (action) Self, for daisy-chaining.
function IdleAction:setDirection(direction)
  assert(direction == nil or
      direction == "north" or direction == "south" or
      direction == "east" or direction == "west",
      "Invalid value for parameter 'direction'")

  self.direction = direction
  return self
end

--! Set the function to call on interrupt.
--!param on_interrupt (function) Function to call on interrupt.
--!return (action) Self, for daisy-chaining.
function IdleAction:setOnInterrupt(on_interrupt)
  assert(on_interrupt == nil or type(on_interrupt) == "function",
      "Invalid value for parameter 'on_interrupt'")

  self.on_interrupt = on_interrupt
  return self
end

local action_idle_interrupt = permanent"action_idle_interrupt"( function(_, humanoid)
  humanoid:setTimer(1, humanoid.finishAction)
end)

local action_timer = permanent"action_idle_timer"( function(humanoid)
  local action = humanoid:getCurrentAction()
  if action.after_use then
    action.after_use()
    action.must_happen = true
  end
  humanoid:finishAction()
end)

local function action_idle_start(action, humanoid)
  local direction = action.direction or humanoid.last_move_direction
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
  if action.count then
    humanoid:setTimer(action.count, action_timer)
    action.must_happen = true
  end
  -- If an interrupt is already specified for the idle action don't replace it
  if action.must_happen and not action.on_interrupt then
    action.on_interrupt = action_idle_interrupt
  end
  if action.loop_callback then
    action:loop_callback(humanoid)
  end
end

return action_idle_start
