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
object.id = "surgeon_screen"
object.class = "SurgeonScreen"
object.thob = 35
object.name = _S.object.surgeon_screen
object.tooltip = _S.tooltip.objects.surgeon_screen
object.ticks = false
object.build_cost = 200
object.build_preview_animation = 926
object.idle_animations = {
  north = 2772,
}
object.orientations = {
  north = {
    footprint = { {-1, -1, only_passable = true}, {-1, 0}, {0, -1}, {0, 0} },
    render_attach_position = {-1, 0},
    use_position = "passable",
  },
}

class "SurgeonScreen" (Object)
function SurgeonScreen:SurgeonScreen(...)
  self:Object(...)
  self.num_green_outfits = 2
  self.num_white_outfits = 0
end

return object
