--[[ Copyright (c) 2010 Wendell Misiedjan
Edited with some help of Corsix.

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
object.id = "radiation_shield_b"
object.class = "RadiationShield"
object.thob = 28
object.name = _S.object.radiation_shield
object.tooltip = _S.tooltip.objects.radiation_shield
object.ticks = false
object.build_cost = 0

local function copy_east_to_west(t)
  t.west = t.east
  return t
end

object.idle_animations = copy_east_to_west {
  east = 1968,
}

object.orientations = {
  north = {
    render_attach_position = {0, 2},
    use_position = {0, 0},
    footprint = {},
  },
  east = {
    render_attach_position = {1, 1},
    use_position = {0, 0},
    footprint = {},
  },
}

return object
