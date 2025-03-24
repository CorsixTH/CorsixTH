--[[ Copyright (c) 2024 Toby "tobylane"

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

--! Manages all earthquakes in the world
class "Earthquake"

---@type Earthquake
local Earthquake = _G["Earthquake"]

--[[
All fields relating to the current or next earthquake:
  active (boolean) If there is a current earthquake, after start_day of start_month
    has passed, during the warning_length, warning_period or damage timers
  next_planned (boolean) If the next earthquake has been planned/generated
  start_month (integer) The month the earthquake warning is triggered (1-12)
  start_day (integer) The day of the month the earthquake warning is triggered (1-31)
  size (integer) The amount of damage the earthquake causes (1-9)
  remaining_damage (integer) The amount of damage this earthquake has yet to inflict (1-9)
  damage_timer (integer) The number of hours until the earthquake next inflicts damage if active (0-16)
  warning_timer (integer) The number of hours left until the real damaging earthquake begins (0-600)
  current_map_earthquake (integer) The number of earthquakes that have happened on this map so far
  disabled (boolean) If earthquakes have been disabled by the cheat menu
--]]

local damage_time = 16 -- Hours between each damage caused by an earthquake
local warning_period = 600 -- Hours between warning and main quakes
local warning_length = 25 -- Length of early warning quake

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

--! Track earthquakes in the world
--!param world (table) Owned by this world
--!param convert (boolean) If true, world is upgraded from before this Earthquake class
function Earthquake:Earthquake(world, convert)
  self.world = world
  if not convert then
    self.current_map_earthquake = 0
    self:nextEarthquake()
  end
end

--! Perform actions to simulate an active earthquake.
function Earthquake:tick()
  if not self.active or self.disabled then return end
  local hosp = self.world:getLocalPlayerHospital()
  -- Check if this is the day that the earthquake is supposed to stop
  if self.remaining_damage == 0 then
    self.active = false
    hosp:tickEarthquake("end")
    -- If the earthquake measured more than 7 on the richter scale, tell the user about it
    if self.size > 7 then
      hosp:giveAdvice({_A.earthquake.ended:format(math.floor(self.size))})
    end

    -- Set up the next earthquake date
    self:nextEarthquake()
    return
  end

  -- Start of warning quake
  if self.warning_timer == warning_period then
    self.next_planned = false
    hosp:tickEarthquake("warning_start")
  end

  -- End of warning quake
  if self.warning_timer >= warning_period - warning_length and
      self.warning_timer - self.world.hours_per_tick < warning_period - warning_length then
    hosp:tickEarthquake("end")
  end

  if self.warning_timer > 0 then
    self.warning_timer = self.warning_timer - self.world.hours_per_tick
    -- Nothing more to do during inactive warning period
    if self.warning_timer < warning_period - warning_length then
      return
    end

    -- Start of real earthquake
    if self.warning_timer <= 0 then
      hosp:tickEarthquake("main_start")
    end
  end

  -- All earthquakes start and end small (small earthquakes never become
  -- larger), so when there has been less than 2 damage applied or only
  -- 2 damage remaining to be applied, move the screen with less
  -- intensity than otherwise.
  if self.remaining_damage <= 2 or
      self.size - self.remaining_damage <= 2 then
    hosp:tickEarthquake("small_damage")
  else
    hosp:tickEarthquake("large_damage")
  end

  hosp:tickEarthquake("sound")

  -- Do not continue to damage phase while in a warning quake
  if self.warning_timer > 0 then
    return
  end

  -- Check if damage phase should go ahead
  self.damage_timer = self.damage_timer - self.world.hours_per_tick
  if self.damage_timer > 0 then return end

  for _, room in pairs(self.world.rooms) do
    for object, _ in pairs(room.objects) do
      local object_is_machine = object.strength
      if object_is_machine then
        object:earthquakeImpact(room)
      end
    end
  end

  self.remaining_damage = self.remaining_damage - 1
  self.damage_timer = self.damage_timer + damage_time

  -- The below code triggers random patient falls during an earthquake.
  -- It is currently disabled except for debugging purposes in the config file.
  -- Current behaviour can cause empty action queues or other undesired behaviours.
  -- Once working, the debugging flag can be removed.
  if not TheApp.config.debug_falling then return end
  local hospital = self.world:getLocalPlayerHospital()
  -- loop through the patients and allow the possibility for them to fall over
  for _, patient in ipairs(hospital.patients) do
    if not patient.in_room and patient.falling_anim then
      patient:falling(false)
    end
  end
end

--! Check if it's time for an earthquake
function Earthquake:onEndDay()
  if self.world.game_date:monthOfGame() == self.start_month and
      self.world.game_date:dayOfMonth() == self.start_day and
      not self.disabled then
    -- Mark the planned earthquake as ready to start in the next tick.
    self.active = true
  end
end

--! Called when it is time to have another earthquake
function Earthquake:nextEarthquake()
  self.active = false

  local level_config = self.world.map.level_config
  -- Check carefully that no value that we are going to use is going to be nil
  if level_config.quake_control and level_config.quake_control[self.current_map_earthquake] and
      level_config.quake_control[self.current_map_earthquake].Severity ~= 0 then
    -- This map has rules to follow when making earthquakes, let's follow them
    local control = level_config.quake_control[self.current_map_earthquake]
    self.start_month = math.random(control.StartMonth, control.EndMonth)

    -- Month length of the start of the earthquake. From start to finish
    -- earthquakes do not persist for >= a month so we can wrap all days
    -- after the start around the month length unambiguously.
    local eqml = month_length[(self.start_month % 12) + 1]
    self.start_day = math.random(1, eqml)

    self.size = control.Severity
    self.remaining_damage = self.size
    self.damage_timer = damage_time
    self.warning_timer = warning_period
    self.current_map_earthquake = self.current_map_earthquake + 1
    self.next_planned = true
  end
end

--! Create a small or medium quake now for the "Create Earthquake" cheat
function Earthquake:createEarthquake()
  -- Make sure an earthquake isn't already happening, or are disabled
  if self.active or self.disabled then return false end

  self.start_day = self.world.game_date:dayOfMonth()
  self.start_month = self.world.game_date:monthOfGame()
  if not self.next_planned then
    -- Forcefully make an earthquake if there are none left in level file
    self.size = math.random(1, 6) -- Above 6 seems disastrous
    self.remaining_damage = self.size
    self.damage_timer = damage_time
    self.warning_timer = warning_period
  end
end

--! Check if there is a current earthquake
--!return (boolean) True if there is a current earthquake
function Earthquake:isActive()
  return self.active
end

--! Afterload sections before 189 were taken from World
--!param old (integer) The old version of the save game.
--!param new (integer) The current version of the save game format.
function Earthquake:afterLoad(old, new) -- luacheck: ignore 212 keep params from parent function
  local old_quake = self.world.next_earthquake
  if old < 115 then
    if old_quake.active then
      local rd = 0
      for _, room in pairs(self.world.rooms) do
        for object, _ in pairs(room.objects) do
          if object.quake_points then
            rd = math.max(rd, object.quake_points)
            object.quake_points = nil
          end
        end
      end
      old_quake.remaining_damage = rd
      old_quake.damage_timer = damage_time
      old_quake.warning_timer = 0
    end
  end

  if old < 189 then
    self.disabled = self.world.earthquakes_disabled -- Used in cheats
    if old_quake then
      for k, v in pairs(old_quake) do
        self[k] = v
      end
    else
      self:nextEarthquake()
    end
  end
end
