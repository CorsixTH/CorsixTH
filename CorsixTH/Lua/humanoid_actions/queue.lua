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

local function get_direction(x, y, facing_x, facing_y)
  if facing_y < y then
    return "north"
  elseif facing_y > y then
    return "south"
  end
  if facing_x > x then
    return "east"
  elseif facing_x < x then
    return "west"
  end
end

local function interrupt_head(humanoid, n)
  while n > 1 do
    local action = humanoid.action_queue[n]
    if action.name == "use_object" then
      -- Pull object usages out of the queue
      if action.object and action.object.reserved_for == humanoid then
        action.object.reserved_for = nil
      end
      table.remove(humanoid.action_queue, n)
    else
      -- Mark other actions as needing interruption
      assert(action.must_happen)
      action.todo_interrupt = true
    end
    n = n - 1
  end
  
  local action = humanoid.action_queue[n]
  assert(action.must_happen)
  local on_interrupt = action.on_interrupt
  if on_interrupt then
    action.on_interrupt = nil
    on_interrupt(action, humanoid)
  end
end

local function action_queue_leave_bench(action, humanoid)
  local index
  for i, current_action in ipairs(humanoid.action_queue) do
    assert(current_action ~= action)
    if current_action.name == "use_object" then
      if humanoid.action_queue[i + 1] == action then
        interrupt_head(humanoid, i)
        index = i
        break
      end
    end
  end
  index = index + 1
  while true do
    local current_action = humanoid.action_queue[index]
    if current_action == action then
      return index - 1
    end
    index = index - 1
  end
  error "Queue action not in action_queue"
end

local function action_queue_find_idle(action, humanoid)
  local found_any = false
  for i, current_action in ipairs(humanoid.action_queue) do
    if current_action.name == "idle" then
      found_any = true
      if humanoid.action_queue[i + 1] == action then
        return i
      end
    end
  end
  if found_any then
    error "Proper idle not in action_queue"
  else
    error "Idle not in action_queue"
  end
end

local function action_queue_finish_standing(action, humanoid)
  local index = action_queue_find_idle(action, humanoid)
  interrupt_head(humanoid, index)
  index = index + 1
  while true do
    local current_action = humanoid.action_queue[index]
    if current_action == action then
      return index - 1
    end
    index = index - 1
  end
  error "Queue action not in action_queue"
end

local action_queue_on_change_position = permanent"action_queue_on_change_position"( function(action, humanoid)
  -- Find out if we have to be standing up
  local must_stand = class.is(humanoid, Staff) or (humanoid.disease and humanoid.disease.must_stand)
  local queue = action.queue
  if not must_stand then
    for i = 1, queue.bench_threshold do
      if queue[i] == humanoid then
        must_stand = true
        break
      end
    end
  end
  
  if not must_stand then
    -- Try to find a bench
    local bench_max_distance
    if action:isStanding() then
      bench_max_distance = 10
    else
      bench_max_distance = action.current_bench_distance / 2
    end
    local bench, bx, by, dist = humanoid.world:getFreeBench(action.x, action.y, bench_max_distance)
    if bench then
      local num_actions_prior
      if action:isStanding() then
        num_actions_prior = action_queue_finish_standing(action, humanoid)
      else
        num_actions_prior = action_queue_leave_bench(action, humanoid)
      end
      action.current_bench_distance = dist
      humanoid:queueAction({
        name = "walk",
        x = bx,
        y = by,
        must_happen = true,
      }, num_actions_prior)
      humanoid:queueAction({
        name = "use_object",
        object = bench,
        must_happen = true,
      }, num_actions_prior + 1)
      bench.reserved_for = humanoid
      return
    elseif not action:isStanding() then
      -- Already sitting down, so nothing to do.
      return
    end
  end
  
  -- Stand up in the correct position in the queue
  local standing_index = 0
  local our_room = humanoid:getRoom()
  for i, person in ipairs(queue) do
    if person == humanoid then
      break
    end
    if queue.callbacks[person]:isStanding() and person:getRoom() == our_room then
      standing_index = standing_index + 1
    end
  end
  local ix, iy = humanoid.world:getIdleTile(action.x, action.y, standing_index)
  assert(ix and iy)
  local facing_x, facing_y
  if standing_index == 0 then
    facing_x, facing_y = action.face_x or action.x, action.face_y or action.y
  else
    facing_x, facing_y = humanoid.world:getIdleTile(action.x, action.y, standing_index - 1)
  end
  assert(facing_x and facing_y)
  local idle_direction = get_direction(ix, iy, facing_x, facing_y)
  if action:isStanding() then
    local idle_index = action_queue_find_idle(action, humanoid)
    humanoid.action_queue[idle_index].direction = idle_direction
    humanoid:queueAction({
      name = "walk",
      x = ix,
      y = iy,
      must_happen = true,
    }, idle_index - 1)
  else
    action.current_bench_distance = nil
    local num_actions_prior = action_queue_leave_bench(action, humanoid)
    humanoid:queueAction({
      name = "walk",
      x = ix,
      y = iy,
      must_happen = true,
    }, num_actions_prior)
    humanoid:queueAction({
      name = "idle",
      direction = idle_direction,
      must_happen = true,
    }, num_actions_prior + 1)
  end
end)

local action_queue_is_standing = permanent"action_queue_is_standing"( function(action)
  return not action.current_bench_distance
end)

local action_queue_on_leave = permanent"action_queue_on_leave"( function(action, humanoid)
  action.is_in_queue = false
  if action.reserve_when_done then
    action.reserve_when_done.reserved_for = humanoid
  end
  for i, current_action in ipairs(humanoid.action_queue) do
    if current_action == action then
      interrupt_head(humanoid, i)
      return
    end
  end
  error "Queue action not in action_queue"
end)

-- While queueing one could get thirsty.
local action_queue_get_soda = permanent"action_queue_get_soda"( 
function(action, humanoid, machine, mx, my, fun_after_use)
  local num_actions_prior
  if action:isStanding() then
    num_actions_prior = action_queue_finish_standing(action, humanoid)
  else
    num_actions_prior = action_queue_leave_bench(action, humanoid)
  end
  
  -- Callback function used after the drinks machine has been used.
  local --[[persistable:action_queue_get_soda_after_use]] function after_use()
    fun_after_use() -- Defined in patient:tickDay
    action_queue_on_change_position(action, humanoid)
  end
  
  -- Walk to the machine and then use it.
  humanoid:queueAction({
    name = "walk",
    x = mx,
    y = my,
    must_happen = true,
  }, num_actions_prior)
  humanoid:queueAction({
    name = "use_object",
    object = machine,
    after_use = after_use,
    must_happen = true,
  }, num_actions_prior + 1)
  machine:addReservedUser(humanoid)
  -- Insert an idle action so that change_position can do its work.
  humanoid:queueAction({
      name = "idle", 
      direction = machine.direction,
      must_happen = true,
    }, num_actions_prior + 2)
  -- Make sure noone thinks we're sitting down anymore.
  action.current_bench_distance = nil
end)

local action_queue_interrupt = permanent"action_queue_interrupt"( function(action, humanoid)
  if action.is_in_queue then
    action.queue:removeValue(humanoid)
    if action.reserve_when_done then
      action.reserve_when_done:updateDynamicInfo()
    end
  end
  if action.reserve_when_done then
    if action.reserve_when_done.reserved_for == humanoid then
      action.reserve_when_done.reserved_for = nil
    end
  end
  humanoid:finishAction()
end)

local function action_queue_start(action, humanoid)
  local queue = action.queue
  
  if action.done_init then
    return
  end
  action.done_init = true
  action.must_happen = true
  action.on_interrupt = action_queue_interrupt
  action.onChangeQueuePosition = action_queue_on_change_position
  action.onLeaveQueue = action_queue_on_leave
  action.onGetSoda = action_queue_get_soda
  action.isStanding = action_queue_is_standing
  
  action.is_in_queue = true
  queue:unexpect(humanoid)
  queue:push(humanoid, action)
  
  local door = action.reserve_when_done
  if door then
    door:updateDynamicInfo()
    if class.is(humanoid, Patient) then
      humanoid:updateDynamicInfo(_S.dynamic_info.patient.actions.queueing_for:format(door.room.room_info.name))
      -- Make another call for staff just in case.
      humanoid.world.dispatcher:callForStaff(door.room)
    end
  end
  humanoid:queueAction({
    name = "idle",
    must_happen = true,
  }, 0)
  action:onChangeQueuePosition(humanoid)
  
  if queue.same_room_priority then
    queue.same_room_priority:getRoom():tryAdvanceQueue()
  end
end

return action_queue_start
