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

--! An `Entity` which occupies a single tile and is capable of moving around the map.
class "Humanoid" (Entity)

local TH = require "TH"

local walk_animations = permanent"humanoid_walk_animations"({})
local door_animations = permanent"humanoid_door_animations"({})
local die_animations = permanent"humanoid_die_animations"({})
local mood_icons = permanent"humanoid_mood_icons"({})
local flag_cache = {} -- Used in tickDay

local function anims(name, walkN, walkE, idleN, idleE, doorL, doorE, knockN, knockE)
  walk_animations[name] = {
    walk_east = walkE,
    walk_north = walkN,
    idle_east = idleE,
    idle_north = idleN,
  }
  door_animations[name] = {
    entering = doorE,
    leaving = doorL,
    knock_north = knockN,
    knock_east = knockE,
  }
end

local function die_anims(name, fall, rise, wings, hands, fly, extra)
  die_animations[name] = {
    fall_east = fall,
    rise_east = rise,
    wings_east = wings,
    hands_east = hands,
    fly_east = fly,
    extra_east = extra,
  }
end

local function moods(name, iconNo, prio, alwaysOn)
  mood_icons[name] = {icon = iconNo, priority = prio, on_hover = alwaysOn}
end

--   | Walk animations           |
--   | Name                      |WalkN|WalkE|IdleN|IdleE|DoorL|DoorE|KnockN|KnockE| Notes
-----+---------------------------+-----+-----+-----+-----+-----+-----+------+------+
anims("Standard Male Patient",       16,   18,   24,   26,  182,  184,   286,   288) -- 0-16, ABC
anims("Gowned Male Patient",        406,  408,  414,  416)                           -- 0-10
anims("Stripped Male Patient",      818,  820,  826,  828)                           -- 0-16
anims("Alternate Male Patient",    2704, 2706, 2712, 2714, 2748, 2750,  2764,  2766) -- 0-10, ABC
anims("Slack Male Patient",        1484, 1486, 1492, 1494, 1524, 1526,  2764,  1494) -- 0-14, ABC
anims("Transparent Male Patient",  1064, 1066, 1072, 1074, 1104, 1106,  1120,  1074) -- 0-16, ABC
anims("Standard Female Patient",      0,    2,    8,   10,  258,  260,   294,   296) -- 0-16, ABC
anims("Gowned Female Patient",     2876, 2878, 2884, 2886)                           -- 0-8
anims("Stripped Female Patient",    834,  836,  842,  844)                           -- 0-16
anims("Transparent Female Patient",3012, 3014, 3020, 3022, 3052, 3054,  3068,  3070) -- 0-8, ABC
anims("Chewbacca Patient",          858,  860,  866,  868, 3526, 3528,  4150,  4152)
anims("Elvis Patient",              978,  980,  986,  988, 3634, 3636,  4868,  4870)
anims("Invisible Patient",         1642, 1644, 1840, 1842, 1796, 1798,  4192,  4194)
anims("Alien Patient",             3598, 3600, 3606, 3608) -- Is it a patient?
anims("Doctor",                      32,   34,   40,   42,  670,  672)
anims("Surgeon",                   2288, 2290, 2296, 2298)
anims("Nurse",                     1206, 1208, 1650, 1652, 3264, 3266)
anims("Handyman",                  1858, 1860, 1866, 1868, 3286, 3288)
anims("Receptionist",              3668, 3670, 3676, 3678) -- Could do with door animations
anims("VIP",                        266,  268,  274,  276)
anims("Grim Reaper",                994,  996, 1002, 1004)

--  | Die Animations                 |
--  | Name                           |FallE|RiseE|WingsE|HandsE|FlyE|ExtraE| Notes
----+--------------------------------+-----+-----+-----+-----+------+------+
die_anims("Standard Male Patient",     1682, 2434, 2438, 2446,  2450) -- Always facing east or south
die_anims("Alternate Male Patient",    1682, 2434, 2438, 2446,  2450)
die_anims("Slack Male Patient",        1682, 2434, 2438, 2446,  2450)
-- TODO: Where is slack male transformation? Uses alternate male for now.
die_anims("Transparent Male Patient",  4412, 2434, 2438, 2446,  2450,  4416) -- Extra = Transformation
die_anims("Standard Female Patient",   3116, 3208, 3212, 3216,  3220,  4288) -- Extra = Slack tongue
die_anims("Transparent Female Patient",4420, 3208, 3212, 3216,  3220,  4428) -- Extra = Transformation
die_anims("Chewbacca Patient",         4182, 2434, 2438, 2446,  2450) -- Only males die... (1222)
die_anims("Elvis Patient",              974, 2434, 2438, 2446,  2450,  4186) -- Extra = Transformation
die_anims("Invisible Patient",         4200, 2434, 2438, 2446,  2450)
die_anims("Alien Patient",             4882, 2434, 2438, 2446,  2450)


--   | Available Moods |
--   | Name            |Icon|Priority|Show Always| Notes
-----+-----------------+----+--------+-----------+
moods("reflexion",      4020,       5)            -- Some icons should only appear when the player
moods("cantfind",       4050,       3)            -- hover over the humanoid
moods("idea1",          2464,      10)            -- Higher priority is more important.
moods("idea2",          2466,      11)
moods("idea3",          4044,      12)
moods("staff_wait",     4054,      20)
moods("tired",          3990,      30)
moods("pay_rise",       4576,      40)
moods("thirsty",        3986,       4)
moods("cold",           3994,       0,       true) -- These have no priority since
moods("hot",            3988,       0,       true) -- they will be shown when hovering
moods("queue",          4568,       0,       true) -- no matter what other priorities.
moods("poo",            3996,       5)
moods("money",          4018,      30)
moods("patient_wait",   5006,      40)
moods("epidemy1",       4566,      38)
moods("epidemy2",       4570,      40)
moods("epidemy3",       4572,      40)
moods("epidemy4",       4574,      40)
moods("sad1",           3992,      40)
moods("sad2",           4000,      41)
moods("sad3",           4002,      42)
moods("sad4",           4004,      43)
moods("sad5",           4006,      44)
moods("sad6",           4008,      45)
moods("sad7",           4578,      46)
moods("dead",           4046,      60)
moods("cured",          4048,      60)
moods("emergency",      3914,      50)
moods("exit",           4052,      60)

local anim_mgr = TheApp.animation_manager
for anim in values(door_animations, "*.entering") do
  anim_mgr:setMarker(anim, 0, {-1, 0}, 3, {-1, 0}, 9, {0, 0})
end
for anim in values(door_animations, "*.leaving") do
  anim_mgr:setMarker(anim, 1, {0, 0.4}, 4, {0, 0.4}, 7, {0, 0}, 11, {0, -1})
end

function Humanoid:Humanoid(...)
  self:Entity(...)
  self.action_queue = {}
  self.last_move_direction = "east"
  self.attributes = {}
  self.attributes["warmth"] = 0.6
  self.attributes["happiness"] = 1
  self.active_moods = {}
  self.should_knock_on_doors = false
end

function Humanoid:onClick(ui, button)
  if TheApp.config.debug then
    -- for debugging
    local name = "clicked humanoid"
    if self.profile then
      name = self.profile.name
    end
    print("-----------------------------------")
    print("Clicked on ".. name)
    print("Class: ", self.humanoid_class)
    if self.humanoid_class == "Doctor" then
      print(string.format("Skills: (%.3f)  Surgeon (%.3f)  Psych (%.3f)  Researcher (%.3f)",
        self.profile.skill or 0,
        self.profile.is_surgeon or 0,
        self.profile.is_psychiatrist or 0,
        self.profile.is_researcher or 0))
    end
    print(string.format("Warmth: %.3f   Happiness: %.3f   Fatigue: %.3f",
      self.attributes["warmth"] or 0,
      self.attributes["happiness"] or 0,
      self.attributes["fatigue"] or 0))
    print("")
    print("Actions:")
    for i = 1, #self.action_queue do
      if self.action_queue[i].room_type then
        print(self.action_queue[i].name .. " - " .. self.action_queue[i].room_type)
      elseif self.action_queue[i].object then
        print(self.action_queue[i].name .. " - " .. self.action_queue[i].object.object_type.id)
      else
        print(self.action_queue[i].name)
      end
    end
    print("-----------------------------------")
  end
end

function Humanoid:onDestroy()
  local x, y = self.tile_x, self.tile_y
  if x and y then
    local notify_object = self.world:getObjectToNotifyOfOccupants(x, y)
    if notify_object then
      notify_object:onOccupantChange(-1)
    end
  end
  return Entity.onDestroy(self)
end

function Humanoid:setHospital(hospital)
  self.hospital = hospital
  if not hospital or not hospital.is_in_world then
    local spawn_points = self.world.spawn_points
    self:setNextAction{
      name = "spawn",
      mode = "despawn",
      point = spawn_points[math.random(1, #spawn_points)],
      must_happen = true,
    }
  end
end

-- Function to activate/deactivate moods of a humanoid.
-- If mood_name is nil it is considered a refresh only. 
function Humanoid:setMood(mood_name, activate)
  if mood_name then 
    if activate and activate ~= "deactivate" then
      if self.active_moods[mood_name] then
        return -- No use doing anything if it already exists.
      end
      self.active_moods[mood_name] = mood_icons[mood_name]
    else
      if not self.active_moods[mood_name] then
        return -- No use doing anything if the mood isn't there anyway.
      end
      self.active_moods[mood_name] = nil
    end
  end
  local new_mood = nil
  -- TODO: Make equal priorities cycle, or make all moods unique
  for key, value in pairs(self.active_moods) do
    if new_mood then -- There is a mood, check priorities.
      if new_mood.priority < value.priority then
        new_mood = value
      end
    else
      if not value.on_hover then
        new_mood = value
      end
    end
  end
  self:setMoodInfo(new_mood)
end

-- Is the given mood in the list of active moods.
function Humanoid:isMoodActive(mood)
  for i, _ in pairs(self.active_moods) do
    if i == mood then
      return true
    end
  end
  return false
end

function Humanoid.getIdleAnimation(humanoid_class)
  return assert(walk_animations[humanoid_class], "Invalid humanoid class").idle_east
end

function Humanoid:getCurrentMood()
  if self.mood_info then
    return self.mood_info
  end
end

local function Humanoid_startAction(self)
  local action = self.action_queue[1]
  assert(action, "Empty action queue")
  
  -- Call the action start handler
  TheApp.humanoid_actions[action.name](action, self)
  
  if action == self.action_queue[1] and action.todo_interrupt then
    local high_priority = action.todo_interrupt == "high"
    action.todo_interrupt = nil
    local on_interrupt = action.on_interrupt
    if on_interrupt then
      action.on_interrupt = nil
      on_interrupt(action, self, high_priority)
    end
  end
end

function Humanoid:setNextAction(action, high_priority)
  -- Aim: Cleanly finish the current action (along with any subsequent actions
  -- which must happen), then replace all the remaining actions with the given
  -- one.
  local i = 1
  local queue = self.action_queue
  local interrupted = false
  
  -- Skip over any actions which must happen
  while queue[i] and queue[i].must_happen do
    interrupted = true
    i = i + 1
  end
  
  -- Remove actions which are no longer going to happen
  local done_set = {}
  for j = #queue, i, -1 do
    local removed = queue[j]
    queue[j] = nil
    if removed.until_leave_queue and not done_set[removed.until_leave_queue] then
      removed.until_leave_queue:removeValue(self)
      done_set[removed.until_leave_queue] = true
    end
    if removed.object and removed.object:isReservedFor(self) then
      removed.object:removeReservedUser(self)
    end
  end
  
  -- Add the new action to the queue
  queue[i] = action
  
  -- Interrupt the current action and queue other actions to be interrupted
  -- when they start.
  if interrupted then
    interrupted = queue[1]
    for j = 2, i - 1 do
      queue[j].todo_interrupt = high_priority and "high" or true
    end
    local on_interrupt = interrupted.on_interrupt
    if on_interrupt then
      interrupted.on_interrupt = nil
      on_interrupt(interrupted, self, high_priority or false)
    end
  else
    -- Start the action if it has become the current action
    Humanoid_startAction(self)
  end
  return self
end

function Humanoid:queueAction(action, pos)
  if pos then
    table.insert(self.action_queue, pos + 1, action)
    if pos == 0 then
      Humanoid_startAction(self)
    end
  else
    self.action_queue[#self.action_queue + 1] = action
  end
  return self
end


function Humanoid:finishAction(action)
  if action ~= nil then
    assert(action == self.action_queue[1], "Can only finish current action")
  end
  table.remove(self.action_queue, 1)
  Humanoid_startAction(self)
end

function Humanoid:setType(humanoid_class)
  assert(walk_animations[humanoid_class], "Invalid humanoid class: " .. tostring(humanoid_class))
  self.walk_anims = walk_animations[humanoid_class]
  self.door_anims = door_animations[humanoid_class]
  self.die_anims  = die_animations[humanoid_class]
  self.humanoid_class = humanoid_class
  if #self.action_queue == 0 then
    self:setNextAction {name = "idle"}
  end
  
  self.th:setPartialFlag(self.permanent_flags or 0, false)
  if humanoid_class == "Invisible Patient" then
    -- Invisible patients do not have very many pixels to hit, box works better
    self.permanent_flags = DrawFlags.BoundBoxHitTest
  else
    self.permanent_flags = nil
  end
  self.th:setPartialFlag(self.permanent_flags or 0)
end

function Humanoid:walkTo(tile_x, tile_y, must_happen)
  self:setNextAction {
    name = "walk",
    x = tile_x,
    y = tile_y,
    must_happen = must_happen,
  }
end

-- Stub functions for handling fatigue. These are overridden by the staff subclass,
-- but also defined here, so we can just call it on any humanoid
function Humanoid:tire(amount)
end

function Humanoid:wake(amount)
end

function Humanoid:handleRemovedObject(object)
  local replacement_action
  if self.humanoid_class and self.humanoid_class == "Receptionist" then
    replacement_action = {name = "meander"}
  elseif object.object_type.id == "bench" then
    replacement_action = {name = "idle", must_happen = true}
  end

  for i, action in ipairs(self.action_queue) do
    if (action.name == "use_object" or action.name == "staff_reception") and action.object == object then
      if replacement_action then
        self:queueAction(replacement_action, i)
      end
      if i == 1 then
        action:on_interrupt(self, true)
      else
        table.remove(self.action_queue, i)
        self.associated_desk = nil -- NB: for the other case, this is already handled in the on_interrupt function
      end
    end
  end
end

-- Function to alter one of a humanoids's different attributes.
-- Currently available attributes are happiness, thirst, toilet_need and warmth.
function Humanoid:changeAttribute(attribute, amount)
  assert(amount <= 1 and amount >= -1, "Amount must me between -1 and 1")

  -- Receptionist is always 100% happy
  if self.humanoid_class and self.humanoid_class == "Receptionist" and attribute == "happiness" then
    self.attributes[attribute] = 1;
    return true
  end

  if self.attributes[attribute] then
    self.attributes[attribute] = self.attributes[attribute] + amount
    if self.attributes[attribute] > 1 then
      self.attributes[attribute] = 1
    elseif self.attributes[attribute] < 0 then
      self.attributes[attribute] = 0
    end
  end
end

-- Check if it is cold or hot around the humanoid and increase/decrease the
-- feeling of warmth accordingly. Returns whether the calling function should proceed.
function Humanoid:tickDay()
-- No use doing anything if we're going home or are outside the hospital
  self.world.map.th:getCellFlags(self.tile_x, self.tile_y, flag_cache)
  if self.going_home or not flag_cache.hospital then
    return false
  end
  -- TODO: Distance should depend on the heating setting of the radiators
  -- and most importantly, values need balancing. Multiple radiators
  -- should also make a difference.
  -- Preferably each tile should have a heat value associated with it - computed in C?
  local radiator, lx, ly = self.world:findObjectNear(self, "radiator", 5)
  if radiator then
    local radiator_distance = ((lx - self.tile_x)^2 + (ly - self.tile_y)^2)^0.5
    local change = math.floor(6 - radiator_distance)*0.002*(0.8 - self.attributes["warmth"])
    self:changeAttribute("warmth", math.abs(change))
  else
    self:changeAttribute("warmth", -0.01)
  end
  
  -- If it is too hot or too cold, start to decrease happiness and 
  -- show the corresponding icon. Otherwise we could get happier instead.
  if self.attributes["warmth"] then
    if self.attributes["warmth"] < 0.1 then
      self:changeAttribute("happiness", -0.02)
      self:setMood("cold", "activate")
    elseif self.attributes["warmth"] > 0.9 then
      self:changeAttribute("happiness", -0.02)
      self:setMood("hot", "activate")
    else
      self:changeAttribute("happiness", 0.005)
      self:setMood("cold", "deactivate")
      self:setMood("hot", "deactivate")
    end
  end
  return true
end

-- Helper function that finds out if there is an action queued to use the specified object
function Humanoid:goingToUseObject(object_type)
  for i, action in ipairs(self.action_queue) do
    if action.object and action.object.object_type.id == object_type then
      return true
    end
  end
  return false
end
