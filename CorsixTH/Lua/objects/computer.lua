--[[ Copyright (c) 2009 Manuel König

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
object.id = "computer"
object.thob = 40
object.research_category = "cure"
object.research_fallback = 46
object.name = _S.object.computer
object.tooltip = _S.tooltip.objects.computer
object.ticks = false
object.build_cost = 5000
object.build_preview_animation = 5090

local function copy_north_to_south(t)
  t.south = t.north
  return t
end

object.idle_animations = copy_north_to_south {
  north = 2094,
}
object.usage_animations = copy_north_to_south {
  north = {
    in_use = {
      Doctor = 2098,
    },
  },
}
object.orientations = {
  north = {
    use_position = "passable",
    use_animate_from_use_position = true,
    footprint = { {0, 0}, {0, 1, only_passable = true} },
  },
  east = {
    use_position = "passable",
    use_animate_from_use_position = true,
    footprint = { {0, 0}, {1, 0, only_passable = true} },
    early_list_while_in_use = true,
  },
}

return object
