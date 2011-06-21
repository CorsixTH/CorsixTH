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

local function meander_action_start(action, humanoid)
  local room = humanoid:getRoom()
  -- Answering call queue
  if class.is(humanoid, Staff) and humanoid:isIdle() and not room then
    -- If staff starts wandering around in Idle mode,
    -- he's effectively not in any room and need not to comeback after 
    -- staff room visit
    if humanoid.world.dispatcher:answerCall(humanoid) then
      if action.must_happen then 
        humanoid:finishAction()
      end
      return
    elseif humanoid.humanoid_class == "Handyman" then
      -- An idle handyman meandering in the corridor, check for nearby litter.
      local litter, x, y = humanoid.world:findObjectNear(humanoid, "litter", 6)
      if litter and x then
        humanoid:setNextAction{name = "walk", x = x, y = y}
        humanoid:queueAction{name = "sweep_floor", litter = litter}
        humanoid:queueAction{name = "meander"}
        return
      end
    else
      -- Nowhere to go, start going to the old room if it's still in
      -- need of staff.
      local room = humanoid.last_room
      if room and room.is_active
      and room:testStaffCriteria(room:getMaximumStaffCriteria(), humanoid) then
        humanoid:queueAction(room:createEnterAction(humanoid))
        humanoid:setDynamicInfoText(_S.dynamic_info.staff.actions.heading_for
        :format(room.room_info.name))
        humanoid:finishAction()
        return
      end
    end
    humanoid.last_room = nil
  end

  -- Just wandering around
  if humanoid.humanoid_class == "Doctor" or humanoid.humanoid_class == "Nurse" then
    if not room then
      humanoid:setDynamicInfoText(_S.dynamic_info.staff.actions.wandering)
    end
  end
  local x, y = humanoid.world.pathfinder:findIdleTile(humanoid.tile_x,
    humanoid.tile_y, math.random(1, 24))
  if x == humanoid.tile_x and y == humanoid.tile_y then
    -- Nowhere to walk to - go idle instead, or go onto the next action
    if #humanoid.action_queue == 1 then
      humanoid:queueAction{name = "idle"}
    end
    humanoid:finishAction()
    return
  end
  if action.todo_interrupt then
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
    if action ~= humanoid.action_queue[1] then
      return
    end
  end
  local procrastination
  if action.can_idle and math.random(1, 3) == 1 then
    procrastination = {name = "idle", count = math.random(25, 40)}
  else
    action.can_idle = true
    procrastination = {name = "walk", x = x, y = y}
  end
  procrastination.must_happen = action.must_happen
  humanoid:queueAction(procrastination, 0)
end

return meander_action_start
