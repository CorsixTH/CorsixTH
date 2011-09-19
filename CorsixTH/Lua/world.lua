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

local pathsep = package.config:sub(1, 1)
local TH = require"TH"
local ipairs, _G, table_remove
    = ipairs, _G, table.remove

dofile "entity"
dofile "room"
dofile "entities/object"
dofile "entities/humanoid"
dofile "entities/patient"
dofile "entities/vip"
dofile "entities/machine"
dofile "staff_profile"
dofile "hospital"
dofile "calls_dispatcher"
dofile "research_department"

--! Manages entities, rooms, and the date.
class "World"

local local_criteria_variable = {
  {name = "reputation",       icon = 10, formats = 2}, 
  {name = "balance",          icon = 11, formats = 2}, 
  {name = "percentage_cured", icon = 12, formats = 2}, 
  {name = "num_cured" ,       icon = 13, formats = 2}, 
  {name = "percentage_killed",icon = 14, formats = 2}, 
  {name = "value",            icon = 15, formats = 2}, 
  {name = "population",       icon = 11, formats = 1},
}
  
function World:World(app)
  self.map = app.map
  self.wall_types = app.walls
  self.object_types = app.objects
  self.anims = app.anims
  self.animation_manager = app.animation_manager
  self.pathfinder = TH.pathfinder()
  self.pathfinder:setMap(app.map.th)
  self.entities = {}
  self.dispatcher = CallsDispatcher(self)
  self.objects = {}
  self.object_counts = {
    extinguisher = 0,
    radiator = 0,
    plant = 0,
    reception_desk = 0,
    general = 0,
  }
  self.objects_notify_occupants = {}
  self.rooms = {} -- List that can have gaps when a room is deleted, so use pairs to iterate.

  -- Time
  self.hours_per_day = 50
  self.hours_per_tick = 1
  self.tick_rate = 3
  self.tick_timer = 0
  self.year = 1
  self.month = 1 -- January
  self.day = 1
  self.hour = 0

  self.debug_disable_salary_raise = false
  self.idle_cache = {}
  -- List of which goal criterion means what, and what number the corresponding icon has.
  self.level_criteria = local_criteria_variable
  self.room_build_callbacks = {--[[a set rather than a list]]}
  self.room_built = {} -- List of room types that have been built
  self.hospitals = {}
  self.floating_dollars = {}
  self.game_log = {} -- saves list of useful debugging information
  self.savegame_version = app.savegame_version
  
  self:initLevel(app)
  self.hospitals[1] = Hospital(self) -- Player's hospital
  self:initCompetitors()
  self:initRooms()

  -- TODO: Add (working) AI and/or multiplayer hospitals
  -- TODO: Needs to be changed for multiplayer support
  self:initStaff()
  self.wall_id_by_block_id = {}
  for _, wall_type in ipairs(self.wall_types) do
    for _, set in ipairs{"inside_tiles", "outside_tiles", "window_tiles"} do
      for name, id in pairs(wall_type[set]) do
        self.wall_id_by_block_id[id] = wall_type.id
      end
    end
  end
  self.wall_set_by_block_id = {}
  for _, wall_type in ipairs(self.wall_types) do
    for _, set in ipairs{"inside_tiles", "outside_tiles", "window_tiles"} do
      for name, id in pairs(wall_type[set]) do
        self.wall_set_by_block_id[id] = set
      end
    end
  end
  self.wall_dir_by_block_id = {}
  for _, wall_type in ipairs(self.wall_types) do
    for _, set in ipairs{"inside_tiles", "outside_tiles", "window_tiles"} do
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

  self:nextEmergency()
  self:nextVip()

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

--! Register key shortcuts for controling the world (game speed, etc.)
function World:setUI(ui)
  self.ui = ui
  self.ui:addKeyHandler("P", self, self.pauseOrUnpause, "Pause")
  self.ui:addKeyHandler("1", self, self.setSpeed, "Slowest")
  self.ui:addKeyHandler("2", self, self.setSpeed, "Slower")
  self.ui:addKeyHandler("3", self, self.setSpeed, "Normal")
  self.ui:addKeyHandler("4", self, self.setSpeed, "Max speed")
  self.ui:addKeyHandler("5", self, self.setSpeed, "And then some more")
  
  self.ui:addKeyHandler("+", self, self.adjustZoom,  1)
  self.ui:addKeyHandler("-", self, self.adjustZoom, -1)
end

function World:adjustZoom(delta)
  local scr_w = self.ui.app.config.width
  local virtual_width = scr_w / (self.ui.zoom_factor or 1)
  virtual_width = virtual_width - delta * 40
  if virtual_width < 200 then
    return false
  end
  return self.ui:setZoom(scr_w / virtual_width)
end

function World:initLevel(app)
  local level_config = self.map.level_config
  -- Determine available diseases
  self.available_diseases = {}
  local visual = level_config.visuals
  local non_visual = level_config.non_visuals
  local added_diseases = 0
  for i, disease in ipairs(app.diseases) do
    if not disease.pseudo then
      local vis = 1
      if visual and (visual[disease.visuals_id] or non_visual[disease.non_visuals_id]) then
        vis = disease.visuals_id and visual[disease.visuals_id].Value 
        or non_visual[disease.non_visuals_id].Value
      end
      if vis ~= 0 then
        self.available_diseases[#self.available_diseases + 1] = disease
        self.available_diseases[disease.id] = disease
        added_diseases = added_diseases + 1
      end
    end
  end
  if added_diseases == 0 then
    print("Warning: This level does not contain any diseases")
  end
  -- Alter build cost for all objects based on the current level.
  -- This does in practise make object.build_cost obsolete,
  -- but it will remain for now to avoid too many complications.
  -- TODO: Remove object.build_cost from all objects.
  -- A few places will need fixing to be able to do that.
  local config = self.map.level_config.objects
  for _, object in ipairs(app.objects) do
    local cost = 0
    if config[object.thob] then
      cost = config[object.thob].StartCost
    end
    object.build_cost = cost
  end
  self:determineWinningConditions()
end

function World:initStaff()
  local level_config = self.map.level_config
  local hosp = self.hospitals[1]
  if level_config.start_staff then
    local i = 0
    for n, conf in ipairs(level_config.start_staff) do
      local profile
      local skill = 0
      local added_staff = true
      if conf.Skill then
        skill = conf.Skill / 100
      end
      
      if conf.Nurse == 1 then
        profile = StaffProfile("Nurse", _S.staff_class["nurse"])
        profile:init(skill, self)
      elseif conf.Receptionist == 1 then
        profile = StaffProfile("Receptionist", _S.staff_class["receptionist"])
        profile:init(skill, self)
      elseif conf.Handyman == 1 then
        profile = StaffProfile("Handyman", _S.staff_class["handyman"])
        profile:init(skill, self)      
      elseif conf.Doctor == 1 then
        profile = StaffProfile("Doctor", _S.staff_class["doctor"])
        
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
        profile:initDoctor(shrink,surg,rsch,jr,cons,skill,self)
      else
        added_staff = false
      end
      if added_staff then
        local staff = self:newEntity("Staff", 2)
        staff:setProfile(profile)
        -- TODO: Make a somewhat "nicer" placing algorithm.
        staff:setTile(self.map.th:getCameraTile(1))
        staff:onPlaceInCorridor()
        hosp.staff[#hosp.staff + 1] = staff
        staff:setHospital(hosp)
      end
    end
  end
end

function World:determineWinningConditions()
  -- Determine winning and losing conditions
  local win = self.map.level_config.win_criteria
  local lose = self.map.level_config.lose_criteria
  local active = {}
  local total = 0
  local criteria = self.level_criteria
  -- There might be no winning criteria (i.e. the demo), then
  -- we don't have to worry about the progress report dialog
  -- since it doesn't exist anyway.
  if win then
    for _, values in pairs(win) do
      if values.Criteria ~= 0 then
        total = total + 1
        local criterion = criteria[values.Criteria].name
        active[criterion] = {
          name = criterion,
          win_value = values.Value, 
          boundary = values.Bound, 
          criterion = values.Criteria,
          max_min_win = values.MaxMin,
          group = values.Group,
          number = total,
        }
        active[#active + 1] = active[criterion]
      end
    end
  end
  -- Likewise there might be no losing criteria (i.e. the demo)
  if lose then
    for _, values in pairs(lose) do
      if values.Criteria ~= 0 then
        local criterion = criteria[values.Criteria].name
        if not active[criterion] then
          active[criterion] = {number = #active + 1, name = criterion}
          active[#active + 1] = active[criterion]
        end
        active[criterion].lose_value = values.Value
        active[criterion].boundary = values.Bound
        active[criterion].criterion = values.Criteria
        active[criterion].max_min_lose = values.MaxMin
        active[criterion].group = values.Group
        active[active[criterion].number].lose_value = values.Value
        active[active[criterion].number].boundary = values.Bound
        active[active[criterion].number].criterion = values.Criteria
        active[active[criterion].number].max_min_lose = values.MaxMin
        active[active[criterion].number].group = values.Group
      end
    end
  end
  
  -- Order the criteria (some icons in the progress report shouldn't be next to each other)
  table.sort(active, function(a,b) return a.criterion < b.criterion end)
  self.goals = active
  self.winning_goals = total
end

function World:initRooms()
  -- Combination of set and list. Use ipairs to iterate through all available rooms.
  self.available_rooms = {}
  
  local obj = self.map.level_config.objects
  local rooms = self.map.level_config.rooms
  for i, room in ipairs(TheApp.rooms) do
    -- Add build cost based on level files for all rooms.
    -- For now, sum it up so that the result is the same as before.
    -- TODO: Change the whole build process so that this value is 
    -- the room cost only? (without objects)
    local build_cost = rooms[room.level_config_id].Cost
    local available = true
    local is_discovered = true
    -- Make sure that all objects needed for this room are available
    for name, no in pairs(room.objects_needed) do
      local spec = obj[TheApp.objects[name].thob]
      if spec.AvailableForLevel == 0 then
        -- It won't be possible to build this room at all on the level.
        available = false
      elseif spec.StartAvail == 0 then
        -- Ok, it will be availabe at some point just not from the beginning.
        is_discovered = false
      end
      -- Add cost for this object.
      build_cost = build_cost + obj[TheApp.objects[name].thob].StartCost * no
    end
    -- Now define the total build cost for the room.
    for _, hospital in ipairs(self.hospitals) do
      hospital.research.research_progress[room] = {
        build_cost = build_cost,
      }
    end
    if available then
      self.available_rooms[#self.available_rooms + 1] = room
      self.available_rooms[room.id] = room
      
      if is_discovered then
        for _, hospital in ipairs(self.hospitals) do
          hospital.discovered_rooms[room] = true
        end
      else
        for _, hospital in ipairs(self.hospitals) do
          hospital.undiscovered_rooms[room] = true
        end
      end
    end
  end
end

function World:initCompetitors()
  -- Add computer players
  -- TODO: Right now they're only names
  local level_config = self.map.level_config
  for key, value in pairs(level_config.computer) do
    if value.Playing == 1 then
      self.hospitals[#self.hospitals + 1] = AIHospital(tonumber(key) + 1, self)
    end
  end
end

--! Initializes variables carried from previous levels
function World:initFromPreviousLevel(carry)
  for object, tab in pairs(carry) do
    if object == "world" then
      for key, value in pairs(tab) do
        self[key] = value
      end
    elseif object == "hospital" then
      for key, value in pairs(tab) do
        self.hospitals[1][key] = value
      end
    end
  end
end

function World:getLocalPlayerHospital()
  -- NB: UI code can get the hospital to use via ui.hospital
  -- TODO: Make this work in multiplayer?
  return self.hospitals[1]
end

-- Identify the tiles on the map suitable for spawning `Humanoid`s from.
function World:calculateSpawnTiles()
  self.spawn_points = {}
  local w, h = self.map.width, self.map.height
  for _, edge in ipairs{
    {direction = "north", origin = {1, 1}, step = { 1,  0}},
    {direction = "east" , origin = {w, 1}, step = { 0,  1}},
    {direction = "south", origin = {w, h}, step = {-1,  0}},
    {direction = "west" , origin = {1, h}, step = { 0, -1}},
  } do
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
      local index = 1 + math.floor((i - 1) / (num - 1) * (#xs - 1) + 0.5)
      self.spawn_points[#self.spawn_points + 1] = {x = xs[index], y = ys[index], direction = edge.direction}
    end
  end
end

function World:spawnPatient(hospital)
  -- The level might not contain any diseases
  if #self.available_diseases < 1 then
    return
  end
  assert(#self.spawn_points > 0, "Could not spawn patient because no spawn points are available. Please place walkable tiles on the edge of your level.")
  if not hospital then
    hospital = self:getLocalPlayerHospital()
  end
  if hospital:hasStaffedDesk() then
    local spawn_point = self.spawn_points[math.random(1, #self.spawn_points)]
    local patient = self:newEntity("Patient", 2)
    local disease = self.available_diseases[math.random(1, #self.available_diseases)]
    patient:setDisease(disease)
    patient:setNextAction{name = "spawn", mode = "spawn", point = spawn_point}
    patient:setHospital(hospital)
    
    return patient
  end
end

function World:spawnVIP(hospital)
  if not hospital then
    hospital = self:getLocalPlayerHospital()
  end

  hospital.announce_vip = 1
  
  local spawn_point = self.spawn_points[math.random(1, #self.spawn_points)]
  local vip = self:newEntity("Vip", 2)
  vip:setType "VIP"
  vip.enter_deaths = hospital.num_deaths
  vip.enter_visitors = hospital.num_visitors
  vip.enter_cures = hospital.num_cured

  vip.enter_explosions = hospital.num_explosions

  -- we need to know how many rooms vip visiting for room evaluation
  vip.enter_num_rooms = #self.rooms

  local spawn_point = self.spawn_points[math.random(1, #self.spawn_points)]
  vip:setNextAction{name = "spawn", mode = "spawn", point = spawn_point}
  vip:setHospital(hospital)
  vip:queueAction{name = "seek_reception"}
end

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
  local conf = self.map.level_config.staff_levels
  while conf[conf_entry + 1] and conf[conf_entry + 1].Month <= month do
    conf_entry = conf_entry + 1
  end
  self.available_staff = {}
  for _, info in ipairs(staff_to_make) do
    local num
    local ind = conf_entry
    while not num do
      assert(ind >= 0, "Staff amount " .. info.conf .. " not existent (should at least be given by base_config).")
      num = conf[ind][info.conf]
      ind = ind - 1
    end
    local group = {}
    for i = 1, num do
      group[i] = StaffProfile(info.class, _S.staff_class[info.name])
      group[i]:randomise(self, month)
    end
    self.available_staff[info.class] = group
  end
end

--[[ Register a callback for when `Humanoid`s enter or leave a given tile.
! Note that only one callback may be registered to each tile.
!param x (integer) The 1-based X co-ordinate of the tile to monitor.
!param y (integer) The 1-based Y co-ordinate of the tile to monitor.
!param object (Object) Something with an `onOccupantChange` method, which will
be called whenever a `Humanoid` enters or leaves the given tile. The method
will recieve one argument (after `self`), which will be `1` for an enter event
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

local flag_cache = {}
function World:createMapObjects(objects)
  self.delayed_map_objects = {}
  local map = self.map.th
  for _, object in ipairs(objects) do repeat
    local x, y, thob, flags = unpack(object)
    local object_id = self.object_id_by_thob[thob]
    if not object_id then
      print("Warning: Map contained object with unrecognised THOB (" .. thob .. ") at " .. x .. "," .. y)
      break -- continue
    end
    local object_type = self.object_types[object_id]
    if not object_type or not object_type.supports_creation_for_map then
      print("Warning: Unable to create map object " .. object_id .. " at " .. x .. "," .. y)
      break -- continue
    end
    -- Delay making objects which are on plots which haven't been purchased yet
    local parcel = map:getCellFlags(x, y, flag_cache).parcelId
    if parcel ~= 0 and map:getPlotOwner(parcel) == 0 then
      self.delayed_map_objects[{object_id, x, y, flags, "map object"}] = parcel
    else
      self:newObject(object_id, x, y, flags, "map object")
    end
  until true end
end

function World:setPlotOwner(parcel, owner)
  self.map.th:setPlotOwner(parcel, owner)
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

-- Register a function to be called whenever a room is built.
--!param callback (function) A function taking one argument: a `Room`.
function World:registerRoomBuildCallback(callback)
  self.room_build_callbacks[callback] = true
end

-- Unregister a function from being called whenever a room is built.
--!param callback (function) A function previously passed to
-- `registerRoomBuildCallback`.
function World:unregisterRoomBuildCallback(callback)
  self.room_build_callbacks[callback] = nil
end

function World:newRoom(x, y, w, h, room_info, ...)
  local id = #self.rooms + 1
  -- Note: Room IDs will be unique, but they may not form continuous values
  -- from 1, as IDs of deleted rooms may not be re-issued for a while
  local class = room_info.class and _G[room_info.class] or Room
  -- TODO: Take hospital based on the owner of the plot the room is built on
  local hospital = self.hospitals[1]
  local room = class(x, y, w, h, id, room_info, self, hospital, ...)
  
  self.rooms[id] = room
  self:clearCaches()
  return room
end

function World:markRoomAsBuilt(room)
  room:roomFinished()
  local diag_disease = self.hospitals[1].disease_casebook["diag_" .. room.room_info.id]
  if diag_disease and not diag_disease.discovered then
    self.hospitals[1].disease_casebook["diag_" .. room.room_info.id].discovered = true
  end
  for callback in pairs(self.room_build_callbacks) do
    callback(room)
  end
end

--! Clear all internal caches which are dependant upon map state / object position
function World:clearCaches()
  self.idle_cache = {}
end

function World:getWallIdFromBlockId(block_id)
  return self.wall_id_by_block_id[block_id]
end

function World:getWallSetFromBlockId(block_id)
  return self.wall_set_by_block_id[block_id]
end

function World:getWallDirFromBlockId(block_id)
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
  return self.month, self.day
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
}

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
  self.prev_speed = self:getCurrentSpeed()
  local numerator, denominator = unpack(tick_rates[speed])
  self.hours_per_tick = numerator
  self.tick_rate = denominator
end

-- Dedicated function to allow unpausing by pressing 'p' again
function World:pauseOrUnpause()
  if not self:isCurrentSpeed("Pause") then
    self:setSpeed("Pause")
  elseif self.prev_speed then
    self:setSpeed(self.prev_speed)
  end
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

-- World ticks are translated to game ticks (or hours) depending on the
-- current speed of the game. There are 50 hours in a TH day.
function World:onTick()
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
      local status, err = pcall(TheApp.save, TheApp, "Autosaves" .. pathsep .. "Autosave" .. self.month .. ".sav")
      if not status then
        print("Error while autosaving game: " .. err)
      end
    end
    if self.year == 1 and self.month == 1 and self.day == 1 and self.hour == 0 then
      if not self.ui.start_tutorial then
        self.ui:addWindow(UIWatch(self.ui, "initial_opening"))
        self.ui:showBriefing()
      end
    end
    self.tick_timer = self.tick_rate
    self.hour = self.hour + self.hours_per_tick

    -- End of day/month/year
    if self.hour >= self.hours_per_day then
      for _, hospital in ipairs(self.hospitals) do
        hospital:onEndDay()
      end
      self:onEndDay()
      self.hour = self.hour - self.hours_per_day
      self.day = self.day + 1
      if self.day > month_length[self.month] then
        self.day = month_length[self.month]
        for _, hospital in ipairs(self.hospitals) do
          hospital:onEndMonth()
        end
        -- Let the hospitals do what they need to do at end of month first.
        if self:onEndMonth() then
          -- Bail out as the game has already been ended.
          return
        end
        self.day = 1
        self.month = self.month + 1
        -- A temporary solution to make players more aware of the need for radiators
        if self.month == 6 and self.year == 1 then
          local warmth = 0
          local no = 0
          for _, staff in ipairs(self.hospitals[1].staff) do
            warmth = warmth + staff.attributes["warmth"]
            no = no + 1
          end
          if warmth / no < 0.5 then
            self.ui.adviser:say(_S.adviser.information.initial_general_advice.place_radiators)
          end
        end
        if self.month > 12 then
          self.month = 12
          if self.year == 1 then
            for _, hospital in ipairs(self.hospitals) do
              hospital.initial_grace = false
            end
          end
          -- It is crucial that the annual report gets to initialize before onEndYear is called.
          -- Yearly statistics are reset there.
          self.ui:addWindow(UIAnnualReport(self.ui, self))
          self:onEndYear()
          self.year = self.year + 1
          self.month = 1
        end
      end
    end
    for i = 1, self.hours_per_tick do
      for _, hospital in ipairs(self.hospitals) do
        hospital:tick()
      end
      -- A patient might arrive to the player hospital.
      -- TODO: Multiplayer support.
      if self.spawn_hours[self.hour + i-1] and self.hospitals[1].opened then
        for k=1, self.spawn_hours[self.hour + i-1] do
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
      self.map.th:updateTemperatures(outside_temperatures[self.month],
        0.25 + self.hospitals[1].radiator_heat * 0.3)
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
  self.day = month_length[self.month]
  self.hour = self.hours_per_day - 1
end

function World:setEndYear()
  self.month = 12
  self:setEndMonth()
end

-- Called immediately prior to the ingame day changing.
function World:onEndDay()
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
  if (self.year - 1) * 12 + self.month == self.next_vip_month
  and self.day == self.next_vip_day then
    if #self.rooms > 0 and self.ui.hospital:hasStaffedDesk() then
      self.hospitals[1]:createVip()
    else
      self:nextVip()
    end
  end

  -- Maybe it's time for an emergency?
  if (self.year - 1) * 12 + self.month == self.next_emergency_month 
  and self.day == self.next_emergency_day then
    -- Postpone it if anything clock related is already underway.
    if self.ui:getWindow(UIWatch) then
      self.next_emergency_month = self.next_emergency_month + 1
      self.next_emergency_day = math.random(1, month_length[self.next_emergency_month])
    else
      -- Do it only for the player hospital for now. TODO: Multiplayer
      local control = self.map.level_config.emergency_control
      if control[0].Mean or control[0].Random then
        -- The level uses random emergencies, so just create one.
        self.hospitals[1]:createEmergency()
      else
        control = control[self.next_emergency_no]
        -- Find out which disease the emergency patients have.
        local disease
        for _, dis in ipairs(TheApp.diseases) do
          if dis.expertise_id == control.Illness then
            disease = dis
            break
          end
        end
        if not disease then
          -- Unknown disease! Create a random one instead.
          self.hospitals[1]:createEmergency()
        else
          local emergency = {
            disease = disease,
            victims = math.random(control.Min, control.Max),
            bonus = control.Bonus,
            percentage = control.PercWin/100,
            killed_emergency_patients = 0,
            cured_emergency_patients = 0,
          }
          self.hospitals[1]:createEmergency(emergency)
        end
      end
    end
  end
  -- Any patients tomorrow?
  self.spawn_hours = {}
  if self.spawn_dates[self.day] then
    for i = 1, self.spawn_dates[self.day] do
      local hour = math.random(1, self.hours_per_day)
      self.spawn_hours[hour] = self.spawn_hours[hour] and self.spawn_hours[hour] + 1 or 1
    end
  end
  -- TODO: Do other regular things? Such as checking if any room needs
  -- staff at the moment and making plants need water.
end

-- Called immediately prior to the ingame month changing.
-- returns true if the game was killed due to the player losing
function World:onEndMonth()
  -- Check if a player has won the level.
  -- TODO.... this is a step closer to the way TH would check.
  -- What is missing is that if offer is declined then the next check should be
  -- either 6 months later or at the end of month 12 and then every 6 months
  if self.month % 3 == 0 then
    for i, hospital in ipairs(self.hospitals) do
      local res = self:checkWinningConditions(i)
      if res.state == "win" then
        self:winGame(i)
      end
    end
  end

  -- Change population share for the hospitals, TODO according to reputation.
  -- Since there are no competitors yet the player's hospital can be considered
  -- to be fairly good no matter what it looks like, so after gbv.AllocDelay
  -- months, change the share to half of the new people.
  if self.month >= self.map.level_config.gbv.AllocDelay then
    self:getLocalPlayerHospital().population = 0.5
  end

  -- Also possibly change world spawn rate according to the level configuration.
  local index = 0
  local popn = self.map.level_config.popn
  while popn[index] do
    if popn[index].Month == self.month + (self.year - 1)*12 then
      self.monthly_spawn_increase = popn[index].Change
      break
    end
    index = index + 1
  end
  -- Now set the new spawn rate
  self.spawn_rate = self.spawn_rate + self.monthly_spawn_increase
  self:updateSpawnDates()

  self:makeAvailableStaff((self.year - 1) * 12 + self.month)
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
  -- Set dates when people arrive
  local no_of_spawns = math.n_random(self.spawn_rate, 2)
  -- Use ceil so that at least one patient arrives (unless population = 0)
  no_of_spawns = math.ceil(no_of_spawns*self:getLocalPlayerHospital().population)
  self.spawn_dates = {}
  for i = 1, no_of_spawns do
    -- We are interested in the coming month, pick days from it at random.
    local day = math.random(1, month_length[self.month % 12 + 1])
    self.spawn_dates[day] = self.spawn_dates[day] and self.spawn_dates[day] + 1 or 1
  end
end

-- Called when it is time to determine what the 
-- next emergency should look like.
function World:nextEmergency()
  local control = self.map.level_config.emergency_control
  local current_month = (self.year - 1) * 12 + self.month
  -- Does this level use random emergencies?
  if control and (control[0].Random or control[0].Mean) then
    -- Support standard values for mean and variance
    local mean = control[0].Mean or 180
    local variance = control[0].Variance or 30
    -- How many days until next emergency?
    local days = math.round(math.n_random(mean, variance))
    local next_month = self.month
    
    -- Walk forward to get the resulting month and day.
    if days > month_length[next_month] - self.day then
      days = days - (month_length[next_month] - self.day)
      next_month = next_month + 1
    end
    while days > month_length[(next_month - 1) % 12 + 1] do
      days = days - month_length[(next_month - 1) % 12 + 1]
      next_month = next_month + 1
    end
    -- Make it the same format as for "controlled" emergencies
    self.next_emergency_month = next_month + (self.year - 1) * 12
    self.next_emergency_day = days
  else
    if not self.next_emergency_no then
      self.next_emergency_no = 0
    else
      repeat
        self.next_emergency_no = self.next_emergency_no + 1
        -- Level three is missing [5].
        if not control[self.next_emergency_no] 
        and control[self.next_emergency_no + 1] then
          self.next_emergency_no = self.next_emergency_no + 1
        end
      until not control[self.next_emergency_no]
      or control[self.next_emergency_no].EndMonth >= current_month
    end

    local emergency = control[self.next_emergency_no]

    -- No more emergencies?
    if not emergency or emergency.EndMonth == 0 then
      self.next_emergency_month = 0
    else
      -- Generate the next month and day the emergency should occur at.
      -- Make sure it doesn't happen in the past.
      local start = math.max(emergency.StartMonth, self.month + (self.year - 1) * 12)
      local next_month = math.random(start, emergency.EndMonth)
      self.next_emergency_month = next_month
      local day_start = 1
      if start == emergency.EndMonth then
        day_start = self.day
      end
      local day_end = month_length[(next_month - 1) % 12 + 1]
      self.next_emergency_day = math.random(day_start, day_end)
    end
  end
end

-- Called when it is time to have another VIP
function World:nextVip()
  local current_month = (self.year - 1) * 12 + self.month

  -- Support standard values for mean and variance
  local mean = 180
  local variance = 30
  -- How many days until next vip?
  local days = math.round(math.n_random(mean, variance))
  local next_month = self.month

  -- Walk forward to get the resulting month and day.
  if days > month_length[next_month] - self.day then
    days = days - (month_length[next_month] - self.day)
    next_month = next_month + 1
  end
  while days > month_length[(next_month - 1) % 12 + 1] do
    days = days - month_length[(next_month - 1) % 12 + 1]
    next_month = next_month + 1
  end
  self.next_vip_month = next_month + (self.year - 1) * 12
  self.next_vip_day = days
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
  for i, goal in ipairs(self.goals) do
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
      if (current_value - goal.lose_value)*max_min > 0 then
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
      if (current_value - goal.win_value)*max_min <= 0 then
        result.state = "nothing"
      end
    end
  end
  return result
end

function World:winGame(player_no)
  if player_no == 1 then -- Player won. TODO: Needs to be changed for multiplayer
    local text = {}
    local choice_text, choice
    local bonus_rate = math.random(4,9)
    local with_bonus = self.ui.hospital.cheated and 0 or (self.ui.hospital.player_salary * bonus_rate) / 100
    self.ui.hospital.salary_offer = math.floor(self.ui.hospital.player_salary + with_bonus)
    if tonumber(self.map.level_number) then
      local no = tonumber(self.map.level_number)
      local repeated_offer = false -- TODO whether player was asked previously to advance and declined
      local has_next = no < 12 and not TheApp.using_demo_files
      -- Letters 1-4  normal
      -- Letters 5-8  repeated offer
      -- Letters 9-12 last level
      local letter_idx = math.random(1, 4) + (not has_next and 8 or repeated_offer and 4 or 0)
      for key, value in ipairs(_S.letter[letter_idx]) do
        text[key] = value
      end
      text[1] = text[1]:format(self.hospitals[player_no].name)
      text[2] = text[2]:format(self.hospitals[player_no].salary_offer)
      text[3] = text[3]:format(_S.level_names[self.map.level_number + 1])
      if no < 12 then
        choice_text = _S.fax.choices.accept_new_level
        choice = 1
      else
        choice_text = _S.fax.choices.return_to_main_menu
        choice = 2
      end
    else
      -- TODO: When custom levels can contain sentences this should be changed to something better.
      text[1] = _S.letter.dear_player:format(self.hospitals[player_no].name)
      text[2] = _S.letter.custom_level_completed
      text[3] = _S.letter.return_to_main_menu
      choice_text = _S.fax.choices.return_to_main_menu
      choice = 2
    end
    local message = {
      {text = text[1]},
      {text = text[2]},
      {text = text[3]},
      choices = {
        {text = choice_text,  choice = choice == 1 and "accept_new_level" or "return_to_main_menu"},
        {text = _S.fax.choices.decline_new_level, choice = "stay_on_level"},
      },
    }
    self.ui.bottom_panel:queueMessage("information", message, nil, 28*24, 2)
  end
end

--! Cause the player with the player number player_no to lose.
--!param player_no (number) The number of the player which should lose.
--!param reason (string) [optional] The name of the criterion the player lost to.
--!param limit (number) [optional] The number the player went over/under which caused him to lose.
function World:loseGame(player_no, reason, limit)
  if player_no == 1 then -- TODO: Multiplayer
    local message = {_S.information.level_lost[1]}
    if reason then
      message[2] = _S.information.level_lost[2]
      message[3] = _S.information.level_lost[reason]:format(limit)
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
  for i, hospital in ipairs(self.hospitals) do
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
--!param x1 (integer) X-cordinate of first tile's Lua tile co-ordinates.
--!param y1 (integer) Y-cordinate of first tile's Lua tile co-ordinates.
--!param x2 (integer) X-cordinate of second tile's Lua tile co-ordinates.
--!param y2 (integer) Y-cordinate of second tile's Lua tile co-ordinates.
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

local face_dir = {
  [0] = "south",
  [1] = "west",
  [2] = "north",
  [3] = "east",
}

function World:getFreeBench(x, y, distance)
  local bench, rx, ry, bench_distance
  local object_type = self.object_types.bench
  self.pathfinder:findObject(x, y, object_type.thob, distance, function(x, y, d, dist)
    local b = self:getObject(x, y, "bench")
    if b and not b.user and not b.reserved_for then
      local orientation = object_type.orientations[b.direction]
      if orientation.pathfind_allowed_dirs[d] then
        rx = x + orientation.use_position[1]
        ry = y + orientation.use_position[2]
        bench = b
        bench_distance = dist
        return true
      end
    end
  end)
  return bench, rx, ry, bench_distance
end

-- This helper function checks if the given tile is part of a nearby object (walkable tiles count as part of the object)
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
    distance = 20
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
  
  local callback = function(x, y, d)
    local obj = self:getObject(x, y, object_type_name)
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
      local obj = self:getObject(x, y, object_type_name)
      if obj then
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
  -- These return values are only relevent for the default callback - are nil
  -- for custom callbacks
  return obj, ox, oy
end

function World:findFreeObjectNearToUse(humanoid, object_type_name, which, current_object)
  -- If which == nil or false, then the nearest object is taken.
  -- If which == "far", then the furthest object is taken.
  -- If which == "near", then the nearest object is taken with 50% probabilty, the second nearest with 25%, and so on
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
      if d > distance then
        break -- continue
      end
      local this_score = d
      if mode == "advanced" then
        this_score = this_score + r:getUsageScore()
        -- Add constant penalty if queue is full
        if r.door.queue:isFull() then
          this_score = this_score + 1000
        end
      end
      if not score or this_score < score then
        score = this_score
        room = r
      end
    end
  until true end
  return room
end

function World:newFloatingDollarSign(patient, amount)
  if not self.floating_dollars then
    self.floating_dollars = {}
  end
  
  local spritelist = TH.spriteList()
  spritelist:setPosition(-17, -60)
  spritelist:setSpeed(0, -1):setLifetime(100)
  spritelist:setSheet(TheApp.gfx:loadSpriteTable("Data", "Money01V"))
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

--! Creates a new object by finding the object_type from the "id" variable and 
--  calls its class constructor.
--!param id (string) The unique id of the object to be created.
--!return The created object.
function World:newObject(id, ...)
  local object_type = self.object_types[id]
  local entity
  if object_type.class then
    entity = _G[object_type.class](self, object_type, ...)
  elseif object_type.default_strength then
    entity = Machine(self, object_type, ...)
    -- Tell the player if there is no handyman to take care of the new machinery.
    if not self.hospitals[1]:hasStaffOfCategory("Handyman") then
      self.ui.adviser:say(_S.adviser.staff_advice.need_handyman_machines)
    end
  else
    entity = Object(self, object_type, ...)
  end
  self:objectPlaced(entity, id)
  return entity
end

--! Notifies the world that an object has been placed, notifying 
--  interested entities in the vicinity of the new arrival.
--!param entity (Entity) The entity that was just placed.
--!param id (string) That entity's id.
function World:objectPlaced(entity, id)
  -- If id is not supplied, we can use the entities internal id if it exists
  -- This is so the bench check below works
  -- see place_object.lua:UIPlaceObjects:placeObject for call w/o id --cgj
  if not id and entity.object_type.id then
    id = entity.object_type.id
  end

  self.entities[#self.entities + 1] = entity
  -- If it is a bench we're placing, notify queueing patients in the vicinity
  if id == "bench" and entity.tile_x and entity.tile_y then
    for _, patient in ipairs(self.entities) do
      if class.is(patient, Patient) then
        if math.abs(patient.tile_x - entity.tile_x) < 7 and 
          math.abs(patient.tile_y - entity.tile_y) < 7 then
          patient:notifyNewObject(id)
        end
      end
    end
  end
  if id == "reception_desk" and not self.ui.start_tutorial
    and not self.hospitals[1]:hasStaffOfCategory("Receptionist") then
    -- TODO: Will not work correctly for multiplayer
    self.ui.adviser:say(_S.adviser.room_requirements.reception_need_receptionist)
  end
  -- If it is a plant it might be advisable to hire a handyman
  if id == "plant" and not self.hospitals[1]:hasStaffOfCategory("Handyman") then
    self.ui.adviser:say(_S.adviser.staff_advice.need_handyman_plants)
  end
end

--! Notify the world of an object being removed from a tile
--! See also `World:addObjectToTile`
--!param object (Object) The object being removed.
--!param x (integer) The X-coordinate of the tile which the object was on
--!param y (integer) The Y-coordinate of the tile which the object was on
function World:removeObjectFromTile(object, x, y)
  local index = (y - 1) * self.map.width + x
  local objects = self.objects[index]
  if objects then
    for k, v in ipairs(objects) do
      if v == object then
        table_remove(objects, k)
        if k == 1 then
          if objects[1] then
            self.map.th:setCellFlags(x, y, {thob = objects[1].object_type.thob})
          else
            self.map.th:setCellFlags(x, y, {thob = 0})
          end
        end
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
    if #objects >= 1 then
      -- Until it is clear how multiple objects will work, this warning should
      -- be in place. In most cases, having multiple objects on a tile should
      -- be impossible, but there are some edge cases like having two radiators
      -- or bins on a tile which need thinking about.
      print("Warning: Multiple objects on tile " .. x .. "," .. y .. " - only one will be encoded")
    else
      self.map.th:setCellFlags(x, y, {thob = object.object_type.thob})
    end
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

function World:getObjects(x, y)
  local index = (y - 1) * self.map.width + x
  return self.objects[index]
end

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

function World:getRoom(x, y)
  return self.rooms[self.map:getRoomId(x, y)]
end

--! Returns localized name of the room, internal required staff name
-- and localized name of staff required.
function World:getRoomNameAndRequiredStaffName(room_id)
  local room_name, required_staff, staff_name
  for _, room in ipairs(TheApp.rooms) do
    if room.id == room_id then
      room_name = room.name
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
end

--! Dump the contents of the game log into a file.
-- This is automatically done on each error.
function World:dumpGameLog()
  local config_path = TheApp.command_line["config-file"] or ""
  local pathsep = package.config:sub(1, 1)
  config_path = config_path:match("^(.-)[^".. pathsep .."]*$")
  local gamelog_path = config_path .. "gamelog.txt"
  local fi, err = io.open(gamelog_path, "w")
  if fi then
    for _, str in ipairs(self.game_log) do
      fi:write(str .. "\n")
    end
    fi:close()
  else
    print("Warning: Cannot dump game log: " .. tostring(err))
  end
end

function World:afterLoad(old, new)
  for _, cat in pairs({self.entities, self.rooms, self.hospitals}) do
    for _, obj in pairs(cat) do
      obj:afterLoad(old, new)
    end
  end
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
    for position, obj_list in pairs(self.objects) do
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
    for position, obj_list in pairs(self.objects) do
      for _, obj in ipairs(obj_list) do
        local count_cat = obj.object_type.count_category
        if count_cat and count_cat == "reception_desk" then
          self.object_counts[count_cat] = self.object_counts[count_cat] + 1
        end
      end
    end
  end
  if old < 12 then
    self.animation_manager = TheApp.animation_manager
    self.anim_length_cache = nil
  end
  if old < 16 then
    self.ui:addKeyHandler("+", self, self.adjustZoom,  1)
    self.ui:addKeyHandler("-", self, self.adjustZoom, -1)
  end
  if old < 17 then
    -- Added another object
    local _, shield = pcall(dofile, "objects" .. pathsep .. "radiation_shield")
    local _, shield_b = pcall(dofile, "objects" .. pathsep .. "radiation_shield_b")
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
  self.savegame_version = new
end
