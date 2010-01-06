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

class "Entity"

local TH = require "TH"

function Entity:Entity(animation)
  self.th = animation
  self.layers = {}
  animation:setHitTestResult(self)
  self.ticks = true
end

function Entity:playSound(name)
  -- This plays a sound "at" the entity, meaning the sound will not be played
  -- if the entity is off-screen, and the volume will be quieter the further
  -- the entity is from the center of the screen. If this is not what you want
  -- then use UI:playSound instead.
  TheApp.audio:playSound(name, self)
end

function Entity:setAnimation(animation, flags)
  flags = flags or 0
  if animation ~= self.animation_idx or flags ~= self.animation_flags then
    self.animation_idx = animation
    self.animation_flags = flags
    self.th:setAnimation(self.world.anims, animation, flags)
  end
  return self
end

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
  return self.world:getRoom(self.tile_x, self.tile_y)
end

function Entity:setPosition(x, y)
  self.th:setPosition(x, y)
  return self
end

function Entity:setSpeed(x, y)
  self.th:setSpeed(x, y)
  return self
end

function Entity:setTilePositionSpeed(tx, ty, px, py, sx, sy)
  self:setTile(tx, ty)
  self:setPosition(px or 0, py or 0)
  self:setSpeed(sx or 0, sy or 0)
  return self
end

function Entity:tick()
  if self.num_animation_ticks then
    for i = 1, self.num_animation_ticks do
      self.th:tick()
    end
    if self.num_animation_ticks == 1 then
      self.num_animation_ticks = nil
    end
  else
    self.th:tick()
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

function Entity:setLayer(layer, id)
  self.th:setLayer(layer, id)
  self.layers[layer] = id
  return self
end

function Entity:setTimer(tick_count, f)
  self.timer_time = tick_count
  self.timer_function = f
end

-- Used to set a mood icon over the entity.
function Entity:setMoodInfo(new_mood)
  if new_mood then
    if not self.mood_info then
      self.mood_info = TH.animation()
      self.mood_info:setPosition(-1, -96)
    end
    self.mood_info:setAnimation(self.world.anims, new_mood.icon)
    self.mood_info:setParent(self.th)
  else
    if self.mood_info then
      self.mood_info:setTile(nil)
    end
    self.mood_info = false
  end
end

function Entity:onDestroy()
  self:setTile(nil)
  -- Debug aid to check that there are no hanging references after the entity
  -- has been destroyed:
  --[[
  self.gc_dummy = newproxy(true) -- undocumented Lua library function
  getmetatable(self.gc_dummy).__gc = function()
    print("Entity " .. tostring(self) .. " has been garbage collected.")
  end --]]
end

-- Function stubs to be able to call these from the world/ui if it is a humanoid
function Entity:tickDay()
end

function Entity:notifyNewObject(id)
end

function Entity:setMood(mood_name, activate)
end
