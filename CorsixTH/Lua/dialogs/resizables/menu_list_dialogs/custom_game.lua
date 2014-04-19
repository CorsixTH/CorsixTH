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

local pathsep = package.config:sub(1, 1)

--! Custom Game Window
class "UICustomGame" (UIMenuList)

function UICustomGame:UICustomGame(ui)

  -- Supply the required list of items to UIMenuList
  local path = debug.getinfo(1, "S").source:sub(2, -57)

  path = path .. "Levels" .. pathsep

  -- Create the actual list
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
          tooltip = _S.tooltip.custom_game_window.start_game_with_name:format(level_file, level_intro),
          level_file = level_file,
          path = path .. file,
          intro = level_intro,
        }
      end
    end
  end
  self:UIMenuList(ui, "menu", _S.custom_game_window.caption, items, 10, 30)

  -- Now add the free build button above the list.
  if not pcall(function()
    local palette = ui.app.gfx:loadPalette("QData", "DrugN01V.pal")
    self.panel_sprites = ui.app.gfx:loadSpriteTable("QData", "DrugN02V", true, palette)
    self.border_sprites = ui.app.gfx:loadSpriteTable("Bitmap", "aux_ui", true)
  end) then
    self:close()
    return
  end

  self:addBevelPanel(20, 40, 200, 20, self.col_bg):setLabel(_S.custom_game_window.free_build).lowered = true
  local button =  self:addPanel(12, 230, 36):makeToggleButton(0, 0, 29, 29, 11, self.buttonFreebuild)
    :setTooltip(_S.tooltip.custom_game_window.free_build)
  if self.ui.app.config.free_build_mode then
    button:toggle()
  end
end

-- Overrides the function in the UIMenuList, choosing what should happen when the player
-- clicks a choice in the list.
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

function UICustomGame:buttonFreebuild(checked)
  self.ui.app.config.free_build_mode = checked
end


