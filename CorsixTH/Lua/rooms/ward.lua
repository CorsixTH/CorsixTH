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
room.objects_additional = { "extinguisher", "radiator", "plant", "bin", "bed" }
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
room.maximum_staff = room.required_staff
room.call_sound = "reqd009.wav"

class "WardRoom" (Room)

function WardRoom:WardRoom(...)
  self:Room(...)
end

function WardRoom:roomFinished()
  local fx, fy = self:getEntranceXY(true)
  local objects = self.world:findAllObjectsNear(fx, fy)
  local number = 0
  for object, value in pairs(objects) do
    if object.object_type.id == "bed" then
      number = number + 1
    end
  end
  self.maximum_patients = number
  if not self.hospital:hasStaffOfCategory("Nurse") then
    self.world.ui.adviser
    :say(_S.adviser.room_requirements.ward_need_nurse)
  end
  Room.roomFinished(self)
end

function WardRoom:commandEnteringStaff(humanoid)
  self.staff_member = humanoid
  self:doStaffUseCycle(humanoid)
  return Room.commandEnteringStaff(self, humanoid)
end

function WardRoom:doStaffUseCycle(humanoid)
  local meander_time = math.random(4, 10)
  local desk_use_time = math.random(8, 16)
  
  humanoid:setNextAction{
    name = "meander",
    count = meander_time,
  }
  local obj, ox, oy = self.world:findObjectNear(humanoid, "desk")
  humanoid:queueAction{name = "walk", x = ox, y = oy}
  humanoid:queueAction{name = "use_object",
    object = obj,
    loop_callback = --[[persistable:ward_desk_loop_callback]] function()
      desk_use_time = desk_use_time - 1
      if desk_use_time == 0 then
        self:doStaffUseCycle(humanoid)
      end
    end,
  }
end

function WardRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local bed, pat_x, pat_y = self.world:findFreeObjectNearToUse(patient, "bed")
  if not bed then
    patient:setNextAction(self:createLeaveAction())
    patient:queueAction(self:createEnterAction())
    print("Warning: A patient was called into the ward even though there are no free beds.")
  else
    bed.reserved_for = patient
    local length = math.random(90, 120) * (1.5 - staff.profile.skill)
    local --[[persistable:ward_loop_callback]] function loop_callback(action)
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
      loop_callback = loop_callback,
      after_use = after_use,
    }
  end

  return Room.commandEnteringPatient(self, patient)
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
  Room.afterLoad(self, old, new)
end

return room
