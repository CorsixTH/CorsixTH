--[[ Copyright (c) 2010 Peter "Corsix" Cawley

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

local room = {}
room.id = "operating_theatre"
room.name = _S.rooms_short.operating_theatre
room.tooltip = _S.tooltip.rooms.operating_theatre
room.build_cost = 8000
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = {
  operating_table = 1,
  surgeon_screen = 1,
  op_sink1 = 1,
  x_ray_viewer = 1
}
room.build_preview_animation = 5080
room.categories = {
  treatment = 3,
}
room.minimum_size = 6
room.wall_type = "white"
room.floor_tile = 21
room.swing_doors = true
room.required_staff = {
  Surgeon = 2,
}

return room
