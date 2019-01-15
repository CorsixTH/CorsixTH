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
room.level_config_id = 28
room.class = "ResearchRoom"
room.name = _S.rooms_short.research_room
room.long_name = _S.rooms_long.research_room
room.tooltip = _S.tooltip.rooms.research_room
room.objects_additional = {
  "extinguisher",
  "radiator",
  "plant",
  "bin",
  "computer",
  "desk",
  "cabinet",
  "analyser" }
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

---@type ResearchRoom
local ResearchRoom = _G["ResearchRoom"]

function ResearchRoom:ResearchRoom(...)
  self:Room(...)
  self.staff_member_set = {}
end

local staff_usage_objects = {
  desk = true,
  cabinet = true,
  computer = true,
  analyser = true,
  -- Not autopsy: it should be free for when a patient arrives
}

function ResearchRoom:doStaffUseCycle(staff, previous_object)
  local obj, ox, oy = self.world:findFreeObjectNearToUse(staff,
    staff_usage_objects, "near", previous_object)

  if obj then
    obj.reserved_for = staff
    staff:walkTo(ox, oy)
    if obj.object_type.id == "desk" then
      local desk_use_time = math.random(7, 14)
      local loop_callback_desk = --[[persistable:research_desk_loop_callback]] function(action)
        desk_use_time = desk_use_time - 1
        if action.todo_interrupt or desk_use_time == 0 then
          action.prolonged_usage = false
        end
      end

      local after_use_desk = --[[persistable:research_desk_after_use]] function()
        -- TODO: Should interactions give points?
        self.hospital.research:addResearchPoints(100)
      end

      staff:queueAction(UseObjectAction(obj):setLoopCallback(loop_callback_desk)
          :setAfterUse(after_use_desk))
    else
      local after_use_obj = --[[persistable:research_obj_after_use]] function()
        if obj.object_type.id == "computer" then
          self.hospital.research:addResearchPoints(500)
        elseif obj.object_type.id == "analyser" then
          self.hospital.research:addResearchPoints(800)
          -- TODO: Balance value, find it in level config?
        end
      end

      staff:queueAction(UseObjectAction(obj):setAfterUse(after_use_obj))
    end
  end

  local num_meanders = math.random(2, 4)
  local loop_callback_meander = --[[persistable:research_meander_loop_callback]] function(action)
    num_meanders = num_meanders - 1
    if num_meanders == 0 then
      self:doStaffUseCycle(staff)
    end
  end

  staff:queueAction(MeanderAction():setLoopCallback(loop_callback_meander))
end

function ResearchRoom:roomFinished()
  local fx, fy = self:getEntranceXY(true)
  local objects = self.world:findAllObjectsNear(fx, fy)
  local number = 0
  for object, _ in pairs(objects) do
    -- The number of desks in the room determines how many researchers
    -- can work there at once.
    if object.object_type.id == "desk" then
      number = number + 1
    end
  end
  self.maximum_staff = {
    Researcher = number,
  }
  -- Is this the first research department built?
  if not self.hospital.research_dep_built and not TheApp.using_demo_files then
    self.hospital.research_dep_built = true
    self.world.ui.adviser:say(_A.information.initial_general_advice
    .research_now_available)
  end
  -- Also check if it would be good to hire a researcher.
  if not self.hospital:hasStaffOfCategory("Researcher") then
    self.world.ui.adviser:say(_A.room_requirements.research_room_need_researcher)
  end
  return Room.roomFinished(self)
end

function ResearchRoom:getMaximumStaffCriteria()
  return self.maximum_staff
end

function ResearchRoom:commandEnteringStaff(staff)
  self.staff_member_set[staff] = true
  self:doStaffUseCycle(staff)
  return Room.commandEnteringStaff(self, staff, true)
end

function ResearchRoom:commandEnteringPatient(patient)
  local staff = next(self.staff_member_set)
  local autopsy, stf_x, stf_y = self.world:findObjectNear(patient, "autopsy")
  local pat_x, pat_y = autopsy:getSecondaryUsageTile()
  patient:walkTo(pat_x, pat_y)
  patient:queueAction(IdleAction():setDirection("east"))
  staff:walkTo(stf_x, stf_y)

  local after_use_autopsy = --[[persistable:autopsy_after_use]] function()
    self:commandEnteringStaff(staff)
    -- Patient dies :(
    self:onHumanoidLeave(patient)
    -- Some research is done. :) Might trigger a loss of reputation though.
    local hosp = self.hospital
    local patient_room = patient.disease.treatment_rooms[#patient.disease.treatment_rooms]
    hosp.research:addResearchPoints("dummy", patient_room)
    if not hosp.autopsy_discovered and hosp.discover_autopsy_risk > math.random(1, 100) then
      -- Can only be discovered once.
      hosp.autopsy_discovered = true
      hosp:changeReputation("autopsy_discovered")
      hosp.world.ui.adviser:say(_A.research.autopsy_discovered_rep_loss)
    else
      -- The risk increases after each use.
      -- TODO: Should it ever become 100%?
      self.hospital.discover_autopsy_risk = self.hospital.discover_autopsy_risk + 10
    end
    if patient.hospital then
      hosp:removePatient(patient)
    end
    patient.world:destroyEntity(patient)
  end

  staff:queueAction(MultiUseObjectAction(autopsy, patient):setAfterUse(after_use_autopsy))
  return Room.commandEnteringPatient(self, patient)
end

-- Returns the staff member with the minimum amount of skill.
function ResearchRoom:getStaffMember()
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

function ResearchRoom:setStaffMember(staff)
  self.staff_member_set[staff] = true
end

function ResearchRoom:setStaffMembersAttribute(attribute, value)
  for staff_member, _ in pairs(self.staff_member_set) do
    staff_member[attribute] = value
  end
end

function ResearchRoom:onHumanoidLeave(humanoid)
  self.staff_member_set[humanoid] = nil
  Room.onHumanoidLeave(self, humanoid)
end

function ResearchRoom:afterLoad(old, new)
  if old < 56 then
    self.hospital.research_dep_built = true
  end
end
return room
