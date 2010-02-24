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
object.id = "pool_table"
object.thob = 10
object.name = _S.object.pool_table
object.tooltip = _S.tooltip.objects.pool_table
object.ticks = false
object.build_cost = 550
object.build_preview_animation = 5058
object.idle_animations = {
  north = 2130,
  south = 2130,
}
-- There are five animations, for each the doctor and the handyman.
-- The nurses don't like pool, appearently.
-- 
-- anim      | doctor | handyman
-- -----------------------------
-- aim       |  1230  |   3924
-- shoot     |  1234  |   3928
-- chalk     |  1238  |   3932
-- take cue  |  1244  |   3936
-- leave cue |  1248  |   3940
--
-- the playing procedure is: take cue, chalk, aim, shoot, leave cue

object.usage_animations = {
  north = {
    begin_use = {
      Doctor   = 1244,
      Handyman = 3936,
    },
    begin_use_2 = {
      Doctor   = 1238,
      Handyman = 3932,
    },
    begin_use_3 = {
      Doctor   = 1230,
      Handyman = 3924,
    },
    in_use = {
      Doctor   = 1234,
      Handyman = 3928,
    },
    finish_use = {
      Doctor   = 1248,
      Handyman = 3940,
    },
  },
  south = { -- duplicate of north
    begin_use = {
      Doctor   = 1244,
      Handyman = 3936,
    },
    begin_use_2 = {
      Doctor   = 1238,
      Handyman = 3932,
    },
    begin_use_3 = {
      Doctor   = 1230,
      Handyman = 3924,
    },
    in_use = {
      Doctor   = 1234,
      Handyman = 3928,
    },
    finish_use = {
      Doctor   = 1248,
      Handyman = 3940,
    },
  },
}

object.orientations = {
  north = {
    footprint = { {-1, -2, only_passable = true}, {0, -2},                       {1, -2, only_passable = true},
                  {-1, -1, only_passable = true}, {0, -1},                       {1, -1, only_passable = true},
                  {-1,  0, only_passable = true}, {0,  0, only_passable = true}, {1,  0, only_passable = true} },
    render_attach_position = {-1, 0},
    use_position = {0, 0},
  },
  east = {
    footprint = {{-2, -1, only_passable = true}, {-1, -1, only_passable = true}, {0, -1, only_passable = true},
                 {-2,  0},                       {-1,  0},                       {0,  0, only_passable = true},
                 {-2,  1, only_passable = true}, {-1,  1, only_passable = true}, {0,  1, only_passable = true} },
    render_attach_position = {0, -1},
    use_position = {0, 0},
  },
}

return object
