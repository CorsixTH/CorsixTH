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

---@type Queue
local Queue = _G["Queue"]

--! Constructor of a queue.
function Queue:Queue()
  -- Number of real patients that can be observed in the door queue interface.
  self.reported_size = 0
  -- Expected humanoids
  self.expected = {}
  self.callbacks = {}
  -- Number of expected patients
  self.expected_count = 0
  self.visitor_count = 0
  -- Maximum queue length (default value)
  self.max_size = 6
  self.bench_threshold = 0
end

--! A humanoid is expected in a queue.
--!param humanoid - any humanoid expected for the room
--!param callback - register a callback for when queue is 'destroyed'
function Queue:expect(humanoid, callback)
  if not self.expected[humanoid] then
    self.expected[humanoid] = callback
    -- only count patients in the expected count
    if class.is(humanoid, Patient) then
      self.expected_count = self.expected_count + 1
    end
  end
end

--! A humanoid is canceled as expected in a queue.
--!param humanoid - Humanoid that is not coming to this queue.
function Queue:unexpect(humanoid)
  if self.expected[humanoid] then
    self.expected[humanoid] = nil
    -- only count patients in the expected count
    if class.is(humanoid, Patient) then
      self.expected_count = self.expected_count - 1
    end
  end
end

--! Lower the max queue length.
--!param amount (int) Decrement length value of the queue.
function Queue:decreaseMaxSize(amount)
  self.max_size = math.max(0, self.max_size - amount)
end

--! Increase max queue length.
--!param amount (int) Increment length value of the queue.
function Queue:increaseMaxSize(amount)
  self.max_size = math.min(30, self.max_size + amount)
end

function Queue:setBenchThreshold(standing_count)
  self.bench_threshold = standing_count
end

--! Set max queue length.
--!param queue_count (int) New max queue length to set.
function Queue:setMaxQueue(queue_count)
  self.max_size = queue_count
end

--! Total size of the queue, which are various people wanting in or out of the room.
--! For a true patient queue count, use Queue:reportedSize.
--!return (int) Number of various people in the queue.
function Queue:size()
  -- Remember, the size includes people waiting to leave and staff waiting to enter
  -- For just the patients waiting to be served, use Queue:reportedSize()
  -- Most of the time, size() == reportedSize(), so it won't be immediately obvious
  -- if you're using the wrong method, but from time to time, staff or exiting
  -- patients will be in the queue, at which point the sizes will differ.
  return #self
end

--! Retrieve whether the queue is full.
--!return (boolean) Whether the queue is full.
function Queue:isFull()
  return self:size() >= self.max_size
end

--! Get the number of real patients in the queue.
--!return (int) Number of real patients in the queue.
function Queue:reportedSize()
  return self.reported_size
end

--! Get the number of expected patients.
--!return (int) Number of expected patients (in the near future).
function Queue:expectedSize()
  return self.expected_count
end

--! Check if the queue has an emergency patient.
--!return (boolean) Whether an emergency patient was found in the queue.
function Queue:hasEmergencyPatient()
  for _, humanoid in ipairs(self) do
    if humanoid.is_emergency then
      return true
    end
  end
  return false
end

--! Retrieve the total number of queued and expected patients.
--return (int) Number of patients.
function Queue:patientSize()
  return self.reported_size + self.expected_count
end

--! Get the 'index' real patient.
--!param index (int) Index of the patient to retrieve (runs up to Queue:reportedSize).
--!return Patient at the queried point in the queue.
function Queue:reportedHumanoid(index)
  return self[self:size() - self.reported_size + index]
end

function Queue:setPriorityForSameRoom(entity)
  self.same_room_priority = entity
end

local function _isLeaving(queue, humanoid)
  return queue.same_room_priority and queue.same_room_priority:getRoom() == humanoid:getRoom()
end

--! Get queue priority for given humanoid
--! Humanoids with priority lower that 'reported_priority_threshold'
-- are not displayed in the door queue interface.
--!param queue (object) target Queue.
--!param humanoid (object) Humanoid for which we're asking the priority.
--return (int) priority. Lower value means more significant priority.
local function _getHumanoidQueuePriority(queue, humanoid)
  if _isLeaving(queue, humanoid) then
    -- If humanoid is leaving they have the highest priority
    -- To prevent cases like #873
    return 1
  elseif class.is(humanoid, Staff) then
    -- Next are staff members
    return 2
  elseif class.is(humanoid, Vip) or class.is(humanoid, Inspector) then
    -- Next is a Vip and other hospital guests.
    -- Who are served instantly and do not delay others.
    return 3
  elseif humanoid.is_emergency then
    -- Next are Emergency patients
    return 4
  else
    -- All other regular patients receive this priority
    return 5
  end
end

--! Determines whether Humanoid priority is sufficient
-- to display this Humanoid in door queue interface.
--!param priority (int) humanoid priority.
--return (bool) true if patient should be displayed.
local function _shouldDisplayInDoorQueueInterface(priority)
  local reported_priority_threshold = 3
  return priority > reported_priority_threshold
end

function Queue:push(humanoid, callbacks_on)
  local index = self:size() + 1
  local priority = _getHumanoidQueuePriority(self, humanoid)

  -- calculate under what 'index' we should insert new humanoid into the queue
  while index > 1 do
    -- Is the new humanoid's priority higher or equal to the current index's humanoid
    if _getHumanoidQueuePriority(self, self[index - 1]) <= priority then
      break
    end
    index = index - 1
  end

  if _shouldDisplayInDoorQueueInterface(priority) then
    self.reported_size = self.reported_size + 1
  end

  self.callbacks[humanoid] = callbacks_on
  table.insert(self, index, humanoid)
  for i = index + 1, self:size() do
    local queued_humanoid = self[i]
    local callbacks = self.callbacks[queued_humanoid]
    if callbacks then
      callbacks:onChangeQueuePosition(queued_humanoid)
    end
  end
end

--! Get the first person in the queue (queue is not changed).
--! Note that first person may not be a patient, use Queue:reportedHumanoid to get patients
--!return First person in the queue.
function Queue:front()
  return self[1]
end

--! Get the last person in the queue (queue is not changed).
--!return Last person in the queue.
function Queue:back()
  return self[self:size()]
end

--! Pop first person from the queue.
--! Note that first person may not be a patient, use Queue:reportedHumanoid to get patients
--!return First person in the queue.
function Queue:pop()
  if self.reported_size == self:size() then
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
    callbacks = self.callbacks[humanoid]
    if callbacks then
      callbacks:onChangeQueuePosition(humanoid)
    end
  end
  return oldfront
end

--! Remove person from the queue by index number.
--! Note that the person may not be a patient.
--!param index (jnt) Index in the queue of the person to remove.
--!return The removed person.
function Queue:remove(index)
  if self[index] == nil then
    return
  end
  local value = self[index]
  if index > self:size() - self.reported_size then
    self.reported_size = self.reported_size - 1
  end
  value:setMood("queue", "deactivate")
  table.remove(self, index)
  self.callbacks[value] = nil
  for i = self:size(), index, -1 do
    local humanoid = self[i]
    if humanoid.onAdvanceQueue then
      humanoid:onAdvanceQueue(self, i - 1)
    end
  end
  return value
end

--! Remove a person by value from the queue.
--!param value Person to remove.
--!return Whether the person could be found (and was removed).
function Queue:removeValue(value)
  for i = 1, self:size() do
    if self[i] == value then
      self:remove(i)
      return true
    end
  end
  return false
end

--! Move the person at position 'index' to position 'new_index'.
--! Persons between 'index' and 'new_index' move one place to 'index'.
--!param index (int) Index number of the person to move.
--!param new_index (int) Destination of the person being moved.
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

--! Move an entering patient in the queue at position 'index' to position 'new_index'.
--! Persons between 'index' and 'new_index' move one place to 'index'.
--! Values are relative to the reported humanoids in the queue
--!param index (int) Index number of the person to move.
--!param new_index (int) Destination of the person being moved.
--!param new_index (string) 'front' or 'back' as relative markers
function Queue:movePatient(index, new_index)
  local first_patient_index = self:size() - self:reportedSize() + 1
  if type(new_index) == "string" then
    if new_index == 'front' then
      new_index = first_patient_index
    else
      new_index = self:size()
    end
  else
    new_index = first_patient_index + new_index
  end
  self:move(first_patient_index + index - 1, new_index)
end

--! Called when reception desk is destroyed, or when a room is destroyed from a crashed machine.
--!param room_id Id of the room to reroute to, 'nil' for reception.
function Queue:rerouteAllPatients(room_id)
  for _, humanoid in ipairs(self) do
    -- check by class type as staff/vips shouldn't get a SeekRoomAction
    if class.is(humanoid, Patient) then
      -- slight delay so the desk is really destroyed before rerouting
      humanoid:setNextAction(IdleAction():setCount(1))

      local action
      if room_id then
        action = SeekRoomAction(room_id)
      else
        action = SeekReceptionAction()
      end
      humanoid:queueAction(action)

    elseif class.is(humanoid, Staff) then
      -- likewise believe we need action here to stop
      humanoid:setNextAction(IdleAction():setCount(1))
      humanoid:queueAction(MeanderAction())
    else
      -- other humanoids don't enter rooms
      humanoid:setNextAction(MeanderAction())
    end
  end
  for humanoid, callback in pairs(self.expected) do
    -- call the callback if registered as door is closing
    if callback then
      callback.callback()
    end
    self:unexpect(humanoid)
  end
end
