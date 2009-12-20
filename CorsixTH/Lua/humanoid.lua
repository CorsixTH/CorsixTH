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

class "Humanoid" (Entity)

local TH = require "TH"

local walk_animations = {}
local door_animations = {}
local die_animations = {}

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

local function die_anims(name, fall, rise, wings, hands, fly)
  die_animations[name] = {
    fall_east = fall,
    rise_east = rise,
    wings_east = wings,
    hands_east = hands,
    fly_east = fly,
  }
end

--   |Name                       |WalkN|WalkE|IdleN|IdleE|DoorL|DoorE|KnockN|KnockE| Notes
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

--  |Name                           |FallE|RiseE|WingsE|HandsE|FlyE| Notes
----+-------------------------------+-----+-----+-----+-----+------+
die_anims("Standard Male Patient",    1682, 2434, 2438, 2446,  2450) -- Always facing east or south
die_anims("Standard Female Patient",  3116, 3208, 3212, 3216,  3220)


function Humanoid:Humanoid(...)
  self:Entity(...)
  self.action_queue = {
  }
  self.last_move_direction = "east"
  self.warmth = 0.6
end

function Humanoid:onClick(ui, button)
  -- temporary for debugging
  local name = "clicked humanoid"
  if self.profile then
    name = self.profile.name
  end
  print("Actions of ".. name ..": ")
  for i = 1, #self.action_queue do
    print(self.action_queue[i].name)
  end
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

function Humanoid:setMood(mood)
  self.mood = mood
  if mood == nil then
    if self.mood_info then
      self.mood_info:setTile(nil)
    end
    self.mood_info = false
    return
  end
  local moods = {
    bored = 4054,
    cantfind = 4050,
    coffee = 3986,
    cold = 3994,
    emergency = 3914,
    epidemy1 = 4566, epidemy2 = 4570, epidemy3 = 4572, epidemy4 = 4574,
    exit = 4052,
    happy = 4048,
    hot = 3988,
    idea1 = 2464, idea2 = 2466, idea3 = 4044,
    money = 4018,
    poo = 3996,
    queue = 4568,
    reflexion = 4020,
    repairing = 4564,     
    rise = 4576,
    sad1 = 3992, sad2 = 4000, sad3 = 4002, sad4 = 4004, sad5 = 4006, sad6 = 4008, sad7 = 4578,
    tired = 3990,
    unhappy = 4046,
    wait = 5006,
  }
  if not self.mood_info then
    self.mood_info = TH.animation()
  end
  self.mood_info:setAnimation(self.world.anims, moods[mood])
end

function Humanoid.getIdleAnimation(humanoid_class)
  return assert(walk_animations[humanoid_class], "Invalid humanoid class").idle_east
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
    if removed.object and removed.object.reserved_for == self then
      removed.object.reserved_for = nil
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
  -- Only two types can die: Standard Male/Female Patients
  if humanoid_class == "Standard Female Patient" or humanoid_class == "Standard Male Patient" then
    self.die_anims  = die_animations[humanoid_class]
  end
  self.humanoid_class = humanoid_class
  if #self.action_queue == 0 then
    self:setNextAction {name = "idle"}
  end
end

function Humanoid:walkTo(tile_x, tile_y)
  self:setNextAction {
    name = "walk",
    x = tile_x,
    y = tile_y,
  }
end

-- Stub functions for handling fatigue. These are overridden by the staff subclass,
-- but also defined here, so we can just call it on any humanoid
function Humanoid:tire(amount)
end

function Humanoid:wake(amount)
end
