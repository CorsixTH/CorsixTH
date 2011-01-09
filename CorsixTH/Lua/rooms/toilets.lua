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
room.id = "toilets"
room.level_config_id = 29
room.class = "ToiletRoom"
room.name = _S.rooms_short.toilets
room.tooltip = _S.tooltip.rooms.toilets
room.objects_additional = { "extinguisher", "radiator", "plant", "bin", "loo", "sink" }
room.objects_needed = { loo = 1, sink = 1 }
room.build_preview_animation = 5098
room.categories = {
  facilities = 3,
}
room.minimum_size = 4
room.wall_type = "green"
room.floor_tile = 21

class "ToiletRoom" (Room)

function ToiletRoom:ToiletRoom(...)
  self:Room(...)
  self.door.queue:setBenchThreshold(3)
end

function ToiletRoom:roomFinished()
  local fx, fy = self:getEntranceXY(true)
  local objects = self.world:findAllObjectsNear(fx, fy)
  local number = 0
  for object, value in pairs(objects) do
    if object.object_type.id == "loo" then
      number = number + 1
    end
  end
  self.maximum_patients = number
  Room.roomFinished(self)
end

function ToiletRoom:dealtWithPatient(patient)
-- Continue to the previous room
  patient:setNextAction(self:createLeaveAction())
  if patient.next_room_to_visit then
    patient:queueAction{name = "seek_room", room_type = patient.next_room_to_visit.room_info.id}
  else
    patient:queueAction{name = "seek_reception"}
  end
end

function ToiletRoom:onHumanoidEnter(humanoid)
  if class.is(humanoid, Patient) then
    local loo, lx, ly = self.world:findFreeObjectNearToUse(humanoid, "loo")
    if loo and lx and ly then
      humanoid:walkTo(lx, ly)
      loo.reserved_for = humanoid
      local use_time = math.random(0, 2)
      -- One class only have a 1 tick long usage animation
      if humanoid.humanoid_class == "Transparent Female Patient" then
        use_time = math.random(15, 40)
      end
      humanoid:queueAction{
        name = "use_object",
        object = loo,
        loop_callback = --[[persistable:toilets_loop_callback]] function()
          use_time = use_time - 1
          if use_time <= 0 then
            humanoid:setMood("poo", "deactivate")
            humanoid:changeAttribute("toilet_need", -(0.85 + math.random()*0.15))
            humanoid.going_to_toilet = nil
          -- There are only animations for standard patients to use the sinks.
            if humanoid.humanoid_class == "Standard Female Patient" or
              humanoid.humanoid_class == "Standard Male Patient" then
              local --[[persistable:toilets_find_sink]] function after_use()
                local sink, sx, sy = self.world:findFreeObjectNearToUse(humanoid, "sink")
                if sink then
                  humanoid:walkTo(sx, sy)
                  humanoid:queueAction{
                    name = "use_object",
                    object = sink,
                    prolonged_usage = false,
                    after_use = --[[persistable:toilets_after_use_sink]] function()
                      self:dealtWithPatient(humanoid)
                    end,
                  }
                  sink.reserved_for = humanoid
                  -- Make sure that the mood waiting is no longer active.
                  humanoid:setMood("patient_wait", "deactivate")
                else
                  -- Wait for a while before trying again.
                  humanoid:setNextAction{
                    name = "idle", 
                    count = 5,
                    after_use = after_use,
                    direction = loo.direction == "north" and "south" or "east",
                    }
                  -- For now, activate the wait icon to show the player that the patient hasn't
                  -- got stuck. TODO: Make a custom mood? Let many people use the sinks?
                  humanoid:setMood("patient_wait", "activate")
                end
              end
              after_use()
            else
              self:dealtWithPatient(humanoid)
            end
          end
        end
      }
    else
      -- If no loo is found, go out again and start over. TODO: This should never happen - 
      -- when does it?
      humanoid:setNextAction(self:createLeaveAction())
      humanoid:queueAction(self:createEnterAction())
      print("Warning: A patient was called into the toilets even though there are no free loos.")
    end
  end
  return Room.onHumanoidEnter(self, humanoid)
end

return room
