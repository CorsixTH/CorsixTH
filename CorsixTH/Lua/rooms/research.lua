--[[ Copyright (c) 2009 Manuel König

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
room.id = "research"
room.level_config_id = 55
room.class = "ResearchRoom"
room.name = _S.rooms_short.research_room
room.tooltip = _S.tooltip.rooms.research_room
room.build_cost = 5000
room.objects_additional = { "extinguisher", "radiator", "plant", "bin", "computer", "desk", "cabinet", "analyser" }
room.objects_needed = { desk = 1, cabinet = 1, autopsy = 1 }
room.build_preview_animation = 5102
room.categories = {
  facilities = 2,
}
room.minimum_size = 5
room.wall_type = "green"
room.floor_tile = 21
room.required_staff = {
  Researcher = 1,
}
room.call_sound = "reqd023.wav"

class "ResearchRoom" (Room)

function ResearchRoom:ResearchRoom(...)
  self:Room(...)
  self.staff_member_set = {}
end

local staff_usage_objects = {
  desk = true,
  cabinet = true,
  computer = true,
  -- Not autopsy: it should be free for when a patient arrives
  -- Not atom analyser: there are no usage anims
}

function ResearchRoom:doStaffUseCycle(staff, previous_object)
  local obj, ox, oy = self.world:findFreeObjectNearToUse(staff,
    staff_usage_objects, nil, "near", previous_object)
  
  if obj then
    obj.reserved_for = staff
    staff:walkTo(ox, oy)
    if obj.object_type.id == "desk" then
      local desk_use_time = math.random(7, 14)
      staff:queueAction(UseObjectAction {
        object = obj,
        loop_callback = --[[persistable:research_desk_loop_callback]] function(action)
          desk_use_time = desk_use_time - 1
          if action.todo_interrupt or desk_use_time == 0 then
            action.prolonged_usage = false
          end
        end
      })
    else
      staff:queueAction(UseObjectAction {
        object = obj,
        after_use = --[[persistable:research_obj_after_use]] function() end,
      })
    end
  end
  
  local num_meanders = math.random(2, 4)
  staff:queueAction(MeanderAction {
    loop_callback = --[[persistable:research_meander_loop_callback]] function(action)
      num_meanders = num_meanders - 1
      if num_meanders == 0 then
        self:doStaffUseCycle(staff)
      end
    end
  })
end

function ResearchRoom:roomFinished()
  local fx, fy = self:getEntranceXY(true)
  local objects = self.world:findAllObjectsNear(fx, fy)
  local number = 0
  for object, value in pairs(objects) do
    if staff_usage_objects[object.object_type.id] then
      number = number + 1
    end
  end
  self.maximum_staff = {
    Researcher = number,
  }
  return Room.roomFinished(self)
end

function ResearchRoom:getMaximumStaffCriteria()
  return self.maximum_staff
end

function ResearchRoom:commandEnteringStaff(staff)
  self.staff_member_set[staff] = true
  self:doStaffUseCycle(staff)
  return Room.commandEnteringStaff(self, staff)
end

function ResearchRoom:commandEnteringPatient(patient)
  local staff = next(self.staff_member_set)
  local autopsy, stf_x, stf_y = self.world:findObjectNear(patient, "autopsy")
  local orientation = autopsy.object_type.orientations[autopsy.direction]
  local pat_x, pat_y = autopsy:getSecondaryUsageTile()
  patient:walkTo(pat_x, pat_y)
  staff:walkTo(stf_x, stf_y)
  patient:queueAction(staff:queueAction(MultiUseObjectAction {
    object = autopsy,
    after_use = --[[persistable:autopsy_after_use]] function()
      -- Patient dies :(
      self:onHumanoidLeave(patient)
      if patient.hospital then
        patient:setHospital(nil)
      end
      patient.world:destroyEntity(patient)
    end,
  }):createSecondaryUserAction())
  staff:queueAction(LogicAction{self.doStaffUseCycle, self, staff})
  patient:queueAction(LogicAction{self.makePatientRejoinQueue, self, patient})
  return Room.commandEnteringPatient(self, patient)
end


function ResearchRoom:onHumanoidLeave(humanoid)
  self.staff_member_set[humanoid] = nil
  Room.onHumanoidLeave(self, humanoid)
end

return room
