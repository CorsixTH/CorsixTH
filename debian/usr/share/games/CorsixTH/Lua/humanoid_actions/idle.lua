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

local action_idle_interrupt = permanent"action_idle_interrupt"( function(action, humanoid)
  humanoid:setTimer(1, humanoid.finishAction)
end)

local action_timer = permanent"action_idle_timer"( function(humanoid)
  local action = humanoid.action_queue[1]
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
  if action.must_happen then
    action.on_interrupt = action_idle_interrupt
  end
  if action.loop_callback then
    action:loop_callback(humanoid)
  end
end

return action_idle_start
