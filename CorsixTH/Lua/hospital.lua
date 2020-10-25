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

class "Hospital"

---@type Hospital
local Hospital = _G["Hospital"]

function Hospital:Hospital(world, avail_rooms, name)
  self.world = world
  local level_config = world.map.level_config
  local level = world.map.level_number
  local balance, interest_rate_numerator, reputation, overdraft_differential_numerator

  if level_config.towns and level_config.towns[level] then
    balance = level_config.towns[level].StartCash
    interest_rate_numerator = level_config.towns[level].InterestRate
    reputation = level_config.towns[level].StartRep
    overdraft_differential_numerator = level_config.towns[level].OverdraftDiff
  elseif level_config.town then
    balance = level_config.town.StartCash
    interest_rate_numerator = level_config.town.InterestRate
    reputation = level_config.town.StartRep
    overdraft_differential_numerator = level_config.town.OverdraftDiff
  end

  self.name = name or "PLAYER"
  -- When playing in free build mode you don't care about money.
  self.balance = not world.free_build_mode and balance or 0
  self.loan = 0
  self.acc_loan_interest = 0
  self.acc_research_cost = 0
  self.acc_overdraft = 0
  self.acc_heating = 0

  -- The sum of all material values (tiles, rooms, objects).
  -- Initial value: hospital tile count * tile value + 20000
  self.value = world.map:getParcelPrice(self:getPlayerIndex()) + 20000

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
  self.concurrent_epidemic_limit = level_config.gbv.EpidemicConcurrentLimit or 1

  -- Initial values
  self.interest_rate = interest_rate_numerator / 10000
  self.inflation_rate = 0.045
  self.overdraft_interest_rate = self.interest_rate + overdraft_differential_numerator / 10000
  self.salary_incr = level_config.gbv.ScoreMaxInc or 300
  self.sal_min = level_config.gbv.ScoreMaxInc / 6 or 50
  self.reputation_min = 0
  self.reputation_max = 1000
  self.reputation = math.min(math.max(reputation, self.reputation_min), self.reputation_max)

  local difficulty = self.world.map:getDifficulty()
  -- Price distortion level under which the patients might consider the
  -- treatment to be under-priced.
  local under_priced_thresholds = {-0.3, -0.4, -0.5}
  self.under_priced_threshold = under_priced_thresholds[difficulty]

  -- Price distortion level over which the patients might consider the
  -- treatment to be over-priced.
  local over_priced_thresholds = {0.4, 0.3, 0.2}
  self.over_priced_threshold = over_priced_thresholds[difficulty]

  -- (int) Number of days until the next heating or vomit wave disaster.
  -- TODO: Implement the vomit wave.
  self.disasterless_days = self:daysUntilNextDisaster()

  -- Heating system variables.
  self.heating = {
    radiator_heat = 0.5, -- (float) [0..1] fraction of heating by a radiator.
    saved_radiator_heat = nil, -- (float) Saved radiator heat when boiler has broken down.
    boiler_repair_count = nil, -- (int) Number of items to repair.
    heating_broke = false -- (bool) Whether the heating system is broken down currently.
  }

  self.num_visitors = 0
  self.num_deaths = 0
  self.num_deaths_this_year = 0
  self.num_cured = 0
  self.not_cured = 0
  self.num_explosions = 0
  self.announce_vip = 0
  self.vip_declined = 0
  self.num_vips = 0 -- used to check if it's the user's first vip
  self.percentage_cured = 0
  self.percentage_killed = 0
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
      reputation = self.reputation
    }
  }
  self.money_in = 0
  self.money_out = 0

  -- Other statistics, back to zero each year
  self.has_impressive_reputation = true
  self:unconditionalChangeReputation(0) -- Reset self.has_impressive_reputation

  self.sodas_sold = 0
  self.num_vips_ty  = 0 -- used to count how many VIP visits in the year for an award
  self.pleased_vips_ty  = 0
  self.num_cured_ty = 0
  self.not_cured_ty = 0
  self.num_visitors_ty = 0

  self.ownedPlots = {1} -- Plots owned by the hospital
  self.ratholes = {} -- List of table {x, y, wall, parcel, optional object} for ratholes in the hospital corridors.
  self.is_in_world = true -- Whether the hospital is in this world (AI hospitals are not)
  self.opened = false -- Whether the hospital is opened (timer was cleared or ended).
  self.transactions = {}
  self.staff = {}
  self.patients = {}
  self.debug_patients = {} -- right-click-commandable patients for testing
  self.disease_casebook = {}
  self.policies = {}
  self.discovered_diseases = {} -- a list

  -- Make a table containing available rooms for the level, and its discovery status (room, discovery_status)
  -- Index is the room's id e.g. gp
  self.room_discoveries = {}
  for _, avail_room in ipairs(avail_rooms) do
    self.room_discoveries[avail_room.room.id] = {
      room = avail_room.room,
      is_discovered = avail_room.is_discovered or false
    }
  end

  self.policies["staff_allowed_to_move"] = true
  self.policies["send_home"] = 0.1
  self.policies["guess_cure"] = 0.9
  self.policies["stop_procedure"] = 1 -- Note that this is between 1 and 2 ( = 100% - 200%)
  self.policies["goto_staffroom"] = 0.6
  self.policies["grant_wage_increase"] = TheApp.config.grant_wage_increase

  -- Semi-randomly select three insurance companies to use, only different by name right now.
  -- The companies in the first quarter of the list are more likely to be selected
  self.insurance = {}
  -- Make a local writeable copy table of the translated company names.
  local companies = {}
  for no, local_name in ipairs(_S.insurance_companies) do
    companies[no] = local_name
  end
  while #self.insurance < 3 and #companies > 0 do
    local num = math.random(1, 2) == 1 and math.random(1, math.ceil(#companies / 4)) or
        math.random(1, #companies)
    self.insurance[#self.insurance + 1] = companies[num]
    table.remove(companies, num)
  end

  -- A list of how much each insurance company owes you. The first entry for
  -- each company is the current month's dept, the second the previous
  -- month and the third the month before that.
  -- All payment that goes through an insurance company a given month is paid two
  -- months later. For example diagnoses in April are paid the 1st of July
  self.insurance_balance = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}

  -- Initialize diseases
  local diseases = TheApp.diseases
  local expertise = level_config.expertise
  local gbv = level_config.gbv
  for _, disease in ipairs(diseases) do
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

--! Checks if a room has been discovered
--!param room_id (string) The name of the room
--!return (boolean) true if discovered, otherwise false
function Hospital:isRoomDiscovered(room_id)
  return self.room_discoveries[room_id].is_discovered
end

--! Give the user possibly a message about a cured patient.
function Hospital:msgCured()
  -- Nothing to do, override in a derived class.
end

--! Give the user possibly a message about a dead patient.
function Hospital:msgKilled()
  -- Nothing to do, override in a derived class.
end

--! Update the loaded game with version 'old' to the version 'new'.
--!param old Version of the loaded game.
--!param new Version of the code being executed.
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
    local cfg_objects = self.world.map.level_config.objects
    for _, room in ipairs(self.world.available_rooms) do
      -- If a room is discovered, make sure its objects are also
      -- discovered, otherwise add it to the undiscovered list.
      if self.discovered_rooms[room] then
        for name, _ in pairs(room.objects_needed) do
          local object = TheApp.objects[name]
          if cfg_objects[object.thob] and cfg_objects[object.thob].AvailableForLevel == 1 and
              object.research_category and not research.research_progress[object].discovered then
            local progress = self.research_rooms[room]
            if self.research.cure.current == room or self.research.diagnosis.current == room then
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
            if cfg_objects[object.thob] and cfg_objects[object.thob].AvailableForLevel == 1 and
                object.research_category and not research.research_progress[object].discovered then
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
    for _, room in ipairs(TheApp.rooms) do
      -- Sum up the build cost of the room
      local build_cost = rooms[room.level_config_id].Cost
      for name, no in pairs(room.objects_needed) do
        -- Add cost for this object.
        build_cost = build_cost + cfg_objects[TheApp.objects[name].thob].StartCost * no
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
    local cfg_objects = self.world.map.level_config.objects
    local cfg_rooms = self.world.map.level_config.rooms
    for _, room in ipairs(TheApp.rooms) do
      -- Sum up the build cost of the room
      local build_cost = cfg_rooms[room.level_config_id].Cost
      for name, no in pairs(room.objects_needed) do
        -- Add cost for this object.
        build_cost = build_cost + cfg_objects[TheApp.objects[name].thob].StartCost * no
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

  if old < 50 then
    self.num_vips_ty = 0
    self.pleased_vips_ty = 0
    self.num_cured_ty = 0
    self.not_cured_ty = 0
    self.num_visitors_ty = 0
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
  if old < 84 then
    self.vip_declined = 0
  end

  if old < 88 then
    self.future_epidemics_pool = {}
    self.concurrent_epidemic_limit = self.world.map.level_config.gbv.EpidemicConcurrentLimit or 1
  end

  if old < 107 then
    self.reception_desks = nil
  end

  if old < 109 then
    -- price distortion
    self.under_priced_threshold = -0.4
    self.over_priced_threshold = 0.3
  end

  if old < 111 then
    self.initial_grace = nil
  end

  if old < 114 then
    self.ratholes = {}
  end

  if old < 131 then
    self.autopsy_discovered = nil
    self.discover_autopsy_risk = nil
  end

  if old < 140 then
    self.has_impressive_reputation = self.reputation_above_threshold and true or false
    self.reputation_above_threshold = nil
    self:unconditionalChangeReputation(0) -- Setup 'has_impressive_reputation'
  end

  if old < 142 then
    self.disasterless_days = self:daysUntilNextDisaster()

    self.heating = {
      radiator_heat = self.radiator_heat or 0.5,
      saved_radiator_heat = self.curr_setting or 0.5,
      boiler_repair_count = self.boiler_countdown or 0,
      heating_broke = self.heating_broke or false
    }
    self.radiator_heat = nil
    self.curr_setting = nil
    self.boiler_countdown = nil
    self.boiler_can_break = nil -- Equivalent to self.opened.
    self.heating_broke = nil
  end

  if old < 143 and new >= 143 then
    if self:isPlayerHospital() then
      setmetatable(self, PlayerHospital._metatable)
    end

    -- To avoid recursion, apply the remaining changes asif the game was
    -- started from version 143.
    self:afterLoad(143, new)
    return
  end

  if old < 146 then
    self.staff_room_msg = nil
    self.toilet_msg = nil
    self.bench_msg = nil
    self.warmth_msg = nil
    self.thirst_msg = nil
    self.seating_warning = nil
    self.cash_msg = nil
  end

  if old < 147 then
    self.patientcount = nil
    self.receptionist_msg = nil
  end
  if old < 148 then
    self.msg_counter = nil
  end
  if old < 152 then
    -- If old save has an emergency fax, or emergency active, of an undiscovered disease
    -- make the disease discovered to prevent crashing (see #1754, #1799)
    local em = self.emergency
    if em and not self.disease_casebook[em.disease.id].discovered then
      self.research:discoverDisease(em.disease)
    end
  end

  if old < 154 then
    -- We now use one table for our room discovery
    self.room_discoveries = {}
    -- Get the level start available rooms
    local avail_rooms = self.world:getAvailableRooms()
    for _, avail_room in ipairs(avail_rooms) do
      self.room_discoveries[avail_room.room.id] = {
        room = avail_room.room,
        is_discovered = avail_room.is_discovered or false
      }
    end
    -- Has the player discovered rooms since?
    for _, room_new in pairs(self.room_discoveries) do
      if self.discovered_rooms[room_new.room] then -- old system used rooms as keys
        room_new.is_discovered = true
      end
    end
    -- Clear old variables
    self.discovered_rooms = nil
    self.undiscovered_rooms = nil
  end

  if old < 155 then
    self.overdraft_interest_rate = self.interest_rate + 0.02
  end

  -- Update other objects in the hospital (added in version 106).
  if self.epidemic then self.epidemic.afterLoad(old, new) end
  for _, future_epidemic in ipairs(self.future_epidemics_pool) do
    future_epidemic.afterLoad(old, new)
  end
  self.research.afterLoad(old, new)
end

--! Count the number of patients in the hospital.
--!param max_count (optional integer) If provided, non-negative maximum count to return.
--!return The number of patients in the hospital, at most max_count is returned if provided.
function Hospital:countPatients(max_count)
  local count = 0
  for _, patient in ipairs(self.patients) do
    -- Only count patients that are in the hospital.
    local tx, ty = patient.tile_x, patient.tile_y
    if tx and ty and self:isInHospital(tx, ty) then
      count = count + 1
      if max_count ~= nil and count >= max_count then break end
    end
  end
  return count
end

--! Count number of sitting and standing patients in the hospital.
--!return (integer, integer) Number of sitting and number of standing patient in the hospital.
function Hospital:countSittingStanding()
  local numberSitting = 0
  local numberStanding = 0
  for _, patient in ipairs(self.patients) do
    local pat_action = patient:getCurrentAction()
    if pat_action.name == "idle" and not patient:getRoom() then
      numberStanding = numberStanding + 1
    elseif pat_action.name == "use_object" and pat_action.object.object_type.id == "bench" then
      numberSitting = numberSitting + 1
    end
  end
  return numberSitting, numberStanding
end

--! Called each tick, also called 'hours'. Check hours_per_day in
--! date.lua to see how many times per day this is.
function Hospital:tick()
  -- Add some random background sounds, ringing phones, coughing, belching etc.
  --
  -- TODO: Background noises of other hospitals are heard in multi-player,
  -- TODO: decide where this should go.
  if math.random(1, 100) == 3 then
    -- Wait until there are some patients in the hospital and a room, otherwise you
    -- will wonder who is coughing or who is the receptionist telephoning!
    -- Opted for gp as you can't run the hospital without one.
    if self:countRoomOfType("gp", 1) > 0 and self:countPatients(3) > 2 then
      local sounds = {
        "ispot001.wav", "ispot002.wav", "ispot003.wav", "ispot004.wav",
        "ispot005.wav", "ispot006.wav", "ispot007.wav", "ispot008.wav",
        "ispot009.wav", "ispot010.wav", "ispot011.wav", "ispot012.wav",
        "ispot013.wav", "ispot014.wav", "ispot015.wav", "ispot016.wav",
        "ispot017.wav", "ispot018.wav", "ispot019.wav", "ispot020.wav",
        "ispot021.wav", "ispot022.wav", "ispot023.wav", "ispot024.wav",
        "ispot025.wav"
      } -- ispot026 and ispot027 are both toilet related sounds.

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
  if map.th:isParcelPurchasable(plot_number, self:getPlayerIndex()) then
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
      self:adviseCannotAffordPlot()
    end
  end
  return false
end

function Hospital:adviseCannotAffordPlot()
  -- Nothing to do, override in a derived class.
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
  -- the specified tile is suitable by checking the spawn tile for
  -- passability.
  if y > 0 and self.world.map:getCellFlag(x, y, "passable") then
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

--[[ Test if a given map tile is part of this hospital.
!param x (integer) The 1-based X coordinate of the tile to test.
!param y (integer) The 1-based Y coordinate of the tile to test.
]]
function Hospital:isInHospital(x, y)
  local flags = self.world.map.th:getCellFlags(x, y)
  return flags.hospital and flags.owner == self:getPlayerIndex()
end

--! Decide how many days the hospital functions within specification.
--!return (int) Number of disaster-free days in the hospital.
function Hospital:daysUntilNextDisaster()
  local disaster_free_days = {300, 200, 150}
  -- Original doesn't use random, see Github #490.
  return disaster_free_days[self.world.map:getDifficulty()] + math.random(1, 21) - 11
end

--! Boiler should break down.
--!param broken_heat (0 or 1) Amount of heat to output due to being broken.
function Hospital:boilerBreakdown(broken_heat)
  local heat_vars = self.heating

  if not self.opened then return end -- Boiler cannot break if hospital is closed.
  if heat_vars.heating_broke then return end -- Still broken, don't break it again.

  local num_radiators = self:countRadiators()
  if num_radiators == 0 then return end -- No radiators, don't bother to break the boiler.

  local num_handyman = self:countStaffOfCategory("Handyman")
  if num_radiators <= 8 * num_handyman then return end -- Enough handyman to maintain the heating system.

  heat_vars.saved_radiator_heat = heat_vars.radiator_heat
  heat_vars.radiator_heat = broken_heat
  heat_vars.boiler_repair_count = math.random(10, 30)
  heat_vars.heating_broke = true

  -- Warn the player of the boiler's breakdown
  self:adviseBoilerBreakdown(broken_heat)
end

--! Select a relevant message to be displayed to the user
function Hospital:adviseBoilerBreakdown()
  -- Nothing to do, override in a sub-class.
end

--! Boiler broke down and work is done to get it fixed.
function Hospital:_fixBoiler()
  local heat_vars = self.heating

  if not heat_vars.heating_broke then return end -- Not broken, done!

  -- Repair the boiler or radiators, more handy men speeds up repair, see also github #490
  local num_radiators = self:countRadiators()
  local num_handyman = self:countStaffOfCategory("Handyman")
  if num_radiators < 5 * num_handyman then
    heat_vars.boiler_repair_count = heat_vars.boiler_repair_count - 3
  elseif num_radiators < 8 * num_handyman then
    heat_vars.boiler_repair_count = heat_vars.boiler_repair_count - 2
  else
    heat_vars.boiler_repair_count = heat_vars.boiler_repair_count - 1
  end

  if heat_vars.boiler_repair_count <= 0 then
    -- It's fixed, restore previous settings.
    heat_vars.radiator_heat = heat_vars.saved_radiator_heat
    heat_vars.heating_broke = false
    if num_radiators > 0 and self:isPlayerHospital() then
      -- Only tell the player about fix if there is at least one radiator.
      self.world.ui.adviser:say(_A.boiler_issue.resolved)
    end
  end
end

--! Daily update of the ratholes.
--!param self (Hospital) hospital being updated.
local function dailyUpdateRatholes(self)
  local map = self.world.map
  local th = map.th

  local wanted_holes = math.round(th:getLitterFraction(self:getPlayerIndex()) * 200)
  if #self.ratholes < wanted_holes then -- Not enough holes, find a new spot
    -- Try to find a wall in a corridor, and add it if possible.
    -- Each iteration does a few probes at a random position, most tries will
    -- fail on not being on a free (non-built) tile in a corridor with a wall
    -- in the right hospital.
    -- Doing more iterations speeds up finding a suitable location, less
    -- iterations is reduces needed processor time.
    -- "6 + 2 * difference" is an arbitrary value that seems to work nicely, 12
    -- is an arbitrary upper limit on the number of tries.
    for _ = 1, math.min(12, 6 + 2 * (wanted_holes - #self.ratholes)) do
      local x = math.random(1, map.width)
      local y = math.random(1, map.height)
      local flags = th:getCellFlags(x, y)
      if self:isInHospital(x, y) and flags.roomId == 0 and flags.buildable then
        local walls = self:getWallsAround(x, y)
        if #walls > 0 then
          -- Found a wall, check it for not being used.
          local wall = walls[math.random(1, #walls)]
          local found = false
          for _, hole in ipairs(self.ratholes) do
            if hole.x == x and hole.y == y and hole.wall == wall.wall then
              found = true
              break
            end
          end

          if not found then
            self:addRathole(x, y, wall.wall, wall.parcel)
            break
          end
        end
      end
    end
  end
end

-- Called at the end of each day.
function Hospital:onEndDay()
  local pay_this = self.loan*self.interest_rate/365 -- No leap years
  self.acc_loan_interest = self.acc_loan_interest + pay_this
  self.research:researchCost()

  self.show_progress_screen_warnings = math.random(1, 3) -- used in progress report to limit warnings
  if self.balance < 0 then
    local overdraft_interest = self.overdraft_interest_rate
    local overdraft = math.abs(self.balance)
    local overdraft_payment = (overdraft*overdraft_interest)/365
    self.acc_overdraft = self.acc_overdraft + overdraft_payment
  end

  -- Count receptionists.
  self.receptionist_count = 0
  for _, staff in ipairs(self.staff) do
    if staff.humanoid_class == "Receptionist" then
      self.receptionist_count = self.receptionist_count + 1
    end
  end

  -- check if we still have to announce VIP visit
  if self.announce_vip > 0 then
    -- check if the VIP is in the building yet
    for _, e in ipairs(self.world.entities) do
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

  self:_fixBoiler() -- Boiler always needs work (especially if broken).

  -- Do we have a disaster?
  self.disasterless_days = self.disasterless_days - 1
  if self.disasterless_days <= 0 then
    self.disasterless_days = self:daysUntilNextDisaster()

    local disaster_type = math.random(1, 3) -- TODO: Set to 3 until the vomit wave is implemented.
    -- disaster_type == 1 is for skipping the disaster, nothing happens.
    if disaster_type == 2 then
      self:boilerBreakdown(1) -- max heat
    elseif disaster_type == 3 then
      self:boilerBreakdown(0) -- min heat
    end
    -- TODO: Implement vomit wave disaster for disaster_type == 4
  end

  -- Calculate heating cost daily.  Divide the monthly cost by the number of days in that month
  local num_radiators = self:countRadiators()
  local heating_costs = (self.heating.radiator_heat * 10 * num_radiators * 7.50) / self.world:date():lastDayOfMonth()
  self.acc_heating = self.acc_heating + heating_costs

  if self:isPlayerHospital() then dailyUpdateRatholes(self) end
end

-- Called at the end of each month.
function Hospital:onEndMonth()
  -- Spend wages
  local wages = 0
  for _, staff in ipairs(self.staff) do
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
    -- Get the amount that is about to be paid to the player
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
  self.research:checkAutomaticDiscovery(self.world:date():monthOfGame())

  -- Add some interesting statistics.
  self.statistics[self.world:date():monthOfGame() + 1] = {
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
end

--! Returns whether this hospital is controlled by a real person or not.
function Hospital:isPlayerHospital()
  return self == self.world:getLocalPlayerHospital()
end

--! Does the hospital have a working reception?
--!return (bool) Whether there is a working reception in the hospital.
function Hospital:hasStaffedDesk()
  for _, desk in ipairs(self:findReceptionDesks()) do
    if desk.receptionist or desk.reserved_for then return true end
  end
  return false
end

--! Collect the reception desks in the hospital.
--!return (list) The reception desks in the hospital.
function Hospital:findReceptionDesks()
  -- TODO Breaks in multiplayer mode.
  local reception_desks = {}
  for _, obj_list in pairs(self.world.objects) do
    for _, obj in ipairs(obj_list) do
      if obj.object_type.id == "reception_desk" then
        reception_desks[#reception_desks + 1] = obj
      end
    end
  end
  return reception_desks
end

--! Called at the end of each year
function Hospital:onEndYear()
  self.sodas_sold = 0
  self.num_vips_ty  = 0
  self.num_deaths_this_year = 0

  self.has_impressive_reputation = true
  self:unconditionalChangeReputation(0) -- Reset self.has_impressive_reputation

  -- On third year of level 3 there is the large increase to salary
  -- this will replicate that. TODO: check other levels above 5 to
  -- see if there are other large increases.
  if self.world:date():year() == 3 and self.world.map.level_number == 3 then
    -- adds the extra to salary in level 3 year 3
    self.player_salary = self.player_salary + math.random(8000,20000)
  end
end

-- Creates complete emergency with patients, what disease they have, what's needed
-- to cure them and the fax.
--!return (optional string) Textual reason for failure, else nil
function Hospital:createEmergency(emergency)
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

    -- If disease chosen isn't discovered, cancel emergency
    if not self.disease_casebook[emergency.disease.id].discovered then
      return "undiscovered_disease"
    end

    self.emergency = emergency
    -- The last room in the list of treatment rooms is considered when checking for availability.
    -- It works for all original diseases, but if we introduce new multiple room diseases it might break.
    -- TODO: Make it work for all kinds of lists of treatment rooms.
    -- TODO: Change to make use of Hospital:checkDiseaseRequirements
    local no_rooms = #emergency.disease.treatment_rooms
    local room_name, required_staff, staff_name =
      self.world:getRoomNameAndRequiredStaffName(emergency.disease.treatment_rooms[no_rooms])

    local staff_available = self:countStaffOfCategory(required_staff) > 0
    -- Check so that all rooms in the list are available
    if self:countRoomOfType(emergency.disease.treatment_rooms[no_rooms], 1) > 0 then
      room_name = nil
    end

    local casebook = self.disease_casebook[random_disease.id]
    local added_info = casebook.drug and
        _S.fax.emergency.cure_possible_drug_name_efficiency:format(emergency.disease.name, casebook.cure_effectiveness)
        or _S.fax.emergency.cure_possible
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
    self.world.ui.bottom_panel:queueMessage("emergency", message, nil, Date.hoursPerDay() * 16, 2) -- automatically refuse after 16 days
    return -- successfully created
  end
  return "no heliport"
end

-- Called when the timer runs out during an emergency or when all emergency patients are cured or dead.
function Hospital:resolveEmergency()
  local emer = self.emergency
  local rescued_patients = emer.cured_emergency_patients
  for _, patient in ipairs(self.emergency_patients) do
    if patient and not patient.cured and not patient.dead
        and not patient.going_home and not patient:getRoom() then
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

  self.world:nextEmergency()
end

--! Determine if all of the patients in the emergency have been cured or killed.
--! If they have end the emergency timer.
function Hospital:checkEmergencyOver()
  local killed = self.emergency.killed_emergency_patients
  local cured = self.emergency.cured_emergency_patients
  if killed + cured >= self.emergency.victims then
    local window = self.world.ui:getWindow(UIWatch)
    if window then
      window:onCountdownEnd()
    end
  end
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
  if patient.is_emergency or not patient.disease.contagious or self.epidemics_off then
    return false
  end
  -- ContRate treated like a percentage with ContRate% of patients with
  -- a disease having the contagious strain
  local level_config = self.world.map.level_config
  local disease = patient.disease
  local contRate = level_config.expertise[disease.expertise_id].ContRate or 0

  -- The patient is potentially contagious as we do not yet know if there
  -- is a suitable epidemic which they can belong to
  local potentially_contagious = contRate > 0 and (math.random(1,contRate) == contRate)
  -- The patient isn't contagious if these conditions aren't passed
  local reduce_months = level_config.ReduceContMonths or 14
  local reduce_people = level_config.ReduceContPeepCount or 20
  local date_in_months = self.world:date():monthOfGame()

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
  local epidemic = self.epidemic
  -- Don't add a new contagious patient if the player is trying to cover up
  -- an existing epidemic - not really fair
  if epidemic and not epidemic.coverup_in_progress and
      (patient.disease == epidemic.disease) then
    epidemic:addContagiousPatient(patient)
  elseif self.future_epidemics_pool and
      not (epidemic and epidemic.coverup_in_progress) then
    local added = false
    for _, future_epidemic in ipairs(self.future_epidemics_pool) do
      if future_epidemic.disease == patient.disease then
        future_epidemic:addContagiousPatient(patient)
        added = true
        break
      end
    end

    if not added then
      -- Make a new epidemic as one doesn't exist with this disease, but only if
      -- we haven't reach the concurrent epidemic limit
      if self:countEpidemics() < self.concurrent_epidemic_limit then
        local new_epidemic = Epidemic(self, patient)
        self.future_epidemics_pool[#self.future_epidemics_pool + 1] = new_epidemic
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
  -- Everything is free in free build mode.
  if self.world.free_build_mode then return 0 end

  local progress = self.research.research_progress
  local cfg_objects = self.world.map.level_config.objects
  local obj_def = TheApp.objects[name]
  -- Get how much this item costs at the start of the level.
  local obj_cost = cfg_objects[obj_def.thob].StartCost
  -- Some objects might have got their cost reduced by research.
  if progress[obj_def] then
    obj_cost = progress[obj_def].cost
  end
  return obj_cost
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
    self:logTransaction({spend = amount, desc = reason})
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
    self:logTransaction({receive = amount, desc = reason})
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
    local disease_id = patient:getTreatmentDiseaseId()
    if disease_id == nil then return end
    local casebook = self.disease_casebook[disease_id]
    local reason
    if casebook.pseudo then
      reason = _S.transactions.treat_colon .. " " .. casebook.disease.name
    else
      reason = _S.transactions.cure_colon .. " " .. casebook.disease.name
    end
    local amount = self:getTreatmentPrice(disease_id)

    -- 25% of the payments now go through insurance
    if patient.insurance_company then
      self:addInsuranceMoney(patient.insurance_company, amount)
    else
      -- patient is paying normally (but still, he could feel like it's
      -- under- or over-priced and it could impact happiness and reputation)
      self:computePriceLevelImpact(patient, casebook)
      self:receiveMoney(amount, reason)
    end
    casebook.money_earned = casebook.money_earned + amount
    patient.world:newFloatingDollarSign(patient, amount)
  end
end

--! Sell a soda to a patient.
--!param patient (patient) The patient buying the soda.
function Hospital:sellSodaToPatient(patient)
  self:receiveMoneyForProduct(patient, 20, _S.transactions.drinks)
  self.sodas_sold = self.sodas_sold + 1
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

--! Pay drug if drug has been purchased to treat a patient.
--!param disease_id Disease that was treated.
function Hospital:paySupplierForDrug(disease_id)
  local drug_amount = self.disease_casebook[disease_id].drug_cost or 0
  if drug_amount ~= 0 then
    local str = _S.drug_companies[math.random(1, 5)]
    self:spendMoney(drug_amount, _S.transactions.drug_cost .. ": " .. str)
  end
end

--[[ Add a transaction to the hospital's transaction log.
!param transaction (table) A table containing a string field called `desc`, and
at least one of the following integer fields: `spend`, `receive`.
]]
function Hospital:logTransaction(transaction)
  transaction.balance = self.balance
  transaction.day = self.world:date():dayOfMonth()
  transaction.month = self.world:date():monthOfYear()
  while #self.transactions > 20 do
    self.transactions[#self.transactions] = nil
  end
  table.insert(self.transactions, 1, transaction)
end

--! Initialize hospital staff from the level config.
function Hospital:initStaff()
  local level_config = self.world.map.level_config
  if level_config.start_staff then
    for _, conf in ipairs(level_config.start_staff) do
      local profile
      local skill = 0
      local added_staff = true
      if conf.Skill then
        skill = conf.Skill / 100
      end

      if conf.Nurse == 1 then
        profile = StaffProfile(self.world, "Nurse", _S.staff_class["nurse"])
        profile:init(skill)
      elseif conf.Receptionist == 1 then
        profile = StaffProfile(self.world, "Receptionist", _S.staff_class["receptionist"])
        profile:init(skill)
      elseif conf.Handyman == 1 then
        profile = StaffProfile(self.world, "Handyman", _S.staff_class["handyman"])
        profile:init(skill)
      elseif conf.Doctor == 1 then
        profile = StaffProfile(self.world, "Doctor", _S.staff_class["doctor"])

        local shrink = 0
        local rsch = 0
        local surg = 0
        local jr, cons

        if conf.Shrink == 1 then shrink = 1 end
        if conf.Surgeon == 1 then surg = 1 end
        if conf.Researcher == 1 then rsch = 1 end

        if conf.Junior == 1 then jr = 1
        elseif conf.Consultant == 1 then cons = 1
        end
        profile:initDoctor(shrink,surg,rsch,jr,cons,skill)
      else
        added_staff = false
      end
      if added_staff then
        local staff = self.world:newEntity(profile.humanoid_class, 2)
        staff:setProfile(profile)

        -- Identify a safe starting place and
        -- try to place the staff member randomly near it or on it
        local map = self.world.map.th
        local map_x_length, map_y_length = map:size()
        local map_offset = 10
        local x, y = map:getCameraTile(self:getPlayerIndex())
        -- Make sure the random numbers (x_attempt, y_attempt) will be safely within the map
        local x_safe = math.max(map_offset + 1, math.min(x, map_x_length - map_offset))
        local y_safe = math.max(map_offset + 1, math.min(y, map_y_length - map_offset))
        local x_attempt, y_attempt
        local attempts = 0
        repeat
          x_attempt = x_safe + math.random(-map_offset, map_offset)
          y_attempt = y_safe + math.random(-map_offset, map_offset)
          attempts = attempts + 1
        until attempts > 100 or self:isInHospital(x_attempt, y_attempt)
        if attempts <= 100 then
          staff:setTile(x_attempt, y_attempt)
        elseif self:isInHospital(x, y) then
          staff:setTile(x, y)
        else
          staff:setTile(map_x_length / 2, map_y_length / 2)
        end
        staff:onPlaceInCorridor()
        self.staff[#self.staff + 1] = staff
        staff:setHospital(self)
      end
    end
  end
end


function Hospital:addStaff(staff)
  self.staff[#self.staff + 1] = staff
  -- Cost of hiring staff:
  self:spendMoney(staff.profile.wage, _S.transactions.hire_staff .. ": "
    .. staff.profile:getFullName())
  self:notifyOfStaffChange(staff)
end

function Hospital:addPatient(patient)
  self.patients[#self.patients + 1] = patient
  -- Add to the hospital's visitor count
  self.num_visitors = self.num_visitors + 1
  self.num_visitors_ty = self.num_visitors_ty + 1

  -- Decide if the patient belongs in an epidemic
  self:determineIfContagious(patient)
end

--! Humanoid has died, record the incident.
--!param patient The deceased.
function Hospital:humanoidDeath(patient)
  self:msgKilled()

  if not patient.is_debug then
    local case = self.disease_casebook[patient.disease.id]
    case.fatalities = case.fatalities + 1
  end
  self.num_deaths = self.num_deaths + 1
  self.num_deaths_this_year = self.num_deaths_this_year + 1

  self:changeReputation("death", patient.disease)
  self:updatePercentages()

  if patient.is_emergency then
    self.emergency.killed_emergency_patients = self.emergency.killed_emergency_patients + 1
  end
end

--! Checks if the hospital employs staff of a given category.
--!param category (string) A humanoid_class or one of the specialists, i.e.
--! "Doctor", "Nurse", "Handyman", "Receptionist", "Psychiatrist",
--! "Surgeon", "Researcher", "Junior" or "Consultant"
--!param max_count (optional integer) If provided, non-negative maximum count to return.
--! returns Number of that type employed, at most max_count is returned if provided.
function Hospital:countStaffOfCategory(category, max_count)
  local result = 0
  for _, staff in ipairs(self.staff) do
    if staff:fulfillsCriterion(category) then
      result = result + 1
    end
    if max_count ~= nil and result >= max_count then break end
  end
  return result
end

--! Checks if the hospital has a room of a given type.
--!param type (string) A room_info.id, e.g. "ward".
--!param max_count (optional integer) If provided, non-negative maximum count to return.
--! Returns Number of that type found, at most max_count is returned if provided.
function Hospital:countRoomOfType(type, max_count)
  -- Check how many rooms there are.
  local result = 0
  for _, room in pairs(self.world.rooms) do
    if room.hospital == self and room.room_info.id == type and room.is_active then
      result = result + 1
      if max_count ~= nil and result >= max_count then break end
    end
  end
  return result
end

--! Get the number of reception desks in the hospital.
--!return (int) Number of reception desks in the hospital.
function Hospital:countReceptionDesks()
  -- TODO Breaks in multiplayer mode.
  return self.world.object_counts["reception_desk"]
end

--! Get the number of radiators in the hospital.
--!return (int) Number of radiators in the hospital.
function Hospital:countRadiators()
  -- TODO Breaks in multiplayer mode.
  return self.world.object_counts["radiator"]
end

--! Get the number of plants in the hospital.
--!return (int) Number of plants in the hospital.
function Hospital:countPlants()
  -- TODO Breaks in multiplayer mode.
  return self.world.object_counts["plant"]
end

--! Get the number of fire extinguishers in the hospital.
--!return (int) Number of fire extinguishers in the hospital.
function Hospital:countFireExtinguishers()
  -- TODO Breaks in multiplayer mode.
  return self.world.object_counts["extinguisher"]
end

--! Get the number of general objects in the hospital.
--!return (int) Number of general objects in the hospital.
function Hospital:countGeneralObjects()
  -- TODO Breaks in multiplayer mode.
  return self.world.object_counts["general"]
end

--! A new object has been placed in the hospital.
--!param entity (Entity) The entity that was just placed.
--!param id (string) That entity's id.
function Hospital:objectPlaced(entity, id)
  -- If it is a bench we're placing, notify queueing patients in the vicinity
  if id == "bench" then
    local notify_distance = 6
    local w, h = self.world.map.th:size()
    for tx = math.max(1, entity.tile_x - notify_distance), math.min(w, entity.tile_x + notify_distance) do
      for ty = math.max(1, entity.tile_y - notify_distance), math.min(h, entity.tile_y + notify_distance) do
        for _, patient in ipairs(self.world.entity_map:getHumanoidsAtCoordinate(tx, ty)) do
          if class.is(patient, Patient) then
            patient:notifyNewObject(id)
          end
        end
      end
    end
    return
  end

  if id == "reception_desk" then
    self:msgReceptionDesk()
    return
  end

  if id == "plant" then
    self:msgPlant()
    return
  end

  if id == "gates_to_hell" then
    self:showGatesToHell(entity)
    return
  end
end

--! Give advice to the user about having bought a reception desk.
function Hospital:msgReceptionDesk()
  -- Nothing to do, override in a sub-class.
end

--! Give advice to the user about maintenance of plants.
function Hospital:msgPlant()
  -- Nothing to do, override in a sub-class.
end

--! Show the 'Gates to hell' animation.
--!param _entity (Entity) Gates to hell.
function Hospital:showGatesToHell(_entity)
  -- Nothing to do, override in a sub-class.
end

--! Remove the first entry with a given value from a table.
--! Only works reliably for lists.
--!param t Table to search for the value, and update.
--!param value Value to search and remove.
--!return Whether the value was removed.
local function RemoveByValue(t, value)
  for i, v in ipairs(t) do
    if v == value then
      table.remove(t, i)
      return true
    end
  end
  return false
end

--! Remove a staff member from the hospital staff.
--!param staff (Staff) Staff member to remove.
function Hospital:removeStaff(staff)
  RemoveByValue(self.staff, staff)
  -- update all messages for waiting patients
  self:notifyOfStaffChange(staff)
end

--! Remove a patient from the hospital.
--!param patient (Patient) Patient to remove.
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
  ["over_priced"] = -2,
  ["under_priced"] = 1,
  ["room_crash"] = -50,
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
    local rep_hit_perc = self.world.map.level_config.gbv.AutopsyRepHitPercent
    amount = rep_hit_perc and math.floor(-self.reputation * rep_hit_perc / 100) or -70
  elseif valueChange then
    amount = valueChange
  else
    amount = reputation_changes[reason]
  end
  if self:isReputationChangeAllowed(amount) then
    self:unconditionalChangeReputation(amount)
  end
  if disease then
    local casebook = self.disease_casebook[disease.id]
    casebook.reputation = casebook.reputation + amount
  end
end

--! Unconditionally change the reputation.
--! In most cases, the better entry point for changing reputation
--! is 'Hospital:changeReputation'.
--!param valueChange (integer) Amount of change.
function Hospital:unconditionalChangeReputation(valueChange)
  self.reputation = self.reputation + valueChange

  if self.reputation < self.reputation_min then
    self.reputation = self.reputation_min
  elseif self.reputation > self.reputation_max then
    self.reputation = self.reputation_max
  end

  -- Check if criteria for trophy is still met
  if self.has_impressive_reputation then
    local level_config = self.world.map.level_config
    if level_config.awards_trophies then
      local min_repuration = level_config.awards_trophies.Reputation
      self.has_impressive_reputation = min_repuration < self.reputation
      return
    end
    self.has_impressive_reputation = false
  end
end

--! Decide whether a reputation change is effective or not. As we approach 1000,
--! a gain is less likely. As we approach 0, a loss is less likely.
--! Under 500, a gain is always effective.  Over 500, a loss is always effective.
--!param amount (int): The amount of reputation change.
function Hospital:isReputationChangeAllowed(amount)
  if (amount > 0 and self.reputation <= 500) or (amount < 0 and self.reputation >= 500) or (amount == 0) then
    return true
  else
    return math.random() <= self:getReputationChangeLikelihood()
  end
end

--! Compute the likelihood for a reputation change to be effective.
--! Likelihood gets smaller as hospital reputation gets closer to extreme values.
--!return (float) Likelihood of a reputation change.
function Hospital:getReputationChangeLikelihood()
  -- The result follows a quadratic function, for a curved and smooth evolution.
  -- If reputation == 500, the result is 100%.
  -- Between [380-720], the result is still over 80%.
  -- At 100 or 900, it's under 40%.
  -- At 0 or 1000, it's 0%.
  --
  -- The a, b and c coefficients have been computed to include points
  -- (x=0, y=1), (x=500, y=0) and (x=1000, y=1) where x is the current
  -- reputation and y the likelihood of the reputation change to be
  -- refused, based a discriminant (aka "delta") == 0
  local a = 0.000004008
  local b = 0.004008
  local c = 1

  local x = self.reputation

  -- The result is "reversed" for more readability
  return 1 - (a * x * x - b * x + c)
end

--! Update the 'cured' counts of the hospital.
--!param patient Patient that was cured.
function Hospital:updateCuredCounts(patient)
  self:msgCured()

  if not patient.is_debug then
    self:changeReputation("cured", patient.disease)
  end

  self.num_cured = self.num_cured + 1
  self.num_cured_ty = self.num_cured_ty + 1

  local casebook = self.disease_casebook[patient.disease.id]
  casebook.recoveries = casebook.recoveries + 1

  if patient.is_emergency then
    self.emergency.cured_emergency_patients = self.emergency.cured_emergency_patients + 1
  end
end

--! Update the 'not cured' counts of the hospital.
--!param patient Patient that was not cured.
--!param reason (string) the reason why the patient is not cured.
--! -"kicked": Patient goes home early (manually sent, no treatment room, etc).
--! -"over_priced": Patient considers the price too high.
function Hospital:updateNotCuredCounts(patient, reason)
  if patient.is_debug then return end

  self:changeReputation(reason, patient.disease)
  self.not_cured = self.not_cured + 1
  self.not_cured_ty = self.not_cured_ty + 1

  if reason == "kicked" then
    local casebook = self.disease_casebook[patient.disease.id]
    casebook.turned_away = casebook.turned_away + 1
  end

  -- though not killed allows timer to close early
  if patient.is_emergency then
    self.emergency.killed_emergency_patients = self.emergency.killed_emergency_patients + 1
  end
end

function Hospital:updatePercentages()
  local killed = self.num_deaths / (self.num_cured + self.num_deaths) * 100
  self.percentage_killed = math.round(killed)
  local cured = self.num_cured / (self.num_cured + self.not_cured + self.num_deaths) * 100
  self.percentage_cured = math.round(cured)
end

--! Compute average of an attribute for all patients in the hospital.
--!param attribute (str) Name of the attribute.
--!param default_value Value to return if there are no patients.
--!return Average value of the attribute for all hospital patients, or the default value.
function Hospital:getAveragePatientAttribute(attribute, default_value)
  local sum = 0
  local count = 0
  for _, patient in ipairs(self.patients) do
    local tx, ty = patient.tile_x, patient.tile_y
    -- Some patients (i.e. Alien) may not have the attribute in question, so check for that
    if tx and ty and self:isInHospital(tx, ty) and patient.attributes[attribute] then
      sum = sum + patient.attributes[attribute]
      count = count + 1
    end
  end

  if count == 0 then
    return default_value
  else
    return sum / count
  end
end

--! Compute average of an attribute for all staff in the hospital.
--!param attribute (str) Name of the attribute.
--!param default_value Value to return if there is no staff.
--!return Average value of the attribute for all staff, or the default value.
function Hospital:getAverageStaffAttribute(attribute, default_value)
  local sum = 0
  local count = 0
  for _, staff in ipairs(self.staff) do
    if staff.attributes[attribute] then
      sum = sum + staff.attributes[attribute]
      count = count + 1
    end
  end

  return count == 0 and default_value or sum / count
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
  for _, room_id in ipairs(self.world.available_diseases[disease].treatment_rooms) do
    local found = self:countRoomOfType(room_id, 1) > 0
    if not found then
      rooms[#rooms + 1] = room_id
      any = true
    end

    -- Get staff for room
    for staff_class, amount in pairs(TheApp.rooms[room_id].required_staff) do
      local available = self:countStaffOfCategory(staff_class)
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

--! Get the set of walls around a tile position.
--!param x (int) X position of the queried tile.
--!param y (int) Y position of the queried tile.
--!return (table {wall, parcel}) The walls around the given position.
function Hospital:getWallsAround(x, y)
  local map = self.world.map
  local th = map.th

  local _, nw, ww
  local walls = {} -- List of {wall="north"/"west"/"south"/"east", parcel}
  local flags = th:getCellFlags(x, y)

  _, nw, ww = th:getCell(x, y) -- floor, north wall, west wall
  if ww ~= 0 then
    walls[#walls + 1] = {wall = "west", parcel = flags.parcelId}
  end
  if nw ~= 0 then
    walls[#walls + 1] = {wall = "north",  parcel = flags.parcelId}
  end

  if x ~= map.width then
    _, _, ww = th:getCell(x + 1, y)
    if ww ~= 0 then
      walls[#walls + 1] = {wall = "east", parcel = flags.parcelId}
    end
  end

  if y ~= map.height then
    _, nw, _ = th:getCell(x, y + 1)
    if nw ~= 0 then
      walls[#walls + 1] = {wall = "south", parcel = flags.parcelId}
    end
  end

  return walls
end

--! Test for the given position to be inside the given rectangle.
--!param x (int) X position to test.
--!param y (int) Y position to test.
--!param rect (table x, y, width, height) Rectangle to check against.
--!return (bool) Whether the position is inside the rectangle.
local function isInside(x, y, rect)
  return x >= rect.x and x < rect.x + rect.width and y >= rect.y and y < rect.y + rect.height
end

--! Find all ratholes that match the `to_match` criteria.
--!param holes (list ratholes) Currently existing holes.
--!param to_match (table) For each direction a rectangle with matching tile positions.
--!return (list) Matching ratholes.
local function findMatchingRatholes(holes, to_match)
  local matched = {}
  for _, hole in ipairs(holes) do
    if isInside(hole.x, hole.y, to_match[hole.wall]) then table.insert(matched, hole) end
  end
  return matched
end

--! Remove the ratholes that use the walls of the provided room.
--!param room (Room) Room being de-activated.
function Hospital:removeRatholesAroundRoom(room)
  local above_rect = {x = room.x, width = room.width, y = room.y - 1,          height = 1}
  local below_rect = {x = room.x, width = room.width, y = room.y +room.height, height = 1}
  local left_rect  = {x = room.x - 1,          width = 1, y = room.y, height = room.height}
  local right_rect = {x = room.x + room.width, width = 1, y = room.y, height = room.height}

  local to_delete = {east = left_rect, west = right_rect, south = above_rect, north = below_rect}

  local remove_holes = findMatchingRatholes(self.ratholes, to_delete)
  for _, hole in ipairs(remove_holes) do self:removeRathole(hole) end
end

-- Add a rathole to the room.
--!param x (int) X position of the tile containing the rathole.
--!param y (int) Y position of the tile containing the rathole.
--!param wall (string) Wall containing the hole (north, west, south, east)
--!param parcel (int) Parcel number of the xy position.
function Hospital:addRathole(x, y, wall, parcel)
  for _, rathole in ipairs(self.ratholes) do
    if rathole.x == x and rathole.y == y and rathole.wall == wall then return end
  end

  local hole = {x = x, y = y, wall = wall, parcel = parcel}
  if wall == "north" or wall == "west" then
    -- Only add a rat-hole graphics object for the visible holes.
    hole["object"] = self.world:newObject("rathole", hole.x, hole.y, hole.wall)
  end
  table.insert(self.ratholes, hole)
end

--! Remove the provided rathole.
--!param hole (table{x, y, wall, optional object}) Hole to remove.
function Hospital:removeRathole(hole)
  for i, rathole in ipairs(self.ratholes) do
    if rathole.x == hole.x and rathole.y == hole.y and rathole.wall == hole.wall then
      table.remove(self.ratholes, i)
      if rathole.object then
        self.world:destroyEntity(rathole.object)
      end

      break
    end
  end
end

--! Remove any rathole from the given position.
--!param x X position of the tile that should not have ratholes.
--!param y Y position of the tile that should not have ratholes.
function Hospital:removeRatholeXY(x, y)
  for i = #self.ratholes, 1, -1 do
    local rathole = self.ratholes[i]
    if rathole.x == x and rathole.y == y then
      table.remove(self.ratholes, i)
      if rathole.object then self.world:destroyEntity(rathole.object) end
    end
  end
end

--! Adds a handyman task
--!param object The object needing attention
--!param taskType The handyman task type: repairing, watering, cleaning
--!param priority Task priority: 1 is low, 2 is high
--!param x coordinate
--!param y coordinate
--!param call The call added to the dispatcher
function Hospital:addHandymanTask(object, taskType, priority, x, y, call)
  local parcelId = self.world.map.th:getCellFlags(x, y).parcelId
  local subTable = self:findHandymanTaskSubtable(taskType)
  table.insert(subTable, {["object"] = object, ["priority"] = priority, ["tile_x"] = x, ["tile_y"] = y, ["parcelId"] = parcelId, ["call"] = call})
end

--! Queries the priority of an existing handyman task
--!param taskIndex (integer) Number of task
--!param taskType The handyman task type: repairing, watering, cleaning
--!return Priority of task
function Hospital:getHandymanTaskPriority(taskIndex, taskType)
  local subTable = self:findHandymanTaskSubtable(taskType)
  return subTable[taskIndex].priority
end

function Hospital:modifyHandymanTaskPriority(taskIndex, newPriority, taskType)
  if taskIndex ~= -1 then
    local subTable = self:findHandymanTaskSubtable(taskType)
    subTable[taskIndex].priority = newPriority
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
  for i = 1, #self.handymanTasks do
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
          v.assignedHandyman:unassignTask()
        elseif not v.assignedHandyman.hospital then
          -- This should normally never be the case. If the handyman doesn't belong to a hsopital
          -- then they should not have any tasks assigned to them however it was previously possible
          -- We need to tidy up to make sure the task can be reassigned.
          print("Warning: Orphaned handyman is still assigned a task. Removing.")
          v.assignedHandyman:unassignTask()
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

--! Find a handyman task by task type, position, and possibly the used object.
--!param x (int) The X coordinate of the position.
--!param y (int) The Y coordinate of the position.
--!param taskType Type of the task.
--!param obj (Object) If specified, the object used for doing the task.
--! Since multiple litter objects may exist at the same tile, the object must be given when cleaning.
function Hospital:getIndexOfTask(x, y, taskType, obj)
  local subTable = self:findHandymanTaskSubtable(taskType)
  for i, v in ipairs(subTable) do
    if v.tile_x == x and v.tile_y == y and (obj == nil or v.object == obj) then
      return i
    end
  end
  return -1
end

--! Afterload function to initialize the owned plots.
function Hospital:initOwnedPlots()
  self.ownedPlots = {}
  for _, v in ipairs(self.world.entities) do
    if v.tile_x and v.tile_y then
      local parcel = self.world.map.th:getCellFlags(v.tile_x, v.tile_y).parcelId
      local isAlreadyContained = false
      for _, v2 in ipairs(self.ownedPlots) do
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
--!param disease (string): the disease to be checked.
function Hospital:roomNotYetResearched(disease)
  local req = self:checkDiseaseRequirements(disease)
  if type(req) == "table" and #req.rooms > 0 then
    for _, room_id in ipairs(req.rooms) do
      if not self:isRoomDiscovered(room_id) then return true end
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

--! Change patient happiness and hospital reputation based on price distortion.
--! The patient happiness is adjusted proportionally. The hospital reputation
--! can only be affected when the distortion level reaches some threshold.
--!param patient (patient) The patient paying the bill. His/her happiness level
--! is adjusted.
--!param casebook (object) Disease casebook entry. It's used to display the
--! localised disease name when Adviser tells the warning message.
function Hospital:computePriceLevelImpact(patient, casebook)
  local price_distortion = patient:getPriceDistortion(casebook)
  patient:changeAttribute("happiness", -(price_distortion / 2))

  if price_distortion < self.under_priced_threshold then
    if math.random(1, 100) == 1 then
      self:advisePriceLevelImpact("under", casebook.disease.name)
      self:changeReputation("under_priced")
    end
  elseif price_distortion > self.over_priced_threshold then
    if math.random(1, 100) == 1 then
      self:advisePriceLevelImpact("over", casebook.disease.name)
      self:changeReputation("over_priced")
    end
  elseif math.abs(price_distortion) <= 0.15 and math.random(1, 200) == 1 then
    -- When prices are well adjusted (i.e. abs(price distortion) <= 0.15)
    self:advisePriceLevelImpact("fair", casebook.disease.name)
  end
end

function Hospital:advisePriceLevelImpact()
  -- Nothing to do, override in a derived class.
end

--! Notify patients of a change to hospital staff members
--!param staff (Staff) Changed staff member subject of notification
function Hospital:notifyOfStaffChange(staff)
  for _, patient in pairs(self.patients) do
    patient:notifyOfStaffChange(staff)
  end
end

--! Change the hospital value by an amount independent of a cost being incurred
--!param changeValue (int) The amount the hospital value should change by
function Hospital:changeValue(changeValue)
  self.value = self.value + changeValue
end

--! Collect the hospital level settings relevant for the next hospital
--!return campaign_data (table) Hospital campaign data
function Hospital:getCampaignData()
  local campaign_data = {
    player_salary = self.player_salary,
    message_popup = self.message_popup,
    handyman_popup = self.handyman_popup,
    hospital_littered = self.hospital_littered,
    has_seen_pay_rise = self.has_seen_pay_rise,
    policies = self.policies,
  }
  return campaign_data
end

--! Restore the hospital settings from the previous hospital
--!param campaign_data (table) Hospital campaign data
function Hospital:setCampaignData(campaign_data)
  for key, value in pairs(campaign_data) do
    self[key] = value
  end
end

--! Finds a random room with significantly long queues
--!return room or nil The chosen room in the hospital or nil for no room busy enough
function Hospital:getRandomBusyRoom()
  local long_queue_rooms, active_rooms, total_queue = {}, 0, 0
  for _, room in pairs(self.world.rooms) do
    if room.is_active and room.door.queue then
      total_queue = total_queue + #room.door.queue
      active_rooms = active_rooms + 1
      if #room.door.queue > 7 then
        long_queue_rooms[#long_queue_rooms + 1] = room
      end
    end
  end
  if #long_queue_rooms == 0 then return end

  local busy_threshold = 1.5 * total_queue / active_rooms
  local chosen_room = long_queue_rooms[math.random(1, #long_queue_rooms)]
  if #chosen_room.door.queue >= busy_threshold then return chosen_room end
end

function Hospital:adviseDiscoverDisease()
  -- Nothing to do, override in a derived class.
end

function Hospital:makeRaiseRequest()
  -- Nothing to do, override in a derived class.
end

function Hospital:announceRepair()
  -- Nothing to do, override in a derived class.
end
