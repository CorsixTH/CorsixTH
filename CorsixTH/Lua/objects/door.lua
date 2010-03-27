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
object.id = "door"
object.thob = 3
object.name = _S.object.door
object.tooltip = _S.tooltip.objects.door
object.class = "Door"
object.ticks = false
object.idle_animations = {
  north = 104,
  west = 106,
}

dofile "queue"

class "Door" (Object)

function Door:Door(...)
  self:Object(...)
  self.queue = Queue()
  -- Priority should be given to humanoids already inside the door's room, as
  -- otherwise we could end up in a situation where a patient trying to leave
  -- a room is in the queue behind a patient trying to enter, and the entering
  -- one cannot enter until the leaving one has left, etc.
  self.queue:setPriorityForSameRoom(self)
  self.hover_cursor = TheApp.gfx:loadMainCursor("queue")
  -- self.user = "locked" -- prevents doors from being used (debug aid)
end

function Door:getRoom()
  return self.room
end

function Door:updateDynamicInfo()
  if self.room then
    self:setDynamicInfo('text', {
      self.room.room_info.name, 
      _S.dynamic_info.object.queue_size:format(self.queue:reportedSize()), 
      _S.dynamic_info.object.queue_expected:format(self.queue.expected_count)
    })
  end
end

function Door:onClick(ui, button)
  -- For consistency with reception desk, only open queue from a left click
  if button == "left" and self.queue then
    local queue_window = UIQueue(ui, self.queue)
    ui:addWindow(queue_window)
  end
end

local door_flag_name = {
  north = {"doorNorth", "tallNorth"},
  west = {"doorWest", "tallWest"},
}

function Door:setTile(x, y)
  local map = self.world.map
  local flag_names = door_flag_name[self.direction]
  if self.tile_x then
    map:setCellFlags(self.tile_x, self.tile_y, {
      [flag_names[1]] = false,
      [flag_names[2]] = false,
      buildable = true,
      doNotIdle = false,
    })
    if self.direction == "west" then
      map:setCellFlags(self.tile_x - 1, self.tile_y, {buildable = true, doNotIdle = false})
    else
      map:setCellFlags(self.tile_x, self.tile_y - 1, {buildable = true, doNotIdle = false})
    end
  end
  Object.setTile(self, x, y)
  if x then
    map:setCellFlags(x, y, {
      [flag_names[1]] = true,
      [flag_names[2]] = true,
      buildable = false,
      doNotIdle = true,
    })
    if self.direction == "west" then
      map:setCellFlags(x - 1, y, {buildable = false, doNotIdle = true})
    else
      map:setCellFlags(x, y - 1, {buildable = false, doNotIdle = true})
    end
  end
  map.th:updateShadows()
  return self
end

function Door:getWalkableTiles()
  local x, y = self.tile_x, self.tile_y
  if self.direction == "west" then
    x = x - 1
  else
    y = y - 1
  end  
  return { {self.tile_x, self.tile_y}, {x, y} }
end

local flag_early_list = 1024
local flag_list_bottom = 2048

function Door:setAnimation(animation, flags)
  flags = (flags or 0) + flag_list_bottom
  if self.direction == "north" then
    flags = flags + flag_early_list
  end
  return Object.setAnimation(self, animation, flags)
end

function Door:closeDoor()
  self.queue:rerouteAllPatients({name = "seek_room", room_type = self:getRoom().room_info.id})
  self:clearDynamicInfo(nil)
  self.hover_cursor = nil
end

function Door:checkForDeadlock()
  -- In an ideal world, deadlocks should not occur, as they indicate errors in
  -- some logic elsewhere. From a practical point of view, we should check for
  -- deadlocks from time to time and attempt to fix them.
  if self.queue and self.reserved_for then
    -- If the door is reserved for someone, then that person should either be
    -- at the front of the queue, or not in any queues at all.
    for _, action in ipairs(self.reserved_for.action_queue) do
      if action.name == "queue" then
        if action.queue ~= self.queue or self.queue[1] ~= self.reserved_for then
          self.reserved_for = nil
          self:getRoom():tryAdvanceQueue()
        end
        break
      end
    end
  end
end

return object
