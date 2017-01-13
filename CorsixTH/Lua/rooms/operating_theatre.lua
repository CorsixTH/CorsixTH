--[[ Copyright (c) 2010 Peter "Corsix" Cawley

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

local room = {}
room.id = "operating_theatre"
room.level_config_id = 10
room.class = "OperatingTheatreRoom"
room.name = _S.rooms_short.operating_theatre
room.long_name = _S.rooms_long.operating_theatre
room.tooltip = _S.tooltip.rooms.operating_theatre
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = {
  operating_table = 1,
  surgeon_screen = 1,
  op_sink1 = 1,
  x_ray_viewer = 1
}
room.build_preview_animation = 5080
room.categories = {
  treatment = 3,
}
room.minimum_size = 6
room.wall_type = "white"
room.floor_tile = 21
room.swing_doors = true
room.required_staff = {
  Surgeon = 2,
}
room.call_sound = "reqd010.wav" -- TODO: There is also an unused sound
-- "Another surgeon needed [...]", reqd011.wav
-- room.handyman_call_sound = "maint007.wav" TODO: No sound for this room?

class "OperatingTheatreRoom" (Room)

---@type OperatingTheatreRoom
local OperatingTheatreRoom = _G["OperatingTheatreRoom"]

function OperatingTheatreRoom:OperatingTheatreRoom(...)
  self:Room(...)
  self.staff_member_set = {}
end

function OperatingTheatreRoom:roomFinished()
  -- Find the X-ray viewer
  local fx, fy = self:getEntranceXY(true)
  local objects = self.world:findAllObjectsNear(fx, fy)
  for object in pairs(objects) do
    local id = object.object_type.id
    if id == "x_ray_viewer" then
      self[id] = object
    end
  end
  -- Tell the player what is missing, if anything.
  if not self.hospital:hasRoomOfType("ward") then
    self.world.ui.adviser:say(_A.room_requirements.op_need_ward)
  end
  if not self.hospital:hasStaffOfCategory("Surgeon") then
    self.world.ui.adviser:say(_A.room_requirements.op_need_two_surgeons)
  elseif self.hospital:hasStaffOfCategory("Surgeon") == 1 then
    self.world.ui.adviser:say(_A.room_requirements.op_need_another_surgeon)
  end
  return Room.roomFinished(self)
end

local function wait_for_object(humanoid, obj, must_happen)
  assert(type(must_happen) == "boolean", "must happen must be true or false")

  local loop_callback_wait = --[[persistable:operatring_theatre_wait]] function(action)
    if action.todo_interrupt or not obj.user then
      humanoid:finishAction(action)
    else
      humanoid:queueAction(IdleAction():setCount(5):setMustHappen(true), 0)
    end
  end

  return IdleAction():setMustHappen(must_happen):setLoopCallback(loop_callback_wait)
end

--! Returns true if an operation is ongoing
function OperatingTheatreRoom:isOperating()
  for k, _ in pairs(self.staff_member_set) do
    if k.action_queue[1].name == "multi_use_object" then
      return true
    end
  end

  return false
end

--! Builds the second operation action (i.e. with the surgeon whose we
--! see the back). Called either when the operation starts or when the
--! operation is resumed after interruption caused by the picking up of
--! the second surgeon.
--! Note: Must be part of OperatingTheatreRoom and not a local function
--! because of the use in the persisted callback function operation_standby.
--!param multi_use (action): the first operation action (built with via buildTableAction1()).
--!param operation_table_b (OperatingTable): slave object representing the operation table.
function OperatingTheatreRoom._buildTableAction2(multi_use, operation_table_b)
  local num_loops = math.random(2, 5)

  local loop_callback_use_object = --[[persistable:operatring_theatre_use_callback]] function(action)
    num_loops = num_loops - 1
    if num_loops <= 0 then
      action.prolonged_usage = false
    end
  end

  local after_use_use_object = --[[persistable:operatring_theatre_after_use]] function()
    multi_use.prolonged_usage = false
  end

  return UseObjectAction(operation_table_b):setLoopCallback(loop_callback_use_object)
      :setAfterUse(after_use_use_object):setMustHappen(true):disableTruncate()
end

function OperatingTheatreRoom:commandEnteringStaff(staff)
  -- Put surgeon outfit on
  local screen, screen_x, screen_y = self.world:findObjectNear(staff, "surgeon_screen")
  staff:walkTo(screen_x, screen_y)
  staff:queueAction(wait_for_object(staff, screen, false))
  staff:queueAction(UseScreenAction(screen))

  -- Resume operation if already ongoing
  if self:isOperating() then
    local surgeon1 = next(self.staff_member_set)
    local ongoing_action = surgeon1.action_queue[1]
    assert(ongoing_action.name == "multi_use_object")

    local table, table_x, table_y = self.world:findObjectNear(staff, "operating_table_b")
    self:queueWashHands(staff)
    staff:queueAction(WalkAction(table_x, table_y))
    staff:queueAction(self._buildTableAction2(ongoing_action, table))
  end

  self.staff_member_set[staff] = true

  -- Wait around for patients
  local loop_callback_more_patients = --[[persistable:operatring_theatre_after_surgeon_clothes_on]] function()
    self.staff_member_set[staff] = "ready"
    self:tryAdvanceQueue()
  end
  staff:queueAction(MeanderAction():setMustHappen(true):setLoopCallback(loop_callback_more_patients))

  -- Ensure that surgeons turn back into doctors when they leave
  staff:queueAction(WalkAction(screen_x, screen_y):setMustHappen(true):setIsLeaving(true)
      :truncateOnHighPriority())
  staff:queueAction(UseScreenAction(screen):setMustHappen(true):setIsLeaving(true))

  return Room.commandEnteringStaff(self, staff, true)
end

function OperatingTheatreRoom:setStaffMembersAttribute(attribute, value)
  for staff_member, _ in pairs(self.staff_member_set) do
    staff_member[attribute] = value
  end
end

-- Returns the current staff member. if there are currently two surgeons it returns
-- the one with higher tiredness.
function OperatingTheatreRoom:getStaffMember()
  local staff
  for staff_member, _ in pairs(self.staff_member_set) do
    if staff and not staff.fired then
      if staff.attributes["fatigue"] < staff_member.attributes["fatigue"] then
        staff = staff_member
      end
    else
      staff = staff_member
    end
  end
  return staff
end

--! Builds the first operation action (i.e. with the surgeon whose we see the front).
--!param surgeon1 (Staff): the surgeon who does this operation action. He must
--! be the same as the surgeon who gets the action on his queue.
--!param patient (Patient): the patient to be operated.
--!param operation_table (OperatingTable): master object representing
--! the operation table.
function OperatingTheatreRoom:buildTableAction1(surgeon1, patient, operation_table)
  local loop_callback_multi_use = --[[persistable:operatring_theatre_multi_use_callback]] function(_)
    -- dirty hack to make the truncated animation work
    surgeon1.animation_idx = nil
  end

  local after_use_table = --[[persistable:operatring_theatre_table_after_use]] function()
    self:dealtWithPatient(patient)
    -- Tell the patient that it's time to leave, but only if the first action
    -- is really an idle action.
    if patient.action_queue[1].name == "idle" then
      patient:finishAction()
    end
  end

  return MultiUseObjectAction(operation_table, patient):setProlongedUsage(true)
      :setLoopCallback(loop_callback_multi_use):setAfterUse(after_use_table)
      :setMustHappen(true):disableTruncate()
end

--! Sends the surgeon to the nearest operation sink ("op_sink1")
--! and makes him wash his hands
--!param at_front (boolean): If true, add the actions at the front the action queue.
--! Add the actions at the end of the queue otherwise.
--! Default value is true.
function OperatingTheatreRoom:queueWashHands(surgeon, at_front)
  local sink, sink_x, sink_y = self.world:findObjectNear(surgeon, "op_sink1")
  local walk = WalkAction(sink_x, sink_y):setMustHappen(true):disableTruncate()
  local wait = wait_for_object(surgeon, sink, true)
  local wash = UseObjectAction(sink):setMustHappen(true)

  for pos, action in pairs({walk, wait, wash}) do
    if (at_front) then
      surgeon:queueAction(action, pos)
    else
      surgeon:queueAction(action)
    end
  end
end

--! Turn on/off x-ray viewer - if it's been found
--!param turn_on (boolean): true to switch on and false to switch off
function OperatingTheatreRoom:setXRayOn(turn_on)
  if self.x_ray_viewer then
    self.x_ray_viewer:setLayer(11, (turn_on and 2 or 0))
  end
end

function OperatingTheatreRoom:commandEnteringPatient(patient)
  -- Turn on x-ray viewer
  self:setXRayOn(true)

  -- Identify the staff
  local surgeon1 = next(self.staff_member_set)
  local surgeon2 = next(self.staff_member_set, surgeon1)
  assert(surgeon1 and surgeon2, "Not enough staff in operating theatre")

  -- Patient changes into surgical gown
  local screen, sx, sy = self.world:findObjectNear(patient, "surgeon_screen")
  patient:walkTo(sx, sy)
  patient:queueAction(UseScreenAction(screen))

  -- Meanwhile, surgeons wash their hands
  -- TODO: They sometimes overlap each other when doing that. Can we avoid that?
  self:queueWashHands(surgeon1, true)
  self:queueWashHands(surgeon2, true)

  local num_ready = {0}
  ----- BEGIN Save game compatibility -----
  -- These function are merely for save game compatibility.
  -- And they does not participate in the current game logic.
  -- Do not move or edit
  local --[[persistable:operatring_theatre_wait_for_ready]] function wait_for_ready(action)
    action.on_interrupt = nil
    if not action.done_ready then
      num_ready[1] = num_ready[1] + 1
      action.done_ready = true
    end
    if num_ready[1] == 3 then
      surgeon1:finishAction()
      surgeon2:finishAction()
    end
  end
  local after_use = --[[persistable:operatring_theatre_after_multi_use]] function()
    self:dealtWithPatient(patient)
    patient:finishAction()
  end
  ----- END Save game compatibility -----

  local --[[persistable:operatring_theatre_operation_standby]] function operation_standby(action, humanoid)
    action.on_interrupt = nil
    if not action.done_ready then
      num_ready[1] = num_ready[1] + 1
      action.done_ready = true
    end
    if self.staff_member_set[humanoid] and self.staff_member_set[humanoid] == "abort" then
      humanoid:finishAction()
    elseif num_ready[1] == 3 then
      -- Only if everyone (2 Surgeons and Patient) ready, we schedule the operation action
      local obj, _, _ = self.world:findObjectNear(surgeon1, "operating_table")

      local table_action1 = self:buildTableAction1(surgeon1, patient, obj)
      surgeon1:queueAction(table_action1, 1)

      obj, _, _ = self.world:findObjectNear(surgeon2, "operating_table_b")
      surgeon2:queueAction(self._buildTableAction2(table_action1, obj), 1)

      -- Kick off
      surgeon1:finishAction()
      surgeon2:finishAction()
    end
  end

  ---- Everyone standby...and sync start the operation
  --
  -- first surgeon walk over to the operating table
  local obj, ox, oy = self.world:findObjectNear(surgeon1, "operating_table")
  surgeon1:queueAction(WalkAction(ox, oy):setMustHappen(true):disableTruncate(), 4)
  surgeon1:queueAction(IdleAction():setLoopCallback(operation_standby):setMustHappen(true), 5)

  -- Patient walk to the side of the operating table
  ox, oy = obj:getSecondaryUsageTile()
  patient:queueAction(WalkAction(ox, oy):setMustHappen(true):disableTruncate())
  patient:queueAction(IdleAction():setLoopCallback(operation_standby):setMustHappen(true))

  -- Patient changes out of the gown afterwards
  patient:queueAction(WalkAction(sx, sy):setMustHappen(true):disableTruncate())
  patient:queueAction(UseScreenAction(screen):setMustHappen(true))

  -- Meanwhile, second surgeon walks over to other side of operating table
  local _
  _, ox, oy = self.world:findObjectNear(surgeon1, "operating_table_b")
  surgeon2:queueAction(WalkAction(ox, oy):setMustHappen(true):disableTruncate(), 4)
  surgeon2:queueAction(IdleAction():setLoopCallback(operation_standby):setMustHappen(true), 5)

  return Room.commandEnteringPatient(self, patient)
end

function OperatingTheatreRoom:onHumanoidLeave(humanoid)
  self.staff_member_set[humanoid] = nil

  if class.is(humanoid, Patient) then
    -- Turn off x-ray viewer
    -- (FIXME: would be better when patient dress back?)
    self:setXRayOn(false)

    local surgeon1 = next(self.staff_member_set)
    local surgeon2 = next(self.staff_member_set, surgeon1)
    if surgeon1 then
      self.staff_member_set[surgeon1] = "abort"
    end
    if surgeon2 then
      self.staff_member_set[surgeon2] = "abort"
    end
  end
  return Room.onHumanoidLeave(self, humanoid)
end

function OperatingTheatreRoom:canHumanoidEnter(humanoid)
  local can = Room.canHumanoidEnter(self, humanoid)
  if can and class.is(humanoid, Patient) then
    -- Patients can only enter once all doctors are in surgeon clothes
    for staff, is_ready in pairs(self.staff_member_set) do
      if staff.humanoid_class == "Doctor" or is_ready ~= "ready" then
        return false
      end
    end
  end
  return can
end

return room
