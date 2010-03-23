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

--! Class for main menu window.
class "UIMainMenu" (Window)

function UIMainMenu:UIMainMenu(ui)
  self:Window()
  
  local app = ui.app
  self.esc_closes = false
  self.ui = ui
  self.modal_class = "main menu"
  self.on_top = true
  self.width = 200
  self.height = 280
  self:setDefaultPosition(0.5, 0.25)
  self.border_sprites = app.gfx:loadSpriteTable("Bitmap", "aux_ui", true)
  self.panel_sprites = app.gfx:loadSpriteTable("Bitmap", "main_menu", true)
  self.white_font = app.gfx:loadFont("QData", "Font01V")
  
  self:addPanel(1, 0, 0) -- top part of window
  self:addPanel(2, 0, 160) -- bottom part of window
  
  -- individual buttons
  self.default_button_sound = "selectx.wav"
  self:addPanel(3, 18, 18):makeButton(0, 0, 164, 44, 4, self.buttonNewGame):setDisabledSprite(5):setTooltip(_S.tooltip.main_menu.new_game)
  self:addPanel(3, 18, 66):makeButton(0, 0, 164, 44, 4, nil):setDisabledSprite(5):setTooltip(_S.tooltip.main_menu.custom_level .. " " .. _S.misc.not_yet_implemented):enable(false)
  self:addPanel(3, 18, 114):makeButton(0, 0, 164, 44, 4, self.buttonLoadGame):setDisabledSprite(5):setTooltip(_S.tooltip.main_menu.load_game)
  self:addPanel(3, 18, 162):makeButton(0, 0, 164, 44, 4, nil):setDisabledSprite(5):setTooltip(_S.tooltip.main_menu.options .. " " .. _S.misc.not_yet_implemented):enable(false)
  self:addPanel(3, 18, 222):makeButton(0, 0, 164, 44, 4, self.buttonExit):setDisabledSprite(5):setTooltip(_S.tooltip.main_menu.exit)
  
  self.button_labels = {
    _S.main_menu.new_game,
    _S.main_menu.custom_level,
    _S.main_menu.load_game,
    _S.main_menu.options,
    _S.main_menu.exit,
  }
  self:onChangeResolution()
end

function UIMainMenu:getSavedWindowPositionName()
  return "main_menu_group"
end

local label_y = { 27, 75, 123, 171, 231 }

function UIMainMenu:draw(canvas, x, y)
  -- Draw border
  local sprites = self.border_sprites
  if sprites then
    local draw = sprites.draw
    local x = self.x + x
    local y = self.y + y
    canvas:nonOverlapping(true)
    draw(sprites, canvas, 10, x - 9, y - 9)
    draw(sprites, canvas, 12, x + 160, y - 9)
    draw(sprites, canvas, 15, x - 9, y + 240)
    draw(sprites, canvas, 17, x + 160, y + 240)
    for x = x + 40, x + 120, 40 do
      draw(sprites, canvas, 11, x, y - 9)
      draw(sprites, canvas, 16, x, y + 280)
    end
    for y = y + 40, y + 200, 40 do
      draw(sprites, canvas, 13, x - 9, y)
      draw(sprites, canvas, 14, x + 200, y)
    end
    canvas:nonOverlapping(false)
  end
  -- Draw window components
  Window.draw(self, canvas, x, y)
  -- Draw labels
  x, y = self.x + x, self.y + y
  for i, ly in ipairs(label_y) do
    self.white_font:draw(canvas, self.button_labels[i], x + 27, y + ly, 146, 26)
  end
end

function UIMainMenu:onMouseDown(button, x, y)
  local repaint = Window.onMouseDown(self, button, x, y)
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
  self.ui.app:loadLevel(1)
end

function UIMainMenu:buttonLoadGame()
  local window = UILoadGame(self.ui, "menu")
  self.ui:addWindow(window)
  self:close()
end

function UIMainMenu:buttonExit()
  self.ui.app:exit()
end
