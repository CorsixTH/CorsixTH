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
object.id = "autopsy"
object.thob = 55
object.research_category = "cure"
object.name = _S.object.auto_autopsy
object.tooltip = _S.tooltip.objects.auto_autopsy
object.ticks = true
object.build_cost = 4000
object.build_preview_animation = 5102
object.crashed_animation = 3304

local function copy_north_to_south(t)
  t.south = t.north
  return t
end

object.idle_animations = copy_north_to_south {
  north = 2146,
}

object.usage_animations = copy_north_to_south {
  north = {
    in_use = {
      Handyman = 3566,
    },
  },
}

dofile "entities/humanoid"
object.multi_usage_animations = {}
local function anim_set(patient_type, invite_in, configure, taken_in, closing)
  local anims = {
    -- Machine door opens and bed comes out
    begin_use    = 2154,
    secondary = {
      begin_use = Humanoid.getIdleAnimation(patient_type),
    },
    -- Patient gets onto the bed
    begin_use_2  = invite_in,
    -- Doctor presses some buttons with patient on bed
    begin_use_3  = configure,
    -- Bed withdraws back into machine
    in_use       = taken_in,
    -- Machine door closes
    finish_use   = closing,
    -- Doctor stands by machine while it flashes
    finish_use_2 = 4010,
  }
  object.multi_usage_animations["Doctor - ".. patient_type] = {
    north = anims,
    south = anims,
  }
end
anim_set("Standard Male Patient"     , 2166, 3334, 4548, 4552)
anim_set("Standard Female Patient"   , 3196, 3200, 3188, 3192)
anim_set("Alternate Male Patient"    , 4544, 3334, 4548, 4552) -- Incomplete
anim_set("Chewbacca Patient"         , 4118, 4126, 4130, 4134)
anim_set("Elvis Patient"             , 4086, 4090, 4094, 4098)
anim_set("Slack Male Patient"        , 4332, 4336, 4340, 4552)
anim_set("Slack Female Patient"      , 3196, 3200, 3188, 3192) -- Incomplete
anim_set("Transparent Male Patient"  , 4460, 4856, 4456, 4626)
anim_set("Transparent Female Patient", 4860, 4804, 4796, 4800)
anim_set("Invisible Patient"         , 4212, 4224, 4216, 4220)

object.orientations = {
  north = {
    use_position_secondary = {-2, 1},
    use_position = {0, 1},
    handyman_position = {0, 1},
    footprint = {
      {-2, -1}, {-2, 0}, {-2, 1, only_passable = true},
      {-1, -1},  {-1, 0}, {-1, 1, only_passable = true},
      {0, -1}, {0, 0}, {0, 1, only_passable = true},
    },
    early_list = true,
  },
  east = {
    render_attach_position = {-1, 0},
    use_position_secondary = {1, -2},
    use_position = {1, 0},
    handyman_position = {1, 0},
    footprint = {
      {-1, -2}, {-1, -1}, {-1, 0},
      {0, -2}, {0, -1}, {0, 0},
      {1, -2, only_passable = true}, {1, -1, only_passable = true},
        {1, -0, only_passable = true},
    },
  },
}
local anim_mgr = TheApp.animation_manager
anim_mgr:setMarker(object.idle_animations.north, {0.0 , 0.0})

-- In (some versions of?) the original animations, 4086 has a builtin repeat,
-- which looks very wrong, hence trim it to the length of a similar animation.
anim_mgr:setAnimLength(4086, anim_mgr:getAnimLength(2166))

return object
