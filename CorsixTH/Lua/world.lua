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

dofile "entity"
dofile "room"
dofile "entities/object"
dofile "entities/humanoid"
dofile "entities/patient"
dofile "entities/machine"
dofile "staff_profile"
dofile "hospital"

class "World"

function World:World(app)
  self.map = app.map
  self.wall_types = app.walls
  self.object_types = app.objects
  self.anims = app.anims
  self.anim_length_cache = {}
  self.pathfinder = TH.pathfinder()
  self.pathfinder:setMap(app.map.th)
  self.entities = {}
  self.objects = {}
  self.objects_notify_occupants = {}
  self.rooms = {}
  self.ticks_per_tick = 1
  self.tick_rate = 3
  self.tick_timer = 0
  self.year = 1
  self.month = 1 -- January
  self.day = 1
  self.hour = 0
  self.debug_disable_salary_raise = false
  self.idle_cache = {}
  self:initLevel(app)
  self.room_build_callbacks = {--[[a set rather than a list]]}
  self.room_built = {} -- List of room types that have been built
  self.hospitals = {}
  self.floating_dollars = {}
  self.game_log = {} -- saves list of useful debugging information
  self.savegame_version = app.savegame_version
  
  self.hospitals[1] = Hospital(self) -- Player's hospital
  self:initCompetitors()
  -- TODO: Add (working) AI and/or multiplayer hospitals
  
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
  self:makeAvailableStaff()
  self:calculateSpawnTiles()
  
  self:gameLog("Created game with savegame version " .. self.savegame_version .. ".")
end

function World:setUI(ui)
  self.ui = ui
  self.ui:addKeyHandler("P", self, self.pauseOrUnpause, "Pause")
  self.ui:addKeyHandler("1", self, self.setSpeed, "Slowest")
  self.ui:addKeyHandler("2", self, self.setSpeed, "Slower")
  self.ui:addKeyHandler("3", self, self.setSpeed, "Normal")
  self.ui:addKeyHandler("4", self, self.setSpeed, "Max speed")
  self.ui:addKeyHandler("5", self, self.setSpeed, "And then some more")
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
  -- Determine available rooms from their required objects
  self.available_rooms = {}
  local obj = level_config.objects
  for i, room in ipairs(app.rooms) do
    local avail = 1
    if obj and room.level_config_id and obj[room.level_config_id] then
      avail = obj[room.level_config_id].AvailableForLevel
    end
    if avail == 1 then
      if obj and room.level_config_id and obj[room.level_config_id] then
        room.discovered = obj[room.level_config_id].StartAvail == 1 and true or false
      else
        room.discovered = true
      end
      self.available_rooms[#self.available_rooms + 1] = room
      self.available_rooms[room.id] = room
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

function World:getLocalPlayerHospital()
  -- NB: UI code can get the hospital to use via ui.hospital
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
  if not hospital then
    hospital = self:getLocalPlayerHospital()
  end
  local spawn_point = self.spawn_points[math.random(1, #self.spawn_points)]
  local patient = self:newEntity("Patient", 2)
  local disease = self.available_diseases[math.random(1, #self.available_diseases)]
  patient:setDisease(disease)
  patient:setNextAction{name = "spawn", mode = "spawn", point = spawn_point}
  patient:setHospital(hospital)
  
  return patient
end

function World:makeDebugPatient(hospital)
  if not hospital then
    hospital = self:getLocalPlayerHospital()
  end

  local patient = self:newEntity("Patient", 2)
  patient.is_debug = true
  table.insert(hospital.debug_patients, patient)
--  local disease = -- should they have one? hmm... no, for now not. May cause some errors if sent into rooms with staff.
  
  local types = {
    -- Types with variations doubled up to make them more likely:
    "Standard Male Patient", "Standard Male Patient",
    "Alternate Male Patient", "Alternate Male Patient",
    "Slack Male Patient", "Slack Male Patient",
    "Transparent Male Patient", "Transparent Male Patient",
    "Standard Female Patient", "Standard Female Patient",
    "Transparent Female Patient", "Transparent Female Patient",
    -- Types with no variation:
    "Chewbacca Patient",
    "Elvis Patient",
    "Invisible Patient",
  }
  
  patient:setType(types[math.random(1, #types)])
  patient:setTile(64, 64) -- center of map
  patient:setLayer(0, math.random(1, 4) * 2)
  patient:setLayer(1, math.random(0, 3) * 2)
  patient:setLayer(2, math.random(0, 2) * 2)
  patient:setLayer(3, math.random(0, 5) * 2)
  patient:setLayer(4, math.random(0, 5) * 2)
  patient:setMood("emergency", "activate") -- temporary, to make debug patients distinguishable from normal ones
  patient:setHospital(hospital)
  
  return patient
end

function World:debugDisableSalaryRaise(mode)
  self.debug_disable_salary_raise = mode
end

function World:makeAvailableStaff()
  self.available_staff = {}
  for class, local_string in pairs {
    Doctor = _S.staff_class.doctor,
    Nurse = _S.staff_class.nurse,
    Handyman = _S.staff_class.handyman,
    Receptionist = _S.staff_class.receptionist,
    } do
    local group = {}
    for i = 1, math.random(3, 12) do
      group[i] = StaffProfile(class, local_string)
      group[i]:randomise()
    end
    self.available_staff[class] = group
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

function World:createMapObjects(objects)
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
    self:newObject(object_id, x, y, flags, "map object")
  until true end
end

function World:getAnimLength(anim)
  if not self.anim_length_cache[anim] then
    local length = 0
    local seen = {}
    local frame = self.anims:getFirstFrame(anim)
    while not seen[frame] do
      seen[frame] = true
      length = length + 1
      frame = self.anims:getNextFrame(frame)
    end
    self.anim_length_cache[anim] = length
  end
  return self.anim_length_cache[anim]
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

local tick_rates = {
  ["Pause"]              = {0, 1},
  ["Slowest"]            = {1, 9},
  ["Slower"]             = {1, 5},
  ["Normal"]             = {1, 3},
  ["Max speed"]          = {1, 1},
  ["And then some more"] = {3, 1},
}

function World:isCurrentSpeed(speed)
  local numerator, denominator = unpack(tick_rates[speed])
  return self.ticks_per_tick == numerator and self.tick_rate == denominator
end

function World:getCurrentSpeed()
  for name, rate in pairs(tick_rates) do
    if rate[1] == self.ticks_per_tick and rate[2] == self.tick_rate then
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
  self.ticks_per_tick = numerator
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

function World:onTick()
  if self.tick_timer == 0 then
    if self.autosave_next_tick then
      self.autosave_next_tick = nil
      local status, err = pcall(SaveGameFile, "CorsixTH-Auto.sav")
      if not status then
        print("Error while autosaving game: " .. err)
      end
    end
    if self.year == 1 and self.month == 1 and self.day == 1 and self.hour == 0 then
      if self.map.level_number then
        local text = {_S.information.custom_game}
        if type(self.map.level_number) == "number" then
          text = _S.introduction_texts["level" .. self.map.level_number]
        end
        self.ui:addWindow(UIInformation(self.ui, text))
      end
      local message = {
        {             text = _S.fax.tutorial[1]},
        {offset =  8, text = _S.fax.tutorial[2]},
        choices = {
          {text = _S.fax.tutorial[3], choice = "tutorial"},
          {text = _S.fax.tutorial[4], choice = "no_tutorial"},
        },
      }
      self.ui.bottom_panel:queueMessage("information", message)
    end
    self.tick_timer = self.tick_rate
    self.hour = self.hour + self.ticks_per_tick
    -- There doesn't need to be 24 hours in a day. Whatever value gives the
    -- best ingame speed can be used, but 24 works OK and is a good starting
    -- point. Vanilla TH appears to take ~3 seconds per day at normal speed.
    -- With ~33 ticks/sec, reduced to 11 /sec at normal speed, 3 seconds -> 33
    -- ticks, which is 1 day and 9 hours.
    if self.hour >= 24 then
      self.hour = self.hour - 24
      self.day = self.day + 1
      if self.day > month_length[self.month] then
        self.day = month_length[self.month]
        self:onEndMonth()
        for _, hospital in ipairs(self.hospitals) do
          hospital:onEndMonth()
        end
        self.day = 1
        self.month = self.month + 1
        if self.month > 12 then
          self.month = 12
          self:onEndYear()
          self.year = self.year + 1
          self.month = 1
        end
      end
      for _, entity in ipairs(self.entities) do
        if entity.ticks and class.is(entity, Humanoid) then
          self.current_tick_entity = entity
          entity:tickDay()
        elseif class.is(entity, Plant) then
          entity:tickDay()
        end
      end
      self.current_tick_entity = nil
      -- Emergencies may arrive now and then - though not too often.
      local last_emergency  = (self.time_since_emergency and self.time_since_emergency or 0) + 1
      if last_emergency > 180 then
        -- More and more likely as time goes on, TODO: balance...
        -- Avoid making a new emergency if one is already underway or any other watch-related
        -- scenario is active.
        if not self.ui:getWindow(UIWatch) and math.random(1, last_emergency) > 150 then
          self.hospitals[1]:createEmergency()
          last_emergency = 0
        end
      end
      self.time_since_emergency = last_emergency
      -- TODO: Do other regular things, such as checking if any room needs
      -- staff at the moment and making plants need water.
    end
    for i = 1, self.ticks_per_tick do
      for _, hospital in ipairs(self.hospitals) do
        hospital:tick()
      end
      for _, entity in ipairs(self.entities) do
        if entity.ticks then
          self.current_tick_entity = entity
          entity:tick()
        end
      end
      self.current_tick_entity = nil
      self.map:onTick()
      if self.ui then
        self.ui:onWorldTick()
      end
    end
  end
  if self.ticks_per_tick > 0 and self.floating_dollars then
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

-- Called immediately prior to the ingame month changing.
function World:onEndMonth()
  self:makeAvailableStaff()
  self.autosave_next_tick = true
  for _, entity in ipairs(self.entities) do
    if entity.checkForDeadlock then
      self.current_tick_entity = entity
      entity:checkForDeadlock()
    end
  end
  self.current_tick_entity = nil
end

-- Called immediately prior to the ingame year changing.
function World:onEndYear()
  -- TODO: Temporary, until research is in the game. This is just so that something happens...
  for _, room in pairs(self.available_rooms) do
    if not room.discovered then
      room.discovered = true
      self.ui.adviser:say(_S.adviser.research.new_available:format(room.name))
      break
    end
  end
end

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

-- returns a set of all objects near the given position
function World:findAllObjectsNear(x, y, distance)
  if not distance then
    -- Note that regardless of distance, only the room which the humanoid is in
    -- is searched (or the corridor if the humanoid is not in a room).
    distance = 20
  end
  local objects = {}
  local callback = function(x, y, d)
    local obj = self:getObject(x, y)
    if obj then
      objects[obj] = true
    end
  end
  self.pathfinder:findObject(x, y, 0, distance, callback)
  return objects
end

function World:findObjectNear(humanoid, object_type_name, distance, callback)
  if not distance then
    -- Note that regardless of distance, only the room which the humanoid is in
    -- is searched (or the corridor if the humanoid is not in a room).
    distance = 2^30
  end
  local obj, ox, oy
  if not callback then
    -- The default callback returns the first object found, along with its
    -- usage tile position. Note that this may return an object already being
    -- used - if you want to find an object not in use (in order to use it),
    -- then call findFreeObjectNearToUse instead.
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
  self.pathfinder:findObject(humanoid.tile_x, humanoid.tile_y,
    self.object_types[object_type_name].thob, distance, callback)
  -- These return values are only relevent for the default callback - are nil
  -- for custom callbacks
  return obj, ox, oy
end

function World:findFreeObjectNearToUse(humanoid, object_type_name, distance, which, current_object)
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
  for _, r in ipairs(self.rooms) do repeat
    if r.built and (not room_type_id or r.room_info.id == room_type_id) and r.is_active then
      local x, y = r:getEntranceXY(false)
      local d = self:getPathDistance(humanoid.tile_x, humanoid.tile_y, x, y)
      if d > distance then
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

function World:newObject(id, ...)
  local object_type = self.object_types[id]
  local entity
  if object_type.class then
    entity = _G[object_type.class](self, object_type, ...)
  elseif object_type.default_strength then
    entity = Machine(self, object_type, ...)
  else
    entity = Object(self, object_type, ...)
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
  return entity
end

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
        return true
      end
    end
  end
  return false
end

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

-- Search for available staff to meet the requirements for the room. Also notify the player with a sound.
function World:callForStaff(room, repair_object, urgent)
  -- Don't do anything if the room is being edited.
  if not room.is_active then
    return
  end
  if repair_object then
    if urgent then
      local sound = room.room_info.handyman_call_sound
      if sound then
        self.ui:playAnnouncement(sound)
        self.ui:playSound "machwarn.wav"
      end
    end
    local handyman = self:selectNearestStaffForRoom(room, "Handyman", 1, "repairing")
    if handyman then
      room.needs_repair = handyman
      repair_object:setRepairing(true)
      local x, y = repair_object:getRepairTile()
      handyman:queueAction{
        name = "walk",
        x = x,
        y = y,
      }
      handyman:queueAction(repair_object:createRepairAction(handyman))
      handyman:queueAction(room:createLeaveAction())
      handyman:queueAction{name = "meander"}
      handyman:setDynamicInfoText(_S.dynamic_info.staff.actions.going_to_repair
        :format(repair_object.object_type.name))
    else
      -- Different messages depending on if any handyman has been hired yet or not.
      if self.hospitals[1]:hasStaffOfCategory("Handyman") then
        self.ui.adviser:say(_S.adviser.warnings.machines_falling_apart)
      else
        self.ui.adviser:say(_S(28, 34))
      end
    end
  else
    local missing = room:getMissingStaff(room:getRequiredStaffCriteria(), true)
    local sound = room.room_info.call_sound
    for attribute, count in pairs(missing) do
      self:selectNearestStaffForRoom(room, attribute, count)
      if sound and not room.sound_played and count > 0 then
        self.ui:playAnnouncement(sound)
        room.sound_played = true
      end
    end
  end
end
-- Finds staff with the given attributes within 'distance' from the point (x,y).
-- If 'mode' is set to one of the handyman's three concentration areas those
-- will be accounted for when doing the sort. 
function World:getSuitableStaffCandidates(x, y, attribute, distance, mode)
  local candidates = {}
  if not distance then
    distance = 2^30
  end
  for _, e in ipairs(self.entities) do
    if class.is(e, Staff) and e:fulfillsCriterium(attribute) and e:isIdle() then
      local dist = self:getPathDistance(e.tile_x, e.tile_y, x, y)
      if dist and dist < distance then
        if mode and e.attributes[mode] then
          dist = dist + (1 - e.attributes[mode]) * 10
        end
        candidates[#candidates + 1] = {
          entity = e,
          dist = dist,
        }
      end
    end
  end

  table.sort(candidates, function (c1, c2) return c1.dist < c2.dist end)
  return candidates
end

-- Sends nearest staff members with the required attributes to the given room.
-- TODO take into account the tiredness of the staff etc. when deciding who to pick?
-- If 'mode' is set to one of the handyman's three concentration areas those
-- will be accounted for when doing the sort. 
function World:selectNearestStaffForRoom(room, attribute, count, mode)
  local door_x, door_y = room:getEntranceXY()
  local candidates = self:getSuitableStaffCandidates(door_x, door_y, attribute, nil, mode)
  for _, cand in ipairs(candidates) do
    if count <= 0 then
      break
    end
    count = count - 1
    cand.entity:setNextAction(room:createEnterAction(cand.entity))
    cand.entity:setDynamicInfoText(_S.dynamic_info.staff.actions.heading_for:format(room.room_info.name))
    return cand.entity
  end
end

-- Get the nearest room which is in need of the given staff member.
-- That is, the room is currently empty and there is at least
-- one patient in the queue.
function World:getNearestRoomNeedingStaff(humanoid)
  local candidates = {}
  for _, room in ipairs(self.rooms) do
    if room.door.queue:reportedSize() >= 1 and room:testStaffCriteria(room:getMaximumStaffCriteria(), humanoid) then
      local door_x, door_y = room:getEntranceXY()
      candidates[#candidates + 1] = {
        room = room,
        distance = self:getPathDistance(humanoid.tile_x, humanoid.tile_y, door_x, door_y)
      }
    end
  end

  if #candidates == 0 then
    return nil
  end

  table.sort(candidates, function (c1, c2) return c1.distance < c2.distance end)
  return candidates[1].room
end

-- !Log a message in the game log.
function World:gameLog(message)
  self.game_log[#self.game_log + 1] = message
end

-- !Dump the contents of the game log into a file.
-- This is automatically done on each error.
function World:dumpGameLog()
  local fi = assert(io.open("gamelog.txt", "wt"))
  for _, str in ipairs(self.game_log) do
    fi:write(str .. "\n")
  end
  fi:close()
end

function World:afterLoad(old, new)
  for _, cat in pairs({self.entities, self.rooms}) do
    for _, obj in pairs(cat) do
      obj:afterLoad(old, new)
    end
  end
  -- insert global compatibility code here
  if old < 4 then
    self.room_built = {}
  end
  
  self.savegame_version = new
end
