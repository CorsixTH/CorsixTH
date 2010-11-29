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

class "StaffProfile"

function StaffProfile:StaffProfile(humanoid_class, local_string)
  self.humanoid_class = humanoid_class
  self.name = "U. N. Initialised"
  self.wage = 0
  self.skill = 0 -- [0.0, 1.0]
  self.layer5 = 2
  self.attention_to_detail = 0.5 -- [0.0, 1.0] TODO currently not used
  self.profession = local_string
end

function StaffProfile:setDoctorAbilities(psychiatrist, surgeon, researcher, junior, consultant)
  self.is_psychiatrist = psychiatrist
  self.is_surgeon = surgeon
  self.is_researcher = researcher
  self.is_junior = junior
  self.is_consultant = consultant 
end

function StaffProfile:initDoctor(psychiatrist, surgeon, researcher, junior, consultant, skill, world)
  self:setDoctorAbilities(psychiatrist, surgeon, researcher, junior, consultant)
  self:init(skill, world)
end

function StaffProfile:init(skill, world)
  self:setSkill(skill)
  self.wage = self:getFairWage(world)
  self:randomiseOrganical()
end

function StaffProfile:setSkill(skill)
	self.skill = skill
end

local name_parts = {_S.humanoid_name_starts, _S.humanoid_name_ends}

local function shuffle(t)
  local r = {}
  local i = {}
  for k in ipairs(t) do
    r[k] = math.random()
    i[k] = k
  end
  table.sort(i, function(x, y) return r[x] < r[y] end)
  for k in ipairs(t) do
    r[k] = t[i[k]]
  end
  return r
end

local function our_concat(t)
  -- The standard table.concat function doesn't like our userdata strings :(
  local result = ""
  for _, s in ipairs(t) do
    result = result .. s
  end
  return result
end

function StaffProfile:randomise(world)
  local level_config = world.map.level_config
  
  -- decide general skill for all staff
  self.skill = math.random()
  --self.skill_level_modifier = math.random(-50, 50) / 1000 -- [-0.05, +0.05]
  --self:parseSkillLevel()
  
  if self.humanoid_class == "Doctor" then
    -- find the correct config line (based on month) for generation of the doctor
    local i = 0
    while i < #level_config.staff_levels and 
    level_config.staff_levels[i+1].Month < world.month + (world.year - 1)*12 do 
      i = i+1 
    end
  
    local shrinkrate = 0
    local surgrate = 0
    local rschrate = 0
    local jrRate = 0
    local consRate = 0
    
  
    if level_config.staff_levels[i].ShrkRate ~= 0 then
      shrinkrate = 1 / level_config.staff_levels[i].ShrkRate
    end
    if level_config.staff_levels[i].SurgRate ~= 0 then
      surgrate = 1 / level_config.staff_levels[i].SurgRate
    end
    if level_config.staff_levels[i].RschRate ~= 0 then
      rschrate = 1 / level_config.staff_levels[i].RschRate
    end
    if level_config.staff_levels[i].JrRate ~= 0 then
      jrRate = 1 / level_config.staff_levels[i].JrRate
    end
    if level_config.staff_levels[i].ConsRate ~= 0 then
      consRate = 1 / level_config.staff_levels[i].ConsRate
    end
    -- FULL05.SAM contains the values 255, which means 0
    --if shrinkrate > 1.0 then shrinkrate = 0 end
    --if surgrate > 1.0 then surgrate = 0 end
    --if rschrate > 1.0 then rschrate = 0 end
  
    self.is_surgeon      = math.random() < surgrate and 1.0 or 0
    self.is_psychiatrist = math.random() < shrinkrate and 1.0 or 0
    self.is_researcher   = math.random() < rschrate and 1.0 or 0
    
    
    -- decide seniority
    -- FULL05.SAM contains the values 255, which means 0
    if jrRate > 1.0 then jrRate = 0 end
    if consRate > 1.0 then consRate = 0 end
    
    self.is_junior = math.random() < jrRate and 1.0 or nil
    if not self.is_junior then
  	  self.is_consultant = math.random() < consRate and 1.0 or nil
    end
  
    local jr_limit = 0.4
    local cons_limit = 0.9
  
    -- put the doctor in the right skill level box ( 0 .. 0.4 .. 0.9 .. 1 )
    if self.is_junior then
      self.skill = jr_limit * self.skill
    elseif self.is_consultant then
      self.skill = cons_limit + ((1 - cons_limit) * self.skill)
    else
      self.skill = jr_limit + ((cons_limit - jr_limit) * self.skill)
    end
  end
  self.wage = self:getFairWage(world)
  self:randomiseOrganical()
end

function StaffProfile:randomiseOrganical()
  self.name = string.char(string.byte"A" + math.random(0, 25)) .. ". "
  for _, part_table in ipairs(name_parts) do
    self.name = self.name .. part_table.__random
  end
  local desc_table1, desc_table2
  if self.skill < 0.33 then
    desc_table1 = _S.staff_descriptions.bad
    desc_table2 = _S.staff_descriptions.bad
  elseif self.skill < 0.66 then
    desc_table1 = _S.staff_descriptions.good
    desc_table2 = _S.staff_descriptions.bad
  else
    desc_table1 = _S.staff_descriptions.good
    desc_table2 = _S.staff_descriptions.good
  end
  local descs = {_S.staff_descriptions.misc.__random,
                 desc_table1.__random,
                 desc_table2.__random}
  if descs[2] == descs[3] then
    descs[3] = nil
  end
  while #our_concat(descs) > 96 do
    descs[#descs] = nil
  end
  self.desc = our_concat(shuffle(descs))
  if self.humanoid_class == "Doctor" then
    self.is_black = math.random(0, 1) == 0
    if self.is_black then
      self.hair_index = math.random(5, 9)
      self.face_index = math.random(5, 9)
      self.chin_index = math.random(5, 9)
      self.layer5 = 4
    else
      self.hair_index = math.random(0, 4)
      self.face_index = math.random(0, 4)
      self.chin_index = math.random(0, 4)
      self.layer5 = 2
    end
  elseif self.humanoid_class == "Nurse" then
    self.hair_index = math.random(10, 12)
    self.face_index = math.random(10, 12)
    self.chin_index = math.random(10, 12)
  elseif self.humanoid_class == "Receptionist" then
    self.hair_index = math.random(13, 14)
    self.face_index = math.random(13, 14)
    self.chin_index = math.random(13, 14)
  elseif self.humanoid_class == "Handyman" then
    self.hair_index = math.random(15, 17)
    self.face_index = math.random(15, 17)
    self.chin_index = math.random(15, 17)
  end
end

function StaffProfile:drawFace(canvas, x, y, parts_bitmap)
  parts_bitmap:draw(canvas, x, y     , 0,       self.hair_index * 29, 65, 29)
  parts_bitmap:draw(canvas, x, y + 29, 0, 522 + self.face_index * 24, 65, 24)
  parts_bitmap:draw(canvas, x, y + 53, 0, 954 + self.chin_index * 22, 65, 22)
end

function StaffProfile:parseSkillLevel()
  local junior_skill = 0.4
  self.is_junior     = self.skill <= junior_skill and 1 or nil
  local consultant_skill = 0.9
  self.is_consultant = self.skill >= consultant_skill and 1 or nil
end

local conf_id = {
  Nurse = 0,
  Doctor = 1,
  Handyman = 2,
  Receptionist = 3,
}

local ability_conf_id = {
  is_junior       = 3,
  is_doctor       = 4,
  is_surgeon      = 5,
  is_psychiatrist = 6,
  is_consultant   = 7,
  is_researcher   = 8,
}

function StaffProfile:getFairWage(world)
  local level_config = world.map.level_config
  local wage = level_config.staff[conf_id[self.humanoid_class]].MinSalary
  wage = wage + self.skill * 1000 / level_config.gbv.SalaryAbilityDivisor
  if self.humanoid_class == "Doctor" then
    for name, id in pairs(ability_conf_id) do
      if self[name] == 1 then
        wage = wage + level_config.gbv.SalaryAdd[id]
      end
    end
    if not self.is_junior and not self.is_consultant then
      wage = wage + level_config.gbv.SalaryAdd[ability_conf_id.is_doctor]
    end
  end
  return math.max(math.floor(wage), level_config.staff[conf_id[self.humanoid_class]].MinSalary)
end
