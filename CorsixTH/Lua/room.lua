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

class "Room"

function Room:Room(x, y, w, h, id, room_info, world)
  self.id = id
  self.world = world
  self.x = x
  self.y = y
  self.width = w
  self.height = h
  self.maximum_patients = 1 -- A good default for most rooms
  
  self.world.map.th:markRoom(x, y, w, h, room_info.floor_tile, id)
  
  self.humanoids = {--[[a set rather than a list]]}
  
  self.objects_additional = {}
  if room_info.objects_additional then
    for i = 1, #room_info.objects_additional do
      self.objects_additional[i] = { object = TheApp.objects[room_info.objects_additional[i]], qty = 0 }
    end
  end

  self.objects_needed = {}
  if room_info.objects_needed then
    for i = 1, #room_info.objects_needed do
      self.objects_needed[i] = { object = TheApp.objects[room_info.objects_needed[i]], qty = 1, needed = true }
    end
  end
  -- TODO
end

function Room:createLeaveAction()
  local door = self.door
  local x, y = door.tile_x, door.tile_y
  if self.world:getRoom(x, y) == self then
    if door.direction == "north" then
      y = y - 1
    elseif door.direction == "west" then
      x = x - 1
    end
  end
  return {name = "walk", x = x, y = y}
end

function Room:onHumanoidEnter(humanoid)
  assert(not self.humanoids[humanoid], "Humanoid entering a room that they are already in")
  self.humanoids[humanoid] = true
  --print(humanoid, "enter", self.id, class.is(humanoid, Staff), class.is(humanoid, Patient), class.is(humanoid, Humanoid))
  
  -- For now, staff always leave rooms, even if they are suitable for the room
  -- TODO: Change this
  if class.is(humanoid, Staff) and humanoid.humanoid_class ~= "Handyman" then
    humanoid:queueAction(self:createLeaveAction(), 1)
  end
end

function Room:onHumanoidLeave(humanoid)
  assert(self.humanoids[humanoid], "Humanoid leaving a room that they are not in")
  self.humanoids[humanoid] = nil
  --print(humanoid, "leave", self.id)
end
