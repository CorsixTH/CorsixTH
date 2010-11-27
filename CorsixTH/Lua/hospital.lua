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
  local level_config = world.map.level_config
  local level = world.map.level_number
  local balance = 40000
  local interest_rate = 0.01
  if level_config then
    if level_config.towns and level_config.towns[level] then
      balance = level_config.towns[level].StartCash
      interest_rate = level_config.towns[level].InterestRate / 10000
    elseif level_config.town then
      balance = level_config.town.StartCash
      interest_rate = level_config.town.InterestRate / 10000
    end
    -- Check if awards are available
    if level_config.awards_trophies then
      self.win_awards = true
    end
  end
  self.name = os.getenv("USER") or os.getenv("USERNAME") or "PLAYER"
  -- TODO: Variate initial reputation etc based on level
  self.balance = balance
  self.loan = 0
  self.acc_loan_interest = 0
  self.acc_research_cost = 0
  self.discover_autopsy_risk = 10
  self.initial_grace = true
  
  -- The sum of all material values (tiles, rooms, objects).
  -- Initial value: hospital tile count * tile value + 20000
  self.value = world.map:getParcelPrice(self:getPlayerIndex()) + 20000
  
  -- TODO: With the fame/shame screen and scoring comes salary.
  self.player_salary = 10000
  self.salary_offer = 0
  
  -- Initial values
  self.interest_rate = interest_rate
  self.inflation_rate = 0.045
  self.salary_incr = level_config.gbv.ScoreMaxInc or 300
  self.sal_min = level_config.gbv.ScoreMaxInc / 6 or 50
  self.reputation = 500
  self.reputation_min = 0
  self.reputation_max = 1000
  self.radiator_heat = 0.5
  self.num_visitors = 0
  self.num_deaths = 0
  self.num_deaths_this_year = 0
  self.num_cured = 0
  self.not_cured = 0
  self.percentage_cured = 0
  self.percentage_killed = 0
  self.population = 1 -- TODO: Percentage showing how much of the total population that goes
  -- to the player's hospital, used for one of the goals. Change when competitors are there.
  
  -- Other statistics, back to zero each year
  self.sodas_sold = 0
  self.reputation_above_threshold = self.win_awards and level_config.awards_trophies.Reputation < self.reputation or false
  
  self.is_in_world = true
  self.opened = false
  self.transactions = {}
  self.staff = {}
  self.patients = {}
  self.debug_patients = {} -- right-click-commandable patients for testing
  self.disease_casebook = {}
  self.policies = {}
  self.discovered_diseases = {} -- a list
  self.discovered_rooms = {} -- a set; keys are the entries of TheApp.rooms, values are true or nil
  self.research_rooms = {} -- a set; keys are the entries of TheApp.rooms, values are research
  -- points gained for this room or nil
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
  -- A list of how much each insurance company owes you. The first entry for
  -- each company is the current month's dept, the second the previous 
  -- month and the third the month before that.
  -- All payment that goes through an insurance company a given month is payed two
  -- months later. For example diagnoses in April are payed the 1st of July
  self.insurance_balance = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}
  -- Initialize any staff already present in the world
  for _, staff in ipairs(world.initial_staff) do
    self:addStaff(staff)
    staff:setHospital(self)
  end
  -- Initialize diseases
  local diseases = TheApp.diseases
  local expertise = self.world.map.level_config.expertise
  local gbv = self.world.map.level_config.gbv
  for i, disease in ipairs(diseases) do
    local disease_available = true
    local drug_effectiveness = 95
    local drug = disease.treatment_rooms and disease.treatment_rooms[1] == "pharmacy" or nil
    local drug_cost = 100
    if expertise then
      disease_available = expertise[disease.expertise_id].Known == 1 and true or false
      -- This means that the config is available
      drug_effectiveness = gbv.StartRating
      drug_cost = gbv.StartCost
    end
    if world.available_diseases[disease.id] or disease.pseudo then
      local info = {
        reputation = not disease.pseudo and 500 or nil,
        price = 1.0, -- user-set multiplier between 0.5 and 2.0
        money_earned = 0,
        recoveries = 0,
        fatalities = 0,
        turned_away = 0,
        disease = disease,
        discovered = disease_available,
        concentrate_research = false,
        cure_effectiveness = drug and drug_effectiveness or 100,
        -- This will only work as long as there's only one treatment room.
        drug = drug,
        drug_cost = drug and drug_cost,
        psychiatrist = disease.treatment_rooms and disease.treatment_rooms[1] == "psych" or nil,
        machine = disease.requires_machine,
        -- This assumes we always have the ward then the operating_theatre as treatment rooms.
        surgeon = disease.treatment_rooms and disease.treatment_rooms[2] == "operating_theatre" or nil,
        researcher = disease.requires_researcher, -- TODO: Fix when aliens are in the game.
        pseudo = disease.pseudo, -- Diagnosis is pseudo
      }
      self.disease_casebook[disease.id] = info
    end
  end
end

--[[ Initialize research for the level.
!param next_diag (room) The next diagnosis room to research
!param next_cure (room) The next treatment room to research
]]
function Hospital:_initResearch(next_diag, next_cure) 
  self.research = {
    improvements = {frac = 20, points = 0, current = "inflation"},
    drugs = {frac = 20, points = 0, current = "invisibility"},
    diagnosis = {frac = 20, points = 0, current = next_diag},
    cure = {frac = 20, points = 0, current = next_cure},
    specialisation = {frac = 20, points = 0, current = "special"},
    global = 100,
  }
  self.research_dep_built = false
end

--[[ Add some more research points to research progress. If 
autopsy_room is specified points are not used. Instead research
progresses according to the level config for autopsies. 
Otherwise they will be divided according to the research policy 
into the different research areas.
!param points (integer) The total amount of points (before applying
any level specific divisors to add to research.
!param autopsy_room (string) If a specific room should get points following
an autopsy, then this is the id of that room.
]]
function Hospital:addResearchPoints(points, autopsy_room)
  -- Fetch the level research divisor. Fallback is 5 (medium)
  local level_config = self.world.map.level_config
  local divisor = 5
  if level_config and level_config.gbv then
    divisor = level_config.gbv.ResearchPointsDivisor or 5
  end
  -- If an autopsy_room has been specified, let research go there.
  if autopsy_room then
    -- Currently only research of rooms is implemented
    for room, value in pairs(self.research_rooms) do
      if room.id == autopsy_room then
        -- Maybe we have enough to discover the room?
        local required = level_config.expertise[room.level_config_research].RschReqd
        local advance = level_config.gbv.AutopsyRschPercent / 100 * required
        -- Is generic research also focusing on this room?
        local normal_points = 0
        if self.research.cure.current.id == autopsy_room then
          normal_points = self.research.cure.points
        end
        if value + advance + normal_points > required then
          self:discoverRoom(room, "cure")
        else
          self.research_rooms[room] = value + advance
        end
      end
    end
  else
    ---- General research ----
    -- Divide the points into the different areas. If global is not at 100 % they are
    -- lowered, but then cost is also lowered.
    
    points = math.ceil(points*self.research.global/(100*divisor))
    -- It also costs to research.
    -- TODO: This is now simply 3 monetary units per "research", what should it be?
    self.acc_research_cost = self.acc_research_cost + math.ceil(3*self.research.global/(100))
    
    -- Divide the points into the different categories
    for _, info in pairs(self.research) do
      if type(info) == "table" then
        info.points = info.points + points*info.frac/100
      end
    end
    local areas = self.research
    local config = self.world.map.level_config.expertise
    
    -- Do something if the number of points in a category is enough to get something out of it.
    if areas.diagnosis.current then
      -- At this point we know that a level config exists, otherwise all rooms would be available
      local room = areas.diagnosis.current
      local added_points = self.research_rooms[room]
      local req = config[room.level_config_research].RschReqd
      if req < areas.diagnosis.points + added_points then
        areas.diagnosis.points = areas.diagnosis.points + added_points - req
        self:discoverRoom(room, "diagnosis")
      end
    end
    if areas.cure.current then
      local room = areas.cure.current
      -- Some extra points might have been added through for example the autopsy
      local added_points = self.research_rooms[room]
      local req = config[room.level_config_research].RschReqd
      if req < areas.cure.points + added_points then
        areas.cure.points = areas.cure.points + added_points - req
        self:discoverRoom(room, "cure")
      end
    end
  end
end

--[[ When a new room is ready to be discovered, this function is called.
Also announces through the adviser that the new room is available.
!param room (room) The room to make available
!param cat (string) One of "diagnosis" or "cure", the category from this
room is.
]]
function Hospital:discoverRoom(room, cat)
  self.discovered_rooms[room] = true
  self.research_rooms[room] = nil
  if self == self.world.ui.hospital then
    self.world.ui.adviser:say(_S.adviser.research.new_machine_researched:format(room.name))
  end
  -- Find something new to research
  local finished = true
  local areas = self.research
  for room, _ in pairs(self.research_rooms) do
    if (cat == "diagnosis" and room.categories.diagnosis) 
    or (cat == "cure" and not room.categories.diagnosis) then
      areas[cat].current = room
      finished = false
      break
    end
  end
  -- No more rooms to research in this category. Set the fraction of this area
  -- to zero.
  if finished then
    areas[cat].current = nil
    areas.global = areas.global - areas[cat].frac
    areas[cat].frac = 0
    if self == self.world.ui.hospital then
      -- TODO: The original string contains a %-sign, format cannot handle it
      --self.world.ui.adviser:say(_S.adviser.research.drug_fully_researched:
      --:format(_S.research.categories.cure))
    end
  end
end

function Hospital:afterLoad(old, new)
  if old < 8 then
    -- The list of discovered rooms was not saved. The best we can do is make everything
    -- discovered which is available for the level.
    self.discovered_rooms = {}
    for _, room in ipairs(self.world.available_rooms) do
      self.discovered_rooms[room] = true
    end
  end
  if old < 9 then
    -- Initial opening added
    self.opened = true
  end
  if old < 14 then
    self:_initResearch()
  end
  if old < 19 then
    -- The statistics on the current map will be wrong, but it's better than nothing.
    self.num_visitors = 0
    self.player_salary = 10000
    self.sodas_sold = 0
    if self.world.map.level_config and self.world.map.level_config.awards_trophies then
      self.win_awards = true
    end
  end
  if old < 20 then
    -- New variables
    self.acc_loan_interest = 0
    self.acc_research_cost = 0
    -- Go through all diseases and remove individual reputation for diagnoses
    for _, disease in pairs(self.disease_casebook) do
      if disease.pseudo == true then
        disease.reputation = nil
      end
    end
    -- Go through all possible rooms and add those not researched to the research list.
    self.research_rooms = {}
    local next_diag = nil
    local next_cure = nil
    for _, room in ipairs(self.world.available_rooms) do
      if not self.discovered_rooms[room] then
        self.research_rooms[room] = 0
        if room.categories.diagnosis then
          next_diag = room
        else
          next_cure = room
        end
      end
    end
    -- Go through all rooms and find if a research department has been built
    -- Also check for training rooms where the training_factor needs to be set
    for _, room in pairs(self.world.rooms) do
      if room.room_info.id == "research" then
        self.research_dep_built = true
      elseif room.room_info.id == "training" then
        -- A standard value to keep things going
        room.training_factor = 5
      end
    end
    -- Redefine the research table
    self.research = {
      improvements = {frac = 20, points = 0, current = "inflation"},
      drugs = {frac = 20, points = 0, current = "invisibility"},
      diagnosis = {frac = 20, points = 0, current = next_diag},
      cure = {frac = 20, points = 0, current = next_cure},
      specialisation = {frac = 20, points = 0, current = "special"},
      global = 100,
    }
    self.discover_autopsy_risk = 10
  end
  if old < 24 then
    -- New variables
    self.salary_incr = 300
    self.sal_min = 50
    self.salary_offer = 0
  end
  if old < 25 then
    self.insurance_balance = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}
    self.num_deaths_this_year = 0
  end
end

function Hospital:tick()
  if self.opened then
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
end

function Hospital:purchasePlot(plot_number)
  local map = self.world.map
  if map.th:isParcelPurchasable(plot_number, self:getPlayerIndex()) then
    local cost = map:getParcelPrice(plot_number)
    if cost <= self.balance then
      self.world:setPlotOwner(plot_number, self:getPlayerIndex())
      self:spendMoney(cost, _S.transactions.buy_land, cost)
      return true
    end
  end
  return false
end

function Hospital:getPlayerIndex()
  -- TODO: In multiplayer, return 2 or 3 or 4
  return 1
end

-- Returns the heliport x and y coordinates or nil if none exist.
function Hospital:getHeliportPosition()
  local x, y = self.world.map.th:getHeliportTile(self:getPlayerIndex())
  -- NB: Level 2 has a heliport tile set, but no heliport, so we ensure that
  -- the specified tile is suitable by checking the adjacent spawn tile for
  -- passability.
  if y > 1 and self.world.map:getCellFlag(x, y - 1, "passable") then
    return x, y
  end
end

-- Returns the tile on which patients should spawn when getting out of the helicopter.
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

-- Called at the end of each day.
function Hospital:onEndDay()
  local pay_this = self.loan*self.interest_rate/365 -- No leap years
  self.acc_loan_interest = self.acc_loan_interest + pay_this
end

-- Called at the end of each month.
function Hospital:onEndMonth()
  -- Spend wages
  local wages = 0
  for i, staff in ipairs(self.staff) do
    wages = wages + staff.profile.wage
  end
  if wages ~= 0 then
    self:spendMoney(wages, _S.transactions.wages)
  end
  -- Pay interest on loans
  if math.floor(self.acc_loan_interest+0.5) > 0 then
    self:spendMoney(math.floor(self.acc_loan_interest+0.5), _S.transactions.loan_interest)
    self.acc_loan_interest = 0
  end
  -- Pay research costs
  if math.floor(self.acc_research_cost+0.5) > 0 then
    self:spendMoney(math.floor(self.acc_research_cost+0.5), _S.transactions.research)
    self.acc_research_cost = 0
  end
  -- add to score each month
  -- rate varies on some performance factors i.e. reputation above 500 increases the score
  -- and the number of deaths will reduce the score. 
  local sal_inc = self.salary_incr /10
  local sal_mult = ((self.reputation)-500)/((self.num_deaths)+1) -- added 1 so that you don't multipy by 0
  local month_incr = sal_inc + sal_mult
  -- To ensure that you can't recieve less than 50 or 
  -- more than 300 per month
  if month_incr < self.sal_min then
    month_incr = self.sal_min
  elseif month_incr > self.salary_incr then
    month_incr = self.salary_incr
  else 
    month_incr = month_incr
  end
  self.player_salary = self.player_salary + math.ceil(month_incr)
  
  -- TODO: do you get interest on the balance owed?
  for i, company in ipairs(self.insurance_balance) do
    -- Get the amount that is about to be payed to the player
    local payout_amount = company[3]
    if payout_amount > 0 then
      local str = _S.transactions.insurance_colon .. " " .. self.insurance[i]
      self:receiveMoney(payout_amount, str)
    end
    -- Shift the amounts to the left
    table.remove(company, 3)
    table.insert(company, 1, 0) -- The new month have no payments yet
  end

  -- Pay heating costs
  -- TODO: Should this also be on a per day basis "behind the scenes" as above?
  local radiators = self.world.object_counts.radiator
  local heating_costs = math.floor(((self.radiator_heat *10)* radiators)* 7.5)
  self:spendMoney(heating_costs, _S.transactions.heating)
end

--! Called at the end of each year
function Hospital:onEndYear()
  self.sodas_sold = 0
  self.num_deaths_this_year = 0
  self.reputation_above_threshold = self.win_awards 
  and self.world.map.level_config.awards_trophies.Reputation < self.reputation or false
  -- On third year of level 3 there is the large increase to salary
  -- this will replicate that. I have still to check other levels above 5 to 
  -- see if there are other large increases.
  -- TODO Hall of fame and shame
  if self.world.year == 3 and self.world.map.level_number == 3 then
    -- adds the extra to salary in level 3 year 3
    self.player_salary = self.player_salary + math.random(8000,20000)
  end
end

-- Creates complete emergency with patients, what disease they have, what's needed
-- to cure them and the fax.
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
    -- The last room in the list of treatment rooms is considered when checking for availability.
    -- It works for all original diseases, but if we introduce new multiple room diseases it might break.
    -- TODO: Make it work for all kinds of lists of treatment rooms.
    local no_rooms = #emergency.disease.treatment_rooms
    local room_name, required_staff, staff_name = 
      self.world:getRoomNameAndRequiredStaffName(emergency.disease.treatment_rooms[no_rooms])
    
    local staff_available = self:hasStaffOfCategory(required_staff)
    -- Check so that all rooms in the list are available
    for _, room in pairs(self.world.rooms) do
      if room.room_info.id == emergency.disease.treatment_rooms[no_rooms] then
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
    self.world.ui.bottom_panel:queueMessage("emergency", message, nil, 24*20, 2) -- automatically refuse after 20 days
    created_one = true
  end
  return created_one
end

-- Called when the timer runs out during an emergency or when all emergency patients are cured or dead.
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
      {text = _S.fax.emergency_result.close_text, choice = "close"},
    },
  }
  self.world.ui.bottom_panel:queueMessage("report", message, nil, 24*25, 1)
  if earned > 0 then -- Reputation increased
    self:changeReputation("emergency_success", self.emergency.disease)
    self:receiveMoney(earned, _S.transactions.emergency_bonus)
  else -- Too few rescued, reputation hit
    self:changeReputation("emergency_failed", self.emergency.disease)
  end
end

function Hospital:spawnPatient()
  self.world:spawnPatient(self)
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

--[[ Lowers the player's money by the given amount and logs the transaction.

!param amount (integer) The (positive) amount to spend.
!param reason (string) A string that shows what happened. Should be one of the strings
in _S.transactions.
!param changeValue (integer) The (positive) amount the hospital value should be increased
]]
function Hospital:spendMoney(amount, reason, changeValue)
  self.balance = self.balance - amount
  self:logTransaction{spend = amount, desc = reason}
  if changeValue then
    self.value = self.value + changeValue
  end
end

--[[ Increases the player's money by the given amount and logs the transaction.

!param amount (integer) The (positive) amount to receive.
!param reason (string) A string that tells what happened. Should be one of the strings
in _S.transactions.
!param changeValue (integer) The (positive) amount the hospital value should be decreased
]]
function Hospital:receiveMoney(amount, reason, changeValue)
  self.balance = self.balance + amount
  self:logTransaction{receive = amount, desc = reason}
  if changeValue then
    self.value = self.value - changeValue
  end
end

--[[ Determines how much the player should receive after a patient is treated in a room.

!param patient (Patient) The patient that just got treated.
]]
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
  amount = math.ceil(amount * casebook.price)
  casebook.money_earned = casebook.money_earned + amount
  patient.world:newFloatingDollarSign(patient, amount)
  -- 25% of the payments now go through insurance
  if patient.insurance_company then
    self:addInsuranceMoney(patient.insurance_company, amount)
  else
    self:receiveMoney(amount, reason)  
  end
end

function Hospital:addInsuranceMoney(company, amount)
  local old_balance = self.insurance_balance[company][1]
  self.insurance_balance[company][1] = old_balance + amount
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
  -- Add to the hospital's visitor count
  self.num_visitors = self.num_visitors + 1
end

function Hospital:humanoidDeath(humanoid)
  self.num_deaths = self.num_deaths + 1
  self.num_deaths_this_year = self.num_deaths_this_year + 1
  
  self:changeReputation("death", humanoid.disease)
  self:updatePercentages()
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

function Hospital:changeReputation(reason, disease)
  local amount
  if reason == "autopsy_discovered" then
    local config = self.world.map.level_config.gbv.AutopsyRepHitPercent
    amount = config and math.floor(-self.reputation*config/100) or -70
  else
    amount = reputation_changes[reason]
  end
  self.reputation = self.reputation + amount
  if disease then
    local casebook = self.disease_casebook[disease.id]
    casebook.reputation = casebook.reputation + amount
  end
  if self.reputation < self.reputation_min then
    self.reputation = self.reputation_min
  elseif self.reputation > self.reputation_max then
    self.reputation = self.reputation_max
  end
  -- Check if criteria for trophy is still met
  if self.reputation_above_threshold then
    self.reputation_above_threshold = self.world.map.level_config.awards_trophies.Reputation < self.reputation
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

function Hospital:updatePercentages()
  self.percentage_killed = self.num_deaths / (self.num_cured + self.num_deaths) * 100
  self.percentage_cured = self.num_cured / (self.num_cured + self.not_cured + self.num_deaths) * 100
end

function Hospital:getAveragePatientAttribute(attribute)
  local sum = 0
  for _, patient in ipairs(self.patients) do
    sum = sum + patient.attributes[attribute]
  end
  return sum / #self.patients
end

class "AIHospital" (Hospital)

local competitors = {
  "ORAC", 
  "COLOSSUS", 
  "HAL", 
  "MULTIVAC", 
  "HOLLY", 
  "DEEP THOUGHT", 
  "ZEN", 
  "SKYNET",
  "MARVIN",
  "CEREBRO",
  "MOTHER",
  "JAYNE",
  "CORSIX",
  "ROUJIN",
  "EDVIN",
}

function AIHospital:AIHospital(competitor, ...)
  self:Hospital(...)
  if competitors[competitor] then
    self.name = competitors[competitor]
  else
    self.name = "NONAME"
  end
  self.is_in_world = false
end

function AIHospital:spawnPatient()
  -- TODO: Simulate patient
end

function AIHospital:logTransaction()
  -- AI doesn't need a log of transactions, as it is only used for UI purposes
end

