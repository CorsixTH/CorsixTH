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

dofile("dialogs/menu_list_dialog")

local pathsep = package.config:sub(1, 1)

--! Custom Game Window
class "UICustomGame" (UIMenuList)

function UICustomGame:UICustomGame(ui)

  local path = debug.getinfo(1, "S").source:sub(2, -28)

  path = path .. "Levels" .. pathsep

  -- Supply the required list of items to UIMenuList
  local items = {}
  for file in lfs.dir(path) do
    if file:match"%.level$" then
      local level_name, level_file, level_intro
      for line in io.lines(path .. pathsep .. file) do
        -- Get level name and name of the level file to load
        if line:sub(1, 1) == "%" then
          for text in line:gmatch("\".+\"") do
            if line:find("Name") then
              level_name = text
            elseif line:find("LevelFile") then
              level_file = text
            elseif line:find("LevelBriefing") then
              level_intro = text
            end
          end
        end
      end
      if level_name and level_file then
        items[#items + 1] = {
          name = level_name, 
          tooltip = _S.tooltip.custom_game_window.start_game_with_name:format(level_name),
          level_file = level_file,
          path = path .. file,
          intro = level_intro,
        }
      end
    end
  end
  self:UIMenuList(ui, "menu", _S.custom_game_window.caption, items)
end
  
function UICustomGame:buttonClicked(num)
  local app = self.ui.app
  local item = self.items[num + self.scrollbar.value - 1]
  local level_name = item.name:sub(2, -2)
  local level_file = item.level_file:sub(2, -2)
  local level_intro = item.intro and item.intro:sub(2, -2)
  local filename = item.path
  -- First make sure the map file exists.
  local _, errors = app:readLevelDataFile(level_file)
  if errors then
    self.ui:addWindow(UIInformation(self.ui, {errors}))
    return
  end
  app:loadLevel(filename, nil, level_name, level_file, level_intro)
end

