--[[ Copyright (c) 2009 Edvin "Lego3" Linge

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

local function action_die_tick(humanoid)
  local action = humanoid.action_queue[1]
  local phase = action.phase
  local mirror = humanoid.last_move_direction == "east" and 0 or 1
  if phase == 0 then
    action.phase = 1
    humanoid:setTimer(11, action_die_tick)
    humanoid:setAnimation(humanoid.die_anims.rise_east, mirror)
  elseif phase == 1 then
    action.phase = 2
    humanoid:setTimer(11, action_die_tick)
    humanoid:setAnimation(humanoid.die_anims.wings_east, mirror)
  elseif phase == 2 then
    action.phase = 3
    humanoid:setTimer(15, action_die_tick)
    humanoid:setAnimation(humanoid.die_anims.hands_east, mirror)
  elseif phase == 3 then
    action.phase = 4
    humanoid:setTimer(30, action_die_tick)
    humanoid:setAnimation(humanoid.die_anims.fly_east, mirror)
    humanoid:setTilePositionSpeed(humanoid.tile_x, humanoid.tile_y, nil, nil, 0, -4)
  else
    humanoid:setHospital(nil)
    humanoid.world:destroyEntity(humanoid)
  end
end

local function action_die_start(action, humanoid)
  if math.random(0, 1) == 1 then
    humanoid.last_move_direction = "east"
  else
    humanoid.last_move_direction = "south"
  end
  local direction = humanoid.last_move_direction
  local anims = humanoid.die_anims
  assert(anims, "Error: no death animation for humanoid ".. humanoid.humanoid_class)
  action.must_happen = true
  -- TODO: Right now the angle version of death is the only possibility
  -- The Grim Reaper should sometimes also have a go.
  if direction == "east" then
    humanoid:setAnimation(anims.fall_east, 0)
  elseif direction == "south" then
    humanoid:setAnimation(anims.fall_east, 1)
  end
  action.phase = 0
  humanoid:setTimer(15, action_die_tick)
end

return action_die_start
