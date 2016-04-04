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

local orient_opposite = {
  north = "south",
  west = "east",
  east = "west",
  south = "north",
}

local action_spawn_despawn = permanent"action_spawn_despawn"( function(humanoid)
  if humanoid.hospital then
    humanoid:despawn()
  end
  humanoid.world:destroyEntity(humanoid)
end)

local function action_spawn_start(action, humanoid)
  assert(action.mode == "spawn" or action.mode == "despawn", "spawn action given invalid mode: " .. action.mode)
  local x, y =  action.point.x,  action.point.y
  if action.mode == "despawn" and (humanoid.tile_x ~= x or humanoid.tile_y ~= y) then
    humanoid:queueAction({
      name = "walk",
      x = action.point.x,
      y = action.point.y,
      must_happen = action.must_happen,
    }, 0)
    return
  end
  action.must_happen = true

  local anims = humanoid.walk_anims
  local walk_dir = action.point.direction
  if action.mode == "spawn" then
    walk_dir = orient_opposite[walk_dir]
  end
  -- These two values specifies how many tiles away the patient should start walking before actually
  -- spawning in the destination tile. Default is 2, and it should not be set to 0.
  local offset_x = 2
  local offset_y = 2
  if action.offset then
    offset_x = action.offset.x and action.offset.x or 2
    offset_y = action.offset.y and action.offset.y or 2
  end
  assert(offset_x > 0 and offset_y > 0, "Spawning needs to be done from an adjacent tile.")
  local anim, flag, speed_x, speed_y, duration
  if walk_dir == "east" then
    anim, flag, speed_x, speed_y, duration = anims.walk_east , 0,  4,  2, 10*offset_x
  elseif walk_dir == "west" then
    anim, flag, speed_x, speed_y, duration = anims.walk_north, 1, -4, -2, 10*offset_x
  elseif walk_dir == "south" then
    anim, flag, speed_x, speed_y, duration = anims.walk_east , 1, -4,  2, 10*offset_y
  else--if walk_dir == "north" then
    anim, flag, speed_x, speed_y, duration = anims.walk_north, 0,  4, -2, 10*offset_y
  end
  humanoid.last_move_direction = walk_dir
  humanoid:setAnimation(anim, flag)
  local pos_x, pos_y = 0, 0
  if action.mode == "spawn" then
    pos_x = -speed_x * duration
    pos_y = -speed_y * duration
    humanoid:setTimer(duration, humanoid.finishAction)
  else
    humanoid:setTimer(duration, action_spawn_despawn)
  end
  humanoid:setTilePositionSpeed(x, y, pos_x, pos_y, speed_x, speed_y)
end

return action_spawn_start
