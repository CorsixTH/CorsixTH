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

local col_bg = {
  red = 24,
  green = 24,
  blue = 20,
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
  self.research = ui.hospital.research
  
  -- stubs for backwards compatibility
  local --[[persistable:research_policy_adjust]] function adjust(name) end
  local --[[persistable:research_less_stub]] function less_stub() end
  local --[[persistable:research_more_stub]] function more_stub() end
  
  -- Close button
  self:addPanel(0, 607, 447):makeButton(0, 0, 40, 40, 4, self.close):setTooltip(_S.tooltip.research.close)
  self.adjust_buttons = {}
  self:updateCategories()
  
  self.waterclk = 0
  self.ratclk = 0
  self.waterpanel= self:addPanel(5, 2, 312)
  self.ratpanel= self:addPanel(13, 480, 365)

  -- Add tooltips to progress of research.
  local lx = 165
  local ly = 60
  for i, category in ipairs(research_categories) do
    self:makeDynamicTooltip(--[[persistable:research_policy_research_progress_tooltip]] function()
      local research = self.research.research_policy
      if research[category].current
      and not research[category].current.dummy then
        local required = self.research:getResearchRequired(research[category].current)
        local available = self.research.research_progress[research[category].current].points
        return _S.tooltip.research_policy.research_progress:format(math.round(available), required)
      else
        return _S.tooltip.research_policy.no_research
      end
    end, lx, ly, lx + 315, ly + 41)
    ly = ly + 41
  end
end

function UIResearch:updateCategories()
  -- Buttons to increase/decrease percentages
  local size = 40
  local topy = 21
  local spacing = 41
  local c1 = 372
  local c2 = 450
  
  local function handler_factory(area, mode)
    return --[[persistable:research_policy_adjust_handler]] function(self)
      self:adjustResearch(area, mode)
    end
  end

  for i, area in ipairs(research_categories) do
    local current = self.hospital.research.research_policy[area].current
    if current then
      self.adjust_buttons[area] = {
        less = self:addPanel(0, c1, topy+i*spacing):makeRepeatButton(0, 0, size, size, 1, handler_factory(area, "less")),
        more = self:addPanel(0, c2, topy+i*spacing):makeRepeatButton(0, 0, size, size, 2, handler_factory(area, "more")),
      }
    else
      if self.adjust_buttons[area] then
        self.adjust_buttons[area].less.enabled = false
        self.adjust_buttons[area].more.enabled = false
      end
      self:addColourPanel(c1, topy+i*spacing, 120, 30, col_bg.red, col_bg.green, col_bg.blue)
    end
  end
end

function UIResearch:adjustResearch(area, mode)
  local res = self.research
  local amount = 1
  if self.buttons_down.ctrl then
    amount = amount * 20
  elseif self.buttons_down.shift then
    amount = amount * 5
  end
  if mode == "less" then
    if res.research_policy[area].frac > 0 then
      res.research_policy[area].frac = math.max(0, res.research_policy[area].frac - amount)
      self.ui:playSound("selectx.wav")
    else
      self.ui:playSound("Wrong2.wav")
    end
  elseif mode == "more" then
    if res.research_policy.global < 100 and res.research_policy[area].current then
      res.research_policy[area].frac = res.research_policy[area].frac +
        math.min(amount, 100 - res.research_policy.global)
      self.ui:playSound("selectx.wav")
    else
      self.ui:playSound("Wrong2.wav")
    end
  end
  
  res.research_policy.global = 0
  for _, category in ipairs(research_categories) do
    res.research_policy.global = res.research_policy.global + res.research_policy[category].frac
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
  
  return UIFullscreen.onTick(self)
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
  local research = self.research.research_policy
  
  for i, category in ipairs(research_categories) do
    local y = y + ytop + i * spacing
    lbl_font:draw(canvas, _S.research.categories[category], x + 170, y)
    if not research[category].current then
      num_font:draw(canvas, _S.misc.done, x + 270, y, 300, 0)
    else
      num_font:draw(canvas, research[category].frac, x + 270, y, 300, 0)
    end
    -- Display research progress.
    if research[category].current 
    and not research[category].current.dummy then
      local ly = y + 26
      local lx = x + 172
      local required = self.research:getResearchRequired(research[category].current)
      local available = self.research.research_progress[research[category].current].points
      local length = 290*available/required
      local dx = 0
      while dx + 10 < length do
        self.panel_sprites:draw(canvas, 3, lx + dx, ly)
        dx = dx + 10
      end
    end
  end
  
  num_font:draw(canvas, research.global, x + 270, y + 288, 300, 0)
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
