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

---@type Hospital
local Hospital = _G["Hospital"]

function Hospital:Hospital(world, avail_rooms, name)
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
  self.name = name or "PLAYER"
  -- TODO: Variate initial reputation etc based on level
  -- When playing in free build mode you don't care about money.
  self.balance = not world.free_build_mode and balance or 0
  self.loan = 0
  self.acc_loan_interest = 0
  self.acc_research_cost = 0
  self.acc_overdraft = 0
  self.acc_heating = 0
  self.discover_autopsy_risk = 10
  self.initial_grace = true

  -- The sum of all material values (tiles, rooms, objects).
  -- Initial value: hospital tile count * tile value + 20000
  self.value = world.map:getParcelPrice(self:getPlayerIndex()) + 20000

  -- TODO: With the fame/shame screen and scoring comes salary.
  self.player_salary = 10000
  self.salary_offer = 0


  self.handymanTasks = {}
  -- Represents the "active" epidemic non-nil if
  -- an epidemic is happening currently in the hospital
  -- Only one epidemic is ever "active"
  self.epidemic = nil

  -- The pool of epidemics which may happen in the future.
  -- Epidemic in this table continue in the background its
  -- patients infecting each other. Epidemics are chosen from
  -- this pool to become the "active" epidemic
  self.future_epidemics_pool = {}
  -- How many epidemics can exist simultaneously counting current and future
  -- epidemics. If epidemic_limit = 1 then only one epidemic can exist at a
  -- time either in the futures pool or as a current epidemic.
  self.concurrent_epidemic_limit = self.world.map.level_config.gbv.EpidemicConcurrentLimit or 1

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
  self.seating_warning = 0
  self.num_explosions = 0
  self.announce_vip = 0
  self.vip_declined = 0
  self.num_vips = 0 -- used to check if it's the user's first vip
  self.percentage_cured = 0
  self.percentage_killed = 0
  self.msg_counter = 0
  self.population = 0.25 -- TODO: Percentage showing how much of
  -- the total population that goes to the player's hospital,
  -- used for one of the goals. Change when competitors are there.
  -- Since there are none right now the player's hospital always get
  -- 50 % of all patients as soon as gbv.AllocDelay has expired.

  -- Statistics used in the graph dialog. Each entry is the month, inside it
  -- is "money in", "money out", wages, balance, visitors, cures, deaths, reputation
  -- statistic[i] shows what the values were when going from month i - 1 to i.
  self.statistics = {
    {
      money_in = 0,
      money_out = 0,
      wages = 0,
      balance = balance,
      visitors = 0,
      cures = 0,
      deaths = 0,
      reputation = 500, -- TODO: Always 500 from the beginning?
    }
  }
  self.money_in = 0
  self.money_out = 0

  -- Other statistics, back to zero each year
  self.sodas_sold = 0
  self.reputation_above_threshold = self.win_awards and level_config.awards_trophies.Reputation < self.reputation or false
  self.num_vips_ty  = 0 -- used to count how many VIP visits in the year for an award
  self.pleased_vips_ty  = 0
  self.num_cured_ty = 0
  self.not_cured_ty = 0
  self.num_visitors_ty = 0

  self.ownedPlots = {1}
  self.is_in_world = true
  self.opened = false
  self.transactions = {}
  self.staff = {}
  self.reception_desks = {}
  self.patients = {}
  self.debug_patients = {} -- right-click-commandable patients for testing
  self.disease_casebook = {}
  self.policies = {}
  self.discovered_diseases = {} -- a list

  self.discovered_rooms = {} -- a set; keys are the entries of TheApp.rooms, values are true or nil
  self.undiscovered_rooms = {} -- NB: These two together must form the list world.available_rooms
  for _, avail_room in ipairs(avail_rooms) do
    if avail_room.is_discovered then
      self.discovered_rooms[avail_room.room] = true
    else
      self.undiscovered_rooms[avail_room.room] = true
    end
  end

  self.policies["staff_allowed_to_move"] = true
  self.policies["send_home"] = 0.1
  self.policies["guess_cure"] = 0.9
  self.policies["stop_procedure"] = 1 -- Note that this is between 1 and 2 ( = 100% - 200%)
  self.policies["goto_staffroom"] = 0.6
  self.policies["grant_wage_increase"] = TheApp.config.grant_wage_increase
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
      disease_available = expertise[disease.expertise_id].Known == 1
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
      if disease_available and not disease.pseudo then
        self.discovered_diseases[#self.discovered_diseases + 1] = disease.id
      end
    end
  end
  self.research = ResearchDepartment(self)

  -- Initialize build cost for all available rooms.
  for _, avail_room in ipairs(avail_rooms) do
    self.research.research_progress[avail_room.room] = {
        -- In free build mode, everything is freely available.
        build_cost = not self.free_build_mode and avail_room.build_cost or 0,
      }
  end
end

-- Seasoned players will know these things, but it does not harm to be reminded if there is no staff room or toilet!
function Hospital:noStaffroom_msg()
  local staffroom_msg = {
    (_A.warnings.build_staffroom),
    (_A.warnings.need_staffroom),
    (_A.warnings.staff_overworked),
    (_A.warnings.staff_tired),
  }
  if staffroom_msg then
    self.world.ui.adviser:say(staffroom_msg[math.random(1, #staffroom_msg)])
    self.staff_room_msg = true
  end
end

function Hospital:noToilet_msg()
  local toilet_msg = {
    (_A.warnings.need_toilets),
    (_A.warnings.build_toilets),
    (_A.warnings.build_toilet_now),
  }
  if toilet_msg then
    self.world.ui.adviser:say(toilet_msg[math.random(1, #toilet_msg)])
    self.toilet_msg = true
  end
end

-- Give praise where it is due
function Hospital:praiseBench()
  local bench_msg = {
    (_A.praise.many_benches),
    (_A.praise.plenty_of_benches),
    (_A.praise.few_have_to_stand),
  }
  if bench_msg then
    self.world.ui.adviser:say(bench_msg[math.random(1, #bench_msg)])
    self.bench_msg = true
  end
end

--! Messages regarding numbers cured and killed
function Hospital:msgCured()
  local msg_chance = math.random(1, 15)
  if self.num_cured > 1 then
    if msg_chance == 3 and self.msg_counter > 10 then
      self.world.ui.adviser:say(_A.level_progress.another_patient_cured:format(self.num_cured))
      self.msg_counter = 0
    elseif msg_chance == 12 and self.msg_counter > 10 then
      self.world.ui.adviser:say(_A.praise.patients_cured:format(self.num_cured))
      self.msg_counter = 0
    end
  end
end
--! So the messages don't show too often there will need to be at least 10 days before one can show again.
function Hospital:msgKilled()
  local msg_chance = math.random(1, 10)
  if self.num_deaths > 1 then
    if msg_chance < 4 and self.msg_counter > 10 then
      self.world.ui.adviser:say(_A.warnings.many_killed:format(self.num_deaths))
      self.msg_counter = 0
    elseif msg_chance > 7 and self.msg_counter > 10 then
      self.world.ui.adviser:say(_A.level_progress.another_patient_killed:format(self.num_deaths))
      self.msg_counter = 0
    end
  end
end

-- Warn if the hospital is lacking some basics
function Hospital:warningBench()
  local bench_msg = {
    (_A.warnings.more_benches),
    (_A.warnings.people_have_to_stand),
  }
  if bench_msg then
    self.world.ui.adviser:say(bench_msg[math.random(1, #bench_msg)])
    self.bench_msg = true
  end
end

-- Warn when it is too hot
function Hospital:warningTooHot()
  local hot_msg = {
    (_A.information.initial_general_advice.decrease_heating),
    (_A.warnings.patients_too_hot),
    (_A.warnings.patients_getting_hot),
  }
  if hot_msg then
    self.world.ui.adviser:say(hot_msg[math.random(1, #hot_msg)])
    self.warmth_msg = true
  end
end

-- Warn when it is too cold
function Hospital:warningTooCold()
  local cold_msg = {
    (_A.information.initial_general_advice.increase_heating),
    (_A.warnings.patients_very_cold),
    (_A.warnings.people_freezing),
  }
  if cold_msg then
    self.world.ui.adviser:say(cold_msg[math.random(1, #cold_msg)])
    self.warmth_msg = true
  end
end

function Hospital:warningThirst()
  local thirst_msg = {
    (_A.warnings.patients_thirsty),
    (_A.warnings.patients_thirsty2),
  }
  if thirst_msg then
    self.world.ui.adviser:say(thirst_msg[math.random(1, #thirst_msg)])
    self.thirst_msg = true
  end
end

-- Remind the player when cash is low that a loan might be available
function Hospital:cashLow()
  -- Don't remind in free build mode.
  if self.world.free_build_mode then
    return
  end
  local hosp = self.world.hospitals[1]
  local cashlowmessage = {
    (_A.warnings.money_low),
    (_A.warnings.money_very_low_take_loan),
    (_A.warnings.cash_low_consider_loan),
  }
  if hosp.balance < 2000 and hosp.balance >= -500 then
    hosp.world.ui.adviser:say(cashlowmessage[math.random(1, #cashlowmessage)])
  elseif hosp.balance < -2000 and hosp.world.month > 8 then
    -- ideally this should be linked to the lose criteria for balance
    hosp.world.ui.adviser:say(_A.warnings.bankruptcy_imminent)
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
    -- NOTE: This will no longer work, but cluttering the code with stub functions
    -- for this "old" compatibility, is it necessary?
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
      improvements =   {frac = 20, points = 0, current = "inflation"},
      drugs =          {frac = 20, points = 0, current = "invisibility"},
      diagnosis =      {frac = 20, points = 0, current = next_diag},
      cure =           {frac = 20, points = 0, current = next_cure},
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
  if old < 30 then
    if self.emergency then
      self.emergency.percentage = 0.75
    end
  end
  if old < 33 then
    -- Research has been revamped and expanded. Drugs and improvements
    -- will work fine, but room research needs to be rebuilt.
    local research = ResearchDepartment(self)
    self.undiscovered_rooms = {}
    local cure, diagnosis
    local config = self.world.map.level_config.objects
    for _, room in ipairs(self.world.available_rooms) do
      -- If a room is discovered, make sure its objects are also
      -- discovered, otherwise add it to the undiscovered list.
      if self.discovered_rooms[room] then
        for name, _ in pairs(room.objects_needed) do
          local object = TheApp.objects[name]
          if config[object.thob] and (config[object.thob].AvailableForLevel == 1)
          and object.research_category
          and not research.research_progress[object].discovered then
            local progress = self.research_rooms[room]
            if self.research.cure.current == room
            or self.research.diagnosis.current == room then
              progress = progress + self.research.diagnosis.points
            end
            research.research_progress[object].discovered = true
            research.research_progress[object].points = progress
          end
        end
      else
        self.undiscovered_rooms[room] = true
        if not cure or not diagnosis then
          for name, _ in pairs(room.objects_needed) do
            local object = TheApp.objects[name]
            if config[object.thob] and (config[object.thob].AvailableForLevel == 1)
            and object.research_category
            and not research.research_progress[object].discovered then
              if object.research_category == "cure" then
                cure = object
              elseif object.research_category == "diagnosis" then
                diagnosis = object
              end
            end
          end
        end
      end
    end
    local policy = research.research_policy
    if cure then
      policy.cure.current = cure
    else
      policy.global = policy.global - policy.cure.frac
      policy.cure.frac = 0
    end
    if diagnosis then
      research.research_policy.diagnosis.current = diagnosis
    else
      policy.global = policy.global - policy.diagnosis.frac
      policy.diagnosis.frac = 0
    end
    self.research = research
    self.research_rooms = nil
    -- Cost of rooms has also been changed
    local rooms = self.world.map.level_config.rooms
    if not rooms then
      -- Add the new variables manually.
      rooms = {
        [7] = {Cost = 2280}, -- GP_OFFICE
        [8] = {Cost = 2270}, -- PSYCHO
        [9] = {Cost = 1700}, -- WARD
        [10] = {Cost = 2250}, -- OP_THEATRE
        [11] = {Cost = 500}, -- PHARMACY
        [12] = {Cost = 470}, -- CARDIO
        [13] = {Cost = 3970}, -- SCANNER
        [14] = {Cost = 2000}, -- ULTRASCAN
        [15] = {Cost = 3000}, -- BLOOD_MACHINE
        [16] = {Cost = 2000}, -- XRAY
        [17] = {Cost = 1500}, -- INFLATOR
        [18] = {Cost = 7000}, -- ALIEN
        [19] = {Cost = 500}, -- HAIR_RESTORER
        [20] = {Cost = 1500}, -- SLACK_TONGUE
        [21] = {Cost = 500}, -- FRACTURE
        [22] = {Cost = 1850}, -- TRAINING
        [23] = {Cost = 500}, -- ELECTRO
        [24] = {Cost = 4500}, -- JELLY_VAT
        [25] = {Cost = 1350}, -- STAFF ROOM
        [26] = {Cost = 5}, -- TV ??
        [27] = {Cost = 720}, -- GENERAL_DIAG
        [28] = {Cost = 800}, -- RESEARCH
        [29] = {Cost = 1170}, -- TOILETS
        [30] = {Cost = 5500}, -- DECON_SHOWER
      }
      self.world.map.level_config.rooms = rooms
    end
    for i, room in ipairs(TheApp.rooms) do
      -- Sum up the build cost of the room
      local build_cost = rooms[room.level_config_id].Cost
      for name, no in pairs(room.objects_needed) do
        -- Add cost for this object.
        build_cost = build_cost + config[TheApp.objects[name].thob].StartCost * no
      end
      -- Now define the total build cost for the room.
      room.build_cost = build_cost
    end
  end
  if old < 34 then
    -- New variable
    self.acc_overdraft = 0
  end
  if old < 35 then
    -- Define build costs for rooms once again.
    local config = self.world.map.level_config.objects
    local rooms = self.world.map.level_config.rooms
    for i, room in ipairs(TheApp.rooms) do
      -- Sum up the build cost of the room
      local build_cost = rooms[room.level_config_id].Cost
      for name, no in pairs(room.objects_needed) do
        -- Add cost for this object.
        build_cost = build_cost + config[TheApp.objects[name].thob].StartCost * no
      end
      -- Now define the total build cost for the room.
      self.research.research_progress[room] = {
        build_cost = build_cost,
      }
    end
  end
  if old < 39 then
    self.acc_heating = 0
  end
  if old < 40 then
    self.statistics = {}
    self.money_in = 0
    self.money_out = 0
  end
  if old < 41 then
    self.boiler_can_break = true
  end

  if old < 45 then
    self.num_explosions = 0
    self.num_vips = 0
  end

  if old < 48 then
    self.seating_warning = 0
  end

  if old < 50 then
    self.num_vips_ty = 0
    self.pleased_vips_ty = 0
    self.num_cured_ty = 0
    self.not_cured_ty = 0
    self.num_visitors_ty = 0

    self.reception_desks = {}
    for _, obj_list in pairs(self.world.objects) do
      for _, obj in ipairs(obj_list) do
        if obj.object_type.id == "reception_desk" then
          self.reception_desks[obj] = true
        end
      end
    end
  end

  if old < 52 then
    self:initOwnedPlots()
    self.handymanTasks = {}
  end

  if old < 54 then
    local current = self.research.research_policy.specialisation.current
      if current and not current.dummy and not current.thob and not current.drug then
        for _, disease_entry in pairs(self.disease_casebook) do
        if disease_entry.concentrate_research then
          self.research:concentrateResearch(disease_entry.disease.id)
          self.research:concentrateResearch(disease_entry.disease.id)
        end
      end
    end
  end

  if old < 56 then
    self.research_dep_built = false
  end
  if old < 76 then
    self.msg_counter = 0
  end
  if old < 84 then
    self.vip_declined = 0
  end

  if old < 88 then
    self.future_epidemics_pool = {}
    self.concurrent_epidemic_limit = self.world.map.level_config.gbv.EpidemicConcurrentLimit or 1
  end

end

--! Update the Hospital.patientcount variable.
function Hospital:countPatients()
  -- I have taken the patient count out of town map, from memory it does not work the other way round.
  -- i.e. calling it from town map to use here
  -- so Town map now takes this information from here.  (If I am wrong, put it back)
  self.patientcount = 0
  for _, patient in pairs(self.patients) do
  -- only count patients that are in the hospital
    local tx, ty = patient.tile_x, patient.tile_y
    if tx and ty and self:isInHospital(tx, ty) then
      self.patientcount = self.patientcount + 1
    end
  end
end

--! Count number of sitting and standing patients in the hospital.
--!return (integer, integer) Number of sitting and number of standing patient in the hospital.
function Hospital:countSittingStanding()
  local numberSitting = 0
  local numberStanding = 0
  for _, patient in ipairs(self.patients) do
    if patient.action_queue[1].name == "idle" then
      numberStanding = numberStanding + 1
    elseif patient.action_queue[1].name == "use_object"
    and patient.action_queue[1].object.object_type.id == "bench" then
      numberSitting = numberSitting + 1
    end
  end
  return numberSitting, numberStanding
end


-- A range of checks to help a new player. These are set days apart and will show no more than once a month
function Hospital:checkFacilities()
  if self.hospital and self:isPlayerHospital() then
    -- If there is no staff room, remind player of the need to build one
    if self.world.day == 3 and not self:hasRoomOfType("staff_room") then
      if self.world.month > 4 and not self.staff_room_msg then
        self:noStaffroom_msg()
      elseif self.world.year > 1 then
        self:noStaffroom_msg()
      end
    end
    -- If there is no toilet, remind player of the need to build one
    if self.world.day == 8 and not self:hasRoomOfType("toilets") then
      if self.world.month > 4 and not self.toilet_msg then
        self:noToilet_msg()
      elseif self.world.year > 1 then
        self:noToilet_msg()
      end
    end
    -- How are we for seating, if there are plenty then praise is due, if not the player is warned
    -- We don't want to see praise messages about seating every month, so randomise the chances of it being shown
    -- check the seating : standing ratio of waiting patients
    -- find all the patients who are currently waiting around
    local show_msg = math.random(1, 4)
    local numberSitting, numberStanding = self:countSittingStanding()

    -- If there are patients standing then maybe the seating is in the wrong place!
    -- set to 5% (standing:seated) if there are more than 50 patients or 20% if there are less than 50.
    -- If this happens for 10 days in any month you are warned about seating unless you have already been warned that month
    -- So there are now two checks about having enough seating, if either are called then you won't receive praise. (may need balancing)
    if self.patientcount < 50 then
      if numberStanding > math.min(numberSitting / 5) then
        self.seating_warning = self.seating_warning + 1
      end
    else
      if numberStanding > math.min(numberSitting / 20) then
        self.seating_warning = self.seating_warning + 1
      end
      if self.seating_warning >= 10 and not self.bench_msg then
        self:warningBench()
        self.seating_warning = 0
      end
    end
    if self.world.day == 12 and show_msg  == 4 and not self.bench_msg
    and (self.world.year > 1 or (self.world.year == 1 and self.world.month > 4)) then
      -- If there are less patients standing than sitting (1:20) and there are more benches than patients in the hospital
      -- you have plenty of seating.  If you have not been warned of standing patients in the last month, you could be praised.
      if self.world.object_counts.bench > self.patientcount then
        self:praiseBench()
      -- Are there enough benches for the volume of patients in your hospital?
      elseif self.world.object_counts.bench < self.patientcount then
        self:warningBench()
      end
    end

    -- Make players more aware of the need for radiators and how hot or cold the patients and staff are
    -- If there are no radiators remind the player from May onwards
    if self.world.object_counts.radiator == 0 and self.world.month > 4 and self.world.day == 15 then
      self.world.ui.adviser:say(_A.information.initial_general_advice.place_radiators)
    end
    -- Now to check how warm or cold patients and staff are.  So that we are not bombarded with warmth
    -- messages if we are told about patients then we won't be told about staff as well in the same month
    -- And unlike TH we don't want to be told that anyone is too hot or cold when the boiler is broken do we!
    if not self.heating_broke then
      if not self.warmth_msg and self.world.day == 15 then
        local warmth = self:getAveragePatientAttribute("warmth")
        if (self.world.year > 1 or self.world.month > 4) and warmth < 0.22 then
          self:warningTooCold()
        elseif self.world.month > 4 and warmth >= 0.36 then
          self:warningTooHot()
        end
      end
      -- Are the staff warm enough?
      if not self.warmth_msg and self.world.day == 20 then
        local warmth = 0
        local no = 0
        for _, staff in ipairs(self.staff) do
          warmth = warmth + staff.attributes["warmth"]
          no = no + 1
        end
        if (self.world.year > 1 or self.world.month > 4) and warmth / no < 0.22 then
          self.world.ui.adviser:say(_A.warnings.staff_very_cold)
        elseif self.world.month > 4 and warmth / no >= 0.36 then
          self.world.ui.adviser:say(_A.warnings.staff_too_hot)
        end
      end
    end
    -- Are the patients in need of a drink
    if not self.thirst_msg and self.world.day == 24 then
      local thirst = self:getAveragePatientAttribute("thirst")
      if self.world.year == 1 and self.world.month > 4 then
        if thirst > 0.8 then
          self.world.ui.adviser:say(_A.warnings.patients_very_thirsty)
        elseif thirst > 0.6 then
          self:warningThirst()
        end
      end
      if self.world.year > 1 then
        if thirst > 0.9 then
          self.world.ui.adviser:say(_A.warnings.patients_very_thirsty)
        elseif thirst > 0.6 then
          self:warningThirst()
        end
      end
    end
    -- reset all the messages on 28th of each month
    if self.world.day == 28 then
      self.staff_room_msg = false
      self.toilet_msg = false
      self.bench_msg = false
      self.cash_msg = false
      self.warmth_msg = false
      self.thirst_msg = false
      self.seating_warning = 0
    end
  end
end

--! Called each tick, also called 'hours'. Check hours_per_day in
--! world.lua to see how many times per day this is.
function Hospital:tick()
-- add some random background sounds, ringing phones, coughing, belching etc
  self:countPatients()
  local sounds = {
  "ispot001.wav", "ispot002.wav", "ispot003.wav", "ispot004.wav", "ispot005.wav", "ispot006.wav", "ispot007.wav", "ispot008.wav",
  "ispot009.wav", "ispot010.wav", "ispot011.wav", "ispot012.wav", "ispot013.wav", "ispot014.wav", "ispot015.wav", "ispot016.wav",
  "ispot017.wav", "ispot018.wav", "ispot019.wav", "ispot020.wav", "ispot021.wav", "ispot022.wav", "ispot023.wav", "ispot024.wav",
  "ispot025.wav"
  } -- ispot026 and ispot027 are both toilet related sounds
-- wait until there are some patients in the hospital and a room, otherwise you will wonder who is coughing or who is the
-- receptionist telephoning! opted for gp as you can't run the hospital without one.
  if self:hasRoomOfType("gp") and self.patientcount > 2 then
    if math.random(1, 100) == 3 then
      local sound_to_play = sounds[math.random(1, #sounds)]
      if TheApp.audio:soundExists(sound_to_play) then
        self.world.ui:playSound(sound_to_play)
      end
    end
  end
  self:manageEpidemics()
end

function Hospital:purchasePlot(plot_number)
  local map = self.world.map
  if map.th:isParcelPurchasable(plot_number, self:getPlayerIndex()) and not self.world.ui.transparent_walls then
    local cost = not self.world.free_build_mode and map:getParcelPrice(plot_number) or 0
    if cost <= self.balance then
      self.world:setPlotOwner(plot_number, self:getPlayerIndex())
      table.insert(self.ownedPlots, plot_number)
      -- Also make sure to apply transparency to the new walls, if required.
      self.world.ui:applyTransparency()
      self:spendMoney(cost, _S.transactions.buy_land, cost)
      return true
    else
    -- Give visual warning that player doesn't have enough $ to build
    -- Let the message remain unitl cancelled by the player as it is being displayed behind the town map
      self.world.ui.adviser:say(_A.warnings.cannot_afford_2, true, true)
    end
  end
  return false
end

function Hospital:getPlayerIndex()
  -- TODO: In multiplayer, return 2 or 3 or 4
  return 1
end

--! Returns the heliport x and y coordinates or nil if none exist.
--!return (pair of integers, or nil) The x,y position of the tile with the heliport, if it exists.
function Hospital:getHeliportPosition()
  local x, y = self.world.map.th:getHeliportTile(self:getPlayerIndex())
  -- NB: Level 2 has a heliport tile set, but no heliport, so we ensure that
  -- the specified tile is suitable by checking the adjacent spawn tile for
  -- passability.
  if y > 1 and self.world.map:getCellFlag(x, y - 1, "passable") then
    return x, y
  end
end

--! Returns the tile on which patients should spawn when getting out of the helicopter.
--!return (pair of integers, or nil) The x,y position to use for spawning emergency patients from the heliport, if available.
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
function Hospital:coldWarning()
  local announcements = {
    "sorry002.wav", "sorry004.wav",
  }
  if announcements and self:isPlayerHospital() then
    self.world.ui:playAnnouncement(announcements[math.random(1, #announcements)])
  end
end
function Hospital:hotWarning()
  local announcements = {
    "sorry003.wav", "sorry004.wav",
  }
  if announcements and self:isPlayerHospital() then
    self.world.ui:playAnnouncement(announcements[math.random(1, #announcements)])
  end
end
-- Called when the hospitals's boiler has broken down.
-- It will remain broken for a certain period of time.
function Hospital:boilerBreakdown()
  self.curr_setting = self.radiator_heat
  self.radiator_heat = math.random(0, 1)
  self.boiler_countdown = math.random(7, 25)

  self.heating_broke = true

  -- Only show the message when relevant to the local player's hospital.
  if self:isPlayerHospital() then
    if self.radiator_heat == 0 then
      self.world.ui.adviser:say(_A.boiler_issue.minimum_heat)
      self:coldWarning()
    else
      self.world.ui.adviser:say(_A.boiler_issue.maximum_heat)
      self:hotWarning()
    end
  end
end

-- When the boiler has been repaired this function is called.
function Hospital:boilerFixed()
  self.radiator_heat = self.curr_setting
  self.heating_broke = false
  if self:isPlayerHospital() then
    self.world.ui.adviser:say(_A.boiler_issue.resolved)
  end
end

-- Called at the end of each day.
function Hospital:onEndDay()
  local pay_this = self.loan*self.interest_rate/365 -- No leap years
  self.acc_loan_interest = self.acc_loan_interest + pay_this
  self.research:researchCost()
  if self:hasStaffedDesk() then
    self:checkFacilities()
  end
  self.show_progress_screen_warnings = math.random(1, 3) -- used in progress report to limit warnings
  self.msg_counter = self.msg_counter + 1
  if self.balance < 0 then
    -- TODO: Add the extra interest rate to level configuration.
    local overdraft_interest = self.interest_rate + 0.02
    local overdraft = math.abs(self.balance)
    local overdraft_payment = (overdraft*overdraft_interest)/365
    self.acc_overdraft = self.acc_overdraft + overdraft_payment
  end
  local hosp = self.world.hospitals[1]
  hosp.receptionist_count = 0
  for i, staff in ipairs(self.staff) do
    if staff.humanoid_class == "Receptionist" then
      hosp.receptionist_count = hosp.receptionist_count + 1
    end
  end
  -- if there's currently an earthquake going on, possibly give the machines some damage
  if (self.world.active_earthquake) then
    for _, room in pairs(self.world.rooms) do
      -- Only damage this hospital's objects.
      if room.hospital == self then -- TODO: For multiplayer?
        for object, value in pairs(room.objects) do
          if object.strength then
            -- The or clause is for backwards compatibility. Then the machine takes one damage each day.
            if (object.quake_points and object.quake_points > 0)
            or object.quake_points == nil then
              object:machineUsed(room)
            end
            if object.quake_points then
              object.quake_points = object.quake_points - 1
            end
          end
        end
      end
    end
  end

  -- check if we still have to anounce VIP visit
  if self.announce_vip > 0 then
    -- check if the VIP is in the building yet
    for i, e in ipairs(self.world.entities) do
      if e.humanoid_class == "VIP" and e.announced == false then
        if self:isInHospital(e.tile_x, e.tile_y) and self:isPlayerHospital() then
          -- play VIP arrival sound and show tooltips
          e:announce()
          e.announced = true
          self.announce_vip = self.announce_vip - 1
        end
      end
    end
  end

  -- Countdown for boiler breakdowns
  if self.heating_broke then
    self.boiler_countdown = self.boiler_countdown - 1
    if self.boiler_countdown == 0 then
      self:boilerFixed()
    end
  end

  -- Is the boiler working today?
  local breakdown = math.random(1, 240)
  if breakdown == 1 and not self.heating_broke and self.boiler_can_break
  and self.world.object_counts.radiator > 0 then
    if tonumber(self.world.map.level_number) then
      if self.world.map.level_number == 1 and (self.world.month > 5 or self.world.year > 1) then
        self:boilerBreakdown()
      elseif self.world.map.level_number > 1 then
        self:boilerBreakdown()
      end
    else
      self:boilerBreakdown()
    end
  end

  -- Calculate heating cost daily.  Divide the monthly cost by the number of days in that month
  local month_length = {
    31, -- Jan
    28, -- Feb
    31, -- Mar
    30, -- Apr
    31, -- May
    30, -- Jun
    31, -- Jul
    31, -- Aug
    30, -- Sep
    31, -- Oct
    30, -- Nov
    31, -- Dec
  }
  local radiators = self.world.object_counts.radiator
  local heating_costs = (((self.radiator_heat * 10) * radiators) * 7.50) / month_length[self.world.month]
  self.acc_heating = self.acc_heating + heating_costs
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
  -- Pay heating costs
  if math.round(self.acc_heating) > 0 then
    self:spendMoney(math.round(self.acc_heating), _S.transactions.heating)
    self.acc_heating = 0
  end
  -- how is the bank balance
  if self:isPlayerHospital() then
    if self.balance < 1000 and not self.cash_msg then
      self:cashLow()
    elseif self.balance > 6000
    and self.loan > 0 and not self.cash_ms then
      self.world.ui.adviser:say(_A.warnings.pay_back_loan)
    end
    self.cash_msg = true
  end
  -- Pay interest on loans
  if math.round(self.acc_loan_interest) > 0 then
    self:spendMoney(math.round(self.acc_loan_interest), _S.transactions.loan_interest)
    self.acc_loan_interest = 0
  end
  -- Pay overdraft charges
  if math.round(self.acc_overdraft) > 0 then
    self:spendMoney(math.round(self.acc_overdraft), _S.transactions.overdraft)
    self.acc_overdraft = 0
  end
  -- Pay research costs
  if math.round(self.acc_research_cost) > 0 then
    self:spendMoney(math.round(self.acc_research_cost), _S.transactions.research)
    self.acc_research_cost = 0
  end
  -- add to score each month
  -- rate varies on some performance factors i.e. reputation above 500 increases the score
  -- and the number of deaths will reduce the score.
  local sal_inc = self.salary_incr / 10
  local sal_mult = (self.reputation - 500) / (self.num_deaths + 1) -- added 1 so that you don't divide by 0
  local month_incr = sal_inc + sal_mult
  -- To ensure that you can't receive less than 50 or
  -- more than 300 per month
  if month_incr < self.sal_min then
    month_incr = self.sal_min
  elseif month_incr > self.salary_incr then
    month_incr = self.salary_incr
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

  -- Check for equipment getting available
  self.research:checkAutomaticDiscovery(self.world.month + 12 * (self.world.year - 1))

  -- Add some interesting statistics.
  self.statistics[self.world.month + 1 + 12 * (self.world.year - 1)] = {
    money_in = self.money_in,
    money_out = self.money_out,
    wages = wages,
    balance = self.balance,
    visitors = self.num_visitors,
    cures = self.num_cured,
    deaths = self.num_deaths,
    reputation = self.reputation,
  }
  self.money_in = 0
  self.money_out = 0

  -- make players aware of the need for a receptionist and desk.
  if (self:isPlayerHospital() and not self:hasStaffedDesk()) and self.world.year == 1 then
    if self.receptionist_count ~= 0 and self.world.month > 2 and not self.receptionist_msg then
      self.world.ui.adviser:say(_A.warnings.no_desk_6)
      self.receptionist_msg = true
    elseif self.receptionist_count == 0 and self.world.month > 2 and self.world.object_counts["reception_desk"] ~= 0  then
      self.world.ui.adviser:say(_A.warnings.no_desk_7)
    --  self.receptionist_msg = true
    elseif self.world.month == 3 then
      self.world.ui.adviser:say(_A.warnings.no_desk, true)
    elseif self.world.month == 8 then
      self.world.ui.adviser:say(_A.warnings.no_desk_1, true)
    elseif self.world.month == 11 then
      if self.visitors == 0 then
        self.world.ui.adviser:say(_A.warnings.no_desk_2, true)
      else
        self.world.ui.adviser:say(_A.warnings.no_desk_3, true)
      end
    end
  end
end

--! Returns whether this hospital is controlled by a real person or not.
function Hospital:isPlayerHospital()
  return self == self.world:getLocalPlayerHospital()
end

function Hospital:hasStaffedDesk()
  return (self.world.object_counts["reception_desk"] ~= 0 and self:hasStaffOfCategory("Receptionist"))
end

--! Called at the end of each year
function Hospital:onEndYear()
  self.sodas_sold = 0
  self.num_vips_ty  = 0
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
function Hospital:createEmergency(emergency)
  local created_one = false
  local random_disease = self.world.available_diseases[math.random(1, #self.world.available_diseases)]
  local disease = TheApp.diseases[random_disease.id]
  local number = math.random(2, disease.emergency_number)
  if self:getHeliportSpawnPosition() and self:hasStaffedDesk() then
    if not emergency then
      -- Create a random emergency if parameters are not specified already.
      emergency = {
        disease = disease,
        victims = number,
        bonus = 1000,
        percentage = 0.75,
        killed_emergency_patients = 0,
        cured_emergency_patients = 0,
      }
    end

    self.emergency = emergency
    -- The last room in the list of treatment rooms is considered when checking for availability.
    -- It works for all original diseases, but if we introduce new multiple room diseases it might break.
    -- TODO: Make it work for all kinds of lists of treatment rooms.
    -- TODO: Change to make use of Hospital:checkDiseaseRequirements
    local no_rooms = #emergency.disease.treatment_rooms
    local room_name, required_staff, staff_name =
      self.world:getRoomNameAndRequiredStaffName(emergency.disease.treatment_rooms[no_rooms])

    local staff_available = self:hasStaffOfCategory(required_staff)
    -- Check so that all rooms in the list are available
    if self:hasRoomOfType(emergency.disease.treatment_rooms[no_rooms]) then
      room_name = nil
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

    local one_or_many_victims_msg
    if emergency.victims == 1 then
      one_or_many_victims_msg = _S.fax.emergency.num_disease_singular:format(emergency.disease.name)
    else
      one_or_many_victims_msg = _S.fax.emergency.num_disease:format(emergency.victims, emergency.disease.name)
    end
    local message = {
      {text = _S.fax.emergency.location:format(_S.fax.emergency.locations[math.random(1,9)])},
      {text = one_or_many_victims_msg },
      {text = added_info},
      {text = self.world.free_build_mode and _S.fax.emergency.free_build or _S.fax.emergency.bonus:format(emergency.bonus*emergency.victims)},
      choices = {
        {text = _S.fax.emergency.choices.accept, choice = "accept_emergency"},
        {text = _S.fax.emergency.choices.refuse, choice = "refuse_emergency"},
      },
    }
    self.world.ui.bottom_panel:queueMessage("emergency", message, nil, 24*20, 2) -- automatically refuse after 20 days
    created_one = true
  end
  return created_one
end

-- Called when the timer runs out during an emergency or when all emergency patients are cured or dead.
function Hospital:resolveEmergency()
  local emer = self.emergency
  local rescued_patients = emer.cured_emergency_patients
  for i, patient in ipairs(self.emergency_patients) do
    if patient and patient.hospital and not patient:getRoom() then
      patient:die()
    end
  end
  local total = emer.victims
  local max_bonus = emer.bonus * total
  local emergency_success = rescued_patients/total >= emer.percentage
  local earned = 0
  if emergency_success then
    earned = emer.bonus * rescued_patients
  end
  local message = {
    {text = _S.fax.emergency_result.saved_people
      :format(rescued_patients, total)},
    {text = self.world.free_build_mode and "" or _S.fax.emergency_result.earned_money:format(max_bonus, earned)},
    choices = {
      {text = _S.fax.emergency_result.close_text, choice = "close"},
    },
  }
  self.world.ui.bottom_panel:queueMessage("report", message, nil, 24*25, 1)
  if emergency_success then -- Reputation increased
    self:changeReputation("emergency_success", emer.disease)
    self:receiveMoney(earned, _S.transactions.emergency_bonus)
  else -- Too few rescued, reputation hit
    self:changeReputation("emergency_failed", emer.disease)
  end

  --check if there's a VIP in the building, and if there is then let him know the outcome
  for i, e in ipairs(self.world.entities) do
    if class.is(e, Vip) then
      e:evaluateEmergency(emergency_success)
    end
  end

  self.world:nextEmergency()
end

-- Creates VIP and sends a FAX to query the user.
function Hospital:createVip()
  local vipName =  _S.vip_names[math.random(1,10)]
  local message = {
    {text = _S.fax.vip_visit_query.vip_name:format(vipName)},
    choices = {{text = _S.fax.vip_visit_query.choices.invite, choice = "accept_vip", additionalInfo = {name=vipName}},
               {text = _S.fax.vip_visit_query.choices.refuse, choice = "refuse_vip", additionalInfo = {name=vipName}}}
  }
  -- auto-refuse after 20 days
  self.world.ui.bottom_panel:queueMessage("personality", message, nil, 24*20, 2)
end

--[[ Creates a new epidemic by creating a new contagious patient with
 a random disease - this is NOT typically how epidemics are started (mainly for cheat use)
 see @Hospital:determineIfContagious() to see how epidemics are typically started]]
function Hospital:spawnContagiousPatient()
  --[[ Gets the available non-visual disease in the current world
    @return non_visuals (table) table of available non-visual diseases]]
  local function get_avaliable_contagious_diseases()
    local contagious = {}
    for _, disease in ipairs(self.world.available_diseases) do
      if disease.contagious then
          contagious[#contagious + 1] = disease
      end
    end
    return contagious
  end

  if self:hasStaffedDesk() then
    local patient = self.world:newEntity("Patient", 2)
    local contagious_diseases = get_avaliable_contagious_diseases()
    if #contagious_diseases > 0 then
      local disease = contagious_diseases[math.random(1,#contagious_diseases)]
      patient:setDisease(disease)
      --Move the first patient closer (FOR TESTING ONLY)
      local x,y = self:getHeliportSpawnPosition()
      patient:setTile(x,y)
      patient:setHospital(self)
      self:addToEpidemic(patient)
    else
      print("Cannot create epidemic - no contagious diseases available")
    end
  else
    print("Cannot create epidemic - no staffed reception desk")
  end
end

function Hospital:countEpidemics()
  -- Count the current epidemic if it exists
  local epidemic_count = self.epidemic and 1 or 0
  epidemic_count = epidemic_count + #self.future_epidemics_pool
  return epidemic_count
end

--[[ Make the active epidemic (if exists) and any future epidemics tick. If there
is no current epidemic determines if any epidemic in the pool of future
epidemics can become the active one. Also removes any epidemics from the
future pool which have no infected patients and thus, will have no effect on
the hospital. ]]
function Hospital:manageEpidemics()
  --[[ Can the future epidemic be revealed to the player
  @param future_epidemic (Epidemic) the epidemic to attempt to reveal
  @return true if can be revealed false otherwise (boolean) ]]
  local function can_be_revealed(epidemic)
    return not self.world.ui:getWindow(UIWatch) and
    not self.epidemic and epidemic.ready_to_reveal
  end

  local current_epidemic = self.epidemic
  if(current_epidemic) then
    current_epidemic:tick()
  end

  if self.future_epidemics_pool then
    for i, future_epidemic in ipairs(self.future_epidemics_pool) do
      if future_epidemic:hasNoInfectedPatients() then
        table.remove(self.future_epidemics_pool,i)
      elseif can_be_revealed(future_epidemic) then
        self.epidemic = future_epidemic
        self.epidemic:revealEpidemic()
        table.remove(self.future_epidemics_pool,i)
      else
        future_epidemic:tick()
      end
    end
  end
end

--[[ Determines if a patient is contagious and then attempts to add them the
 appropriate epidemic if so.
 @param patient (Patient) patient to determine if contagious]]
function Hospital:determineIfContagious(patient)
  if patient.is_emergency or not patient.disease.contagious then
    return false
  end
  -- ContRate treated like a percentage with ContRate% of patients with
  -- a disease having the contagious strain
  local config = self.world.map.level_config
  local expertise = config.expertise
  local disease = patient.disease
  local contRate = expertise[disease.expertise_id].ContRate or 0

  -- The patient is potentially contagious as we do not yet know if there
  -- is a suitable epidemic which they can belong to
  local potentially_contagious = contRate > 0 and (math.random(1,contRate) == contRate)
  -- The patient isn't contagious if these conditions aren't passed
  local reduce_months = config.ReduceContMonths or 14
  local reduce_people = config.ReduceContPeepCount or 20
  local date_in_months = self.world.month + (self.world.year - 1)*12

  if potentially_contagious and date_in_months > reduce_months and
      self.num_visitors > reduce_people then
    self:addToEpidemic(patient)
  end
end

--[[ Determines if there is a suitable epidemic the contagious patient can
 belong to and adds them to it if possible. N.B. a patient isn't actually
 contagious until they belong to an epidemic. So if it isn't possible to add a
 patient to an epidemic they are just treated as a normal patient.
 @param patient (Patient) patient to attempt to add to an epidemic  ]]
function Hospital:addToEpidemic(patient)
  --[[ See if there exists a future epidemic with the same
  disease as the contagious patient - if so add them to it
  @param patient (Patient) the patient to add to the epidemic
  @return true if patient was successfully added to a future epidemic
  false otherwise (boolean) ]]
  local function add_to_existing_future_epidemic(patient)
    for _, future_epidemic in ipairs(self.future_epidemics_pool) do
      if future_epidemic.disease == patient.disease then
        future_epidemic:addContagiousPatient(patient)
        return true
      end
    end
    return false
  end

  --[[ Create a new epidemic and add it to the pool of future epidemics
  @param patient (Patient) the patient who will be the first
  contagious patient of the new epidemic]]
  local function add_new_epidemic_to_pool(patient)
    local new_epidemic = Epidemic(self,patient)
    self.future_epidemics_pool[#self.future_epidemics_pool + 1] = new_epidemic
  end

  local epidemic = self.epidemic
  -- Don't add a new contagious patient if the player is trying to cover up
  -- an existing epidemic - not really fair
  if epidemic and not epidemic.coverup_in_progress and
      (patient.disease == epidemic.disease) then
    epidemic:addContagiousPatient(patient)
  elseif self.future_epidemics_pool and
      not (epidemic and epidemic.coverup_in_progress) then
    local added_to_future_epidemic = add_to_existing_future_epidemic(patient)
    if not added_to_future_epidemic then
      -- Make a new epidemic as one doesn't exist with this disease only if
      -- we haven't reach the concurrent epidemic limit
      if self:countEpidemics() < self.concurrent_epidemic_limit then
        add_new_epidemic_to_pool(patient)
      end
    end
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

--[[ Returns how much a given object currently costs to purchase. The cost
may be affected by research progress.

!param name (string) The name (id) of the object to investigate.
]]
function Hospital:getObjectBuildCost(name)
  -- Some helpers
  local progress = self.research.research_progress
  local config = self.world.map.level_config.objects
  local obj_def = TheApp.objects[name]
  -- Get how much this item costs at the start of the level.
  local obj_cost = config[obj_def.thob].StartCost
  -- Some objects might have got their cost reduced by research.
  if progress[obj_def] then
    obj_cost = progress[obj_def].cost
  end
  -- Everything is free in free build mode.
  return not self.world.free_build_mode and obj_cost or 0
end

--[[ Lowers the player's money by the given amount and logs the transaction.

!param amount (integer) The (positive) amount to spend.
!param reason (string) A string that shows what happened. Should be one of the strings
in _S.transactions.
!param changeValue (integer) The (positive) amount the hospital value should be increased
]]
function Hospital:spendMoney(amount, reason, changeValue)
  if not self.world.free_build_mode then
    self.balance = self.balance - amount
    self:logTransaction{spend = amount, desc = reason}
    self.money_out = self.money_out + amount
    if changeValue then
      self.value = self.value + changeValue
    end
  end
end

--[[ Increases the player's money by the given amount and logs the transaction.

!param amount (integer) The (positive) amount to receive.
!param reason (string) A string that tells what happened. Should be one of the strings
in _S.transactions.
!param changeValue (integer) The (positive) amount the hospital value should be decreased
]]
function Hospital:receiveMoney(amount, reason, changeValue)
  if not self.world.free_build_mode then
    self.balance = self.balance + amount
    self:logTransaction{receive = amount, desc = reason}
    self.money_in = self.money_in + amount
    if changeValue then
      self.value = self.value - changeValue
    end
  end
end

--[[ Determines how much the player should receive after a patient is treated in a room.

!param patient (Patient) The patient that just got treated.
]]
function Hospital:receiveMoneyForTreatment(patient)
  if not self.world.free_build_mode then
    local disease_id
    local reason
    if not self.world.free_build_mode then
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
     local amount = self:getTreatmentPrice(disease_id)
      casebook.money_earned = casebook.money_earned + amount
      patient.world:newFloatingDollarSign(patient, amount)
      -- 25% of the payments now go through insurance
      if patient.insurance_company then
        self:addInsuranceMoney(patient.insurance_company, amount)
      else
        self:receiveMoney(amount, reason)
      end
    end
  end
end

--! Function to determine the price for a treatment, modified by reputation and percentage
-- Treatment charge should never be less than the starting price if reputation falls below 500
function Hospital:getTreatmentPrice(disease)
  local reputation = self.disease_casebook[disease].reputation or self.reputation
  local percentage = self.disease_casebook[disease].price
  local raw_price  = self.disease_casebook[disease].disease.cure_price
  if reputation >= 500 then
    return math.ceil(raw_price * (reputation / 500) * percentage)
  else
    return math.ceil(raw_price * percentage)
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
  self.num_visitors_ty = self.num_visitors_ty + 1

  -- Decide if the patient belongs in an epidemic
  self:determineIfContagious(patient)
end

function Hospital:humanoidDeath(humanoid)
  self.num_deaths = self.num_deaths + 1
  self.num_deaths_this_year = self.num_deaths_this_year + 1

  self:changeReputation("death", humanoid.disease)
  self:updatePercentages()
end

--! Checks if the hospital employs staff of a given category.
--!param category (string) A humanoid_class or one of the specialists, i.e.
--! "Doctor", "Nurse", "Handyman", "Receptionist", "Psychiatrist",
--! "Surgeon", "Researcher" or "Consultant"
--! returns false if none, else number of that type employed
function Hospital:hasStaffOfCategory(category)
  local result = false
  for i, staff in ipairs(self.staff) do
    if staff.humanoid_class == category then
      result = (result or 0) + 1
    elseif staff.humanoid_class == "Doctor" then
      if (category == "Psychiatrist" and staff.profile.is_psychiatrist >= 1.0) or
          (category == "Surgeon" and staff.profile.is_surgeon >= 1.0) or
          (category == "Researcher" and staff.profile.is_researcher >= 1.0) or
          (category == "Consultant" and staff.profile.is_consultant) then
        result = (result or 0) + 1
      end
    end
  end
  return result
end

--! Checks if the hospital has a room of a given type.
--!param type (string) A room_info.id, e.g. "ward".
--! Returns false if none, else number of that type found
function Hospital:hasRoomOfType(type)
  -- Check how many rooms there are.
  local result = false
  for _, room in pairs(self.world.rooms) do
    if room.hospital == self and room.room_info.id == type and room.is_active then
      result = (result or 0) + 1
    end
  end
  return result
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

--! Normally reputation is changed based on a reason, and the affected
--! disease also has its own reputation meter.
--!param reason (string) The reason for changing reputation, for example "cured" or "death".
--!param disease The disease, if any, that should be affected.
--!param valueChange (integer) In some cases, for example at year end, the amount varies a lot.
-- Then it is specified here.
function Hospital:changeReputation(reason, disease, valueChange)
  local amount
  if reason == "autopsy_discovered" then
    local config = self.world.map.level_config.gbv.AutopsyRepHitPercent
    amount = config and math.floor(-self.reputation*config/100) or -70
  elseif valueChange then
    amount = valueChange
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

function Hospital:updatePercentages()
  local killed = self.num_deaths / (self.num_cured + self.num_deaths) * 100
  self.percentage_killed = math.round(killed)
  local cured = self.num_cured / (self.num_cured + self.not_cured + self.num_deaths) * 100
  self.percentage_cured = math.round(cured)
end

function Hospital:getAveragePatientAttribute(attribute)
  -- Some patients (i.e. Alien) may not have the attribute in question, so check for that
  local sum = 0
  local count = 0
  for _, patient in ipairs(self.patients) do
    sum = sum + (patient.attributes[attribute] or 0)
    if patient.attributes[attribute] then
      count = count + 1
    end
  end
  return sum / count
end

--! Checks if the requirements for the given disease are met in the hospital and returns the ones missing.
--!param disease (String) The disease to check the requirements for
--! returns false if all requirements are met, else a table in the form
--! { rooms = {[room1], [room2], ...}, staff = {[humanoid_class] = [amount_needed] or nil} }
--! i.e. a list of rooms (ordered the same as disease.treatment_rooms), and a set of humanoid_classes with
--! the needed amount of that class as the value
function Hospital:checkDiseaseRequirements(disease)
  -- Copy rooms list from disease but leave out the ones that are present in the hospital
  -- Get required staff from all rooms required by the disease, if not already present in hospital
  local rooms = {}
  local staff = {}
  local any = false
  for i, room_id in ipairs(self.world.available_diseases[disease].treatment_rooms) do
    local found = self:hasRoomOfType(room_id)
    if not found then
      rooms[#rooms + 1] = room_id
      any = true
    end

    -- Get staff for room
    for staff_class, amount in pairs(TheApp.rooms[room_id].required_staff) do
      local available = self:hasStaffOfCategory(staff_class) or 0
      if available < amount then
        -- Don't add up the staff requirements of different rooms, but take the maximum
        staff[staff_class] = math.max(staff[staff_class] or 0, amount - available)
        any = true
      end
    end
  end
  -- False if no rooms and no staff were added
  return any and {rooms = rooms, staff = staff}
end

class "AIHospital" (Hospital)

---@type AIHospital
local AIHospital = _G["AIHospital"]

function AIHospital:AIHospital(competitor, ...)
  self:Hospital(...)
  if _S.competitor_names[competitor] then
    self.name = _S.competitor_names[competitor]
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

function Hospital:addHandymanTask(object, taskType, priority, x, y, call)
  local parcelId = self.world.map.th:getCellFlags(x, y).parcelId
  local subTable = self:findHandymanTaskSubtable(taskType)
  table.insert(subTable, {["object"] = object, ["priority"] = priority, ["tile_x"] = x, ["tile_y"] = y, ["parcelId"] = parcelId, ["call"] = call});
end

function Hospital:modifyHandymanTaskPriority(taskIndex, newPriority, taskType)
  if taskIndex ~= -1 then
    local subTable = self:findHandymanTaskSubtable(taskType)
    subTable[taskIndex].priority = newPriority;
  end
end

function Hospital:removeHandymanTask(taskIndex, taskType)
  if taskIndex ~= -1 then
    local subTable = self:findHandymanTaskSubtable(taskType)
    local task = subTable[taskIndex]
    table.remove(subTable, taskIndex)
    if task.assignedHandyman then
      if task.object.ticks ~= true then
        task.assignedHandyman:interruptHandymanTask()
      end
    end
  end
end

function Hospital:findHandymanTaskSubtable(taskType)
  for i,v in ipairs(self.handymanTasks) do
    if self.handymanTasks[i].taskType == taskType then
      return self.handymanTasks[i].subTable
    end
  end
  table.insert(self.handymanTasks, {["taskType"] = taskType, ["subTable"] = {}})
  return self:findHandymanTaskSubtable(taskType)
end

function Hospital:getTaskObject(taskIndex, taskType)
  return self:findHandymanTaskSubtable(taskType)[taskIndex]
end

function Hospital:assignHandymanToTask(handyman, taskIndex, taskType)
  if taskIndex ~= -1 then
    local subTable = self:findHandymanTaskSubtable(taskType)
    if not subTable[taskIndex].assignedHandyman then
      subTable[taskIndex].assignedHandyman = handyman
    else
      local formerHandyman = subTable[taskIndex].assignedHandyman
      subTable[taskIndex].assignedHandyman = handyman
      formerHandyman:interruptHandymanTask()
    end
  end
end

function Hospital:searchForHandymanTask(handyman, taskType)
  local subTable = self:findHandymanTaskSubtable(taskType)
  --if a distance is smaller than this value stop the search to
  --save performance
  local thresholdForStopping = 3
  local first, dist, index, priority, multiplier = true, 0, -1, 0, 1
  if handyman.profile.is_consultant then
    multiplier = 0.5
  elseif handyman.profile.is_junior then
    multiplier = 2
  end
  if not handyman.parcelNr then
    handyman.parcelNr = 0
  end
  for i, v in ipairs(subTable) do
    local distance = self.world:getPathDistance(v.tile_x, v.tile_y, handyman.tile_x, handyman.tile_y)
    local canContinue = true
    if not first and v.priority < priority then
      canContinue = false
    end
    if not v.parcelId then
       v.parcelId = self.world.map.th:getCellFlags(v.tile_x, v.tile_y).parcelId
    end
    if handyman.parcelNr ~= 0 and handyman.parcelNr ~= v.parcelId then
      canContinue = false
    end
    if distance == false then
      canContinue = false
    end
    if canContinue then
      if v.assignedHandyman then
        if v.assignedHandyman.fired then
          v.assignedHandyman = nil
        elseif not v.assignedHandyman.hospital then
          -- This should normally never be the case. If the handyman doesn't belong to a hsopital
          -- then they should not have any tasks assigned to them however it was previously possible
          -- We need to tidy up to make sure the task can be reassigned.
          print("Warning: Orphaned handyman is still assigned a task. Removing.");
          v.assignedHandyman = nil
        else
          local assignedDistance = self.world:getPathDistance(v.tile_x, v.tile_y, v.assignedHandyman.tile_x, v.assignedHandyman.tile_y)
          if assignedDistance ~= false then
            if v.assignedHandyman.profile.is_consultant then
              assignedDistance = assignedDistance / 2
            elseif v.assignedHandyman.profile.is_junior then
              assignedDistance = assignedDistance * 2
            end
            distance = distance * multiplier
            if distance + 5 > assignedDistance then
              canContinue = false
            else
              distance = distance / multiplier
            end
          end
        end
      end
      if canContinue then
        if first then
          if distance <= thresholdForStopping then
            return i
          end
          first, dist, index, priority = false, distance, i, v.priority
        elseif  priority < v.priority or distance < dist then
          if distance < thresholdForStopping then
            return i
          end
          dist, index, priority = distance, i, v.priority
        end
      end
    end
  end
  return index
end


function Hospital:getIndexOfTask(x, y, taskType)
  local subTable = self:findHandymanTaskSubtable(taskType)
  for i, v in ipairs(subTable) do
    if v.tile_x == x and v.tile_y == y then
      return i
    end
  end
  return -1
end

function Hospital:initOwnedPlots()
  self.ownedPlots = {}
  for i, v in ipairs(self.world.entities) do
    if v.tile_x and v.tile_y then
      local parcel = self.world.map.th:getCellFlags(v.tile_x, v.tile_y).parcelId;
      local isAlreadyContained = false
      for i2, v2 in ipairs(self.ownedPlots) do
        if parcel == v2 then
          isAlreadyContained = true
          break
        end
      end
      if isAlreadyContained == false and parcel ~= 0 and self.world.map.th:getPlotOwner(parcel) ~= 0  then
        table.insert(self.ownedPlots, parcel)
      end
    end
  end
end

--! Function that returns true if the room for the given disease
--! has not been researched yet.
--! param disease (string): the disease to be checked.
function Hospital:roomNotYetResearched(disease)
  local req = self:checkDiseaseRequirements(disease)
  if type(req) == "table" and #req.rooms > 0 then
    for i, room_id in ipairs(req.rooms) do
      if not self.discovered_rooms[self.world.available_rooms[room_id]] then
        return true
      end
    end
  end
  return false
end

--! Function that returns true if concentrating research on the disease is possible.
--! @param disease (string): the disease to be checked.
function Hospital:canConcentrateResearch(disease)
  local book = self.disease_casebook
  if not book[disease].pseudo and self:roomNotYetResearched(disease) then
    return true
  end
  if book[disease].drug then
    return book[disease].cure_effectiveness < 100
  end
  local room
  if book[disease].pseudo then
    room = book[disease].disease.id:sub(6)
  else
    room = book[disease].disease.treatment_rooms[#book[disease].disease.treatment_rooms]
  end
  local research_progress = self.research.research_progress
  local object_type
  for obj, _ in pairs(self.world.available_rooms[room].objects_needed) do
    if self.world.object_types[obj].default_strength then
      object_type = obj
      break
    end
  end

  if object_type then
    local progress = research_progress[self.world.object_types[object_type]]
    return progress.start_strength < self.world.map.level_config.gbv.MaxObjectStrength
  end
  return false
end
