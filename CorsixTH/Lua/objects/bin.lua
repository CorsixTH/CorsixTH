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
object.id = "bin"
object.thob = 50
object.name = _S.object.bin
object.tooltip = _S.tooltip.objects.bin
object.ticks = false
object.class = "SideObject"
object.build_preview_animation = 5096
object.idle_animations = {
  north = 1752,
  south = 1752,
}
object.orientations = {
  north = {
    footprint = { {0, 0, only_side = true} }
  },
  east = {
    footprint = { {0, 0, only_side = true} }
  },
}

class "SideObject" (Object)

function SideObject:SideObject(...)
  self:Object(...)
end

function SideObject:getDrawingLayer()
  if self.direction == "north" then
    return 1
  elseif self.direction == "west" then
    return 2
  else
    if self.direction == "east" then
      if self.object_type.thob == 50 then
      --[[ bins have two orientations north and east by they are displayed in
        the north and west part of the tile respectively which could lead to
        a graphical glitch in which a bin in the west part of the tile is
        displayed over a doctor in the middle of the tile ]]
        return 2
      else
        return 8
      end
    else --south
      return 9;
    end
  end
end
return object
