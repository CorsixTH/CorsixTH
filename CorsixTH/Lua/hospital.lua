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

class "Hospital"

function Hospital:Hospital(world)
  self.world = world
  -- TODO: Variate initial balance, reputation etc based on level
  self.balance = 40000
  self.loan = 0
  self.value = 32495 -- TODO: How is this calculated?
  self.interest_rate = 0.01 -- Should these be worldwide?
  self.inflation_rate = 0.045
  self.reputation = 500
  self.reputation_min = 0
  self.reputation_max = 1000
  self.radiator_heat = 0.5
  self.num_deaths = 0
  self.num_cured = 0
  self.is_in_world = true
  self.transactions = {}
  self.staff = {}
  self.patients = {}
  self.debug_patients = {} -- right-click-commandable patients for testing
  self.disease_casebook = {}
  self.policies = {}
  self.discovered_diseases = {}
  self.policies["staff_allowed_to_move"] = true
  self.policies["send_home"] = 0.1
  self.policies["guess_cure"] = 0.9
  self.policies["stop_procedure"] = 1 -- Note that this is between 1 and 2 ( = 100% - 200%)
  self.policies["goto_staffroom"] = 0.6
  -- Randomly select three insurance companies to use, only different by name right now.
  -- The first ones are more likely to come
  self.insurance = {}
  for no, local_name in ipairs(_S.insurance_companies) do
    -- NOTE: Will not work if more companies are added
    if math.random(1, 11) < 4 or 11 - no < #self.insurance + 3 then
      self.insurance[#self.insurance + 1] = local_name
    end
    if #self.insurance > 2 then
      break
    end
  end
  -- TODO: Take disease list from the world's available diseases and available
  -- rooms (for diagnosis psuedo-piseases)
  local diseases = TheApp.diseases
  for i, disease in ipairs(diseases) do
    local info = {
      reputation = 500,
      price = 1.0, -- user-set multiplier between 0.5 and 2.0
      money_earned = 0,
      recoveries = 0,
      fatalities = 0,
      turned_away = 0,
      disease = disease,
      discovered = (disease.pseudo and true or false),
      concentrate_research = false,
      cure_effectiveness = 100,
      -- This will only work as long as there's only one treatment room.
      drug = disease.treatment_rooms and disease.treatment_rooms[1] == "pharmacy" or nil,
      psychiatrist = disease.treatment_rooms and disease.treatment_rooms[1] == "psych" or nil,
      machine = disease.requires_machine,
      surgeon = disease.requires_surgeon, -- TODO: Fix when operating theatre is in.
      researcher = disease.requires_researcher, -- TODO: Fix when aliens are in the game.
      pseudo = disease.pseudo, -- Diagnosis is pseudo
    }
    self.disease_casebook[disease.id] = info
  end
end

function Hospital:tick()
  local spawn_rate = 200
  -- Vary spawn rate +/- 150 based on reputation
  spawn_rate = spawn_rate - (self.reputation / 500 - 1) * 150
  -- TODO: Variate spawn rate based on level, etc.
  if self.spawn_rate_cheat then
    -- Roujin's challenge cheat: constant high spawn rate
    spawn_rate = 40
  end
  if math.random(1, spawn_rate) == 1 then
    self:spawnPatient()
  end
end

function Hospital:getPlayerIndex()
  -- TODO: In multiplayer, return 2 or 3 or 4
  return 1
end

function Hospital:getHeliportPosition()
  local x, y = self.world.map.th:getHeliportTile(self:getPlayerIndex())
  -- NB: Level 2 has a heliport tile set, but no heliport, so we ensure that
  -- the specified tile is suitable by checking the adjacent spawn tile for
  -- passability.
  if y > 1 and self.world.map:getCellFlag(x, y - 1, "passable") then
    return x, y
  end
end

function Hospital:getHeliportSpawnPosition()
  local x, y = self:getHeliportPosition()
  if x and y then
    return x, y - 1
  end
end

--[[ Test if a given map tile is part of the hospital.
!param x (integer) The 1-based X co-ordinate of the tile to test.
!param y (integer) The 1-based Y co-ordinate of the tile to test.
]]
function Hospital:isInHospital(x, y)
  -- TODO: Fix to work when there are multiple hospitals.
  return self.world.map.th:getCellFlags(x, y).hospital
end

function Hospital:onEndMonth()
  -- Spend wages
  local wages = 0
  for i, staff in ipairs(self.staff) do
    wages = wages + staff.profile.wage
  end
  if wages ~= 0 then
    self:spendMoney(wages, _S.transactions.wages)
  end
  -- Pay interest on loans, TODO: It should not be possible to return loans
  -- at the end of the month to avoid paying interest
  if self.loan > 0 then
    local pay_this = math.floor(self.loan*self.interest_rate/12)
    self:spendMoney(pay_this, _S.transactions.loan_interest)
  end
end

function Hospital:createEmergency()
  local created_one = false
  if self:getHeliportSpawnPosition() and #self.discovered_diseases > 0 then
    local random_disease = self.discovered_diseases[math.random(1, #self.discovered_diseases)]
    local victims = math.random(4,6) -- TODO: Should depend on disease (e.g. operating theatre is harder)
    local emergency = {
      disease = TheApp.diseases[random_disease],
      victims = victims,
      bonus = 1000 * victims,
      killed_emergency_patients = 0,
      cured_emergency_patients = 0,
    }
    self.emergency = emergency
    local room_name, required_staff, staff_name = 
      self.world:getRoomNameAndRequiredStaffName(emergency.disease.treatment_rooms[1])
    
    local staff_available = self:hasStaffOfCategory(required_staff)
    for _, room in ipairs(self.world.rooms) do
      if room.room_info.id == emergency.disease.treatment_rooms[1] then
        room_name = nil
        break
      end
    end
    local added_info = _S.fax.emergency.cure_possible
    -- TODO: Differentiate if a drug is needed, add drug effectiveness. Add undiscovered treatment.
    -- added_info = _S.fax.emergency.cure_not_possible
    if room_name then
      if staff_available then
        added_info = _S.fax.emergency.cure_not_possible_build:format(room_name) .. "."
      else
        added_info = _S.fax.emergency.cure_not_possible_build_and_employ:format(room_name, staff_name) .. "."
      end
    elseif not staff_available then
      added_info = _S.fax.emergency.cure_not_possible_employ:format(staff_name) .. "."
    end
    local message = {
      {text = _S.fax.emergency.location:format(_S.fax.emergency.locations[math.random(1,9)])},
      {text = _S.fax.emergency.num_disease:format(emergency.victims, emergency.disease.name)},
      {text = added_info},
      {text = _S.fax.emergency.bonus:format(emergency.bonus)},
      choices = {
        {text = _S.fax.emergency.choices.accept, choice = "accept_emergency"},
        {text = _S.fax.emergency.choices.refuse, choice = "refuse"},
      },
    }
    self.world.ui.bottom_panel:queueMessage("emergency", message)
    created_one = true
  end
  return created_one
end

function Hospital:resolveEmergency()
  local rescued_patients = self.emergency.cured_emergency_patients
  for i, patient in ipairs(self.emergency_patients) do
    if patient and patient.hospital and not patient:getRoom() then
      patient:die()
    end
  end
  local total = self.emergency.victims
  local max_bonus = self.emergency.bonus
  local earned = math.floor((rescued_patients/total > 0.75 and 
    rescued_patients/total or 0)*10)*max_bonus/10
  local message = {
    {text = _S.fax.emergency_result.saved_people
      :format(rescued_patients, self.emergency.victims)},
    {text = _S.fax.emergency_result.earned_money:format(max_bonus, earned)},
    choices = {
      {text = _S.fax.emergency_result.close_text, choice = "close", offset = 50},
    },
  }
  self.world.ui.bottom_panel:queueMessage("report", message)
  if earned > 0 then -- Reputation increased
    self:changeReputation("emergency_success")
    self:receiveMoney(earned, _S.transactions.emergency_bonus)
  else -- Too few rescued, reputation hit
    self:changeReputation("emergency_failed")
  end
end

function Hospital:spawnPatient()
  self.world:spawnPatient(self)
end

function Hospital:makeDebugPatient()
  self.world:makeDebugPatient(self)
end

function Hospital:removeDebugPatient(patient)
  for i, p in ipairs(self.debug_patients) do
    if p == patient then
      table.remove(self.debug_patients, i)
      return
    end
  end
end

local debug_n
function Hospital:getDebugPatient()
  if not debug_n or debug_n >= #self.debug_patients then
    debug_n = 1
  else
    debug_n = debug_n + 1
  end
  return self.debug_patients[debug_n]
end

function Hospital:spendMoney(amount, reason)
  self.balance = self.balance - amount
  self:logTransaction{spend = amount, desc = reason}
end

function Hospital:receiveMoney(amount, reason)
  self.balance = self.balance + amount
  self:logTransaction{receive = amount, desc = reason}
end

function Hospital:receiveMoneyForTreatment(patient)
  local disease_id
  local reason
  if patient.diagnosed then
    disease_id = patient.disease.id
    reason = _S.transactions.cure_colon .. " " .. patient.disease.name
  else
    local room_info = patient:getRoom()
    if not room_info then
      print("Warning: Trying to receieve money for treated patient who is "..
            "not in a room")
      return
    end
    room_info = room_info.room_info
    disease_id = "diag_" .. room_info.id
    reason = _S.transactions.treat_colon .. " " .. room_info.name
  end
  local casebook = self.disease_casebook[disease_id]
  local amount = casebook.disease.cure_price
  amount = amount * (casebook.reputation or self.reputation) / 500
  amount = amount * casebook.price
  casebook.money_earned = casebook.money_earned + amount
  patient.world:newFloatingDollarSign(patient, amount)
  -- TODO: Optionally delay payment through an insurance company
  self:receiveMoney(amount, reason)
end

function Hospital:receiveMoneyForProduct(patient, amount, reason)
  patient.world:newFloatingDollarSign(patient, amount)
  self:receiveMoney(amount, reason)
end

--[[ Add a transaction to the hospital's transaction log.
!param transaction (table) A table containing a string field called `desc`, and
at least one of the following integer fields: `spend`, `receive`.
]]
function Hospital:logTransaction(transaction)
  transaction.balance = self.balance
  transaction.day = self.world.day
  transaction.month = self.world.month
  while #self.transactions > 20 do
    self.transactions[#self.transactions] = nil
  end
  table.insert(self.transactions, 1, transaction)
end

function Hospital:addStaff(staff)
  self.staff[#self.staff + 1] = staff
  -- Cost of hiring staff:
  self:spendMoney(staff.profile.wage, _S.transactions.hire_staff .. ": " .. staff.profile.name)
end

function Hospital:addPatient(patient)
  self.patients[#self.patients + 1] = patient
end

function Hospital:hasStaffOfCategory(category)
  for i, staff in ipairs(self.staff) do
    if staff.humanoid_class == category then
      return true
    elseif staff.humanoid_class == "Doctor" then
      if (category == "Psychiatrist" and staff.profile.is_psychiatrist >= 1.0) or 
          (category == "Surgeon" and staff.profile.is_surgeon >= 1.0) or 
          (category == "Researcher" and staff.profile.is_researcher >= 1.0) then
        return true
      end
    end
  end
  return false
end

local function RemoveByValue(t, value)
  for i, v in ipairs(t) do
    if v == value then
      table.remove(t, i)
      return true
    end
  end
  return false
end

function Hospital:removeStaff(staff)
  RemoveByValue(self.staff, staff)
end

function Hospital:removePatient(patient)
  RemoveByValue(self.patients, patient)
end

-- TODO: This should depend on difficulty and level
 local reputation_changes = {
  ["cured"]  =  1, -- a patient was successfully treated
  ["death"]  = -4, -- a patient died due to bad treatment or waiting too long
  ["kicked"] = -3, -- firing a staff member OR sending a patient home
  ["emergency_success"] = 15,
  ["emergency_failed"] = -20,
}

function Hospital:changeReputation(reason)
  self.reputation = self.reputation + reputation_changes[reason]
  if self.reputation < self.reputation_min then
    self.reputation = self.reputation_min
  elseif self.reputation > self.reputation_max then
    self.reputation = self.reputation_max
  end
end

function Hospital:setCrazyDoctors(crazy)
  self.crazy_doctors = crazy
  for i, staff in ipairs(self.staff) do
    if staff.humanoid_class == "Doctor" then
      if crazy then
        staff:setLayer(5, staff.layers[5] + 4)
        staff.profile.temp_skill = staff.profile.skill
        staff.profile.skill = 0
      else
        if not (staff.layers[5] < 5) then -- If sane doctors were hired in between
          staff:setLayer(5, staff.layers[5] - 4)
          staff.profile.skill = staff.profile.temp_skill
          staff.profile.temp_skill = nil
        end
      end
    end
  end
end

class "AIHospital" (Hospital)

function AIHospital:AIHospital(...)
  self:Hospital(...)
  self.is_in_world = false
end

function AIHospital:spawnPatient()
  -- TODO: Simulate patient
end

function AIHospital:logTransaction()
  -- AI doesn't need a log of transactions, as it is only used for UI purposes
end

