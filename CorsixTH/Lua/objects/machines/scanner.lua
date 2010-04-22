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
object.id = "scanner"
object.thob = 14
object.name = _S.object.scanner
object.tooltip = _S.tooltip.objects.scanner
object.ticks = false
object.build_cost = 5000
object.build_preview_animation = 920
object.default_strength = 12
object.crashed_animation = 3316
local function copy_north_to_south(t)
  t.south = t.north
  return t
end

object.idle_animations = copy_north_to_south {
  north = 1398,
}
object.usage_animations = copy_north_to_south { -- still incomplete
  north = {
    begin_use = { -- goes down
      ["Transparent Male Patient"] = 878,
      ["Chewbacca Patient"] = 1180,
      ["Stripped Male Patient"] = 1406,
      ["Stripped Female Patient"] = 1446,
      ["Elvis Patient"] = 4916,
      ["Transparent Female Patient"] = 4930,
      ["Invisible Patient"] = 4946,
      ["Alternate Male Patient"] = 4962,
      ["Slack Male Patient"] = 4978,
      -- additional female sprites 5158+
    },
    in_use = { -- stays down
      ["Transparent Male Patient"] = 886,
      ["Chewbacca Patient"] = 1188,
      ["Stripped Male Patient"] = 1410,
      ["Stripped Female Patient"] = 1450,
      ["Elvis Patient"] = 4924,
      ["Transparent Female Patient"] = 4938,
      ["Invisible Patient"] = 4954,
      ["Alternate Male Patient"] = 4970,
      ["Slack Male Patient"] = 4986,
      ["Handyman"] = 564,
    },
    finish_use = { -- goes up
      ["Transparent Male Patient"] = 882,
      ["Chewbacca Patient"] = 1184,
      ["Stripped Male Patient"] = 1414,
      ["Stripped Female Patient"] = 1454,
      ["Elvis Patient"] = 4920,
      ["Transparent Female Patient"] = 4934,
      ["Invisible Patient"] = 4950,
      ["Alternate Male Patient"] = 4966,
      ["Slack Male Patient"] = 4982,
    },
  },
}
object.orientations = {
  north = {
    use_position = {0, 0},
    footprint = { {-2, -1}, {-1, -1}, {0, -1}, {-2, 0}, {-1, 0},  {0, 0, only_passable = true} },
    render_attach_position = {0, -1},
  },
  east = {
    use_position = {0, 0},
    footprint = { {-1, -2} , {0, -2}, {-1, -1}, {0, -1}, {-1, 0}, {0, 0, only_passable = true} },
    render_attach_position = {-1, 0},
  },
}
local anim_mgr = TheApp.animation_manager
anim_mgr:setMarker(object.idle_animations.north, {-1.1, -1.1})

return object
