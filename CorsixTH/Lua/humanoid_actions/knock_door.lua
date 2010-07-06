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

--! Have a `Humanoid` knock on a `Door`.
class "KnockDoorAction" {} (Action)

--!param ... Arguments for the base class constructor.
function KnockDoorAction:KnockDoorAction(...)
  self:Action(...)
end

function KnockDoorAction:canRemoveFromQueue(is_high_priority)
  return (not self.is_active or is_high_priority) and
    Action.canRemoveFromQueue(self, is_high_priority)
end

function KnockDoorAction:truncate(is_high_priority)
  if is_high_priority then
    self.humanoid:callTimer()
  end
end

function KnockDoorAction:onFinish()
  local door = self.humanoid.user_of
  door:setUser(nil)
  self.humanoid.user_of = nil
  door:getRoom():tryAdvanceQueue()
  
  Action.onFinish(self)
end

function KnockDoorAction:onStart()
  Action.onStart(self)
  
  local humanoid = self.humanoid  
  local direction = self.direction
  local anims = humanoid.door_anims
  local door = self.door
  local anim = anims.knock_north
  local flag_mirror = (direction == "west" or direction == "south") and 1 or 0
  if direction == "east" or direction == "south" then
    anim = anims.knock_east
  end
  humanoid:setAnimation(anim, flag_mirror)
  humanoid:setTilePositionSpeed(humanoid.tile_x, humanoid.tile_y)
  humanoid:setTimer(humanoid.world:getAnimLength(anim), humanoid.finishAction)
  humanoid.user_of = door
  door:setUser(humanoid)
  door.th:makeVisible()
end

-- For compatibility
permanent"action_knock_door_tick"(function(humanoid)
  humanoid:finishAction()
end)
