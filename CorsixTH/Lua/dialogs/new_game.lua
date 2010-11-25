--[[ Copyright (c) 2010 Edvin "Lego3" Linge

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

dofile("dialogs/resizable")

--! Class for the difficulty choice window.
class "UINewGame" (UIResizable)

local col_bg = {
  red = 154,
  green = 146,
  blue = 198,
}

local col_button = {
  red = 84,
  green = 180,
  blue = 84,
}

function UINewGame:UINewGame(ui)
  self:UIResizable(ui, 200, 280, col_bg)
  
  local app = ui.app
  self.esc_closes = true
  self.resizable = false
  self.modal_class = "main menu"
  self.on_top = true
  self:setDefaultPosition(0.5, 0.25)
  if not pcall(function()
    local palette = app.gfx:loadPalette("QData", "DrugN01V.pal")
    self.panel_sprites = app.gfx:loadSpriteTable("QData", "DrugN02V", true, palette)
    self.border_sprites = app.gfx:loadSpriteTable("Bitmap", "aux_ui", true)
  end) then
    -- Couldn't find some files, which implies we're using the demo version of TH.
    -- Load directly and activate the tutorial. Those who use the demo files probably
    -- want that anyway.
    self.start_tutorial = true
    self:startGame("full")
    self:close()
    return
  end

  -- individual buttons
  self.default_button_sound = "selectx.wav"
  self:addBevelPanel(20, 25, 110, 20, col_bg):setLabel(_S.new_game_window.tutorial).lowered = true
  self:addPanel(12, 150, 20):makeToggleButton(0, 0, 29, 29, 11, self.buttonTutorial):setTooltip(_S.tooltip.new_game_window.tutorial)
  self:addBevelPanel(20, 65, 160, 40, col_bg):setLabel(_S.new_game_window.easy):makeButton(0, 0, 160, 40, nil, self.buttonEasy):setTooltip(_S.tooltip.new_game_window.easy)
  self:addBevelPanel(20, 115, 160, 40, col_bg):setLabel(_S.new_game_window.medium):makeButton(0, 0, 160, 40, nil, self.buttonMedium):setTooltip(_S.tooltip.new_game_window.medium)
  self:addBevelPanel(20, 165, 160, 40, col_bg):setLabel(_S.new_game_window.hard):makeButton(0, 0, 160, 40, nil, self.buttonHard):setTooltip(_S.tooltip.new_game_window.hard)
  self:addBevelPanel(20, 220, 160, 40, col_bg):setLabel(_S.new_game_window.cancel):makeButton(0, 0, 160, 40, nil, self.buttonCancel):setTooltip(_S.tooltip.new_game_window.cancel)
end

function UINewGame:getSavedWindowPositionName()
  return "main_menu_group"
end

local label_y = { 27, 75, 123, 171, 231 }

function UINewGame:onMouseDown(button, x, y)
  local repaint = UIResizable.onMouseDown(self, button, x, y)
  if button == "left" and not repaint and not (x >= 0 and y >= 0 and
  x < self.width and y < self.height) and self:hitTest(x, y) then
    return self:beginDrag(x, y)
  end
  return repaint
end

function UINewGame:hitTest(x, y)
  if x >= 0 and y >= 0 and x < self.width and y < self.height then
    return true
  end
  local sprites = self.border_sprites
  if not sprites then
    return false
  end
  if x < -9 or y < -9 or x >= self.width + 9 or y >= self.height + 9 then
    return false
  end
  if (0 <= x and x < self.width) or (0 <= y and y < self.height) then
    return true
  end
  local test = sprites.hitTest
  return test(sprites, 10, x + 9, y + 9)
      or test(sprites, 12, x - 160, y + 9)
      or test(sprites, 15, x + 9, y - 240)
      or test(sprites, 17, x - 160, y - 240)
end

function UINewGame:buttonTutorial(checked)
  self.start_tutorial = checked
end

function UINewGame:buttonEasy()
  self:startGame("easy")
end

function UINewGame:buttonMedium()
  self:startGame("full")
end

function UINewGame:buttonHard()
  self:startGame("hard")
end

function UINewGame:startGame(difficulty)
  self.ui.app:loadLevel(1, difficulty)
  if self.start_tutorial then
    TheApp.ui.start_tutorial = true
    TheApp.ui:startTutorial()
  end
end

function UINewGame:buttonCancel()
  self:close()
end

function UINewGame:close()
  UIResizable.close(self)
  self.ui:addWindow(UIMainMenu(self.ui))
end
