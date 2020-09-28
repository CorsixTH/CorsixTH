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
object.corridor_object = 7
object.build_preview_animation = 934

object.idle_animations = {
  north = 1950,
  south = 1950,
  east = 1950,
  west = 1950,
}
object.usage_animations = {
  north = {
    begin_use = { ["Handyman"] = {1972, object_visible = true} },
    in_use = { ["Handyman"] = {1980, object_visible = true} },
  },
  east = {
    begin_use = { ["Handyman"] = {1974, object_visible = true} },
    in_use = { ["Handyman"] = {1982, object_visible = true} },
  },
}
object.orientations = {
  north = {
    footprint = { {0, 0, complete_cell = true} },
    use_position = {0, -1},
    use_animate_from_use_position = true
  },
  east = {
    footprint = { {0, 0, complete_cell = true} },
    use_position = {-1, 0},
    use_animate_from_use_position = true
  },
  south = {
    footprint = { {0, 0, complete_cell = true} },
    use_position = {0, -1},
    use_animate_from_use_position = true
  },
  west = {
    footprint = { {0, 0, complete_cell = true} },
    use_position = {-1, 0},
    use_animate_from_use_position = true
  },
}

-- For litter: put broom back 356
-- take broom out: 1874
-- swoop: 1878
-- Frames for plant states are
-- * healthy: 1950
-- * drooping1: 1951
-- * drooping2: 1952
-- * dying: 1953
-- * dead: 1954


local days_between_states = 75

-- days before we reannouncing our watering status if we were unreachable
local days_unreachable = 10

--! An `Object` which needs watering now and then.
class "Plant" (Object)

---@type Plant
local Plant = _G["Plant"]

function Plant:Plant(world, object_type, x, y, direction, etc)
  -- It doesn't matter which direction the plant is facing. It will be rotated so that an approaching
  -- handyman uses the correct usage animation when appropriate.
  self:Object(world, object_type, x, y, direction, etc)
  self.current_state = 0
  self.base_frame = self.th:getFrame()
  self.days_left = days_between_states
  self.unreachable = false
  self.unreachable_counter = days_unreachable
end

--! Goes one step forward (or backward) in the states of the plant.
--!param restoring (boolean) If true the plant improves its health instead of drooping.
function Plant:setNextState(restoring)
  if restoring then
    if self.current_state > 0 then
      self.current_state = self.current_state - 1
    end
  elseif self.current_state < 5 then
    self.current_state = self.current_state + 1
  end

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

  local taskIndex = self.hospital:getIndexOfTask(self.tile_x, self.tile_y, "watering")
  if taskIndex ~= -1 then
  self.hospital:removeHandymanTask(taskIndex, "watering")
  end
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
    if self.days_left < 10 then
      return true
    end
  else
    return true
  end
end

--! When the plant needs water it periodically calls for a nearby handyman.
function Plant:callForWatering()
  -- If self.ticks is true it means that a handyman is currently watering the plant.
  -- If there are no tiles to water from, just die.
  if not self.ticks then
    if not self.unreachable then
      local index = self.hospital:getIndexOfTask(self.tile_x, self.tile_y, "watering")
      if index == -1 then
        local call = self.world.dispatcher:callForWatering(self)
        self.hospital:addHandymanTask(self, "watering", self.current_state + 1, self.tile_x, self.tile_y, call)
      else
        self.hospital:modifyHandymanTaskPriority(index, self.current_state + 1, "watering")
      end
    end

    -- If very thirsty, make user aware of it.
    if self.current_state > 1 and not self.plant_announced then
      self.world.ui.adviser:say(_A.warnings.plants_thirsty)
      self.plant_announced = true
    end
  end
end

--! When a handyman is about to be summoned this function queues the complete set of actions necessary,
--  including entering and leaving any room involved. It also queues a meander action at the end.
--  Note that if there are more plants that need watering inside the room he will continue to water
--  those too before leaving.
--!param handyman (Staff) The handyman that is about to get the actions.
function Plant:createHandymanActions(handyman)
  local this_room = self:getRoom()
  local handyman_room = handyman:getRoom()
  local ux, uy = self:getBestUsageTileXY(handyman.tile_x, handyman.tile_y)
  if not ux or not uy then
    -- The plant cannot be reached.
    self.unreachable = true
    self.unreachable_counter = days_unreachable
    local index = self.hospital:getIndexOfTask(self.tile_x, self.tile_y, "watering")
    if index ~= -1 then
      self.hospital:removeHandymanTask(index, "watering")
    end
    -- Release Handyman
    handyman:setCallCompleted()
    if handyman_room then
      handyman:setNextAction(handyman_room:createLeaveAction())
      handyman:queueAction(MeanderAction())
    else
      handyman:setNextAction(MeanderAction())
    end
    return
  end
  self.reserved_for = handyman
  local walk_action = WalkAction(ux, uy):setIsEntering(this_room and true or false)
  if handyman_room and handyman_room ~= this_room then
    handyman:setNextAction(handyman_room:createLeaveAction())
    handyman:queueAction(walk_action)
  else
    handyman:setNextAction(walk_action)
  end
  handyman:queueAction(UseObjectAction(self):enableWateringPlant())
  CallsDispatcher.queueCallCheckpointAction(handyman)
  handyman:queueAction(AnswerCallAction())
end

--! When a handyman should go to the plant he should approach it from the
-- closest reachable tile within hospital buildings.
--!param from_x (integer) The x coordinate of tile to calculate from.
--!param from_y (integer) The y coordinate of tile to calculate from.
function Plant:getBestUsageTileXY(from_x, from_y)
  local access_points = {{dx =  0, dy =  1, direction = "north"},
                         {dx =  0, dy = -1, direction = "south"},
                         {dx = -1, dy =  0, direction = "east"},
                         {dx =  1, dy =  0, direction = "west"}}
  local shortest
  local best_point = nil
  local room_here = self:getRoom()
  for _, point in ipairs(access_points) do
    local dest_x, dest_y = self.tile_x + point.dx, self.tile_y + point.dy
    local room_there = self.world:getRoom(dest_x, dest_y)
    if room_here == room_there and self.hospital:isInHospital(dest_x, dest_y) then
      local distance = self.world:getPathDistance(from_x, from_y, dest_x, dest_y)
      if distance and (not best_point or shortest > distance) then
        best_point = point
        shortest = distance
      end
    end
  end

  if best_point then
    self.direction = best_point.direction
    return self.tile_x + best_point.dx, self.tile_y + best_point.dy
  else
    self.direction = "north"
    return
  end
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
    elseif not self.reserved_for and self:needsWatering() and not self.unreachable then
      self:callForWatering()
    end
    if self.unreachable then
      self.unreachable_counter = self.unreachable_counter - 1
      if self.unreachable_counter == 0 then
        self.unreachable = false
      end
    end
  end
end

--! The plant needs to retain its animation and reset its unreachable flag when being moved
function Plant:onClick(ui, button)
  if button == "right" then
    self.unreachable = false
    self.picked_up = true
    self.current_frame = self.base_frame + self.current_state
  end
  Object.onClick(self, ui, button)
end

function Plant:isPleasing()
  if not self.ticks then
    return true
  else
   return false
  end
end

--! Check if a plant is dying or about to start dying
function Plant:isDying()
  if self.current_state ~= 0 or self.days_left < 3 then
    return true
  end
  return false
end

function Plant:onDestroy()
  local index = self.hospital:getIndexOfTask(self.tile_x, self.tile_y, "watering")
  if index ~= -1 then
    self.hospital:removeHandymanTask(index, "watering")
  end
  Object.onDestroy(self)
end

function Plant:afterLoad(old, new)
  if old < 52 then
    self.hospital = self.world:getLocalPlayerHospital()
  end
  Object.afterLoad(self, old, new)
end


return object
