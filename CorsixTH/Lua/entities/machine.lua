--[[ Copyright (c) 2009 Edvin "Lego3" Linge

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

class "Machine" (Object)

function Machine:Machine(world, object_type, ...)
  -- Initialize machines with strength values. (TODO: according to current research)
  if object_type.default_strength then
    self.hover_cursor = TheApp.gfx:loadMainCursor("repair")
    self.strength = object_type.default_strength
    self.total_usage = -1 -- Incremented in the constructor of Object.
  end
  self:Object(world, object_type, ...)
  self:updateDynamicInfo(true)
end

function Machine:machineUsed(room)
  self:updateDynamicInfo()
  local threshold = self.times_used/self.strength
  if threshold > 0.85 then
    room:crashRoom()
    self:setAnimation(self.object_type.crashed_animation)
  elseif threshold > 0.65 then
    self.world:callForStaff(room, self, true)
    -- TODO: 3428 is smoke, add it when additional objects can be made
  elseif threshold > 0.35 then
    self.world:callForStaff(room, self) 
  end
end

function Machine:machineRepaired(room)
  room.needs_repair = nil
  local str = self.strength
  if self.times_used/str > 0.55 then
    self.strength = str - 1
  end
  self.times_used = 0
  self:setRepairing(false)
  self:updateDynamicInfo(true)
end

function Machine:setRepairing(activate)
  local anim = {icon = 4564} -- The only icon for machinery
  self:setMoodInfo(activate and anim or nil)
  if activate then
    self.ticks = true
  else
    self.ticks = self.object_type.ticks
  end
end

function Machine:updateDynamicInfo(only_update)
  if not only_update then
    self.times_used = self.times_used + 1
    self.total_usage = self.total_usage + 1
  end
  if self.strength then
    self:setDynamicInfo("text", {
      self.object_type.name, 
      _S(59, 31):format(self.strength),
      _S(59, 32):format(self.times_used),
    })
  end
end

function Machine:onClick(ui, button)
  if button == "left" and self.strength then
    local room = self.world:getRoom(self.tile_x, self.tile_y)
    ui:addWindow(UIMachine(ui, self, room))
  else
    Object.onClick(ui, button)
  end
end
