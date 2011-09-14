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

local TH = require "TH" 

class "Room"

function Room:Room(x, y, w, h, id, room_info, world, hospital, door, door2)
  self.id = id
  self.world = world
  self.hospital = hospital
  
  self.room_info = room_info
  self:initRoom(x, y, w, h, door, door2)
end

function Room:initRoom(x, y, w, h, door, door2)
  self.x = x
  self.y = y
  self.width = w
  self.height = h
  self.maximum_patients = 1 -- A good default for most rooms
  door.room = self
  self.door = door
  -- If it's a swing door we have two doors
  self.door2 = door2
  door:setDynamicInfo('text', {
    self.room_info.name, 
    _S.dynamic_info.object.queue_size:format(0), 
    _S.dynamic_info.object.queue_expected:format(0)
  })
  self.built = false
  self.crashed = false
  
  self.world.map.th:markRoom(x, y, w, h, self.room_info.floor_tile, self.id)
  
  self.humanoids = {--[[a set rather than a list]]}
  self.objects = {--[[a set rather than a list]]}
end

function Room:getEntranceXY(inside)
  local door = self.door
  local x, y = door.tile_x, door.tile_y
  if (inside and self.world:getRoom(x, y) ~= self) or (not inside and self.world:getRoom(x, y) == self) then
    if door.direction == "north" then
      y = y - 1
    elseif door.direction == "west" then
      x = x - 1
    end
  end
  return x, y
end

function Room:createLeaveAction()
  local x, y = self:getEntranceXY(false)
  return {
    name = "walk",
    x = x,
    y = y,
    is_leaving = true,
    truncate_only_on_high_priority = true,
  }
end

function Room:createEnterAction(humanoid_entering)
  local x, y = self:getEntranceXY(true)
  return {name = "walk", x = x, y = y, 
    is_entering = humanoid_entering and self or true}
end

function Room:getPatient()
  for humanoid in pairs(self.humanoids) do
    if class.is(humanoid, Patient) then
      return humanoid
    end
  end
end

function Room:getPatientCount()
  local count = 0
  for humanoid in pairs(self.humanoids) do
    if class.is(humanoid, Patient) then
      count = count + 1
    end
  end
  return count
end

function Room:dealtWithPatient(patient)
  patient = patient or self:getPatient()
  -- If the patient was sent home while in the room, don't
  -- do anything apart from removing any leading idle action.
  if not patient.hospital then
    if patient.action_queue[1].name == "idle" then
      patient:finishAction()
    end
    return
  end
  patient:setNextAction(self:createLeaveAction())
  patient:addToTreatmentHistory(self.room_info)

  if patient.disease and not patient.diagnosed then
    -- Patient not yet diagnosed, hence just been in a diagnosis room.
    -- Increment diagnosis_progress, and send patient back to GP.

    patient:completeDiagnosticStep(self) 
    patient:queueAction{name = "seek_room", room_type = "gp"}
    self.hospital:receiveMoneyForTreatment(patient)
  elseif patient.disease and patient.diagnosed then
    -- Patient just been in a cure room, so either patient now cured, or needs
    -- to move onto next cure room.
    patient.cure_rooms_visited = patient.cure_rooms_visited + 1
    local next_room = patient.disease.treatment_rooms[patient.cure_rooms_visited + 1]
    if next_room then
      -- Do not say that it is a treatment room here, since that check should already have been made.
      patient:queueAction{name = "seek_room", room_type = next_room}
    else
      -- Patient is "done" at the hospital
      patient:treated()
    end
  else
    patient:queueAction{name = "meander", count = 2}
    patient:queueAction{name = "idle"}
  end

  -- The staff member(s) might be needed somewhere else.
  self:findWorkForStaff()
end

--! Checks if the room still needs the staff in it and otherwise 
-- sends them away if they're needed somewhere else.
function Room:findWorkForStaff()
  -- It the the staff member is idle we can send him/her somewhere else
  for humanoid in pairs(self.humanoids) do
    -- Don't check handymen
    if class.is(humanoid, Staff) and humanoid.humanoid_class ~= "Handyman" and humanoid:isIdle() then
      self.world.dispatcher:answerCall(humanoid)
    end
  end
end

local profile_attributes = {
  Psychiatrist = "is_psychiatrist",
  Surgeon = "is_surgeon",
  Researcher = "is_researcher",
}

-- Given any type of staff criteria (required/maximum), subtract the staff in the room and return the result
function Room:getMissingStaff(criteria)
  local result = {}
  for attribute, count in pairs(criteria) do
    for humanoid in pairs(self.humanoids) do
      if class.is(humanoid, Staff) and humanoid:fulfillsCriterium(attribute) and not humanoid:isLeaving() then
        count = count - 1
      end
    end
    if count <= 0 then
      count = nil
    end
    result[attribute] = count
  end
  return result
end

function Room:testStaffCriteria(criteria, extra_humanoid)
  -- criteria should be required_staff or maximum_staff table.
  -- if extra_humanoid is nil, then returns true if the humanoids in the room
  -- meet the given criteria, and false otherwise.
  -- if extra_humanoid is not nil, then returns true if the given humanoid
  -- would assist in satisfying the given criteria, and false if they would not.
  local missing = self:getMissingStaff(criteria)
  
  if extra_humanoid then
    local class = extra_humanoid.humanoid_class
    if class == "Surgeon" then
      class = "Doctor"
    end
    if missing[class] then
      return true
    end
    if class == "Doctor" then
      -- check for special proficiencies
      for attribute, profile_attribute in pairs(profile_attributes) do
        if extra_humanoid.profile and extra_humanoid.profile[profile_attribute] == 1.0 and missing[attribute] then
          return true
        end
      end
    end
    return false
  else
    for attribute, count in pairs(missing) do
      return false
    end
    return true
  end
end

local no_staff = {}
function Room:getMaximumStaffCriteria()
  -- Some rooms have dynamic criteria (i.e. dependent upon the number of items
  -- in the room), so this method is provided for such rooms to override it.
  return self.room_info.maximum_staff or self.room_info.required_staff or no_staff
end

function Room:getRequiredStaffCriteria()
  return self.room_info.required_staff or no_staff
end

function Room:onHumanoidEnter(humanoid)
  assert(not self.humanoids[humanoid], "Humanoid entering a room that they are already in")
  humanoid.in_room = self
  humanoid.last_room = self -- Remember where the staff was for them to come back after staffroom rest
  -- Do not set humanoids[humanoid] here, because it affect staffFitsInRoom test
  
  -- If this humanoid for some strange reason happens to enter a non-active room,
  -- just leave.
  if not self.is_active then
    if class.is(humanoid, Patient) then
        self:makePatientLeave(humanoid)
        humanoid:queueAction({name = "seek_room", room_type = self.room_info.id})
      else
        humanoid:setNextAction(self:createLeaveAction())
        humanoid:queueAction({name = "meander"})
      end
  end
  if humanoid.humanoid_class == "Handyman" then
    -- Handymen can always enter a room (to repair stuff, water plants, etc.)
    self.humanoids[humanoid] = true
    -- Check for machines which need repair or plants which need watering if
    -- the handyman didn't arrive as a part of a job
    if humanoid.on_call then
      assert(humanoid.on_call.object:getRoom() == self, "Handyman arrived is on call but not arriving to the designated room")
    else      
      -- If the handyman was not assigned for the job (e.g. drop by manual pickup), do answer a call
      humanoid:setNextAction{name = "answer_call"}
    end
    return
  end
  if class.is(humanoid, Staff) then
    -- If the room is already full of staff, or the staff member isn't relevant
    -- to the room, then make them leave. Otherwise, take control of them.
    if not self:staffFitsInRoom(humanoid) then
      self.humanoids[humanoid] = true
      humanoid:setNextAction(self:createLeaveAction())
      humanoid:queueAction{name = "meander"}
    else
      self.humanoids[humanoid] = true
      humanoid:setCallCompleted()
      self:commandEnteringStaff(humanoid)
    end
    self:tryAdvanceQueue()
    return
  end
  self.humanoids[humanoid] = true
  self:tryAdvanceQueue()
  if class.is(humanoid, Patient) then
    -- Check if the staff requirements are still fulfilled (the staff might have left / been picked up meanwhile)
    if self:testStaffCriteria(self:getRequiredStaffCriteria()) then
      self:commandEnteringPatient(humanoid)
    else
      humanoid:setNextAction(self:createLeaveAction())
      humanoid:queueAction(self:createEnterAction())
    end
  end
end

-- Returns false if the room is already full of staff or if the given member of staff cannot help out.
-- Otherwise returns true.
function Room:staffFitsInRoom(staff)
  local criteria = self:getMaximumStaffCriteria()
  if self:testStaffCriteria(criteria) or not self:testStaffCriteria(criteria, staff) then
    return false
  end
  return true
end

-- Tests whether this room is awaiting more staff to be able to do business
function Room:isWaitingToGetStaff(staff)
  if not self.is_active or (self.door.queue:patientSize() == 0 
  and not (self.door.reserved_for and class.is(self.door.reserved_for, Patient) or false)) then
    return false
  end
  return self:staffFitsInRoom(staff, true)
end

function Room:commandEnteringStaff(humanoid)
  -- To be extended in derived classes
  self:tryToFindNearbyPatients()
  humanoid:setDynamicInfoText("")
  -- This variable is used to avoid multiple calls for staff (sound played only)
  self.sound_played = nil
  if self:testStaffCriteria(self:getRequiredStaffCriteria()) then
    self.world.dispatcher:dropFromQueue(self)
  end
end

function Room:commandEnteringPatient(humanoid)
  -- To be extended in derived classes
  self.door.queue.visitor_count = self.door.queue.visitor_count + 1
  humanoid:updateDynamicInfo("")
  
  for humanoid in pairs(self.humanoids) do -- Staff is no longer waiting
    if class.is(humanoid, Staff) then
      if humanoid.humanoid_class ~= "Handyman" then
        humanoid:setMood("staff_wait", "deactivate")
        humanoid:setDynamicInfoText("")
      end
    end
  end
end

function Room:tryAdvanceQueue()
  if self.door.queue:size() > 0 and not self.door.user 
  and not self.door.reserved_for then
    local front = self.door.queue:front()
    -- These two conditions differ by the waiting symbol
    
    if self:canHumanoidEnter(front) then
      self.door.queue:pop()
      self.door:updateDynamicInfo()
      -- Do nothing if it is the staff room or training room.
      if self:hasQueueDialog() then
        for humanoid in pairs(self.humanoids) do -- Staff is now waiting
          if class.is(humanoid, Staff) then
            if humanoid.humanoid_class ~= "Handyman" then
              humanoid:setMood("staff_wait", "activate")
              humanoid:setDynamicInfoText(_S.dynamic_info.staff.actions.waiting_for_patient)
            end
          end
        end
      end
    elseif self.humanoids[front] then
      self.door.queue:pop()
      self.door:updateDynamicInfo()
    end
  end
end

function Room:onHumanoidLeave(humanoid)
  humanoid.in_room = nil
  if not self.humanoids[humanoid] then
    print("Warning: Humanoid leaving a room that they are not in")
    return
  end
  self.humanoids[humanoid] = nil
  local staff_leaving = false
  if class.is(humanoid, Patient) then
    -- Some staff member in the room might be waiting to get to the staffroom.
    for humanoid in pairs(self.humanoids) do
      -- A patient leaving allows doctors/nurses inside to go to staffroom, if needed
      -- In a rare case a handyman that just decided he wants to go to the staffroom
      -- could be in the room at the same time as a patient leaves.
      if class.is(humanoid, Staff) and humanoid.humanoid_class ~= "Handyman" then
        if humanoid.staffroom_needed then
          humanoid.staffroom_needed = nil
          humanoid:goToStaffRoom()
          staff_leaving = true
        end
      end
    end
    -- There might be other similar rooms with patients queueing
    if self.door.queue and self.door.queue:reportedSize() == 0 then
      self:tryToFindNearbyPatients()
    end
  end
  if not staff_leaving then
    self:tryAdvanceQueue()
  else
    -- Staff is leaving. If there is still a need for this room (people are in the queue) then call
    -- someone new.
    if self.door.queue:patientSize() > 0 then
      -- This call might not be effective, if the doctor last action is 
      -- walking/must_happen but is_leaving not set (psych likes to walk around in the room)
      -- hence testStaffCriteria still pass.
      -- This is guarded by onHumanoidLeave(Staff)
      self.world.dispatcher:callForStaff(self)
    end
  end
  if class.is(humanoid, Staff) then
    -- Make patients leave the room if there are no longer enough staff
    if not self:testStaffCriteria(self:getRequiredStaffCriteria()) then
      -- Call for staff if needed
      if self.door.queue:patientSize() > 0 then
        self.world.dispatcher:callForStaff(self)
      end
      for humanoid in pairs(self.humanoids) do
        if class.is(humanoid, Patient) and self:shouldHavePatientReenter(humanoid) then
          self:makePatientLeave(humanoid)
          humanoid:queueAction(self:createEnterAction())
        end
      end
    end
    -- Remove any unwanted moods the staff member might have
    humanoid:setMood("staff_wait", "deactivate")
  end
  -- The player might be waiting to edit this room
  if not self.is_active then
    local i = 0
    for humanoid in pairs(self.humanoids) do
      i = i + 1
    end
    if i == 0 then
      local ui = self.world.ui
      ui:addWindow(UIEditRoom(ui, self))
      ui:setCursor(ui.default_cursor)
    end
  end
end

function Room:shouldHavePatientReenter(patient)
  return not patient:hasLeavingAction()
end

local tile_factor = 10     -- how many tiles further are we willing to walk for 1 person fewer in the queue
local readiness_bonus = 50 -- how many tiles further are we willing to walk if the room has all the required staff
function Room:getUsageScore()
  local queue = self.door.queue
  local score = queue:patientSize() + self:getPatientCount() - self.maximum_patients
  score = score * tile_factor
  if self:testStaffCriteria(self:getRequiredStaffCriteria()) then
    score = score - readiness_bonus
  end
  return score
end

function Room:canHumanoidEnter(humanoid)
  -- If the room is not active nobody can enter
  if not self.is_active then
    return false
  end
  -- By default, staff can always enter
  if class.is(humanoid, Staff) then
    return true
  end
  -- By default, patients can only enter if there are sufficient staff and not
  -- too many patients.
  if class.is(humanoid, Patient) and not self.needs_repair then
    return self:testStaffCriteria(self:getRequiredStaffCriteria()) and self:getPatientCount() < self.maximum_patients
  end
  -- By default, other classes of humanoids cannot enter
  return false
end

-- Function stub for rooms to implement. Called when the final confirm
-- button has been pressed when building/editing a room.
function Room:roomFinished()
  -- True once the room has been finished after initial construction, and then
  -- as long as the user doesn't edit it and go back beyond the first phase (place objects)
  self.built = true
  -- Only true when not editing the room at all.
  self.is_active = true
  -- Show information about the room if not already shown.
  if not self.world.room_built[self.room_info.id] then
    self.world.ui:addWindow(UIInformation(self.world.ui, _S.room_descriptions[self.room_info.id]))
    self.world.room_built[self.room_info.id] = true
  end
  self:tryToFindNearbyPatients()
  -- It may also happen that there are patients queueing for this room already (e.g after editing)
  self:tryAdvanceQueue()
end

function Room:tryToFindNearbyPatients()
  if not self.door.queue then
    return
  end
  local world = self.world
  local our_score = self:getUsageScore()
  local our_x, our_y = self:getEntranceXY(true)
  for _, room in pairs(self.world.rooms) do
    if room.hospital == self.hospital and room.room_info == self.room_info
    and room.door.queue and room.door.queue:reportedSize() >= 2 then
      local other_score = room:getUsageScore()
      local other_x, other_y = room:getEntranceXY(true)
      local queue = room.door.queue
      while queue:reportedSize() > 1 do
        local patient = queue:back()
        local px, py = patient.tile_x, patient.tile_y
        if world:getPathDistance(px, py, our_x, our_y) + our_score <
        world:getPathDistance(px, py, other_x, other_y) + other_score then
          -- Update the queues
          queue:removeValue(patient)
          patient.next_room_to_visit = self
          self.door.queue:expect(patient)
          self.door:updateDynamicInfo()
          
          -- Update our cached values
          our_score = self:getUsageScore()
          other_score = room:getUsageScore()
          
          -- Rewrite the action queue
          for i, action in ipairs(patient.action_queue) do
            if i ~= 1 then
              action.todo_interrupt = true
            end
            if action.name == "walk" and action.x == other_x and action.y == other_y then
              local action = self:createEnterAction()
              patient:queueAction(action, i)
              break
            end
          end
          local interrupted = patient.action_queue[1]
          local on_interrupt = interrupted.on_interrupt
          if on_interrupt then
            interrupted.on_interrupt = nil
            on_interrupt(interrupted, patient, false)
          end
        else
          break
        end
      end
    end
  end
end

function Room:crashRoom()
  self.door:closeDoor()
  if self.door2 then
    self.door2.hover_cursor = nil
  end

  local remove_humanoid = function(humanoid)
    humanoid:queueAction({name = "idle"}, 1)
    humanoid.user_of = nil
    -- Make sure any emergency list is not messed up.
    -- Note that these humanoids might just have been kicked. (No hospital set)
    if humanoid.is_emergency then
      table.remove(self.world:getLocalPlayerHospital().emergency_patients, humanoid.is_emergency)
    end
    humanoid:die()
    self.world:destroyEntity(humanoid)
  end

  -- Remove all humanoids in the room
  for humanoid, _ in pairs(self.humanoids) do
    remove_humanoid(humanoid)
  end
  -- There might also be someone using the door, even if that person is just about to exit
  -- he/she is killed too.
  local walker = self.door.user
  if walker then
    self.door:setUser(nil)
    remove_humanoid(walker)
  end
  
  -- Remove all objects in the room
  local fx, fy = self:getEntranceXY(true)
  for object, _ in pairs(self.world:findAllObjectsNear(fx, fy)) do
    -- Machines (i.e. objects with strength) are already done.
    if object.object_type.id ~= "door" and not object.strength
    and object.object_type.class ~= "SwingDoor" then
      object.user = nil
      object.user_list = nil
      object.reserved_for = nil
      object.reserved_for_list = nil
      self.world:destroyEntity(object)
    end
  end
  
  local map = self.world.map.th
  -- TODO: Explosion, animations: 4612, 3280
  
  -- Make every floor tile have soot on them
  for x = self.x, self.x + self.width - 1 do
    for y = self.y, self.y + self.height - 1 do
      local soot = self.world:newObject("litter", x, y)
      soot:setLitterType("soot_floor", 0)
    end
  end
  -- Make walls have soot on them too
  local ty = self.y
  local soot_type, soot, block
  for x = self.x, self.x + self.width - 1 do
    block = map:getCell(x, ty, 2)
    soot_type = "soot_wall"
    if self.world:getWallSetFromBlockId(block) == "window_tiles" then
      soot_type = "soot_window"
    end
    soot = self.world:newObject("litter", x, ty)
    soot:setLitterType(soot_type, 1)
  end
  local x = self.x
  for y = self.y, self.y + self.height - 1 do
    block = map:getCell(x, y, 3)
    soot_type = "soot_wall"
    if self.world:getWallSetFromBlockId(block) == "window_tiles" then
      soot_type = "soot_window"
    end
    soot = self.world:newObject("litter", x, y)
    soot:setLitterType(soot_type, 0)
  end
  
  self.hospital.num_explosions = self.hospital.num_explosions + 1

  self.crashed = true
  self:deactivate()
end

-- Tells the patient to leave the room. This can be overridden for special
-- handling, e.g. if the patient needs to change before leaving the room.
function Room:makePatientLeave(patient)
  local leave = self:createLeaveAction()
  leave.must_happen = true
  patient:setNextAction(leave)
end

function Room:deactivate()
  self.is_active = false -- So that no more patients go to it.
  self.world.dispatcher:dropFromQueue(self)
end

function Room:tryToEdit()
  self:deactivate()
  local i = 0
  -- Tell all humanoids that they should leave
  -- If someone is entering the room right now they are also counted.
  if self.door.user and self.door.user.action_queue[1].is_entering then
    i = 1
  end
  for humanoid, _ in pairs(self.humanoids) do
    if not humanoid:isLeaving() then
      if class.is(humanoid, Patient) then
        self:makePatientLeave(humanoid)
        humanoid:queueAction({name = "seek_room", room_type = self.room_info.id})
      else
        humanoid:setNextAction(self:createLeaveAction())
        humanoid:queueAction({name = "meander"})
      end
    end
    i = i + 1
  end
  -- If there were no people inside we're ready to edit the room
  if i == 0 then
  local ui = self.world.ui
    ui:addWindow(UIEditRoom(ui, self))
    ui:setCursor(ui.default_cursor)
  end
end

function Room:hasQueueDialog()
  return not self.room_info.has_no_queue_dialog
end

--! Stub to be extended in subclasses, if needed.
function Room:afterLoad(old, new)
end

