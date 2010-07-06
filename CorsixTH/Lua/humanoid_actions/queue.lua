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

--! Keep a `Humanoid` amused whilst they wait for a `Room` or `Object`
-- to become available for use.
class "QueueAction" {} (Action)

--!param ... Arguments for the base class constructor.
function QueueAction:QueueAction(...)
  self:Action(...)
end

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

function QueueAction:findIndexInQueue()
  local index = 1
  local queue = self.humanoid.action_queue
  while queue[index] do
    if queue[index] == self then
      return index
    end
    index = index + 1
  end
  error "Queue action not in action_queue"
end

local function insert_into_queue(humanoid, index, action, ...)
  if action then
    humanoid:queueAction(action, index)
    return insert_into_queue(humanoid, index + 1, ...)
  end
end

function QueueAction:setProcrastination(...)
  local action_index = self:findIndexInQueue() - 1
  -- This new procrastination will cancel any existing bench visit (unless it
  -- is a bench visit, in which case current_bench_distance will be set by the
  -- caller after this call).
  self.current_bench_distance = nil
  -- Insert new procrastination
  insert_into_queue(self.humanoid, action_index, ...)
  -- Cancel old procrastination
  self.humanoid:cancelActions(1, action_index)
end

function QueueAction:nudge()
  self:onChangeQueuePosition()
end

function QueueAction:onChangeQueuePosition()
  local action = self
  local humanoid = self.humanoid
  if not self.is_in_queue or self.postponed then
    return
  end

  -- Find out if we have to be standing up
  local must_stand = class.is(humanoid, Staff)
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
      bench_max_distance = 16
    else
      bench_max_distance = action.current_bench_distance / 2
    end
    local bench, bx, by, dist = humanoid.world:getFreeBench(action.x, action.y, bench_max_distance)
    if bench then
      self:setProcrastination(
        WalkAction {
          x = bx,
          y = by,
          postponable = false,
        },
        UseObjectAction {
          object = bench,
        }
      )
      self.current_bench_distance = dist
      self.is_sitting = true
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
  self:setProcrastination(
    WalkAction {
      x = ix,
      y = iy,
      postponable = false,
    },
    IdleAction {
      direction = get_direction(ix, iy, facing_x, facing_y),
    }
  )
end

function QueueAction:isStanding()
  return not self.current_bench_distance
end

function QueueAction:onLeaveQueue()
  local action = self
  local humanoid = self.humanoid
  if not action.is_in_queue then
    return
  end
  action.is_in_queue = false
  if action.reserve_when_done then
    action.reserve_when_done.reserved_for = humanoid
    action.reserve_when_done = nil
  end
  humanoid:cancelActions(1, self:findIndexInQueue()) 
end

-- While queueing one could get thirsty.
function QueueAction:postponeFor(action, index_in_queue)
  if self.is_in_queue then
    self.postponed = true
    self:setProcrastination(action)
    --machine:addReservedUser(humanoid)
  else
    self.humanoid:queueAction(action, index_in_queue - 1)
  end
  return true
end

function QueueAction:onRemoveFromQueue()
  local action = self
  local humanoid = self.humanoid
  
  if action.reserve_when_done then
    if action.reserve_when_done.reserved_for == humanoid then
      action.reserve_when_done.reserved_for = nil
    end
  end
  if action.is_in_queue then
    action.is_in_queue = false
    action.queue:removeValue(humanoid)
  end
  
  Action.onRemoveFromQueue(self)
end

function QueueAction:onStart()
  Action.onStart(self)
  
  local action = self
  local humanoid = self.humanoid
  local queue = action.queue
  
  self.postponed = false
  if action.done_init then
    self:onChangeQueuePosition()
    return
  end
  action.done_init = true
  
  action.is_in_queue = true
  queue:unexpect(humanoid)
  queue:push(humanoid, action)
  
  local door = action.reserve_when_done
  if door then
    door:updateDynamicInfo()
    humanoid:updateDynamicInfo(_S.dynamic_info.patient.actions.queueing_for:format(door.room.room_info.name))
    -- Make another call for staff just in case.
    humanoid.world:callForStaff(door.room)
  end
  action:onChangeQueuePosition()
  
  if queue.same_room_priority then
    queue.same_room_priority:getRoom():tryAdvanceQueue()
  end
end
