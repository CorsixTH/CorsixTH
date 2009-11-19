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
room.name = _S(14, 5)
room.class = "GPRoom"
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { "desk", "cabinet", "chair" }
room.build_cost = 2500
room.build_preview_animation = 900
room.categories = {
  diagnosis = 1,
}
room.minimum_size = 4
room.wall_type = "white"
room.floor_tile = 18
room.required_staff = {
  Doctor = 1,
}
room.maximum_staff = room.required_staff

class "GPRoom" (Room)

function GPRoom:GPRoom(...)
  self:Room(...)
end

function GPRoom:onHumanoidEnter(humanoid)
  -- Don't copy this function for other rooms just yet - I'm not entirely 
  -- happy with some of it, so the way in which it is implemented will likely
  -- change.
  
  -- This logic for deciding whether or not to make use of the humanoid will
  -- probably be generalised and moved into Room:onHumanoidEnter()
  local take_control = false
  if humanoid.humanoid_class == "Doctor" then
    take_control = true
    for human in pairs(self.humanoids) do
      if human.humanoid_class == "Doctor" then
        take_control = false
        break
      end
    end
  end
  if not take_control then
    return Room.onHumanoidEnter(self, humanoid)
  end
  self.humanoids[humanoid] = true
  
  local desk, ox, oy = self.world:findObjectNear(humanoid, "desk")
  -- THOB markers may be adjusted to incorporate the footprint origin, making
  -- these next few lines unrequired in the future.
  -- Alternatively, THOB markers may remain the same, but these lines moved to
  -- World:findObjectNear()'s default callback
  local origin = desk.object_type.orientations[desk.direction]
  if origin.footprint_origin then
    ox = ox - origin.footprint_origin[1]
    oy = oy - origin.footprint_origin[2]
  end
  if origin.use_position then
    ox = ox + origin.use_position[1]
    oy = oy + origin.use_position[2]
  end
  -- The method for chaining something to happen after a walk will probably
  -- also change.
  humanoid:walkTo(ox, oy, function()
    humanoid:setNextAction{name = "use_object", object = desk}
  end)
end

return room
