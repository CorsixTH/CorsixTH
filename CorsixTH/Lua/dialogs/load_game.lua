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

local col_caption = {
  red = 174,
  green = 166,
  blue = 218,
}

local col_scrollbar = {
  red = 164,
  green = 156,
  blue = 208,
}

function UILoadGame:UILoadGame(ui, mode)
  self:UIResizable(ui, 200, 280, col_bg)
  
  local app = ui.app
  self.mode = mode
  self.modal_class = "main menu"
  self.resizable = false
  self:setDefaultPosition(0.5, 0.25)
  
  self:addBevelPanel(20, 10, 160, 20, col_caption):setLabel(_S.load_game_window.caption)
    .lowered = true
  
  -- Scan for savegames
  self.saves = self.ui.app:scanSavegames()
  
  local scrollbar_base = self:addBevelPanel(160, 40, 20, 10*17, col_bg)
  scrollbar_base.lowered = true
  self.scrollbar = scrollbar_base:makeScrollbar(col_scrollbar, --[[persistable:load_game_scrollbar_callback]] function()
    self:updateButtons()
  end, 1, math.max(#self.saves, 1), 10)
  
  local function load_button(num)
    return --[[persistable:load_game_button]] function(self)
      self:buttonLoad(num)
    end
  end
  
  self.savegame_panels = {}
  self.savegame_buttons = {}
  for num = 1, 10 do
    self.savegame_panels[num] = self:addBevelPanel(20, 40 + (num - 1) * 17, 130, 17, col_bg)
    self.savegame_buttons[num] = self.savegame_panels[num]:makeButton(0, 0, 130, 17, nil, load_button(num))
  end
  
  self:addBevelPanel(20, 220, 160, 40, col_bg):setLabel(_S.load_game_window.back)
    :makeButton(0, 0, 160, 40, nil, self.buttonBack):setTooltip(_S.tooltip.load_game_window.back)
  
  self:updateButtons()
end

function UILoadGame:updateButtons()
  for num = 1, 10 do
    local panel = self.savegame_panels[num]
    local button = self.savegame_buttons[num]
    local filename = self.saves[num + self.scrollbar.value - 1]
    if filename then
      panel:setLabel(filename)
      panel:setTooltip(_S.tooltip.load_game_window.load_game:format(filename))
      button:enable(true)
    else
      panel:setLabel()
      panel:setTooltip()
      button:enable(false)
    end
  end
end

function UILoadGame:getSavedWindowPositionName()
  if self.mode == "menu" then
    return "main_menu_group"
  end
  return UIResizable.getSavedWindowPositionName(self)
end

function UILoadGame:buttonLoad(num)
  local filename = self.saves[num] .. ".sav"
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
