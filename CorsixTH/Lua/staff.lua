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

class "Staff" (Humanoid)

function Staff:Staff(...)
  self:Humanoid(...)
  self.hover_cursor = TheApp.gfx:loadMainCursor("staff")
end

function Staff:tick()
  Entity.tick(self)
  self:checkIfNeedRest()
end

function Staff:fire()
  if self.fired then
    return
  end
  
  self.fired = true
  self:setHospital(nil)
  self.hover_cursor = nil
  self.fatigue = nil
  -- TODO: Remove from world/hospital staff list
end

function Staff:onClick(ui, button)
  if self.fired then
    return
  end
  
  if button == "left" then
    ui:addWindow(UIStaff(ui, self))
    -- temporary for debugging
    print("Actions of ", self.profile.name, ": ")
    for i = 1, #self.action_queue do
      print(self.action_queue[i].name)
    end
    print("Fatigue: ", self.fatigue)
  elseif button == "right" then
    self:setNextAction({name = "pickup", ui = ui, must_happen = true}, true)
  end
end

function Staff:setProfile(profile)
  self.profile = profile
  self:setType(profile.humanoid_class)
  if (self.humanoid_class ~= "Receptionist") then
    self.fatigue = 0
  end
  self:setLayer(5, profile.layer5)
end

-- Function for increasing fatigue. Fatigue can be between 0 and 1,
-- so amounts here should be appropriately small comma values.
function Staff:tire(amount)
  if self.fatigue then
    self.fatigue = self.fatigue + amount
    if self.fatigue > 1 then
      self.fatigue = 1
    end
  end
end

-- Function for decreasing fatigue. Fatigue can be between 0 and 1,
-- so amounts here should be appropriately small comma values.
function Staff:wake(amount)
  if self.fatigue then
    self.fatigue = self.fatigue - amount
    if self.fatigue < 0 then
      self.fatigue = 0
    end
  end
end

-- Check if fatigue is over a certain level (now: 0.8, later: configurable), and go to the StaffRoom if it is.
function Staff:checkIfNeedRest()
  if self.fatigue and self.fatigue >= 0.8 and not class.is(self:getRoom(), StaffRoom) then
    -- If there's already a "seek_staffroom" action in the action queue, or staff is currently picked up, do nothing
    if self.going_to_staffroom or self.action_queue[1].name == "pickup" then
      return
    end
    -- Else, seek a staff room now
    self:setNextAction{name = "seek_staffroom", must_happen = true}
    self.going_to_staffroom = true
    -- NB: going_to_staffroom set if (and only if) a seek_staffroom action is in the action_queue
  end
end

function Staff:onPlaceInCorridor()
  if self.humanoid_class ~= "Receptionist" then
    return
  end
  
  local world = self.world
  world:findObjectNear(self, "reception_desk", nil, function(x, y)
    local obj = world:getObject(x, y, "reception_desk")
    if not obj.receptionist and not obj.reserved_for then
      obj.reserved_for = self
      self.associated_desk = obj
      local use_x, use_y = obj:getSecondaryUsageTile()
      self:setNextAction{name = "walk", x = use_x, y = use_y, must_happen = true}
      self:queueAction{name = "staff_reception", object = obj, must_happen = true}
      return true
    end
  end)
end

function Staff:setHospital(hospital)
  if self.hospital then
    self.hospital:removeStaff(self)
  end
  Humanoid.setHospital(self, hospital)
  if hospital then
    hospital:addStaff(self)
  end
end
