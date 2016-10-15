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
room.long_name = _S.rooms_long.toilets
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

---@type ToiletRoom
local ToiletRoom = _G["ToiletRoom"]

function ToiletRoom:ToiletRoom(...)
  self:Room(...)
  self.door.queue:setBenchThreshold(3)
end

function ToiletRoom:roomFinished()
  local fx, fy = self:getEntranceXY(true)
  local objects = self.world:findAllObjectsNear(fx, fy)
  local number = 0
  for object, _ in pairs(objects) do
    if object.object_type.id == "loo" then
      number = number + 1
    end
  end
  self.maximum_patients = number
  Room.roomFinished(self)
end

function ToiletRoom:dealtWithPatient(patient)
  -- Continue going to the room before going to the toilets.
  patient:setNextAction(self:createLeaveAction())
  if patient.next_room_to_visit then
    patient:queueAction(SeekRoomAction(patient.next_room_to_visit.room_info.id))
  else
    patient:queueAction(SeekReceptionAction())
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

      local loop_callback_toilets = --[[persistable:toilets_loop_callback]] function()
        use_time = use_time - 1
        if use_time <= 0 then
          humanoid:setMood("poo", "deactivate")
          humanoid:changeAttribute("toilet_need", -(0.85 + math.random() * 0.15))
          humanoid.going_to_toilet = "no"

          -- There are only animations for standard patients to use the sinks.
          if humanoid.humanoid_class == "Standard Female Patient" or
              humanoid.humanoid_class == "Standard Male Patient" then
            local --[[persistable:toilets_find_sink]] function after_use()
              local sink, sx, sy = self.world:findFreeObjectNearToUse(humanoid, "sink")
              if sink then
                humanoid:walkTo(sx, sy)

                local after_use_sink = --[[persistable:toilets_after_use_sink]] function()
                  self:dealtWithPatient(humanoid)
                end

                humanoid:queueAction(UseObjectAction(sink):setProlongedUsage(false)
                    :setAfterUse(after_use_sink))
                sink.reserved_for = humanoid
                -- Make sure that the mood waiting is no longer active.
                humanoid:setMood("patient_wait", "deactivate")
              else
                -- if there is a queue to wash hands there is a chance we might not bother
                -- but the patient won't be happy about this.
                if math.random(1, 4) > 2 then
                  -- Wait for a while before trying again.
                  humanoid:setNextAction(IdleAction():setCount(5):setAfterUse(after_use)
                      :setDirection(loo.direction == "north" and "south" or "east"))

                else
                  self:dealtWithPatient(humanoid)
                  humanoid:changeAttribute("happiness", -0.08)
                  humanoid:setMood("patient_wait", "deactivate")
                end
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

      humanoid:queueAction(UseObjectAction(loo):setLoopCallback(loop_callback_toilets))
    else
      --[[ If no loo is found, perhaps the patient followed another one in and they were heading for the same one.
      Now there is no free loo, so wait for a bit and then leave the room to wait outside.  No need for a warning
      as this is what happens in busy toilets]]
      humanoid:setNextAction(MeanderAction():setCount(1))
      humanoid:queueAction(self:createLeaveAction())
      humanoid:queueAction(self:createEnterAction(humanoid))
    end
  end
  return Room.onHumanoidEnter(self, humanoid)
end

-- Override the standard way to count the number of patients to take into account
-- that some of them may not be using the loo, allowing others to enter the room earlier than normal;
-- but not if there is only one loo in the room, then it becomes a private toilet with only one person at a time.
function ToiletRoom:getPatientCount()
  local number_users = 0
  local not_using_loo = 0
  for humanoid in pairs(self.humanoids) do
    if class.is(humanoid, Patient) then
      number_users = number_users + 1

      if humanoid.action_queue[1].name == "use_object" and
          humanoid.action_queue[1].object.object_type.id ~= "loo" then
        not_using_loo = not_using_loo + 1
      end
    end
  end

  if self.maximum_patients == 1 then
    return number_users
  else
    return number_users - not_using_loo
  end
end

function ToiletRoom:afterLoad(old, new)
  if old < 110 then
    room.free_loos = nil
  end
  Room.afterLoad(self, old, new)
end

return room
