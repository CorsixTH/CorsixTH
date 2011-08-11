--[[ Copyright (c) 2011 Edvin "Lego3" Linge

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

-- Set markers for all animations involved.
local animation_numbers = {
  1874,
  1878,
}
TheApp.animation_manager:setMarker(animation_numbers, {-1.05, -0.05})

local finish = permanent"action_sweep_floor_finish"( function(humanoid)
  humanoid:finishAction()
end)

local remove_litter = permanent"action_sweep_floor_remove_litter"( function(humanoid)
  humanoid.world:removeObjectFromTile(humanoid.user_of, humanoid.tile_x, humanoid.tile_y)
  humanoid.world.map.th:setCellFlags(humanoid.tile_x, humanoid.tile_y, {buildable = true})
  humanoid.user_of:setTile(nil)
  humanoid.user_of = nil
  humanoid:setTimer(humanoid.world:getAnimLength(animation_numbers[2]) * 2, finish)
end)

local sweep = permanent"action_sweep_floor_sweep"( function(humanoid)
  local anim = animation_numbers[2]
  humanoid:setAnimation(anim)
  humanoid:setTimer(humanoid.world:getAnimLength(anim) * 2, remove_litter)
end)

local function action_sweep_floor_start(action, humanoid)
  action.must_happen = true
  humanoid.user_of = action.litter
  local anim = animation_numbers[1]
  humanoid:setAnimation(anim)
  humanoid:setTimer(humanoid.world:getAnimLength(anim), sweep)
end

return action_sweep_floor_start
