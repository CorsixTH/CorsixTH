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

--! Manages a list of `Humanoid`s which are waiting to use an `Object`.
--! A queue stores a list of humanoids waiting to use an object.
-- For a reception desk, this is as expected.
-- For a room, the queue is for the door, not the room. Hence the queue stores
-- the list of patients waiting to enter (the traditional queue for the room),
-- the list of staff waiting to enter (because of the door being in use for
-- example), the list of staff and patients waiting to leave (again due to door
-- being in use).
-- Queues are currently implemented as normal Lua arrays, but you should access
-- a queue via its methods rather than directly.
class "Queue"

function Queue:Queue()
  self.reported_size = 0
  self.expected = {}
  self.callbacks = {}
  self.expected_count = 0
  self.visitor_count = 0
  self.max_size = 6
  self.bench_threshold = 0
end

function Queue:expect(humanoid)
  if not self.expected[humanoid] then
    self.expected[humanoid] = true
    self.expected_count = self.expected_count + 1
  end
end

function Queue:unexpect(humanoid)
  if self.expected[humanoid] then
    self.expected[humanoid] = nil
    self.expected_count = self.expected_count - 1
  end
end

function Queue:decreaseMaxSize(amount)
  self.max_size = math.max(0, self.max_size - amount)
end

function Queue:increaseMaxSize(amount)
  self.max_size = math.min(30, self.max_size + amount)
end

function Queue:setBenchThreshold(standing_count)
  self.bench_threshold = standing_count
end

function Queue:setMaxQueue(queue_count)
  self.max_size = queue_count
end

function Queue:size()
  -- Rememeber, the size includes people waiting to leave and staff waiting to enter
  -- For just the patients waiting to enter, use Queue:reportedSize()
  -- Most of the time, size() == reportedSize(), so it won't be immediately obvious
  -- if you're using the wrong method, but from time to time, staff or exiting
  -- patients will be in the queue, at which point the sizes will differ.
  return #self
end

function Queue:isFull()
  return #self >= self.max_size
end

function Queue:reportedSize()
  return self.reported_size
end

function Queue:expectedSize()
  return self.expected_count
end

function Queue:hasEmergencyPatient()
  local index = #self
  for i, humanoid in ipairs(self) do
    if humanoid.is_emergency then
      return true
    end
  end
  return false
end

-- Returns how many patients are queued or expected
function Queue:patientSize()
  return self.reported_size + self.expected_count
end


function Queue:reportedHumanoid(index)
  return self[#self - self.reported_size + index]
end

function Queue:setPriorityForSameRoom(entity)
  self.same_room_priority = entity
end

function Queue:push(humanoid, callbacks_on)
  local index = #self + 1
  local increment_reported_size = true
  if self.same_room_priority then
    -- If humanoid in the priority room, then position them in the queue before
    -- humanoids not in the room (because if they are in the room and in the
    -- queue, then they are trying to leave the room).
    local room = self.same_room_priority:getRoom()
    if humanoid:getRoom() == room then
      while index > 1 do
        local before = self[index - 1]
        if before:getRoom() == room then
          break
        end
        index = index - 1
      end
      increment_reported_size = false
    end
  end
  if class.is(humanoid, Staff) then
    -- Give staff priority over patients
    while index > 1 do
      local before = self[index - 1]
      if class.is(before, Staff) then
        break
      end
      index = index - 1
    end
    increment_reported_size = false
  end
  if humanoid.is_emergency then -- Emergencies get put before all the other patients, but AFTER currently queued emergencies.
    while index > 1 do
      local before = self[index - 1]
      if before.is_emergency then
        break
      end
      index = index - 1
    end
  end
  if increment_reported_size then
    self.reported_size = self.reported_size + 1
  end
  self.callbacks[humanoid] = callbacks_on
  table.insert(self, index, humanoid)
  for i = index + 1, #self do
    local humanoid = self[i]
    local callbacks = self.callbacks[humanoid]
    if callbacks then
      callbacks:onChangeQueuePosition(humanoid)
    end
  end
end

function Queue:front()
  return self[1]
end

function Queue:back()
  return self[#self]
end

function Queue:pop()
  if self.reported_size == #self then
    self.reported_size = self.reported_size - 1
  end
  local oldfront = self[1]
  table.remove(self, 1)
  oldfront:setMood("queue", "deactivate")
  local callbacks = self.callbacks[oldfront]
  if callbacks then
    callbacks:onLeaveQueue(oldfront)
  end
  self.callbacks[oldfront] = nil
  for _, humanoid in ipairs(self) do
    local callbacks = self.callbacks[humanoid]
    if callbacks then
      callbacks:onChangeQueuePosition(humanoid)
    end
  end
  return oldfront
end

function Queue:remove(index)
  if self[index] == nil then
    return
  end
  local value = self[index]
  if index > #self - self.reported_size then
    self.reported_size = self.reported_size - 1
  end
  value:setMood("queue", "deactivate")
  table.remove(self, index)
  self.callbacks[value] = nil
  for i = #self, index, -1 do
    local humanoid = self[i]
    if humanoid.onAdvanceQueue then
      humanoid:onAdvanceQueue(self, i - 1)
    end
  end
  return value
end

function Queue:removeValue(value)
  for i = 1, #self do
    if self[i] == value then
      self:remove(i)
      return true
    end
  end
  return false
end

function Queue:move(index, new_index)
  if self[index] == nil or self[new_index] == nil or index == new_index then
    return
  end

  local i
  if new_index < index then
    i = -1
  else
    i = 1
  end

  while new_index ~= index do
    local temp = self[index + i]
    self[index + i] = self[index]
    self[index] = temp
    index = index + i
  end
end

-- Called when reception desk is destroyed. May be extended later to handle removed rooms, too.
-- Update: Now also used when a room is destroyed from a crashed machine.
function Queue:rerouteAllPatients(action)
  for i, humanoid in ipairs(self) do
    -- slight delay so the desk is really destroyed before rerouting
    humanoid:setNextAction({name = "idle", count = 1})
    -- Don't queue the same action table, but clone it for each patient.
    local clone = {} 
    for k, v in pairs(action) do clone[k] = v end
    humanoid:queueAction(clone)
  end
  for humanoid in pairs(self.expected) do
    humanoid:setNextAction({name = "idle", count = 1})
    humanoid:queueAction(action)
    self:unexpect(humanoid)
  end
end
