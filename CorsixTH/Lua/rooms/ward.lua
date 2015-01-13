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
  for object, value in pairs(objects) do
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
  local desk_use_time = math.random(8, 16)

  humanoid:setNextAction{
    name = "meander",
    count = meander_time,
  }
  local obj, ox, oy = self.world:findFreeObjectNearToUse(humanoid, "desk")
   if obj then
    obj.reserved_for = humanoid
    humanoid:walkTo(ox, oy)
    if obj.object_type.id == "desk" then
      local desk_use_time = math.random(7, 14)
      humanoid:queueAction {
        name = "use_object",
        object = obj,
    loop_callback = --[[persistable:ward_desk_loop_callback]] function()
      desk_use_time = desk_use_time - 1
      if desk_use_time == 0 then
        self:doStaffUseCycle(humanoid)
      end
    end,
  }
  end

  end
  local num_meanders = math.random(2, 4)
  humanoid:queueAction {
    name = "meander",
    loop_callback = --[[persistable:ward_meander_loop_callback]] function(action)
      num_meanders = num_meanders - 1
      if num_meanders == 0 then
        self:doStaffUseCycle(humanoid)
      end
    end
  }
end


-- TODO the nurse should not leave the ward if there are beds in use, therefore prevent her from being picked up
-- and have a system that stops patients entering the ward if she is in need of taking a break or being called elsewhere.
function WardRoom:commandEnteringPatient(patient)
  local staff = next(self.staff_member_set) or self.staff_member
  local bed, pat_x, pat_y = self.world:findFreeObjectNearToUse(patient, "bed")
  self:setStaffMembersAttribute("dealing_with_patient", nil)
  if not bed then
    patient:setNextAction(self:createLeaveAction())
    patient:queueAction(self:createEnterAction(patient))
    print("Warning: A patient was called into the ward even though there are no free beds.")
  else
    bed.reserved_for = patient
    self:countWorkingNurses()
    local length = (math.random(200, 800) * (1.5 - staff.profile.skill))  / self.nursecount -- reduce time in ward if there is more than one nurse on duty
    local --[[persistable:ward_loop_callback]] function loop_callback(action)
    -- TODO Perhaps it should take longer if there are more used beds!
      if length <= 0 then
        action.prolonged_usage = false
      end
      length = length - 1
    end
    local after_use = --[[persistable:ward_after_use]] function()
      self:dealtWithPatient(patient)
    end
    patient:walkTo(pat_x, pat_y)
    patient:queueAction{
      name = "use_object",
      object = bed,
      prolonged_usage = true,
      loop_callback = loop_callback,
      after_use = after_use,
    }
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

    local function checkLocation(x, y)
      if self.world:getRoom(x, y)
      or not map:getCellFlags(x, y, flags).passable then
        local message = "Warning: An update has resolved a problem concerning "
        .. "swing doors, but not all tiles adjacent to them could be fixed."
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
      nurse:queueAction({name = "meander"})
    end
  end
  Room.afterLoad(self, old, new)
end

return room
