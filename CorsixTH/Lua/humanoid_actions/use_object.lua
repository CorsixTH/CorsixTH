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

local TH = require("TH")


class "UseObjectAction" (HumanoidAction)

---@type UseObjectAction
local UseObjectAction = _G["UseObjectAction"]

--! Construct a 'use object' action.
--!param object (Object) Object to use.
function UseObjectAction:UseObjectAction(object)
  assert(class.is(object, Object), "Invalid value for parameter 'object'")

  self:HumanoidAction("use_object")
  self.object = object
  self.watering_plant = false -- Whether the action is watering the plant.
  self.prolonged_usage = nil -- If true, the usage is prolonged.
end

--! Set the 'watering plant' flag.
--!return (action) self, for daisy chaining.
function UseObjectAction:enableWateringPlant()
  self.watering_plant = true
  return self
end

--! Set prolonged usage of the object.
--!param prolonged (bool or nil) If set, enable prolonged usage of the object.
--!return (action) self, for daisy-chaining.
function UseObjectAction:setProlongedUsage(prolonged)
  assert(prolonged == nil or type(prolonged) == "boolean",
      "Invalid value for parameter 'prolonged'")

  self.prolonged_usage = prolonged
  return self
end

local orient_mirror = {
  north = "west",
  west = "north",
  east = "south",
  south = "east",
}

--! Find the next phase with an animation to show.
--!param action (UseObjectAction) The use_object action.
--!param phase The previous displayed phase or -100.
--!return The phase to show after the previous phase. Is 100 if there are no
--  phases with animations anymore.
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

--! Compute and set the position of the animated humanoid from the footprint.
--  The humanoid does not move.
--!param action (UseObjectAction) Action being performed.
--!param humanoid (Humanoid) Person using the object.
local function setHumanoidTileSpeed(action, humanoid)
  local object = action.object
  local obj_orient = object.object_type.orientations[object.direction]

  -- Decide the animation tile.
  local tx, ty
  if obj_orient.use_animate_from_use_position then
    tx, ty = action.old_tile_x, action.old_tile_y
  else
    tx, ty = object:getRenderAttachTile()
  end
  if humanoid.humanoid_class == "Handyman" and
      obj_orient.added_handyman_animate_offset_while_in_use then
    tx = tx + obj_orient.added_handyman_animate_offset_while_in_use[1]
    ty = ty + obj_orient.added_handyman_animate_offset_while_in_use[2]
  end

  -- Decide pixel offset.
  local anim_offset = obj_orient.animation_offset
  local added_offset = obj_orient.added_animation_offset_while_in_use or {0, 0}
  local px = anim_offset[1] + added_offset[1]
  local py = anim_offset[2] + added_offset[2]

  humanoid:setTilePositionSpeed(tx, ty, px, py)
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

  -- Get the animation table for the current phase.
  local anim_table = action.anims.in_use -- phase 0
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

  -- Animation can be shown 'length' times rather than just once.
  local anim_length = 1
  if type(anim) == "table" and anim.length then
    anim_length = anim.length
  end

  local is_list = false
  if type(anim) == "table" and anim[1] ~= "morph" and #anim > 1 then
    -- If an animation list is provided rather than a single animation, then
    -- choose an animation from the list at random.
    is_list = true
    anim = anim[math.random(1, #anim)]
  end

  -- Handle various flags:
  -- "mirror" to mirror a single animation (possibly for the second time).
  -- "object_visible" whether the used object should be visible as well.
  --     Default is to not show it.
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

    -- If not morphing, grab the animation to show.
    if anim[1] ~= "morph" then
      anim = anim[1]
    end
  else
    object.th:makeInvisible()
  end

  -- For split animations, add a Crop flag to the selected animations.
  if object.split_anims then
    flags = flags + DrawFlags.Crop
    local anims = humanoid.world.anims
    for i = 2, #object.split_anims do
      local th = object.split_anims[i]
      th:setAnimation(anims, anim, flags)
    end
  end

  -- Morph from one animation to another.
  if type(anim) == "table" and anim[1] == "morph" then
    -- If a table with entries {"morph", A, B} is given rather than a single
    -- animation, then display A first, then morph to B.
    humanoid:setAnimation(anim[2], flags) -- A animation.
    local morph_target = TH.animation()
    local morph_flags = flags
    if anim.mirror_morph then
      morph_flags = flag_toggle(morph_flags, DrawFlags.FlipHorizontal)
    end
    morph_target:setAnimation(humanoid.world.anims, anim[3], morph_flags) -- B animation.
    for layer, id in pairs(humanoid.layers) do
      morph_target:setLayer(layer, id)
    end
    if anim.layers then
      for layer, id in pairs(humanoid[anim.layers]) do
        morph_target:setLayer(layer, id)
      end
      action.change_layers = humanoid[anim.layers] -- Rescue the layers for use afterwards.
    end
    humanoid.th:setMorph(morph_target, anim_length)
    anim = anim[3]
  else
    humanoid:setAnimation(anim, flags)
  end

  -- Set position (and speed) of the humanoid, and make it the user of the object.
  setHumanoidTileSpeed(action, humanoid)
  humanoid.user_of = object

  local frame_count = humanoid.world:getAnimLength(anim)
  local action_anim_count = 1 -- Number of times to show 'in_use' animation for the action.
  if action.min_length and phase == 0 then
    -- 'action.min_length' is a frame count, convert to number of complete animations.
    action_anim_count = math.floor((action.min_length + frame_count - 1) / frame_count)
  end
  -- Take the smallest number of of animations that satisfies both the object and
  -- the action minimum count.
  local length = math.max(action_anim_count, anim_length) * frame_count

  -- A timer would be redundant in certain situations, so check it is needed
  if phase ~= 0 or is_list or length ~= 1 or not action.prolonged_usage or
      not action.on_interrupt or action.loop_callback then
    humanoid:setTimer(length, action_use_object_tick)
  end
end

--! Setup split animations by copying the humanoid layers and hit-test
--  to the other animations.
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

--! Cleanup function after usage.
local function finish_using(object, humanoid)
  object:removeUser(humanoid) -- Disconnect the humanoid from the object.
  humanoid.user_of = nil

  -- Restore the layers and hit-test of the object, and set all animations
  -- to the same frame.
  if object.split_anims then
    local anims = humanoid.world.anims
    local anim = object.th:getAnimation()
    local frame = object.th:getFrame()
    local flags = object.th:getFlag()

    for i = 2, #object.split_anims do
      local th = object.split_anims[i]
      th:setLayersFrom(object.th)
      th:setHitTestResult(object)
      th:setAnimation(anims, anim, flags)
      th:setFrame(frame)
    end

    -- Restore ticks to default of the object.
    object.ticks = object.object_type.ticks
  end
end

--! Callback after an animation.
action_use_object_tick = permanent"action_use_object_tick"( function(humanoid)
  local action = humanoid:getCurrentAction()
  local object = action.object
  local phase = action.phase
  local oldphase = phase

  -- walk_in phase done.
  if oldphase == -6 then
    object:setUser(humanoid)
    humanoid.user_of = object
    init_split_anims(object, humanoid)
    if action.after_walk_in then
      action:after_walk_in()
    end
  end

  if phase ~= 0 or not action.prolonged_usage or not action.on_interrupt then
    -- For the 'begin_use*', the 'finish_use*', and simple 'in_use' animations,
    -- find to the next phase to animate.
    phase = action_use_next_phase(action, phase)
  elseif action.loop_callback then
    action:loop_callback()
  end

  -- Apply the layers from before the morphed animation if available.
  if action.change_layers then
    for layer, id in pairs(action.change_layers) do
      humanoid:setLayer(layer, id)
    end
    action.change_layers = nil
  end

  -- Except for possibly walking away from the object, all usage animations are done.
  -- Perform cleanup.
  if oldphase <= 5 and phase > 5 then
    finish_using(object, humanoid)
  end

  if phase == 100 then
    -- Any walking away from the object is done too.
    humanoid:setTilePositionSpeed(action.old_tile_x, action.old_tile_y)

    -- Check if the room is about to be destroyed
    local room_destroyed = false
    local object_is_machine = object.strength
    if object_is_machine then
      if humanoid.humanoid_class ~= "Handyman"  then
        room_destroyed = object:machineUsed(humanoid:getRoom())
      end
    elseif object:getDynamicInfo() and not object.master then
      -- Don't update if it is a slave object.
      object:incrementUsedCount()
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
    -- Perform the next phase.
    action_use_phase(action, humanoid, phase)
  end
end)

local action_use_object_interrupt = permanent"action_use_object_interrupt"( function(action, humanoid, high_priority)
  if high_priority then
    local object = action.object
    if humanoid.user_of then
      finish_using(object, humanoid) -- Cleanup after usage.
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
    flags = flags + DrawFlags.FlipHorizontal
  end
  local spec = object.object_type.orientations[object.direction]
  -- early_list_while_in_use (if defined) will take precedence over early_list
  if spec.early_list_while_in_use or (spec.early_list_while_in_use == nil and spec.early_list) then
    flags = flags + DrawFlags.EarlyList
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

  -- If walking in and walking out must be done, delay assigning the object to the humanoid.
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
