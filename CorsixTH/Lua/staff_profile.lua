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

---@type StaffProfile
local StaffProfile = _G["StaffProfile"]

function StaffProfile:StaffProfile(world, humanoid_class, local_string)
  self.world = world
  self.humanoid_class = humanoid_class
  self.name = "U. N. Initialised"
  self.wage = 0
  self.skill = 0 -- [0.0, 1.0]
  self.layer5 = 2
  self.attention_to_detail = math.random()
  self.profession = local_string
end

function StaffProfile:setDoctorAbilities(psychiatrist, surgeon, researcher, junior, consultant)
  self.is_psychiatrist = psychiatrist
  self.is_surgeon = surgeon
  self.is_researcher = researcher
  self.is_junior = junior
  self.is_consultant = consultant
end

function StaffProfile:initDoctor(psychiatrist, surgeon, researcher, junior, consultant, skill)
  self:setDoctorAbilities(psychiatrist, surgeon, researcher, junior, consultant)
  self:init(skill)
end

function StaffProfile:init(skill)
  self:setSkill(skill)
  self.wage = self:getFairWage()
  self:randomiseOrganical()
end

function StaffProfile:setSkill(skill)
  self.skill = skill
  self:parseSkillLevel()
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

function StaffProfile:randomise(month)
  local level_config = self.world.map.level_config

  -- decide general skill for all staff
  self.skill = math.random()
  --self.skill_level_modifier = math.random(-50, 50) / 1000 -- [-0.05, +0.05]

  if self.humanoid_class == "Doctor" then
    -- find the correct config line (based on month) for generation of the doctor
    local i = 0
    while i < #level_config.staff_levels and
    level_config.staff_levels[i+1].Month <= month do
      i = i+1
    end

    -- list of level_config values and the corresponding staff modifiers, plus the value set for "no"
    local mods = {
      {"ShrkRate", "is_psychiatrist", 0},
      {"SurgRate", "is_surgeon",      0},
      {"RschRate", "is_researcher",   0},
      {"JrRate",   "is_junior",     nil},
      {"ConsRate", "is_consultant", nil},
    }

    -- The following assumes ascending month order of the staff_levels table.
    -- TODO don't assume this but sort when loading map config
    for _, m in ipairs(mods) do
      local rate
      local ind = i
      while not rate do
        assert(ind >= 0, "Staff modifier " .. m[1] .. " not existent (should at least be given by base_config).")
        rate = level_config.staff_levels[ind][m[1]]
        ind = ind - 1
      end
      -- 0 means none. Other values x mean "one in x"; thus 1 means "one in one" aka "all"
      rate = (rate == 0) and 0 or 1 / rate
      self[m[2]] = math.random() < rate and 1.0 or m[3]
    end

    -- is_consultant is forced to nil if is_junior is already 1
    self.is_consultant = not self.is_junior and self.is_consultant or nil

    local jr_limit = level_config.gbv.DoctorThreshold / 1000
    local cons_limit = level_config.gbv.ConsultantThreshold / 1000

    -- put the doctor in the right skill level box
    if self.is_junior then
      self.skill = jr_limit * self.skill
    elseif self.is_consultant then
      self.skill = cons_limit + ((1 - cons_limit) * self.skill)
    else
      self.skill = jr_limit + ((cons_limit - jr_limit) * self.skill)
    end
  end
  self.wage = self:getFairWage()
  self:parseSkillLevel()
  self:randomiseOrganical()
end

function StaffProfile:randomiseOrganical()
  local letters = tostring(our_concat(_S.humanoid_name_starts) .. our_concat(_S.humanoid_name_ends)):sub(33)
  -- If UTF8 then make a table of the letters and pick a random one
  if letters:find("([%z\1-\127\194-\244][\128-\191]*)") then
    local initials = {}
    for uchar in string.gmatch(letters,
      "([%z\1-\127\194-\244][\128-\191]*)") do
      initials[#initials+1] = uchar
    end
    self.name = initials[math.random(1, #initials)] .. ". "
  else
    local num = math.random(1, letters:len())
    self.name = letters:sub(num, num) .. ". "
  end

  for _, part_table in ipairs(name_parts) do
    self.name = self.name .. part_table.__random
  end
  local desc_table1, desc_table2
  if self.skill < 0.55 then
    desc_table1 = _S.staff_descriptions.bad
    desc_table2 = _S.staff_descriptions.misc
  else
    desc_table1 = _S.staff_descriptions.good
    desc_table2 = _S.staff_descriptions.misc
  end
  local descs = {desc_table1.__random,
                 desc_table2.__random}
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

-- Update junior and consultant status
function StaffProfile:parseSkillLevel()
  local level_config = self.world.map.level_config

  local junior_skill = level_config.gbv.DoctorThreshold / 1000
  self.is_junior = self.skill <= junior_skill and 1 or nil

  local consultant_skill = level_config.gbv.ConsultantThreshold / 1000
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

function StaffProfile:getFairWage()
  if self.world.free_build_mode then
    return 0
  end

  local level_config = self.world.map.level_config
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
