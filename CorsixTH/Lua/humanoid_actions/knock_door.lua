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

class "KnockDoorAction" (HumanoidAction)

---@type KnockDoorAction
local KnockDoorAction = _G["KnockDoorAction"]

--! Constructor for knocking on the door action.
--!param door (Object) Door to knock on.
--!param direction (string) Direction of facing.
function KnockDoorAction:KnockDoorAction(humanoid, door, direction)
  assert(class.is(humanoid, Humanoid), "Invalid value for parameter 'humanoid'")
  assert(class.is(door, Door), "Invalid value for parameter 'door'")
  assert(direction == "north" or direction == "south" or
      direction == "east" or direction == "west",
      "Invalid value for parameter 'direction'")

  self:HumanoidAction("knock_door")
  self.humanoid = humanoid
  self.door = door -- Door to knock on.
  self.direction = direction -- Direction of facing.
  self.state = nil -- Next step in the animation.
end

function KnockDoorAction:start()
  self.state = 0
  self:update()
end


local function action_knock_door_start(action, humanoid)
  assert(humanoid == action.humanoid)
  action:start()
end

local action_knock_door_tick = permanent"action_knock_door_tick"( function(humanoid)
  local action = humanoid:getCurrentAction()
  action:update()
end)


function KnockDoorAction:update()
  if self.state == 0 then
    local direction = self.direction
    local anims = self.humanoid.door_anims
    local door = self.door
    self.must_happen = true
    local anim = anims.knock_north
    local flag_mirror = (direction == "west" or direction == "south") and 1 or 0
    if direction == "east" or direction == "south" then
      anim = anims.knock_east
    end
    self.humanoid:setAnimation(anim, flag_mirror)
    self.humanoid:setTilePositionSpeed(self.humanoid.tile_x, self.humanoid.tile_y)
    self.humanoid:setTimer(TheApp.animation_manager:getAnimLength(anim), action_knock_door_tick)
    self.humanoid.user_of = door
    door:setUser(self.humanoid)
    door.th:makeVisible()

    self.state = 1
    return

  elseif self.state == 1 then
    local door = self.humanoid.user_of
    door:removeUser(self.humanoid)
    self.humanoid.user_of = nil
    door:getRoom():tryAdvanceQueue()
    self.humanoid:finishAction()

    self.state = nil
    return
  end

  error("Illegal state " .. tostring(self.state) .. " in KnockDoorAction:update")
end

return action_knock_door_start
