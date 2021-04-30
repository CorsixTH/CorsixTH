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

local TH = require"TH"
local ipairs, _G, table_remove
    = ipairs, _G, table.remove

corsixth.require("entities.humanoids.patient")
corsixth.require("entities.humanoids.staff.doctor")
corsixth.require("entities.humanoids.staff.nurse")
corsixth.require("entities.humanoids.staff.handyman")
corsixth.require("entities.humanoids.staff.receptionist")
corsixth.require("entities.humanoids.vip")
corsixth.require("entities.humanoids.grim_reaper")
corsixth.require("entities.humanoids.inspector")
corsixth.require("staff_profile")
corsixth.require("hospital")
corsixth.require("hospitals.player_hospital")
corsixth.require("hospitals.ai_hospital")
corsixth.require("cheats")
corsixth.require("epidemic")
corsixth.require("calls_dispatcher")
corsixth.require("research_department")
corsixth.require("entity_map")
corsixth.require("date")
corsixth.require("announcer")

local AnnouncementPriority = _G["AnnouncementPriority"]

--! Manages entities, rooms, and the date.
class "World"

---@type World
local World = _G["World"]

local local_criteria_variable = {
  {name = "reputation",       icon = 10, formats = 2},
  {name = "balance",          icon = 11, formats = 2},
  {name = "percentage_cured", icon = 12, formats = 2},
  {name = "num_cured" ,       icon = 13, formats = 2},
  {name = "percentage_killed",icon = 14, formats = 2},
  {name = "value",            icon = 15, formats = 2},
  {name = "population",       icon = 11, formats = 1},
}

-- time between each damage caused by an earthquake
local earthquake_damage_time = 16 -- hours
local earthquake_warning_period = 600 -- hours between warning and real thing
local earthquake_warning_length = 25 -- length of early warning quake

function World:World(app)
  self.app = app
  self.map = app.map
  self.wall_types = app.walls
  self.object_types = app.objects
  self.anims = app.anims
  self.animation_manager = app.animation_manager
  self.pathfinder = TH.pathfinder()
  self.pathfinder:setMap(app.map.th)
  self.entities = {} -- List of entities in the world.
  self.dispatcher = CallsDispatcher(self)
  self.objects = {}
  self.object_counts = {
    extinguisher = 0,
    radiator = 0,
    plant = 0,
    reception_desk = 0,
    bench = 0,
    general = 0,
  }
  self.objects_notify_occupants = {}
  self.rooms = {} -- List that can have gaps when a room is deleted, so use pairs to iterate.
  self.entity_map = EntityMap(self.map)

  -- All information relating to the next or current earthquake, nil if
  -- there is no scheduled earthquake.
  -- Contains the following fields:
  -- active (boolean) Whether we are currently running the warning or damage timers (after start_day of start_month is passed).
  -- start_month (integer) The month the earthquake warning is triggered.
  -- start_day (integer) The day of the month the earthquake warning is triggered.
  -- size (integer) The amount of damage the earthquake causes (1-9).
  -- remaining_damage (integer) The amount of damage this earthquake has yet to inflict.
  -- damage_timer (integer) The number of hours until the earthquake next inflicts damage if active.
  -- warning_timer (integer) The number of hours left until the real damaging earthquake begins.
  self.next_earthquake = { active = false }

  -- Time
  self.hours_per_tick = 1
  self.tick_rate = 3
  self.tick_timer = 0
  self.game_date = Date() -- Current date in the game.

  self.room_information_dialogs = app.config.room_information_dialogs
  -- This is false when the game is paused.
  self.user_actions_allowed = true

  -- The system pause method is used as an additional layer to pause the game, where the user
  -- needs to deal with a recoverable error
  self.system_pause = false

  -- In Free Build mode?
  if tonumber(self.map.level_number) then
    self.free_build_mode = false
  else
    self.free_build_mode = app.config.free_build_mode
  end

  -- If set, do not create salary raise requests.
  self.debug_disable_salary_raise = self.free_build_mode
  self.idle_cache = {}
  -- List of which goal criterion means what, and what number the corresponding icon has.
  self.level_criteria = local_criteria_variable
  self.delayed_map_objects = {} -- Initial objects in the map for parcels without owner.
  self.room_remove_callbacks = {--[[a set rather than a list]]}
  self.room_built = {} -- List of room types that have been built
  self.hospitals = {}
  self.floating_dollars = {}
  self.game_log = {} -- saves list of useful debugging information
  self.savegame_version = app.savegame_version -- Savegame version number
  self.release_version = app:getVersion(self.savegame_version) -- Savegame release version (e.g. 0.60), or Trunk
  -- Also preserve this throughout future updates.
  self.original_savegame_version = app.savegame_version

  -- Initialize available rooms.
  local avail_rooms = self:getAvailableRooms()
  self.available_rooms = {} -- Both a list and a set, use ipairs to iterate through the available rooms.
  for _, avail_room in ipairs(avail_rooms) do
    local room = avail_room.room
    self.available_rooms[#self.available_rooms + 1] = room
    self.available_rooms[room.id] = room
  end

  -- Initialize available diseases and winning conditions.
  self:initLevel(app, avail_rooms)

  -- Construct hospitals.
  self.hospitals[1] = PlayerHospital(self, avail_rooms, app.config.player_name)

  -- Add computer players
  -- TODO: Right now they're only names
  local level_config = self.map.level_config
  for key, value in pairs(level_config.computer) do
    if value.Playing == 1 then
      self.hospitals[#self.hospitals + 1] = AIHospital(tonumber(key) + 1,
          self, avail_rooms, value.Name)
    end
  end

  -- Setup research.
  for _, hospital in ipairs(self.hospitals) do
    hospital.research:setResearchConcentration()
  end

  self:updateInitialsCache()
  -- TODO: Add (working) AI and/or multiplayer hospitals
  -- TODO: Needs to be changed for multiplayer support
  self.hospitals[1]:initStaff()

  self.wall_id_by_block_id = {}
  for _, wall_type in ipairs(self.wall_types) do
    for _, set in ipairs({"inside_tiles", "outside_tiles", "window_tiles"}) do
      for _, id in pairs(wall_type[set]) do
        self.wall_id_by_block_id[id] = wall_type.id
      end
    end
  end
  self.wall_set_by_block_id = {}
  for _, wall_type in ipairs(self.wall_types) do
    for _, set in ipairs({"inside_tiles", "outside_tiles", "window_tiles"}) do
      for _, id in pairs(wall_type[set]) do
        self.wall_set_by_block_id[id] = set
      end
    end
  end
  self.wall_dir_by_block_id = {}
  for _, wall_type in ipairs(self.wall_types) do
    for _, set in ipairs({"inside_tiles", "outside_tiles", "window_tiles"}) do
      for name, id in pairs(wall_type[set]) do
        self.wall_dir_by_block_id[id] = name
      end
    end
  end

  self.object_id_by_thob = {}
  for _, object_type in ipairs(self.object_types) do
    self.object_id_by_thob[object_type.thob] = object_type.id
  end
  self:makeAvailableStaff(0)
  self:calculateSpawnTiles()

  -- Next Events dates
  -- emergencies
  -- The emergency control level data starts with an array of 0
  self.next_emergency_no = 0
  self:nextEmergency()

  -- vip
  self.next_vip_date = self:_generateNextVipDate()

  -- earthquakes
  -- current_map_earthquakes is a counter that tracks which number of earthquake
  -- we are currently on in maps which have information for earthquakes in them
  self.current_map_earthquake = 0
  self:nextEarthquake()

  -- Set initial spawn rate in people per month.
  -- Assumes that the first entry is always the first month.
  self.spawn_rate = self.map.level_config.popn[0].Change
  self.monthly_spawn_increase = self.spawn_rate

  self.spawn_hours = {}
  self.spawn_dates = {}
  self:updateSpawnDates()

  self.cheat_announcements = {
    "cheat001.wav", "cheat002.wav", "cheat003.wav",
  }

  self:gameLog("Created game with savegame version " .. self.savegame_version .. ".")
end

--! Register key shortcuts for controlling the world (game speed, etc.)
function World:setUI(ui)
  self.ui = ui

  self.ui:addKeyHandler("ingame_pause", self, self.pauseOrUnpause, "Pause")
  self.ui:addKeyHandler("ingame_gamespeed_slowest", self, self.setSpeed, "Slowest")
  self.ui:addKeyHandler("ingame_gamespeed_slower", self, self.setSpeed, "Slower")
  self.ui:addKeyHandler("ingame_gamespeed_normal", self, self.setSpeed, "Normal")
  self.ui:addKeyHandler("ingame_gamespeed_max", self, self.setSpeed, "Max speed")
  self.ui:addKeyHandler("ingame_gamespeed_thensome", self, self.setSpeed, "And then some more")

  self.ui:addKeyHandler("ingame_zoom_in", self, self.adjustZoom,  1)
  self.ui:addKeyHandler("ingame_zoom_in_more", self, self.adjustZoom, 5)
  self.ui:addKeyHandler("ingame_zoom_out", self, self.adjustZoom, -1)
  self.ui:addKeyHandler("ingame_zoom_out_more", self, self.adjustZoom, -5)
  self.ui:addKeyHandler("ingame_reset_zoom", self, self.resetZoom)
end

function World:adjustZoom(delta)
  local scr_w = self.ui.app.config.width
  local factor = self.ui.app.config.zoom_speed
  local virtual_width = scr_w / (self.ui.zoom_factor or 1)

  -- The modifier is a normal distribution to make it more difficult to zoom at the extremes
  local modifier = math.exp(-((self.ui.zoom_factor - 1) ^ 2) / 2) / math.sqrt(2 * math.pi)

  if modifier < 0.05 or modifier > 1 then
    modifier = 0.05
  end

  virtual_width = virtual_width - delta * factor * modifier
  if virtual_width < 200 then
    return false
  end

  return self.ui:setZoom(scr_w / virtual_width)
end

function World:resetZoom()
  return self.ui:setZoom(1)
end

--! Initialize the game level (available diseases, winning conditions).
--!param app Game application.
--!param avail_rooms (list) Available rooms in the level.
function World:initLevel(app, avail_rooms)
  local existing_rooms = {}
  for _, avail_room in ipairs(avail_rooms) do
    existing_rooms[avail_room.room.id] = true
  end

  -- Determine available diseases
  self.available_diseases = {}
  local level_config = self.map.level_config
  local visual = level_config.visuals
  local non_visual = level_config.non_visuals
  for _, disease in ipairs(app.diseases) do
    if not disease.pseudo then
      local vis_id = disease.visuals_id
      local nonvis_id = disease.non_visuals_id

      local vis = 1
      if visual and (visual[vis_id] or non_visual[nonvis_id]) then
        vis = vis_id and visual[vis_id].Value or non_visual[nonvis_id].Value
      end
      if vis ~= 0 then
        for _, room_id in ipairs(disease.treatment_rooms) do
          if existing_rooms[room_id] == nil then
            print("Warning: Removing disease \"" .. disease.id ..
                  "\" due to missing treatment room \"" .. room_id .. "\".")
            vis = 0 -- Missing treatment room, disease cannot be treated. Remove it.
            break
          end
        end
      end
      -- TODO: Where the value is greater that 0 should determine the frequency of the patients
      if vis ~= 0 then
        self.available_diseases[#self.available_diseases + 1] = disease
        self.available_diseases[disease.id] = disease
      end
    end
  end
  if #self.available_diseases == 0 and not self.map.level_number == "MAP EDITOR" then
    -- No diseases are needed if we're actually in the map editor!
    print("Warning: This level does not contain any diseases")
  end

  self:determineWinningConditions()
end

function World:toggleInformation()
  self.room_information_dialogs = not self.room_information_dialogs
end

--! Load goals to win and lose from the map, and store them in 'self.goals'.
--! Also set 'self.winning_goal_count'.
function World:determineWinningConditions()
  local winning_goal_count = 0
  -- No conditions if in free build mode!
  if self.free_build_mode then
    self.goals = {}
    self.winning_goal_count = winning_goal_count
    return
  end
  -- Determine winning and losing conditions
  local world_goals = {}

  -- There might be no winning criteria (i.e. the demo), then
  -- we don't have to worry about the progress report dialog
  -- since it doesn't exist anyway.
  local win = self.map.level_config.win_criteria
  if win then
    for _, values in pairs(win) do
      if values.Criteria ~= 0 then
        winning_goal_count = winning_goal_count + 1
        local crit_name = self.level_criteria[values.Criteria].name
        world_goals[crit_name] = {
          name = crit_name,
          win_value = values.Value,
          boundary = values.Bound,
          criterion = values.Criteria,
          max_min_win = values.MaxMin,
          group = values.Group,
          number = winning_goal_count,
        }
        world_goals[#world_goals + 1] = world_goals[crit_name]
      end
    end
  end
  -- Likewise there might be no losing criteria (i.e. the demo)
  local lose = self.map.level_config.lose_criteria
  if lose then
    for _, values in pairs(lose) do
      if values.Criteria ~= 0 then
        local crit_name = self.level_criteria[values.Criteria].name
        if not world_goals[crit_name] then
          world_goals[crit_name] = {number = #world_goals + 1, name = crit_name}
          world_goals[#world_goals + 1] = world_goals[crit_name]
        end
        world_goals[crit_name].lose_value = values.Value
        world_goals[crit_name].boundary = values.Bound
        world_goals[crit_name].criterion = values.Criteria
        world_goals[crit_name].max_min_lose = values.MaxMin
        world_goals[crit_name].group = values.Group
        world_goals[world_goals[crit_name].number].lose_value = values.Value
        world_goals[world_goals[crit_name].number].boundary = values.Bound
        world_goals[world_goals[crit_name].number].criterion = values.Criteria
        world_goals[world_goals[crit_name].number].max_min_lose = values.MaxMin
        world_goals[world_goals[crit_name].number].group = values.Group
      end
    end
  end

  -- Order the criteria (some icons in the progress report shouldn't be next to each other)
  table.sort(world_goals, function(a,b) return a.criterion < b.criterion end)
  self.goals = world_goals
  self.winning_goal_count = winning_goal_count
end

--! Find the rooms available at the level.
--!return (list) Available rooms, with discovery state at start, and build_cost.
function World:getAvailableRooms()
  local avail_rooms = {}

  local cfg_objects = self.map.level_config.objects
  local cfg_rooms = self.map.level_config.rooms
  for _, room in ipairs(TheApp.rooms) do
    -- Add build cost based on level files for all rooms.
    -- For now, sum it up so that the result is the same as before.
    -- TODO: Change the whole build process so that this value is
    -- the room cost only? (without objects)
    local build_cost = cfg_rooms[room.level_config_id].Cost
    local available = true
    local is_discovered = true
    -- Make sure that all objects needed for this room are available
    for name, no in pairs(room.objects_needed) do
      local spec = cfg_objects[TheApp.objects[name].thob]
      if spec.AvailableForLevel == 0 then
        -- It won't be possible to build this room at all on the level.
        available = false
      elseif spec.StartAvail == 0 then
        -- Ok, it will be available at some point just not from the beginning.
        is_discovered = false
      end
      -- Add cost for this object.
      build_cost = build_cost + cfg_objects[TheApp.objects[name].thob].StartCost * no
    end

    if available then
      avail_rooms[#avail_rooms + 1] = {room = room, is_discovered = is_discovered, build_cost = build_cost}
    end
  end
  return avail_rooms
end

--! Get the hospital controlled by the (single) player.
--!return (Hospital) The hospital controlled by the (single) player.
function World:getLocalPlayerHospital()
  -- NB: UI code can get the hospital to use via ui.hospital
  -- TODO: Make this work in multiplayer?
  return self.hospitals[1]
end

--! Identify the tiles on the map suitable for spawning `Humanoid`s from.
function World:calculateSpawnTiles()
  self.spawn_points = {}
  local w, h = self.map.width, self.map.height
  local directions = {
    {direction = "north", origin = {1, 1}, step = { 1,  0}},
    {direction = "east" , origin = {w, 1}, step = { 0,  1}},
    {direction = "south", origin = {w, h}, step = {-1,  0}},
    {direction = "west" , origin = {1, h}, step = { 0, -1}},
  }
  for _, edge in ipairs(directions) do
    -- Find all possible spawn points on the edge
    local xs = {}
    local ys = {}
    local x, y = edge.origin[1], edge.origin[2]
    repeat
      if self.pathfinder:isReachableFromHospital(x, y) then
        xs[#xs + 1] = x
        ys[#ys + 1] = y
      end
      x = x + edge.step[1]
      y = y + edge.step[2]
    until x < 1 or x > w or y < 1 or y > h

    -- Choose at most 8 points for the edge
    local num = math.min(8, #xs)
    for i = 1, num do
      local index = math.floor((i - 0.5) / num * #xs + 1)
      self.spawn_points[#self.spawn_points + 1] = {x = xs[index], y = ys[index], direction = edge.direction}
    end
  end
end

--! Function to determine whether a given disease is available for new patients.
--!param self (World) World object.
--!param disease (disease) Disease to test.
--!param hospital (Hospital) Hospital that needs a new patient.
--!return (boolean) Whether the disease is usable for new spawned patients.
local function isDiseaseUsableForNewPatient(self, disease, hospital)
  if disease.only_emergency then return false end
  if not disease.visuals_id then return true end

  -- level files can delay visuals to a given month
  -- and / or until a given number of patients have arrived
  local level_config = self.map.level_config
  local hold_visual_months = level_config.gbv.HoldVisualMonths
  local hold_visual_peep_count = level_config.gbv.HoldVisualPeepCount

  -- if the month is greater than either of these values then visuals will not appear in the game
  if (hold_visual_months and hold_visual_months > self.game_date:monthOfGame()) or
      (hold_visual_peep_count and hold_visual_peep_count > hospital.num_visitors) then
    return false
  end

  -- The value against #visuals_available determines from which month a disease can appear.
  -- 0 means it can show up anytime.
  return level_config.visuals_available[disease.visuals_id].Value < self.game_date:monthOfGame()
end

--! Spawn a patient from a spawn point for the given hospital.
--!param hospital (Hospital) Hospital that the new patient should visit.
--!return (Patient entity) The spawned patient, or 'nil' if no patient spawned.
function World:spawnPatient(hospital)
  if not hospital then
    hospital = self:getLocalPlayerHospital()
  end

  -- The level might not contain any diseases
  if #self.available_diseases < 1 then
    self.ui:addWindow(UIInformation(self.ui, {"There are no diseases on this level! Please add some to your level."}))
    return
  end
  if #self.spawn_points == 0 then
    self.ui:addWindow(UIInformation(self.ui, {"Could not spawn patient because no spawn points are available. Please place walkable tiles on the edge of your level."}))
    return
  end

  if not hospital:hasStaffedDesk() then return nil end

  -- Construct disease, take a random guess first, as a quick clear-sky attempt.
  local disease = self.available_diseases[math.random(1, #self.available_diseases)]
  if not isDiseaseUsableForNewPatient(self, disease, hospital) then
    -- Lucky shot failed, do a proper calculation.
    local usable_diseases = {}
    for _, d in ipairs(self.available_diseases) do
      if isDiseaseUsableForNewPatient(self, d, hospital) then
        usable_diseases[#usable_diseases + 1] = d
      end
    end

    if #usable_diseases == 0 then return nil end

    disease = usable_diseases[math.random(1, #usable_diseases)]
  end

  -- Construct patient.
  local spawn_point = self.spawn_points[math.random(1, #self.spawn_points)]
  local patient = self:newEntity("Patient", 2)
  patient:setDisease(disease)
  patient:setNextAction(SpawnAction("spawn", spawn_point))
  patient:setHospital(hospital)
  return patient
end

--A VIP is invited (or he invited himself) to the player hospital.
--!param name Name of the VIP
function World:spawnVIP(name)
  local hospital = self:getLocalPlayerHospital()

  local vip = self:newEntity("Vip", 2)
  vip:setType("VIP")
  vip.name = name
  vip.enter_deaths = hospital.num_deaths
  vip.enter_visitors = hospital.num_visitors
  vip.enter_cures = hospital.num_cured
  vip.enter_patients = #hospital.patients
  -- VIP's room visit chance is 50% if total rooms in hospital is less than 80 (makes a math.random with 0 and 1 possibilities).
  -- Else decided by total rooms / 40 (0, 1, 2 [33%]; 0, 1, 2, 3 [25%] etc)
  local rooms_threshold = 79
  if #self.rooms > rooms_threshold then
    vip.room_visit_chance = math.floor(#self.rooms / 40)
  end

  local spawn_point = self.spawn_points[math.random(1, #self.spawn_points)]
  vip:setNextAction(SpawnAction("spawn", spawn_point))
  vip:setHospital(hospital)
  vip:updateDynamicInfo()
  hospital.announce_vip = hospital.announce_vip + 1
  vip:queueAction(SeekReceptionAction())
end

--! Perform actions to simulate an active earthquake.
function World:tickEarthquake()
  if self:isCurrentSpeed("Pause") then return end

  -- check if this is the day that the earthquake is supposed to stop
  if self.next_earthquake.remaining_damage == 0 then
    self.next_earthquake.active = false
    self.ui:endShakeScreen()
    -- if the earthquake measured more than 7 on the richter scale, tell the user about it
    if self.next_earthquake.size > 7 then
      self.ui.adviser:say(_A.earthquake.ended:format(math.floor(self.next_earthquake.size)))
    end

    -- set up the next earthquake date
    self:nextEarthquake()
  else
    local announcements = {
      "quake001.wav", "quake002.wav", "quake003.wav", "quake004.wav",
    }

    -- start of warning quake
    if self.next_earthquake.warning_timer == earthquake_warning_period then
      self.ui:beginShakeScreen(0.2)
      self.ui:playAnnouncement(announcements[math.random(1, #announcements)], AnnouncementPriority.Critical)
    end

    -- end of warning quake
    if self.next_earthquake.warning_timer >= earthquake_warning_period - earthquake_warning_length and
        self.next_earthquake.warning_timer - self.hours_per_tick < earthquake_warning_period - earthquake_warning_length then
      self.ui:endShakeScreen()
    end

    if self.next_earthquake.warning_timer > 0 then
      self.next_earthquake.warning_timer = self.next_earthquake.warning_timer - self.hours_per_tick
      -- nothing more to do during inactive warning period
      if self.next_earthquake.warning_timer < earthquake_warning_period - earthquake_warning_length then
        return
      end

      -- start of real earthquake
      if self.next_earthquake.warning_timer <= 0 then
        self.ui:playAnnouncement(announcements[math.random(1, #announcements)], AnnouncementPriority.Critical)
      end
    end

    -- All earthquakes start and end small (small earthquakes never become
    -- larger), so when there has been less than 2 damage applied or only
    -- 2 damage remaining to be applied, move the screen with less
    -- intensity than otherwise.
    if self.next_earthquake.remaining_damage <= 2 or
        self.next_earthquake.size - self.next_earthquake.remaining_damage <= 2 then
      self.ui:beginShakeScreen(0.5)
    else
      self.ui:beginShakeScreen(1)
    end

    -- Play the earthquake sound. It has different names depending on language used though.
    if TheApp.audio:soundExists("quake2.wav") then
      self.ui:playSound("quake2.wav")
    else
      self.ui:playSound("quake.wav")
    end

    -- do not continue to damage phase while in a warning quake
    if self.next_earthquake.warning_timer > 0 then
      return
    end

    self.next_earthquake.damage_timer = self.next_earthquake.damage_timer - self.hours_per_tick
    if self.next_earthquake.damage_timer <= 0 then
      for _, room in pairs(self.rooms) do
        for object, _ in pairs(room.objects) do
          if object.strength then
            object:machineUsed(room)
          end
        end
      end

      self.next_earthquake.remaining_damage = self.next_earthquake.remaining_damage - 1
      self.next_earthquake.damage_timer = self.next_earthquake.damage_timer + earthquake_damage_time
    end

    local hospital = self:getLocalPlayerHospital()
    -- loop through the patients and allow the possibility for them to fall over
    for _, patient in ipairs(hospital.patients) do
      if not patient.in_room and patient.falling_anim then

        -- make the patients fall

        -- jpirie: this is currently disabled. Calling this function
        -- really screws up the action queue, sometimes the patients
        -- end up with nil action queues, and sometimes the resumed
        -- actions throw exceptions. Also, patients in the hospital
        -- who have not yet found reception throw exceptions after
        -- they visit reception. Some debugging needed here to get
        -- this working.

        -- patient:falling()
      end
    end
  end
end

--! Enable or disable salary raise events.
--!param mode (boolean) If true, do not create salary raise events.
function World:debugDisableSalaryRaise(mode)
  self.debug_disable_salary_raise = mode
end

local staff_to_make = {
  {class = "Doctor",       name = "doctor",       conf = "Doctors"      },
  {class = "Nurse",        name = "nurse",        conf = "Nurses"       },
  {class = "Handyman",     name = "handyman",     conf = "Handymen"     },
  {class = "Receptionist", name = "receptionist", conf = "Receptionists"},
}
function World:makeAvailableStaff(month)
  local conf_entry = 0
  local cfg_staff_levels = self.map.level_config.staff_levels
  while cfg_staff_levels[conf_entry + 1] and cfg_staff_levels[conf_entry + 1].Month <= month do
    conf_entry = conf_entry + 1
  end
  self.available_staff = {}
  for _, info in ipairs(staff_to_make) do
    local num
    local ind = conf_entry
    while not num do
      assert(ind >= 0, "Staff amount " .. info.conf .. " not existent (should at least be given by base_config).")
      num = cfg_staff_levels[ind][info.conf]
      ind = ind - 1
    end
    local group = {}
    for i = 1, num do
      group[i] = StaffProfile(self, info.class, _S.staff_class[info.name])
      group[i]:randomise(month)
    end
    self.available_staff[info.class] = group
  end
end

--[[ Register a callback for when `Humanoid`s enter or leave a given tile.
! Note that only one callback may be registered to each tile.
!param x (integer) The 1-based X coordinate of the tile to monitor.
!param y (integer) The 1-based Y coordinate of the tile to monitor.
!param object (Object) Something with an `onOccupantChange` method, which will
be called whenever a `Humanoid` enters or leaves the given tile. The method
will receive one argument (after `self`), which will be `1` for an enter event
and `-1` for a leave event.
]]
function World:notifyObjectOfOccupants(x, y, object)
  local idx = (y - 1) * self.map.width + x
  self.objects_notify_occupants[idx] =  object or nil
end

function World:getObjectToNotifyOfOccupants(x, y)
  local idx = (y - 1) * self.map.width + x
  return self.objects_notify_occupants[idx]
end

--! Place objects from a map file onto the map.
--!param objects Objects to place.
function World:createMapObjects(objects)
  self.delayed_map_objects = {}

  for _, object in ipairs(objects) do
    self:_createMapObject(object)
  end
end

local flag_cache = {}
--! Internal function for placing an object from the map file.
--!param object Object to place.
function World:_createMapObject(object)
  local x, y, thob, flags = unpack(object)
  local object_id = self.object_id_by_thob[thob]
  if not object_id then
    print("Warning: Map contained object with unrecognised THOB (" .. thob
        .. ") at " .. x .. "," .. y)
    return
  end

  local object_type = self.object_types[object_id]
  if not object_type or not object_type.supports_creation_for_map then
    print("Warning: Unable to create map object " .. object_id .. " at "
        .. x .. "," .. y)
    return
  end

  local map = self.map.th
  local parcel = map:getCellFlags(x, y, flag_cache).parcelId
  if parcel ~= 0 and map:getPlotOwner(parcel) == 0 then
    -- Delay making objects which are on plots which haven't been purchased yet
    self.delayed_map_objects[{object_id, x, y, flags, "map object"}] = parcel

  else
    self:newObject(object_id, x, y, flags, "map object")
  end
end

--! Change owner of a plot.
--!param parcel (int) Plot to change.
--!param owner (int) New owner (may be 0).
function World:setPlotOwner(parcel, owner)
  self.map:setPlotOwner(parcel, owner)
  if owner ~= 0 and self.delayed_map_objects then
    for info, p in pairs(self.delayed_map_objects) do
      if p == parcel then
        self:newObject(unpack(info))
        self.delayed_map_objects[info] = nil
      end
    end
  end
  self.map.th:updateShadows()
end

function World:getAnimLength(anim)
  return self.animation_manager:getAnimLength(anim)
end

-- Register a function to be called whenever a room has been deactivated (crashed or edited).
--!param callback (function) A function taking one argument: a `Room`.
function World:registerRoomRemoveCallback(callback)
  self.room_remove_callbacks[callback] = true
end

-- Unregister a function from being called whenever a room has been deactivated (crashed or edited).
--!param callback (function) A function previously passed to
-- `registerRoomRemoveCallback`.
function World:unregisterRoomRemoveCallback(callback)
  self.room_remove_callbacks[callback] = nil
end

function World:newRoom(x, y, w, h, room_info, ...)
  local id = #self.rooms + 1
  -- Note: Room IDs will be unique, but they may not form continuous values
  -- from 1, as IDs of deleted rooms may not be re-issued for a while
  local class = room_info.class and _G[room_info.class] or Room
  local hospital = self:getHospital(x, y)
  local room = class(x, y, w, h, id, room_info, self, hospital, ...)

  self.rooms[id] = room
  self:clearCaches()
  return room
end

--! Called when a room has been completely built and is ready to use.
--!param room (Room) The new room.
function World:markRoomAsBuilt(room)
  room:roomFinished()
  local diag_disease = self.hospitals[1].disease_casebook["diag_" .. room.room_info.id]
  if diag_disease and not diag_disease.discovered then
    self.hospitals[1].disease_casebook["diag_" .. room.room_info.id].discovered = true
  end
  for _, entity in ipairs(self.entities) do
    if entity.notifyNewRoom then
      entity:notifyNewRoom(room)
    end
  end
end

--! Called when a room has been deactivated (crashed or edited)
function World:notifyRoomRemoved(room)
  self.dispatcher:dropFromQueue(room)
  for callback in pairs(self.room_remove_callbacks) do
    callback(room)
  end
end

--! Clear all internal caches which are dependent upon map state / object position
function World:clearCaches()
  self.idle_cache = {}
end

function World:getWallIdFromBlockId(block_id)
  -- Remove the transparency flag if present.
  if self.ui.transparent_walls then
    block_id = block_id - 1024
  end
  return self.wall_id_by_block_id[block_id]
end

function World:getWallSetFromBlockId(block_id)
  -- Remove the transparency flag if present.
  if self.ui.transparent_walls then
    block_id = block_id - 1024
  end
  return self.wall_set_by_block_id[block_id]
end

function World:getWallDirFromBlockId(block_id)
  -- Remove the transparency flag if present.
  if self.ui.transparent_walls then
    block_id = block_id - 1024
  end
  return self.wall_dir_by_block_id[block_id]
end

local month_length = {
  31, -- Jan
  28, -- Feb (29 in leap years, but TH doesn't have leap years)
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

function World:getDate()
  return self.game_date:monthOfYear(), self.game_date:dayOfMonth()
end

-- Game speeds. The second value is the number of world clicks that pass for each
-- in-game tick and the first is the number of hours to progress when this
-- happens.
local tick_rates = {
  ["Pause"]              = {0, 1},
  ["Slowest"]            = {1, 9},
  ["Slower"]             = {1, 5},
  ["Normal"]             = {1, 3},
  ["Max speed"]          = {1, 1},
  ["And then some more"] = {3, 1},
  ["Speed Up"]           = {4, 1},
}

function World:speedUp()
  self:setSpeed("Speed Up")
end

function World:previousSpeed()
  if self:isCurrentSpeed("Speed Up") then
    self:setSpeed(self.prev_speed)
  end
end

-- Return if the selected speed the same as the current speed.
function World:isCurrentSpeed(speed)
  local numerator, denominator = unpack(tick_rates[speed])
  return self.hours_per_tick == numerator and self.tick_rate == denominator
end

-- Return the name of the current speed, relating to a key in tick_rates.
function World:getCurrentSpeed()
  for name, rate in pairs(tick_rates) do
    if rate[1] == self.hours_per_tick and rate[2] == self.tick_rate then
      return name
    end
  end
end

-- Set the (approximate) number of seconds per tick.
--!param speed (string) One of: "Pause", "Slowest", "Slower", "Normal",
-- "Max speed", or "And then some more".
function World:setSpeed(speed)
  if self:isCurrentSpeed(speed) then
    return
  end
  if speed == "Pause" or self.system_pause then
    -- stop screen shaking if there was an earthquake in progress
    if self.next_earthquake.active then
      self.ui:endShakeScreen()
    end
    -- By default actions are not allowed when the game is paused.
    self.user_actions_allowed = TheApp.config.allow_user_actions_while_paused
  elseif self:getCurrentSpeed() == "Pause" then
    self.user_actions_allowed = true
  end

  local currentSpeed = self:getCurrentSpeed()
  if currentSpeed ~= "Pause" and currentSpeed ~= "Speed Up" then
    self.prev_speed = self:getCurrentSpeed()
  end

  local was_paused = currentSpeed == "Pause"
  local numerator, denominator = unpack(tick_rates[speed])
  self.hours_per_tick = numerator
  self.tick_rate = denominator

  if was_paused then
    TheApp.audio:onEndPause()
  end

  -- Set the blue filter according to whether the user can build or not.
  TheApp.video:setBlueFilterActive(not self.user_actions_allowed)
  return false
end

function World:isPaused()
  return self:isCurrentSpeed("Pause")
end

--! Dedicated function to allow unpausing by pressing 'p' again
function World:pauseOrUnpause()
  if self:isSystemPauseActive() then return end -- System pause takes precedence
  if not self:isCurrentSpeed("Pause") then
    self:setSpeed("Pause")
  elseif self.prev_speed then
    self:setSpeed(self.prev_speed)
  end
end

--! Sets the system_pause parameter
--!param state (bool)
function World:setSystemPause(state)
  self.system_pause = state
end

--! Reports the system pause status
--!return (bool) true is system pause is active, else false
function World:isSystemPauseActive()
  return self.system_pause
end

--! Function to check if player can perform actions when paused
--!return (bool) Returns true if player hasn't allowed editing while paused
function World:isUserActionProhibited()
  if self:isSystemPauseActive() then return true end
  return self:isCurrentSpeed("Pause") and not self.user_actions_allowed
end

-- Outside (air) temperatures based on climate data for Oxford, taken from
-- Wikipedia. For scaling, 0 degrees C becomes 0 and 50 degrees C becomes 1
local outside_temperatures = {
   4.1  / 50, -- January
   4.4  / 50, -- February
   6.3  / 50, -- March
   8.65 / 50, -- April
  11.95 / 50, -- May
  15    / 50, -- June
  16.95 / 50, -- July
  16.55 / 50, -- August
  14.15 / 50, -- September
  10.5  / 50, -- October
   6.8  / 50, -- November
   4.75 / 50, -- December
}

--! World ticks are translated to game ticks (or hours) depending on the
-- current speed of the game. There are 50 hours in a TH day.
function World:onTick()
  if self.map.level_number == "MAP EDITOR" then return end

  if self.tick_timer == 0 then
    if self.autosave_next_tick then
      self.autosave_next_tick = nil
      local pathsep = package.config:sub(1, 1)
      local dir = TheApp.savegame_dir
      if not dir:sub(-1, -1) == pathsep then
        dir = dir .. pathsep
      end
      if not lfs.attributes(dir .. "Autosaves", "modification") then
        lfs.mkdir(dir .. "Autosaves")
      end
      local status, err = pcall(TheApp.save, TheApp, dir .. "Autosaves" .. pathsep .. "Autosave" .. self.game_date:monthOfYear() .. ".sav")
      if not status then
        print("Error while autosaving game: " .. err)
      end
    end
    if self.game_date == Date() then
      if self.ui.start_tutorial then
        self.ui:addWindow(UIWatch(self.ui, "tutorial"))
      else
        self.ui:addWindow(UIWatch(self.ui, "initial_opening"))
        self.ui:showBriefing()
      end
    end
    self.tick_timer = self.tick_rate

    -- if an earthquake is supposed to be going on, call the earthquake function
    if self.next_earthquake.active then
      self:tickEarthquake()
    end

    local new_game_date = self.game_date:plusHours(self.hours_per_tick)
    -- End of day/month/year
    if self.game_date:dayOfMonth() ~= new_game_date:dayOfMonth() then
      for _, hospital in ipairs(self.hospitals) do
        hospital:onEndDay()
      end
      self:onEndDay()
      if self.game_date:isLastDayOfMonth() then
        for _, hospital in ipairs(self.hospitals) do
          hospital:onEndMonth()
        end
        -- Let the hospitals do what they need to do at end of month first.
        if self:onEndMonth() then
          -- Bail out as the game has already been ended.
          return
        end

        if self.game_date:isLastDayOfYear() then
          -- It is crucial that the annual report gets to initialize before onEndYear is called.
          -- Yearly statistics are reset there.
          self.ui:addWindow(UIAnnualReport(self.ui, self))
          self:onEndYear()
        end
      end
    end
    self.game_date = new_game_date

    for i = 1, self.hours_per_tick do
      self.anims:tick()
      for _, hospital in ipairs(self.hospitals) do
        hospital:tick()
      end
      -- A patient might arrive to the player hospital.
      -- TODO: Multiplayer support.
      local spawn_count = self.spawn_hours[self.game_date:hourOfDay() + i - 1]
      if spawn_count and self.hospitals[1].opened then
        for _ = 1, spawn_count do
          self:spawnPatient()
        end
      end
      for _, entity in ipairs(self.entities) do
        if entity.ticks then
          self.current_tick_entity = entity
          entity:tick()
        end
      end
      self.current_tick_entity = nil
      self.map:onTick()
      self.map.th:updateTemperatures(outside_temperatures[self.game_date:monthOfYear()],
          0.25 + self.hospitals[1].heating.radiator_heat * 0.3)
      if self.ui then
        self.ui:onWorldTick()
      end
      self.dispatcher:onTick()
    end
  end
  if self.hours_per_tick > 0 and self.floating_dollars then
    for obj in pairs(self.floating_dollars) do
      obj:tick()
      if obj:isDead() then
        obj:setTile(nil)
        self.floating_dollars[obj] = nil
      end
    end
  end
  self.tick_timer = self.tick_timer - 1
end

function World:setEndMonth()
  local previous_date = self.game_date
  local first_day_of_next_month = Date(self.game_date:year(), self.game_date:monthOfYear() + 1)
  self.game_date = first_day_of_next_month:plusHours(-1)
  -- Has the date jump caused an emergency to be missed?
  if self:wasEmergencySkipped(previous_date, self.game_date) then
    self:nextEmergency()
  end
end

function World:setEndYear()
  local previous_date = self.game_date
  local first_day_of_next_year = Date(self.game_date:year() + 1)
  self.game_date = first_day_of_next_year:plusHours(-1)
  -- Has the date jump caused an emergency to be missed?
  if self:wasEmergencySkipped(previous_date, self.game_date) then
    self:nextEmergency()
  end
end

--! Checks if a time jump caused an emergency to be missed
--!param prev_date (Date) Original game date before jump
--!param new_date (Date) Game date after time jump
--!return (boolean) true if emergency has been skipped
function World:wasEmergencySkipped(prev_date, new_date)
  local emer_date = self.next_emergency_date
  return emer_date and emer_date < new_date and prev_date < emer_date
end


-- Called immediately prior to the ingame day changing.
function World:onEndDay()
  local local_hospital = self:getLocalPlayerHospital()
  for _, entity in ipairs(self.entities) do
    if entity.ticks and class.is(entity, Humanoid) then
      self.current_tick_entity = entity
      entity:tickDay()
    elseif class.is(entity, Plant) then
      entity:tickDay()
    end
  end
  self.current_tick_entity = nil

  --check if it's time for a VIP visit
  if self.game_date:isSameDay(self.next_vip_date) then
    if #self.rooms > 0 and local_hospital:hasStaffedDesk() then
      local_hospital:createVip()
    else
      self.next_vip_date = self:_generateNextVipDate()
    end
  end

  -- check if it's time for an earthquake, and the user is at least on level 5
  if self.game_date:monthOfGame() == self.next_earthquake.start_month and
      self.game_date:dayOfMonth() == self.next_earthquake.start_day then
    -- warn the user that an earthquake is on the way
    self.next_earthquake.active = true
  end

  -- Maybe it's time for an emergency?
  if self.game_date:monthOfGame() == self.next_emergency_month and
      self.game_date:dayOfMonth() == self.next_emergency_day then
    -- Postpone it if anything clock related is already underway.
    if self.ui:getWindow(UIWatch) then
      self.next_emergency_month = self.next_emergency_month + 1
      local month_of_year = 1 + ((self.next_emergency_month - 1) % 12)
      self.next_emergency_day = math.random(1, Date(1, month_of_year):lastDayOfMonth())
    else
      -- Do it only for the player hospital for now. TODO: Multiplayer
      local control = self.map.level_config.emergency_control
      if control[0].Mean or control[0].Random then
        -- The level uses random emergencies, so just create one.
        local_hospital:createEmergency()
      else
        local next_em = self.next_emergency
        -- Find out which disease the emergency patients have.
        local disease
        for _, dis in ipairs(self.available_diseases) do
          if dis.expertise_id == next_em.Illness then
            disease = dis
            break
          end
        end
        if not disease then
          -- Unknown disease! Create a random one instead.
          local_hospital:createEmergency()
        else
          local emergency = {
            disease = disease,
            victims = math.random(next_em.Min, next_em.Max),
            bonus = next_em.Bonus,
            percentage = next_em.PercWin/100,
            killed_emergency_patients = 0,
            cured_emergency_patients = 0,
          }
          local_hospital:createEmergency(emergency)
        end
      end
    end
  end
  -- Any patients tomorrow?
  self.spawn_hours = {}
  local day = self.game_date:dayOfMonth()
  if self.spawn_dates[day] then
    for _ = 1, self.spawn_dates[day] do
      local hour = math.random(1, Date.hoursPerDay())
      self.spawn_hours[hour] = self.spawn_hours[hour] and self.spawn_hours[hour] + 1 or 1
    end
  end
  -- TODO: Do other regular things? Such as checking if any room needs
  -- staff at the moment and making plants need water.
end

function World:checkIfGameWon()
  for i, _ in ipairs(self.hospitals) do
    local res = self:checkWinningConditions(i)
    if res.state == "win" then
      self:winGame(i)
    end
  end
end

-- Called immediately prior to the ingame month changing.
-- returns true if the game was killed due to the player losing
function World:onEndMonth()
  local local_hospital = self:getLocalPlayerHospital()
  local_hospital.population = 0.25
  if self.game_date:monthOfGame() >= self.map.level_config.gbv.AllocDelay then
    local_hospital.population = local_hospital.population * self:getReputationImpact(local_hospital)
  end

  -- Also possibly change world spawn rate according to the level configuration.
  local index = 0
  local popn = self.map.level_config.popn
  while popn[index] do
    if popn[index].Month == self.game_date:monthOfGame() then
      self.monthly_spawn_increase = popn[index].Change
      break
    end
    index = index + 1
  end
  -- Now set the new spawn rate
  self.spawn_rate = self.spawn_rate + self.monthly_spawn_increase
  self:updateSpawnDates()

  self:makeAvailableStaff(self.game_date:monthOfGame())
  self.autosave_next_tick = true
  for _, entity in ipairs(self.entities) do
    if entity.checkForDeadlock then
      self.current_tick_entity = entity
      entity:checkForDeadlock()
    end
  end
  self.current_tick_entity = nil
end

-- Called when a month ends. Decides on which dates patients arrive
-- during the coming month.
function World:updateSpawnDates()
  local local_hospital = self:getLocalPlayerHospital()
  -- Set dates when people arrive
  local no_of_spawns = math.n_random(self.spawn_rate, 2)
  -- If Roujin's Challenge is on, override spawn rate
  if local_hospital.spawn_rate_cheat then
    no_of_spawns = 40
  end
  -- Use ceil so that at least one patient arrives (unless population = 0)
  no_of_spawns = math.ceil(no_of_spawns*self:getLocalPlayerHospital().population)
  self.spawn_dates = {}
  for _ = 1, no_of_spawns do
    -- We are interested in the next month, pick days from it at random.
    local day = math.random(1, self.game_date:lastDayOfMonth())
    self.spawn_dates[day] = self.spawn_dates[day] and self.spawn_dates[day] + 1 or 1
  end
end

--! Computes the impact of hospital reputation on the spawn rate.
--! The relation between reputation and its impact is linear.
--! Returns a percentage (as a float):
--!     1% if reputation < 253
--!    60% if reputation == 400
--!   100% if reputation == 500
--!   140% if reputation == 600
--!   180% if reputation == 700
--!   300% if reputation == 1000
--!param hospital (hospital): the hospital used to compute the
--! reputation impact
function World:getReputationImpact(hospital)
  local result = 1 + ((hospital.reputation - 500) / 250)

  -- The result must be positive
  if result <= 0 then
    return 0.01
  else
    return result
  end
end

-- Called when it is time to determine when the next emergency should happen
function World:nextEmergency()
  local control = self.map.level_config.emergency_control
  -- Does this level use random emergencies?
  if control[0].Random or control[0].Mean then
    self:scheduleRandomEmergency(control)
    return
  end
  repeat
    local emer_num = self.next_emergency_no
    -- Account for missing Level 3 emergency[5]
    if not control[emer_num] and control[emer_num + 1] then
      emer_num = emer_num + 1
      self.next_emergency_no = emer_num
    end
    local emergency = control[emer_num]
    -- No more emergencies?
    if not emergency then
      self.next_emergency_month = 0
      self.next_emergency_date = nil
      self.next_emergency = nil
      return
    end
    self.next_emergency = emergency
    self.next_emergency_no = self.next_emergency_no + 1
  until self:computeNextEmergencyDates(emergency)
end

--! If a level file specifies random emergencies we make the next one as defined by the mean/variance given
--!param control (table) Contains emergency information from level file
function World:scheduleRandomEmergency(control)
  -- Support standard values for mean and variance
  local mean = control[0].Mean or 180
  local variance = control[0].Variance or 30
  -- How many days until next emergency?
  local days = math.round(math.n_random(mean, variance))
  days = days > 1 and days or 1  -- Don't schedule in the past
  local emergency_date = self.game_date:plusDays(days)

  -- Make it the same format as for "controlled" emergencies
  self.next_emergency_month = emergency_date:monthOfGame()
  self.next_emergency_day = emergency_date:dayOfMonth()
  self.next_emergency_date = Date(1, self.next_emergency_month, self.next_emergency_day) -- TODO: Make more use of this
end

--! Generate the dates for the next emergency
--!param emergency The next scheduled emergency to take place
--!return (boolean) true if emergency successfully scheduled
function World:computeNextEmergencyDates(emergency)
  -- Generate the next month and day the emergency should occur at.
  -- Make sure it doesn't happen in the past.
  local start = math.max(emergency.StartMonth, self.game_date:monthOfGame())
  if (emergency.EndMonth < start) then
    return false
  end
  local next_month = math.random(start, emergency.EndMonth)
  self.next_emergency_month = next_month
  local day_start = 1
  if start == emergency.EndMonth then
    day_start = self.game_date:dayOfMonth()
  end
  local day_end = Date(1, next_month):lastDayOfMonth()
  self.next_emergency_day = math.random(day_start, day_end)
  self.next_emergency_date = Date(1, self.next_emergency_month, self.next_emergency_day) -- TODO: Make more use of this
  return self.game_date <= self.next_emergency_date
end

-- Called when it is time to have another VIP
function World:nextVip()
  self.next_vip_date = self:_generateNextVipDate()
end

-- PRIVATE method to generate the next VIP date
function World:_generateNextVipDate()
  -- Support standard values for mean and variance
  local mean = 180
  local variance = 30
  -- How many days until next vip?
  local days = math.round(math.n_random(mean, variance))
  return self.game_date:plusDays(days)
end

-- Called when it is time to have another earthquake
function World:nextEarthquake()
  self.next_earthquake = {}
  self.next_earthquake.active = false

  local level_config = self.map.level_config
  -- check carefully that no value that we are going to use is going to be nil
  if level_config.quake_control and level_config.quake_control[self.current_map_earthquake] and
      level_config.quake_control[self.current_map_earthquake].Severity ~= 0 then
    -- this map has rules to follow when making earthquakes, let's follow them
    local control = level_config.quake_control[self.current_map_earthquake]
    self.next_earthquake.start_month = math.random(control.StartMonth, control.EndMonth)

    -- Month length of the start of the earthquake. From start to finish
    -- earthquakes do not persist for >= a month so we can wrap all days
    -- after the start around the month length unambiguously.
    local eqml = month_length[(self.next_earthquake.start_month % 12) + 1]
    self.next_earthquake.start_day = math.random(1, eqml)

    self.next_earthquake.size = control.Severity
    self.next_earthquake.remaining_damage = self.next_earthquake.size
    self.next_earthquake.damage_timer = earthquake_damage_time
    self.next_earthquake.warning_timer = earthquake_warning_period
    self.current_map_earthquake = self.current_map_earthquake + 1
  end
end

-- Earthquake override from cheat menu
function World:createEarthquake()
  --make sure an earthquake isn't already happening
  if not self.next_earthquake.active then
    self.next_earthquake.start_day = self.game_date:dayOfMonth()
    self.next_earthquake.start_month = self.game_date:monthOfGame()
    if self.next_earthquake.size == nil then
      --forcefully make an earthquake if none left in level file
      self.next_earthquake.size = math.random(1,6) -- above 6 seems disastrous
      self.next_earthquake.remaining_damage = self.next_earthquake.size
      self.next_earthquake.damage_timer = earthquake_damage_time
      self.next_earthquake.warning_timer = earthquake_warning_period
    end
  end
end

--! Checks if all goals have been achieved or if the player has lost.
--! Returns a table that always contains a state string ("win", "lose" or "nothing").
--! If the state is "lose", the table also contains a reason string,
--! which corresponds to the criterion name the player lost to
--! (reputation, balance, percentage_killed) and a number limit which
--! corresponds to the limit the player passed.
--!param player_no The index of the player to check in the world's list of hospitals
function World:checkWinningConditions(player_no)
  -- If there are no goals at all, do nothing.
  if #self.goals == 0 then
    return {state = "nothing"}
  end

  -- Default is to win.
  -- As soon as a goal that doesn't support this is found it is changed.
  local result = {state = "win"}
  local hospital = self.hospitals[player_no]

  -- Go through the goals
  for _, goal in ipairs(self.goals) do
    local current_value = hospital[goal.name]
    -- If max_min is 1 the value must be > than the goal condition.
    -- If 0 it must be < than the goal condition.
    if goal.lose_value then
      local max_min = goal.max_min_lose == 1 and 1 or -1
      -- Is this a minimum/maximum that has been passed?
      -- This is actually not entirely correct. A lose condition
      -- for balance at -1000 will make you lose if you have exactly
      -- -1000 too, but how often does that happen? Probably not more often
      -- than having exactly e.g. 200 in reputation,
      -- which is handled correctly.
      if (current_value - goal.lose_value) * max_min > 0 then
        result.state = "lose"
        result.reason = goal.name
        result.limit = goal.lose_value
        break
      end
    end
    if goal.win_value then
      local max_min = goal.max_min_win == 1 and 1 or -1
      -- Special case for balance, subtract any loans!
      if goal.name == "balance" then
        current_value = current_value - hospital.loan
      end
      -- Is this goal not fulfilled yet?
      if (current_value - goal.win_value) * max_min <= 0 then
        result.state = "nothing"
      end
    end
  end
  return result
end

--! Process that the given player number won the game.
--!param player_no (integer) Number of the player who just won.
function World:winGame(player_no)
  if player_no == 1 then -- Player won. TODO: Needs to be changed for multiplayer
    local text = {}
    local choice_text, choice
    local bonus_rate = math.random(4,9)
    local with_bonus = self.ui.hospital.cheated and 0 or (self.ui.hospital.player_salary * bonus_rate) / 100
    self.ui.hospital.salary_offer = math.floor(self.ui.hospital.player_salary + with_bonus)
    if type(self.map.level_number) == "number" or self.campaign_info then
      text, choice_text, choice = self:getCampaignWinningText(player_no)
    else
      local level_info = TheApp:readLevelFile(self.map.level_number)
      text[1] = _S.letter.dear_player:format(self.hospitals[player_no].name)
      text[2] = level_info.end_praise and level_info.end_praise or _S.letter.custom_level_completed
      text[3] = _S.letter.return_to_main_menu
      choice_text = _S.fax.choices.return_to_main_menu
      choice = "return_to_main_menu"
    end
    local message = {
      {text = text[1]},
      {text = text[2]},
      {text = text[3]},
      choices = {
        {text = choice_text, choice = choice},
        {text = _S.fax.choices.decline_new_level, choice = "stay_on_level"},
      },
    }
    local --[[persistable:world_win_game_message_close_callback]] function callback ()
      local world = self.ui.app.world
      if world then
        world.hospitals[player_no].game_won = false
        if world:isCurrentSpeed("Pause") then
          world:setSpeed(world.prev_speed)
        end
      end
    end
    self.hospitals[player_no].game_won = true
    if self:isCurrentSpeed("Speed Up") then
      self:previousSpeed()
    end
    self.ui.bottom_panel:queueMessage("information", message, nil, 0, 2, callback)
    self.ui.bottom_panel:openLastMessage()
  end
end

--! Finds what text the winning fax should contain, and which choices the player has.
--!param player_no (integer) Which player that will see the message.
--!return (string, string, string) Text to show in the fax, text that accompanies
--!       the "continue"-choice the player has, and whether it is the "return_to_main_menu"
--!       choice or the "accept_new_level" choice.
function World:getCampaignWinningText(player_no)
  local text = {}
  local choice_text, choice
  local hosp = self:getLocalPlayerHospital()
  local repeated_offer = hosp.win_declined
  local has_next = false
  if type(self.map.level_number) == "number" then
    local no = tonumber(self.map.level_number)
    has_next = no < 12 and not TheApp.using_demo_files
    -- Standard letters 1-4:  normal
    -- Standard letters 5-8:  repeated offer
    -- Standard letters 9-12: last level
    local letter_idx = math.random(1, 4) + (not has_next and 8 or repeated_offer and 4 or 0)
    for key, value in ipairs(_S.letter[letter_idx]) do
      text[key] = value
    end
    text[1] = text[1]:format(self.hospitals[player_no].name)
    text[2] = text[2]:format(self.hospitals[player_no].salary_offer)
    text[3] = text[3]:format(_S.level_names[self.map.level_number + 1])
  else
    local campaign_info = self.campaign_info
    local next_level_name
    if campaign_info then
      for i, level in ipairs(campaign_info.levels) do
        if self.map.level_number == level then
          has_next = i < #campaign_info.levels
          if has_next then
            local next_level_info = TheApp:readLevelFile(campaign_info.levels[i + 1])
            if not next_level_info then
              return {_S.letter.campaign_level_missing:format(campaign_info.levels[i + 1]), "", ""},
                     _S.fax.choices.return_to_main_menu,
                     "return_to_main_menu"
            end
            next_level_name = next_level_info.name
          end
          break
        end
      end
    end
    local level_info = TheApp:readLevelFile(self.map.level_number)
    text[1] = _S.letter.dear_player:format(self.hospitals[player_no].name)
    if has_next then
      text[2] = level_info.end_praise and level_info.end_praise:format(next_level_name) or _S.letter.campaign_level_completed:format(next_level_name)
      text[3] = ""
    else
      text[2] = campaign_info.winning_text and campaign_info.winning_text or _S.letter.campaign_completed
      text[3] = ""
    end
  end
  if has_next then
    choice_text = _S.fax.choices.accept_new_level
    choice = "accept_new_level"
  else
    choice_text = _S.fax.choices.return_to_main_menu
    choice = "return_to_main_menu"
  end
  return text, choice_text, choice
end

--! Cause the player with the player number player_no to lose.
--!param player_no (number) The number of the player which should lose.
--!param reason (string) [optional] The name of the criterion the player lost to.
--!param limit (number) [optional] The number the player went over/under which caused him to lose.
function World:loseGame(player_no, reason, limit)
  if player_no == 1 then -- TODO: Multiplayer
    self.ui.app.moviePlayer:playLoseMovie()
    local message = {_S.information.level_lost[1]}
    if reason then
      message[2] = _S.information.level_lost[2]
      message[3] = _S.information.level_lost[reason]:format(limit)
    else
      message[2] = _S.information.level_lost["cheat"]
     end
    self.ui.app:loadMainMenu(message)
  end
end

-- Called immediately prior to the ingame year changing.
function World:onEndYear()
  for _, hospital in ipairs(self.hospitals) do
    hospital:onEndYear()
  end
  -- This is done here instead of in onEndMonth so that the player gets
  -- the chance to receive money or reputation from trophies and awards first.
  for i, _ in ipairs(self.hospitals) do
    local res = self:checkWinningConditions(i)
    if res.state == "lose" then
      self:loseGame(i, res.reason, res.limit)
      if i == 1 then
        return true
      end
    end
  end
end

-- Calculate the distance of the shortest path (along passable tiles) between
-- the two given map tiles. This operation is commutative (swapping (x1, y1)
-- with (x2, y2) has no effect on the result) if both tiles are passable.
--!param x1 (integer) X-cordinate of first tile's Lua tile coordinates.
--!param y1 (integer) Y-cordinate of first tile's Lua tile coordinates.
--!param x2 (integer) X-cordinate of second tile's Lua tile coordinates.
--!param y2 (integer) Y-cordinate of second tile's Lua tile coordinates.
--!return (integer, boolean) The distance of the shortest path, or false if
-- there is no path.
function World:getPathDistance(x1, y1, x2, y2)
  return self.pathfinder:findDistance(x1, y1, x2, y2)
end

function World:getPath(x, y, dest_x, dest_y)
  return self.pathfinder:findPath(x, y, dest_x, dest_y)
end

function World:getIdleTile(x, y, idx)
  local cache_idx = (y - 1) * self.map.width + x
  local cache = self.idle_cache[cache_idx]
  if not cache then
    cache = {
      x = {},
      y = {},
    }
    self.idle_cache[cache_idx] = cache
  end
  if not cache.x[idx] then
    local ix, iy = self.pathfinder:findIdleTile(x, y, idx)
    if not ix then
      return ix, iy
    end
    cache.x[idx] = ix
    cache.y[idx] = iy
  end
  return cache.x[idx], cache.y[idx]
end

--[[
This function checks if a tile has no entity on it and (optionally) if it is not
in a room.
!param x (integer) the queried tile's x coordinate.
!param y (integer) the queried tile's y coordinate.
!param not_in_room (boolean) If set, also check the tile is not in a room.
!return (boolean) whether all checks hold.
--]]
function World:isTileEmpty(x, y, not_in_room)
  if #self.entity_map:getHumanoidsAtCoordinate(x, y) ~= 0 or
      #self.entity_map:getObjectsAtCoordinate(x, y) ~= 0 then
    return false
  end
  if not_in_room then
    return self:getRoom(x, y) == nil
  end
  return true
end

function World:getFreeBench(x, y, distance)
  local bench, rx, ry, bench_distance
  local object_type = self.object_types.bench
  x, y, distance = math.floor(x), math.floor(y), math.ceil(distance)
  self.pathfinder:findObject(x, y, object_type.thob, distance, function(xpos, ypos, d, dist)
    local b = self:getObject(xpos, ypos, "bench")
    if b and not b.user and not b.reserved_for then
      local orientation = object_type.orientations[b.direction]
      if orientation.pathfind_allowed_dirs[d] then
        rx = xpos + orientation.use_position[1]
        ry = ypos + orientation.use_position[2]
        bench = b
        bench_distance = dist
        return true
      end
    end
  end)
  return bench, rx, ry, bench_distance
end

--! Checks whether the given tile is part of a nearby object (walkable tiles
--  count as part of the object)
--!param x X position of the given tile.
--!param y Y position of the given tile.
--!param distance The number of tiles away from the tile to search.
--!return (boolean) Whether the tile is part of a nearby object.
function World:isTilePartOfNearbyObject(x, y, distance)
  for o in pairs(self:findAllObjectsNear(x, y, distance)) do
    for _, xy in ipairs(o:getWalkableTiles()) do
      if xy[1] == x and xy[2] == y then
        return true
      end
    end
  end
  return false
end

-- Returns a set of all objects near the given position but if supplied only of the given object type.
--!param x The x-coordinate at which to originate the search
--!param y The y-coordinate
--!param distance The number of tiles away from the origin to search
--!param object_type_name The name of the objects that are being searched for
function World:findAllObjectsNear(x, y, distance, object_type_name)
  if not distance then
    -- Note that regardless of distance, only the room which the humanoid is in
    -- is searched (or the corridor if the humanoid is not in a room).
    distance = 2^30
  end
  local objects = {}
  local thob = 0
  if object_type_name then
    local obj_type = self.object_types[object_type_name]
    if not obj_type then
      error("Invalid object type name: " .. object_type_name)
    end
    thob = obj_type.thob
  end

  local callback = function(xpos, ypos, d)
    local obj = self:getObject(xpos, ypos, object_type_name)
    if obj then
      objects[obj] = true
    end
  end
  self.pathfinder:findObject(x, y, thob, distance, callback)
  return objects
end

--[[ Find all objects of the given type near the humanoid.
Note that regardless of distance, only the room which the humanoid is in
is searched (or the corridor if the humanoid is not in a room).

When no callback is specified then the first object found is returned,
along with its usage tile position. This may return an object already being
used - if you want to find an object not in use (in order to use it),
then call findFreeObjectNearToUse instead.

!param humanoid The humanoid to search around
!param object_type_name The objects to search for
!param distance Maximum L1 distance to search from humanoid. If nil then
       everywhere in range will be searched.
!param callback Function to call for each result. If it returns true then
       the search will be ended.
--]]
function World:findObjectNear(humanoid, object_type_name, distance, callback)
  if not distance then
    distance = 2^30
  end
  local obj, ox, oy
  if not callback then
    -- The default callback returns the first object found
    callback = function(x, y, d)
      obj = self:getObject(x, y, object_type_name)
      local orientation = obj.object_type.orientations
      if orientation then
        orientation = orientation[obj.direction]
        if not orientation.pathfind_allowed_dirs[d] then
          return
        end
        x = x + orientation.use_position[1]
        y = y + orientation.use_position[2]
      end
      ox = x
      oy = y
      return true
    end
  end
  local thob = 0
  if type(object_type_name) == "table" then
    local original_callback = callback
    callback = function(x, y, ...)
      local cb_obj = self:getObject(x, y, object_type_name)
      if cb_obj then
        return original_callback(x, y, ...)
      end
    end
  elseif object_type_name ~= nil then
    local obj_type = self.object_types[object_type_name]
    if not obj_type then
      error("Invalid object type name: " .. object_type_name)
    end
    thob = obj_type.thob
  end
  self.pathfinder:findObject(humanoid.tile_x, humanoid.tile_y, thob, distance,
    callback)
  -- These return values are only relevant for the default callback - are nil
  -- for custom callbacks
  return obj, ox, oy
end

function World:findFreeObjectNearToUse(humanoid, object_type_name, which, current_object)
  -- If which == nil or false, then the nearest object is taken.
  -- If which == "far", then the furthest object is taken.
  -- If which == "near", then the nearest object is taken with 50% probability, the second nearest with 25%, and so on
  -- Other values for which may be added in the future.
  -- Specify current_object if you want to exclude the currently used object from the search
  local object, ox, oy
  self:findObjectNear(humanoid, object_type_name, nil, function(x, y, d)
    local obj = self:getObject(x, y, object_type_name)
    if obj.user or (obj.reserved_for and obj.reserved_for ~= humanoid) or (current_object and obj == current_object) then
      return
    end
    local orientation = obj.object_type.orientations
    if orientation then
      orientation = orientation[obj.direction]
      if not orientation.pathfind_allowed_dirs[d] then
        return
      end
      x = x + orientation.use_position[1]
      y = y + orientation.use_position[2]
    end
    object = obj
    ox = x
    oy = y
    if which == "far" then
      -- just take the last found object, so don't ever abort
    elseif which == "near" then
      -- abort at each item with 50% probability
      local chance = math.random(1, 2)
      if chance == 1 then
        return true
      end
    else
      -- default: return at the first found item
      return true
    end
  end)
  return object, ox, oy
end

function World:findRoomNear(humanoid, room_type_id, distance, mode)
  -- If mode == "nearest" (or nil), the nearest room is taken
  -- If mode == "advanced", prefer a near room, but also few patients and fulfilled staff criteria
  local room
  local score
  if not mode then
    mode = "nearest" -- default mode
  end
  if not distance then
    distance = 2^30
  end
  for _, r in pairs(self.rooms) do repeat
    if r.built and (not room_type_id or r.room_info.id == room_type_id) and r.is_active then
      local x, y = r:getEntranceXY(false)
      local d = self:getPathDistance(humanoid.tile_x, humanoid.tile_y, x, y)
      if not d or d > distance then
        break -- continue
      end
      local this_score = d
      if mode == "advanced" then
        this_score = this_score + r:getUsageScore()
      end
      if not score or this_score < score then
        score = this_score
        room = r
      end
    end
  until true end
  return room
end

--! Setup an animated floating money amount above a patient.
--!param patient Patient to float above.
--!param amount Amount of money to display.
function World:newFloatingDollarSign(patient, amount)
  if self.free_build_mode or patient.hospital ~= self:getLocalPlayerHospital() then
    return
  end
  if not self.floating_dollars then
    self.floating_dollars = {}
  end
  local spritelist = TH.spriteList()
  spritelist:setPosition(-17, -60)
  spritelist:setSpeed(0, -1):setLifetime(100)
  spritelist:setSheet(TheApp.gfx:loadSpriteTable("Data", "Money01V"))
  spritelist:setUseIntermediateBuffer()
  spritelist:append(1, 0, 0)
  local len = #("%i"):format(amount)
  local xbase = math.floor(10.5 + (20 - 5 * len) / 2)
  for i = 1, len do
    local digit = amount % 10
    amount = (amount - digit) / 10
    spritelist:append(2 + digit, xbase + 5 * (len - i), 5)
  end
  spritelist:setTile(self.map.th, patient.tile_x, patient.tile_y)

  self.floating_dollars[spritelist] = true
end

function World:newEntity(class, animation)
  local th = TH.animation()
  th:setAnimation(self.anims, animation)
  local entity = _G[class](th)
  self.entities[#self.entities + 1] = entity
  entity.world = self
  return entity
end

function World:destroyEntity(entity)
  for i, e in ipairs(self.entities) do
    if e == entity then
      table.remove(self.entities, i)
      break
    end
  end
  entity:onDestroy()
end

function World:newObjectType(new_object)
  self.object_types[new_object.id] = new_object
end

--! Creates a new object by finding the object_type from the "id" variable and
--  calls its class constructor.
--!param id (string) The unique id of the object to be created.
--!param x X position of the new object.
--!param y Y position of the new object.
--!param flags Flags of the new object.
--!param name Name of the new object.
--!return The created object.
function World:newObject(id, x, y, flags, name)
  local object_type = self.object_types[id]
  local hospital = self:getLocalPlayerHospital()

  local entity
  if object_type.class then
    entity = _G[object_type.class](hospital, object_type, x, y, flags, name)
  elseif object_type.default_strength then
    entity = Machine(hospital, object_type, x, y, flags, name)
    -- Tell the player if there is no handyman to take care of the new machinery.
    if hospital:countStaffOfCategory("Handyman", 1) == 0 then
      self.ui.adviser:say(_A.staff_advice.need_handyman_machines)
    end
  else
    entity = Object(hospital, object_type, x, y, flags, name)
  end
  self:objectPlaced(entity, id)
  return entity
end

function World:canNonSideObjectBeSpawnedAt(x, y, objects_id, orientation, spawn_rooms_id, player_id)
  local object = self.object_types[objects_id]
  local objects_footprint = object.orientations[orientation].footprint
  for _, tile in ipairs(objects_footprint) do
    local tiles_world_x = x + tile[1]
    local tiles_world_y = y + tile[2]
    if not self:isOnMap(tiles_world_x, tiles_world_y) then
      return false
    end

    if not self:willObjectsFootprintTileBeWithinItsAllowedRoomIfLocatedAt(x, y, object, spawn_rooms_id).within_room then
      return false
    end

    if not self:isFootprintTileBuildableOrPassable(x, y, tile, objects_footprint, "buildable", player_id) then
      return false
    end
  end
  return not self:wouldNonSideObjectBreakPathfindingIfSpawnedAt(x, y, object, orientation, spawn_rooms_id)
end

--! Test whether the given coordinate is on the map.
--!param x (int) X position of the coordinate to test.
--!param y (int) Y position of the coordinate to test.
--!return (boolean) Whether the provided position is on the map.
function World:isOnMap(x, y)
  return x >= 1 and x <= self.map.width and y >= 1 and y <= self.map.height
end

---
-- @param allowed_rooms_id_parameter Should be nil when the object is allowed to be placed in any room.
-- @return {within_room, roomId}
---
function World:willObjectsFootprintTileBeWithinItsAllowedRoomIfLocatedAt(x, y, object, allowed_rooms_id_parameter)
  local xy_rooms_id = self.map.th:getCellFlags(x, y, {}).roomId

  if allowed_rooms_id_parameter then
    return {within_room = allowed_rooms_id_parameter == xy_rooms_id, roomId = allowed_rooms_id_parameter}
  elseif xy_rooms_id == 0 then
    return {within_room = object.corridor_object ~= nil, roomId = xy_rooms_id}
  else
    for _, additional_objects_name in pairs(self.rooms[xy_rooms_id].room_info.objects_additional) do
      if TheApp.objects[additional_objects_name].thob == object.thob then
        return {within_room = true, roomId = xy_rooms_id}
      end
    end
    for needed_objects_name, _ in pairs(self.rooms[xy_rooms_id].room_info.objects_needed) do
      if TheApp.objects[needed_objects_name].thob == object.thob then
        return {within_room = true, roomId = xy_rooms_id}
      end
    end
    return {within_room = false, roomId = xy_rooms_id}
  end
end

---
-- A footprint tile will either need to be buildable or passable so this function
-- checks if its buildable/passable using the tile's appropriate flag and then returns this
-- flag's boolean value or false if the tile isn't valid.
---
function World:isFootprintTileBuildableOrPassable(x, y, tile, footprint, requirement_flag, player_id)
  local function isTileValid(xpos, ypos, complete_cell, flags, flag_name, need_side)
    if complete_cell or need_side then
      return flags[flag_name]
    end
    for _, fp_tile in ipairs(footprint) do
      if fp_tile[1] == xpos and fp_tile[2] == ypos then
        return flags[flag_name]
      end
    end
    return true
  end

  local direction_parameters = {
      north = { x = 0, y = -1, buildable_flag = "buildableNorth", passable_flag = "travelNorth", needed_side = "need_north_side"},
      east = { x = 1, y = 0, buildable_flag =  "buildableEast", passable_flag = "travelEast", needed_side = "need_east_side"},
      south = { x = 0, y = 1, buildable_flag = "buildableSouth", passable_flag = "travelSouth", needed_side = "need_south_side"},
      west = { x = -1, y = 0, buildable_flag = "buildableWest", passable_flag = "travelWest", needed_side = "need_west_side"}
    }
  local flags = {}
  local requirement_met = self.map.th:getCellFlags(x, y, flags)[requirement_flag] and
      (player_id == 0 or player_id == flags.owner)

  if requirement_met then
    -- For each direction check that the tile is valid:
    for _, direction in pairs(direction_parameters) do
      local x1, y1 = tile[1] + direction["x"], tile[2] + direction["y"]
      if not isTileValid(x1, y1, tile.complete_cell, flags, direction["buildable_flag"], tile[direction["needed_side"]]) then
        return false
      end
    end
    return true
  else
    return false
  end
end

---
-- Check that pathfinding still works, i.e. that placing the object
-- wouldn't disconnect one part of the hospital from another. To do
-- this, we provisionally mark the footprint as unpassable (as it will
-- become when the object is placed), and then check that the cells
-- surrounding the footprint have not had their connectedness changed.
---
function World:wouldNonSideObjectBreakPathfindingIfSpawnedAt(x, y, object, objects_orientation, spawn_rooms_id)
  local objects_footprint = object.orientations[objects_orientation].footprint
  local map = self.map.th

  local function setFootprintTilesPassable(passable)
    for _, tile in ipairs(objects_footprint) do
      if not tile.only_passable then
        map:setCellFlags(x + tile[1], y + tile[2], {passable = passable})
      end
    end
  end

  local function isIsolated(xpos, ypos)
    setFootprintTilesPassable(false)
    local result = not self.pathfinder:isReachableFromHospital(xpos, ypos)
    setFootprintTilesPassable(true)
    return result
  end

  local all_good = true

  --1. Find out which footprint tiles are passable now before this function makes some unpassable
  --during its test:
  local tiles_passable_flags = {}
  for _, tile in ipairs(objects_footprint) do
    table.insert(tiles_passable_flags, map:getCellFlags(x + tile[1], y + tile[2], {}).passable)
  end

  --2. Find out which tiles adjacent to the footprint would become isolated:
  setFootprintTilesPassable(false)
  local prev_x, prev_y
  for _, tile in ipairs(object.orientations[objects_orientation].adjacent_to_solid_footprint) do
    local xpos = x + tile[1]
    local ypos = y + tile[2]
    local flags = {}
    if map:getCellFlags(xpos, ypos, flags).roomId == spawn_rooms_id and flags.passable then
      if prev_x then
        if not self.pathfinder:findDistance(xpos, ypos, prev_x, prev_y) then
          -- There is no route between the two map nodes. In most cases,
          -- this means that connectedness has changed, though there is
          -- one rare situation where the above test is insufficient. If
          -- (xpos, ypos) is a passable but isolated node outside the hospital
          -- and (prev_x, prev_y) is in the corridor, then the two will
          -- not be connected now, but critically, neither were they
          -- connected before.
          if not isIsolated(xpos, ypos) then
            if not isIsolated(prev_x, prev_y) then
              all_good = false
              break
            end
          else
            xpos = prev_x
            ypos = prev_y
          end
        end
      end
      prev_x = xpos
      prev_y = ypos
    end
  end

  -- 3. For each footprint tile passable flag set to false by step 2 undo this change:
  for tiles_index, tile in ipairs(objects_footprint) do
    map:setCellFlags(x + tile[1], y + tile[2], {passable = tiles_passable_flags[tiles_index]})
  end

  return not all_good
end

--! Notifies the world that an object has been placed, notifying
--  interested entities in the vicinity of the new arrival.
--!param entity (Entity) The entity that was just placed.
--!param id (optional string) That entity's id.
function World:objectPlaced(entity, id)
  -- If id is not supplied, we can use the entities internal id if it exists
  -- This is so the bench check below works
  -- see place_object.lua:UIPlaceObjects:placeObject for call w/o id --cgj
  if not id and entity.object_type.id then
    id = entity.object_type.id
  end

  self.entities[#self.entities + 1] = entity

  -- Warn a hospital if that is possible.
  if not entity.tile_x or not entity.tile_y then return end
  local hosp = self:getHospital(entity.tile_x, entity.tile_y)
  if hosp then hosp:objectPlaced(entity, id) end
end

--! Notify the world of an object being removed from a tile
--! See also `World:addObjectToTile`
--!param object (Object) The object being removed.
--!param x (integer) The X-coordinate of the tile which the object was on
--!param y (integer) The Y-coordinate of the tile which the object was on
function World:removeObjectFromTile(object, x, y)
  local index = (y - 1) * self.map.width + x
  local objects = self.objects[index]
  local thob = object.object_type.thob
  if objects then
    for k, v in ipairs(objects) do
      if v == object then
        table_remove(objects, k)
        self.map.th:removeObjectType(x, y, thob)
        local count_cat = object.object_type.count_category
        if count_cat then
          self.object_counts[count_cat] = self.object_counts[count_cat] - 1
        end
        return true
      end
    end
  end
  return false
end

--! Notify the world of a new object being placed somewhere in the world
--! See also `World:removeObjectFromTile`
--!param object (Object) The object being placed
--!param x (integer) The X-coordinate of the tile being placed upon
--!param y (integer) The Y-coordinate of the tile being placed upon
function World:addObjectToTile(object, x, y)
  local index = (y - 1) * self.map.width + x
  local objects = self.objects[index]
  if objects then
    self.map.th:setCellFlags(x, y, {thob = object.object_type.thob})
    objects[#objects + 1] = object
  else
    objects = {object}
    self.objects[index] = objects
    self.map.th:setCellFlags(x, y, {thob = object.object_type.thob})
  end
  local count_cat = object.object_type.count_category
  if count_cat then
    self.object_counts[count_cat] = self.object_counts[count_cat] + 1
  end
  return true
end

--! Retrieve all objects from a given position.
--!param x (int) X position of the object to retrieve.
--!param y (int) Y position of the object to retrieve.
function World:getObjects(x, y)
  local index = (y - 1) * self.map.width + x
  return self.objects[index]
end

--! Retrieve one object from a given position.
--!param x (int) X position of the object to retrieve.
--!param y (int) Y position of the object to retrieve.
--!param id Id to search, nil gets first object, string gets first object with
--! that id, set of strings gets first object that matches an entry in the set.
--!return (Object or nil) The found object, or nil if the object is not found.
function World:getObject(x, y, id)
  local objects = self:getObjects(x, y)
  if objects then
    if not id then
      return objects[1]
    elseif type(id) == "table" then
      for _, obj in ipairs(objects) do
        if id[obj.object_type.id] then
          return obj
        end
      end
    else
      for _, obj in ipairs(objects) do
        if obj.object_type.id == id then
          return obj
        end
      end
    end
  end
  return -- nil
end

--! Remove all cleanable litter from a given tile.
--!param x (int) X position of the tile to clean.
--!param y (int) Y position of the tile to clean.
function World:removeAllLitter(x, y)
  local litters = {}
  local objects = self:getObjects(x, y)
  if not objects then return end

  for _, obj in ipairs(objects) do
    if obj.object_type.id == "litter" and obj:isCleanable() then
      litters[#litters + 1] = obj
    end
  end
  for _, litter in ipairs(litters) do litter:remove() end
end

--! Prepare all tiles of the footprint for build of an object.
--!param object_footprint Footprint of the object being build.
--!param x (int) X position of the object
--!param y (int) Y position of the object
function World:prepareFootprintTilesForBuild(object_footprint, x, y)
  local hospital = self:getLocalPlayerHospital()

  for _, tile in ipairs(object_footprint) do
    if tile.complete_cell or not (tile.passable or tile.only_passable) then
      self:removeAllLitter(x + tile[1], y + tile[2])
      hospital:removeRatholeXY(x + tile[1], y + tile[2])
    end
  end
end

--! Prepare all tiles in the given rectangle for building a room.
--!param x (int) Start x position of the area.
--!param y (int) Start y position of the area.
--!param w (int) Number of tiles in x direction.
--!param h (int) Number of tiles in y direction.
function World:prepareRectangleTilesForBuild(x, y, w, h)
  local hospital = self:getLocalPlayerHospital()

  x = x - 1
  y = y - 1
  for dx = 1, w do
    for dy = 1, h do
      self:removeAllLitter(x + dx, y + dy)
      if dx == 1 or dx == w or dy == 1 or dy == h then hospital:removeRatholeXY(x + dx, y + dy) end
    end
  end
end

--! Get the room at a given tile location.
--!param x (int) X position of the queried tile.
--!param y (int) Y position of the queried tile.
--!return (Room) Room of the tile, or 'nil'.
function World:getRoom(x, y)
  return self.rooms[self.map:getRoomId(x, y)]
end

--! Get the hospital at a given tile location.
--!param x (int) X position of the queried tile.
--!param y (int) Y position of the queried tile.
--!return (Hospital) Hospital at the given location or 'nil'.
function World:getHospital(x, y)
  local th = self.map.th

  local flags = th:getCellFlags(x, y)
  if not flags.hospital then return nil end
  return self.hospitals[flags.owner]
end

--! Returns localized name of the room, internal required staff name
-- and localized name of staff required.
function World:getRoomNameAndRequiredStaffName(room_id)
  local room_name, required_staff, staff_name
  for _, room in ipairs(TheApp.rooms) do
    if room.id == room_id then
      room_name = room.long_name
      required_staff = room.required_staff
    end
  end
  for key, _ in pairs(required_staff) do
    staff_name = key
  end
  required_staff = staff_name -- This is the "programmatic" name of the staff.
  if staff_name == "Nurse" then
    staff_name = _S.staff_title.nurse
  elseif staff_name == "Psychiatrist" then
    staff_name = _S.staff_title.psychiatrist
  elseif staff_name == "Researcher" then
    staff_name = _S.staff_title.researcher
  elseif staff_name == "Surgeon" then
    staff_name = _S.staff_title.surgeon
  elseif staff_name == "Doctor" then
    staff_name = _S.staff_title.doctor
  end
  return room_name, required_staff, staff_name
end

--! Append a message to the game log.
--!param message (string) The message to add.
function World:gameLog(message)
  self.game_log[#self.game_log + 1] = message
  -- If in debug mode also show it in the command prompt
  if TheApp.config.debug then
    print(message)
  end
end

--! Dump the contents of the game log into a file.
-- This is automatically done on each error.
function World:dumpGameLog()
  local config_path = TheApp.command_line["config-file"] or ""
  local pathsep = package.config:sub(1, 1)
  config_path = config_path:match("^(.-)[^" .. pathsep .. "]*$")
  local gamelog_path = config_path .. "gamelog.txt"
  local fi = self.app:writeToFileOrTmp(gamelog_path)
  for _, str in ipairs(self.game_log) do
    fi:write(str .. "\n")
  end
  fi:close()
end

--! Because the save file only saves one thob per tile if they are more that information
-- will be lost. To solve this after a load we need to set again all the thobs on each tile.
function World:resetAnimations()
  -- Erase entities from the map if they want.
  for _, entity in ipairs(self.entities) do
    entity:eraseObject()
  end
  -- Add them again.
  for _, entity in ipairs(self.entities) do
    entity:resetAnimation()
  end
end

strict_declare_global "staff_initials_cache"
staff_initials_cache = {}

local function our_concat(t)
  -- The standard table.concat function doesn't like our userdata strings :(
  local result = ""
  for _, s in ipairs(t) do
    result = result .. s
  end
  return result
end

--! Refresh cache of letters in current language to be used for staff member's initials
function World:updateInitialsCache()
  local parts = tostring(our_concat(_S.humanoid_name_starts)
      .. our_concat(_S.humanoid_name_ends)):sub(33)
  local initials = {}
  for uchar in parts:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
    initials[#initials + 1] = uchar
  end
  staff_initials_cache.initials = initials
end

--! Change the staff name first letter to one from the current language
-- from the seed (generated here or in staff_profile.lua)
--!param profile (table) The profile of the staff member
function World:localiseInitial(profile)
  if not profile.name_seed then
    -- 1009 is a prime number which avoids a modulo of 0 when we need
    -- a positive number to randomly pick the initial letter
    profile.name_seed = math.random(1, 1009)
  end
  if profile.name_lang == TheApp.config.language then return end
  -- Staff member doesn't have an initial in the current language
  local num = profile.name_seed % #staff_initials_cache.initials
  profile.initial = staff_initials_cache.initials[num]
  profile.name_lang = TheApp.config.language
end

--! Let the world react to and old save game. First it gets the chance to
-- do things for itself, and then it calls corresponding functions for
-- the hospitals, entities and rooms in that order.
--!param old The old version of the save game.
--!param new The current version of the save game format.
function World:afterLoad(old, new)

  if not self.original_savegame_version then
    self.original_savegame_version = old
  end
  -- If the original save game version is considerably lower than the current, warn the player.
  if new - 20 > self.original_savegame_version then
    self.ui:addWindow(UIInformation(self.ui, {_S.information.very_old_save}))
  end

  self:setUI(self.ui)

  -- insert global compatibility code here
  if old < 4 then
    self.room_built = {}
  end
  if old < 6 then
    -- Calculate hospital value

    -- Initial value
    local value = self.map.parcelTileCounts[self.hospitals[1]:getPlayerIndex()] * 25 + 20000

    -- Add room values
    for _, room in pairs(self.rooms) do
      local valueChange = room.room_info.build_cost

      -- Subtract values of objects in rooms to avoid calculating those object values twice
      for obj, num in pairs(room.room_info.objects_needed) do
        valueChange = valueChange - num * TheApp.objects[obj].build_cost
      end
      value = value + valueChange
    end

    -- Add up all object values
    for _, object in ipairs(self.entities) do
        if class.is(object, Object) and object.object_type.build_cost then
          value = value + object.object_type.build_cost
        end
    end

    self.hospitals[1].value = value
  end

  if old < 7 then
    self.level_criteria = local_criteria_variable
    self:determineWinningConditions()
  end
  if old < 10 then
    self.object_counts = {
      extinguisher = 0,
      radiator = 0,
      plant = 0,
      general = 0,
    }
    for _, obj_list in pairs(self.objects) do
      for _, obj in ipairs(obj_list) do
        local count_cat = obj.object_type.count_category
        if count_cat then
          self.object_counts[count_cat] = self.object_counts[count_cat] + 1
        end
      end
    end
  end
  if old < 43 then
    self.object_counts.reception_desk = 0
    for _, obj_list in pairs(self.objects) do
      for _, obj in ipairs(obj_list) do
        local count_cat = obj.object_type.count_category
        if count_cat and count_cat == "reception_desk" then
          self.object_counts[count_cat] = self.object_counts[count_cat] + 1
        end
      end
    end
  end
  if old < 47 then
    self.object_counts.bench = 0
    for _, obj_list in pairs(self.objects) do
      for _, obj in ipairs(obj_list) do
        local count_cat = obj.object_type.count_category
        if count_cat and count_cat == "bench" then
          self.object_counts[count_cat] = self.object_counts[count_cat] + 1
        end
      end
    end
  end
  if old < 12 then
    self.animation_manager = TheApp.animation_manager
    self.anim_length_cache = nil
  end
  if old < 17 then
    -- Added another object
    local pathsep = package.config:sub(1, 1)
    local _, shield = pcall(corsixth.require, "objects" .. pathsep .. "radiation_shield")
    local _, shield_b = pcall(corsixth.require, "objects" .. pathsep .. "radiation_shield_b")
    shield.slave_type = shield_b
    shield.slave_type.master_type = shield
    Object.processTypeDefinition(shield)
    Object.processTypeDefinition(shield_b)

    self.object_id_by_thob[shield.thob] = shield.id
    self.object_id_by_thob[shield_b.thob] = shield_b.id
    self.object_types[shield.id] = shield
    self.object_types[shield_b.id] = shield_b
    self.ui.app.objects[shield.id] = shield
    self.ui.app.objects[shield_b.id] = shield_b
    self.ui.app.objects[#self.ui.app.objects + 1] = shield
    self.ui.app.objects[#self.ui.app.objects + 1] = shield_b
  end
  if old < 27 then
    -- Add callsDispatcher
    self.dispatcher = CallsDispatcher(self)
  end
  if old < 30 then
    self:nextEmergency()
  end
  if old < 31 then
    self.hours_per_day = 50
    self:setSpeed("Normal")
  end
  if old < 36 then
    self:determineWinningConditions()
  end
  if old < 37 then
    -- Spawn rate is taken from level files now.
    -- Make sure that all config values are present.
    if not self.map.level_config.popn then
      self.map.level_config.popn = {
        [0] = {Change = 3, Month = 0},
        [1] = {Change = 1, Month = 1},
      }
    end
    if not self.map.level_config.gbv.AllocDelay then
      self.map.level_config.gbv.AllocDelay = 3
    end
    local index = 0
    local popn = self.map.level_config.popn
    self.spawn_rate = popn[index].Change
    self.monthly_spawn_increase = self.spawn_rate

    -- Bring the spawn rate "up to speed".
    for month = 1, self.month + (self.year-1)*12 do
      -- Check if the next entry should be used.
      while popn[index + 1] and month >= popn[index + 1].Month do
        index = index + 1
      end
      self.monthly_spawn_increase = popn[index].Change
      self.spawn_rate = self.spawn_rate + self.monthly_spawn_increase
    end
    self.spawn_hours = {}
    self.spawn_dates = {}
    self:updateSpawnDates()
  end
  if old < 45 then
    self:nextVip()
  end
  if old < 52 then
    -- Litter was not properly removed from the world.
    for i = #self.entities, 1, -1 do
      if class.is(self.entities[i], Litter) then
        if not self.entities[i].tile_x then
          self:destroyEntity(self.entities[i])
        end
      end
    end
  end
  if old < 53 then
    self.current_map_earthquake = 0
    -- It may happen that the current game has gone on for a while
    if self.map.level_config.quake_control then
      while true do
        if self.map.level_config.quake_control[self.current_map_earthquake] and
            self.map.level_config.quake_control[self.current_map_earthquake] ~= 0 then
          -- Check to see if the start month has passed
          local control = self.map.level_config.quake_control[self.current_map_earthquake]
          if control.StartMonth <= self.month + 12 * (self.year - 1) then
            -- Then check the next one
            self.current_map_earthquake = self.current_map_earthquake + 1
          else
            -- We found an earthquake coming in the future!
            break
          end
        else
          -- No more earthquakes in the config file.
          break
        end
      end
    end
    -- Now set up the next earthquake.
    self:nextEarthquake()
  end
  if old < 57 then
    self.user_actions_allowed = true
  end
  if old < 61 then
    -- room remove callbacks added
    self.room_remove_callbacks = {}
  end
  if old < 64 then
    -- added reference to world for staff profiles
    for _, group in pairs(self.available_staff) do
      for _, profile in ipairs(group) do
        profile.world = self
      end
    end
  end
  if old < 66 then
    -- Unreserve objects which are not actually reserved for real in the staff room.
    -- This is a special case where reserved_for could be set just as a staff member was leaving
    for _, room in pairs(self.rooms) do
      if room.room_info.id == "staff_room" then
        -- Find all objects in the room
        local fx, fy = room:getEntranceXY(true)
        for obj, _ in pairs(self:findAllObjectsNear(fx, fy)) do
          if obj.reserved_for then
            local found = false
            for _, action in ipairs(obj.reserved_for.action_queue) do
              if action.name == "use_object" then
                if action.object == obj then
                  found = true
                  break
                end
              end
            end
            if not found then
              self:gameLog("Unreserved an object: " .. obj.object_type.id .. " at " .. obj.tile_x .. ":" .. obj.tile_y)
              obj.reserved_for = nil
            end
          end
        end
      end
    end
  end

  if old < 103 then
    -- If a room has patients who no longer exist in its
    -- humanoids_enroute table because of #133 remove them:
    for _, room in pairs(self.rooms) do
      for patient, _ in pairs(room.humanoids_enroute) do
        if patient.tile_x == nil then
          room.humanoids_enroute[patient] = nil
        end
      end
    end
  end
  if old < 124 then
    self.game_date = Date(self.year, self.month, self.day, self.hour)
    -- self.next_vip_month is number of months since the game start
    self.next_vip_date = Date(1, self.next_vip_month, self.next_vip_day)
  end

  -- Now let things inside the world react.
  for _, cat in pairs({self.hospitals, self.entities, self.rooms}) do
    for _, obj in pairs(cat) do
      obj:afterLoad(old, new)
    end
  end

  if old < 80 then
    self:determineWinningConditions()
  end

  if old >= 87 then
    self:playLoadedEntitySounds()
  end

  if old < 88 then
    --Populate the entity map
    self.entity_map = EntityMap(self.map)
    for _, e in ipairs(self.entities) do
      local x, y = e.tile_x, e.tile_y
      if x and y then
        self.entity_map:addEntity(x,y,e)
      end
    end
  end
  if old < 108 then
    self.room_build_callbacks = nil
  end
  if old < 113 then -- Make cleanable littered tiles buildable.
    for x = 1, self.map.width do
      for y = 1, self.map.height do
        local litter = self:getObject(x, y, "litter")
        if litter and litter:isCleanable() then self.map:setCellFlags(x, y, {buildable=true}) end
      end
    end
  end
  if old < 115 then
    self.next_earthquake = {
      start_month = self.next_earthquake_month,
      start_day = self.next_earthquake_day,
      size = self.earthquake_size,
      active = self.earthquake_active or false
    }
    self.next_earthquake_month = nil
    self.next_earthquake_day = nil
    self.earthquake_stop_day = nil
    self.earthquake_size = nil
    self.earthquake_active = nil
    self.randomX = nil
    self.randomY = nil
    self.currentX = nil
    self.currentY = nil

    if self.next_earthquake.active then
      local rd = 0
      for _, room in pairs(self.rooms) do
        for object, _ in pairs(room.objects) do
          if object.quake_points then
            rd = math.max(rd, object.quake_points)
            object.quake_points = nil
          end
        end
      end
      self.next_earthquake.remaining_damage = rd
      self.next_earthquake.damage_timer = earthquake_damage_time
      self.next_earthquake.warning_timer = 0
    else
      self.next_earthquake.remaining_damage = self.next_earthquake.size
      self.next_earthquake.damage_timer = earthquake_damage_time
      self.next_earthquake.warning_timer = earthquake_warning_period
    end
  end
  if old < 120 then
    -- Issue #1105 updates to fix any broken saves with travel<dir> flags for side objects
    self:resetSideObjects()
  end

  if old < 153 then
    -- Set the new variable next_emergency_date
    -- Also set the new variable next_emergency
    -- In previous code month == 0 meant emergencies were over
    if self.next_emergency_month ~= 0 then
      self.next_emergency_date = Date(1, self.next_emergency_month, self.next_emergency_day)
      local control = self.map.level_config.emergency_control
      self.next_emergency = control[self.next_emergency_no]
      -- Complementary afterLoad to see if emergencies got stuck in the level.
      -- There's no guarantee we can unstick the level, however.
      local next_emer_date = Date(1, self.next_emergency_month, self.next_emergency_day)
      --[[ UIWatch's emergency timer is 52 days but this is local.
      The emergency fax also is held for 16 days.
      Add one extra day to this for compensation = 69. (Unavoidable magic number)]]--
      if self.game_date > next_emer_date:plusDays(69) then
        -- The date the emergency should've finished by has passed.
        -- Next check if the emergency could still be happening.
        local watch = self.ui:getWindow(UIWatch)
        if not watch or watch.count_type ~= "emergency" then
          -- The emergency is likely stuck
          self:nextEmergency()
        end
      end
    end
  end

  -- Fix the initial of staff names
  self:updateInitialsCache()
  for _, staff_category in pairs(self.available_staff) do
    for _, staff in pairs(staff_category) do
      self:localiseInitial(staff)
    end
  end
  for _, staff in ipairs(self:getLocalPlayerHospital().staff) do
    self:localiseInitial(staff.profile)
  end

  self.savegame_version = new
  self.release_version = TheApp:getVersion(new)
  self.system_pause = false -- Reset flag on load
end

function World:playLoadedEntitySounds()
  for _, entity in pairs(self.entities) do
    entity:playAfterLoadSound()
  end
end

--[[ There is a problem with room editing in that it resets all the partial passable flags
(travelNorth, travelSouth etc.) in the corridor, a workaround is calling this function
after the room was edited so that all edge only objects, that set partial passable flags set
those flags again]]
function World:resetSideObjects()
  for _, objects in pairs(self.objects) do
    for _, obj in ipairs(objects) do
      if obj.object_type.class == "SideObject" then
        obj:setTile(obj.tile_x, obj.tile_y)
      end
    end
  end
end

--[[ When placing doors and objects the passable tiles need to be checked for overlapping
passable tiles. This presents problems with objects like Bench where the passable tile
is not for exclusive use of the Bench (another object can share that same tile)
the footprint.shareable differentiates shareable passable tiles, and exclusive use
passable tiles (the norm for most objects)]]
--!param x (int) x map tile position
--!param y (int) y map tile position
--!param distance (int) searchable distance for nearby objects
--!return (boolean) indicating if exclusively passable or not
function World:isTileExclusivelyPassable(x, y, distance)
  for o in pairs(self:findAllObjectsNear(x, y, distance)) do
    if o and o.footprint then
      for _, footprint in pairs(o.footprint) do
        if footprint[1] + o.tile_x == x and footprint[2] + o.tile_y == y and footprint.only_passable and not footprint.shareable then
          return false
        end
      end
    else
      -- doors don't have a footprint but objects can't be built blocking them either
      for _, footprint in pairs(o:getWalkableTiles()) do
        if o.object_type and o.object_type.thob ~= 62 and footprint[1] == x and footprint[2] == y then
          return false
        end
      end
    end
  end
  return true
end

--! Get todays date.
--!return (Date) Current game date.
function World:date()
  return self.game_date:clone()
end

--! Collect the settings that should be reused in the next world
--!return (table) world and hospital campaign data
function World:getCampaignData()
  local world = {
    room_built = self.room_built,
    campaign_info = self.campaign_info,
    debug_disable_salary_raise = self.debug_disable_salary_raise,
  }
  return { world = world, hospital = self:getLocalPlayerHospital():getCampaignData() }
end

--! Restore the settings from the previous world
--!param campaign_data (table) world and hospital campaign data
function World:setCampaignData(campaign_data)
  for key, value in pairs(campaign_data.world) do
    self[key] = value
  end
  self:getLocalPlayerHospital():setCampaignData(campaign_data.hospital)
end
