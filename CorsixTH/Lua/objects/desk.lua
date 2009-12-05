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
object.id = "desk"
object.thob = 1
object.name = _S(2, 2)
object.ticks = false
object.build_cost = 0
object.build_preview_animation = 900
object.idle_animations = {
  north = 48,
  east = 50,
}
object.usage_animations = {
  north = {
    begin_use = {
      Doctor =   56,
      Nurse  = 3240,
    },
    in_use = {
      -- Note: 72 (normal usage) should happen alot more often than 718 (head
      -- scratching), hence it appears in the list many times.
      Doctor = {72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 718},
      Nurse  = 3256,
    },
    finish_use = {
      Doctor =   64,
      Nurse  = 3248,
    },
  },
  east = {
    begin_use = {
      Doctor =   58,
      Nurse  = 3242,
    },
    in_use = {
      Doctor =   74, -- No analogue to 718 :(
      Nurse  = 3258,
    },
    finish_use = {
      Doctor =   66,
      Nurse  = 3250,
    },
  },
}
object.orientations = {
  north = {
    footprint = { {-2, -1}, {-1, -1}, {-1, 0}, {0, -1}, {0, 0, only_passable = true} },
    render_attach_position = {0, -1},
    use_position = "passable",
  },
  east = {
    footprint = { {0, -2}, {-1, -1}, {0, -1}, {-1, 0, only_passable = true}, {0, 0} , {-1, -2, only_passable = true}},
    render_attach_position = {0, -1},
    use_position = {-1, 0},
    finish_use_position = {-1, -2},
  },
  south = {
    footprint = { {0, -1, only_passable = true}, {-2, 0}, {-1, -1}, {-1, 0}, {0, 0}, {-2, -1, only_passable = true} },
    render_attach_position = {-2, 0},
    use_position = {0, -1},
    finish_use_position = {-2, -1},
  },
  west = {
    footprint = { {-1, -2}, {0, 0, only_passable = true}, {-1, -1}, {0, -1}, {-1, 0} },
    render_attach_position = {-1, 0},
    use_position = "passable",
  },
}

return object
