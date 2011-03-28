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
local decide_next_target = permanent"use_staffroom_action_decide_next_target"( function(action, humanoid)
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
  local obj, ox, oy = humanoid.world:findFreeObjectNearToUse(humanoid, new_type, "near")
  return obj, ox, oy, new_type
end)

-- randomly generate the use time for a given source of relaxation
local generate_use_time = permanent"use_staffroom_action_generate_use_time"( function(type)
  if type == "sofa" then
    return math.random(50, 80)
  elseif type == "pool_table" then
    return math.random(2, 5)
  elseif type == "video_game" then
    return math.random(2, 15)
  end
end)

-- table of how much relaxation an object gives per tick
local relaxation = {
  sofa = 0.001,
  pool_table = 0.05,
  video_game = 0.05,
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
    loop_callback = --[[persistable:use_staffroom_action_loop_callback]] function()
      humanoid:wake(relaxation[action.target_type])
      -- if staff is no longer fatigued, make them leave the staff room
      if humanoid.attributes["fatigue"] == 0 then
        humanoid:setNextAction(humanoid:getRoom():createLeaveAction())
        local room = humanoid.last_room
        -- Send back to the last room if that room is still empty.
        -- (applies to training and research only)
        -- Make sure that the room is still there though.
        -- If not, just answer the call
        if room and room.is_active and 
        (room.room_info.id == "research" or room.room_info.id == "training")
        and room:testStaffCriteria(room:getMaximumStaffCriteria(), humanoid) then
          humanoid:queueAction(room:createEnterAction(humanoid))
          humanoid:setDynamicInfoText(_S.dynamic_info.staff.actions.heading_for:format(room.room_info.name))
        else
          -- Send the staff out of the room
          humanoid:queueAction{name = "meander"}
        end
      end

      obj_use_time = obj_use_time - 1
      -- if staff is done using object
      if obj_use_time == 0 then
        -- Decide on the next target. If it happens to be of the same type as the current, just continue using the current.
        -- also check x,y co-ords to see if the object actually exists in the room
        action.next_target_obj, action.next_ox, action.next_oy, action.next_target_type = decide_next_target(action, humanoid)
        if (not action.next_ox and not action.next_oy) or action.next_target_type == action.target_type then
          obj_use_time = generate_use_time(action.target_type)
        else
          if action.next_target_obj then
            action.next_target_obj.reserved_for = humanoid
          end
          object_action.prolonged_usage = false
        end
      end
    end
  }
  humanoid:queueAction({name = "walk", x = action.ox, y = action.oy}, 0)
  humanoid:queueAction(object_action, 1)
end

return use_staffroom_action_start
