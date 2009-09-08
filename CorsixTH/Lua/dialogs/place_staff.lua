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
dofile "staff"

class "UIPlaceStaff" (Window)

function UIPlaceStaff:UIPlaceStaff(ui, profile, x, y)
  self.ui = ui
  self.world = ui.app.world
  self.modal_class = "main"
  self.esc_closes = true
  self.profile = profile
  self.anim = TH.animation()
  self.anim:setLayer(5, profile.layer5)
  local idle_anim = Humanoid.getIdleAnimation(profile.humanoid_class)
  self.anim:setAnimation(self.world.anims, idle_anim)
  local _, ghost = ui.app.gfx:loadPalette()
  self.world.anims:setAnimationGhostPalette(idle_anim, ghost)
  self:onMouseMove(x, y)
  self:Window()
end

function UIPlaceStaff:onMouseMove(x, y)
  x, y = self.ui:ScreenToWorld(x, y)
  self.tile_x = math_floor(x)
  self.tile_y = math_floor(y)
end

local flag_cache = {}
local flag_altpal = 16
function UIPlaceStaff:draw(canvas)
  self.world.map.th:getCellFlags(self.tile_x, self.tile_y, flag_cache)
  self.anim:setFlag(flag_cache.hospital and 0 or flag_altpal)
  self.anim:draw(canvas, self.ui:WorldToScreen(self.tile_x, self.tile_y))
end

function UIPlaceStaff:onMouseUp(button, x, y)
  if button == "right" then
    self:close()
    return true
  elseif button == "left" then
    self:onMouseMove(x, y)
    self.world.map.th:getCellFlags(self.tile_x, self.tile_y, flag_cache)
    if flag_cache.hospital then
      local entity = self.world:newEntity("Staff", 2)
      entity:setProfile(self.profile)
      entity:setTile(self.tile_x, self.tile_y)
      entity:setNextAction{name = "meander"}
      self:close()
      return true
    end
  end
end
