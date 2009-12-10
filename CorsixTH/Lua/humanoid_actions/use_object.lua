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

local orient_mirror = {
  north = "west",
  west = "north",
  east = "south",
  south = "east",
}

local function action_use_next_phase(action, phase)
  phase = phase + 1
  if phase < -4 then
    phase = -4
  end
  if phase == -4 and not action.do_walk then
    phase = phase + 1
  end
  if phase == -3 and not action.anims.begin_use then
    phase = phase + 1
  end
  if phase == -2 and not action.anims.begin_use_2 then
    phase = phase + 1
  end
  if phase == -1 and not action.anims.begin_use_3 then
    phase = phase + 1
  end
  if phase == 0 and not action.anims.in_use then
    phase = phase + 1
  end
  if phase == 1 and not action.anims.finish_use then
    phase = phase + 1
  end
  if phase == 2 and not action.do_walk then
    phase = phase + 1
  end
  if phase > 2 then
    phase = 100
  end
  return phase
end

local action_use_object_tick

local function action_use_phase(action, humanoid, phase)
  local object = action.object
  humanoid.user_of = nil -- Temporary to avoid tile change warning
  action.phase = phase
  if phase == -4 then
    HumanoidRawWalk(humanoid,
      action.old_tile_x, action.old_tile_y,
      object.tile_x, object.tile_y,
      nil, action_use_object_tick)
    return
  elseif phase == 2 then
    HumanoidRawWalk(humanoid,
      object.tile_x, object.tile_y,
      action.old_tile_x, action.old_tile_y,
      nil, action_use_object_tick)
    return
  end
  local anim_table = action.anims.in_use
  if phase == -3 then
    anim_table = action.anims.begin_use
  elseif phase == -2 then
    anim_table = action.anims.begin_use_2
  elseif phase == -1 then
    anim_table = action.anims.begin_use_3
  elseif phase == 1 then
    anim_table = action.anims.finish_use
  end
  local is_list = false
  local anim = anim_table[humanoid.humanoid_class]
  if type(anim) == "table" then
    -- If an animation list is provided rather than a single animation, then
    -- choose an animation from the list at random.
    is_list = true
    anim = anim[math.random(1, #anim)]
  end
  if not anim then
    error("No animation for " .. humanoid.humanoid_class .. " using " ..
      object.object_type.id .. " facing " .. object.direction .. " phase " ..
      phase)
  end
  humanoid:setAnimation(anim, action.mirror_flags)
  
  local offset = object.object_type.orientations
  if offset then
    local tx, ty
    offset = offset[object.direction]
    if offset.use_animate_from_use_position then
      tx, ty = action.old_tile_x, action.old_tile_y
    else
      tx, ty = object:getRenderAttachTile()
    end
    offset = offset.animation_offset
    humanoid:setTilePositionSpeed(tx, ty, offset[1], offset[2])
  else
    humanoid:setTilePositionSpeed(object.tile_x, object.tile_y, 0, 0)
  end
  humanoid.user_of = object
  local length = humanoid.world:getAnimLength(anim)
  if phase == 0 and (not is_list) and length == 1 and action.prolonged_usage and action.on_interrupt and not action.loop_callback then
    -- a timer would be redundant, so do not set one
  else
    humanoid:setTimer(length, action_use_object_tick)
  end
end

action_use_object_tick = function(humanoid)
  local action = humanoid.action_queue[1]
  local object = action.object
  local phase = action.phase
  local oldphase = phase
  if oldphase == -4 then
    object:setUser(humanoid)
    humanoid.user_of = object
  end
  if phase ~= 0 or not action.prolonged_usage or not action.on_interrupt then
    phase = action_use_next_phase(action, phase)
  elseif action.loop_callback then
    action:loop_callback()
  end
  if oldphase <= 1 and phase > 1 then
    object:setUser(nil)
    humanoid.user_of = nil
  end
  if phase == 100 then
    humanoid:setTilePositionSpeed(action.old_tile_x, action.old_tile_y)
    humanoid:finishAction(action)
  else
    action_use_phase(action, humanoid, phase)
  end
end

local function action_use_object_interrupt(action, humanoid, high_priority)
  if high_priority then
    local object = action.object
    if humanoid.user_of then
      object:setUser(nil)
      humanoid.user_of = nil
    elseif object.reserved_for == humanoid then
      object.reserved_for = nil
    end
    humanoid:setTimer(nil)
    humanoid:setTilePositionSpeed(action.old_tile_x, action.old_tile_y)
    humanoid:finishAction()
  elseif not humanoid.timer_function then
    humanoid:setTimer(1, action_use_object_tick)
  end
end

local function action_use_object_start(action, humanoid)
  action.old_tile_x = humanoid.tile_x
  action.old_tile_y = humanoid.tile_y
  action.on_interrupt = action_use_object_interrupt
  action.must_happen = true
  local object = action.object
  local orient = object.direction
  local flags = 0
  if not object.object_type.usage_animations[orient] then
    orient = orient_mirror[orient]
    flags = flags + 1
  end
  local spec = object.object_type.orientations[object.direction]
  -- early_list_while_in_use (if defined) will take precedence over early_list
  if spec.early_list_while_in_use or (spec.early_list_while_in_use == nil and spec.early_list) then
    flags = flags + 1024
  end
  if spec.finish_use_position then
    action.old_tile_x = object.tile_x + spec.finish_use_position[1]
    action.old_tile_y = object.tile_y + spec.finish_use_position[2]
  end
  local anims = object.object_type.usage_animations[orient]
  action.anims = anims
  action.mirror_flags = flags
  if anims.begin_use and anims.in_use and anims.finish_use then
    action.prolonged_usage = true
  end
  if object.object_type.walk_in_to_use then
    action.do_walk = true
  else
    object:setUser(humanoid)
    humanoid.user_of = object
  end
  action_use_phase(action, humanoid, action_use_next_phase(action, -100))
end

return action_use_object_start
