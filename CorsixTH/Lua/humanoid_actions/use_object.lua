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

local TH = require "TH"

local orient_mirror = {
  north = "west",
  west = "north",
  east = "south",
  south = "east",
}

local function action_use_next_phase(action, phase)
  phase = phase + 1
  if phase < -6 then
    phase = -6
  end
  if phase == -6 and not action.do_walk then
    phase = phase + 1
  end
  if phase == -5 and not action.anims.begin_use then
    phase = phase + 1
  end
  if phase == -4 and not action.anims.begin_use_2 then
    phase = phase + 1
  end
  if phase == -3 and not action.anims.begin_use_3 then
    phase = phase + 1
  end
    if phase == -2 and not action.anims.begin_use_4 then
    phase = phase + 1
  end
    if phase == -1 and not action.anims.begin_use_5 then
    phase = phase + 1
  end
  if phase == 0 and not action.anims.in_use then
    phase = phase + 1
  end
  if phase == 1 and not action.anims.finish_use then
    phase = phase + 1
  end
  if phase == 2 and not action.anims.finish_use_2 then
    phase = phase + 1
  end
  if phase == 3 and not action.anims.finish_use_3 then
    phase = phase + 1
  end
    if phase == 4 and not action.anims.finish_use_4 then
    phase = phase + 1
  end
    if phase == 5 and not action.anims.finish_use_5 then
    phase = phase + 1
  end
  if phase == 6 and not action.do_walk or phase == 6 and action.destroy_user_after_use then
    phase = phase + 1
  end
  if phase > 6 then
    phase = 100
  end
  return phase
end

local action_use_object_tick

local function action_use_phase(action, humanoid, phase)
  local object = action.object
  humanoid.user_of = nil -- Temporary to avoid tile change warning
  action.phase = phase

  if phase == -6 then
    HumanoidRawWalk(humanoid,
      action.old_tile_x, action.old_tile_y,
      action.new_tile_x, action.new_tile_y,
      nil, action_use_object_tick)
    return
  elseif phase == 6 then
    HumanoidRawWalk(humanoid,
      action.new_tile_x, action.new_tile_y,
      action.old_tile_x, action.old_tile_y,
      nil, action_use_object_tick)
    return
  end
  local anim_table = action.anims.in_use
  if phase == -5 then
    anim_table = action.anims.begin_use
  elseif phase == -4 then
    anim_table = action.anims.begin_use_2
  elseif phase == -3 then
    anim_table = action.anims.begin_use_3
  elseif phase == -2 then
    anim_table = action.anims.begin_use_4
  elseif phase == -1 then
    anim_table = action.anims.begin_use_5
  elseif phase == 1 then
    anim_table = action.anims.finish_use
  elseif phase == 2 then
    anim_table = action.anims.finish_use_2
  elseif phase == 3 then
    anim_table = action.anims.finish_use_3
  elseif phase == 4 then
    anim_table = action.anims.finish_use_4
  elseif phase == 5 then
    anim_table = action.anims.finish_use_5
  end
  local is_list = false
  local anim = anim_table[humanoid.humanoid_class]
  if not anim then
    -- Handymen have their own number of animations.
    if humanoid.humanoid_class == "Handyman" then
      --action_use_phase(action, humanoid, action_use_next_phase(action, phase))
      action_use_object_tick(humanoid)
      return
    else
      error("No animation for " .. humanoid.humanoid_class .. " using " ..
        object.object_type.id .. " facing " .. object.direction .. " phase " ..
        phase)
    end
  end

  local anim_length = 1
  if type(anim) == "table" and anim.length then
    anim_length = anim.length
  end

  if type(anim) == "table" and anim[1] ~= "morph" and #anim > 1 then
    -- If an animation list is provided rather than a single animation, then
    -- choose an animation from the list at random.
    is_list = true
    anim = anim[math.random(1, #anim)]
  end

  local flags = action.mirror_flags
  if type(anim) == "table" then
    if anim.mirror then
      -- a single animation may be (un-)mirrored, switch the mirror flag in that case
      flags = flag_toggle(flags, DrawFlags.FlipHorizontal)
    end
    if anim.object_visible then
      -- this flag may be set to make the (idle) object visible additionally to the usage animation
      object.th:makeVisible()
    else
      object.th:makeInvisible()
    end
    if anim[1] ~= "morph" then
      anim = anim[1]
    end
  else
    object.th:makeInvisible()
  end

  if object.split_anims then
    flags = flags + DrawFlags.Crop
    local anims = humanoid.world.anims
    for i = 2, #object.split_anims do
      local th = object.split_anims[i]
      th:setAnimation(anims, anim, flags)
    end
  end

  if type(anim) == "table" and anim[1] == "morph" then
    -- If a table with entries {"morph", A, B} is given rather than a single
    -- animation, then display A first, then morph to B.
    humanoid:setAnimation(anim[2], flags)
    local morph_target = TH.animation()
    local morph_flags = flags
    if anim.mirror_morph then
      morph_flags = flag_toggle(morph_flags, DrawFlags.FlipHorizontal)
    end
    morph_target:setAnimation(humanoid.world.anims, anim[3], morph_flags)
    for layer, id in pairs(humanoid.layers) do
      morph_target:setLayer(layer, id)
    end
    if anim.layers then
      for layer, id in pairs(humanoid[anim.layers]) do
        morph_target:setLayer(layer, id)
      end
      action.change_layers = humanoid[anim.layers]
    end
    humanoid.th:setMorph(morph_target, anim_length)
    anim = anim[3]
  else
    humanoid:setAnimation(anim, flags)
  end

  local offset = object.object_type.orientations
  if offset then
    local tx, ty
    offset = offset[object.direction]
    if offset.use_animate_from_use_position then
      tx, ty = action.old_tile_x, action.old_tile_y
    else
      tx, ty = object:getRenderAttachTile()
    end
    if humanoid.humanoid_class == "Handyman" and
      offset.added_handyman_animate_offset_while_in_use then
      tx = tx + offset.added_handyman_animate_offset_while_in_use[1]
      ty = ty + offset.added_handyman_animate_offset_while_in_use[2]
    end
    local added_offset = nil
    if offset.added_animation_offset_while_in_use then
      added_offset = offset.added_animation_offset_while_in_use
    end
    offset = offset.animation_offset
    if added_offset then
      humanoid:setTilePositionSpeed(tx, ty, offset[1] + added_offset[1],
        offset[2] + added_offset[2])
    else
      humanoid:setTilePositionSpeed(tx, ty, offset[1], offset[2])
    end
  else
    humanoid:setTilePositionSpeed(object.tile_x, object.tile_y, 0, 0)
  end
  humanoid.user_of = object
  local length = anim_length * humanoid.world:getAnimLength(anim)
  if action.min_length and phase == 0 and action.min_length > length then
    -- A certain length is desired.
    -- Even it out so that an integer number of animation sequences are done.
    length = action.min_length + action.min_length % length
  end
  if phase == 0 and (not is_list) and length == 1 and action.prolonged_usage
  and action.on_interrupt and not action.loop_callback then
    -- a timer would be redundant, so do not set one
  else
    humanoid:setTimer(length, action_use_object_tick)
  end
end

local function init_split_anims(object, humanoid)
  if object.split_anims then
    for i = 2, #object.split_anims do
      local th = object.split_anims[i]
      th:setLayersFrom(humanoid.th)
      th:setHitTestResult(humanoid)
    end
    object.ticks = true
  end
end

local function finish_using(object, humanoid)
  object:removeUser(humanoid)
  humanoid.user_of = nil
  if object.split_anims then
    local anims, anim, frame, flags = humanoid.world.anims,
      object.th:getAnimation(), object.th:getFrame(), object.th:getFlag()
    for i = 2, #object.split_anims do
      local th = object.split_anims[i]
      th:setLayersFrom(object.th)
      th:setHitTestResult(object)
      th:setAnimation(anims, anim, flags)
      th:setFrame(frame)
    end
    object.ticks = object.object_type.ticks
  end
end

action_use_object_tick = permanent"action_use_object_tick"( function(humanoid)
  local action = humanoid.action_queue[1]
  local object = action.object
  local phase = action.phase
  local oldphase = phase
  if oldphase == -6 then
    object:setUser(humanoid)
    humanoid.user_of = object
    init_split_anims(object, humanoid)
    if action.after_walk_in then
      action:after_walk_in()
    end
  end
  if phase ~= 0 or not action.prolonged_usage or not action.on_interrupt then
    phase = action_use_next_phase(action, phase)
  elseif action.loop_callback then
    action:loop_callback()
  end
  if action.change_layers then
    for layer, id in pairs(action.change_layers) do
      humanoid:setLayer(layer, id)
    end
    action.change_layers = nil
  end
  if oldphase <= 5 and phase > 5 then
    finish_using(object, humanoid)
  end
  if phase == 100 then
    humanoid:setTilePositionSpeed(action.old_tile_x, action.old_tile_y)

    -- Check if the room is about to be destroyed
    local room_destroyed = false
    if object.strength then
      if humanoid.humanoid_class ~= "Handyman"  then
        room_destroyed = object:machineUsed(humanoid:getRoom())
      end
    elseif object:getDynamicInfo() and not object.master then
      -- Don't update if it is a slave object.
      object:updateDynamicInfo()
    end
    if not room_destroyed then
      -- Note that after_use is not called if the room has been destroyed!
      -- In that case both the patient, staff member(s) and
      -- the actual object are already dead.
      if action.after_use then
        action.after_use()
      end

      if action.destroy_user_after_use then
        humanoid:despawn()
        humanoid.world:destroyEntity(humanoid)
      else
        humanoid:finishAction(action)
      end
    end
  else
    action_use_phase(action, humanoid, phase)
  end
end)

local action_use_object_interrupt = permanent"action_use_object_interrupt"( function(action, humanoid, high_priority)
  if high_priority then
    local object = action.object
    if humanoid.user_of then
      finish_using(object, humanoid)
    elseif object:isReservedFor(humanoid) then
      object:removeReservedUser(humanoid)
    end
    humanoid:setTimer(nil)
    humanoid:setTilePositionSpeed(action.old_tile_x, action.old_tile_y)
    humanoid:finishAction()
  elseif not humanoid.timer_function then
    humanoid:setTimer(1, action_use_object_tick)
  end
  -- Only patients can be vaccination candidates so no need to check
  if humanoid.vaccination_candidate then
    humanoid:removeVaccinationCandidateStatus()
  end
end)

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
  -- The handyman has his own place to be in
  if spec.finish_use_position and humanoid.humanoid_class ~= "Handyman" then
    action.old_tile_x = object.tile_x + spec.finish_use_position[1]
    action.old_tile_y = object.tile_y + spec.finish_use_position[2]
  end
  if spec.walk_in_tile then
    action.new_tile_x = spec.walk_in_tile[1] + object.tile_x
    action.new_tile_y = spec.walk_in_tile[2] + object.tile_y
  else
    action.new_tile_x = object.tile_x
    action.new_tile_y = object.tile_y
  end
  local anims = object.object_type.usage_animations[orient]
  action.anims = anims
  action.mirror_flags = flags
  if action.prolonged_usage == nil and anims.begin_use and
    anims.in_use and anims.finish_use then
    action.prolonged_usage = true
  end
  if object.object_type.walk_in_to_use then
    action.do_walk = true
  else
    object:setUser(humanoid)
    humanoid.user_of = object
    init_split_anims(object, humanoid)
  end
  if action.watering_plant then
    -- Tell the plant to start restoring itself
    object:restoreToFullHealth()
  end
  action_use_phase(action, humanoid, action_use_next_phase(action, -100))
end

return action_use_object_start
