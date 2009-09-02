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

function Humanoid:Humanoid(...)
  self:Entity(...)
  self.action_queue = {
  }
  self.last_move_direction = "east"
end

local function Humanoid_startAction(self)
  local action = self.action_queue[1]
  assert(action, "Empty action queue")
  TheApp.humanoid_actions[action.name](action, self)
  if action.todo_interrupt then
    action.todo_interrupt = nil
    if action.on_interrupt then
      action.must_happen = true
      action:on_interrupt(self)
      action.on_interrupt = nil
    end
  end
end

function Humanoid:setNextAction(action)
  local i = 1
  local queue = self.action_queue
  local interrupted = false
  -- Skip over any actions which must happen
  while queue[i] and queue[i].must_happen do
    interrupted = true
    i = i + 1
  end
  -- Interrupt the current action and queue other actions to be interrupted
  -- when they start.
  if interrupted then
    interrupted = queue[1]
    if interrupted.on_interrupt then
      interrupted:on_interrupt(self)
      interrupted.on_interrupt = nil
    end
    for j = 2, i - 1 do
      queue[j].todo_interrupt = true
    end
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
  -- Start the action if it has become the current action
  if not interrupted then
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
  self.humanoid_class = humanoid_class
  self:setNextAction {name = "idle"}
end

function Humanoid:onAdvanceQueue(queue, n)
  local action = self.action_queue[1]
  if action.until_leave_queue then
    if action.name == "idle" then
      local ix, iy = self.world:getIdleTile(action.x1, action.y1, n - 1)
      if ix then
        self:queueAction({
          name = "walk",
          until_leave_queue = queue,
          must_happen = action.must_happen,
          destination_unimportant = true,
          x = ix,
          y = iy,
        }, 0)
      end
    elseif action.name == "walk" and action.destination_unimportant then
      local idle = self.action_queue[2]
      if idle and idle.name == "idle" then
        local ix, iy = self.world:getIdleTile(idle.x1, idle.y1, n - 1)
        if ix then
          action:on_interrupt(self)
          self:queueAction({
            name = "walk",
            until_leave_queue = queue,
            must_happen = idle.must_happen,
            destination_unimportant = true,
            x = ix,
            y = iy,
          }, 1)
        end    
      end
    end
  end
end

function Humanoid:onLeaveQueue()
  if self.action_queue[1].until_leave_queue then
    local interrupted = false
    local i = 1
    while self.action_queue[i].until_leave_queue do
      local action = self.action_queue[i]
      if action.must_happen then
        if interrupted then
          action.todo_interrupt = true
        else
          if action.on_interrupt then
            action:on_interrupt(self)
            action.on_interrupt = nil
          end
          interrupted = true
        end
        i = i + 1
      else
        table.remove(self.action_queue, i)
      end
    end
    if not interrupted then
      Humanoid_startAction(self)
    end
  end
end

function Humanoid:walkTo(tile_x, tile_y, when_done)
  if tile_x == self.tile_x and tile_y == self.tile_y then
    if when_done then
      when_done()
    end
    return
  end
  
  self:setNextAction {
    name = "walk",
    x = tile_x,
    y = tile_y,
    when_done = when_done,
  }
  self:queueAction {name = "idle"}
end
