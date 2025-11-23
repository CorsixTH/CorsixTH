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

class "Room"

---@type Room
local Room = _G["Room"]

local COST_RECOVERY = 0.40 -- Percentage cost recovery of destroyed room items

function Room:Room(x, y, w, h, id, room_info, world, hospital, door, door2)
  self.id = id
  self.world = world
  self.hospital = hospital

  -- Serving staff in single occupancy rooms (like GD, Pharmacy and etc)
  self.staff_member = nil
  -- Serving staff list in multi-occupancy rooms (like Operating Theatre)
  -- Only set this for multi-occupancy, otherwise single occupancy rooms break
  self.staff_member_set = nil -- Override with {} in derived class

  self.room_info = room_info
  self:initRoom(x, y, w, h, door, door2)
end

--! Initialises primary components of the room.
-- Additionally, if there is already a room, e.g. it is being moved,
-- we can just reinit it by calling this, not make a new one.
--!param x (coordinate) starting tile
--!param y (coordinate) starting tile
--!param w (num) width of room
--!param h (num) height of room
--!param door (object) primary door for room
--!param door2 (object) optional secondary door (e.g. swing doors)
function Room:initRoom(x, y, w, h, door, door2)
  self.x = x
  self.y = y
  self.width = w
  self.height = h
  self.maximum_patients = 1 -- A good default for most rooms

  -- setup new door and new queue
  local new_door = door
  local old_door = self.door
  new_door:setupDoor(self, old_door)
  self.door = new_door

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

  self.world:prepareRectangleTilesForBuild(self.x, self.y, self.width, self.height)
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
  return WalkAction(x, y):setIsLeaving(true):truncateOnHighPriority()
end

function Room:createEnterAction(humanoid_entering, callback)
  local x, y = self:getEntranceXY(true)
  if not callback then
    if class.is(humanoid_entering, Patient) then
      callback = --[[persistable:room_patient_enroute_cancel]] function()
        humanoid_entering:setNextAction(SeekRoomAction(self.room_info.id))
      end
    elseif class.is(humanoid_entering, Vip) then
      callback = --[[persistable:room_vip_enroute_cancel]] function()
        humanoid_entering:setNextAction(IdleAction())
        humanoid_entering.waiting = 1
      end
    else
      callback = --[[persistable:room_humanoid_enroute_cancel]] function()
        local room = humanoid_entering:getRoom()
        -- if the room is one we should 'cycle' in, resume that
        -- otherwise staff member will meander in room incorrectly again
        if room and room.doStaffUseCycle and humanoid_entering.user_of ~= room.door then
          room:commandEnteringStaff(humanoid_entering)
        else
          humanoid_entering:setNextAction(MeanderAction())
        end
      end
    end
  end
  if self.is_active then
    self.door.queue:expect(humanoid_entering, {callback = callback})
  end

  return WalkAction(x, y):setIsEntering(true)
end

--! Get a table of all patients using the room
--! A room usually only has one patient, however in the ward can have multiple
--! patients at once.
--!return patients (table) All patients actively using the room
function Room:getPatients()
  local patients = {}
  -- Are there patients using the room?
  if self:getPatientCount() == 0 then return patients end
  for humanoid in pairs(self.humanoids) do
    if class.is(humanoid, Patient) then
      patients[#patients + 1] = humanoid
    end
  end
  return patients
end

--! Get any patient in the room.
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
-- Should be overridden for rooms that have more than one staff member.
function Room:setStaffMembersAttribute(attribute, value)
  if self.staff_member then
    self.staff_member[attribute] = value
  end
end

function Room:dealtWithPatient(patient)
  patient = patient or self:getPatient()
  -- If the patient was sent home while in the room, don't
  -- do anything apart from removing any leading idle action.
  if not patient.hospital or patient.going_home then
    if patient:getCurrentAction().name == "idle" then
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
        patient:queueAction(SeekRoomAction("gp"))
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
        patient:queueAction(SeekRoomAction(next_room))
      else
        -- Patient is "done" at the hospital
        patient:treatDisease()
      end
    end
  else
    patient:queueAction(MeanderAction():setCount(2))
    patient:queueAction(IdleAction())
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
      -- check state of humanoid is appropriate for room
      -- check they are staff and meet requirements for the room
      -- ensure not leaving (going to staff room) or fired
      -- check if answering a call to another room
      if class.is(humanoid, Staff) and humanoid:fulfillsCriterion(attribute) and
          not humanoid:isLeaving() and not humanoid.fired and
          not (humanoid.on_call and humanoid.on_call.object ~= self) and
          not humanoid.going_to_staffroom then
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
    return next(missing) == nil
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

  -- If this humanoid for some strange reason happens to enter a non-active room,
  -- just leave.
  if not self.is_active then
    print('Warning: humanoid entering non-active room')
    self.humanoids[humanoid] = true
    if class.is(humanoid, Patient) then
      self:makeHumanoidLeave(humanoid)
      humanoid:queueAction(SeekRoomAction(self.room_info.id))
    else
      humanoid:setNextAction(self:createLeaveAction())
      humanoid:queueAction(MeanderAction())
    end
    return
  end
  if class.is(humanoid, Handyman) then
    -- Handymen can always enter a room (to repair stuff, water plants, etc.)
    self.humanoids[humanoid] = true
    -- Check for machines which need repair or plants which need watering if
    -- the handyman didn't arrive as a part of a job
    if humanoid.on_call then
      assert(humanoid.on_call.object:getRoom() == self, "Handyman arrived is on call but not arriving to the designated room")
    else
      -- If the handyman was not assigned for the job (e.g. drop by manual pickup), do answer a call
      humanoid:setNextAction(AnswerCallAction())
    end
    self:tryAdvanceQueue()
    return
  end
  local researcher_desks = {
    (_A.warnings.researcher_needs_desk_1),
    (_A.warnings.researcher_needs_desk_2),
    (_A.warnings.researcher_needs_desk_3),
  }
  local nurse_desks = {
    (_A.warnings.nurse_needs_desk_1),
    (_A.warnings.nurse_needs_desk_2),
  }
  if class.is(humanoid, Staff) then
    -- If the room is already full of staff, or the staff member isn't relevant
    -- to the room, then make them leave. Otherwise, take control of them.
    local staff_entered = humanoid
    if not self:staffFitsInRoom(staff_entered) then
      if self:getStaffMember() and self:staffMeetsRoomRequirements(staff_entered) then
        local staff_in_room = self:getStaffMember()
        self.humanoids[staff_entered] = true
        if staff_in_room.profile.is_researcher and self.room_info.id == "research" then
          self.hospital:giveAdvice(researcher_desks)
        end
        if class.is(staff_in_room, Nurse) and self.room_info.id == "ward" then
          self.hospital:giveAdvice(nurse_desks)
        end
        if not staff_in_room.dealing_with_patient or staff_in_room:isMeandering() then
          -- Previous staff in the room not currently occupied by serving patient in room.
          -- Send out the previous staff and appoint new one.
          staff_in_room:setNextAction(self:createLeaveAction())
          staff_in_room:queueAction(MeanderAction())
          self.staff_member = staff_entered
          staff_entered:setCallCompleted()
          self:commandEnteringStaff(staff_entered)
        else
          -- Previous staff in the room currently occupied by serving patient in room.
          -- Send out the entered staff. It's not needed here.
          staff_entered:setNextAction(self:createLeaveAction())
          staff_entered:queueAction(MeanderAction())
        end
      else
        -- Inappropriate staff for this room
        self.humanoids[staff_entered] = true
        staff_entered:setNextAction(self:createLeaveAction())
        staff_entered:queueAction(MeanderAction())
        staff_entered:adviseWrongPersonForThisRoom()
      end
    else
      self.humanoids[staff_entered] = true
      staff_entered:setCallCompleted()
      self:commandEnteringStaff(staff_entered)
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
    local patient_entered = humanoid
    if patient_entered.infected and not patient_entered.diagnosed and
        not self:isDiagnosisRoomForPatient(patient_entered) then
      patient_entered:queueAction(self:createLeaveAction())
      patient_entered.needs_redirecting = true
      patient_entered:queueAction(SeekRoomAction("gp"))
      return
    end
    -- Check if the staff requirements are still fulfilled (the staff might have left / been picked up meanwhile)
    if self:testStaffCriteria(self:getRequiredStaffCriteria()) then
      if self.staff_member then
        self:setStaffMembersAttribute("dealing_with_patient", true)
      end
      self:commandEnteringPatient(patient_entered)
    else
      patient_entered:setNextAction(self:createLeaveAction())
      patient_entered:queueAction(self:createEnterAction(patient_entered))
    end
  end
end

--! Get the current staff member.
-- In multi-occupancy rooms this returns the staff member with the minimum service quality
--!return (staff) The current staff member.
function Room:getStaffMember()
  if not self.staff_member_set then return self.staff_member end

  local staff
  for staff_member, _ in pairs(self.staff_member_set) do
    if not staff_member.fired and not staff_member:hasLeavingAction() then
      if not staff or staff:getServiceQuality() > staff_member:getServiceQuality() then
        staff = staff_member
      end
    end
  end
  return staff
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
--!param staff (object) The staff in question
--!param already_initialized (bool) If true, this means that the staff has already got order
-- what to do.
function Room:commandEnteringStaff(staff, already_initialized)
  if not already_initialized then
    self.staff_member = staff
    staff:setNextAction(MeanderAction())
  end
  self:tryToFindNearbyPatients()
  staff:setDynamicInfoText("")
  -- This variable is used to avoid multiple calls for staff (sound played only)
  self.sound_played = nil
  if self:testStaffCriteria(self:getRequiredStaffCriteria()) then
    self.world.dispatcher:dropFromQueue(self)
  end
end

--! Activates and deactivates the staff waiting for patient mood icon
-- and dynamic info text
--!param activate (bool) - true to activate, false or nil to deactivate
function Room:_staffWaitToggle(activate)
  if not self.staff_member and not self.staff_member_set then
    return -- No staff in room
  end

  local state = "deactivate"
  local dynamic_text = ""

  if activate then
    dynamic_text = _S.dynamic_info.staff.actions.waiting_for_patient
    state = "activate"
  end

  if not self.staff_member_set and self.staff_member then
    -- single occupancy rooms (like GD, Pharmacy and etc)
    self.staff_member:setMood("staff_wait", state)
    self.staff_member:setDynamicInfoText(dynamic_text)
  else
    -- multi-occupancy rooms (like Operating Theatre)
    for staff_member in pairs(self.staff_member_set) do
      staff_member:setMood("staff_wait", state)
      staff_member:setDynamicInfoText(dynamic_text)
    end
  end
end

--! Check the target room for a staff wait toggle is not staff room/training/toilets,
--! and the front humanoid is a patient.
function Room:_checkWaitToggleValidTarget()
  return self:hasQueueDialog() and self.room_info.id ~= "toilets" and
      class.is(self.door.queue:front(), Patient)
end

--! Handle the patient coming into the room
--! To be extended in derived classes.
--!param humanoid The patient entering
function Room:commandEnteringPatient(humanoid)
  self.door.queue.visitor_count = self.door.queue.visitor_count + 1
  humanoid:updateDynamicInfo("")

  self:_staffWaitToggle(false) -- Staff no longer waiting
end

function Room:tryAdvanceQueue()
  if self.door.queue and self.door.queue:size() > 0 and not self.door.user and not self.door.reserved_for then
    local front = self.door.queue:front()
    -- These two conditions differ by the waiting symbol

    if self:canHumanoidEnter(front) then
      self.door.queue:pop()
      self.door:updateDynamicInfo()
      if self:_checkWaitToggleValidTarget() then
        self:_staffWaitToggle(true) -- Staff are now waiting
      end
    elseif self.humanoids[front] then
      self.door.queue:pop()
      self.door:updateDynamicInfo()
    end
  end
end

--! Handles the departure of a humanoid from the room
--!param humanoid The subject entity
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
  local staff_leaving = false -- used only for staff leaving immediately after a patient

  if class.is(humanoid, Patient) then
    -- Some staff member in the room might be waiting to get to the staffroom.
    for room_humanoid in pairs(self.humanoids) do
      -- A patient leaving allows doctors/nurses inside to go to staffroom, if needed
      -- In a rare case a handyman that just decided he wants to go to the staffroom
      -- could be in the room at the same time as a patient leaves.
      if class.is(room_humanoid, Staff) and not class.is(room_humanoid, Handyman) then
        if room_humanoid.staffroom_needed then
          room_humanoid.staffroom_needed = nil
          room_humanoid:goToStaffRoom()
          staff_leaving = true
        end
      end
    end
    -- There might be other similar rooms with patients queueing
    if self.door.queue and self.door.queue:reportedSize() == 0 and self.is_active then
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
    -- Make patients leave the room (except wards) if there are no longer enough staff
    if not self:testStaffCriteria(self:getRequiredStaffCriteria()) or self:getStaffMember() == nil then
      local call_for_new_staff = self.door.queue:patientSize() > 0
      for room_humanoid in pairs(self.humanoids) do
        if class.is(room_humanoid, Patient) and self:shouldHavePatientReenter(room_humanoid) then
          call_for_new_staff = true
          if self.room_info.id ~= "ward" then
            self:makeHumanoidLeave(room_humanoid)
            room_humanoid:queueAction(self:createEnterAction(room_humanoid))
          end
        end
      end
      -- Call for staff if needed
      if self.is_active and call_for_new_staff then
        self.world.dispatcher:callForStaff(self)
      end
    end
    -- Remove any unwanted moods the staff member might have
    humanoid:setMood("staff_wait", "deactivate")
  end

  -- The player might be waiting to edit this room
  if not self.is_active then
    local people_in_room = 0
    for _ in pairs(self.humanoids) do
      people_in_room = people_in_room + 1
    end
    if people_in_room == 0 then
      self:enterEditMode()
    end
  end
end

function Room:enterEditMode()
  local ui = self.world.ui

  -- If we have the window for this room machine open, close it
  local window = ui:getWindow(UIMachine)
  if window and window.machine and window.machine:getRoom() == self then
    window:close()
  end

  ui:addWindow(UIEditRoom(ui, self))
  ui:setCursor(ui.default_cursor)
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
  if tonumber(self.world.map.level_number) and self.world.room_information_dialogs then
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
  self:calculateHappinessFactor()
end

--! Private function to check for any patients outside the door queueing,
--! or about to come in
--!return (boolean) true if any patient wants to come in
function Room:_arePatientsWantingToEnter()
  local door = self.door
  return (door.queue and door.queue:patientSize() > 0) or
      (door.reserved_for and class.is(door.reserved_for, Patient)) or
      (door.user and class.is(door.user, Patient) and door.user:getCurrentAction().is_entering)
end

--! Check if a room is actively required by patients
--! A room is deemed in demand should any patient be in a state of using, or
--! wanting to use the room.
--!return (boolean) true if the room is currently needed
function Room:isRoomInDemand()
  if self:getPatientCount() > 0 then
    -- Maybe a patient is using the room right now?
    for _, patient in ipairs(self:getPatients()) do
      if not patient:isLeaving() then return true end
    end
  end
  return self:_arePatientsWantingToEnter()
end

--! Try to move a patient from the old room to the new room.
--!param old_room (Room) Room that currently has the patient in the queue.
--!param new_room (Room) Room that wants the patient in the queue.
--!param patient (Humanoid) Patient to move.
--!return (boolean) Whether we are done with the old room (no more patients will come from it).
local function tryMovePatient(old_room, new_room, patient)
  local world = new_room.world

  local px, py = patient.tile_x, patient.tile_y
  -- Don't reroute the patient if he just decided to go to the toilet or is going home
  if patient.going_to_toilet ~= "no" or patient.going_home or patient.going_to_die then
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
      patient:queueAction(new_room:createEnterAction(patient), i)
      break
    end
  end

  -- next_room_to_visit is guarded in checks in WalkAction from being incorrectly
  -- interrupted, there is possibility walk above isn't found and there is no new
  -- room to go to, but this remains mostly safe, see #1561
  patient.next_room_to_visit = new_room
  new_room.door:updateDynamicInfo()
  old_room.door:updateDynamicInfo()

  local interrupted = patient:getCurrentAction()
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
        --Delay so that room is destroyed before the SeekRoom search.
        person:setNextAction(IdleAction():setCount(1))
        person:queueAction(SeekRoomAction(self.room_info.id))
      end
    end
    person:finishAction()
    self.door.reserved_for = nil
  end

  local remove_humanoid = function(humanoid)
    humanoid:queueAction(IdleAction(), 1)
    humanoid.user_of = nil
    -- Make sure any emergency list is not messed up.
    -- Note that these humanoids might just have been kicked. (No hospital set)
    if humanoid.is_emergency then
      table.remove(self.world:getLocalPlayerHospital().emergency_patients, humanoid.is_emergency)
    end
    humanoid:die()
    humanoid:despawn()
    self.world:destroyEntity(humanoid)
  end

  -- Remove all humanoids in the room
  for humanoid, _ in pairs(self.humanoids) do
    remove_humanoid(humanoid)
  end
  self.humanoids = {}
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

  local value_change = self.hospital.research.research_progress[self.room_info].build_cost
  self.hospital:changeValue(value_change * -1)
  self.hospital:changeReputation("room_crash")
  self.crashed = true
  self:deactivate()
end

-- Tells a humanoid in the room to leave it. This can be overridden for special
-- handling, e.g. if the humanoid needs to change before leaving the room.
function Room:makeHumanoidLeave(patient)
  local leave = self:createLeaveAction():setMustHappen(true)
  patient:setNextAction(leave)
end

function Room:makeHumanoidDressIfNecessaryAndThenLeave(humanoid)
  if not humanoid:isLeaving() then
    local leave = self:createLeaveAction():setMustHappen(true)

    if not string.find(humanoid.humanoid_class, "Stripped") then
      --The humanoid is dressed
      humanoid:setNextAction(leave)
      return
    end

    local screen, sx, sy = self.world:findObjectNear(humanoid, "screen")
    local use_screen = UseScreenAction(screen):setMustHappen(true):setIsLeaving(true)

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

    if humanoid:getCurrentAction().name == "use_screen" then
      --The humanoid must be using the screen to undress because this isn't a leaving action:
      if not humanoid:hasDressingAndLeavingAction() then
        humanoid:getCurrentAction().after_use = nil
        humanoid:setNextAction(use_screen)
      end
    else
      --The humanoid undressed but not using use_screen
      humanoid:setNextAction(WalkAction(sx, sy):setMustHappen(true):disableTruncate():setIsLeaving(true))
      humanoid:queueAction(use_screen)
    end

    humanoid:queueAction(leave)
  end
end

--! Deactivate the room from the world.
function Room:deactivate()
  self.is_active = false -- So that no more patients go to it.
  self.world:notifyRoomRemoved(self)

  -- crashRoom might have deactivated the door already
  if self.door.queue then
    self.door.queue:rerouteAllPatients(self.room_info.id)
  end

  self.hospital:removeRatholesAroundRoom(self)
end

function Room:tryToEdit()
  self:deactivate()
  local people_in_room = 0
  -- Tell all humanoids that they should leave
  -- If someone is entering the room right now they are also counted.
  if self.door.user and self.door.user:getCurrentAction().is_entering then
    people_in_room = 1
  end
  for humanoid, _ in pairs(self.humanoids) do
    if not humanoid:isLeaving() then
      if class.is(humanoid, Patient) then
        self:makeHumanoidLeave(humanoid)
        humanoid:queueAction(SeekRoomAction(self.room_info.id))
      else
        humanoid:setNextAction(self:createLeaveAction())
        humanoid:queueAction(MeanderAction())
      end
    end
    people_in_room = people_in_room + 1
  end
  -- If there were no people inside we're ready to edit the room
  if people_in_room == 0 then
    self:enterEditMode()
  end
end

function Room:hasQueueDialog()
  return not self.room_info.has_no_queue_dialog
end

--! Stub to be extended in subclasses, if needed.
function Room:afterLoad(old, new)
  if old < 46 then
    self.humanoids_enroute = {--[[a set rather than a list]]}
  end
  if old < 137 then
    if self.door.queue then
      -- reset expected count so we can recalculate it
      self.door.queue.expected = {}
      self.door.queue.expected_count = 0
      for enroute, callback in pairs(self.humanoids_enroute) do -- Go through all registered callbacks
        local clear_this_callback = true -- Presume the callback must be cleared
        for _, action in pairs(enroute.action_queue) do -- Go through the action queue
          if action.name == "walk" then -- Only look at walk actions
            if self == self.world:getRoom(action.x, action.y) and -- This walk action leads into the room
                self ~= enroute:getRoom() then -- The entity is not already in the room
              clear_this_callback = false -- Assume the callback is valid, don't clear
            end
          end
        end
        if not clear_this_callback then
          -- still expecting
          self.door.queue:expect(enroute, callback)
        end
      end
      self.door:updateDynamicInfo()
    end
    -- no longer using this so empty it
    self.humanoids_enroute = {}
  end
  if old < 186 then
    self:calculateHappinessFactor()
  end
  if old < 233 then
    if self.waiting_staff_member then
      -- Cancel delayed replace existing staff member in room
      self.waiting_staff_member:setNextAction(self:createLeaveAction())
      self.waiting_staff_member:queueAction(MeanderAction())
      self.waiting_staff_member.waiting_on_other_staff = nil
    end
    self.waiting_staff_member = nil
    self.dealt_patient_callback = nil
  end
  -- Patch the saves post 233 that labelled all rooms as having a staff_member_set
  if old >= 233 and old < 235 then
    local room_name = self.room_info.id
    if room_name ~= "ward" and room_name ~= "operating_theatre" and
        room_name ~= "research" then
      self.staff_member_set = nil
    end
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

local window_tile = list_to_set({116, 117, 118, 119, 120, 121, 124, 125, 126, 127})
--! Count the number of windows in the room
--!return (int) Number of windows
function Room:countWindows()
  local map, count = self.world.ui.app.map.th, 0
  for x = self.x, self.x + self.width do
    for y = self.y, self.y + self.height do
      if window_tile[map:getCell(x, y, 2)] or window_tile[map:getCell(x, y, 3)] then
        count = count + 1
      end
    end
  end
  return count
end

--! Get the removal cost
--!return (int) cost of the room
function Room:calculateRemovalCost()
  -- Charge double to clean it up
  local progress = self.hospital.research.research_progress
  local cost = math.floor(progress[self.room_info].build_cost * 2)

  -- Recover some cost as scrap
  for obj, _ in pairs(self.room_info.objects_needed) do
    -- Get how much this item costs.
    local obj_cost = self.hospital:getObjectBuildCost(obj)
    -- recover a percentage of cost as scrap value
    cost = cost - math.floor(obj_cost * COST_RECOVERY)
  end
  return cost
end

--! Calculate the effect the room has on humanoid happiness
function Room:calculateHappinessFactor()
  -- The number of windows affects happiness
  local window_factor, space_factor, window_count = 0, 0, self:countWindows()
  if window_count > 0 then
    if self.room_info.id == "staff_room" then
      -- Staff are pleased to rest in a staff room with windows
      window_count = window_count * 2
    end
    -- More windows help but in smaller increments
   window_factor = math.round(math.log(window_count)) / 1000
  end

  -- Extra space in the room affects happiness
  local extraspace = (self.width * self.height) / (self.room_info.minimum_size * self.room_info.minimum_size)
  if extraspace > 1 then
    -- Greater space helps but in smaller increments
    space_factor = math.round(math.log(extraspace)) / 1000
  end

  self.happiness_factor = window_factor + space_factor
end

----- BEGIN Save game compatibility -----
-- These function are merely for save game compatibility.
-- For 0.69.x gamesaves and below.
-- And they does not participate in the current game logic.
local --[[persistable:room_dealt_with_patient_callback]] function _(staff_humanoid) end
----- END Save game compatibility -----
