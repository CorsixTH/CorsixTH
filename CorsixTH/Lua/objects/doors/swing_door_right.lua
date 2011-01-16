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

local object = {}
object.id = "swing_door_right"
object.thob = 53
object.name = _S.object.swing_door2
object.tooltip = _S.tooltip.objects.swing_door2
object.class = "SwingDoor"
object.ticks = false
object.idle_animations = {
  north = 2006,
  --west = 2050,--1998
}

class "SwingDoor" (Door)

function SwingDoor:SwingDoor(world, object_type, x, y, direction, etc)
  self.is_master = object_type == object
  self:Door(world, object_type, x, y, direction, etc)
  if self.is_master then
    -- Wait one tick before finding the slave so that we're sure it has been created.
    local --[[persistable:swing_door_creation]] function callback()
      local slave_type = "swing_door_left"
      self.slave = world:getObject(x - 1, y, slave_type) or world:getObject(x, y - 1, slave_type) or nil
      self.slave:setAsSlave(self)
      self.ticks = false
    end
    self:setTimer(1, callback)
    self.ticks = true
  end
  self.old_anim = self.th:getAnimation()
  self.old_flags = self.th:getFlag()
end

--[[ Makes the door mimic its master when it comes to hover cursor and what happens
when the player clicks on it.

!param swing_door (Door) The master door to mimic.
]]
function SwingDoor:setAsSlave(swing_door)
  self.master = swing_door
end

-- Depending on if this is a master or slave different onClick functions are called.
function SwingDoor:onClick(ui, button)
  if self.is_master then
    Door.onClick(self, ui, button)
  elseif self.master then
    Door.onClick(self.master, ui, button)
  end
end

-- Depending on if this is a master or slave update the correct information.
function SwingDoor:updateDynamicInfo()
  if self.is_master then
    Door.updateDynamicInfo(self)
  elseif self.master then
    Door.updateDynamicInfo(self.master)
  end
end

-- Depending on if this is a master or slave show the correct information.
function SwingDoor:getDynamicInfo()
  return self.master and self.master.dynamic_info or self.dynamic_info
end

--[[ Tell the associated slave door to start swinging.

!param direction (string) The direction in which to swing. Allowed values are
"in" and "out".
]]
function SwingDoor:swingSlave(direction)
  local flags = (self.direction == "east" or self.direction == "west") and 1 or 0
  local anim = 2034
  if direction == "in" then
    anim = 2032
  end
  self:swing(anim, flags)
end

--[[ Makes the pair of swing doors start swinging in the correct fashion.

!param direction (string) The direction in which to swing. Allowed values are
"in" and "out".
!param length (integer) How long the swing animation is for the entering/leaving entity.
]]
function SwingDoor:swingDoors(direction, length)
  -- First tell the slave door to start swinging
  self.slave:swingSlave(direction)
  -- Then wait for a while before flapping back this door
  local --[[persistable:swing_door_waiting]] function callback()
    local flags = (self.direction == "east" or self.direction == "west") and 1 or 0
    local anim = 2052
    if direction == "in" then
      anim = 2048
    end
    self:swing(anim, flags)
  end
  self:setTimer(length, callback)
  self.ticks = true
end

--[[ The actual swinging is done in this class.

!param anim (integer) The animation to use.
!param flags (integer) Flags, if any, associated with the animation.
]]
function SwingDoor:swing(anim, flags)
  self:setAnimation(anim, flags)
  self.ticks = true
  local --[[persistable:swing_door_opening]] function callback()
    self:setAnimation(self.old_anim, self.old_flags)
    self.ticks = false
    if self.is_master then
      -- We're now ready to let another humanoid walk through
      self:setUser(nil)
      self:getRoom():tryAdvanceQueue()
    end
  end
  self:setTimer(self.world:getAnimLength(anim), callback)
end

function SwingDoor:getWalkableTiles()
  if not self.is_master then
    return {}
  end
  local x, y = self.tile_x, self.tile_y
  if self.direction == "west" then
    return {
      {x-1, y-1}, {x, y-1},
      {x-1, y  }, {x, y  },
      {x-1, y+1}, {x, y+1},
    }
  else
    return {
      {x-1, y-1}, {x, y-1}, {x+1, y-1},
      {x-1, y  }, {x, y  }, {x+1, y  },
    }
  end
end

return object
