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

class "SeekReceptionAction" (HumanoidAction)

---@type SeekReceptionAction
local SeekReceptionAction = _G["SeekReceptionAction"]

-- Distance from queue that patient can join a reception desk queue.
local can_join_queue_distance = 6

function SeekReceptionAction:SeekReceptionAction()
  self:HumanoidAction("seek_reception")
end

--! Can the humanoid join the reception queue at the given position?
--!param humanoid (Humanoid) Humanoid going to the reception.
--!param x (int) X coordinate of the tile to consider.
--!param y (int) Y coordinate of the tile to consider.
--!param dist (int) Distance of the tile to the reception.
--!return (bool) Whether the humanoid can start queueing.
local function can_join_queue_at(humanoid, x, y, dist)
  local flag_cache = humanoid.world.map.th:getCellFlags(x, y)
  return flag_cache.hospital and not flag_cache.room and
      dist <= can_join_queue_distance and
      flag_cache.owner == humanoid.hospital:getPlayerIndex()
end

--! Trim the last part of the path when it is possible to join the reception queue.
--!param humanoid Humanoid that will walk the path.
--!param path_x (array of int) X coordinates of the path, modified in-place.
--!param path_y (array of int) Y coordinates of the path, modified in-place.
local function trimQueuingTail(humanoid, path_x, path_y)
  local pathindex = #path_x
  for i = pathindex - 1, 2, -1 do
    if can_join_queue_at(humanoid, path_x[i], path_y[i], pathindex - i) then
      path_x[i + 1] = nil
      path_y[i + 1] = nil
    else
      break
    end
  end
  return
end

-- Start of the seek-reception action.
local function action_seek_reception_start(action, humanoid)
  local world = humanoid.world
  local best_desk
  local score
  local best_distance_from_desk

  assert(humanoid.hospital, "humanoid must be associated with a hospital to seek reception")

  -- Go through all receptions desks.
  for _, desk in ipairs(humanoid.hospital:findReceptionDesks()) do
    if desk.receptionist or desk.reserved_for then
      -- Ok, so we found one with staff at it or on the way.
      -- Is this one better than the last one?
      -- A lower score is better.
      -- First find out where the usage tile is.
      local orientation = desk.object_type.orientations[desk.direction]
      local x = desk.tile_x + orientation.use_position[1]
      local y = desk.tile_y + orientation.use_position[2]

      local distance_from_desk = humanoid.world:getPathDistance(humanoid.tile_x, humanoid.tile_y, x, y)
      if distance_from_desk then
        local this_score = distance_from_desk + desk:getUsageScore()
        if not score or this_score < score then
          -- It is better, or the first one!
          score = this_score
          best_desk = desk
          best_distance_from_desk = distance_from_desk
        end
      end
    end
  end
  if best_desk then
    -- We found a desk to go to!
    local orientation = best_desk.object_type.orientations[best_desk.direction]
    local x = best_desk.tile_x + orientation.use_position[1]
    local y = best_desk.tile_y + orientation.use_position[2]

    -- TODO: Make 'else' method work for all humanoids
    if class.is(humanoid, Vip) or class.is(humanoid, Inspector) then
      humanoid:updateDynamicInfo(_S.dynamic_info.patient.actions.on_my_way_to
          :format(best_desk.object_type.name))

    else
      humanoid:setDynamicInfoText(_S.dynamic_info.patient.actions.on_my_way_to
          :format(best_desk.object_type.name))
    end
    humanoid.waiting = nil

    -- We don't want patients which have just spawned to be joining the queue
    -- immediately, so walk them closer to the desk before joining the queue
    if can_join_queue_at(humanoid, humanoid.tile_x, humanoid.tile_y, best_distance_from_desk) then
      local face_x, face_y = best_desk:getSecondaryUsageTile()
      humanoid:setNextAction(QueueAction(x, y, best_desk.queue):setMustHappen(action.must_happen)
          :setFaceDirection(face_x, face_y))
    else
      local walk = WalkAction(x, y):setMustHappen(action.must_happen)
      humanoid:queueAction(walk, 0)

      trimQueuingTail(humanoid, walk.path_x, walk.path_y)
      walk.x = walk.path_x[#walk.path_x]
      walk.y = walk.path_y[#walk.path_x]
    end
    humanoid.hospital:msgMultiReceptionDesks()

  else
    -- No reception desk found. One will probably be built soon, somewhere in
    -- the hospital, so either walk to the hospital, or walk around the hospital.
    local procrastination
    if humanoid.hospital:isInHospital(humanoid.tile_x, humanoid.tile_y) then
      procrastination = MeanderAction():setCount(1):setMustHappen(action.must_happen)
      if not humanoid.waiting then
        -- Eventually people are going to get bored and leave.
        humanoid.waiting = 5
      end
    else
      local _, hosp_x, hosp_y = world.pathfinder:isReachableFromHospital(humanoid.tile_x, humanoid.tile_y)
      procrastination = WalkAction(hosp_x, hosp_y):setMustHappen(action.must_happen)
    end
    humanoid:queueAction(procrastination, 0)
  end
end

return action_seek_reception_start
