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
object.id = "sofa"
object.thob = 19
object.name = _S(2, 20)
object.ticks = false
object.build_cost = 250
object.build_preview_animation = 5066
object.idle_animations = {
  north = 2122,
  east = 2124,
}
object.usage_animations = {
  north = {
    begin_use = {
      Doctor   = 2178,
      Nurse    = 3878,
      Handyman = 3570,
    },
    begin_use_2 = {
      Doctor   = 2186,
      Nurse    = 3886,
      Handyman = 3578,
    },
    in_use = {
      Doctor   = 2208,
      Nurse    = 4780, -- also 4786, duplicate?
      Handyman = 4772,
    },
    finish_use = {
      Doctor   = 2194,
      Nurse    = 3894,
      Handyman = 3586,
    },
  },
  east = {
    begin_use = {
      Doctor   = 2180,
      Nurse    = 3880,
      Handyman = 3572,
    },
    begin_use_2 = {
      Doctor   = 2188,
      Nurse    = 3888,
      Handyman = 3580,
    },
    in_use = {
      Doctor   = 2210,
      Nurse    = 4782, -- also 4784, duplicate?
      Handyman = 4774, -- also 4776, duplicate?
    },
    finish_use = {
      Doctor   = 2196,
      Nurse    = 3896,
      Handyman = 3588,
    },
  },
}
object.orientations = {
  north = {
    footprint = { {-1, 0}, {0, 0}, {-1, -1, only_passable = true} },
    render_attach_position = {-1, 0},
    use_position = "passable",
  },
  east = {
    footprint = { {0, -1}, {0, 0}, {1, -1, only_passable = true} },
    use_position = "passable",
  },
  south = {
    footprint = { {-1, 0}, {0, 0}, {-1, 1, only_passable = true} },
    early_list = true,
    use_position = "passable",
  },
  west = {
    footprint = { {0, -1}, {0, 0}, {-1, -1, only_passable = true} },
    use_position = "passable",
  },
}

return object
