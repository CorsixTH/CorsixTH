--[[ Copyright (c) 2010 M.Chalon

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

dofile "dialogs/fullscreen"

class "UIResearch" (UIFullscreen)

local research_categories = {
  "cure",
  "diagnosis",
  "drugs",
  "improvements",
  "specialisation",
}

function UIResearch:UIResearch(ui)
  self:UIFullscreen(ui)
  local gfx = ui.app.gfx
  if not pcall(function()
    self.background = gfx:loadRaw("Res01V", 640, 480)  
    local palette = gfx:loadPalette("QData", "Res01V.pal")
    palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
    self.panel_sprites = gfx:loadSpriteTable("QData", "Res02V", true, palette)
    self.label_font = gfx:loadFont("QData", "Font43V", false, palette)
    self.number_font  = gfx:loadFont("QData", "Font43V", false, palette)  
  end) then
    ui:addWindow(UIInformation(ui, {_S.errors.dialog_missing_graphics}))
    self:close()
    return
  end
  
  self.hospital = ui.hospital
  
  -- stub for backwards compatibility
  local --[[persistable:research_policy_adjust]] function adjust(name)
  end
  
  -- Buttons
  local topy = 21
  local spacing = 41
  local c1 = 372
  local c2 = 450
  local size = 40
  self:addPanel(0, 607, 447):makeButton(0, 0, size, size, 4, self.close):setTooltip(_S.tooltip.research.close)
  
  self.adjust_buttons = {}
  for i, area in ipairs(research_categories) do
    self.adjust_buttons[area] = {
      less = self:addPanel(0, c1, topy+i*spacing):makeButton(0, 0, size, size, 1, --[[persistable:research_less_stub]] function() end),
      more = self:addPanel(0, c2, topy+i*spacing):makeButton(0, 0, size, size, 2, --[[persistable:research_more_stub]] function() end),
    }
  end
  
  self.waterclk = 0
  self.ratclk = 0
  self.waterpanel= self:addPanel(5, 2, 312)
  self.ratpanel= self:addPanel(13, 480, 365)
end

function UIResearch:adjustResearch(area, mode)
  local hosp = self.hospital
  local amount = 1
  if self.buttons_down.ctrl then
    amount = amount * 20
  elseif self.buttons_down.shift then
    amount = amount * 5
  end
  if mode == "less" then
    if hosp.research[area].frac > 0 then
      hosp.research[area].frac = math.max(0, hosp.research[area].frac - amount)
      self.ui:playSound("selectx.wav")
    else
      self.ui:playSound("Wrong2.wav")
    end
  elseif mode == "more" then
    if hosp.research.global < 100 and hosp.research[area].current then
      hosp.research[area].frac = hosp.research[area].frac +
        math.min(amount, 100 - hosp.research.global)
      self.ui:playSound("selectx.wav")
    else
      self.ui:playSound("Wrong2.wav")
    end
  end
  
  hosp.research.global = 0
  for _, category in ipairs(research_categories) do
    hosp.research.global = hosp.research.global + hosp.research[category].frac
  end
end

function UIResearch:onTick()
  -- sprite index for the water are between 5 and 12
  -- We use a sub clock 
  self.waterclk = self.waterclk + 1
  if self.waterclk > 3 then
    self.waterclk = 0
    self.waterpanel.sprite_index = self.waterpanel.sprite_index + 1
    if self.waterpanel.sprite_index > 12 then
      self.waterpanel.sprite_index = 5
    end  
  end
  
  -- sprite index for the rat  are between 10 and 15
  -- We use a sub clock 
  self.ratclk = self.ratclk + 1
  if self.ratclk > 3 then
    self.ratclk = 0
    -- sprite index for the water are between 13 and 20
    self.ratpanel.sprite_index = self.ratpanel.sprite_index + 1
    if self.ratpanel.sprite_index > 20 then
      self.ratpanel.sprite_index = 13
    end  
  end
  
  -- adjust research according to pressed button
  for area, btns in pairs(self.adjust_buttons) do
    for dir, btn in pairs(btns) do
      if btn.active then
        self:adjustResearch(area, dir)
      end
    end
  end
end

function UIResearch:draw(canvas, x, y)
  self.background:draw(canvas, self.x + x, self.y + y)
  UIFullscreen.draw(self, canvas, x, y)
  x, y = self.x + x, self.y + y
  
  local num_font = self.number_font
  local lbl_font = self.label_font

  local ytop = 28
  local spacing = 41
  local config = self.hospital.world.map.level_config
  local research = self.hospital.research
  
  for i, category in ipairs(research_categories) do
    local y = y + ytop + i * spacing
    lbl_font:draw(canvas, _S.research.categories[category], x + 170, y)
    num_font:draw(canvas, research[category].frac, x + 270, y, 300, 0)
    -- Display research progress  - currently for rooms only.
    if (i == 1 or i == 2) and config and research[category].current then
      local ly = y + 26
      local lx = x + 172
      local required = config.expertise[research[category].current.level_config_research].RschReqd
      local extra_points = self.hospital.research_rooms[research[category].current]
      local available = research[category].points + extra_points
      local length = 290*available/required
      local dx = 0
      while dx + 10 < length do
        self.panel_sprites:draw(canvas, 3, lx + dx, ly)
        dx = dx + 10
      end
    end
  end
  
  num_font:draw(canvas, self.hospital.research.global, x + 270, y + 288, 300, 0)
end

function UIResearch:afterLoad(old, new)
  UIFullscreen.afterLoad(self, old, new)
  if old < 26 then
    self.adjust_buttons = {}
    for i, area in ipairs(research_categories) do
      self.adjust_buttons[area] = {
        less = self.buttons[2*i],
        more = self.buttons[2*i+1],
      }
    end
  end
end
