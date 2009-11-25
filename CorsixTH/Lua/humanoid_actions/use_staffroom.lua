--[[ Copyright (c) 2009 Manuel Wolf

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

-- decide on the next source of relaxation the humanoid will go to
-- returns target_obj, ox, oy, new_type
-- the function will always return a value for new_type, depending on what type was chosen,
-- but target_obj, ox and oy will be nil, if no object of the chosen target was found
local function decide_next_target(action, humanoid)
  assert(action.name == "use_staffroom", "decide_next_target only works with the use_staffroom action")
  local cur_type = action.target_type
  assert(class.is(humanoid, Staff), "decide_next_target called for non-staff humanoid")
  local h_class = humanoid.humanoid_class
  
  local chance = math.random(1, 10)
  
  -- take sofa as default
  local new_type = "sofa"

  -- With a chance of 20%, look for a pool table (Doctor and Handyman only)
  -- Don't choose pool table two times in a row though
  if (h_class == "Doctor" or h_class == "Handyman") and cur_type ~= "pool_table" and chance <= 2 then
    new_type = "pool_table"
  end

  -- With a chance of 20%, look for a video game (Doctor and Nurse only)
  -- Don't choose video game two times in a row though
  if (h_class == "Doctor" or h_class == "Nurse") and cur_type ~= "video_game" and 2 < chance and chance <= 4 then
    new_type = "video_game"
  end
  
  -- Take the a near object but not always the nearest (decreasing probability over distance) for some variation.
  local obj, ox, oy = humanoid.world:findFreeObjectNearToUse(humanoid, new_type, nil, "near")
  return obj, ox, oy, new_type
end

-- randomly generate the use time for a given source of relaxation
local function generate_use_time(type)
  if type == "sofa" then
    return math.random(20, 40)
  elseif type == "pool_table" then
    return math.random(2, 5)
  elseif type == "video_game" then
    return math.random(2, 15)
  end
end

-- table of how much relaxation an object gives per tick
local relaxation = {
  sofa = 0.001,
  pool_table = 0.05,
  video_game = 0.04,
}

-- main function of the staffroom action
local function use_staffroom_action_start(action, humanoid)
  assert(class.is(humanoid, Staff), "use_staffroom action called for non-staff humanoid")
  assert(humanoid.humanoid_class ~= "Receptionist", "use_staffroom action called for receptionist")

  -- For initial call of this function we have to decide a new target now
  -- Else, there should be already a new target defined
  if not action.next_target_type then
    action.target_obj, action.ox, action.oy, action.target_type = decide_next_target(action, humanoid)
    if action.target_obj then
      action.target_obj.reserved_for = humanoid
    end
  else
    action.target_obj, action.ox, action.oy, action.target_type = action.next_target_obj, action.next_ox, action.next_oy, action.next_target_type
    action.next_target_obj, action.next_ox, action.next_oy, action.next_target_type = nil
  end
  
  -- If no target was found, then walk around for a bit and try again later
  if not action.target_obj then
    humanoid:queueAction({name = "meander", count = 2}, 0)
    return
  end
  
  -- Otherwise, walk to and use the object:
  -- Note: force prolonged_usage, because video_game wouldn't get it by default (because it has no begin and end animation)
  local object_action
  local obj_use_time = generate_use_time(action.target_type)
  object_action = {
    name = "use_object",
    prolonged_usage = true,
    object = action.target_obj,
    loop_callback = function()
      humanoid.fatigue = humanoid.fatigue - relaxation[action.target_type]
      if humanoid.fatigue < 0 then
        humanoid.fatigue = 0
      end
      obj_use_time = obj_use_time - 1
      if obj_use_time == 0 then
        if humanoid.fatigue == 0 then
          humanoid:setNextAction(humanoid:getRoom():createLeaveAction())
          humanoid:queueAction({name = "meander"})
        else
          -- Decide on the next target. If it happens to be of the same type as the current, just continue using the current.
          action.next_target_obj, action.next_ox, action.next_oy, action.next_target_type = decide_next_target(action, humanoid)
          if action.next_target_type == action.target_type then
            obj_use_time = generate_use_time(action.target_type)
          else
            if action.next_target_obj then
              action.next_target_obj.reserved_for = humanoid
            end
            object_action.prolonged_usage = false
          end
        end
      end
    end
  }
  humanoid:queueAction({name = "walk", x = action.ox, y = action.oy}, 0)
  humanoid:queueAction(object_action, 1)
end

return use_staffroom_action_start
