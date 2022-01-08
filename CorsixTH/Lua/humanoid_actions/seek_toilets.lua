--[[ Copyright (c) 2009 Edvin "Lego3" Linge
Based on seek_staffroom.lua by Manuel Wolf

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

class "SeekToiletsAction" (HumanoidAction)

---@type SeekToiletsAction
local SeekToiletsAction = _G["SeekToiletsAction"]

function SeekToiletsAction:SeekToiletsAction(humanoid)
  assert(class.is(humanoid, Humanoid), "Invalid value for parameter 'humanoid'")

  self:HumanoidAction("seek_toilets")
  self.humanoid = humanoid
end

function SeekToiletsAction:start()
  -- Mechanism for clearing the going_to_toilets flag when this action is
  -- interrupted.
  if self.todo_interrupt then
    self.humanoid.going_to_toilet = "no"
    self.humanoid:finishAction()
    return
  end

  self.must_happen = true

  -- Go to the nearest toilet, if any is found.
  local room = self.humanoid.world:findRoomNear(self.humanoid, "toilets", nil, "advanced")
  if room then
    self.humanoid:setNextAction(room:createEnterAction(self.humanoid):setMustHappen(true))
    -- Unexpect the patient from a possible destination room.
    if self.humanoid.next_room_to_visit then
      local queue = self.humanoid.next_room_to_visit.door.queue
      if queue then
        queue:unexpect(self.humanoid)
      end
      self.humanoid:updateDynamicInfo("")
    end
    -- toilet door should reflect the expected count
    room.door:updateDynamicInfo()
    self.humanoid:finishAction()
  else
    -- This should happen only in rare cases, e.g. if the target toilet room was
    -- removed while heading there and none other exists. In that case, go back
    -- to the previous room or go to the reception.
    if self.humanoid.next_room_to_visit then
      self.humanoid:setNextAction(SeekRoomAction(self.humanoid.next_room_to_visit.room_info.id))
    else
      self.humanoid:queueAction(SeekReceptionAction(self.humanoid))
    end
    self.humanoid.going_to_toilet = "no"
    self.humanoid:finishAction()
  end
end

local function seek_toilets_action_start(action, humanoid)
  assert(humanoid == action.humanoid)
  action:start()
end

return seek_toilets_action_start
