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

--! Have a `Humanoid` hide behind a screen and change clothes.
class "UseScreenAction" {} (Action)

--!param ... Arguments for the base class constructor.
function UseScreenAction:UseScreenAction(...)
  self:Action(...)
end

local finish = permanent"action_use_screen_finish"( function(humanoid)
  humanoid:finishAction()
end)

local patient_clothes_state = permanent"action_use_screen_patient_clothes_state"( function(humanoid)
  humanoid.user_of:setAnimation(1204)
  humanoid.user_of:setLayer(1, humanoid.layers[1])
  return finish(humanoid)
end)

local normal_state = permanent"action_use_screen_normal_state"( function(humanoid)
  humanoid.user_of:setAnimation(1022)
  humanoid.user_of:setLayer(1, 0)
  return finish(humanoid)
end)

local surgical_state = permanent"action_use_screen_surgical_state"( function(humanoid)
  local screen = humanoid.user_of
  if screen.num_green_outfits > 0 then
    if screen.num_white_outfits > 0 then
      screen:setAnimation(2776)
    else
      screen:setAnimation(2772)
    end
  else
    screen:setAnimation(2774)
  end
  return finish(humanoid)
end)

function UseScreenAction:canRemoveFromQueue(is_high_priority)
  local can = true
  if self.must_happen then
    can = false
  elseif self.is_active then
    can = is_high_priority
  end
  return can and Action.canRemoveFromQueue(self, is_high_priority)
end

function UseScreenAction:truncate(is_high_priority)
  self.should_truncate = is_high_priority
end

function UseScreenAction:onFinish()
  if self.false_start then
    self.false_start = nil
  else
    local humanoid = self.humanoid
    local screen = humanoid.user_of
    humanoid.user_of = nil
    screen:setUser(nil)
    humanoid:setTile(screen:getUsageTile())
    local after_use = self.after_use
    if after_use then
      self.after_use = nil
      after_use()
    end
    self.must_happen = false
  end
  
  Action.onFinish(self)
end

function UseScreenAction:setUndoAction(action)
  self.undo_action = action
  return action
end

function UseScreenAction:makeUndoAction()
  return self:setUndoAction(UseScreenAction{object = self.object})
end

function UseScreenAction:onStart()
  Action.onStart(self)
  
  local action = self
  local humanoid = self.humanoid
  local screen = action.object
  local class = humanoid.humanoid_class
  local anim, when_done
  local is_surgical = not not screen.num_green_outfits
  local x, y = screen:getUsageTile()
  
  if not self.should_truncate and (x ~= humanoid.tile_x or y ~= humanoid.tile_y) then
    self.false_start = true
    humanoid:queueAction(WalkAction{
      x = x,
      y = y,
      truncate_only_on_high_priority = self.must_happen,
    }, 0)
    return
  end
  if self.undo_action then
    self.undo_action.must_happen = true
  end
  
  if class == "Elvis Patient" then
    anim, when_done = 946, finish
    humanoid:setType "Standard Male Patient"
    humanoid:setLayer(0, 2)
    humanoid:setLayer(1, math.random(0, 3) * 2)
    humanoid:setLayer(2, 2)
  elseif class == "Stripped Male Patient" then
    humanoid:setType "Standard Male Patient"
    anim, when_done = 1052, normal_state
  elseif class == "Stripped Female Patient" then
    humanoid:setType "Standard Female Patient"
    anim, when_done = 2844, normal_state
  elseif class == "Gowned Male Patient" then
    humanoid:setType "Standard Male Patient"
    anim, when_done = 4768, finish
  elseif class == "Gowned Female Patient" then
    humanoid:setType "Standard Female Patient"
    anim, when_done = 4770, finish
  elseif class == "Standard Male Patient" then
    if is_surgical then
      humanoid:setType "Gowned Male Patient"
      anim, when_done = 4760, finish
    else
      humanoid:setType "Stripped Male Patient"
      anim, when_done = 1048, patient_clothes_state
    end
  elseif class == "Standard Female Patient" then
    if is_surgical then
      humanoid:setType "Gowned Female Patient"
      anim, when_done = 4762, finish
    else
      humanoid:setType "Stripped Female Patient"
      anim, when_done = 2848, patient_clothes_state
    end
  elseif class == "Doctor" then
    humanoid:setType "Surgeon"
    when_done = surgical_state
    if screen.num_white_outfits > 0 then
      if screen.num_green_outfits > 1 then
        anim = 2780
      else
        anim = 2784
      end
    else
      anim = 2782
    end
    screen.num_green_outfits = screen.num_green_outfits - 1
    screen.num_white_outfits = screen.num_white_outfits + 1
  elseif class == "Surgeon" then
    humanoid:setType "Doctor"
    when_done = surgical_state
    if screen.num_green_outfits > 0 then
      if screen.num_white_outfits > 1 then
        anim = 2796
      else
        anim = 2790
      end
    else
      anim = 2792
    end
    screen.num_green_outfits = screen.num_green_outfits + 1
    screen.num_white_outfits = screen.num_white_outfits - 1
  else
    error(class .. " trying to use screen")
  end
  
  humanoid:setAnimation(anim)
  local mood_info = humanoid.mood_info
  humanoid.mood_info = nil -- Do not move mood_info
  humanoid:setTile(screen:getRenderAttachTile())
  local offset = screen.object_type.orientations[screen.direction].animation_offset
  humanoid:setPosition(offset[1], offset[2])
  humanoid.mood_info = mood_info
  humanoid:setSpeed(0, 0)
  humanoid:setTimer(humanoid.world:getAnimLength(anim), when_done)
  
  screen:setUser(humanoid)
  humanoid.user_of = screen
  
  if self.should_truncate then
    humanoid:callTimer()
  end
end
