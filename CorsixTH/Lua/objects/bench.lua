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
object.id = "bench"
object.class = "Bench"
object.thob = 4
object.name = _S.object.bench
object.tooltip = _S.tooltip.objects.bench
object.ticks = false
object.corridor_object = 2
object.build_cost = 40
object.build_preview_animation = 902
object.dynamic_info = true
object.idle_animations = {
  north = 112,
  east  = 114,
}
object.walk_in_to_use = true
object.usage_animations = {
  north = {
    begin_use = {
      ["Standard Male Patient"     ] =   96,
      ["Standard Female Patient"   ] =  232,
      ["Slack Female Patient"      ] =  232,
      ["Transparent Male Patient"  ] = 1080,
      ["Slack Male Patient"        ] = 1500,
      ["Invisible Patient"         ] = 1812,
      ["Alternate Male Patient"    ] = 2732,
      ["Transparent Female Patient"] = 3028,
      ["Elvis Patient"             ] = 3642,
      ["Chewbacca Patient"         ] = 3744,
      ["Alien Male Patient"        ] =   96, -- TEMP
      ["Alien Female Patient"      ] =  232, -- TEMP
    },
    in_use = {
      ["Standard Male Patient"     ] =  146,
      ["Standard Female Patient"   ] =  224,
      ["Slack Female Patient"      ] =  224,
      ["Transparent Male Patient"  ] = 1088,
      ["Slack Male Patient"        ] = 1508,
      ["Invisible Patient"         ] = 1820,
      ["Alternate Male Patient"    ] = 2724,
      ["Transparent Female Patient"] = 3036,
      ["Chewbacca Patient"         ] = 3760,
      ["Elvis Patient"             ] = 4110,
      ["Alien Male Patient"        ] =  146, -- TEMP
      ["Alien Female Patient"      ] =  224, -- TEMP
    },
    finish_use = {
      ["Standard Male Patient"     ] =  216,
      ["Standard Female Patient"   ] =  240,
      ["Slack Female Patient"      ] =  240,
      ["Transparent Male Patient"  ] = 1096,
      ["Slack Male Patient"        ] = 1516,
      ["Invisible Patient"         ] = 1828,
      ["Alternate Male Patient"    ] = 2740,
      ["Transparent Female Patient"] = 3044,
      ["Chewbacca Patient"         ] = 3752,
      ["Elvis Patient"             ] = 4102,
      ["Alien Male Patient"        ] =  216, -- TEMP
      ["Alien Female Patient"      ] =  240, -- TEMP
    },
  },
  east = {
    begin_use = {
      ["Standard Male Patient"     ] =   98,
      ["Standard Female Patient"   ] =  234,
      ["Transparent Male Patient"  ] = 1082,
      ["Slack Female Patient"      ] =  234,
      ["Slack Male Patient"        ] = 1502,
      ["Invisible Patient"         ] = 1814,
      ["Alternate Male Patient"    ] = 2734,
      ["Transparent Female Patient"] = 3030,
      ["Elvis Patient"             ] = 3644,
      ["Chewbacca Patient"         ] = 3746,
      ["Alien Male Patient"        ] =   98, -- TEMP
      ["Alien Female Patient"      ] =  234, -- TEMP
    },
    in_use = {
      ["Standard Male Patient"     ] =  148,
      ["Standard Female Patient"   ] =  226,
      ["Slack Female Patient"      ] =  226,
      ["Transparent Male Patient"  ] = 1090,
      ["Slack Male Patient"        ] = 1510,
      ["Invisible Patient"         ] = 1822,
      ["Alternate Male Patient"    ] = 2726,
      ["Transparent Female Patient"] = 3038,
      ["Chewbacca Patient"         ] = 3762,
      ["Elvis Patient"             ] = 4112,
      ["Alien Male Patient"        ] =  148, -- TEMP
      ["Alien Female Patient"      ] =  226, -- TEMP
    },
    finish_use = {
      ["Standard Male Patient"     ] =  218,
      ["Standard Female Patient"   ] =  242,
      ["Slack Female Patient"      ] =  242,
      ["Transparent Male Patient"  ] = 1098,
      ["Slack Male Patient"        ] = 1518,
      ["Invisible Patient"         ] = 1830,
      ["Alternate Male Patient"    ] = 2742,
      ["Transparent Female Patient"] = 3046,
      ["Chewbacca Patient"         ] = 3754,
      ["Elvis Patient"             ] = 4104,
      ["Alien Male Patient"        ] =  218, -- TEMP
      ["Alien Female Patient"      ] =  242, -- TEMP
    },
  },
}
object.orientations = {
  north = {
    render_attach_position = { {0, 0}, {-1, 0}, {0, -1} },
    footprint = { {0, 0}, {0, -1, only_passable = true, invisible = true} },
    use_position = "passable",
  },
  east = {
    footprint = { {0, 0}, {1, 0, only_passable = true, invisible = true} },
    use_position = "passable",
  },
  south = {
    footprint = { {0, 0}, {0, 1, only_passable = true, invisible = true} },
    use_position = "passable",
  },
  west = {
    footprint = { {0, 0}, {-1, 0, only_passable = true, invisible = true} },
    use_position = "passable",
  },
}

class "Bench" (Object)

function Bench:Bench(...)
  self:Object(...)
end

--Called when the patient sits up from a bench for whatever reason
--Maybe related to Humanoid:removedObject(object)
function Bench:removeUser(user)
  if user then
    local has_idle = false
    for i, action in pairs(user.action_queue) do
      if action.name == "idle" then
        has_idle = true
      end
    end

    -- patient must idle && action:isStanding() == true at this point
    if has_idle == true then
      user:notifyNewObject("bench")
    end
  end

  return Object.removeUser(self, user)
end

--Called when the player picks up a bench
function Bench:onDestroy()
  -- make sure that action:isStanding() will be true, see issue 404
  if self.user then
    for i, action in pairs(self.user.action_queue) do
      if action.name == "queue" then
       self.user.action_queue[i].current_bench_distance = nil
      end
    end
  end

  -- if patient is heading for the destroyed bench then do the same
  -- things as if they were sitting on it 
  if self.reserved_for ~= nil then
    self.reserved_for:handleRemovedObject(self)
    self:removeUser(self.reserved_for)
  end

  
  Object.onDestroy(self)
end

return object
