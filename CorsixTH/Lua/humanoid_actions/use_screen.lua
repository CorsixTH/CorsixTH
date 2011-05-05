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

-- Set markers for all animations involved.
local animation_numbers = {
  946,
  --1022,
  1048,
  1052,
  --1204,
  --2772,
  --2774,
  --2776,
  2780,
  2782,
  2784,
  2790,
  2792,
  2794,
  2796,
  2844,
  2848,
  4760,
  4762,
  4768,
  4770,
}
TheApp.animation_manager:setMarker(animation_numbers, {-1.05, -0.05})

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

local function action_use_screen_start(action, humanoid)
  local screen = action.object
  local class = humanoid.humanoid_class
  local anim, when_done
  local is_surgical = not not screen.num_green_outfits
  local change_to = math.random(1, 3)
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
  elseif class == "Stripped Male Patient 2" then
    humanoid:setType "Standard Male Patient"
    anim, when_done = 1052, normal_state
  elseif class == "Stripped Female Patient 2" then
    humanoid:setType "Standard Female Patient"
    anim, when_done = 2844, normal_state
  elseif class == "Stripped Male Patient 3" then
    humanoid:setType "Standard Male Patient"
    anim, when_done = 1052, normal_state
  elseif class == "Stripped Female Patient 3" then
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
      if change_to == 1 then
        humanoid:setType "Stripped Male Patient"
        anim, when_done = 1048, patient_clothes_state
      elseif change_to == 2 then
        humanoid:setType "Stripped Male Patient 2"
        anim, when_done = 1048, patient_clothes_state
      else
        humanoid:setType "Stripped Male Patient 3"
        anim, when_done = 1048, patient_clothes_state      
      end
    end
  elseif class == "Standard Female Patient" then
    if is_surgical then
      humanoid:setType "Gowned Female Patient"
      anim, when_done = 4762, finish
    else
      if change_to == 1 then
        humanoid:setType "Stripped Female Patient"
        anim, when_done = 2848, patient_clothes_state
      elseif change_to == 2 then
        humanoid:setType "Stripped Female Patient 2"
        anim, when_done = 2848, patient_clothes_state
      else
        humanoid:setType "Stripped Female Patient 3"
        anim, when_done = 2848, patient_clothes_state      
      end
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
  action.must_happen = true
  
  if action.todo_interrupt == "high" then
    humanoid:setTimer(nil)
    when_done(humanoid)
  end
end

return action_use_screen_start
