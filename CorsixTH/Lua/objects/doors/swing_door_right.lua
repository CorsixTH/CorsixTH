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

---@type SwingDoor
local SwingDoor = _G["SwingDoor"]

function SwingDoor:SwingDoor(hospital, object_type, x, y, direction, etc)
  self.is_master = object_type == object
  self:Door(hospital, object_type, x, y, direction, etc)
  self.paired = false
  self:pairDoors(x, y)
  self.old_anim = self.th:getAnimation()
  self.old_flags = self.th:getFlag()
  local --[[persistable:swing_door_creation]] function _() end -- Stub from Oct 2023, savegame version 181
end

--! Links the master to the slave swing door. This allows the slave to mimic the
--! master in interactions
--!param x (num) Coordinate
--!param y (num) Coordinate
function SwingDoor:pairDoors(x, y)
  -- Because we don't know the build order of each door we must accommodate for this
  if self.is_master then -- The master will check for an adjacent slave
    local slave_type = "swing_door_left"
    self.slave = self.world:getObject(x - 1, y, slave_type) or
        self.world:getObject(x, y - 1, slave_type)
    if self.slave then
      self.slave.master = self
      self.paired = true
      self.slave.master.paired = true
    end
  else -- The slave will check for an adjacent master
    local master_type = "swing_door_right"
    self.master = self.world:getObject(x + 1, y, master_type) or
        self.world:getObject(x, y + 1, master_type)
    if self.master then
      self.master.slave = self
      self.paired = true
      self.master.slave.paired = true
    end
  end
  -- The second run of this function must check there was a successful pairing
  self:checkPaired(x, y)
end

--! Checks to see if the swing doors have paired correctly
function SwingDoor:checkPaired(x, y)
  if self.paired then
    assert((self.master and self.master.slave == self) or
        (self.slave and self.slave.master == self),
        "Swing doors did not pair at (" .. x .. ", " .. y .. ")")
  else -- The other door should not yet exist
    local other_door_type = self.is_master and "swing_door_left" or "swing_door_right"
    local other_door_offset = self.is_master and - 1 or 1
    local other_door = self.world:getObject(x + other_door_offset, y, other_door_type) or
        self.world:getObject(x, y + other_door_offset, other_door_type)
    assert(not other_door, "Swing doors did not pair at (" .. x .. ", " .. y .. ")")
  end
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
      self:removeUser()
      self:getRoom():tryAdvanceQueue()
    end
  end
  self:setTimer(TheApp.animation_manager:getAnimLength(anim), callback)
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

function SwingDoor:afterLoad(old, new)
  if old < 184 then
    if (self.is_master and not self.slave) or (not self.is_master and
        not self.master) then
      local x, y =  self.tile_x, self.tile_y
      self.paired = false -- other door will be rectified by pairDoors
      self:pairDoors(x, y)
    else
      self.paired = true
      if self.is_master then
        self.slave.paired = true
      else
        self.master.paired = true
      end
    end
  end
  Door.afterLoad(self, old, new)
end

return object
