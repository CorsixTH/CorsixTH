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

--! Load Game Window
class "UILoadGame" (UIResizable)

local col_bg = {
  red = 154,
  green = 146,
  blue = 198,
}

function UILoadGame:UILoadGame(ui, mode)
  self:UIResizable(ui, 200, 280, col_bg)
  
  local app = ui.app
  self.mode = mode
  self.modal_class = "main menu"
  self.resizable = false
  self:setDefaultPosition(0.5, 0.25)
  self.white_font = app.gfx:loadFont("QData", "Font01V")
  
  local function load_button(filename, file)
    return --[[persistable:load_game_button]] function(self)
      self:buttonLoad(filename)
    end
  end
  
  self.labels = {}
  for num = 1, 9 do
    local filename = (num == 9) and "CorsixTH-Auto.sav" or "CorsixTH-Slot".. num .. ".sav"
    local label = (num == 9) and _S.menu_options.autosave or _S.menu_file_load[num]
    local tooltip = (num == 9) and _S.tooltip.load_game_window.load_autosave or _S.tooltip.load_game_window.load_game_number:format(num)
    local panel = self:addBevelPanel(20, 20 * num, 160, 18, col_bg):setTooltip(tooltip)
    local f = io.open(filename, "rb")
    if f then
      panel:makeButton(0, 0, 160, 18, nil, load_button(filename))
      self.labels[num] = label
      f:close()
    else
      self.labels[num] = _S.tooltip.main_menu.load_menu.empty_slot
    end
  end
  self:addBevelPanel(20, 220, 160, 40, col_bg):makeButton(0, 0, 160, 40, nil, self.buttonBack):setTooltip(_S.tooltip.load_game_window.back)
end

function UILoadGame:getSavedWindowPositionName()
  if self.mode == "menu" then
    return "main_menu_group"
  end
  return UIResizable.getSavedWindowPositionName(self)
end

function UILoadGame:draw(canvas, x, y)
  -- Draw window components
  UIResizable.draw(self, canvas, x, y)
  -- Draw labels
  x, y = self.x + x, self.y + y
  for i, label in ipairs(self.labels) do
    self.white_font:draw(canvas, self.labels[i], x + 20, y + 20 * i, 160, 18)
  end
  
  self.white_font:draw(canvas, _S.load_game_window.back, x + 20, y + 220, 160, 40)
end

function UILoadGame:buttonLoad(filename)
  local app = self.ui.app

  app:loadLevel(1) -- hack

  local handler = LoadGameFile
  local status, err = pcall(handler, filename)
  if not status then
    err = _S.errors.load_prefix .. err
    print(err)
    app:loadMainMenu()
    app.ui:addWindow(UIInformation(self.ui, {err}))
  end
end

function UILoadGame:buttonBack()
  if self.mode == "menu" then
    self.ui:addWindow(UIMainMenu(self.ui))
  end
  self:close()
end
