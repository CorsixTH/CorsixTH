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
object.name = _S.object.desk
object.tooltip = _S.tooltip.objects.desk
object.ticks = false
object.build_cost = 100
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
local anim_mgr = TheApp.animation_manager
local kf1, kf2, kf3 = {0, 0}, {-1, -0.3}, {-0.9, -0.1}
anim_mgr:setMarker(  56, 0, kf1, 10, kf2, 13, kf3)
anim_mgr:setMarker(3240, 0, kf1, 10, kf2, 13, kf3)
anim_mgr:setMarker(  72, kf3)
anim_mgr:setMarker( 718, kf3)
anim_mgr:setMarker(3256, kf3)
anim_mgr:setMarker(  64, 0, kf3, 3, kf2, 12, kf1)
anim_mgr:setMarker(3248, 0, kf3, 3, kf2, 12, kf1)
kf1, kf2, kf3 = {-1, 0}, {-1, -1.1}, {-0.8, -0.9}
anim_mgr:setMarker(  58, 0, kf1, 9, kf2, 11, kf3)
anim_mgr:setMarker(3242, 0, kf1, 9, kf2, 11, kf3)
kf1 = {-0.7, -1}
anim_mgr:setMarker(  74, kf1)
anim_mgr:setMarker(3258, kf1)
kf2, kf1 = {-0.8, -1}, {-1, -2}
anim_mgr:setMarker(  66, 0, kf3, 3, kf2, 8, kf1)
anim_mgr:setMarker(3250, 0, kf3, 3, kf2, 8, kf1)

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
