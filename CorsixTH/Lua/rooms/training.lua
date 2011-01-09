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

class "TrainingRoom" (Room)

function TrainingRoom:TrainingRoom(...)
  self:Room(...)
end

function TrainingRoom:roomFinished()
  local fx, fy = self:getEntranceXY(true)
  local objects = self.world:findAllObjectsNear(fx, fy)
  local number = 0
  local skeletons = 0
  local bookcases = 0
  for object, value in pairs(objects) do
    if object.object_type.id == "lecture_chair" then
      number = number + 1
    elseif object.object_type.id == "skeleton" then
      skeletons = skeletons + 1
    elseif object.object_type.id == "bookcase" then
      bookcases = bookcases + 1
    end
  end
  -- Total staff occupancy: number of lecture chairs plus projector
  self.maximum_staff = { Doctor = number + 1 }
  -- Training rate based on objects in the room
  -- TODO:  What should happen if there is no level configuration?
  local level_config = self.world.map.level_config
  local factor = 10 -- The projector is always available
  -- Make use of at most 2 skeletons and/or bookcases for now.
  -- TODO: Decide how much the two objects affect speed of training.
  -- They don't do anything for now.
  if level_config and level_config.gbv.TrainingRate then
    local skel_fact = level_config.gbv.TrainingValue[1]
    local book_fact = level_config.gbv.TrainingValue[2]
    --factor = factor + (skeletons < 3 and skeletons or 2)*skel_fact
    --factor = factor + (bookcases < 3 and bookcases or 2)*book_fact
    factor = (factor + level_config.gbv.TrainingRate)/10
  end
  self.training_factor = factor
  Room.roomFinished(self)
end

function TrainingRoom:getTrainingFactor()
  return self.training_factor
end

function TrainingRoom:getMaximumStaffCriteria()
  return self.maximum_staff
end

function TrainingRoom:doStaffUseCycle(humanoid)
  local projector, ox, oy = self.world:findObjectNear(humanoid, "projector")
  humanoid:queueAction{name = "walk", x = ox, y = oy}
  local projector_use_time = math.random(20, 30)
  humanoid:queueAction{name = "use_object",
    object = projector,
    loop_callback = --[[persistable:training_loop_callback]] function()
      projector_use_time = projector_use_time - 1
      if projector_use_time == 0 then
        local skeleton, ox, oy = self.world:findObjectNear(humanoid, "skeleton")
        if skeleton then
          -- TODO: Make a little more random
          humanoid:walkTo(ox, oy)
          humanoid:queueAction{name = "use_object", object = skeleton}
          humanoid:queueAction{name = "use_object", object = skeleton}
          humanoid:queueAction{name = "use_object", object = skeleton}
          self:doStaffUseCycle(humanoid)
        else
          -- Consultant will just use the projector indefinitely.
        end
      elseif projector_use_time < 0 then
        -- reset variable to avoid potential overflow (over a VERY long
        -- period of time)
        projector_use_time = 0
      end
    end,
  }
end

function TrainingRoom:commandEnteringStaff(humanoid)
  local obj, ox, oy
  local profile = humanoid.profile

  if profile.humanoid_class == "Doctor" then
    -- Consultants try to use the projector and/or skeleton
    if profile.is_consultant then
      obj, ox, oy = self.world:findFreeObjectNearToUse(humanoid, "projector")
      if obj and not self.staff_member then
        obj.reserved_for = humanoid
        self.staff_member = humanoid
        humanoid:walkTo(ox, oy)
        self:doStaffUseCycle(humanoid)
      else
        humanoid:setNextAction(self:createLeaveAction())
        humanoid:queueAction{name = "meander"}
      end
    else
      obj, ox, oy = self.world:findFreeObjectNearToUse(humanoid, "lecture_chair")
      if obj then
        obj.reserved_for = humanoid
        humanoid:walkTo(ox, oy)
        humanoid:queueAction{name = "use_object", object = obj}
        humanoid:queueAction{name = "meander"}
      else
        humanoid:setNextAction(self:createLeaveAction())
        humanoid:queueAction{name = "meander"}
      end
    end
  elseif humanoid.humanoid_class ~= "Handyman" then
    self.world.ui.adviser:say(_S.adviser.staff_place_advice.only_doctors_in_room:format(_S.rooms_long.training_room))
    humanoid:setNextAction(self:createLeaveAction())
    humanoid:queueAction{name = "meander"}
    return
  end

  return Room.commandEnteringStaff(self, humanoid)
end

function TrainingRoom:onHumanoidLeave(humanoid)
  -- if the consultant is leaving, make sure we indicate that
  if self.staff_member == humanoid then
    self.staff_member = nil
  end

  Room.onHumanoidLeave(self, humanoid)
end

return room
