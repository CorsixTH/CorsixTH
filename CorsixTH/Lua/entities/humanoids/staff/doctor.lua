--[[ Copyright (c) 2009 Peter "Corsix" Cawley
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
  if not self:isVeryTired() then
    if self:isResting() then
      self:setCrazy(false)
    end
  else
    -- doctor can go crazy if they're too tired
    if math.random(1, 300) == 1 then
      self:setCrazy(true)
    end
  end

  -- is self researcher in research room?
  if self:isResearching() then
    self.hospital.research:addResearchPoints(1550 + 1000 * self.profile.skill)
  -- Are we learning new skills today?
  elseif self:isLearning() then
    local room = self:getRoom()
    local consultant = room.staff_member
    local room_factor = room:getTrainingFactor()
    -- When counting room occupancy, we must subtract 1 for the consultant in the room.
    -- Currently, handymen/newly trained consultants also get counted here as they
    -- could be considered distracting to current trainees.
    local student_count = room:getStaffCount() - 1
    self:trainSkills(consultant, room_factor, student_count)
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
    self:updateSkill("skill", 0.000003)
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
  -- Check that the doctor is a trainee (currently in a chair and not a consultant) in
  -- a training room.
  if self.profile.is_consultant then return false end
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

--! Assign skill points
--!param trait (string) The trait of focus
--!param amount (number) The amount granted
function Doctor:updateSkill(trait, amount)
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
    local is = trait:match("^is_(.*)")
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
        self.last_room = nil -- Consultant no longer needs to return to this room
      end
      self:updateStaffTitle()
    end
  end
end

--! Confirm doctor has specialism
--!param trait (string) what to check (in is_xxx format)
--!return true if specialised
function Doctor:hasSpecialism(trait)
  local specialisms = {
    ["is_surgeon"] = self.profile.is_surgeon >= 1,
    ["is_psychiatrist"] = self.profile.is_psychiatrist >= 1,
    ["is_researcher"] = self.profile.is_researcher >= 1,
  }
  return specialisms[trait]
end

--! Generate the performance factor of the training room
--!param doc_atd (number) Attention to detail of student
--!param con_skill (number) Skill level of consultant
--!param class_size (number) Total students in the training room
--!return calculated performance
function Doctor._calculateTrainingPerformance(doc_atd, con_skill, class_size)
  -- Clamp a performance modifier's impact between 90% and 110%
  local function clamp(value)
    local base, range = 0.9, 0.2 -- specify the +-10% variability
    local factor = value * range
    return base + factor
  end

  local performers = {
    clamp(doc_atd), -- doctor focus
    clamp(con_skill * con_skill), -- teacher ability. ~1.0 modifier at 0.75 skill
    math.t_random(0.9, 1, 1.1), -- Allow some randomness
  }
  -- Average the three performance modifiers to generate a single performance factor
  local p_impact = 0
  for i = 1, #performers do
    p_impact = p_impact + performers[i]
  end
  p_impact = p_impact / #performers

  -- Class size impacts performance when there are more than 3 students at rate 2/n-1
  local c_impact = class_size >= 3 and 2 / (class_size - 1) or 1

  return p_impact * c_impact
end

--! Calculates the amount of skill to learn towards becoming a doctor/consultant and
--! any amount towards a specialist skill being taught
--! There are detailed explanations on the logic to these calculations in the Wiki
--!param consultant (entity) The person teaching the student
--!param room_factor (number) What score training objects in the room give
--!param student_count (number) Total number of students present
function Doctor:trainSkills(consultant, room_factor, student_count)
  local level_config = self.world.map.level_config
  local general_factor = level_config.gbv.TrainingRate

  local MIN_LEARN_VALUE = 0.001 -- Doctor always advances at least this amount
  local g_scale = 10000 -- scales generalist calculation
  local s_scale = 12 -- scales specialism calculation

  local function countSkillsTaught()
    local num_skills = 1 -- General skill is always counted
    local skills = {"is_surgeon", "is_psychiatrist", "is_researcher"}
    for _, skill in pairs(skills) do
      if consultant:hasSpecialism(skill) and not self:hasSpecialism(skill) then
        num_skills = num_skills + 1
      end
    end
    return num_skills
  end

  local skills_factor = 1 / countSkillsTaught()
  local class_performance = self._calculateTrainingPerformance(
      self.profile.attention_to_detail,
      consultant.profile.skill,
      student_count)

  -- Calculate the simpler, generalist skill, which is always awarded while training.
  local g_train = (general_factor * skills_factor * class_performance) / g_scale
  self:updateSkill("skill", math.max(g_train, MIN_LEARN_VALUE))

  -- Now begin calculations for specialist skills
  local thresholds = {
    ["is_surgeon"] = level_config.gbv.AbilityThreshold[0],
    ["is_psychiatrist"] = level_config.gbv.AbilityThreshold[1],
    ["is_researcher"] = level_config.gbv.AbilityThreshold[2],
  }

  for name, threshold in pairs(thresholds) do
    if consultant:hasSpecialism(name) and not self:hasSpecialism(name) then
      local base = room_factor / threshold
      local s_train = (base * skills_factor * class_performance) / s_scale
      self:updateSkill(name, math.max(s_train, MIN_LEARN_VALUE))
    end
  end
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
      self.hospital:giveAdvice({_A.warnings.doctor_crazy_overwork})
      self.is_crazy = true
    end
  else
    -- make doctor sane
    if self.is_crazy then
      if self.layers[5] >= 5 then
        self:setLayer(5, self.layers[5] - 4)
        self.is_crazy = false
      end
    end
  end
end

function Doctor:onPickup()
  Staff.onPickup(self)
  self:resetSurgeonState()
end

-- Function resets "Surgeon" state for Doctor.
-- Useful for case when on picking up Doctor from Operating Theatre
-- we need to switching him back to regular clothes and type.
function Doctor:resetSurgeonState()
  if self.humanoid_class == "Surgeon" then
    self:setType("Doctor")
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
    self.hospital:giveAdvice({ _A.staff_place_advice.doctors_cannot_work_in_room:format(room_name) })
  elseif room.room_info.id == "training" then
    self.hospital:giveAdvice({ _A.staff_place_advice.doctors_cannot_work_in_room:format(room_name) })
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
