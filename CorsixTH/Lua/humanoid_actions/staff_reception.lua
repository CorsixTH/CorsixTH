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

local action_staff_reception_interrupt = permanent"action_staff_reception_interrupt"( function(action, humanoid, high_priority)
  local object = action.object
  object.receptionist = nil
  object:checkForNearbyStaff()
  humanoid.associated_desk = nil
  local dx, dy = object:getSecondaryUsageTile()
  if high_priority then
    humanoid:setTilePositionSpeed(dx, dy)
    humanoid:finishAction()
  else
    HumanoidRawWalk(humanoid, humanoid.tile_x, humanoid.tile_y, dx, dy, nil, function()
      humanoid:setTilePositionSpeed(dx, dy)
      humanoid:finishAction()
    end)
  end
end)

local action_staff_reception_idle_phase = permanent"action_staff_reception_idle_phase"( function(humanoid)
  local action = humanoid.action_queue[1]
  local direction = humanoid.last_move_direction
  local anims = humanoid.walk_anims
  local object = action.object
  if direction == "north" then
    humanoid:setAnimation(anims.idle_north, 0)
  elseif direction == "east" then
    humanoid:setAnimation(anims.idle_east, 0)
  elseif direction == "south" then
    humanoid:setAnimation(anims.idle_east, 1)
  elseif direction == "west" then
    humanoid:setAnimation(anims.idle_north, 1)
  end
  humanoid:setTilePositionSpeed(object.tile_x, object.tile_y)
  object.receptionist = humanoid
  object.reserved_for = nil
  object.th:makeVisible()
  if direction == "north" or direction == "west" then
    -- Place desk behind receptionist in render order (they are on the same tile)
    object.th:setTile(object.th:getTile())
  end
  if action.on_interrupt then
    action.on_interrupt = action_staff_reception_interrupt
  else
    action_staff_reception_interrupt(action, humanoid)
  end
end)

local action_staff_reception_interrupt_early = permanent"action_staff_reception_interrupt_early"( function(action, humanoid, high_priority)
  if high_priority then
    action.object.reserved_for = nil
    humanoid.associated_desk:checkForNearbyStaff()
    humanoid.associated_desk = nil
    humanoid:setTimer(nil)
    humanoid:setTilePositionSpeed(action.object:getSecondaryUsageTile())
    humanoid:finishAction()
  end
end)

local function action_staff_reception_start(action, humanoid)
  if action.todo_interrupt then
    humanoid.associated_desk.reserved_for = nil
    humanoid.associated_desk:checkForNearbyStaff()
    humanoid.associated_desk = nil
    humanoid:finishAction(action)
    return
  end
  local object = action.object
  HumanoidRawWalk(humanoid, humanoid.tile_x, humanoid.tile_y,
    object.tile_x, object.tile_y, nil, action_staff_reception_idle_phase)
  action.must_happen = true
  action.on_interrupt = action_staff_reception_interrupt_early
end

return action_staff_reception_start
