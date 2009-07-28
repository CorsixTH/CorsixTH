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

local walk_animations = {}
local door_animations = {}
local function anims(name, walkN, walkE, idleN, idleE, doorL, doorE)
  walk_animations[name] = {
    walk_east = walkE,
    walk_north = walkN,
    idle_east = idleE,
    idle_north = idleN,
  }
  door_animations[name] = {
    entering = doorE,
    leaving = doorL,
  }
end

--   |Name                       |WalkN|WalkE|IdleN|IdleE|DoorL|DoorE| Notes
-----+---------------------------+-----+-----+-----+-----+-----+-----+---------
anims("Standard Male Patient",       16,   18,   24,   26,  182,  184) -- 0-16, ABC
anims("Gowned Male Patient",        406,  408,  414,  416)             -- 0-10
anims("Stripped Male Patient",      818,  820,  826,  828)             -- 0-16
anims("Alternate Male Patient",    2704, 2706, 2712, 2714, 2748, 2750) -- 0-10, ABC
anims("Slack Male Patient",        1484, 1486, 1492, 1494, 1524, 1526) -- 0-14, ABC
anims("Transparent Male Patient",  1064, 1066, 1072, 1074, 1104, 1106) -- 0-16, ABC
anims("Standard Female Patient",      0,    2,    8,   10,  258,  260) -- 0-16, ABC
anims("Gowned Female Patient",     2876, 2878, 2884, 2886)             -- 0-8
anims("Stripped Female Patient",    834,  836,  842,  844)             -- 0-16
anims("Transparent Female Patient",3012, 3014, 3020, 3022, 3052, 3054) -- 0-8, ABC
anims("Chewbacca Patient",          858,  860,  866,  868, 3526, 3528)
anims("Elvis Patient",              978,  980,  986,  988, 3634, 3636)
anims("Invisible Patient",         1642, 1644, 1840, 1842, 1796, 1798)
anims("Alien Patient",             3598, 3600, 3606, 3608)             -- Is it a patient?
anims("Doctor",                      32,   34,   40,   42,  670,  672)
anims("Surgeon",                   2288, 2290, 2296, 2298)
anims("Nurse",                     1206, 1208, 1650, 1652, 3264, 3266)
anims("Handyman",                  1858, 1860, 1866, 1868, 3286, 3288)
anims("Receptionist",              3668, 3670, 3676, 3678) -- Could do with door animations
anims("VIP",                        266,  268,  274,  276)
anims("Grim Reaper",                994,  996, 1002, 1004)

-- Other humanoids which seem to lack walk animations:
-- (none)

function Humanoid:Humanoid(...)
  self:Entity(...)
end

function Humanoid:setType(humanoid_class)
  assert(walk_animations[humanoid_class], "Invalid humanoid class: " .. tostring(humanoid_class))
  self.walk_anims = walk_animations[humanoid_class]
  self.door_anims = door_animations[humanoid_class]
  self:setAnimation(self.walk_anims.idle_east)
end

local walk_timer_weak_set = setmetatable({}, {__mode = "k"})

function Humanoid:walkTo(tile_x, tile_y, when_done)
  if tile_x == self.tile_x and tile_y == self.tile_y then
    if when_done then
      when_done()
    end
    return true
  end
  
  -- Possible future optimisation: when walking from somewhere inside the hospital
  -- to somewhere outside the hospital (or from one building to another?), do
  -- pathfinding in two steps, with the building door as a middle node
  local map = self.world.map.th
  local path_x, path_y = self.world:getPath(self.tile_x, self.tile_y, tile_x, tile_y)
  if not path_x then
    return false, ("No route for humanoid from (%i, %i) to (%i, %i)")
      :format(self.tile_x, self.tile_y, tile_x, tile_y)
  end
  
  if self.timer_function and walk_timer_weak_set[self.timer_function] then
    -- Already walking somewhere - wait until it gets to the next tile before
    -- sending it somewhere else
    local newf = function()
      if self.user_of then
        self.user_of:setUser(nil)
        self.user_of = nil
      end
      if self.animation_idx == self.walk_anims.walk_south then
        self:setAnimation(self.walk_anims.idle_south, self.animation_flags % 1024)
      else
        self:setAnimation(self.walk_anims.idle_east,  self.animation_flags % 1024)
      end
      self:setTilePositionSpeed(self.tile_x_next, self.tile_y_next, 0, 0, 0, 0)
      self.tile_x_next = nil
      self.tile_y_next = nil
      self.timer_function = nil
      self:walkTo(tile_x, tile_y, when_done)
    end
    walk_timer_weak_set[newf] = true
    self.timer_function = newf
    return true
  end
  
  local idx = 1
  local idle = self.walk_anims.idle_south
  
  local path_step, navigate_door
  local function next_step()
    if path_x[idx + 1] then
      path_step(idx)
      idx = idx + 1
    else
      self:setAnimation(idle, self.animation_flags % 1024)
      self:setTilePositionSpeed(tile_x, tile_y)
      self.tile_x_next = nil
      self.tile_y_next = nil
      if when_done then
        when_done()
      end
    end
  end
  walk_timer_weak_set[next_step] = true
  
  local flags = {}
  path_step = function(index)
    local x1, y1 = path_x[index  ], path_y[index  ]
    local x2, y2 = path_x[index+1], path_y[index+1]
    
    -- Make sure that the next tile hasn't somehow become impassable since our
    -- route was determined
    if not map:getCellFlags(x2, y2).passable then
      if map:getCellFlags(x1, y1).passable then
        -- Work out a new route
        self:setAnimation(idle, self.animation_flags % 1024)
        self:setTilePositionSpeed(x1, y1)
        return self:walkTo(tile_x, tile_y, when_done)
      end
    end
    
    if x1 ~= x2 then
      if x1 < x2 then -- Walking east
        idle = self.walk_anims.idle_east
        if map:getCellFlags(x2, y2, flags).doorWest and self.door_anims then
          return navigateDoor(x1, y1, x2, y2, "east")
        else
          self:setAnimation(self.walk_anims.walk_east, 1024)
          self:setTilePositionSpeed(x2, y2, -32, -16, 4, 2)
        end
      else -- Walking west
        idle = self.walk_anims.idle_north
        if map:getCellFlags(x1, y1, flags).doorWest and self.door_anims then
          return navigateDoor(x1, y1, x2, y2, "west")
        else
          self:setAnimation(self.walk_anims.walk_north, 1024 + 1)
          self:setTilePositionSpeed(x1, y1, 0, 0, -4, -2)
        end
      end
    else
      if y1 < y2 then -- Walking south
        idle = self.walk_anims.idle_east
        if map:getCellFlags(x2, y2, flags).doorNorth and self.door_anims then
          return navigateDoor(x1, y1, x2, y2, "south")
        else
          self:setAnimation(self.walk_anims.walk_east, 1)
          self:setTilePositionSpeed(x2, y2, 32, -16, -4, 2)
        end
      else -- Walking north
        idle = self.walk_anims.idle_north
        if map:getCellFlags(x1, y1, flags).doorNorth and self.door_anims then
          return navigateDoor(x1, y1, x2, y2, "north")
        else
          self:setAnimation(self.walk_anims.walk_north)
          self:setTilePositionSpeed(x1, y1, 0, 0, 4, -2)
        end
      end
    end
    self.tile_x_next = x2
    self.tile_y_next = y2
    self:setTimer(8, next_step)
  end
  
  navigateDoor = function(x1, y1, x2, y2, direction)   
    local dx, dy, dd = x1, y1, direction
    local duration = 12
    if direction == "east" then
      dx = dx + 1
      dd = "west"
      duration = 10
    elseif direction == "south" then
      dy = dy + 1
      dd = "north"
      duration = 10
    end
    local door = self.world:getObject(dx, dy, "door")
    if door.user then
      -- door in use; go idle and try again later
      self:setAnimation(idle, self.animation_flags % 1024)
      self:setTilePositionSpeed(x1, y1)
      self:setTimer(11, function() navigateDoor(x1, y1, x2, y2, direction) end)
      return
    end
    door:setUser(self)
    self:setTile(dx, dy)
    self:setSpeed(0, 0)
    if direction == "north" then
      self:setAnimation(self.door_anims.leaving)
      self:setPosition(-1, 0)
    elseif direction == "west" then
      self:setAnimation(self.door_anims.leaving, 1024 + 1)
      self:setPosition(1, 0)
    elseif direction == "east" then
      self:setAnimation(self.door_anims.entering, 1024)
      self:setPosition(-1, 0)
    elseif direction == "south" then
      self:setAnimation(self.door_anims.entering, 1)
      self:setPosition(1, 0)
    end
    local timer = function()
      door:setUser(nil)
      self.user_of = nil
      next_step()
    end
    walk_timer_weak_set[timer] = true
    self.tile_x_next = x2
    self.tile_y_next = y2
    self.user_of = door
    self:setTimer(duration, timer)
  end
  
  next_step()
  
  return true
end
