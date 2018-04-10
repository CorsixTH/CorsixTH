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

local room = {}
room.id = "ward"
room.level_config_id = 9
room.class = "WardRoom"
room.name = _S.rooms_short.ward
room.tooltip = _S.tooltip.rooms.ward
room.long_name = _S.rooms_long.ward
room.objects_additional = {
  "extinguisher",
  "radiator",
  "plant",
  "desk",
  "bin",
  "bed" }
room.objects_needed = { desk = 1, bed = 1 }
room.build_preview_animation = 910
room.categories = {
  treatment = 2,
  diagnosis = 9,
}
room.minimum_size = 6
room.wall_type = "white"
room.floor_tile = 21
room.swing_doors = true
room.required_staff = {
  Nurse = 1,
}

room.call_sound = "reqd009.wav"

class "WardRoom" (Room)

---@type WardRoom
local WardRoom = _G["WardRoom"]

function WardRoom:WardRoom(...)
  self:Room(...)
  self.staff_member_set = {}
end

function WardRoom:roomFinished()
  local fx, fy = self:getEntranceXY(true)
  local objects = self.world:findAllObjectsNear(fx, fy)
  local beds = 0
  local desks = 0
  for object, _ in pairs(objects) do
    if object.object_type.id == "bed" then
      beds = beds + 1
    end
    if object.object_type.id == "desk" then
      desks = desks + 1
    end
  end
  self.maximum_staff = {
    Nurse = desks,
  }
  self.maximum_patients = beds
  if not self.hospital:hasStaffOfCategory("Nurse") then
    self.world.ui.adviser
    :say(_A.room_requirements.ward_need_nurse)
  end
  Room.roomFinished(self)
end

function WardRoom:getMaximumStaffCriteria()
  return self.maximum_staff
end

function WardRoom:commandEnteringStaff(humanoid)
  self.staff_member_set[humanoid] = true
  self:doStaffUseCycle(humanoid)
  return Room.commandEnteringStaff(self, humanoid, true)
end

function WardRoom:doStaffUseCycle(humanoid)
  local meander_time = math.random(4, 10)
  humanoid:setNextAction(MeanderAction():setCount(meander_time))

  local obj, ox, oy = self.world:findFreeObjectNearToUse(humanoid, "desk")
  if obj then
    obj.reserved_for = humanoid
    humanoid:walkTo(ox, oy)
    if obj.object_type.id == "desk" then
      local desk_use_time = math.random(7, 14)
      local desk_loop = --[[persistable:ward_desk_loop_callback]] function()
        desk_use_time = desk_use_time - 1
        if desk_use_time == 0 then
          self:doStaffUseCycle(humanoid)
        end
      end

      humanoid:queueAction(UseObjectAction(obj):setLoopCallback(desk_loop))
    end
  end

  local num_meanders = math.random(2, 4)
  local meanders_loop = --[[persistable:ward_meander_loop_callback]] function(action)
    num_meanders = num_meanders - 1
    if num_meanders == 0 then
      self:doStaffUseCycle(humanoid)
    end
  end
  humanoid:queueAction(MeanderAction():setLoopCallback(meanders_loop))
end

-- This function is called once per tick per ward, unless there's no patient in the ward
function WardRoom:getHealingAmount()
  self.patient_idx = 0 -- Will be reset to nil after handling the last patient each tick
  local nurse_force = 0	-- The total amount of work the nurses do
  local best_staff = 0 -- Used for diagnosis quality
  for humanoid in pairs(self.humanoids) do
    if not humanoid:isLeaving() then
      if class.is(humanoid, Patient) then
        self.patient_idx = self.patient_idx + 1 -- Count the number of patients
      elseif humanoid.humanoid_class == "Nurse" then
        local nurse_quality = humanoid:getServiceQuality()
        nurse_force = nurse_force + 1.0 + nurse_quality
        if nurse_quality > best_staff then
          best_staff = nurse_quality
          self.staff_member = humanoid -- Used in \patient.lua\completeDiagnosticStep()
        end
      end
    end
  end
  self.healing_amount = nurse_force / (1 + self.patient_idx)
end

function WardRoom:commandEnteringPatient(patient)
  local bed, pat_x, pat_y = self.world:findFreeObjectNearToUse(patient, "bed")
  self:setStaffMembersAttribute("dealing_with_patient", nil)
  if not bed then
    patient:setNextAction(self:createLeaveAction())
    patient:queueAction(self:createEnterAction(patient))
    print("Warning: A patient was called into the ward even though there are no free beds.")
  else
    bed.reserved_for = patient
    local amount_to_heal = math.random(150, 450)
    local --[[persistable:ward_loop_callback]] function loop_callback(action)
      if not self.patient_idx then -- This is the first patient for the current tick
	    self:getHealingAmount() -- Evaluate the workload
      end
      --print(self.patient_idx, self.healing_amount, amount_to_heal)
      amount_to_heal = amount_to_heal - self.healing_amount
      if amount_to_heal < 0 then -- The patient is healed or diagnosed
	    action.prolonged_usage = false
      end
      if self.patient_idx == 1 then -- This was the last patient, set up for the next tick
	    self.patient_idx = nil -- Erase the temporary field
      else -- Set up for the next patient
	    self.patient_idx = self.patient_idx - 1
      end
    end
    local after_use = --[[persistable:ward_after_use]] function()
      self:dealtWithPatient(patient)
    end
    patient:walkTo(pat_x, pat_y)
    patient:queueAction(UseObjectAction(bed):setProlongedUsage(true):setLoopCallback(loop_callback)
        :setAfterUse(after_use))
  end
  return Room.commandEnteringPatient(self, patient)
end

-- Returns the staff member with the minimum amount of skill. Perhaps we should consider tiredness too
function WardRoom:getStaffMember()
  local staff
  for staff_member, _ in pairs(self.staff_member_set) do
    if staff and not staff.fired then
      if staff.profile.skill > staff_member.profile.skill then
        staff = staff_member
      end
    else
      staff = staff_member
    end
  end
  return staff
end

function WardRoom:setStaffMember(staff)
  self.staff_member_set[staff] = true
end

function WardRoom:countWorkingNurses()
  local staff = next(self.staff_member_set)
  self.nursecount = 0
  for staff_member, _ in pairs(self.staff_member_set) do
    if staff then
      staff = staff_member
      self.nursecount = self.nursecount + 1
    end
  end
end

function WardRoom:setStaffMembersAttribute(attribute, value)
  for staff_member, _ in pairs(self.staff_member_set) do
    staff_member[attribute] = value
  end
end

function WardRoom:onHumanoidLeave(humanoid)
  self.staff_member_set[humanoid] = nil
  Room.onHumanoidLeave(self, humanoid)
end

function WardRoom:afterLoad(old, new)
  if old < 11 then
    -- Make sure all three tiles outside of the door are unbuildable.
    local door = self.door
    local x = door.tile_x
    local y = door.tile_y
    local dir = door.direction
    local map = self.world.map.th
    local flags = {}

    local function checkLocation(xpos, ypos)
      if self.world:getRoom(xpos, ypos) or not map:getCellFlags(xpos, ypos, flags).passable then
        local message = "Warning: An update has resolved a problem concerning " ..
            "swing doors, but not all tiles adjacent to them could be fixed."
        self.world.ui:addWindow(UIInformation(self.world.ui, {message}))
        return false
      end
      return true
    end
    if dir == "west" then -- In west or east wall
      if self.world:getRoom(x, y) == self then -- In west wall
        if checkLocation(x - 1, y + 1) then
          map:setCellFlags(x - 1, y + 1, {buildable = false})
        end
      else -- East wall
        if checkLocation(x, y + 1) then
          map:setCellFlags(x, y + 1, {buildable = false})
        end
      end
    else -- if dir == "north", North or south wall
      if self.world:getRoom(x, y) == self then -- In north wall
        if checkLocation(x + 1, y - 1) then
          map:setCellFlags(x + 1, y - 1, {buildable = false})
        end
      else -- South wall
        if checkLocation(x + 1, y) then
          map:setCellFlags(x + 1, y, {buildable = false})
        end
      end
    end
  end
  if old < 74 then
    -- add some new variables
    self.staff_member_set = {}
    self.nursecount = 0
    -- reset any wards that already exist
    self:roomFinished()
    -- if there is already a nurse in the ward
    -- make her leave so she gets counted properly
    local nurse = self.staff_member
    if nurse then
      nurse:setNextAction(self:createLeaveAction())
      nurse:queueAction(MeanderAction())
    end
  end
  Room.afterLoad(self, old, new)
end

return room
