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
-- where the first three can be nil, in case the current type is requested again
-- OR if no (TODO: free) object of the requested type was found
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
  
  
  if new_type == cur_type then
    return nil, nil, nil, new_type
  end
  
  local obj, ox, oy = humanoid.world:findObjectNear(humanoid, new_type)
  if not obj then
    return nil, nil, nil, nil
  end
  
  return obj, ox, oy, new_type
end

-- randomly generate the use time for a given source of relaxation
local function generate_use_time(type)
  if type == "sofa" then
    return math.random(20, 30)
  elseif type == "pool_table" then
    return math.random(2, 5)
  elseif type == "video_game" then
    return math.random(2, 10)
  end
end

-- wrapper for creating a staffroom action with defined target
local function makeStaffRoomAction(obj, ox, oy, type)
  return { name = "use_staffroom",
            target_obj = obj,
            ox = ox,
            oy = oy,
            target_type = type }
end

-- main function of the staffroom action
local function use_staffroom_action_start(action, humanoid)
  assert(class.is(humanoid, Staff), "use_staffroom action called for non-staff humanoid")
  assert(humanoid.humanoid_class ~= "Receptionist", "use_staffroom action called for receptionist")

  -- For initial call of this function or (TODO) when the target object
  -- happens to be in use on arrival, we have to decide a new target now
  if not (action.target_obj and action.ox and action.oy and action.target_type) then
    -- Just to be safe, set all of them to nil first
    action.target_obj, action.ox, action.oy, action.target_type = nil, nil, nil, nil
    action.target_obj, action.ox, action.oy, action.target_type = decide_next_target(action, humanoid)
  end
  
  -- If no target was found, wait a certain amount of time and then try again
  if not action.target_obj then
    local restart_callback = function()
      humanoid:setNextAction(action)
    end
    humanoid:queueAction({name = "idle"})
    humanoid:setTimer(10, restart_callback) -- TODO: reasonable waiting time?
    humanoid:finishAction()
    return
  end
  
  -- Beyond this point, all important parameters must be known
--  print("new target: ", action.target_type, action.ox, action.oy)
  assert(action.target_obj and action.ox and action.oy and action.target_type)

  -- Callback needed for sofa and pool table
  local obj_use_time = generate_use_time(action.target_type)
  local countdown_callback = function()
    obj_use_time = obj_use_time - 1
--    print("callback of ", humanoid.profile.name, ": ", obj_use_time)
    if obj_use_time == 0 then
      local obj, ox, oy, new_type = decide_next_target(action, humanoid)
      if obj then
        humanoid:setNextAction(makeStaffRoomAction(obj, ox, oy, new_type))
      else
        obj_use_time = obj_use_time + generate_use_time(action.target_type)
      end
    end
  end
  
  -- walk to the target
  humanoid:walkTo(action.ox, action.oy)
  -- use the target
  -- Note: force prolonged_usage, because video_game wouldn't get it by default (because it has no begin and end animation)
  humanoid:queueAction({name = "use_object", prolonged_usage = true, object = action.target_obj, loop_callback = countdown_callback})
  
  -- to be safe, add a staffroom action with unspecified target to the end
  humanoid:queueAction({name = "use_staffroom"})
end

return use_staffroom_action_start
