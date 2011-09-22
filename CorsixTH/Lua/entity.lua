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

--! Abstraction for visible gameplay things which sit somewhere on the map.
class "Entity"

local TH = require "TH"

function Entity:Entity(animation)
  self.th = animation
  self.layers = {}
  animation:setHitTestResult(self)
  self.ticks = true
  self.dynamic_info = nil;
end

-- This plays a sound "at" the entity, meaning the sound will not be played
-- if the entity is off-screen, and the volume will be quieter the further
-- the entity is from the center of the screen. If this is not what you want
-- then use UI:playSound instead.
-- !param name (string, integer) The filename or ordinal of the sound to play.
function Entity:playSound(name)
  if TheApp.config.play_sounds then
    TheApp.audio:playSound(name, self)
  end
end

--[[ Set which animation is used to give the entity a visual appearance.
! Until an entity is given an animation, it is invisible to the player. Note
that some "animations" consist of a single frame, and hence the term animation
is used both to mean things which are animated and things which are static.

!param animation (integer) The ordinal into the main animation set
!param flags (integer) A combination of zero or more drawing flags to control
the use of alternative palettes, transparency, and other similar settings. See
`THDF_` values in `th_gfx.h` for the possible bit values.
]]
function Entity:setAnimation(animation, flags)
  flags = flags or 0
  if self.permanent_flags then
    flags = flags + self.permanent_flags
  end
  if animation ~= self.animation_idx or flags ~= self.animation_flags then
    self.animation_idx = animation
    self.animation_flags = flags
    self.th:setAnimation(self.world.anims, animation, flags)
  end
  return self
end

--[[ Set the map tile which the entity is on.
!param x (integer) The 1-based X co-ordinate of the tile.
!param y (integer) The 1-based Y co-ordinate of the tile.
]]
function Entity:setTile(x, y)
  if self.user_of then
    print("Warning: Entity tile changed while marked as using an object")
  end
  self.tile_x = x
  self.tile_y = y
  -- NB: (x, y) can be nil, in which case th:setTile expects all nil arguments
  self.th:setTile(x and self.world.map.th, x, y)
  if self.mood_info then
    self.mood_info:setParent(self.th)
  end
  return self
end

function Entity:getRoom()
  if self.tile_x and self.tile_y then
    return self.world:getRoom(self.tile_x, self.tile_y)
  else
    return nil
  end
end

--[[ Set the pixel position of the entity within the current tile.
!param x (integer) The 0-based X pixel offset from the default position.
!param y (integer) The 0-based Y pixel offset from the default position.
]]
function Entity:setPosition(x, y)
  self.th:setPosition(x, y)
  return self
end

--[[ Set the rate at which the entity pixel position changes
!param x (integer) The X component of the speed in pixels per tick.
!param y (integer) The Y component of the speed in pixels per tick.
]]
function Entity:setSpeed(x, y)
  self.th:setSpeed(x, y)
  return self
end

--[[ Combined form of `setTile`, `setPosition`, and `setSpeed`
!param tx (integer) The 1-based X co-ordinate of the tile.
!param ty (integer) The 1-based Y co-ordinate of the tile.
!param px (integer) The 0-based X pixel offset from the default position.
!param py (integer) The 0-based Y pixel offset from the default position.
!param sx (integer) The X component of the speed in pixels per tick.
!param sy (integer) The Y component of the speed in pixels per tick.
]]
function Entity:setTilePositionSpeed(tx, ty, px, py, sx, sy)
  self:setTile(tx, ty)
  self:setPosition(px or 0, py or 0)
  self:setSpeed(sx or 0, sy or 0)
  return self
end

-- Inner tick function that will skip every other tick when
-- slow_animation is set.
function Entity:_tick()
  if self.slow_animation then
    if not self.skip_next_tick then
      self.th:tick()
    end
    self.skip_next_tick = not self.skip_next_tick
  else
    self.th:tick()
  end
end

-- Function which is called once every tick, where a tick is the smallest unit
-- of time in the game engine. Typically used to advance animations and similar
-- recurring or long-duration tasks.
function Entity:tick()
  if self.num_animation_ticks then
    for i = 1, self.num_animation_ticks do
      self:_tick()
    end
    if self.num_animation_ticks == 1 then
      self.num_animation_ticks = nil
    end
  else
    self:_tick()
  end
  if self.mood_info then
    self.mood_info:tick()
  end
  
  local timer = self.timer_time
  if timer then
    timer = timer - 1
    if timer == 0 then
      self.timer_time = nil
      local timer_function = self.timer_function
      self.timer_function = nil
      timer_function(self)
    else
      self.timer_time = timer
    end
  end
end

--[[ Set which parts of the animation to be displayed.
! Each animation is made up of 13 layers, and generally has several different
options for each layer. In the animation viewer tool, multiple options can be
toggled on for each layer, however here only one option may be selected per
layer.
!param layer (integer) The layer to set (1 through 13).
!param id (integer) The option to display for the given layer.
]]
function Entity:setLayer(layer, id)
  self.th:setLayer(layer, id)
  self.layers[layer] = id
  return self
end

--[[ Register a function (related to the entity) to be called at a later time.
! Each `Entity` can have a single timer associated with it, and due to this
limit of one, it is almost always the case that the currently active humanoid
action is the only thing wich calls `setTimer`.
If self.slow_animation is set then all timers will be doubled as animation
length will be doubled.
!param tick_count (integer) If 0, then `f` will be called during the entity's
next `tick`. If 1, then `f` will be called one tick after that, and so on.
!param f (function) Function which takes a single argument (the entity).
]]
function Entity:setTimer(tick_count, f)
  self.timer_time = tick_count
  self.timer_function = f
  if self.slow_animation and tick_count then
    self.skip_next_tick = true
    self.timer_time = tick_count * 2
  end
end

-- Used to set a mood icon over the entity.
function Entity:setMoodInfo(new_mood)
  if new_mood then
    if not self.mood_info then
      self.mood_info = TH.animation()
      self.mood_info:setPosition(-1, -96)
      self.mood_info:setParent(self.th)
    end
    self.mood_info:setAnimation(self.world.anims, new_mood.icon)
  else
    if self.mood_info then
      self.mood_info:setTile(nil)
    end
    self.mood_info = false
  end
end

-- Function which is called when the entity is to be permanently removed from
-- the world.
function Entity:onDestroy()
  self:setTile(nil)
  self.world.dispatcher:dropFromQueue(self)
  -- Debug aid to check that there are no hanging references after the entity
  -- has been destroyed:
  --[[
  self.gc_dummy = newproxy(true) -- undocumented Lua library function
  getmetatable(self.gc_dummy).__gc = function()
    print("Entity " .. tostring(self) .. " has been garbage collected.")
  end --]]
end

-- Function which is called at the end of each ingame day. Should be used to
-- implement behaviours which happen regularly, but not as frequently as to
-- need them in `tick`.
function Entity:tickDay()
end

function Entity:notifyNewObject(id)
end

function Entity:setMood(mood_name, activate)
end

-- Returns a table of hover info about an object.
function Entity:getDynamicInfo()
  return self.dynamic_info
end

-- Sets a piece of Dynamic_info.
-- type could be 'text', 'progress' or 'dividers'
function Entity:setDynamicInfo(type, value)
  if not self.dynamic_info then
    self.dynamic_info = {
      text = nil,
      progress = nil,
      dividers = nil,
    }
  end
  self.dynamic_info[type] = value
end

-- Completely clears the dynamic info.
function Entity:clearDynamicInfo()
  self.dynamic_info = nil
end

--! Stub to be extended in subclasses, if needed.
function Entity:afterLoad(old, new)
end
