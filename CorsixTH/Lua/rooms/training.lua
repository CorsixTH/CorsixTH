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
room.has_no_queue_dialog = true

class "TrainingRoom" (Room)

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
  for object, value in pairs(objects) do
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
    local text = _S.adviser.room_requirements.training_room_need_consultant
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
  if extra_humanoid and extra_humanoid.profile
  and extra_humanoid.profile.is_consultant and self.staff_member then
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
  humanoid:queueAction{name = "walk", x = ox, y = oy}
  local projector_use_time = math.random(6,20)
  humanoid:queueAction{name = "use_object",
    object = projector,
    loop_callback = --[[persistable:training_loop_callback]] function()
      projector_use_time = projector_use_time - 1
      if projector_use_time == 0 then
        local skeleton, sox, soy = self.world:findFreeObjectNearToUse(humanoid, "skeleton", "near")
        local bookcase, box, boy = self.world:findFreeObjectNearToUse(humanoid, "bookcase", "near")
        if math.random(0, 1) == 0 and bookcase then skeleton = nil end -- choose one
        if skeleton then
          humanoid:walkTo(sox, soy)
          for i = 1, math.random(3, 10) do
            humanoid:queueAction{name = "use_object", object = skeleton}
          end
        elseif bookcase then
          humanoid:walkTo(box, boy)
          for i = 1, math.random(3, 10) do
            humanoid:queueAction{name = "use_object", object = bookcase}
          end
        end
        -- go back to the projector
        self:doStaffUseCycle(humanoid)
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
  -- so students stop learning
  if self.staff_member == humanoid then
    self.staff_member = nil
  end
  if humanoid.humanoid_class == "Doctor" then
    -- unreserve whatever it was they we using
    local fx, fy = self:getEntranceXY(true)
    local objects = self.world:findAllObjectsNear(fx,fy)
    for object, value in pairs(objects) do
      if object.reserved_for == humanoid then
        object:removeReservedUser()
      end
    end
  end

  Room.onHumanoidLeave(self, humanoid)
end

return room
