--[[ Copyright (c) 2010 Manuel "Roujin" Wolf

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

--! Class for main menu window.
class "UIMainMenu" (UIResizable)

local col_bg = {
  red = 154,
  green = 146,
  blue = 198,
}

function UIMainMenu:UIMainMenu(ui)
  self:UIResizable(ui, 200, 280, col_bg)
  
  local app = ui.app
  self.esc_closes = false
  self.modal_class = "main menu"
  self.on_top = true
  self:setDefaultPosition(0.5, 0.25)
  self.border_sprites = app.gfx:loadSpriteTable("Bitmap", "aux_ui", true)
  
  -- individual buttons
  self.default_button_sound = "selectx.wav"
  self:addBevelPanel(20, 20, 160, 40, col_bg):setLabel(_S.main_menu.new_game):makeButton(0, 0, 160, 40, nil, self.buttonNewGame):setTooltip(_S.tooltip.main_menu.new_game)
  self:addBevelPanel(20, 65, 160, 40, col_bg):setLabel(_S.main_menu.custom_level):makeButton(0, 0, 160, 40, nil, self.buttonCustomGame):setTooltip(_S.tooltip.main_menu.custom_level)
  self:addBevelPanel(20, 110, 160, 40, col_bg):setLabel(_S.main_menu.load_game):makeButton(0, 0, 160, 40, nil, self.buttonLoadGame):setTooltip(_S.tooltip.main_menu.load_game)
  self:addBevelPanel(20, 155, 160, 40, col_bg):setLabel(_S.main_menu.options):makeButton(0, 0, 160, 40, nil, self.buttonOptions):setTooltip(_S.tooltip.main_menu.options)
  self:addBevelPanel(20, 220, 160, 40, col_bg):setLabel(_S.main_menu.exit):makeButton(0, 0, 160, 40, nil, self.buttonExit):setTooltip(_S.tooltip.main_menu.exit)
end

function UIMainMenu:getSavedWindowPositionName()
  return "main_menu_group"
end

local label_y = { 27, 75, 123, 171, 231 }

function UIMainMenu:onMouseDown(button, x, y)
  local repaint = UIResizable.onMouseDown(self, button, x, y)
  if button == "left" and not repaint and not (x >= 0 and y >= 0 and
  x < self.width and y < self.height) and self:hitTest(x, y) then
    return self:beginDrag(x, y)
  end
  return repaint
end

function UIMainMenu:hitTest(x, y)
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

function UIMainMenu:buttonNewGame()
  local window = UINewGame(self.ui)
  self.ui:addWindow(window)
  
end

function UIMainMenu:buttonCustomGame()
  local window = UICustomGame(self.ui)
  self.ui:addWindow(window)
end

function UIMainMenu:buttonLoadGame()
  local window = UILoadGame(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIMainMenu:buttonOptions()
  local window = UIOptions(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIMainMenu:buttonExit()
  self.ui.app:exit()
end
