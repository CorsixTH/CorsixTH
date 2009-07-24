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

class "Map"
local thMap = require"TH".map

function Map:Map()
  self.width = false
  self.height = false
  self.th = thMap()
end

-- Convert between world co-ordinates and screen co-ordinates
-- World co-ordinates are (at least for standard maps) in the range [1, 128)
-- for both x and y, with the floor of the values giving the cell index.
-- Screen co-ordinates are pixels relative to the map origin - NOT relative to
-- the top-left corner of the screen (use UI:WorldToScreen and UI:ScreenToWorld
-- for this).

function Map:WorldToScreen(x, y)
  return 32 * (x - y), 16 * (x + y - 2)
end

function Map:ScreenToWorld(x, y)
  y = (y / 32) + 1
  x = x / 64
  return y + x, y - x
end

function Map:load(thData)
  assert(self.th:load(thData))
  self.width, self.height = self.th:size()
end

function Map:setBlocks(blocks)
  self.th:setSheet(blocks)
end

function Map:setCellFlags(...)
  self.th:setCellFlags(...)
end

--[[!
  @arguments canvas, screen_x, screen_y, screen_width, screen_height, destination_x, destination_y
  
  Draws the rectangle of the map given by (sx, sy, sw, sh) at position (dx, dy) on the canvas
--]]
function Map:draw(canvas, sx, sy, sw, sh, dx, dy)
  return self.th:draw(canvas, sx, sy, sw, sh, dx, dy)
end
