--[[ Copyright (c) 2016 Albert "Alberth" Hofkamp

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
object.id = "rathole"
object.thob = 64
object.name = _S.object.rathole
object.class = "Rathole"
object.tooltip = _S.tooltip.objects.rathole
object.ticks = false
object.idle_animations = {
  north = 1904,
}
object.orientations = {
  -- Empty footprint, so you can build any other object on top of it.
  north = { footprint = {} },
  south = { footprint = {} },
  west  = { footprint = {} },
  east  = { footprint = {} },
}

-- For ratholes:
-- 1904: hole in north wall
-- 1908: rat moving north
-- 1910: rat moving north-east
-- 1912: rat moving east
-- 1914: rat moving south-east
-- 1916: rat moving south
-- 1918: rat moving south-west
-- 1920: rat moving west
-- 1922: rat moving north-west
-- 1924: rat entering hole north wall
-- 1926: rat entering hole west wall
-- 1928: rat leaving hole north wall

class "Rathole" (Object)

---@type Rathole
local Rathole = _G["Rathole"]

function Rathole:Rathole(world, oject_type, x, y, direction, etc)
  self:Object(world, oject_type, x, y, direction, etc)
end

return object
