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

local function action_multi_use_next_phase(action, phase)
  phase = phase + 1
  if phase < -5 then
    phase = -5
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
  if phase > 5 then
    phase = 100
  end
  return phase
end

local action_multi_use_object_tick

local function action_multi_use_phase(action, humanoid, phase)
  local object = action.object
  humanoid.user_of = nil -- Temporary to avoid tile change warning
  action.phase = phase
  local anim_name = "in_use"
  if phase == -5 then
    anim_name = "begin_use"
  elseif phase == -4 then
    anim_name = "begin_use_2"
  elseif phase == -3 then
    anim_name = "begin_use_3"
  elseif phase == -2 then
    anim_name = "begin_use_4"
  elseif phase == -1 then
    anim_name = "begin_use_5"
  elseif phase == 1 then
    anim_name = "finish_use"
  elseif phase == 2 then
    anim_name = "finish_use_2"
  elseif phase == 3 then
    anim_name = "finish_use_3"
  elseif phase == 4 then
    anim_name = "finish_use_4"
  elseif phase == 5 then
    anim_name = "finish_use_5"
  end
  local anim = action.anims[anim_name]
  if type(anim) == "table" then
    -- If an animation list is provided rather than a single animation, then
    -- choose an animation from the list at random, or according to the previous
    -- phase. Look at general diagnosis for usage example.
    if action.random_anim then
      anim = anim[action.random_anim]
    else
      action.random_anim = math.random(1, #anim)
      anim = anim[action.random_anim]
    end
  end
  if object.split_anims then
    local anims = humanoid.world.anims
    for i = 2, #object.split_anims do
      local th = object.split_anims[i]
      th:setAnimation(anims, anim, action.mirror_flags)
    end
  end
  humanoid:setAnimation(anim, action.mirror_flags)
  
  local offset = object.object_type.orientations
  if offset then
    local tx, ty
    offset = offset[object.direction]
    if offset.use_animate_from_use_position then
      tx, ty = object.tile_x + offset.use_position[1], object.tile_y + offset.use_position[2]
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
  local secondary_anim = action.anims.secondary and action.anims.secondary[anim_name]
  if action.secondary_anim then
    secondary_anim = action.secondary_anim
    action.secondary_anim = nil
  end
  local use_with = action.use_with
  if secondary_anim then
    if type(secondary_anim) == "table" and secondary_anim[1] == "morph" then
      use_with:setAnimation(secondary_anim[2], action.mirror_flags)
      local morph_target = TH.animation()
      morph_target:setAnimation(use_with.world.anims, secondary_anim[3], action.mirror_flags)
      for layer, id in pairs(use_with.layers) do
        morph_target:setLayer(layer, id)
      end
      if secondary_anim.layers then
        for layer, id in pairs(use_with[secondary_anim.layers]) do
          morph_target:setLayer(layer, id)
        end
        action.change_secondary_layers = use_with[secondary_anim.layers]
      end
      use_with.th:setMorph(morph_target)
      secondary_anim = secondary_anim[3]
    else
      use_with:setAnimation(secondary_anim, action.mirror_flags)
    end
    use_with.th:makeVisible()
    local secondary_length = use_with.world:getAnimLength(secondary_anim)
    if secondary_length > length then
      length = secondary_length
    end
  else
    local span = action.invisible_phase_span
    if span then
      if span[1] <= phase and span[2] >= phase then
        use_with.th:makeInvisible()
      else
        use_with.th:makeVisible()
      end
    else
      use_with.th:makeInvisible()
    end
  end
  humanoid:setTimer(length, action_multi_use_object_tick)
end

local function copy_layers(dest, src)
  if class.is(dest, Staff) then
    dest:setLayer(0, src.layers[0])
    dest:setLayer(1, src.layers[1])
    dest:setLayer(2, src.layers[2])
    dest:setLayer(3, src.layers[3])
    dest:setLayer(4, src.layers[4])
  elseif class.is(src, Staff) then
    dest:setLayer(5, src.layers[5])
  end
end

action_multi_use_object_tick = permanent"action_multi_use_object_tick"( function(humanoid)
  local action = humanoid.action_queue[1]
  local use_with = action.use_with
  local object = action.object
  local phase = action.phase
  local oldphase = phase
  if phase ~= 0 or not action.prolonged_usage then
    phase = action_multi_use_next_phase(action, phase)
  elseif action.loop_callback then
    action:loop_callback()
  end
  if action.change_secondary_layers then
    for layer, id in pairs(action.change_secondary_layers) do
      use_with:setLayer(layer, id)
    end
    action.change_secondary_layers = nil
    copy_layers(humanoid, use_with)
  end
  if oldphase <= 5 and phase > 5 then
    object:setUser(nil)
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
  if phase == 0 then
    -- Already now move the secondary user to his final position and orientation.
    -- This is needed if some end phases have the secondary user visible (e.g. jelly moulder)
    local spec = object.object_type.orientations[object.direction]
    local pos = spec.finish_use_position_secondary or spec.use_position_secondary
    local direction = spec.finish_use_orientation_secondary
    use_with:setTilePositionSpeed(object.tile_x + pos[1], object.tile_y + pos[2])
    if direction then
      local anims = use_with.walk_anims
      local anim  = (direction == "north" or direction == "west") and anims.idle_north or anims.idle_east
      local flags = (direction == "north" or direction == "east") and 0 or 1
      use_with:setAnimation(anim, flags)
    end
  end
  if phase == 100 then
    if action.layer3 then
      humanoid:setLayer(3, action.old_layer3_humanoid)
      use_with:setLayer(3, action.old_layer3_use_with)
    end
    
    use_with.th:makeVisible()
    use_with.action_queue[1].on_interrupt = action.idle_interrupt
    use_with.action_queue[1].must_happen = action.idle_must_happen
    local spec = object.object_type.orientations[object.direction]
    local pos = spec.finish_use_position or spec.use_position
    humanoid:setTilePositionSpeed(object.tile_x + pos[1], object.tile_y + pos[2])
    -- Check if the room is about to be destroyed
    local room_destroyed = false
    if object.strength then
      room_destroyed = object:machineUsed(humanoid:getRoom())
    end
    if not room_destroyed then
    -- Now call the after_use function if appropriate
      if action.after_use then
        action.after_use()
      end
      humanoid:finishAction(action)
    end
  else
    action_multi_use_phase(action, humanoid, phase)
  end
end)

local action_multi_use_object_interrupt = permanent"action_multi_use_object_interrupt"( function(action, humanoid)
  if not action.loop_callback then
    action.prolonged_usage = false
  end
end)

local function action_multi_use_object_start(action, humanoid)
  local use_with = action.use_with
  if action.must_happen then
    -- Setting must_happen is slightly dangerous (though required in some
    -- situations), as the multi-usage cannot be sure to happen until the
    -- secondary user is present (at which point, must_happen is always set).
    if action.todo_interrupt and not action.no_truncate then
      humanoid:finishAction(action)
      return
    end
  end
  if use_with.action_queue[1].name ~= "idle" then
    humanoid:queueAction({name = "idle", count = 2}, 0)
    return
  else
    action.idle_interrupt = use_with.action_queue[1].on_interrupt
    action.idle_must_happen = use_with.action_queue[1].must_happen
    use_with.action_queue[1].on_interrupt = nil
    use_with.action_queue[1].must_happen = true
  end
  action.must_happen = true
  if action.prolonged_usage then
    action.on_interrupt = action_multi_use_object_interrupt
    use_with.action_queue[1].on_interrupt = --[[persistable:action_multi_use_object_use_with_interrupt]] function()
      if action.on_interrupt then
        action:on_interrupt()
        action.on_interrupt = nil
      end
    end
  end
  local object = action.object
  local orient = object.direction
  local flags = 0
  local anim_set = humanoid.humanoid_class .. " - " .. use_with.humanoid_class
  if not object.object_type.multi_usage_animations[anim_set][orient] then
    orient = orient_mirror[orient]
    flags = flags + 1
  end
  if object.split_anims then
    flags = flags + DrawFlags.Crop
  end
  local spec = object.object_type.orientations[object.direction]
  -- early_list_while_in_use (if defined) will take precedence over early_list
  if spec.early_list_while_in_use or (spec.early_list_while_in_use == nil and spec.early_list) then
    flags = flags + 1024
  end
  local anims = object.object_type.multi_usage_animations[anim_set][orient]
  action.anims = anims
  action.mirror_flags = flags
  
  object:setUser(humanoid)
  humanoid.user_of = object
  copy_layers(humanoid, use_with)
  if action.layer3 then
    action.old_layer3_humanoid = humanoid.layers[3]
    action.old_layer3_use_with = use_with.layers[3]
    humanoid:setLayer(3, action.layer3)
    use_with:setLayer(3, action.layer3)
  end
  if object.split_anims then
    for i = 2, #object.split_anims do
      local th = object.split_anims[i]
      th:setLayersFrom(humanoid.th)
      th:setHitTestResult(humanoid)
    end
    object.ticks = true
  end
  
  action_multi_use_phase(action, humanoid, action_multi_use_next_phase(action, -100))
end

return action_multi_use_object_start
