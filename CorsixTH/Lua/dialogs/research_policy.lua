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
  
  local hosp = ui.hospital
  self.hospital = hosp

  local --[[persistable:research_policy_adjust]] function adjust(name, state, btn)
    print("You want to : ", name)
    local delta = name:sub(1, 4)
    local area = name:sub(5, -1)
    local amount = 1
    if self.buttons_down.ctrl then
      amount = amount * 20
    elseif self.buttons_down.shift then
      amount = amount * 5
    end
    if delta == "less" then
      if hosp.research[area] > 0 then
        hosp.research[area] = math.max(0, hosp.research[area] - amount)
        self.ui:playSound("selectx.wav")
      else
        self.ui:playSound("Wrong2.wav")
      end
    elseif delta == "more" then
      if hosp.research.global < 100 then
        hosp.research[area] = hosp.research[area] +
          math.min(amount, 100 - hosp.research.global)
        self.ui:playSound("selectx.wav")
      else
        self.ui:playSound("Wrong2.wav")
      end
    end

    hosp.research.global = 0
    for _, category in ipairs(research_categories) do
      hosp.research.global = hosp.research.global + hosp.research[category]
    end
  end

  -- Buttons
  local topy = 21
  local spacing = 41
  local c1 = 372
  local c2 = 450
  local size = 40
  self:addPanel(0, 607, 447):makeButton(0, 0, size, size, 4, self.close):setTooltip(_S.tooltip.research.close)
  
  for i, area in ipairs(research_categories) do
    self:addPanel(0, c1, topy+i*spacing):makeButton(0, 0, size, size, 1, adjust, "less".. area)
    self:addPanel(0, c2, topy+i*spacing):makeButton(0, 0, size, size, 2, adjust, "more".. area)
  end
  
  self.waterclk = 0
  self.ratclk = 0
  self.waterpanel= self:addPanel(5, 2, 312)
  self.ratpanel= self:addPanel(13, 480, 365)
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
end

function UIResearch:draw(canvas, x, y)
  self.background:draw(canvas, self.x + x, self.y + y)
  UIFullscreen.draw(self, canvas, x, y)
  x, y = self.x + x, self.y + y
  
  local num_font = self.number_font
  local lbl_font = self.label_font

  local ytop = 28
  local spacing = 41
  
  for i, category in ipairs(research_categories) do
    local y = y + ytop + i * spacing
    lbl_font:draw(canvas, _S.research.categories[category], x + 170, y)
    num_font:draw(canvas, self.hospital.research[category], x + 270, y, 300, 0)
  end
  
  num_font:draw(canvas, self.hospital.research.global, x + 270, y + 288, 300, 0)
end
