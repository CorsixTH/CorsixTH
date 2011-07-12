--[[ Copyright (c) 2009 Darrell "redneon" Blake

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

local action_vomit_end = permanent"action_vomit_end"( function(humanoid)
  local litter = humanoid.world:newObject("litter", humanoid.tile_x, humanoid.tile_y)
  litter:setLitterType("puke", humanoid.last_move_direction == "south" and 0 or 1)  --For some reason the vomit is inverted.
  
  humanoid:finishAction()
end)

local function action_vomit_start(action, humanoid)
  if math.random(0, 1) == 1 then
    humanoid.last_move_direction = "east"
  else
    humanoid.last_move_direction = "south"
  end
  
  assert(humanoid.vomit_anim, "Error: no vomit animation for humanoid " .. humanoid.humanoid_class)
  action.must_happen = true
  humanoid:setAnimation(humanoid.vomit_anim, humanoid.last_move_direction == "east" and 0 or 1)
  humanoid:setTimer(humanoid.world:getAnimLength(humanoid.vomit_anim), action_vomit_end)
end

return action_vomit_start
