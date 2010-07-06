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

--! Direct a `Patient` toward a bathroom.
class "SeekToiletsAction" {} (Action)

--!param ... Arguments for the base class constructor.
function SeekToiletsAction:SeekToiletsAction(...)
  self:Action(...)
end

function SeekToiletsAction:onRemoveFromQueue()
  humanoid.going_to_toilet = nil
  
  Action.onRemoveFromQueue(self)
end

function SeekToiletsAction:onStart()
  local action = self
  local humanoid = self.humanoid
  
  -- Go to the nearest toilet, if any is found.
  local room = humanoid.world:findRoomNear(humanoid, "toilets", nil, "advanced")
  if room then
    local task = room:createEnterAction()
    -- TODO: Queue instead?
    humanoid:setNextAction(task)
    -- TODO: next_room_to_visit??
    --[[
    -- Unexpect the patient from a possible destination room.
    if humanoid.next_room_to_visit then
      local queue = humanoid.next_room_to_visit.door.queue
      if queue then
        queue:unexpect(humanoid)
      end
      humanoid:updateDynamicInfo("")
    end
    --]]
    if self.is_active then
      humanoid:finishAction()
    end
  else
    -- This should happen only in rare cases, e.g. if the target toilet room was removed while heading there and none other exists
    print("No toilet found in seek_toilets action")
    humanoid:finishAction()
  end
end
