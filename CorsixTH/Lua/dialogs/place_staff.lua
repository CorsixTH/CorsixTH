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

local math_floor
    = math.floor
local TH = require "TH"
dofile "entities/staff"

--! Invisible window which handles placing a `Staff` member in the world.
class "UIPlaceStaff" (Window)

function UIPlaceStaff:UIPlaceStaff(ui, profile, x, y)
  self.ui = ui
  self.world = ui.app.world
  self.modal_class = "main"
  self.esc_closes = true
  if class.is(profile, Staff) then
    self.staff = profile
    profile = profile.profile
  end
  self.profile = profile
  -- The receptionist has no door animations, and hence would not
  -- be able to leave a room if placed in one.
  self.allow_in_rooms = profile.humanoid_class ~= "Receptionist"
  self.anim = TH.animation()
  self.anim:setLayer(5, profile.layer5)
  local idle_anim = Humanoid.getIdleAnimation(profile.humanoid_class)
  self.anim:setAnimation(self.world.anims, idle_anim)
  local _, ghost = ui.app.gfx:loadPalette()
  self.world.anims:setAnimationGhostPalette(idle_anim, ghost)
  self:onCursorWorldPositionChange(x, y)
  self:Window()
end

function UIPlaceStaff:close()
  if self.staff then
    self.staff.pickup = false
    self.staff.going_to_staffroom = nil
    self.staff.action_queue[1].window = nil
    self.staff:setNextAction{name = "meander"}
  elseif self.profile then
    self.ui:tutorialStep(2, {6, 7}, 1)
    self.ui:tutorialStep(4, {4, 5}, 1)
    -- Return the profile to the available staff list
    local staff_pool = self.world.available_staff[self.profile.humanoid_class]
    staff_pool[#staff_pool + 1] = self.profile
  end
  self.ui:playSound "plac_st2.wav"
  Window.close(self)
end

function UIPlaceStaff:onCursorWorldPositionChange(x, y)
  x, y = self.ui:ScreenToWorld(x, y + 14)
  self.tile_x = math_floor(x)
  self.tile_y = math_floor(y)
end

local flag_cache = {}
local flag_altpal = 16
function UIPlaceStaff:draw(canvas)
  self.world.map.th:getCellFlags(self.tile_x, self.tile_y, flag_cache)
  local room = self.world:getRoom(self.tile_x, self.tile_y)
  local valid = flag_cache.hospital and flag_cache.passable and
    (self.allow_in_rooms or flag_cache.roomId == 0) and 
    (not room and true or not room.crashed)
  self.anim:setFlag(valid and 0 or flag_altpal)
  local zoom = self.ui.zoom_factor
  if canvas:scale(zoom) then
    local x, y = self.ui:WorldToScreen(self.tile_x, self.tile_y)
    self.anim:draw(canvas, x / zoom, y / zoom)
    canvas:scale(1)
  else
    self.anim:draw(canvas, self.ui:WorldToScreen(self.tile_x, self.tile_y))
  end
  self.ui:tutorialStep(2, valid and 7 or 6, valid and 6 or 7)
  self.ui:tutorialStep(4, valid and 5 or 4, valid and 4 or 5)
end

function UIPlaceStaff:onMouseUp(button, x, y)
  if button == "right" then
    self:close()
    return true
  elseif button == "left" then
    self:onMouseMove(x, y)
    self.world.map.th:getCellFlags(self.tile_x, self.tile_y, flag_cache)
    local room = self.world:getRoom(self.tile_x, self.tile_y)
    if flag_cache.hospital and flag_cache.passable
    and (self.allow_in_rooms or flag_cache.roomId == 0) 
    and (not room and true or not room.crashed) then
      if self.staff then
        self.staff:setTile(self.tile_x, self.tile_y)
      else
        local entity = self.world:newEntity("Staff", 2)
        entity:setProfile(self.profile)
        self.profile = nil
        entity:setTile(self.tile_x, self.tile_y)
        local room = entity:getRoom()
        if room then
          room:onHumanoidEnter(entity)
        else
          entity:onPlaceInCorridor()
        end
        self.ui.hospital:addStaff(entity)
        entity:setHospital(self.ui.hospital)
        self.ui:tutorialStep(2, 6, "next")
        self.ui:tutorialStep(4, 4, "next")
      end
      self:close()
      return true
    else
      self.ui.adviser:say(_S.adviser.placement_info.staff_cannot_place)
    end
  end
end
