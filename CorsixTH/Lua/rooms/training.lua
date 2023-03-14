--[[ Copyright (c) 2010 Justin Pasher
Copyright (c) 2023 lewri

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
room.id = "training"
room.vip_must_visit = false
room.level_config_id = 22
room.class = "TrainingRoom"
room.long_name = _S.rooms_long.training_room
room.name = _S.rooms_short.training_room
room.tooltip = _S.tooltip.rooms.training_room
room.objects_additional = { "extinguisher", "radiator", "plant", "bin", "lecture_chair", "bookcase", "skeleton" }
room.objects_needed = { lecture_chair = 1, projector = 1 }
room.build_preview_animation = 5086
room.categories = {
  facilities = 4,
}
room.minimum_size = 4
room.wall_type = "green"
room.floor_tile = 17
room.has_no_queue_dialog = true

class "TrainingRoom" (Room)

---@type TrainingRoom
local TrainingRoom = _G["TrainingRoom"]

function TrainingRoom:TrainingRoom(...)
  self:Room(...)
end

function TrainingRoom:roomFinished()
  -- Training rate and max occupancy based on objects in the room
  local fx, fy = self:getEntranceXY(true)
  local objects = self.world:findAllObjectsNear(fx, fy)
  local chairs = 0
  for object, _ in pairs(objects) do
    if object.object_type.id == "lecture_chair" then
      chairs = chairs + 1
    end
  end
  -- Total staff occupancy: number of lecture chairs plus projector
  self.maximum_staff = { Doctor = chairs + 1 }
  self.training_factor = self:calculateTrainingFactor(objects)

  -- Also tell the player if he/she doesn't have a consultant yet.
  if self.hospital:countStaffOfCategory("Consultant", 1) == 0 then
    self.hospital:giveAdvice({_A.room_requirements.training_room_need_consultant})
  end
  Room.roomFinished(self)
end

--! Determing the training factor of this room for teaching specialisms
--!param objects (table) the list of objects in this room
--!return total (number) The final training factor
function TrainingRoom:calculateTrainingFactor(objects)
  -- Tally relevant objects that affect training
  local function countTrainingObjects()
    local projectors = 0 -- There should only ever be one
    local skeletons = 0
    local bookcases = 0
    for object, _ in pairs(objects) do
      if object.object_type.id == "skeleton" then
        skeletons = skeletons + 1
      elseif object.object_type.id == "bookcase" then
        bookcases = bookcases + 1
      elseif object.object_type.id == "projector" then
        projectors = projectors + 1
      end
    end
    return {[0] = projectors, bookcases, skeletons} -- [0] to align with level_config
  end
  -- Work out total training factor (averaged of all relevant items)
  -- param factors(table) An array containing a count of each object and its raw training value
  -- returns the total effect
  local function calculateTotalEffect(factors)
    local count, total = 0, 0
    for _, factor in pairs(factors) do
      count = count + factor.c
      total = total + (factor.c * factor.v)
    end
    return total / count
  end

  -- Object values and training rate set in level config
  local level_config = self.world.map.level_config
  local training_objects = countTrainingObjects()
  -- Consolidate elements of training factor to an array, where c is the number of
  -- objects and v is the raw training value
  local training_factors = {
    projectors = {c = training_objects[0], v = level_config.gbv.TrainingValue[0]},
    bookcases  = {c = training_objects[1], v = level_config.gbv.TrainingValue[1]},
    skeletons  = {c = training_objects[2], v = level_config.gbv.TrainingValue[2]},
  }
  return calculateTotalEffect(training_factors)
end

function TrainingRoom:getStaffCount()
  local count = 0
  for humanoid in pairs(self.humanoids) do
    if class.is(humanoid, Staff) then
      count = count + 1
    end
  end
  return count
end

function TrainingRoom:testStaffCriteria(criteria, extra_humanoid)
  if extra_humanoid and extra_humanoid.profile and
      extra_humanoid.profile.is_consultant and self.staff_member then
    -- Training room can only have one consultant
    return false
  end
  return Room.testStaffCriteria(self, criteria, extra_humanoid)
end

function TrainingRoom:getTrainingFactor()
  return self.training_factor
end

function TrainingRoom:getMaximumStaffCriteria()
  return self.maximum_staff
end

function TrainingRoom:doStaffUseCycle(humanoid)
  local projector, ox, oy = self.world:findObjectNear(humanoid, "projector")
  humanoid:queueAction(WalkAction(ox, oy))
  local projector_use_time = math.random(6,20)

  local loop_callback_training = --[[persistable:training_loop_callback]] function()
    projector_use_time = projector_use_time - 1
    if projector_use_time == 0 then
      local skeleton, sox, soy = self.world:findFreeObjectNearToUse(humanoid, "skeleton", "near")
      local bookcase, box, boy = self.world:findFreeObjectNearToUse(humanoid, "bookcase", "near")
      if math.random(0, 1) == 0 and bookcase then skeleton = nil end -- choose bookcase or skeleton
      if skeleton then
        humanoid:walkTo(sox, soy)
        for _ = 1, math.random(3, 10) do
          humanoid:queueAction(UseObjectAction(skeleton))
        end
      elseif bookcase then
        humanoid:walkTo(box, boy)
        for _ = 1, math.random(3, 10) do
          humanoid:queueAction(UseObjectAction(bookcase))
        end
      end
      -- go back to the projector
      self:doStaffUseCycle(humanoid)
    elseif projector_use_time < 0 then
      -- reset variable to avoid potential overflow (over a VERY long
      -- period of time)
      projector_use_time = 0
    end
  end

  humanoid:queueAction(UseObjectAction(projector):setLoopCallback(loop_callback_training))
end

function TrainingRoom:onHumanoidEnter(humanoid)
  if humanoid.humanoid_class ~= "Doctor" then
    -- use default behavior for staff other than doctors
    return Room.onHumanoidEnter(self, humanoid)
  end

  assert(not self.humanoids[humanoid], "Humanoid entering a room that they are already in")
  humanoid.in_room = self
  humanoid.last_room = self -- Remember where the staff was for them to come back after staffroom rest

  humanoid:setCallCompleted()
  self:commandEnteringStaff(humanoid)
  self.humanoids[humanoid] = true
  self:tryAdvanceQueue()
end

function TrainingRoom:commandEnteringStaff(humanoid)
  local obj, ox, oy
  local profile = humanoid.profile

  if profile.humanoid_class == "Doctor" then
    if profile.is_consultant then
      -- Consultant entered/placed in room.
      obj, ox, oy = self.world:findObjectNear(humanoid, "projector")
      local projector = obj
      -- Check if another consultant is teaching the lecture
      if self.staff_member then
        -- Release projector and dismiss current lector
        projector.reserved_for = nil
        self.staff_member:setNextAction(self:createLeaveAction(), true)
        self.staff_member:queueAction(MeanderAction())
      end
      -- Start lecture with entered consultant
      projector.reserved_for = humanoid
      humanoid:walkTo(ox, oy)
      self:doStaffUseCycle(humanoid)
      self:setStaffMember(humanoid)
    else
      -- Student entered/placed in room
      obj, ox, oy = self.world:findFreeObjectNearToUse(humanoid, "lecture_chair")
      local lecture_chair = obj
      -- If any chair available
      if lecture_chair then
        -- Student occupy chair
        lecture_chair.reserved_for = humanoid
        humanoid:walkTo(ox, oy)
        humanoid:queueAction(UseObjectAction(obj))
        humanoid:queueAction(MeanderAction())
      else
        -- Student leave room
        self.hospital:giveAdvice({_A.staff_place_advice.not_enough_lecture_chairs})
        humanoid:setNextAction(self:createLeaveAction())
        humanoid:queueAction(MeanderAction())
        humanoid.last_room = nil -- Prevent Doctor returning to this room automatically
      end
    end
  elseif humanoid.humanoid_class ~= "Handyman" then
    self.hospital:giveAdvice({_A.staff_place_advice.only_doctors_in_room
      :format(_S.rooms_long.training_room)})
    humanoid:setNextAction(self:createLeaveAction())
    humanoid:queueAction(MeanderAction())
    return
  end

  return Room.commandEnteringStaff(self, humanoid, true)
end

function TrainingRoom:onHumanoidLeave(humanoid)
  if humanoid.humanoid_class == "Doctor" then
    -- unreserve whatever it was they we using
    local fx, fy = self:getEntranceXY(true)
    local objects = self.world:findAllObjectsNear(fx,fy)
    for object, _ in pairs(objects) do
      if object.reserved_for == humanoid then
        object:removeReservedUser()
      end
    end

  end

  Room.onHumanoidLeave(self, humanoid)
end

function TrainingRoom:afterLoad(old, new)
  if old < 234 then
    local fx, fy = self:getEntranceXY(true)
    local objects = self.world:findAllObjectsNear(fx, fy)
    self.training_factor = self:calculateTrainingFactor(objects)
  end
  Room.afterLoad(self, old, new)
end

return room
