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

local action_knock_door_tick = permanent"action_knock_door_tick"( function(humanoid)
  local door = humanoid.user_of
  door:setUser(nil)
  humanoid.user_of = nil
  door:getRoom():tryAdvanceQueue()
  humanoid:finishAction()
end)

local function action_knock_door_start(action, humanoid)
  local direction = action.direction
  local anims = humanoid.door_anims
  local door = action.door
  action.must_happen = true
  local anim = anims.knock_north
  local flag_mirror = (direction == "west" or direction == "south") and 1 or 0
  if direction == "east" or direction == "south" then
    anim = anims.knock_east
  end
  humanoid:setAnimation(anim, flag_mirror)
  humanoid:setTilePositionSpeed(humanoid.tile_x, humanoid.tile_y)
  humanoid:setTimer(humanoid.world:getAnimLength(anim), action_knock_door_tick)
  humanoid.user_of = door
  door:setUser(humanoid)
  door.th:makeVisible()
end

return action_knock_door_start
