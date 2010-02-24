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
object.id = "extinguisher"
object.thob = 43
object.name = _S.object.fire_extinguisher
object.tooltip = _S.tooltip.objects.fire_extinguisher
object.ticks = false
object.corridor_object = 4
object.build_cost = 25
object.build_preview_animation = 912
object.idle_animations = {
  north = 178,
  east = 468,
  south = 470,
}
object.orientations = {
  north = {
    footprint = { {0, 0} }
  },
  east = {
    footprint = { {0, 0} }
  },
  south = {
    footprint = { {0, 0} }
  },
  west = {
    footprint = { {0, 0} }
  },
}

return object
