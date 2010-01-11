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

local finish = permanent"action_use_screen_finish"( function(humanoid)
  local screen = humanoid.user_of
  humanoid.user_of = nil
  screen:setUser(nil)
  local offset = screen.object_type.orientations[screen.direction].use_position
  humanoid:setTile(screen.tile_x + offset[1], screen.tile_y + offset[2])
  local after_use = humanoid.action_queue[1].after_use
  if after_use then
    after_use()
  end
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

local function action_use_screen_start(action, humanoid)
  local screen = action.object
  local class = humanoid.humanoid_class
  local anim, when_done
  local is_surgical -- TODO
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
    anim, when_done = 4768, gowned_male__standard_male -- TODO
  elseif class == "Gowned Female Patient" then
    anim, when_done = 4770, gowned_female__standard_female -- TODO
  elseif class == "Standard Male Patient" then
    if is_surgical then
      anim, when_done = 4760, standard_male__gowned_male -- TODO
    else
      humanoid:setType "Stripped Male Patient"
      anim, when_done = 1048, patient_clothes_state
    end
  elseif class == "Standard Female Patient" then
    if is_surgical then
      anim, when_done = 4762, standard_female__gowned_female -- TODO
    else
      humanoid:setType "Stripped Female Patient"
      anim, when_done = 2848, patient_clothes_state
    end
  elseif class == "Doctor" then
    -- TODO (2778, 2780, 2782, 2784)
  elseif class == "Surgeon" then
    -- TODO (2790, 2792, 2794, 2796)
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
  action.must_happen = true
end

return action_use_screen_start
