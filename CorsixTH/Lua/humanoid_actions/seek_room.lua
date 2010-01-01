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

local function action_seek_room_interrupt(action, humanoid)
  humanoid:setMood("patient_wait", nil)
  humanoid.world:unregisterRoomBuildCallback(action.build_callback)
  humanoid:finishAction()
end

local function action_seek_room_start(action, humanoid)
  local room = humanoid.world:findRoomNear(humanoid, action.room_type, nil, "advanced")
  if room then
    humanoid:setNextAction(room:createEnterAction())
    humanoid.next_room_to_visit = room.room_info.id
    room.door.queue:expect(humanoid)
    if not room:testStaffCriteria(room:getRequiredStaffCriteria()) then
      humanoid.world:callForStaff(room)
    end
  else
    -- TODO: Give user option of "wait in hospital" / "send home" / etc.
    if not action.done_init then
      action.done_init = true
      humanoid:setMood("patient_wait", true)
      action.must_happen = true
      action.build_callback = function(room)
        if room.room_info.id == action.room_type then
          humanoid:setNextAction(room:createEnterAction())
          humanoid.next_room_to_visit = room.room_info.id
        end
      end
      humanoid.world:registerRoomBuildCallback(action.build_callback)
      action.on_interrupt = action_seek_room_interrupt
    end
    if not action.done_walk then
      humanoid:queueAction({name = "meander", count = 1, must_happen = true}, 0)
      action.done_walk = true
      return
    else
      local direction = humanoid.last_move_direction
      local anims = humanoid.walk_anims
      if direction == "north" then
        humanoid:setAnimation(anims.idle_north, 0)
      elseif direction == "east" then
        humanoid:setAnimation(anims.idle_east, 0)
      elseif direction == "south" then
        humanoid:setAnimation(anims.idle_east, 1)
      elseif direction == "west" then
        humanoid:setAnimation(anims.idle_north, 1)
      end
      humanoid:setTilePositionSpeed(humanoid.tile_x, humanoid.tile_y)
    end
  end
end

return action_seek_room_start
