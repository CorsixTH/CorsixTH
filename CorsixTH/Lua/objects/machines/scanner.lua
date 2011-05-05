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
object.research_category = "diagnosis"
object.research_fallback = 36
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
 --[[This is incomplete as the scanner and console should be in sync with each other
 i.e. Dr sits down and pushes some buttons and the scanner scans, the he pushes the lever and it
 will tip back etc.]]
object.usage_animations = copy_north_to_south { 
  north = {
    begin_use = { -- goes down
      ["Transparent Male Patient"] = 874,
      ["Chewbacca Patient"] = 1176,
      ["Stripped Male Patient"] = 1402,
      ["Stripped Female Patient"] = 1442,
      ["Stripped Male Patient 2"] = 1406,
      ["Stripped Female Patient 2"] = 1446,
      ["Stripped Male Patient 3"] = 1402,
      ["Stripped Female Patient 3"] = 1442,      
      ["Elvis Patient"] = 4914,
      ["Transparent Female Patient"] = 4926,
      ["Invisible Patient"] = 4942,
      ["Alternate Male Patient"] = 4958,
      ["Slack Male Patient"] = 4974,
      ["Slack Female Patient"] = 5158,
    },
    begin_use_2 = { -- stays down
      ["Transparent Male Patient"] = 874,
      ["Chewbacca Patient"] = 1176,
      ["Stripped Male Patient"] = 1402,
      ["Stripped Female Patient"] = 1442,
      ["Stripped Male Patient 2"] = 1410,
      ["Stripped Female Patient 2"] = 1450,
      ["Stripped Male Patient 3"] = 1402,
      ["Stripped Female Patient 3"] = 1442,      
      ["Elvis Patient"] = 4914,
      ["Transparent Female Patient"] = 4926,
      ["Invisible Patient"] = 4942,
      ["Alternate Male Patient"] = 4958,
      ["Slack Male Patient"] = 4974,
      ["Slack Female Patient"] = 5158,
      ["Handyman"] = 564,
    },
    begin_use_3 = { -- goes up
      ["Transparent Male Patient"] = 878,
      ["Chewbacca Patient"] = 1180,
      ["Stripped Male Patient"] = 1406,
      ["Stripped Female Patient"] = 1446,
      ["Stripped Male Patient 2"] = 1414,
      ["Stripped Female Patient 2"] = 1454,
      ["Stripped Male Patient 3"] = 1418,
      ["Stripped Female Patient 3"] = 1458,      
      ["Elvis Patient"] = 4916,
      ["Transparent Female Patient"] = 4930,
      ["Invisible Patient"] = 4946,
      ["Alternate Male Patient"] = 4962,
      ["Slack Male Patient"] = 4978,
      ["Slack Female Patient"] = 5162,
    },
    begin_use_4 = { -- stays up
      ["Transparent Male Patient"] = 886,
      ["Chewbacca Patient"] = 1188,
      ["Stripped Male Patient"] = 1410,
      ["Stripped Female Patient"] = 1450,
      ["Stripped Male Patient 2"] = 1402,
      ["Stripped Female Patient 2"] = 1442,
      ["Stripped Male Patient 3"] = 1422,
      ["Stripped Female Patient 3"] = 1462,
      ["Elvis Patient"] = 4922,
      ["Transparent Female Patient"] = 4938,
      ["Invisible Patient"] = 4954,
      ["Alternate Male Patient"] = 4970,
      ["Slack Male Patient"] = 4986,
      ["Slack Female Patient"] = 5166,
    },
    begin_use_5 = { -- goes down/go back
      ["Transparent Male Patient"] = 882,
      ["Chewbacca Patient"] = 1184,
      ["Stripped Male Patient"] = 1414,
      ["Stripped Female Patient"] = 1454,
      ["Stripped Male Patient 2"] = 1418,
      ["Stripped Female Patient 2"] = 1458,
      ["Stripped Male Patient 3"] = 1426,
      ["Stripped Female Patient 3"] = 1466,
      ["Elvis Patient"] = 4918,
      ["Transparent Female Patient"] = 4934,
      ["Invisible Patient"] = 4950,
      ["Alternate Male Patient"] = 4966,
      ["Slack Male Patient"] = 4982,
      ["Slack Female Patient"] = 5170,
    },
    finish_use = { -- stays down/stay back
      ["Transparent Male Patient"] = 874,
      ["Chewbacca Patient"] = 1176,
      ["Stripped Male Patient"] = 1402,
      ["Stripped Female Patient"] = 1442,
      ["Stripped Male Patient 2"] = 1422,
      ["Stripped Female Patient 2"] = 1462,
      ["Stripped Male Patient 3"] = 1430,
      ["Stripped Female Patient 3"] = 1470,
      ["Elvis Patient"] = 4914,
      ["Transparent Female Patient"] = 4926,
      ["Invisible Patient"] = 4942,
      ["Alternate Male Patient"] = 4958,
      ["Slack Male Patient"] = 4974,
      ["Slack Female Patient"] = 5158,
    },
    finish_use_2 = { -- goes up/forwards scan
      ["Transparent Male Patient"] = 878,
      ["Chewbacca Patient"] = 1180,
      ["Stripped Male Patient"] = 1406,
      ["Stripped Female Patient"] = 1446,
      ["Stripped Male Patient 2"] = 1426,
      ["Stripped Female Patient 2"] = 1466,
      ["Stripped Male Patient 3"] = 1434,
      ["Stripped Female Patient 3"] = 1474,
      ["Elvis Patient"] = 4916,
      ["Transparent Female Patient"] = 4930,
      ["Invisible Patient"] = 4946,
      ["Alternate Male Patient"] = 4962,
      ["Slack Male Patient"] = 4978,
      ["Slack Female Patient"] = 5162,
    },
    finish_use_3 = { -- goes down/stay forwards
      ["Transparent Male Patient"] = 886,
      ["Chewbacca Patient"] = 1188,
      ["Stripped Male Patient"] = 1410,
      ["Stripped Female Patient"] = 1450,
      ["Stripped Male Patient 2"] = 1430,
      ["Stripped Female Patient 2"] = 1470,
      ["Stripped Male Patient 3"] = 1422,
      ["Stripped Female Patient 3"] = 1462,
      ["Elvis Patient"] = 4922,
      ["Transparent Female Patient"] = 4938,
      ["Invisible Patient"] = 4954,
      ["Alternate Male Patient"] = 4970,
      ["Slack Male Patient"] = 4986,
      ["Slack Female Patient"] = 5166,
    },
    finish_use_4 = { -- stays down/reverse scan
      ["Transparent Male Patient"] = 882,
      ["Chewbacca Patient"] = 1184,
      ["Stripped Male Patient"] = 1414,
      ["Stripped Female Patient"] = 1454,
      ["Stripped Male Patient 2"] = 1434,
      ["Stripped Female Patient 2"] = 1474,
      ["Stripped Male Patient 3"] = 1422,
      ["Stripped Female Patient 3"] = 1462,
      ["Elvis Patient"] = 4918,
      ["Transparent Female Patient"] = 4934,
      ["Invisible Patient"] = 4950,
      ["Alternate Male Patient"] = 4966,
      ["Slack Male Patient"] = 4982,
      ["Slack Female Patient"] = 5170,
    },
    finish_use_5 = { -- goes up/tips forward
      ["Transparent Male Patient"] = 874,
      ["Chewbacca Patient"] = 1176,
      ["Stripped Male Patient"] = 1402,
      ["Stripped Female Patient"] = 1442,
      ["Stripped Male Patient 2"] = 1438,
      ["Stripped Female Patient 2"] = 1478,
      ["Stripped Male Patient 3"] = 1438,
      ["Stripped Female Patient 3"] = 1478,
      ["Elvis Patient"] = 4914,
      ["Transparent Female Patient"] = 4926,
      ["Invisible Patient"] = 4942,
      ["Alternate Male Patient"] = 4958,
      ["Slack Male Patient"] = 4974,
      ["Slack Female Patient"] = 5158,
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
