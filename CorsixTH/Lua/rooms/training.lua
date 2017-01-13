--[[ Copyright (c) 2010 Justin Pasher

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
  local skeletons = 0
  local bookcases = 0
  for object, _ in pairs(objects) do
    if object.object_type.id == "lecture_chair" then
      chairs = chairs + 1
    elseif object.object_type.id == "skeleton" then
      skeletons = skeletons + 1
    elseif object.object_type.id == "bookcase" then
      bookcases = bookcases + 1
    end
  end
  -- Total staff occupancy: number of lecture chairs plus projector
  self.maximum_staff = { Doctor = chairs + 1 }
  -- factor is divided by ten so the result from new algroithm will be similar to the old algorithm
  self.training_factor = self:calculateTrainingFactor(skeletons, bookcases) / 10.0

  -- Also tell the player if he/she doesn't have a consultant yet.
  if not self.hospital:hasStaffOfCategory("Consultant") then
    local text = _A.room_requirements.training_room_need_consultant
    self.world.ui.adviser:say(text)
  end
  Room.roomFinished(self)
end

function TrainingRoom:calculateTrainingFactor(skeletons, bookcases)
  -- TODO: tweak/change this function, used in Staff:trainSkill(...)
  -- Object values and training rate set in level config
  local level_config = self.world.map.level_config
  local proj_val = 10
  local book_val = 15
  local skel_val = 20
  local training_rate = 40
  if level_config and level_config.gbv.TrainingRate then
    book_val = level_config.gbv.TrainingValue[1]
    skel_val = level_config.gbv.TrainingValue[2]
    training_rate = level_config.gbv.TrainingRate
  end
  -- Training factor is just everything added together
  return proj_val + skeletons*skel_val + bookcases*book_val + training_rate
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
    -- Training room can only have on consultant
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
      if math.random(0, 1) == 0 and bookcase then skeleton = nil end -- choose one
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

  --entering humanoids are no longer enroute
  if self.humanoids_enroute[humanoid] then
    self.humanoids_enroute[humanoid] = nil -- humanoid is no longer walking to this room
  end

  humanoid:setCallCompleted()
  self:commandEnteringStaff(humanoid)
  self.humanoids[humanoid] = true
  self:tryAdvanceQueue()
end

function TrainingRoom:commandEnteringStaff(humanoid)
  local obj, ox, oy
  local profile = humanoid.profile

  if profile.humanoid_class == "Doctor" then
    -- Consultants try to use the projector and/or skeleton
    if profile.is_consultant then
      obj, ox, oy = self.world:findFreeObjectNearToUse(humanoid, "projector")
      if self.staff_member then
        if self.waiting_staff_member then
          local staff = self.waiting_staff_member
          staff.waiting_on_other_staff = nil
          staff:setNextAction(self:createLeaveAction())
          staff:queueAction(MeanderAction())
        end
        humanoid.waiting_on_other_staff = true
        humanoid:setNextAction(MeanderAction())
        self.waiting_staff_member = humanoid
        self.staff_member:setNextAction(self:createLeaveAction())
        self.staff_member:queueAction(MeanderAction())
      else
        if obj then
          obj.reserved_for = humanoid
          humanoid:walkTo(ox, oy)
          self:doStaffUseCycle(humanoid)
          self:setStaffMember(humanoid)
        else
          humanoid:setNextAction(self:createLeaveAction())
          humanoid:queueAction(MeanderAction())
        end
      end
    else
      obj, ox, oy = self.world:findFreeObjectNearToUse(humanoid, "lecture_chair")
      if obj then
        obj.reserved_for = humanoid
        humanoid:walkTo(ox, oy)
        humanoid:queueAction(UseObjectAction(obj))
        humanoid:queueAction(MeanderAction())
      else
        humanoid:setNextAction(self:createLeaveAction())
        humanoid:queueAction(MeanderAction())
        humanoid.last_room = nil
      end
    end
  elseif humanoid.humanoid_class ~= "Handyman" then
    self.world.ui.adviser:say(_A.staff_place_advice.only_doctors_in_room
    :format(_S.rooms_long.training_room))
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

    if humanoid.profile.is_consultant and humanoid == self.staff_member then
      local staff = self.waiting_staff_member
      self:setStaffMember(nil)
      if staff then
        staff.waiting_on_other_staff = nil
        self.waiting_staff_member = nil
        self:commandEnteringStaff(staff)
      end
    end
  end

  Room.onHumanoidLeave(self, humanoid)
end

return room
