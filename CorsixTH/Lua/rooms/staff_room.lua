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

local room = {}
room.id = "staff_room"
room.level_config_id = 25
room.class = "StaffRoom"
room.name = _S.rooms_short.staffroom
room.tooltip = _S.tooltip.rooms.staffroom
room.objects_additional = { "extinguisher", "radiator", "plant", "sofa", "pool_table", "tv", "video_game" }
room.objects_needed = { sofa = 1 }
room.build_preview_animation = 5066
room.categories = {
  facilities = 1,
}
room.minimum_size = 4
room.wall_type = "green"
room.floor_tile = 17
room.has_no_queue_dialog = true

class "StaffRoom" (Room)

function StaffRoom:StaffRoom(...)
  self:Room(...)
end

function StaffRoom:onHumanoidEnter(humanoid)
  self.humanoids[humanoid] = true
  self:tryAdvanceQueue()
  humanoid:setDynamicInfoText("")
  if class.is(humanoid, Staff) then
    -- Receptionists cannot enter, so we do not have to worry about them
    -- If it is a handyman and he is here to do a job, let him pass
    if not humanoid.on_call then
      humanoid:setNextAction({name = "use_staffroom"})
      self.door.queue.visitor_count = self.door.queue.visitor_count + 1
    end
  else
    -- Other humanoids shouldn't be entering, so don't worry about them
  end
end

function StaffRoom:testStaffCriteria(criteria, extra_humanoid)
  -- The staff room always accept more tired staff members.
  if extra_humanoid then
    return true
  else
    return false
  end
end

return room
