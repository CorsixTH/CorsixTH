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
object.id = "video_game"
object.thob = 57
object.name = _S.object.video_game
object.tooltip = _S.tooltip.objects.video_game
object.ticks = false
object.build_cost = 200
object.build_preview_animation = 5106
object.idle_animations = {
  north = 3696,
  south = 3696,
}
-- There are only animations for the doctor and the nurse.
-- It seems the handyman doesn't play video games.
--
-- For the Doctor, there's an additional animation standing still.
-- Don't know how to use that one...

object.usage_animations = {
  north = {
    in_use = {
      Doctor   = 3700, -- also 3692, standing still in front of the game
      Nurse    = 4764,
    },
  },
  south = { -- duplicate of north
    in_use = {
      Doctor   = 3700,
      Nurse    = 4764,
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
    footprint = { {0, 0}, {1, 0, only_passable = true} },
    early_list_while_in_use = true,
    use_position = "passable",
    use_animate_from_use_position = true,
  },
}

return object
