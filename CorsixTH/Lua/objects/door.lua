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
object.class = "Door"
object.ticks = false
object.idle_animations = {
  north = 104,
  west = 106,
}

dofile "Queue"

class "Door" (Object)

function Door:Door(...)
  self:Object(...)
  self:setPosition(-1, 0)
  self.queue = Queue()
end

local door_flag_name = {
  north = "doorNorth",
  west = "doorWest",
}

function Door:setTile(x, y)
  local map = self.world.map
  if self.tile_x then
    map:setCellFlags(self.x, self.y, {
      [door_flag_name[self.direction]] = false,
      buildable = true,
    })
    if self.direction == "west" then
      map:setCellFlags(self.x - 1, self.y, {buildable = true})
    else
      map:setCellFlags(self.x, self.y - 1, {buildable = true})
    end
  end
  Object.setTile(self, x, y)
  if x then
    map:setCellFlags(x, y, {
      [door_flag_name[self.direction]] = true,
      buildable = false,
    })
    if self.direction == "west" then
      map:setCellFlags(x - 1, y, {buildable = false})
    else
      map:setCellFlags(x, y - 1, {buildable = false})
    end
  end
  return self
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

return object
