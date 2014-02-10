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

--! Timer / clock / watch / countdown dialog for emergencies / level start
--! The timer lasts approximately 100 days, split into 13 segments
class "UIWatch" (Window)

--!param count_type (string) One of: "open_countdown" or "emergency" or "epidemic"
function UIWatch:UIWatch(ui, count_type)
  self:Window()
  
  local app = ui.app
  
  self.esc_closes = false
  self.modal_class = "open_countdown"
  self.tick_rate = math.floor((100 * app.world.hours_per_day) / 13)
  self.tick_timer = self.tick_rate  -- Initialize tick timer
  self.open_timer = 12
  self.ui = ui
  self.hospital = ui.hospital
  self.width = 39
  self.height = 79
  self:setDefaultPosition(20, -100)
  self.panel_sprites = app.gfx:loadSpriteTable("Data", "Watch01V", true)
  self.epidemic = false
  self.count_type = count_type
  
  local end_sprite = (count_type == "epidemic") and 14 or 16
  
  local tooltips = {
    ["initial_opening"] = _S.tooltip.watch.hospital_opening,
    ["emergency"]       = _S.tooltip.watch.emergency,
    ["epidemic"]        = _S.tooltip.watch.epidemic,
  }
  
  if count_type ~= "emergency" then
    self.end_button = self:addPanel(end_sprite, 4, 0)
      :makeButton(4, 0, 27, 28, end_sprite + 1, self.onCountdownEnd)
      :setTooltip(tooltips[count_type])
  end
  self:addPanel(13, 0, 28):setTooltip(tooltips[count_type])
  self:addPanel(1, 2, 47)
end

function UIWatch:onCountdownEnd()
  self:close()
  if self.count_type == "emergency" then
    self.ui.hospital:resolveEmergency()
  elseif self.count_type == "initial_opening" then
    self.ui.hospital.opened = true
    self.ui.hospital.boiler_can_break = true -- boiler can't break whilst build timer is open
    self.ui:playSound("fanfare.wav")
  end
end

function UIWatch:onWorldTick()
  if self.tick_timer == 0 and self.open_timer >= 0 then -- Used for making a smooth animation
    self.tick_timer = self.tick_rate
    self.open_timer = self.open_timer - 1
    if self.open_timer == 11 then
      self:addPanel(2, 2, 47)
    elseif self.open_timer == 0 then
      self.panels[#self.panels].sprite_index = 0
    elseif self.open_timer < 11 and self.open_timer > 0 then
      self.panels[#self.panels].sprite_index = 13 - self.open_timer
      if self.open_timer == 5 then
        table.remove(self.panels, #self.panels - 1)
      end
    end
  elseif self.open_timer == -1 then -- the timer is at 0 when it is completely red.
    self:onCountdownEnd() -- Countdown terminated, so we open the hospital or ends the epidemic panic
  else
    self.tick_timer = self.tick_timer - 1
  end
end
