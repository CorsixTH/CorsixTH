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

local TH = require "TH"
dofile "entity"

class "Object" (Entity)

function Object:Object(world, object_type, x, y, direction)
  local th = TH.animation()
  self:Entity(th)
  
  self.ticks = object_type.ticks
  self.object_type = object_type
  self.world = world
  self.direction = direction
  self.user = false

  self:setAnimation(object_type.idle_animations[direction])  
  self:setTile(x, y)
end

function Object:setTile(x, y)
  if self.tile_x ~= nil then
    self.world:removeObjectFromTile(self, self.tile_x, self.tile_y)
  end
  Entity.setTile(self, x, y)
  if x then
    self.world:addObjectToTile(self, x, y)
  end
  return self
end

function Object:setUser(user)
  self.user = user or false
  if user then
    self.th:makeInvisible()
  else
    self.th:makeVisible()
  end
end
