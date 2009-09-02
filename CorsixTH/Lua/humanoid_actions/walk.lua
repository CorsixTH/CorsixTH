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

local function action_walk_interrupt(action, humanoid)
  -- Truncate the remainder of the path
  for j = #action.path_x, action.path_index + 1, -1 do
    action.path_x[j] = nil
    action.path_y[j] = nil
  end
end

local flag_list_bottom = 2048
local flag_early_list = 1024
local flag_flip_h = 1

local navigateDoor

local function action_walk_raw(humanoid, x1, y1, x2, y2, map, timer_fn)
  local anims = humanoid.walk_anims
  if x1 ~= x2 then
    if x1 < x2 then
      if map and map:getCellFlags(x2, y2).doorWest then
        return navigateDoor(humanoid, x1, y1, "east")
      else
        humanoid.last_move_direction = "east"
        humanoid:setAnimation(anims.walk_east, flag_early_list)
        humanoid:setTilePositionSpeed(x2, y2, -32, -16, 4, 2)
      end
    else
      if map and map:getCellFlags(x1, y1).doorWest then
        return navigateDoor(humanoid, x1, y1, "west")
      else
        humanoid.last_move_direction = "west"
        humanoid:setAnimation(anims.walk_north, flag_early_list + flag_flip_h)
        humanoid:setTilePositionSpeed(x1, y1, 0, 0, -4, -2)
      end
    end
  else
    if y1 < y2 then
      if map and map:getCellFlags(x2, y2).doorNorth then
        return navigateDoor(humanoid, x1, y1, "south")
      else
        humanoid.last_move_direction = "south"
        humanoid:setAnimation(anims.walk_east, flag_flip_h)
        humanoid:setTilePositionSpeed(x2, y2, 32, -16, -4, 2)
      end
    else
      if map and map:getCellFlags(x1, y1).doorNorth then
        return navigateDoor(humanoid, x1, y1, "north")
      else
        humanoid.last_move_direction = "north"
        humanoid:setAnimation(anims.walk_north)
        humanoid:setTilePositionSpeed(x1, y1, 0, 0, 4, -2)
      end
    end
  end
  humanoid:setTimer(8, timer_fn)
end

local function action_walk_tick(humanoid)
  local action = humanoid.action_queue[1]
  local path_x = action.path_x
  local path_y = action.path_y
  local path_index = action.path_index
  local check_doors = not not humanoid.door_anims
  local x1, y1 = path_x[path_index  ], path_y[path_index  ]
  local x2, y2 = path_x[path_index+1], path_y[path_index+1]
  
  if not x2 then
    -- Arrival at final tile
    humanoid:setTilePositionSpeed(x1, y1)
    humanoid:finishAction(action)
    if action.when_done then
      action.when_done()
    end
    return
  end
  
  -- Make sure that the next tile hasn't somehow become impassable since our
  -- route was determined
  local map = humanoid.world.map.th
  if not map:getCellFlags(x2, y2).passable then
    if map:getCellFlags(x1, y1).passable then
      humanoid:setTilePositionSpeed(x1, y1)
      return action:on_restart(humanoid)
    end
  end
  
  action_walk_raw(humanoid, x1, y1, x2, y2, check_doors and map, action_walk_tick)
  action.path_index = path_index + 1
end

-- This is a slight hack, but is the easiest way to make walk functionality
-- available to other actions which want to do low-level walk operations.
strict_declare_global "HumanoidRawWalk"
HumanoidRawWalk = action_walk_raw

local function action_walk_tick_door(humanoid)
  local door = humanoid.user_of
  door:setUser(nil)
  humanoid.user_of = nil
  if door.queue:size() > 0 then
    door.queue:pop()
  end
  return action_walk_tick(humanoid)
end

navigateDoor = function(humanoid, x1, y1, dir)
  local action = humanoid.action_queue[1]
  local duration = 12
  local dx = x1
  local dy = y1
  if dir == "east" then
    dx = dx + 1
    duration = 10
  elseif dir == "south" then
    dy = dy + 1
    duration = 10
  end
  
  local door = humanoid.world:getObject(dx, dy, "door")
  if door.user or (door.reserved_for and door.reserved_for ~= humanoid) then
    -- door in use; go idle (or find a bench) and try again later
    humanoid:setTilePositionSpeed(x1, y1)
    action.must_happen = action.saved_must_happen
    action.reserve_on_resume = door
    local queue = door.queue
    local bench, ix, iy = humanoid.world:getFreeBench(x1, y1, 10)
    if not ix then
      ix, iy = humanoid.world:getIdleTile(x1, y1, queue:size())
      if not ix then
        ix, iy = humanoid.world:getIdleTile(x1, y1)
      end
    end
    if ix then
      humanoid:queueAction({
        name = "walk",
        until_leave_queue = queue,
        must_happen = action.saved_must_happen,
        destination_unimportant = not bench,
        x = ix,
        y = iy,
      }, 0)
    end
    if bench then
      humanoid:queueAction({
        name = "use_object",
        until_leave_queue = queue,
        must_happen = action.saved_must_happen,
        object = bench
      }, 1)
      bench.reserved_for = humanoid
    else
      humanoid:queueAction({
        name = "idle",
        until_leave_queue = queue,
        must_happen = action.saved_must_happen,
        x1 = x1,
        y1 = y1,
      }, ix and 1 or 0)
    end
    door.queue:push(humanoid)
    return
  end
  
  local anims = humanoid.door_anims
  humanoid:setTile(dx, dy)
  humanoid:setSpeed(0, 0)
  humanoid.user_of = door
  door:setUser(humanoid)
  if dir == "north" then
    humanoid:setAnimation(anims.leaving, flag_list_bottom)
    humanoid:setPosition(-1, 0)
  elseif dir == "west" then
    humanoid:setAnimation(anims.leaving, flag_list_bottom + flag_early_list + flag_flip_h)
    humanoid:setPosition(1, 0)
  elseif dir == "east" then
    humanoid:setAnimation(anims.entering, flag_list_bottom + flag_early_list)
    humanoid:setPosition(-1, 0)
  elseif dir == "south" then
    humanoid:setAnimation(anims.entering, flag_list_bottom + flag_flip_h)
    humanoid:setPosition(1, 0)
  end
  humanoid.last_move_direction = dir
  
  action.path_index = action.path_index + 1
  humanoid:setTimer(duration, action_walk_tick_door)
end

local function action_walk_start(action, humanoid)
  -- Possible future optimisation: when walking from somewhere inside the hospital
  -- to somewhere outside the hospital (or from one building to another?), do
  -- pathfinding in two steps, with the building door as a middle node
  local path_x, path_y = humanoid.world:getPath(humanoid.tile_x, humanoid.tile_y, action.x, action.y)
  if not path_x then
    humanoid:setTimer(1, humanoid.finishAction)
    return
  end
  action.path_x = path_x
  action.path_y = path_y
  action.path_index = 1
  action.on_interrupt = action_walk_interrupt
  action.on_restart = action_walk_start
  action.saved_must_happen = action.must_happen
  action.must_happen = true
  if action.reserve_on_resume then
    action.reserve_on_resume.reserved_for = humanoid
    action.reserve_on_resume = nil
  end
  
  return action_walk_tick(humanoid)
end

return action_walk_start
