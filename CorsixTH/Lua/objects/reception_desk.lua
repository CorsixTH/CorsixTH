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
object.id = "reception_desk"
object.thob = 11
object.class = "ReceptionDesk"
object.name = _S(2, 12)
object.ticks = true
object.corridor_object = 1
object.build_cost = 150
object.build_preview_animation = 5060
object.idle_animations = {
  north = 2062,
  east = 2064,
}
object.orientations = {
  north = {
    footprint = { {0, 0}, {0, -1, only_passable = true}, {0, 1, only_passable = true}, {1, 0}, {-1, 0} },
    use_position = {0, -1},
    use_position_secondary = {0, 1},
  },
  east = {
    footprint = { {0, 0}, {0, -1}, {0, 1}, {1, 0, only_passable = true}, {-1, 0, only_passable = true} },
    use_position = {1, 0},
    use_position_secondary = {-1, 0},
  },
  south = {
    footprint = { {0, 0}, {0, -1, only_passable = true}, {0, 1, only_passable = true}, {1, 0}, {-1, 0} },
    use_position = {0, 1},
    use_position_secondary = {0, -1},
  },
  west = {
    footprint = { {0, 0}, {0, -1}, {0, 1}, {1, 0, only_passable = true}, {-1, 0, only_passable = true} },
    use_position = {-1, 0},
    use_position_secondary = {1, 0},
  },
}

dofile "queue"

class "ReceptionDesk" (Object)

function ReceptionDesk:ReceptionDesk(...)
  self:Object(...)
  self.queue = Queue()
  self.queue:setBenchThreshold(3) -- Keep 3 people standing in the queue even if there are benches
  self.hover_cursor = TheApp.gfx:loadMainCursor("queue")
  self.queue_advance_timer = 0
end

function ReceptionDesk:onClick(ui, button)
  if button == "left" then
    local queue_window = UIQueue(ui, self.queue)
    ui:addWindow(queue_window)
  else
    return Object.onClick(self, ui, button)
  end
end

function ReceptionDesk:tick()
  local queue_front = self.queue:front()
  local reset_timer = true
  if self.receptionist and queue_front then
    if queue_front.action_queue[1].name == "idle" then
      self.queue_advance_timer = self.queue_advance_timer + 1
      reset_timer = false
      if self.queue_advance_timer >= 4 + 24 * (1.0 - self.receptionist.profile.skill) then
        reset_timer = true
        queue_front:queueAction{name = "seek_room", room_type = "gp"}
        self.queue:pop()
        self.queue.visitor_count = self.queue.visitor_count + 1
      end
    end
  end
  if reset_timer then
    self.queue_advance_timer = 0
  end
  return Object.tick(self)
end

function ReceptionDesk:checkForNearbyStaff()
  if self.receptionist or self.reserved_for then
    -- Already got staff, or a staff member is on the way
    return true
  end
  
  local nearest_staff, nearest_d
  local world = self.world
  local use_x, use_y = self:getSecondaryUsageTile()
  for _, entity in ipairs(self.world.entities) do
    if entity.humanoid_class == "Receptionist" and not entity.associated_desk then
      local distance = world.pathfinder:findDistance(entity.tile_x, entity.tile_y, use_x, use_y)
      if not nearest_d or distance < nearest_d then
        nearest_staff = entity
        nearest_d = distance
      end
    end
  end
  if not nearest_staff then
    return false
  end
  
  self.reserved_for = nearest_staff
  nearest_staff.associated_desk = self
  nearest_staff:setNextAction{name = "walk", x = use_x, y = use_y, must_happen = true}
  nearest_staff:queueAction{name = "staff_reception", object = self, must_happen = true}
  return true
end

function ReceptionDesk:setTile(x, y)
  Object.setTile(self, x, y)
  if x and y then
    self:checkForNearbyStaff()
  end
  return self
end

function ReceptionDesk:onDestroy()
  if self.receptionist then
    self.receptionist:handleRemovedObject(self)
  end
  self.queue:rerouteAllPatients({name = "seek_reception"})
  return Object.onDestroy(self)
end

return object
