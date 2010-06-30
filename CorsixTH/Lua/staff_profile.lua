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
  self.name = string.char(string.byte"A" + math.random(0, 25)) .. ". "
  for _, part_table in ipairs(name_parts) do
    self.name = self.name .. part_table.__random
  end
  self.skill = math.random()
  self.skill_level_modifier = math.random(-50, 50) / 1000 -- [-0.05, +0.05]
  self:parseSkillLevel()
  if self.humanoid_class == "Doctor" then
    -- 65% chance to have at least one ability
    --  1% chance to have all three abilities
    self.is_surgeon      = math.random() < 0.20 and 1.0 or 0
    self.is_psychiatrist = math.random() < 0.25 and 1.0 or 0
    self.is_researcher   = math.random() < 0.20 and 1.0 or 0
  end
  self.wage = self:getFairWage(world)
  -- Vary wage by +/- 15%
  self.wage = math.floor(self.wage * (math.random(850, 1150) / 1000) + 0.5)
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
  local junior_skill = 0.4 + self.skill_level_modifier
  self.is_junior     = self.skill <= junior_skill and 1 - (self.skill / junior_skill) or nil
  local consultant_skill = 0.9 + self.skill_level_modifier
  self.is_consultant = self.skill >= consultant_skill and (self.skill - consultant_skill) / (1 - consultant_skill) or nil
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
      if self[name] then
        wage = wage + level_config.gbv.SalaryAdd[id]
      end
    end
    if not self.is_junior and not self.is_consultant then
      wage = wage + level_config.gbv.SalaryAdd[ability_conf_id.is_doctor]
    end
  end
  return wage
end
