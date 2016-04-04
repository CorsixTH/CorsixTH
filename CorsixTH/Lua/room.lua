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

---@type Room
local Room = _G["Room"]

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
  if not self:hasQueueDialog() then
    door:setDynamicInfo('text', {
      self.room_info.name
    })
  else
    door:setDynamicInfo('text', {
      self.room_info.name,
      _S.dynamic_info.object.queue_size:format(0),
      _S.dynamic_info.object.queue_expected:format(0)
    })
  end
  self.built = false
  self.crashed = false

  self.world.map.th:markRoom(x, y, w, h, self.room_info.floor_tile, self.id)

  self.humanoids = {--[[a set rather than a list]]}
  self.objects = {--[[a set rather than a list]]}
  -- the set of humanoids walking to this room
  self.humanoids_enroute = {--[[a set rather than a list]]}
end

--! Get the tile next to the door.
--!param inside (bool) If set, get the tile inside the room, else get the tile outside.
--!return x,y (tile coordinates) of the tile next to the door.
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

--! Construct an 'walk' action to the tile next to the door, just outside the room.
--!return Action to move to the tile just outside the room.
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

function Room:createEnterAction(humanoid_entering, callback)
  local x, y = self:getEntranceXY(true)
  if not callback then
    if class.is(humanoid_entering, Patient) then
      callback = --[[persistable:room_patient_enroute_cancel]] function()
        humanoid_entering:setNextAction({name = "seek_room", room_type = self.room_info.id})
      end
    elseif class.is(humanoid_entering, Vip) then
      callback = --[[persistable:room_vip_enroute_cancel]] function()
        humanoid_entering:setNextAction({name = "idle"})
        humanoid_entering.waiting = 1;
      end
    else
      callback = --[[persistable:room_humanoid_enroute_cancel]] function()
        humanoid_entering:setNextAction({name = "meander"})
      end
    end
  end
  if self.is_active then
    self.humanoids_enroute[humanoid_entering] = {callback = callback}
  end

  return {name = "walk", x = x, y = y,
    is_entering = humanoid_entering and self or true}
end

--! Get a patient in the room.
--!return A patient (humanoid) if there is a patient, nil otherwise.
function Room:getPatient()
  for humanoid in pairs(self.humanoids) do
    if class.is(humanoid, Patient) then
      return humanoid
    end
  end
end

--! Count the number of patients in the room.
--!return Number of patients in the room.
function Room:getPatientCount()
  local count = 0
  for humanoid in pairs(self.humanoids) do
    if class.is(humanoid, Patient) then
      count = count + 1
    end
  end
  return count
end

-- function that sets a given attribute to a given value for all staff members.
-- Should be overriden for rooms that have more than one staff member.
function Room:setStaffMembersAttribute(attribute, value)
  if self.staff_member then
    self.staff_member[attribute] = value
  end
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
  if self.staff_member then
    self:setStaffMembersAttribute("dealing_with_patient", false)
  end

  if patient.disease then
    if not patient.diagnosed then
      -- Patient not yet diagnosed, hence just been in a diagnosis room.
      -- Increment diagnosis_progress, and send patient back to GP.

      patient:completeDiagnosticStep(self)
      self.hospital:receiveMoneyForTreatment(patient)
      if patient:agreesToPay("diag_gp") then
        patient:queueAction{name = "seek_room", room_type = "gp"}
      else
        patient:goHome("over_priced", "diag_gp")
      end
    else
      -- Patient just been in a cure room, so either patient now cured, or needs
      -- to move onto next cure room.
      patient.cure_rooms_visited = patient.cure_rooms_visited + 1
      local next_room = patient.disease.treatment_rooms[patient.cure_rooms_visited + 1]
      if next_room then
        -- Do not say that it is a treatment room here, since that check should already have been made.
        patient:queueAction{name = "seek_room", room_type = next_room}
      else
        -- Patient is "done" at the hospital
        patient:treatDisease()
      end
    end
  else
    patient:queueAction{name = "meander", count = 2}
    patient:queueAction{name = "idle"}
  end

  if self.dealt_patient_callback then
    self.dealt_patient_callback(self.waiting_staff_member)
  end
  -- The staff member(s) might be needed somewhere else.
  self:findWorkForStaff()
end

--! Checks if the room still needs the staff in it and otherwise
-- sends them away if they're needed somewhere else.
function Room:findWorkForStaff()
  -- If the staff member is idle we can send him/her somewhere else
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
      if class.is(humanoid, Staff) and humanoid:fulfillsCriterion(attribute) and not humanoid:isLeaving() and not humanoid.fired then
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

local no_staff = {} -- Constant denoting 'no staff at all' in a room.

--! Get the type and number of maximum staff for the room.
--!return (table) Type and number of maximum staff.
function Room:getMaximumStaffCriteria()
  -- Some rooms have dynamic criteria (i.e. dependent upon the number of items
  -- in the room), so this method is provided for such rooms to override it.
  return self.room_info.maximum_staff or self.room_info.required_staff or no_staff
end

--! Get the type and number of required staff for the room.
--!return (table) Type and number of required staff.
function Room:getRequiredStaffCriteria()
  return self.room_info.required_staff or no_staff
end

function Room:onHumanoidEnter(humanoid)
  assert(not self.humanoids[humanoid], "Humanoid entering a room that they are already in")

  humanoid.in_room = self
  humanoid.last_room = self -- Remember where the staff was for them to come back after staffroom rest
  -- Do not set humanoids[humanoid] here, because it affect staffFitsInRoom test

  --entering humanoids are no longer enroute
  if self.humanoids_enroute[humanoid] then
    self.humanoids_enroute[humanoid] = nil -- humanoid is no longer walking to this room
  end

  -- If this humanoid for some strange reason happens to enter a non-active room,
  -- just leave.
  if not self.is_active then
    print('Warning: humanoid entering non-active room')
    self.humanoids[humanoid] = true
    if class.is(humanoid, Patient) then
      self:makeHumanoidLeave(humanoid)
      humanoid:queueAction({name = "seek_room", room_type = self.room_info.id})
    else
      humanoid:setNextAction(self:createLeaveAction())
      humanoid:queueAction({name = "meander"})
    end
    return
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
  local msg = {
    (_A.warnings.researcher_needs_desk_1),
    (_A.warnings.researcher_needs_desk_2),
    (_A.warnings.researcher_needs_desk_3),
  }
  local msg_nurse = {
    (_A.warnings.nurse_needs_desk_1),
    (_A.warnings.nurse_needs_desk_2),
  }
  if class.is(humanoid, Staff) then
    -- If the room is already full of staff, or the staff member isn't relevant
    -- to the room, then make them leave. Otherwise, take control of them.
    if not self:staffFitsInRoom(humanoid) then
      if self:getStaffMember() and self:staffMeetsRoomRequirements(humanoid) then
        local staff_member = self:getStaffMember()
        self.humanoids[humanoid] = true
          if staff_member.profile.is_researcher and self.room_info.id == "research" then
            self.world.ui.adviser:say(msg[math.random(1, #msg)])
          end
          if staff_member.humanoid_class == "Nurse" and self.room_info.id == "ward" then
            self.world.ui.adviser:say(msg_nurse[math.random(1, #msg_nurse)])
          end
        if not staff_member.dealing_with_patient then
          staff_member:setNextAction(self:createLeaveAction())
          staff_member:queueAction{name = "meander"}
          self.staff_member = humanoid
          humanoid:setCallCompleted()
          self:commandEnteringStaff(humanoid)
        else
          if self.waiting_staff_member then
            self.waiting_staff_member.waiting_on_other_staff = nil
            self.waiting_staff_member:setNextAction(self:createLeaveAction())
            self.waiting_staff_member:queueAction{name = "meander"}
          end
          self:createDealtWithPatientCallback(humanoid)
          humanoid.waiting_on_other_staff = true
          humanoid:setNextAction{name = "meander"}
        end
      else
        self.humanoids[humanoid] = true
        humanoid:setNextAction(self:createLeaveAction())
        humanoid:queueAction{name = "meander"}
        humanoid:adviseWrongPersonForThisRoom()
      end
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
    -- An infect patient's disease may have changed so they might have
    -- been sent to an incorrect diagnosis room, they should leave and go
    -- back to the gp for redirection
    if (humanoid.infected) and not humanoid.diagnosed and
        not self:isDiagnosisRoomForPatient(humanoid) then
      humanoid:queueAction(self:createLeaveAction())
      humanoid.needs_redirecting = true
      humanoid:queueAction({name = "seek_room", room_type = "gp"})
      return
    end
    -- Check if the staff requirements are still fulfilled (the staff might have left / been picked up meanwhile)
    if self:testStaffCriteria(self:getRequiredStaffCriteria()) then
      if self.staff_member  then
        self:setStaffMembersAttribute("dealing_with_patient", true)
      end
      self:commandEnteringPatient(humanoid)
    else
      humanoid:setNextAction(self:createLeaveAction())
      humanoid:queueAction(self:createEnterAction(humanoid))
    end
  end
end

function Room:createDealtWithPatientCallback(humanoid)
  self.dealt_patient_callback = --[[persistable:room_dealt_with_patient_callback]] function (humanoid)
    if not humanoid.waiting_on_other_staff then
      return
    end
    local staff_member = self:getStaffMember()
    if staff_member then
      staff_member:setNextAction(self:createLeaveAction())
      staff_member:queueAction{name = "meander"}
      staff_member:setMood("staff_wait", "deactivate")
      staff_member:setDynamicInfoText("")
    end
    humanoid:setCallCompleted()
    humanoid.waiting_on_other_staff = nil
    self:commandEnteringStaff(humanoid)
    self:setStaffMember(humanoid)
    self.waiting_staff_member = nil
    self.dealt_patient_callback = nil
  end
  self.waiting_staff_member = humanoid
end

--! Get the current staff member.
-- Can be overridden in rooms with multiple staff members to return the desired one.
--!return (staff) The current staff member.
function Room:getStaffMember()
  return self.staff_member
end

--! Set the current staff member.
--!param staff (staff) Staff member to denote as current staff.
function Room:setStaffMember(staff)
  self.staff_member = staff
end

--! Does the given staff member fit in the room?
-- Returns false if the room is already full of staff or if the given member of staff cannot help out.
-- Otherwise returns true.
--!return (bool) True if the staff member can work in the room, else False.
function Room:staffFitsInRoom(staff)
  local criteria = self:getMaximumStaffCriteria()
  if self:testStaffCriteria(criteria) or not self:testStaffCriteria(criteria, staff) then
    return false
  end
  return true
end

--! Returns true if the humanoid meets (one of) the required staff criteria of the room
function Room:staffMeetsRoomRequirements(humanoid)
  local criteria = self:getRequiredStaffCriteria()
  for attribute, _ in pairs(criteria) do
    if humanoid:fulfillsCriterion(attribute) then
      return true
    end
  end
  return false
end

--! When a valid member of staff enters the room this function is called.
-- Can be extended in derived classes.
--!param humanoid The staff in question
--!param already_initialized If true, this means that the staff has already got order
-- what to do.
function Room:commandEnteringStaff(humanoid, already_initialized)
  if not already_initialized then
    self.staff_member = humanoid
    humanoid:setNextAction{name = "meander"}
  end
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
  if self.door.queue:size() > 0 and not self.door.user and not self.door.reserved_for then
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
  if self.staff_member == humanoid then
    self.staff_member = nil
  end
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
    if self.active and self.door.queue:patientSize() > 0 then
      -- This call might not be effective, if the doctor last action is
      -- walking/must_happen but is_leaving not set (psych likes to walk around in the room)
      -- hence testStaffCriteria still pass.
      -- This is guarded by onHumanoidLeave(Staff)
      self.world.dispatcher:callForStaff(self)
    end
  end
  if class.is(humanoid, Staff) then
    if humanoid.waiting_on_other_staff then
      humanoid.waiting_on_other_staff = nil
      self.dealt_patient_callback = nil
    end
    -- Make patients leave the room if there are no longer enough staff
    if not self:testStaffCriteria(self:getRequiredStaffCriteria()) then
      local patient_needs_to_reenter = false
      for humanoid in pairs(self.humanoids) do
        if class.is(humanoid, Patient) and self:shouldHavePatientReenter(humanoid) then
          self:makeHumanoidLeave(humanoid)
          humanoid:queueAction(self:createEnterAction(humanoid))
          patient_needs_to_reenter = true
        end
      end
      -- Call for staff if needed
      if self.is_active and (patient_needs_to_reenter or self.door.queue:patientSize() > 0) then
        self.world.dispatcher:callForStaff(self)
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

--! Score function to decide how desirable a room is for a patient.
--!return (int) The score, lower is better.
function Room:getUsageScore()
  local queue = self.door.queue
  local score = queue:patientSize() + self:getPatientCount() - self.maximum_patients
  score = score * tile_factor
  if self:testStaffCriteria(self:getRequiredStaffCriteria()) then
    score = score - readiness_bonus
  end
  -- Add constant penalty if queue is full
  if queue:isFull() then
    score = score + 1000
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
  -- Some rooms should not have the door cursor for the queue dialog
  if not self:hasQueueDialog() then
    self.door.hover_cursor = TheApp.gfx:loadMainCursor("default")
  end
  -- Show information about the room if not already shown.
  -- Also only show them if the player is playing the original campaign.
  if tonumber(self.world.map.level_number) and not self.world.room_information_dialogs_off then
    if not self.world.room_built[self.room_info.id] then
      self.world.ui:addWindow(UIInformation(self.world.ui, _S.room_descriptions[self.room_info.id]))
      self.world.room_built[self.room_info.id] = true
    end
  end
  self:tryToFindNearbyPatients()
  -- It may also happen that there are patients queueing for this room already (e.g after editing)
  if self.door.queue:patientSize() > 0 then
    self.world.dispatcher:callForStaff(self)
  end
  self:tryAdvanceQueue()
end

--! Try to move a patient from the old room to the new room.
--!param old_room (Room) Room that currently has the patient in the queue.
--!param new_room (Room) Room that wants the patient in the queue.
--!param patient (Humanoid) Patient to move.
--!return (boolean) Whether we are done with the old room (no more patients will come from it).
local function tryMovePatient(old_room, new_room, patient)
  local world = new_room.world

  local px, py = patient.tile_x, patient.tile_y
  -- Don't reroute the patient if he just decided to go to the toilet
  if patient.going_to_toilet ~= "no" then
    return false
  end

  local new_x, new_y = new_room:getEntranceXY(true)
  local old_x, old_y = old_room:getEntranceXY(true)
  local new_distance = world:getPathDistance(px, py, new_x, new_y)
  if not new_distance then return true end -- Patient cannot reach us, quit trying

  local new_score = new_room:getUsageScore() + new_distance
  local old_score
  local old_distance = world:getPathDistance(px, py, old_x, old_y)
  if old_distance then
    old_score = old_room:getUsageScore() + old_distance
  else
    old_score = new_score + 1 -- Make condition below fail.
  end
  if new_score >= old_score then return true end

  -- Update the queues
  local old_queue = old_room.door.queue
  old_queue:removeValue(patient)
  patient.next_room_to_visit = new_room
  new_room.door.queue:expect(patient)
  new_room.door:updateDynamicInfo()

  -- Rewrite the action queue
  for i, action in ipairs(patient.action_queue) do
    if i ~= 1 then
      action.todo_interrupt = true
    end
    -- The patient will most likely have a queue action for the other
    -- room that must be cancelled. To prevent the after_use callback
    -- of the drinks machine to enqueue the patient in the other queue
    -- again, is_in_queue is set to false so the callback won't run
    if action.name == 'queue' then
      action.is_in_queue = false
    elseif action.name == "walk" and action.x == old_x and action.y == old_y then
      local action = new_room:createEnterAction(patient)
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
  return false
end

--! Try to find new patients for this room by 'stealing' them from other rooms nearby.
function Room:tryToFindNearbyPatients()
  if not self.door.queue then
    return
  end

  for _, old_room in pairs(self.world.rooms) do
    if old_room.hospital == self.hospital and old_room ~= self and
        old_room.room_info == self.room_info and old_room.door.queue and
        old_room.door.queue:reportedSize() >= 2 then
      local old_queue = old_room.door.queue
      local pat_number = old_queue:reportedSize()
      while pat_number > 1 do
        local patient = old_queue:reportedHumanoid(pat_number)
        if tryMovePatient(old_room, self, patient) then break end
        -- tryMovePatient may have just removed patient 'pat_number', but it does
        -- not change the queue in front of it. 'pat_number - 1' thus still exists.
        pat_number = pat_number - 1
      end
    end
  end
end

--! Explode the room.
function Room:crashRoom()
  self.door:closeDoor()
  if self.door2 then
    self.door2.hover_cursor = nil
  end

  -- A patient might be about to use the door (staff are dealt with elsewhere):
  if self.door.reserved_for then
    local person = self.door.reserved_for
    if not person:isLeaving() then
      if class.is(person, Patient) then
        --Delay so that room is destroyed before the seek_room search.
        person:queueAction({name = "idle", count = 1})
        person:queueAction({name = "seek_room", room_type = self.room_info.id})
      end
    end
    person:finishAction()
    self.door.reserved_for = nil
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
    self.door:removeUser(walker)
    remove_humanoid(walker)
  end

  -- Remove all objects in the room
  local fx, fy = self:getEntranceXY(true)
  for object, _ in pairs(self.world:findAllObjectsNear(fx, fy)) do
    -- Machines (i.e. objects with strength) are already done.
    if object.object_type.class == "Plant" then
      local index = self.hospital:getIndexOfTask(object.tile_x, object.tile_y, "watering")
      if index ~= -1 then
        self.hospital:removeHandymanTask(index, "watering")
      end
      object.unreachable = true
    end
    if object.object_type.id ~= "door" and not object.strength and
        object.object_type.class ~= "SwingDoor" then
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

-- Tells a humanoid in the room to leave it. This can be overridden for special
-- handling, e.g. if the humanoid needs to change before leaving the room.
function Room:makeHumanoidLeave(patient)
  local leave = self:createLeaveAction()
  leave.must_happen = true
  patient:setNextAction(leave)
end

function Room:makeHumanoidDressIfNecessaryAndThenLeave(humanoid)
  if not humanoid:isLeaving() then
    local leave = self:createLeaveAction()
    leave.must_happen = true

    if not string.find(humanoid.humanoid_class, "Stripped") then
      humanoid:setNextAction(leave)
      return
    end

    local screen, sx, sy = self.world:findObjectNear(humanoid, "screen")
    local use_screen = {
      name = "use_screen",
      object = screen,
      must_happen = true,
      is_leaving = true
    }

    --Make old saved game action queues compatible with the changes made by the #293 fix commit:
    for actions_index, action in ipairs(humanoid.action_queue) do
      if action.name == "use screen" or (action.name == "walk" and action.x == sx and action.y == sy) then
        if not action.is_leaving then
          humanoid.humanoid_actions[actions_index].is_leaving = true
        end
        if action.name == "walk" and action.must_happen then
          action.must_happen = false
        end
      end
    end

    if humanoid.action_queue[1].name == "use_screen" then
      --The humanoid must be using the screen to undress because this isn't a leaving action:
      humanoid.action_queue[1].after_use = nil
      humanoid:setNextAction(use_screen)
    else
      humanoid:setNextAction{
        name = "walk",
        x = sx,
        y = sy,
        must_happen = true,
        no_truncate = true,
        is_leaving = true
      }
      humanoid:queueAction(use_screen)
    end

    humanoid:queueAction(leave)
  end
end

--! Deactivate the room from the world.
function Room:deactivate()
  self.is_active = false -- So that no more patients go to it.
  self.world:notifyRoomRemoved(self)
  for humanoid, callback in pairs(self.humanoids_enroute) do
    callback.callback();
  end
  -- Now empty the humanoids_enroute list since they are not enroute anymore.
  self.humanoids_enroute = {}
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
        self:makeHumanoidLeave(humanoid)
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
  if old and old < 46 then
    self.humanoids_enroute = {--[[a set rather than a list]]}
  end
end

--[[ Is the room one of the diagnosis rooms for the patient?
-- This used for epidemics when the disease and therefore the diagnosis
-- rooms of a patient may change.
-- @param patient (Patient) patient to verify if treatment room ]]
-- @return result (boolean) true if is suitable diagnosis room, false otherwise
function Room:isDiagnosisRoomForPatient(patient)
  if self.room_info.id ~= "gp" then
    for _, room_name in ipairs(patient.disease.diagnosis_rooms) do
      if self.room_info.id == room_name then
        return true
      end
    end
    return false
  else
    return true
  end
end

--! Get the average service quality of the staff members in the room.
--!return (float) [0-1] Average staff service quality.
function Room:getStaffServiceQuality()
  local quality = 0.5

  if self.staff_member_set then
    -- For rooms with multiple staff member (like operating theatre)
    quality = 0
    local count = 0
    for member, _ in pairs(self.staff_member_set) do
      quality = quality + member:getServiceQuality()
      count = count + 1
    end

    quality = quality / count
  elseif self.staff_member then
    -- For rooms with one staff member
    quality = self.staff_member:getServiceQuality()
  end

  return quality
end
