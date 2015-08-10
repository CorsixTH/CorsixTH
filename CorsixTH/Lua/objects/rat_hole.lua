--[[ Copyright (c) 2014 Benoît "benckx" Vleminckx

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

local object = {}
object.id = "rat_hole"
object.thob = 64
object.name = "rat hole" -- TODO
object.tooltip = "rate hole" -- TODO
object.ticks = false
object.class = "RatHole"
object.idle_animations = {
  south = 1904,
}
object.orientations = {
  north = {
    footprint = { {0, 0, only_side = true} }
  },
  east = {
    footprint = { {0, 0, only_side = true} }
  },
  south = {
    footprint = { {0, 0, only_side = true} }
  },
  west = {
    footprint = { {0, 0, only_side = true} }
  },
}

class "RatHole" (Object)

function RatHole:RatHole(world, object_type, x, y, direction, etc)
  local th = TH.animation()
  self:Entity(th)
  self.object_type = object_type
  self.world = world
  self:initOrientation(direction)
  self:setTile(x, y)
  if direction == "south" then
    self:setAnimation(1904, 0)
  elseif direction == "east" then
    self:setAnimation(1904, 1)
  end

  -- Life span of the rat hole (in months)
  -- TODO: This could depend on difficulty and level
  self.life_span = math.random(1, 6)
end

return object
