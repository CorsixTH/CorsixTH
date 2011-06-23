--[[ Copyright (c) 2011 Manuel "Roujin" Wolf

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
object.id = "dna_fixer"
object.thob = 23
object.research_fallback = 8
object.research_category = "cure"
object.name = _S.object.dna_fixer
object.tooltip = _S.tooltip.objects.dna_fixer
object.ticks = false
object.build_cost = 10000
object.build_preview_animation = 5070
object.default_strength = 7
object.crashed_animation = 3376 -- TODO correct?
local function copy_north_to_south(t)
  t.south = t.north
  return t
end

-- 2350 another idle?
-- 3848, 3850, 3852 sparks during transformation?
-- TODO: No repair animation??
object.idle_animations = copy_north_to_south {
  north = 3840,
}
object.usage_animations = copy_north_to_south {
  north = { -- NB: SOME (not all) of the animations are provided for east rather than north. There the mirror / mirror_morph flag is used.
    begin_use = {
      ["Standard Female Patient"] = 3614,
      ["Standard Male Patient"  ] = 3614,
    },
    in_use = { -- TODO fix the object being displayed in front of the other anim
      ["Standard Female Patient"] = {"morph", 3594, 1150, mirror_morph = true, object_visible = true, length = 10}, -- 3594 (normal) morph to 1150 (mirrored)
      ["Standard Male Patient"  ] = {"morph", 3594, 3618, mirror_morph = true, object_visible = true, length = 10}, -- 3594 (normal) morph to 3618 (mirrored)
    },
    finish_use = { -- Patient leaves machine, mirrored
      ["Standard Female Patient"] = {1154, mirror = true},
      ["Standard Male Patient"  ] = {3622, mirror = true},
    },
  },
}

object.orientations = {
  north = {
    footprint = { {-2, -1}, {-1, -1}, {0, -1},
                  {-2,  0}, {-1,  0}, {0,  0},
                  {-1,  1, only_passable = true} },
    use_position = "passable",
    early_list = true,
  },
  east = {
    footprint = { {-1,  -2}, {0,  -2}, 
                  {-1,  -1}, {0,  -1},
                  {-1,  0}, {0,  0},
                  {1,  -1, only_passable = true} },
    use_position = "passable",
  },
}

-- TODO
--local anim_mgr = TheApp.animation_manager
--anim_mgr:setMarker(object.idle_animations.north, {-1.3, -1.2})

return object
