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
local pee_animations = permanent"humanoid_pee_animations"({})
local vomit_animations = permanent"humanoid_vomit_animations"({})
local tap_foot_animations = permanent"humanoid_tap_foot_animations"({})
local check_watch_animations = permanent"humanoid_check_watch_animations"({})
local mood_icons = permanent"humanoid_mood_icons"({})

local function anims(name, walkN, walkE, idleN, idleE, doorL, doorE, knockN, knockE, swingL, swingE)
  walk_animations[name] = {
    walk_east = walkE,
    walk_north = walkN,
    idle_east = idleE,
    idle_north = idleN,
  }
  door_animations[name] = {
    entering = doorE,
    leaving = doorL,
    entering_swing = swingE,
    leaving_swing = swingL,
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

local function vomit_anim(name, vomitAnim)
  vomit_animations[name] = vomitAnim
end
local function tap_foot_anim(name, tap_footAnim)
  tap_foot_animations[name] = tap_footAnim
end
local function check_watch_anim(name, check_watchAnim)
  check_watch_animations[name] = check_watchAnim
end
local function pee_anim(name, peeAnim)
  pee_animations[name] = peeAnim
end
local function moods(name, iconNo, prio, alwaysOn)
  mood_icons[name] = {icon = iconNo, priority = prio, on_hover = alwaysOn}
end

--   | Walk animations           |
--   | Name                      |WalkN|WalkE|IdleN|IdleE|DoorL|DoorE|KnockN|KnockE|SwingL|SwingE| Notes
-----+---------------------------+-----+-----+-----+-----+-----+-----+------+------+-------+---------+
anims("Standard Male Patient",       16,   18,   24,   26,  182,  184,   286,   288,  2040,  2042) -- 0-16, ABC
anims("Gowned Male Patient",        406,  408,  414,  416)                           -- 0-10
anims("Stripped Male Patient",      818,  820,  826,  828)                           -- 0-16
anims("Stripped Male Patient 2",      818,  820,  826,  828)                           -- 0-16
anims("Stripped Male Patient 3",      818,  820,  826,  828)    
anims("Alternate Male Patient",    2704, 2706, 2712, 2714, 2748, 2750,  2764,  2766) -- 0-10, ABC
anims("Slack Male Patient",        1484, 1486, 1492, 1494, 1524, 1526,  2764,  1494) -- 0-14, ABC
anims("Slack Female Patient",         0,    2,    8,   10,  258,  260,   294,   296,  2864,  2866) -- 0-16, ABC
anims("Transparent Male Patient",  1064, 1066, 1072, 1074, 1104, 1106,  1120,  1074) -- 0-16, ABC
anims("Standard Female Patient",      0,    2,    8,   10,  258,  260,   294,   296,  2864,  2866) -- 0-16, ABC
anims("Gowned Female Patient",     2876, 2878, 2884, 2886)                           -- 0-8
anims("Stripped Female Patient",    834,  836,  842,  844)                           -- 0-16
anims("Stripped Female Patient 2",    834,  836,  842,  844)                           -- 0-16
anims("Stripped Female Patient 3",    834,  836,  842,  844)    
anims("Transparent Female Patient",3012, 3014, 3020, 3022, 3052, 3054,  3068,  3070) -- 0-8, ABC
anims("Chewbacca Patient",          858,  860,  866,  868, 3526, 3528,  4150,  4152)
anims("Elvis Patient",              978,  980,  986,  988, 3634, 3636,  4868,  4870)
anims("Invisible Patient",         1642, 1644, 1840, 1842, 1796, 1798,  4192,  4194)
anims("Alien Male Patient",        3598, 3600, 3606, 3608,  182,  184,   286,   288, 3626,  3628) -- remember, no "normal"-doors animation
anims("Alien Female Patient",      3598, 3600, 3606, 3608,  258,  260,   294,   296, 3626,  3628) -- identical to male; however death animations differ
anims("Doctor",                      32,   34,   40,   42,  670,  672,   nil,   nil, 4750,  4752)
anims("Surgeon",                   2288, 2290, 2296, 2298)
anims("Nurse",                     1206, 1208, 1650, 1652, 3264, 3266,   nil,   nil, 3272,  3274)
anims("Handyman",                  1858, 1860, 1866, 1868, 3286, 3288,   nil,   nil, 3518,  3520)
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
die_anims("Standard Female Patient",   3116, 3208, 3212, 3216,  3220)
die_anims("Slack Female Patient",      4288, 3208, 3212, 3216,  3220)
die_anims("Transparent Female Patient",4420, 3208, 3212, 3216,  3220,  4428) -- Extra = Transformation
die_anims("Chewbacca Patient",         4182, 2434, 2438, 2446,  2450) -- Only males die... (1222 is the Female)
die_anims("Elvis Patient",              974, 2434, 2438, 2446,  2450,  4186) -- Extra = Transformation
die_anims("Invisible Patient",         4200, 2434, 2438, 2446,  2450)
die_anims("Alien Male Patient",        4882, 2434, 2438, 2446,  2450)
die_anims("Alien Female Patient",      4886, 3208, 3212, 3216,  3220)

--  | Vomit Animations                  |
--  | Name                              |Anim | Notes
----+-----------------------------------+-----+
vomit_anim("Elvis Patient",              1034)
vomit_anim("Standard Female Patient",    3184)
vomit_anim("Standard Male Patient",      4476)
vomit_anim("Alternate Male Patient",     4476)
vomit_anim("Chewbacca Patient",          4138)
vomit_anim("Invisible Patient",          4204)
vomit_anim("Slack Male Patient",         4324)
vomit_anim("Transparent Female Patient", 4452)
vomit_anim("Transparent Male Patient",   4384)

--  | Foot tapping Animations                  |
--  | Name                              |Anim | Notes
----+-----------------------------------+-----+
tap_foot_anim("Standard Female Patient",    4464)
tap_foot_anim("Standard Male Patient",      2960)
tap_foot_anim("Alternate Male Patient",     360)

--  | Check watch Animations                  |
--  | Name                              |Anim | Notes
----+-----------------------------------+-----+
check_watch_anim("Standard Female Patient",    4468)
check_watch_anim("Standard Male Patient",      2964)
check_watch_anim("Alternate Male Patient",     364)
check_watch_anim("Slack Male Patient",         4060)

--  | pee Animations                  |
--  | Name                              |Anim | Notes
----+-----------------------------------+-----+
pee_anim("Elvis Patient",              970)
pee_anim("Standard Female Patient",    4744)
pee_anim("Slack Female Patient",       4744)
pee_anim("Standard Male Patient",      2244) 
pee_anim("Alternate Male Patient",     4472)
pee_anim("Slack Male Patient",         4328)
pee_anim("Chewbacca Patient",          4178)
pee_anim("Invisible Patient",          4208)
pee_anim("Transparent Female Patient", 4852)
pee_anim("Transparent Male Patient",   4848)

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
moods("queue",          4568,      70)             -- no matter what other priorities.
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
for anim in values(door_animations, "*.entering_swing") do
  anim_mgr:setMarker(anim, 0, {-1, 0}, 8, {0, 0})
end
for anim in values(door_animations, "*.leaving_swing") do
  anim_mgr:setMarker(anim, 0, {0.1, 0}, 9, {0, -1})
end

--!param ... Arguments for base class constructor.
function Humanoid:Humanoid(...)
  self:Entity(...)
  self.action_queue = {}
  self.last_move_direction = "east"
  self.attributes = {}
  self.attributes["warmth"] = 0.29
  self.attributes["happiness"] = 1
  -- patients should be not be fully well when they come to your hospital and if it is staff there is no harm done!
  self.attributes["health"] = math.random(80, 100) /100
  self.active_moods = {}
  self.should_knock_on_doors = false

  self.speed = "normal"
end

-- Save game compatibility
function Humanoid:afterLoad(old, new)
  if old < 38 then
    -- should existing patients be updated and be getting really ill?
    -- adds the new variables for health icons 
    self.attributes["health"] = math.random(60, 100) /100
  end
  -- make sure female slack patients have the correct animation
  if old < 42 then
    if self.humanoid_class == "Slack Female Patient" then
      self.die_anims = die_animations["Slack Female Patient"]
    end
  end
end   

-- Function which is called when the user clicks on the `Humanoid`.
--!param ui (GameUI) The UI which the user in question is using.
--!param button (string) One of: "left", "middle", "right".
function Humanoid:onClick(ui, button)
  if TheApp.config.debug then
    self:dump()
  end
end

function Humanoid:getRoom()
  return self.in_room or Entity.getRoom(self)
end

function Humanoid:dump()
  local name = "humanoid"
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
  print(string.format("Warmth: %.3f   Happiness: %.3f   Fatigue: %.3f  Thirst: %.3f  Toilet_Need: %.3f   Health: %.3f",
    self.attributes["warmth"] or 0,
    self.attributes["happiness"] or 0,
    self.attributes["fatigue"] or 0,
    self.attributes["thirst"] or 0,
    self.attributes["toilet_need"] or 0,
    self.attributes["health"] or 0))

  print("")
  print("Actions:")
  for i = 1, #self.action_queue do
    local action = self.action_queue[i]
    local flag = 
      (action.must_happen and "  must_happen" or "  ") ..
      (action.todo_interrupt and "  " or "  ")
    if action.room_type then
      print(action.name .. " - " .. action.room_type .. flag)
    elseif action.object then
      print(action.name .. " - " .. action.object.object_type.id .. flag)
    elseif action.name == "walk" then
      print(action.name .. " - going to " .. action.x .. ":" .. action.y .. flag)
    else
      print(action.name .. flag)
    end
  end
  print("-----------------------------------")
end

-- Called when the humanoid is about to be removed from the world.
function Humanoid:onDestroy()
  local x, y = self.tile_x, self.tile_y
  if x and y then
    local notify_object = self.world:getObjectToNotifyOfOccupants(x, y)
    if notify_object then
      notify_object:onOccupantChange(-1)
    end
  end
  -- Make absolutely sure there are no callbacks left on the humanoid.
  self:unregisterCallbacks()
  return Entity.onDestroy(self)
end

-- Set the `Hospital` which is responsible for treating or employing the
-- `Humanoid`. In single player games, this has little effect, but it is very
-- important in multiplayer games.
--!param hospital (Hospital, nil) The `Hospital` which should be responsible
-- for the `Humanoid`. If nil, then the `Humanoid` is despawned.
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

function Humanoid:setCallCompleted()
  if self.on_call then
    CallsDispatcher.onCheckpointCompleted(self.on_call)    
  end
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
    if not removed then
      -- A bug (rare) that removed could be nil.
      --   but as it's being removed anyway...it could be ignored
      print("Warning: Action to be removed was nil")
    else
      if removed.on_remove then
        removed.on_remove(removed, self)
      end
      if removed.until_leave_queue and not done_set[removed.until_leave_queue] then
        removed.until_leave_queue:removeValue(self)
        done_set[removed.until_leave_queue] = true
      end
      if removed.object and removed.object:isReservedFor(self) then
        removed.object:removeReservedUser(self)
      end
    end
  end
  
  -- Add the new action to the queue
  queue[i] = action
  
  -- Interrupt the current action and queue other actions to be interrupted
  -- when they start.
  if interrupted then
    interrupted = queue[1]
    for j = 1, i - 1 do
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

-- Check if the humanoid is running actions intended to leave the room, as indicated by the flag
function Humanoid:isLeaving()
  return self.action_queue[1].is_leaving
end

-- Check if there is "is_leaving" action in the action queue
function Humanoid:hasLeavingAction()
  for _, action in ipairs(self.action_queue) do
    if action.is_leaving then
      return true
    end
  end
  return false
end

function Humanoid:setType(humanoid_class)
  assert(walk_animations[humanoid_class], "Invalid humanoid class: " .. tostring(humanoid_class))
  self.walk_anims = walk_animations[humanoid_class]
  self.door_anims = door_animations[humanoid_class]
  self.die_anims  = die_animations[humanoid_class]
  self.vomit_anim = vomit_animations[humanoid_class]
  self.tap_foot_anim = tap_foot_animations[humanoid_class]
  self.check_watch_anim = check_watch_animations[humanoid_class]  
  self.pee_anim = pee_animations[humanoid_class]
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

-- Helper function for the common case of instructing a `Humanoid` to walk to
-- a position on the map. Equivalent to calling `setNextAction` with a walk
-- action.
--!param tile_x (integer) The X-component of the Lua tile co-ordinates of the
-- tile to walk to.
--!param tile_y (integer) The Y-component of the Lua tile co-ordinates of the
-- tile to walk to.
--!param must_happen (boolean, nil) If true, then the walk action will not be
-- interrupted.
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

function Humanoid:updateSpeed()
  self.speed = "normal"
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
        local on_interrupt = action.on_interrupt
        action.on_interrupt = nil
        if on_interrupt then
          on_interrupt(action, self, true)
        end
      else
        table.remove(self.action_queue, i)
        self.associated_desk = nil -- NB: for the other case, this is already handled in the on_interrupt function
      end
    end
  end
end

-- Adjusts one of the `Humanoid`'s attributes.
--!param attribute (string) One of: "happiness", "thirst", "toilet_need", "warmth".
--!param amount (number) This amount is added to the existing value for the attribute,
--  and is then capped to be between 0 and 1.
function Humanoid:changeAttribute(attribute, amount)
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
  -- No use doing anything if we're going home
  if self.going_home then
    return false
  end
  
  local temperature = self.world.map.th:getCellTemperature(self.tile_x, self.tile_y)
  self.attributes.warmth = self.attributes.warmth * 0.75 + temperature * 0.25
  
  -- If it is too hot or too cold, start to decrease happiness and 
  -- show the corresponding icon. Otherwise we could get happier instead.
  -- Let the player get into the level first though, don't decrease happiness the first year.
  if self.attributes["warmth"] and self.hospital and not self.hospital.initial_grace then
    -- Cold: less than 11 degrees C
    if self.attributes["warmth"] < 0.22 then
      self:changeAttribute("happiness", -0.02 * (0.22 - self.attributes["warmth"]) / 0.14)
      self:setMood("cold", "activate")
    -- Hot: More than 18 degrees C
    elseif self.attributes["warmth"] > 0.36 then
      self:changeAttribute("happiness", -0.02 * (self.attributes["warmth"] - 0.36) / 0.14)
      self:setMood("hot", "activate")
    -- Ideal: Between 11 and 18
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

-- Function called when a humanoid is sent away from the hospital to prevent
-- further actions taken as a result of a callback
function Humanoid:unregisterCallbacks()
  -- Remove callbacks for new rooms
  if self.build_callback then
    self.world:unregisterRoomBuildCallback(self.build_callback)
  end
  if self.toilet_callback then
    self.world:unregisterRoomBuildCallback(self.toilet_callback)
  end
  -- Remove any message related to the humanoid.
  if self.message_callback then
    self:message_callback(true)
    self.message_callback = nil
  end
end
