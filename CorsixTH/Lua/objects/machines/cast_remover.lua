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
object.id = "cast_remover"
object.thob = 24
object.research_category = "cure"
object.research_fallback = 9
object.name = _S.object.cast_remover
object.tooltip = _S.tooltip.objects.cast_remover
object.ticks = false
object.build_cost = 2000
object.build_preview_animation = 5072
object.default_strength = 10
object.crashed_animation = 3388
local function copy_north_to_south(t)
  t.south = t.north
  return t
end
object.idle_animations = copy_north_to_south {
  north = 2492,
}
object.walk_in_to_use = true -- This is only considered by use_object, not multi_use_object. 
object.usage_animations = copy_north_to_south {
  north = {
    in_use  = {["Handyman"] = 3514},
  },
}
object.multi_usage_animations = {
  ["Alternate Male Patient - Nurse"] = copy_north_to_south {
    north = {
      begin_use    = 2720, -- Patient invited onto machine
      begin_use_2  = 2696, -- Machine closes
      begin_use_3  = 2692, -- Nurse introduces the almighty black bucket
      in_use       = 2688, -- The machine spits in the bucket
      finish_use   = 3662,  -- Nurse takes the bucket again (different tile than 3658!)
      finish_use_2 = 3658, -- The machine opens and the patient stands up
    },
  },
  ["Standard Female Patient - Nurse"] = copy_north_to_south {
    north = {
      begin_use    = 4658, -- Patient invited onto machine
      begin_use_2  = 4666, -- Machine closes
      begin_use_3  = 4670, -- Nurse introduces the almighty black bucket
      in_use       = 4674, -- The machine spits in the bucket
      finish_use   = 5112,  -- Nurse takes the bucket again
      finish_use_2 = 4682, -- The machine opens up and patient leaves
    },
  },
}

object.orientations = {
  north = {
    use_position = {0, 0},
    handyman_position = {{0, -2}, {-1, -1}},
    walk_in_tile = {0, -1},
    use_position_secondary = {0, -1},
    finish_use_position_secondary = {1, -1},
    footprint = { {-1, -1}, {0, -1, only_passable = true}, {1, -1, only_passable = true},
                  {-1, 0}, {0, 0, only_passable = true}, {-1, 1, only_passable = true}, 
                  {-1, -2, only_passable = true, invisible = true, optional = true}, 
                  {-2, -1, only_passable = true, invisible = true, optional = true} },
    list_bottom = true,
    render_attach_position = {-1, 1},
  },
  east = {
    use_position = {0, 0},
    handyman_position = {{-1, -1}, {-2, 0}},
    walk_in_tile = {-1, 0},
    use_position_secondary = {-1, 0},
    finish_use_position_secondary = {-1, 1},
    footprint = { {-1, -1}, {0, -1}, {1, -1, only_passable = true},
                  {-1, 0, only_passable = true}, {0, 0, only_passable = true},
                  {-1, 1, only_passable = true},
                  {-2, -1, only_passable = true, invisible = true, optional = true}, 
                  {-1, -2, only_passable = true, invisible = true, optional = true} },
    early_list = true,
    list_bottom = true,
  },
}
local anim_mgr = TheApp.animation_manager
anim_mgr:setMarker(object.idle_animations.north, {-1.6, -0.8})

return object
