--[[ Copyright (c) 2010 Sam Wong

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

class "CallsDispatcher"

local debug = false -- Turn on for debug message

function CallsDispatcher:CallsDispatcher(world, entities)
  self.world = world
  self.call_queue = {}
  self.change_callback = {}
  self.tick = 0
end

function CallsDispatcher:onTick()
  self.tick = self.tick + 1
end

function CallsDispatcher:addChangeCallback(callback, self_value)
  self.change_callback[callback] = self_value
end

function CallsDispatcher:removeChangeCallback(callback)
  self.change_callback[callback] = nil
end

function CallsDispatcher:onChange()
  for callback, self_value in pairs(self.change_callback) do
    callback(self_value)
  end
end

function CallsDispatcher:callForStaff(room)
  local missing = room:getMissingStaff(room:getRequiredStaffCriteria())
  local anyone_missed = false
  for attribute, count in pairs(missing) do
    anyone_missed = true
    for i = 1, count do
      self:callForStaffEachRoom(room, attribute, attribute .. i)
    end    
  end
  local sound = room.room_info.call_sound
  if anyone_missed and sound and not room.sound_played then
    room.world.ui:playAnnouncement(sound)
    room.sound_played = true
  end
end

function CallsDispatcher:callForStaffEachRoom(room, attribute, key)
  if not key then
    key = "-"
  end
  local new_call = self:enqueue(
    room,
    key,
    _S.calls_dispatcher.staff:format(room.room_info.name, attribute),
    --[[persistable:call_dispatcher_staff_verification]] function(staff)
      return CallsDispatcher.verifyStaffForRoom(room, attribute, staff)
    end,
    --[[persistable:call_dispatcher_staff_priority]] function(staff)
      return CallsDispatcher.getPriorityForRoom(room, attribute, staff)
    end,
    --[[persistable:call_dispatcher_staff_execute]] function(staff)
      return CallsDispatcher.sendStaffToRoom(room, staff)
    end
  )
  return new_call
end

-- Call for repair
--!param urgent Announcement should be made
--!param manual This call should not trigger advisor for "your machine is failing"
--!param lock_room This is a minor maintence. Rooms needed not to be locked.
--  If urgent or manual is specified, lock_room will be true automatically
function CallsDispatcher:callForRepair(object, urgent, manual, lock_room)
  lock_room = manual or lock_room
  local new_call = self:enqueue(
    object,
    'repair',
    _S.calls_dispatcher.repair:format(object.object_type.name),
    --[[persistable:call_dispatcher_repair_verification]] function(staff)
      return CallsDispatcher.verifyStaffForRepair(object, staff)
    end,
    --[[persistable:call_dispatcher_repair_priority]] function(staff)
      return CallsDispatcher.getPriorityForRepair(object, staff)
    end,
    --[[persistable:call_dispatcher_repair_execute]] function(staff)
      return CallsDispatcher.sendStaffToRepair(object, staff)
    end
  )
  
  object:setRepairingMode(lock_room and true or false)
  local message
  local ui = object.world.ui
  if new_call then
    if not object.world:getLocalPlayerHospital():hasStaffOfCategory("Handyman") then
      -- Advise about hiring Handyman
      message = _S.adviser.warnings.machinery_damaged2
    end
  end
  
  if not manual and urgent then
    local room = object:getRoom();
    local sound = room.room_info.handyman_call_sound
    if sound then
      ui:playAnnouncement(sound)
      ui:playSound "machwarn.wav"
    end
    message = _S.adviser.warnings.machines_falling_apart
  end
  if message then
    ui.adviser:say(message)
  end
end

function CallsDispatcher:callForWatering(plant)
  return self:enqueue(
    plant,
    'watering',
    _S.calls_dispatcher.watering:format(plant.tile_x, plant.tile_y),
    --[[persistable:call_dispatcher_watering_verification]] function(staff)
      return CallsDispatcher.verifyStaffForWatering(plant, staff)
    end,
    --[[persistable:call_dispatcher_watering_priority]] function(staff)
      return CallsDispatcher.getPriorityForWatering(plant, staff)
    end,
    --[[persistable:call_dispatcher_watering_execute]] function(staff)
      return CallsDispatcher.sendStaffToWatering(plant, staff)
    end
  )
end

-- Enqueue the call
-- returns: True if the call is inserted and queued, but not served
--          False if the call is served right away, or has been queued and assigned
function CallsDispatcher:enqueue(object, key, description, verification, priority, execute)
  if self.call_queue[object] and self.call_queue[object][key] then
    -- already queued
    return self.call_queue[object][key].assigned and true or false
  elseif not self.call_queue[object] then
    self.call_queue[object] = {}
  end

  local call = {
    verification = verification,
    priority = priority,
    execute = execute,
    object = object,
    key = key,
    description = description,
    dispatcher = self,
    created = self.tick
  }
  self.call_queue[object][key] = call

  return not self:findSuitableStaff(call)
end

-- Find suitable (best) staff for working on a specific call
-- True 
function CallsDispatcher:findSuitableStaff(call)
  if call.dropped then 
    -- If a call was thought needed to be reinserted, but actually it was dropped...
    return
  end 

  -- TODO: Preempt staff those even on_call already.
  --       Say - when an machine broke down, preempt the nearby handyman for repairing 
  --         even if he was going to water a far away plant
  -- TODO: Doctor could go to other room with real needs, even there are patients queued up
  --       (think of emergency? or surgeons still in GP office?)
  local min_score = 2^30
  local min_staff = nil
  for _, e in ipairs(self.world.entities) do
    if class.is(e, Staff) then
      local score = call.verification(e) and call.priority(e) or nil
      if score ~= nil and score < min_score then
        min_score = score
        min_staff = e
      end
    end
  end

  if min_staff then
    if debug then CallsDispatcher.dumpCall(call, 'executed right away') end
    self:executeCall(call, min_staff)
    return true
  else
    if debug then CallsDispatcher.dumpCall(call, 'queued') self:dump(self.call_queue) end
    self:onChange()
    return false
  end
end

-- Find the best call for a staff to work on.
-- When a staff goes to meandering mode, it should call this function to look for new call
-- Return true if a call is answered. False if there is no suitable call waiting and the staff is really free.
function CallsDispatcher:answerCall(staff)
  local min_score = 2^30
  local min_call = nil
  local min_key = nil
  assert(not staff.on_call, "Staff should be idea before he can answer another call")

  -- Find the call with the highest priority (smaller means more urgency)
  --   if the staff satisfy the criteria
  for object, queue in pairs(self.call_queue) do
    for key, call in pairs(queue) do
      local score = call.verification(staff) and call.priority(staff) or nil
      if score ~= nil then
        if call.assigned then -- already being assigned? Can it be preempted?
          local another_score = call.priority(call.assigned)
          if another_score <= score then
            score = nil
          end
        end
        if score ~= nil and score < min_score then
          min_score = score
          min_call = call
          min_key = key
        end
      end
    end
  end

  if min_call then
    if debug then self:dump() CallsDispatcher.dumpCall(min_call, 'answered') end
    if min_call.assigned then 
      CallsDispatcher.unassignCall(min_call) 
    end
    -- Check if the object is still in the world, live and not destroy
    assert(min_call.object.tile_x or min_call.object.x, "An destroyed object still has requested in the dispatching queue. Please check the Entity:onDestroy function")
    self:executeCall(min_call, staff)
    return true
  end
  return false
end

-- Dump the current call table for debugging
function CallsDispatcher:dump()
  print("--- Queue ---")
  for object, queue in pairs(self.call_queue) do
    for key, call in pairs(queue) do
      CallsDispatcher.dumpCall(call, (call.assigned and 'assigned' or 'unassigned'))
    end
  end
  print("----")
end

function CallsDispatcher.dumpCall(call, message)
  if message ~= nil then
    message = ': ' .. message
  else
    message = ''
  end
  local position = 'nowhere'
  if call.object.tile_x then
    position = call.object.tile_x ..','..call.object.tile_y
  end
  if call.object.x then
    position = call.object.x ..','..call.object.y
  end
  print((call.object.room_info and call.object.room_info.id or call.object.object_type.id) .. '-' .. call.key .. 
    '@' .. position .. message)
end

-- Add checkpoint action
-- All call execution method should add this action in apporiate place to signify 
--   the job is finished.
-- A interrupt handler could be supplied if special handling is needed. 
-- If not, the default would be reinsert the call into the queue
function CallsDispatcher.queueCallCheckpointAction(humanoid, interrupt_handler)
  return humanoid:queueAction{
    name = "call_checkpoint", 
    call = humanoid.on_call, 
    on_remove = interrupt_handler or CallsDispatcher.actionInterruptHandler
  }
end

-- Default checkpoint interrupt handler
-- Reset the assigned status, and find an replacement staff
function CallsDispatcher.actionInterruptHandler(action, humanoid)
  if action.call.assigned == humanoid then
    action.call.assigned = nil
    humanoid.on_call = nil
    humanoid.world.dispatcher:findSuitableStaff(action.call)
  end
end

-- Called when a call is completed sucessfully
function CallsDispatcher.onCheckpointCompleted(call)
  if not call.dropped and call.assigned then
    if debug then CallsDispatcher.dumpCall(call, "completed") end
    call.assigned.on_call = nil
    call.assigned = nil
    call.dispatcher:dropFromQueue(call.object, call.key)
  end
end

function CallsDispatcher:executeCall(call, staff)
  assert(not call.assigned, "call to be executed is still assigned")
  assert(not call.dropped, "call to be executed is dropped")
  assert(not staff.on_call, "staff was on call and assigned to a new call")
  call.assigned = staff
  staff.on_call = call
  self:onChange()
  call.execute(staff)
end

-- Drop any call associated with the object (and/or key).
--
-- Expected to be called when the call is no longer needed 
--   (like a machine that needed repaired were replaced),
--   or when the object is destroyed, etc.
function CallsDispatcher:dropFromQueue(object, key)
  if debug then self:dump() end
  if key then
    local call = self.call_queue[object][key]
    if call then
      call.dropped = true
      if call.assigned then 
        CallsDispatcher.unassignCall(call)
      end
      self.call_queue[object][key] = nil
    end
  elseif self.call_queue[object] then
    for key, call in pairs(self.call_queue[object]) do
      call.dropped = true
      if call.assigned then
        CallsDispatcher.unassignCall(call)
      end
    end
    self.call_queue[object] = nil
  end
  self:onChange()
end

function CallsDispatcher.unassignCall(call)
  local assigned = call.assigned
  assert(assigned.on_call == call, "Unassigning call but the staff was not on call or a different call")
  call.assigned = nil
  assigned.on_call = nil
  assigned:setNextAction{name = "answer_call"}
end

function CallsDispatcher.verifyStaffForRoom(room, attribute, staff)
  if staff:isIdle() and staff:fulfillsCriterium(attribute) then
    local current_room = staff:getRoom()
    if not staff.hospital.policies["staff_allowed_to_move"]
    and current_room and current_room ~= room then
      return false
    end
    return true
  end
  return false
end

function CallsDispatcher.getPriorityForRoom(room, attribute, staff)
  local score = 0;
  local x, y = room:getEntranceXY()
  
  -- Doctor prefer serving nearby rooms
  local distance = room.world:getPathDistance(staff.tile_x, staff.tile_y, x, y);
  if distance then
    score = score + distance
  end

  -- More people on the queue has to be served eariler
  if room.door.queue then
    score = score - room.door.queue:reportedSize() * 5 -- 5 is just a weighting scale
    if room.door.queue:hasEmergencyPatient() then
      score = score - 200000 -- Emergency on queue trumps
    end
  end

  -- Prefer the tirer staff (such that less chance to have "resting sychronization issue")
  score = score - staff.attributes["fatigue"] * 40 -- 40 is just a weighting scale

  -- TODO: Assign doctor with higher ability

  -- Room requires specilitist trumps over normal rooms
  if attribute == "Researcher" or attribute == "Psychiatrist" or attribute == "Surgeon" then
    score = score - 100000
  end

  return score
end

function CallsDispatcher.sendStaffToRoom(room, staff)
  if staff:getRoom() == room then
    room:onHumanoidLeave(staff)
    CallsDispatcher.queueCallCheckpointAction(staff, CallsDispatcher.staffActionInterruptHandler)  
    room:onHumanoidEnter(staff)
  else
    staff:setNextAction(room:createEnterAction(staff))
    CallsDispatcher.queueCallCheckpointAction(staff, CallsDispatcher.staffActionInterruptHandler)  
  end
  staff:setDynamicInfoText(_S.dynamic_info.staff.actions.heading_for:format(room.room_info.name))
end

function CallsDispatcher.staffActionInterruptHandler(action, humanoid, high_priority)
  if action.call.assigned == humanoid then
    action.call.assigned = nil
    humanoid.on_call = nil
    if not action.call.dropped then
      humanoid.world.dispatcher:callForStaff(action.call.object)
    end
  end
end

function CallsDispatcher.verifyStaffForRepair(object, staff)
  if staff:isIdle() and staff:fulfillsCriterium("Handyman") then
    return true
  end
  return false
end

function CallsDispatcher.getPriorityForRepair(object, staff)
  local score = 0;
  local x, y = object:getRepairTile()
  
  -- Handyman prefer serving nearby machines
  local distance = object.world:getPathDistance(staff.tile_x, staff.tile_y, x, y);
  if distance then
    score = score + distance
  end

  local object_room = object:getRoom()
  local staff_room = staff:getRoom()
  if object_room and object_room == staff_room then
    -- In the room already? Great
    score = score - 10000
  end

  -- Object with less strength should be served eariler
  -- Design: Boost the priority from 0..50 on average.
  --   ^ 2: power scale
  --   * 70: If the machine is about to explode (at 85% usage), cost reduced by ~50
  --   * 3: Each handyman has 3 assigned tasks...
  --   * 3: Boost the score, machine repairing is more important than watering
  score = score - (math.max(object.times_used / object.strength, object.repairing and 0.85 or 0)) ^ 2 * 70 * 
    staff.attributes["repairing"] * 3 * 3

  return score
end

function CallsDispatcher.sendStaffToRepair(object, handyman)
  object:createHandymanActions(handyman)
end

function CallsDispatcher.verifyStaffForWatering(plant, staff)
  if staff:isIdle() and staff:fulfillsCriterium("Handyman") then
    return true
  end
  return false
end

function CallsDispatcher.getPriorityForWatering(plant, staff)
  local score = 0;
  local x, y = plant:getWateringTile()
  
  -- Handyman prefer serving nearby plants
  local distance = plant.world:getPathDistance(staff.tile_x, staff.tile_y, x, y);
  if distance then
    score = score + distance
  end

  local object_room = plant:getRoom()
  local staff_room = staff:getRoom()
  if object_room and object_room == staff_room then
    -- In the room already? Great
    score = score - 10000
  end

  -- Dying plant should be served earlier
  -- Design: Boost the priority from 0..50 on average.
  --   ^ 2: power scale
  --   * 50: State is 0 to 5. cost reduced by ~50 at most.
  --   * 3: Each handyman has 3 assigned tasks...
  score = score - (plant.current_state / 5) ^ 2 * 50 * staff.attributes["watering"] * 3

  return score
end

function CallsDispatcher.sendStaffToWatering(plant, handyman)
  plant:createHandymanActions(handyman)
end
