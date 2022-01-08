--[[ Copyright (c) 2009 Manuel Wolf

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

class "SeekStaffRoomAction" (HumanoidAction)

---@type SeekStaffRoomAction
local SeekStaffRoomAction = _G["SeekStaffRoomAction"]

function SeekStaffRoomAction:SeekStaffRoomAction(humanoid)
  assert(class.is(humanoid, Humanoid), "Invalid value for parameter 'humanoid'")

  self:HumanoidAction("seek_staffroom")
  self.humanoid = humanoid
  self:setMustHappen(true)
end

function SeekStaffRoomAction:start()
  -- Mechanism for clearing the going_to_staffroom flag when this action is
  -- interrupted (due to entering the staff room, being picked up, etc.)
  if self.todo_interrupt then
    self.humanoid.going_to_staffroom = nil
    self.humanoid:finishAction()
    return
  end

  self.must_happen = true
  -- Go to the nearest staff room, if any is found.
  local room = self.humanoid.world:findRoomNear(self.humanoid, "staff_room")
  if room then
    local task = room:createEnterAction(self.humanoid):setMustHappen(true):setIsLeaving(true)
    self.humanoid:queueAction(task, 0)
    self.humanoid:setDynamicInfoText(_S.dynamic_info.staff.actions.heading_for:format(room.room_info.name))
  else
    -- This should happen only in rare cases, e.g. if the target staff room was removed while heading there and none other exists
    print("No staff room found in seek_staffroom action")
    self.humanoid.going_to_staffroom = nil
    self.humanoid:queueAction(MeanderAction())
    self.humanoid:finishAction()
  end
end

local function seek_staffroom_action_start(action, humanoid)
  assert(humanoid == action.humanoid)
  action:start()
end

return seek_staffroom_action_start
