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

local flag_cache = {}
local function can_join_queue_at(humanoid, x, y, use_x, use_y)
  return humanoid.world.map.th:getCellFlags(x, y, flag_cache).hospital
    and (not flag_cache.room)
    and (x - use_x)^2 + (y - use_y)^2 < 12^2
end

local function action_seek_reception_start(action, humanoid)
  local world = humanoid.world
  
  local found_desk = false
  world:findObjectNear(humanoid, "reception_desk", nil, function(x, y, d)
    local desk = world:getObject(x, y, "reception_desk")
    if (not desk.receptionist and not desk.reserved_for) or desk.queue:isFull() then
      return
    end
    
    local orientation = desk.object_type.orientations[desk.direction]
    if not orientation.pathfind_allowed_dirs[d] then
      return
    end
    x = x + orientation.use_position[1]
    y = y + orientation.use_position[2]
    humanoid:updateDynamicInfo(_S.dynamic_info.patient.actions.on_my_way_to
      :format(desk.object_type.name))
    humanoid.waiting = nil
    
    -- We don't want patients which have just spawned to be joining the queue
    -- immediately, so walk them closer to the desk before joining the queue
    if can_join_queue_at(humanoid, humanoid.tile_x, humanoid.tile_y, x, y) then
      local face_x, face_y = desk:getSecondaryUsageTile()
      humanoid:setNextAction{
        name = "queue",
        x = x,
        y = y,
        queue = desk.queue,
        face_x = face_x,
        face_y = face_y,
        must_happen = action.must_happen,
      }
    else
      local walk = {name = "walk", x = x, y = y, must_happen = action.must_happen}
      humanoid:queueAction(walk, 0)
      
      -- Trim the walk to finish once it is possible to join the queue
      for i = #walk.path_x, 2, -1 do
        if can_join_queue_at(humanoid, walk.path_x[i], walk.path_y[i], x, y) then
          walk.path_x[i + 1] = nil
          walk.path_y[i + 1] = nil
        else
          break
        end
      end
    end
    found_desk = true
    return true
  end)
  if found_desk then
    return
  end
  
  -- No reception desk found. One will probably be built soon, somewhere in
  -- the hospital, so either walk to the hospital, or walk around the hospital.
  local procrastination
  if world.map.th:getCellFlags(humanoid.tile_x, humanoid.tile_y).hospital then
    procrastination = {name = "meander", count = 1}
    if not humanoid.waiting then
      -- Eventually people are going to get bored and leave.
      humanoid.waiting = 5
    end
  else
    local _, hosp_x, hosp_y = world.pathfinder:isReachableFromHospital(humanoid.tile_x, humanoid.tile_y)
    procrastination = {name = "walk", x = hosp_x, y = hosp_y}
  end
  procrastination.must_happen = action.must_happen
  humanoid:queueAction(procrastination, 0)
end

return action_seek_reception_start
