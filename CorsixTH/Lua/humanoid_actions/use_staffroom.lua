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
-- OR returns nil to indicate that there are no suitable relaxation objects
local function decide_next_target(action, humanoid)
  assert(action.name == "use_staffroom", "decide_next_target only works with the use_staffroom action")
  local cur_type = action.target_type
  assert(class.is(humanoid, Staff), "decide_next_target called for non-staff humanoid")
  local h_class = humanoid.humanoid_class
  
  -- take sofa as default
  local new_type = "sofa"
  
  -- With a chance of 1 in 5, look for a pool table (Doctor and Handyman only)
  if (h_class == "Doctor" or h_class == "Handyman") and math.random(1, 5) == 1 then
    new_type = "pool_table"
  end

  -- With a chance of 1 in 5, look for a video game (Doctor and Nurse only)
  if (h_class == "Doctor" or h_class == "Nurse") and math.random(1, 5) == 1 then
    new_type = "video_game"
  end
  
  -- Take the a near object but not always the nearest (decreasing probability over distance) for some variation.
  -- Also avoid re-using the previous object.
  local obj, ox, oy = humanoid.world:findFreeObjectNearToUse(humanoid, new_type, nil, "near", action.target_obj)
  if not obj then
    return
  end
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

-- main function of the staffroom action
local function use_staffroom_action_start(action, humanoid)
  assert(class.is(humanoid, Staff), "use_staffroom action called for non-staff humanoid")
  assert(humanoid.humanoid_class ~= "Receptionist", "use_staffroom action called for receptionist")

  -- For initial call of this function or (TODO) when the target object
  -- happens to be in use on arrival, we have to decide a new target now
  action.target_obj, action.ox, action.oy, action.target_type = decide_next_target(action, humanoid)
  
  -- If no target was found, then walk around for a bit and try again later
  if not action.target_obj then
    humanoid:queueAction({name = "meander", count = 2}, 0)
    return
  end
  
  -- Otherwise, walk to and use the object:
  -- Note: force prolonged_usage, because video_game wouldn't get it by default (because it has no begin and end animation)
  -- Then unset prolonged_usage after a certain amount of time has elapsed.
  local object_action
  local obj_use_time = generate_use_time(action.target_type)
  object_action = {
    name = "use_object",
    prolonged_usage = true,
    object = action.target_obj,
    loop_callback = function()
      obj_use_time = obj_use_time - 1
      object_action.prolonged_usage = obj_use_time > 0
    end
  }
  humanoid:queueAction({name = "walk", x = action.ox, y = action.oy}, 0)
  humanoid:queueAction(object_action, 1)
end

return use_staffroom_action_start
