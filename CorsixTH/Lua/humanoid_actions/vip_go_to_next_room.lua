--[[ Copyright (c) 2012 Edvin "Lego3" Linge

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

class "VipGoToNextRoomAction" (HumanoidAction)

---@type VipGoToNextRoomAction
local VipGoToNextRoomAction = _G["VipGoToNextRoomAction"]

function VipGoToNextRoomAction:VipGoToNextRoomAction()
  self:HumanoidAction("vip_go_to_next_room")
end

local action_vip_go_to_next_room_end = permanent"action_next_room_end"( function(humanoid)
  humanoid:finishAction()
end)

local function action_vip_go_to_next_room_start(action, humanoid)
  if humanoid.next_room_no == nil then
    -- This vip is done here.
    humanoid:goHome()
  else
    -- Walk to the entrance of the room and stay there for a while.
    local x, y = humanoid.next_room:getEntranceXY()
    local callback = --[[persistable:vip_next_room_enroute_cancel]] function()
      humanoid:setNextAction(IdleAction())
      humanoid.waiting = 1
    end
    humanoid:queueAction(WalkAction(x, y))
    -- What happens if the room disappears:
    humanoid.next_room.humanoids_enroute[humanoid] = {callback = callback}

    -- Evaluation function
    local --[[persistable:vip_next_room_eval]] function evaluate()
      -- First remove the VIP from the humanoids_enroute list.
      humanoid.next_room.humanoids_enroute[humanoid] = nil
      --humanoid.next_room.door.reserved_for = humanoid
      humanoid:evaluateRoom()
      humanoid.waiting = 3
    end
    -- Find direction to look at
    local ix, iy = humanoid.next_room:getEntranceXY(true)
    local dir = "north"
    if iy > y then
      dir = "south"
    elseif iy == y then
      if ix < x then
        dir = "west"
      else
        dir = "east"
      end
    end
    humanoid:queueAction(IdleAction():setLoopCallback(evaluate):setDirection(dir))

    -- Finish this action and start the above sequence.
    humanoid:finishAction()
  end
end

return action_vip_go_to_next_room_start
