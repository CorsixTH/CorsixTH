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

class "WalkAction" (HumanoidAction)

---@type WalkAction
local WalkAction = _G["WalkAction"]

--! Action to walk to a given position.
--!param x (int) X coordinate of the destination tile.
--!param y (int) Y coordinate of the destination tile.
--!param trimmed (boolean) Optional parameter to finish action on re-route
function WalkAction:WalkAction(x, y, trimmed)
  assert(type(x) == "number", "Invalid value for parameter 'x'")
  assert(type(y) == "number", "Invalid value for parameter 'y'")

  self:HumanoidAction("walk")
  self.x = x
  self.y = y
  self.trimmed = trimmed
  self.truncate_only_on_high_priority = false
  self.walking_to_vaccinate = false -- Nurse walking with the intention to vaccinate
  self.is_entering = false -- Whether the walk enters a room.
end

function WalkAction:truncateOnHighPriority()
  self.truncate_only_on_high_priority = true
  return self
end

--! Nurse is walking with the intention to vaccinate.
--!return (action) self, for daisy-chaining.
function WalkAction:enableWalkingToVaccinate()
  self.walking_to_vaccinate = true
  return self
end

--! Set a flag whether the walk enters a room.
--!param entering (bool) If set or nil, set the flag of entering the room.
--!return (action) self, for daisy-chaining.
function WalkAction:setIsEntering(entering)
  assert(type(entering) == "boolean", "Invalid value for parameter 'entering'")

  self.is_entering = entering
  return self
end

local action_walk_interrupt
action_walk_interrupt = permanent"action_walk_interrupt"( function(action, humanoid, high_priority)
  if action.truncate_only_on_high_priority and not high_priority then
    action.on_interrupt = action_walk_interrupt
    return
  end

  -- Truncate the remainder of the path
  for j = #action.path_x, action.path_index + 1, -1 do
    action.path_x[j] = nil
    action.path_y[j] = nil
  end
  -- Unreserve any door which we had reserved unless specifically told not to.
  if not action.keep_reserved then
    local door = action.reserve_on_resume
    if door and (door.reserved_for == humanoid or class.is(humanoid, Vip)) then --  "or class.is(humanoid, Vip)" is added as a temporary fix
  -- TODO: find the cause of the "VIP bug", why does the door not get unreserved sometimes when the VIP has looked into a room? See issue 1025
      door.reserved_for = nil
      door:getRoom():tryAdvanceQueue()
    end

    -- guarding with the action.keep_reserved check as we don't want to unexpect
    -- if we are just interrupting but resume the walk action afterwards
    humanoid:unexpectFromRoom(humanoid.world:getRoom(action.x, action.y))
  else
    -- This flag can be used only once at a time.
    action.keep_reserved = nil
  end

  -- Terminate immediately if high-priority
  if high_priority then
    local timer_function = humanoid.timer_function
    humanoid:setTimer(nil)
    timer_function(humanoid)
  end

  if action.walking_to_vaccinate then
    local hospital = humanoid.hospital or humanoid.last_hospital
    local epidemic = hospital.epidemic
    if epidemic then
      epidemic:interruptVaccinationActions(humanoid)
    end
  end
end)

local flag_list_bottom = 2048
local flag_flip_h = 1

local navigateDoor

local function action_walk_raw(humanoid, x1, y1, x2, y2, map, timer_fn)
  -- The variables below must always make up factor*quantity = 8 or the
  -- animation glitches
  -- Factor must also be able to multiply by 2 to become an integer
  -- Quantity must always be an integer
  local factor = 1
  local quantity = 8
  if humanoid.speed and humanoid.speed == "fast" then
    factor = 2
    quantity = 4
  end

  local anims = humanoid.walk_anims
  local world = humanoid.world
  local notify_object = world:getObjectToNotifyOfOccupants(x2, y2)
  if notify_object then
    notify_object:onOccupantChange(1)
  end
  notify_object = world:getObjectToNotifyOfOccupants(x1, y1)
  if notify_object then
    notify_object:onOccupantChange(-1)
  end
  if x1 ~= x2 then
    if x1 < x2 then
      if map and map:getCellFlags(x2, y2).doorWest then
        return navigateDoor(humanoid, x1, y1, "east")
      else
        humanoid.last_move_direction = "east"
        humanoid:setAnimation(anims.walk_east)
        humanoid:setTilePositionSpeed(x2, y2, -32, -16, 4*factor, 2*factor)
      end
    else
      if map and map:getCellFlags(x1, y1).doorWest then
        return navigateDoor(humanoid, x1, y1, "west")
      else
        humanoid.last_move_direction = "west"
        humanoid:setAnimation(anims.walk_north, flag_flip_h)
        humanoid:setTilePositionSpeed(x1, y1, 0, 0, -4*factor, -2*factor)
      end
    end
  else
    if y1 < y2 then
      if map and map:getCellFlags(x2, y2).doorNorth then
        return navigateDoor(humanoid, x1, y1, "south")
      else
        humanoid.last_move_direction = "south"
        humanoid:setAnimation(anims.walk_east, flag_flip_h)
        humanoid:setTilePositionSpeed(x2, y2, 32, -16, -4*factor, 2*factor)
      end
    else
      if map and map:getCellFlags(x1, y1).doorNorth then
        return navigateDoor(humanoid, x1, y1, "north")
      else
        humanoid.last_move_direction = "north"
        humanoid:setAnimation(anims.walk_north)
        humanoid:setTilePositionSpeed(x1, y1, 0, 0, 4*factor, -2*factor)
      end
    end
  end
  humanoid:setTimer(quantity, timer_fn)
end

local flags_here, flags_there = {}, {}
local action_walk_tick; action_walk_tick = permanent"action_walk_tick"( function(humanoid)
  local action = humanoid:getCurrentAction()
  local path_x = action.path_x
  local path_y = action.path_y
  local path_index = action.path_index
  local check_doors = not not humanoid.door_anims
  local x1, y1 = path_x[path_index  ], path_y[path_index  ]
  local x2, y2 = path_x[path_index+1], path_y[path_index+1]

  if not x2 then
    -- Arrival at final tile
    humanoid:setTilePositionSpeed(x1, y1)
    if action.on_next_tile_set then
      action.on_next_tile_set()
    end
    humanoid:finishAction(action)
    return
  end

  -- Make sure that the next tile hasn't somehow become impassable since our
  -- route was determined
  local map = humanoid.world.map.th
  map:getCellFlags(x1, y1, flags_here)
  map:getCellFlags(x2, y2, flags_there)
  local recalc_route = not flags_there.passable and flags_here.passable
  -- Also make sure that a room hasn't unexpectedly been built on top of the
  -- path since the route was calculated.
  if not recalc_route and flags_here.roomId ~= flags_there.roomId then
    -- if going to the corridor we don't care as we are at the door
    -- as this will be false we won't bother checking for rerouting
    recalc_route = flags_there.room
    local door = TheApp.objects.door.id
    local door2 = TheApp.objects.swing_door_right.id
    local doorcheck = {[door] = true, [door2] = true}
    -- but we should see if this is the same room id we want to go to and cancel the reroute
    -- ensure we still have a door on this route
    if recalc_route and (humanoid.world:getObject(x1, y1, doorcheck) or
        humanoid.world:getObject(x2, y2, doorcheck)) and -- is there any door
        map:getCellFlags(path_x[#path_x], path_y[#path_y]).roomId ==
        flags_there.roomId then
      -- A walk including a trimmed path could have the last tile inside a room, and
      -- might need a new route completely (e.g. seek reception)
      recalc_route = action.trimmed
    end
  end
  if recalc_route then
    if map:getCellFlags(x1, y1).passable then
      humanoid:setTilePositionSpeed(x1, y1)
      if action.on_next_tile_set then
        action.on_next_tile_set()
      end
      if action.trimmed then -- request new route
        humanoid:finishAction(action)
        return
      end
      return action:on_restart(humanoid)
    end
  end

  -- on_next_tile_set can be set in the call to action_walk_raw, but it is
  -- then to be called AFTER the next raw walk or tile set, which is why we
  -- remember the previous value and call that, rather than call the new value.
  local on_next_tile_set = action.on_next_tile_set
  action_walk_raw(humanoid, x1, y1, x2, y2, check_doors and map, action_walk_tick)
  action.path_index = path_index + 1
  if on_next_tile_set then
    on_next_tile_set()
  end
end)

-- This is a slight hack, but is the easiest way to make walk functionality
-- available to other actions which want to do low-level walk operations.
strict_declare_global "HumanoidRawWalk"
HumanoidRawWalk = action_walk_raw

local action_walk_tick_door = permanent"action_walk_tick_door"( function(humanoid)
  local door = humanoid.user_of
  if not class.is(door, SwingDoor) then
    -- The doors will need to finish swinging before another humanoid can walk through.
    door:removeUser(humanoid)
  end
  humanoid.user_of = nil
  return action_walk_tick(humanoid)
end)

navigateDoor = function(humanoid, x1, y1, dir)
  local action = humanoid:getCurrentAction()
  local dx = x1
  local dy = y1
  if dir == "east" then
    dx = dx + 1
  elseif dir == "south" then
    dy = dy + 1
  end
  local swinging = false
  local door = humanoid.world:getObject(dx, dy, "door")
  if not door then
    swinging = true
    door = humanoid.world:getObject(dx, dy, "swing_door_right")
  end
  door.queue:unexpect(humanoid)
  door:updateDynamicInfo()
  local room = door:getRoom()
  local is_entering_room = room and humanoid:getRoom() ~= room

  if class.is(humanoid, Staff) and is_entering_room and
      humanoid.humanoid_class ~= "Handyman" then
    -- A member of staff is entering, but is maybe no longer needed
    -- in this room?
    if not room.is_active or not room:staffFitsInRoom(humanoid) then
      humanoid:queueAction(IdleAction(), 0)
      humanoid:setTilePositionSpeed(x1, y1)
      humanoid:setNextAction(IdleAction():setCount(10), 0)
      humanoid:queueAction(MeanderAction())
      if door.reserved_for == humanoid then
        door.reserved_for = nil
        room:tryAdvanceQueue()
      end
      return
    end
  end
  if door.user or (door.reserved_for and door.reserved_for ~= humanoid) or
      (is_entering_room and not room:canHumanoidEnter(humanoid)) then
    local queue = door.queue
    if door.reserved_for == humanoid then
      door.reserved_for = nil
      room:tryAdvanceQueue()
    end
    humanoid:setTilePositionSpeed(x1, y1)
    local action_index = 0
    if is_entering_room and queue:size() == 0 and not room:getPatient() and
        not door.user and not door.reserved_for and humanoid.should_knock_on_doors and
        room.room_info.required_staff and not swinging then
      humanoid:queueAction(KnockDoorAction(humanoid, door, dir), action_index)
      action_index = action_index + 1
    end
    -- a doctor/nurse answering a call but not yet left the room will not ever be leaving
    -- if they happen to queue when leaving the room, humanoid:isLeaving will not reflect
    -- the true state, so just use the is_entering_room fact instead
    humanoid:queueAction(QueueAction(x1, y1, queue):setIsLeaving(not is_entering_room)
        :setReserveWhenDone(door), action_index)
    action.must_happen = action.saved_must_happen
    action.reserve_on_resume = door
    return
  end
  if action.reserve_on_resume then
    assert(action.reserve_on_resume == door)
    action.reserve_on_resume = nil
  elseif is_entering_room and not action.done_knock and humanoid.should_knock_on_doors and
      room.room_info.required_staff and not swinging then
    humanoid:setTilePositionSpeed(x1, y1)
    humanoid:queueAction(KnockDoorAction(humanoid, door, dir), 0)
    action.reserve_on_resume = door
    action.done_knock = true
    return
  end

  local to_x, to_y
  local anims = humanoid.door_anims
  if not anims.leaving or not anims.entering then
    local from_rm, to_rm = room.room_info.id, "corridor"
    if is_entering_room then
      from_rm, to_rm = to_rm, from_rm
    end
    error(("Humanoid (%s) without door animations trying to walk through "..
      "door (from %s to %s)"):format(humanoid.humanoid_class, from_rm, to_rm))
  end
  humanoid:setTilePositionSpeed(dx, dy)
  humanoid.user_of = door
  door:setUser(humanoid)
  local entering = swinging and anims.entering_swing or anims.entering
  local leaving = swinging and anims.leaving_swing or anims.leaving

  local duration, direction
  if dir == "north" then
    humanoid:setAnimation(leaving, flag_list_bottom)
    duration = humanoid.world:getAnimLength(leaving)
    to_x, to_y = dx, dy - 1
    direction = "in"

  elseif dir == "west" then
    humanoid:setAnimation(leaving, flag_list_bottom + flag_flip_h)
    duration = humanoid.world:getAnimLength(leaving)
    to_x, to_y = dx - 1, dy
    direction = "in"

  elseif dir == "east" then
    humanoid:setAnimation(entering, flag_list_bottom)
    duration = humanoid.world:getAnimLength(entering)
    to_x, to_y = dx, dy
    direction = "out"

  elseif dir == "south" then
    humanoid:setAnimation(entering, flag_list_bottom + flag_flip_h)
    duration = humanoid.world:getAnimLength(entering)
    to_x, to_y = dx, dy
    direction = "out"
  end

  humanoid.last_move_direction = dir
  if swinging then
    door:swingDoors(direction, duration)
  end

  -- We want to notify the rooms on either side of the door that the humanoid
  -- has entered / left, but we want to do this AFTER the humanoid has gone
  -- through the door (so that their tile position reflects the room which they
  -- are now in).
  local --[[persistable:action_walk_on_next_tile_set]] function on_next_tile_set()
    if action.on_next_tile_set == on_next_tile_set then
      action.on_next_tile_set = nil
    end
    local rm = humanoid.world:getRoom(x1, y1)
    if rm then
      rm:onHumanoidLeave(humanoid)
    end
    rm = humanoid.world:getRoom(to_x, to_y)
    if rm then
      rm:onHumanoidEnter(humanoid)
    end
  end
  action.on_next_tile_set = on_next_tile_set

  if is_entering_room then
    humanoid.in_room = room
  end

  action.path_index = action.path_index + 1
  humanoid:setTimer(duration, action_walk_tick_door)
end

local function action_walk_start(action, humanoid)
  -- Possible future optimisation: when walking from somewhere inside the hospital
  -- to somewhere outside the hospital (or from one building to another?), do
  -- pathfinding in two steps, with the building door as a middle node
  local path_x, path_y = humanoid.world:getPath(humanoid.tile_x, humanoid.tile_y, action.x, action.y)
  if not path_x or #path_x == 1 then
    -- Finishing an action from within the start handler is a very bad idea, as
    -- it is normal when ordering several actions to setNextAction the first
    -- one, then queueAction the rest. If the first starts straight away, and
    -- then finishes straight away, then the humanoid is left with an empty
    -- action queue. Hence we wait one tick before finishing. We still need to
    -- set the humanoid animation / position though, which is delegated to the
    -- idle action (if this wasn't done, then the previous animation would be
    -- used, which might involve an object).
    TheApp.humanoid_actions.idle(action, humanoid)
    humanoid:setTimer(1, humanoid.finishAction)
    return
  end
  action.path_x = path_x
  action.path_y = path_y
  action.path_index = 1
  if not action.no_truncate then
    action.on_interrupt = action_walk_interrupt
  end
  action.on_restart = action_walk_start
  action.saved_must_happen = action.must_happen
  action.must_happen = true
  if action.reserve_on_resume and not action.todo_interrupt then
    action.reserve_on_resume.reserved_for = humanoid
  end

  return action_walk_tick(humanoid)
end

return action_walk_start
