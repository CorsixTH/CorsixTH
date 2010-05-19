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

local pathsep = package.config:sub(1, 1)

--! Load Game Window
class "UICustomGame" (UIResizable)

local col_bg = {
  red = 154,
  green = 146,
  blue = 198,
}

function UICustomGame:UICustomGame(ui, mode)
  self:UIResizable(ui, 200, 280, col_bg)
  
  local app = ui.app
  local map = app.map
  self.mode = mode
  self.modal_class = "main menu"
  self.resizable = false
  self:setDefaultPosition(0.5, 0.25)
  self.white_font = app.gfx:loadFont("QData", "Font01V")
  
  local function load_button(filename, level_name, level_file)
    return --[[persistable:custom_game_button]] function(self)
      self:buttonLoad(filename, level_name:sub(2, -2), level_file:sub(2, -2))
    end
  end
  
  --self.labels = {}
  local path = debug.getinfo(1, "S").source:sub(2, -28)

  path = path .. "Levels" .. pathsep

  local num = 1
  for file in lfs.dir(path) do
    if file:match"%.level$" then
      local level_name, level_file
      for line in io.lines(path .. pathsep .. file) do
        -- Get level name and name of the level file to load
        if line:sub(1, 1) == "%" then
          for text in line:gmatch("\".+\"") do
            if line:find("Name") then
              level_name = text
            elseif line:find("LevelFile") then
              level_file = text
            end
          end
        end
      end
      if level_name and level_file then
        local tooltip = _S.tooltip.load_game_window.load_game_with_name:format(level_name)
        local panel = self:addBevelPanel(20, 20 * num, 160, 18, col_bg):setTooltip(tooltip)
        panel:makeButton(0, 0, 160, 18, nil, load_button(path .. file, level_name, level_file))
        panel:setLabel(level_name)
        --self.labels[#self.labels + 1] = level_name
        num = num + 1
      end
    end
  end
  self:addBevelPanel(20, 42 + num * 20, 160, 40, col_bg):setLabel(_S.load_game_window.back)
    :makeButton(0, 0, 160, 40, nil, self.buttonBack):setTooltip(_S.tooltip.load_game_window.back)
  self:setSize(self.width, 20 * num + 100)
  self.num_items = num
end

function UICustomGame:getSavedWindowPositionName()
  if self.mode == "menu" then
    return "main_menu_group"
  end
  return UIResizable.getSavedWindowPositionName(self)
end

function UICustomGame:draw(canvas, x, y)
  -- Draw window components
  UIResizable.draw(self, canvas, x, y)
  -- Draw labels
  x, y = self.x + x, self.y + y
  --for i, label in ipairs(self.labels) do
  --  self.white_font:draw(canvas, self.labels[i], x + 20, y + 20 * i, 160, 18)
  --end
  
  --self.white_font:draw(canvas, _S.load_game_window.back, x + 27, y + 51 + self.num_items * 20, 146, 26)
end

function UICustomGame:buttonLoad(filename, level_name, level_file)
  local app = self.ui.app
  -- First make sure the map file exists.
  local _, errors = app:readLevelDataFile(level_file)
  if errors then
    self.ui:addWindow(UIInformation(self.ui, {errors}))
    return
  end
  app:loadLevel(filename, level_name, level_file)
end

function UICustomGame:buttonBack()
  if self.mode == "menu" then
    self.ui:addWindow(UIMainMenu(self.ui))
  end
  self:close()
end
