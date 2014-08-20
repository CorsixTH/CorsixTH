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

local action_die_tick; action_die_tick = permanent"action_die_tick"( function(humanoid)
  local action = humanoid.action_queue[1]
  local phase = action.phase
  local mirror = humanoid.last_move_direction == "east" and 0 or 1
  if phase == 0 then
    action.phase = 1
    if humanoid.die_anims.extra_east ~= nil then
      humanoid:setTimer(humanoid.world:getAnimLength(humanoid.die_anims.extra_east), action_die_tick)
      humanoid:setAnimation(humanoid.die_anims.extra_east, mirror)
    else
      action_die_tick(humanoid)
    end
  elseif phase == 1 then
    action.phase = 2
    humanoid:setTimer(11, action_die_tick)
    humanoid:setAnimation(humanoid.die_anims.rise_east, mirror)
  elseif phase == 2 then
    -- Female slack tongue head layer is missing from wings animation onwards
    -- So we change the head to its standard equivalent
    if humanoid.humanoid_class == "Slack Female Patient" then
      humanoid:setLayer(0, humanoid.layers[0] - 8)
    end

    action.phase = 3
    humanoid:setTimer(11, action_die_tick)
    humanoid:setAnimation(humanoid.die_anims.wings_east, mirror)
  elseif phase == 3 then
    action.phase = 4
    humanoid:setTimer(15, action_die_tick)
    humanoid:setAnimation(humanoid.die_anims.hands_east, mirror)
  elseif phase == 4 then
    action.phase = 5
    humanoid:setTimer(30, action_die_tick)
    humanoid:setAnimation(humanoid.die_anims.fly_east, mirror)
    humanoid:setTilePositionSpeed(humanoid.tile_x, humanoid.tile_y, nil, nil, 0, -4)
  else
    humanoid:setHospital(nil)
    humanoid.world:destroyEntity(humanoid)
  end
end)

local function action_die_start(action, humanoid)
  humanoid:setMoodInfo() -- clear all mood icons
  local preferred_fall_direction = nil
  if math.random(0, 1) == 1 then
    preferred_fall_direction = "east"
  else
    preferred_fall_direction = "south"
  end
  local anims = humanoid.die_anims
  assert(anims, "Error: no death animation for humanoid ".. humanoid.humanoid_class)
  action.must_happen = true
  -- TODO: Right now the angel version of death is the only possibility
  -- The Grim Reaper should sometimes also have a go.
  local fall = anims.fall_east

  --If this isn't done their bald head will become bloated instead of suddenly having hair:
  if humanoid.disease.id == "baldness" then humanoid:setLayer(0,2) end

  --[[Make the patient fall over: because this animation requires two tiles make sure there's
  enough space for this animation--]]
  local mirror_fall = -1
  local east_tile_usable = humanoid.world:isTileEmpty(humanoid.tile_x + 1, humanoid.tile_y, true)
  local south_tile_usable = humanoid.world:isTileEmpty(humanoid.tile_x, humanoid.tile_y + 1, true)
  --Are the preferred fall directions usable?
  if preferred_fall_direction == "east" and east_tile_usable then
    humanoid.last_move_direction = "east"
    mirror_fall = 0
  elseif preferred_fall_direction == "south" and south_tile_usable then
    humanoid.last_move_direction = "south"
    mirror_fall = 1
  else
    --If the preferred direction isn't usable try the other direction:
    if east_tile_usable then
      humanoid.last_move_direction = "east"
      mirror_fall = 0
    elseif south_tile_usable then
      humanoid.last_move_direction = "south"
      mirror_fall = 1
    --[[If the patient's last move direction was east or south then there could be no fall space available so this else
      closure makes them walk to an accessible adjacent tile so that they can then fall on to their current tile:]]--
    else
      -- Either the west or north tile will be accessible because this else closure can only be reached if the tiles adjacent to
      -- the patient east and south are blocked and this game doesn't allow patients to become stuck by having all the tiles
      -- adjacent to them become obstructed by objects and/or rooms:
      if humanoid.world:isTileEmpty(humanoid.tile_x - 1, humanoid.tile_y, true) then
        humanoid:walkTo(humanoid.tile_x - 1, humanoid.tile_y)
      else
        humanoid:walkTo(humanoid.tile_x, humanoid.tile_y - 1)
      end
      humanoid:queueAction({name = "die"})
      humanoid:finishAction()
      return
    end
  end

  humanoid:setAnimation(anims.fall_east, mirror_fall)

  action.phase = 0

  if humanoid.humanoid_class == "Chewbacca Patient" then
    --After 21 ticks the first frame of the buggy falling part of this animation is reached
    --so this animation is ended early, action_die_tick will then use the standard male fall animation:
    humanoid:setTimer(21, action_die_tick)
  else
    humanoid:setTimer(humanoid.world:getAnimLength(fall), action_die_tick)
  end
end

return action_die_start
