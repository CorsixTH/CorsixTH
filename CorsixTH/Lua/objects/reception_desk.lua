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
object.name = _S.object.reception_desk
object.tooltip = _S.tooltip.objects.reception_desk
object.ticks = true
object.corridor_object = 1
object.build_preview_animation = 5060
object.idle_animations = {
  north = 2062,
  east = 2064,
}
object.orientations = {
  north = {
    footprint = { {0, 0}, {0, -1, only_passable = true},
                  {0, 1, only_passable = true}, {1, 0, need_north_side = true, need_south_side = true},
                  {-1, 0, need_north_side = true, need_south_side = true}
                },
    use_position = {0, -1},
    use_position_secondary = {0, 1},
  },
  east = {
    footprint = { {0, 0}, {0, -1, need_west_side = true, need_east_side = true},
                  {0, 1, need_west_side = true, need_east_side = true}, {1, 0, only_passable = true},
                  {-1, 0, only_passable = true}
                },
    use_position = {1, 0},
    use_position_secondary = {-1, 0},
  },
  south = {
    footprint = { {0, 0}, {0, -1, only_passable = true}, {0, 1, only_passable = true},
                  {1, 0, need_north_side = true, need_south_side = true},
                  {-1, 0, need_north_side = true, need_south_side = true}
                },
    use_position = {0, 1},
    use_position_secondary = {0, -1},
  },
  west = {
    footprint = { {0, 0}, {0, -1, need_west_side = true, need_east_side = true},
                   {0, 1, need_west_side = true, need_east_side = true},
                  {1, 0, only_passable = true}, {-1, 0, only_passable = true}
                },
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
  self.queue:setMaxQueue(20) -- larger queues for reception desk
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
      if self.queue_advance_timer >= 4 + self.world.hours_per_day * (1.0 - self.receptionist.profile.skill) then
        reset_timer = true
        if queue_front.next_room_to_visit then
          queue_front:queueAction{name = "seek_room", room_type = queue_front.next_room_to_visit.room_info.id}
        else
          if class.is(queue_front, Inspector) then
            local inspector = queue_front
            if not inspector.going_home  then
              local epidemic = self.world:getLocalPlayerHospital().epidemic
              if epidemic then
                -- The result of the epidemic may already by determined
                -- i.e if an infected patient has left the hospital
                if not epidemic.result_determined then
                  epidemic:finishCoverUp()
                end
                epidemic:applyOutcome()
                inspector:goHome()
              end
            end
            -- VIP has his own list, don't add the gp office twice
          elseif queue_front.humanoid_class ~= "VIP" then
            queue_front:queueAction{name = "seek_room", room_type = "gp"}
          else
            -- the VIP will realise that he is idle, and start going round rooms
            queue_front:queueAction{name = "idle"}
            queue_front.waiting = 1
          end
        end
        self.queue:pop()
        self.queue.visitor_count = self.queue.visitor_count + 1
        queue_front.has_passed_reception = true
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
    if entity.humanoid_class == "Receptionist" and not entity.associated_desk and not entity.fired then
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

  self:occupy(nearest_staff)
  return true
end

-- how many tiles further are we willing to walk for 1 person fewer in the queue
local tile_factor = 10
function ReceptionDesk:getUsageScore()
  local score = self.queue:patientSize() * tile_factor
  -- Add constant penalty if queue is full
  if self.queue:isFull() then
    score = score + 1000
  end
  return score
end

function ReceptionDesk:setTile(x, y)
  Object.setTile(self, x, y)
  if x and y then
    self:checkForNearbyStaff()
  end
  return self
end

function ReceptionDesk:onDestroy()
  self.being_destroyed = true -- temporary flag for receptionist (re-)routing logic
  local receptionist = self.receptionist or self.reserved_for
  if receptionist then
    receptionist:handleRemovedObject(self)
    self.receptionist = nil
    self.reserved_for = nil

    -- Find a new reception desk for the receptionist
    local world = receptionist.world
    world:findObjectNear(receptionist, "reception_desk", nil, function(x, y)
      local obj = world:getObject(x, y, "reception_desk")
      -- Make sure we are not selecting the same desk again
      if obj and obj ~= self then
        return obj:occupy(receptionist)
      end
    end)
  end
  self.queue:rerouteAllPatients({name = "seek_reception"})
  self.world:getLocalPlayerHospital().reception_desks[self] = nil

  self.being_destroyed = nil
  return Object.onDestroy(self)
end

--[[ Create orders for the specified receptionist to walk to and then staff the reception desk,
if not already staffed or someone is on the way
!param receptionist (Staff) the receptionist to occupy this desk
!return true iff the receptionist was ordered to the desk
]]
function ReceptionDesk:occupy(receptionist)
  if not self.receptionist and not self.reserved_for then
    self.reserved_for = receptionist
    receptionist.associated_desk = self
    local use_x, use_y = self:getSecondaryUsageTile()
    receptionist:setNextAction{name = "walk", x = use_x, y = use_y, must_happen = true}
    receptionist:queueAction{name = "staff_reception", object = self, must_happen = true}
    return true
  end
end

return object
