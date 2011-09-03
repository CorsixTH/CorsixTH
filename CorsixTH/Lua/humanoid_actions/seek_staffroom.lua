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

local function seek_staffroom_action_start(action, humanoid)
  -- Mechanism for clearing the going_to_staffroom flag when this action is
  -- interrupted (due to entering the staff room, being picked up, etc.)
  if action.todo_interrupt then
    humanoid.going_to_staffroom = nil
    humanoid:finishAction()
    return
  end
  action.must_happen = true
  -- Go to the nearest staff room, if any is found.
  local room = humanoid.world:findRoomNear(humanoid, "staff_room")
  if room then
    local task = room:createEnterAction()
    task.must_happen = true
    task.is_leaving = true
    humanoid:queueAction(task, 0)
    humanoid:setDynamicInfoText(_S.dynamic_info.staff.actions.heading_for:format(room.room_info.name))
  else
    -- This should happen only in rare cases, e.g. if the target staff room was removed while heading there and none other exists
    print("No staff room found in seek_staffroom action")
    humanoid.going_to_staffroom = nil
    humanoid:queueAction({name = "meander"})
    humanoid:finishAction()
  end
end

return seek_staffroom_action_start
