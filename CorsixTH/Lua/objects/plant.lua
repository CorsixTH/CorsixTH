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

local object = {}
object.id = "plant"
object.thob = 45
object.name = _S.object.plant
object.class = "Plant"
object.tooltip = _S.tooltip.objects.plant
object.ticks = false
object.corridor_object = 6
object.build_cost = 5
object.build_preview_animation = 934

object.idle_animations = {
  north = 1950,
  south = 1950,
  east = 1950,
  west = 1950,
}
object.usage_animations = {
  north = {
    begin_use = { ["Handyman"] = 1972 },
    in_use = { ["Handyman"] = 1980 },
  },
  east = {
    begin_use = { ["Handyman"] = 1974 },
    in_use = { ["Handyman"] = 1982 },
  },
}
object.orientations = {
  north = {
    footprint = { {0, 0} },
    use_position = {0, -1},
    use_animate_from_use_position = true
  },
  east = {
    footprint = { {0, 0} },
    use_position = {-1, 0},
    use_animate_from_use_position = true
  },
  south = {
    footprint = { {0, 0} },
    use_position = {0, -1},
    use_animate_from_use_position = true
  },
  west = {
    footprint = { {0, 0} },
    use_position = {-1, 0},
    use_animate_from_use_position = true
  },
}

-- For litter: put broom back 356
-- take broom out: 1874
-- swoop: 1878
-- For plant: droop down: 1950
-- back up again: 1952

-- The states specify which frame to show
local states = {"healthy", "drooping1", "drooping2", "dying", "dead"}

local days_between_states = 75

--! An `Object` which needs watering now and then.
class "Plant" (Object)

function Plant:Plant(world, object_type, x, y, direction, etc)
  -- It doesn't matter which direction the plant is facing. It will be rotated so that an approaching
  -- handyman uses the correct usage animation when appropriate.
  self:Object(world, object_type, x, y, direction, etc)
  self.current_state = 0
  self.base_frame = self.th:getFrame()
  self.days_left = days_between_states
end

--! Goes one step forward (or backward) in the states of the plant.
--!param restoring (boolean) If true the plant improves its health instead of drooping.
function Plant:setNextState(restoring)
  local change = 0
  if restoring then
    if self.current_state > 0 then
      change = -1
    end
  elseif self.current_state < 5 then
    change = 1
  end

  self.current_state = self.current_state + change
  self.th:setFrame(self.base_frame + self.current_state)
end

local plant_restoring; plant_restoring = permanent"plant_restoring"( function(plant)
  local phase = plant.phase
  plant:setNextState(true)
  if phase > 0 then
    plant.phase = phase - 1
    plant:setTimer(math.floor(14 / plant.cycles), plant_restoring)
  else
    plant.ticks = false
  end
end)

--! Restores the plant to its initial state. (i.e. healthy)
function Plant:restoreToFullHealth()
  self.ticks = true
  self.phase = self.current_state
  self.cycles = self.current_state
  self:setTimer((self.direction == "south" or self.direction == "east") and 35 or 20, plant_restoring)
  self.days_left = days_between_states
end

--! Overridden since the plant animates slowly over time
function Plant:tick()
  local timer = self.timer_time
  if timer then
    timer = timer - 1
    if timer == 0 then
      self.timer_time = nil
      local timer_function = self.timer_function
      self.timer_function = nil
      timer_function(self)
    else
      self.timer_time = timer
    end
  end
end

--! Returns whether the plant is in need of watering right now.
function Plant:needsWatering()
  if self.current_state == 0 then
    if self.days_left < 1 then
      return true
    end
  else
    return true
  end
end

--! When the plant needs water it preiodically calls for a nearby handyman.
function Plant:callForWatering()
  -- Try to find a handyman nearby. If in a room, search just outside it.
  -- Note that only one of possibly many possible sides are chosen, prefering
  -- speed to quality of search.
  -- If self.ticks is true it means that a handyman is currently watering the plant.
  if not self.ticks and not self.reserved_for then
    local map = self.world.ui.app.map.th
    local lx, ly = self.tile_x, self.tile_y
    
    if self:getRoom() then
      lx, ly = self:getRoom():getEntranceXY()
    else
      ly = ly + 1
      if not map:getCellFlags(lx, ly).passable then
        ly = ly - 2
        if not map:getCellFlags(lx, ly).passable then
          ly = ly + 1
          lx = lx + 1
          if not map:getCellFlags(lx, ly).passable then
            lx = lx - 2
            if not map:getCellFlags(lx, ly).passable then
              lx, ly = nil, nil
            end
          end
        end
      end
    end
    if lx and ly then
      local candidate = self.world:getSuitableStaffCandidates(lx, ly, "Handyman", 10, "watering")[1]
      if candidate then
        self:createHandymanActions(candidate.entity)
      end
    end
    if self.current_state > 1 then
      self.world.ui.adviser:say(_S.adviser.warnings.plants_thirsty)
    end
  end
end

--! When a handyman is about to be summoned this function queues the complete set of actions necessary,
--  including entering and leaving any room involved. It also queues a meander action at the end.
--  Note that if there are more plants that need watering inside the room he will continue to water 
--  those too before leaving.
--!param handyman (Staff) The handyman that is about to get the actions.
function Plant:createHandymanActions(handyman)
  local ux, uy = self:getBestUsageTileXY(handyman.tile_x, handyman.tile_y)
  if not ux or not uy then
    -- The plant cannot be reached, let it die.
    return
  end
  local in_a_room = false
  if self:getRoom() then
    in_a_room = true
  end
  self.reserved_for = handyman
  -- Many plants in the vicinity may ask almost at the same time, make sure
  -- this handyman is occupied
  handyman.action_queue[1].is_job = self

  local action = {name = "walk", x = ux, y = uy, is_job = self, is_entering = in_a_room}
  local water_action = {
    name = "use_object", 
    object = self, 
    watering_plant = true,
    must_happen = true,
    is_job = self,
    after_use = --[[persistable:plant_more_plants]] function()
      if in_a_room then
        for object in pairs(self.world:findAllObjectsNear(self.tile_x, self.tile_y)) do
          if object.object_type.id == "plant" then
            if object:needsWatering() and not object.reserved_for then
              object:createHandymanActions(handyman)
              break
            end
          end
        end
      end
    end,
  }
  if handyman.action_queue[1].object then
    -- He's already using an object, he must be in a room!
    handyman:queueAction(action, 1)
    handyman:queueAction(water_action, 2)
  else
    handyman:setNextAction(action)
    handyman:queueAction(water_action)
    if in_a_room then
      local action = self:getRoom():createLeaveAction()
      action.is_job = self
      handyman:queueAction(action)
    end
    handyman:queueAction{name = "meander"}
  end
  
end

--! When a handyman should go to the plant he should approach it from the closest reachable tile.
--!param from_x (integer) The x coordinate of tile to calculate from.
--!param from_y (integer) The y coordinate of tile to calculate from.
function Plant:getBestUsageTileXY(from_x, from_y)
  local lx, ly = self.tile_x, self.tile_y + 1
  local rx, ry
  local shortest_path = 1000
  local world = self.world
  local direction = "north"
  local res_dir = direction
  local function shortest(distance)
    if distance and distance < shortest_path then
      -- Only take this route if there is no wall between the plant and the tile.
      local room_here = self:getRoom()
      local room_there = self.world:getRoom(lx, ly)
      if room_here == room_there or (not room_here and not room_there) then
        shortest_path = distance
        rx = lx
        ry = ly
        res_dir = direction
      end
    end
  end
  shortest(world:getPathDistance(from_x, from_y, lx, ly))
  ly = ly - 2
  direction = "south"
  shortest(world:getPathDistance(from_x, from_y, lx, ly))
  lx = lx - 1
  ly = ly + 1
  direction = "east"
  shortest(world:getPathDistance(from_x, from_y, lx, ly))
  lx = lx + 2
  direction = "west"
  shortest(world:getPathDistance(from_x, from_y, lx, ly))
  self.direction = res_dir
  return rx, ry
end

--! Counts down to eventually let the plant droop.
function Plant:tickDay()
  if not self.picked_up then
    -- The plant will need water a little more often if it is hot where it is.
    local temp = self.world.map.th:getCellTemperature(self.tile_x, self.tile_y)
    self.days_left = self.days_left - (1 + temp)
    if self.days_left < 1 then
      self.days_left = days_between_states
      self:setNextState()
    elseif not self.reserved_for and (self.days_left < 7 or self.current_state > 0) then
      self:callForWatering()
    end
  end
end

--! The plant needs to retain its animation when being moved.
function Plant:onClick(ui, button)
  if button == "right" then
    self.picked_up = true
    self.current_frame = self.base_frame + self.current_state
  end
  Object.onClick(self, ui, button)
end

return object
