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
object.id = "cabinet"
object.thob = 2
object.name = _S.object.cabinet
object.tooltip = _S.tooltip.objects.cabinet
object.ticks = false
object.build_cost = 100
object.build_preview_animation = 5054
object.idle_animations = {
  north = 80,
  east = 82,
}
object.usage_animations = {
  north = {
    in_use = {
      Doctor = 88,
    },
  },
  east = {
    in_use = {
      Doctor = 90,
    },
  },
}
object.orientations = {
  north = {
    footprint = { {0, 0}, {0, 1, only_passable = true} },
    use_position = "passable",
    use_animate_from_use_position = true,
  },
  east = {
    footprint = { {0, 0}, {-1, 0, only_passable = true} },
    early_list_while_in_use = true,
    use_position = "passable",
  },
  south = {
    footprint = { {0, 0}, {0, -1, only_passable = true} },
    use_position = "passable",
  },
  west = {
    footprint = { {0, 0}, {1, 0, only_passable = true} },
    early_list_while_in_use = true,
    use_position = "passable",
    use_animate_from_use_position = true,
  },
}

return object
