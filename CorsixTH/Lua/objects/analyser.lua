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
object.id = "analyser"
object.thob = 41
object.research_category = "cure"
object.research_fallback = 45
object.name = _S.object.atom_analyser
object.tooltip = _S.tooltip.objects.atom_analyser
object.ticks = true
object.class = "AtomAnalyser"
object.build_preview_animation = 5092
object.show_in_town_map = true
object.idle_animations = {
  north = 2134,
  south = 2134,
}
local function copy_north_to_south(t)
  t.south = t.north
  return t
end

object.usage_animations = copy_north_to_south {
  north = {
    in_use = {
      Doctor =  {4878, object_visible = true}
    },
  },
}
object.orientations = {
  north = {
    footprint = { {-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {0, 0, only_passable = true}, {1, 0} },
    use_position = {0, 0},
  },
  east = {
    footprint = { {-1, -1}, {0, -1}, {-1, 0}, {0, 0, only_passable = true}, {-1, 1}, {0, 1} },
    use_position = {0, 0},
  },
}

class "AtomAnalyser" (Object)

---@type AtomAnalyser
local AtomAnalyser = _G["AtomAnalyser"]

function AtomAnalyser:AtomAnalyser(...)
  self:Object(...)
end

function AtomAnalyser:getDrawingLayer()
  return 3
end

return object
