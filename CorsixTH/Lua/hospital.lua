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
  -- TODO: Variate initial balance and reputation based on level
  self.balance = 40000
  self.reputation = 500
  self.reputation_min = 0
  self.reputation_max = 1000
  self.num_deaths = 0
  self.is_in_world = true
  self.transactions = {}
  self.staff = {}
  self.patients = {}
  self.debug_patients = {} -- right-click-commandable patients for testing
  self.disease_casebook = {}
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

function Hospital:onEndMonth()
  -- Spend wages
  local wages = 0
  for i, staff in ipairs(self.staff) do
    wages = wages + staff.profile.wage
  end
  if wages ~= 0 then
    self:spendMoney(wages, _S(8, 2))
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
    reason = _S(8, 10) .. " " .. patient.disease.name
  else
    local room_info = patient:getRoom().room_info
    disease_id = "diag_" .. room_info.id
    reason = _S(8, 8) .. " " .. room_info.name
  end
  local casebook = self.disease_casebook[disease_id]
  local amount = casebook.disease.cure_price
  amount = amount * (casebook.reputation or self.reputation) / 500
  amount = amount * casebook.price
  casebook.money_earned = casebook.money_earned + amount
  -- TODO: Display dollar sign above patient for a short time
  -- TODO: Optionally delay payment through an insurance company
  self:receiveMoney(amount, reason)
end

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
  self:spendMoney(staff.profile.wage, _S(8, 3) .. ": " .. staff.profile.name)
end

function Hospital:addPatient(patient)
  self.patients[#self.patients + 1] = patient
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
