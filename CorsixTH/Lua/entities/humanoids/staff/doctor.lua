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

corsixth.require("announcer")
corsixth.require("entities.humanoids.staff")

local AnnouncementPriority = _G["AnnouncementPriority"]

--! A Doctor (Researcher,Surgan,Psychologist)
class "Doctor" (Staff)

---@type Doctor
local Doctor = _G["Doctor"]

--!param ... Arguments to base class constructor.
function Doctor:Doctor(...)
  self:Staff(...)
  self.leave_sounds = {"sack001.wav", "sack002.wav", "sack003.wav"}
end

function Doctor:tickDay()
  if not Staff.tickDay(self) then
    return false
  end

  -- if you overwork your Dr's then there is a chance that they can go crazy
  -- when this happens, find him and get him to rest straight away
  if self.attributes["fatigue"] then
    if self.attributes["fatigue"] < 0.7 then
      if self:isResting() then
        self:setCrazy(false)
      end
    else
      -- doctor can go crazy if they're too tired
      if math.random(1, 300) == 1 then
        self:setCrazy(true)
      end
    end
  end

  -- is self researcher in research room?
  if self:isResearching() then
    self.hospital.research:addResearchPoints(1550 + 1000*self.profile.skill)
  -- is self using lecture chair in a training room w/ a consultant?
  elseif self:isLearning() then
    -- Find values for how fast doctors learn the different professions from the level
    local level_config = self.world.map.level_config
    local surg_thres = 1
    local psych_thres = 1
    local res_thres = 1
    if level_config and level_config.gbv.AbilityThreshold then
      surg_thres = level_config.gbv.AbilityThreshold[0]
      psych_thres = level_config.gbv.AbilityThreshold[1]
      res_thres = level_config.gbv.AbilityThreshold[2]
    end
    local general_thres = 200 -- general skill factor

    local room = self:getRoom()
    -- room_factor starts at 5 for a basic room w/ TrainingRate == 4
    -- books add +1.5, skeles add +2.0, see TrainingRoom:calculateTrainingFactor
    local room_factor = room:getTrainingFactor()
    -- number of staff includes consultant
    local staff_count = room:getStaffCount() - 1
    -- update general skill
    self:trainSkill(room.staff_member, "skill", general_thres, room_factor, staff_count)
    -- update special skill based on consultant skills
    if room.staff_member.profile.is_surgeon >= 1.0 then
      self:trainSkill(room.staff_member, "is_surgeon", surg_thres, room_factor, staff_count)
    end
    if room.staff_member.profile.is_psychiatrist >= 1.0 then
      self:trainSkill(room.staff_member, "is_psychiatrist", psych_thres, room_factor, staff_count)
    end
    if room.staff_member.profile.is_researcher >= 1.0 then
      self:trainSkill(room.staff_member, "is_researcher", res_thres, room_factor, staff_count)
    end
  end
end

function Doctor:tick()
  Staff.tick(self)
  -- don't do anything if they're fired or picked up or have no hospital
  if self.fired or self.pickup or not self.hospital or self.dead then
    return
  end

    -- if doctor is in a room and they're using an object
    -- then their skill level will increase _slowly_ over time
  if self:isLearningOnTheJob() then
    self:updateSkill(self.humanoid_class, "skill", 0.000003)
  end
end

-- Determine if the staff member should contribute to research
function Doctor:isResearching()
  local room = self:getRoom()

  -- Doctor is in research lab, is qualified, and is not leaving the hospital.
  return room and room.room_info.id == "research" and
      self.profile.is_researcher >= 1.0 and self.hospital
end

-- Determine if the staff member should increase their skills
function Doctor:isLearning()
  local room = self:getRoom()

  -- Doctor is in training room, the training room has a consultant, and  is using lecture chair.
  return room and room.room_info.id == "training" and room.staff_member and
      self:getCurrentAction().name == "use_object" and
      self:getCurrentAction().object.object_type.id == "lecture_chair"
end

function Doctor:isLearningOnTheJob()
  local room = self:getRoom()

  -- Doctor is in room but not training room, staff room, or toilets; is a doctor; and is using something
  return room and room.room_info.id ~= "training" and
      room.room_info.id ~= "staff_room" and room.room_info.id ~= "toilets" and
      self:getCurrentAction().name == "use_object"
end

function Doctor:setProfile(profile)
  Staff.setProfile(self, profile)
  self:updateStaffTitle()
end

function Doctor:updateSkill(consultant, trait, amount) -- luacheck: no unused args
  local old_profile = {
    is_junior = self.profile.is_junior,
    is_consultant = self.profile.is_consultant
  }

  -- don't push further when they are already at 100%+
  if self.profile[trait] >= 1.0 then
    return
  end

  self.profile[trait] = self.profile[trait] + amount
  if self.profile[trait] >= 1.0 then
    self.profile[trait] = 1.0
    local is = trait:match"^is_(.*)"
    if is == "surgeon" or is == "psychiatrist" or is == "researcher" then
      self.hospital:giveAdvice({ _A.information.promotion_to_specialist:format(_S.staff_title[is]) })
      -- patients might we waiting for a doctor with this skill, notify them
      self.hospital:notifyOfStaffChange(self)
    end
    self:updateStaffTitle()
  end

  if trait == "skill" then
    self.profile:parseSkillLevel()

    if old_profile.is_junior and not self.profile.is_junior then
      self.hospital:giveAdvice({ _A.information.promotion_to_doctor })
      self:updateStaffTitle()
    elseif not old_profile.is_consultant and self.profile.is_consultant then
      self.hospital:giveAdvice({ _A.information.promotion_to_consultant })
      if self:getRoom().room_info.id == "training" then
        self:setNextAction(self:getRoom():createLeaveAction())
        self:queueAction(MeanderAction())
        self.last_room = nil
      end
      self:updateStaffTitle()
    end
  end
end

function Doctor:trainSkill(consultant, trait, skill_thres, room_factor, staff_count)
  -- TODO: tweak/rework this algorithm
  -- TODO: possibly adjust based upon consultant's skill level?
  --       possibly based on attention to detail?
  local constant = 12.0
  local staff_factor = constant + (staff_count-1)*(constant/6.0)
  local delta = room_factor / (skill_thres * staff_factor)
  self:updateSkill(consultant, trait, delta)
end

function Doctor:updateStaffTitle()
  local profile = self.profile
  local professions = ""
  local number = 0
  if profile.is_junior then
    professions = _S.staff_title.junior .. " "
    number = 1
  elseif profile.is_consultant then
    professions = _S.staff_title.consultant .. " "
    number = 1
  end
  if profile.is_researcher >= 1.0 then
    professions = professions .. _S.staff_title.researcher .. " "
    number = number + 1
  end
  if profile.is_surgeon >= 1.0 then
    professions = professions .. _S.staff_title.surgeon .. " "
    number = number + 1
  end
  if profile.is_psychiatrist >= 1.0 then
    if number < 3 then
      professions = professions .. _S.staff_title.psychiatrist
    else
      professions = professions .. _S.dynamic_info.staff.psychiatrist_abbrev
    end
  end

  if professions == "" then
    professions = _S.staff_title.doctor
  end
  self.profile.profession = professions
end

function Doctor:setCrazy(crazy)
  if crazy then
    -- make doctor crazy
    if not self.is_crazy then
      self:setLayer(5, self.profile.layer5 + 4)
      self.world.ui.adviser:say(_A.warnings.doctor_crazy_overwork)
      self.is_crazy = true
    end
  else
    -- make doctor sane
    if self.is_crazy then
      if not (self.layers[5] < 5) then
        self:setLayer(5, self.layers[5] - 4)
        self.is_crazy = false
      end
    end
  end
end

local profile_attributes = {
  Psychiatrist = "is_psychiatrist",
  Surgeon = "is_surgeon",
  Researcher = "is_researcher",
  Junior = "is_junior",
  Consultant = "is_consultant",
}

-- Helper function to decide if Staff fulfills a criterion
-- (one of "Doctor", "Nurse", "Psychiatrist", "Surgeon", "Researcher" and "Handyman", "Receptionist", "Junior", "Consultant")
function Doctor:fulfillsCriterion(criterion)
  if criterion == "Doctor" then
    return true
  end
  if self.profile and self.profile[profile_attributes[criterion]] == 1.0 then
    return true
  end
  return false
end

function Doctor:adviseWrongPersonForThisRoom()
  local room = self:getRoom()
  local room_name = room.room_info.long_name
  if room.room_info.id == "toilets" then
    self.world.ui.adviser:say(_A.staff_place_advice.doctors_cannot_work_in_room:format(room_name))
  elseif room.room_info.id == "training" then
    self.world.ui.adviser:say(_A.staff_place_advice.doctors_cannot_work_in_room:format(room_name))
  else
    Staff.adviseWrongPersonForThisRoom(self)
  end
end

function Doctor:afterLoad(old, new)
  if old < 163 then
    self.leave_priority = AnnouncementPriority.High
    self.leave_sounds = {"sack001.wav", "sack002.wav", "sack003.wav"}
  end
  Staff.afterLoad(self, old, new)
end

--[[ Return string representation
! Adds Doctor statistics for a "Doctor" object
!return (string)
]]
function Doctor:tostring()
  local result = Humanoid.tostring(self)
  result = result .. string.format("\nSkills: (%.3f)  Surgeon (%.3f)  Psych (%.3f)  Researcher (%.3f)",
    self.profile.skill or 0,
    self.profile.is_surgeon or 0,
    self.profile.is_psychiatrist or 0,
    self.profile.is_researcher or 0)
  return result
end
