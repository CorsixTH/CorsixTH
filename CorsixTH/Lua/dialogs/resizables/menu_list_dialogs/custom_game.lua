--[[ Copyright (c) 2010-2014 Edvin "Lego3" Linge

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

---@type UICustomGame
local UICustomGame = _G["UICustomGame"]

local col_scrollbar = {
  red = 164,
  green = 156,
  blue = 208,
}

local details_width = 280

function UICustomGame:UICustomGame(ui)

  self.label_font = TheApp.gfx:loadFont("QData", "Font01V")

  -- Supply the required list of items to UIMenuList
  local path = ui.app.level_dir

  -- Create the actual list
  local items = {}
  for file in lfs.dir(path) do
    if file:match"%.level$" then
      local level_info = TheApp:readLevelFile(file)
      if level_info.name and level_info.map_file then
        items[#items + 1] = {
          name = level_info.name,
          tooltip = _S.tooltip.custom_game_window.choose_game,
          map_file = level_info.map_file,
          level_file = file,
          intro = level_info.briefing,
          deprecated_variable_used = level_info.deprecated_variable_used,
        }
      end
    end
  end
  self:UIMenuList(ui, "menu", _S.custom_game_window.caption, items, 10, details_width + 40)

  -- Create a toolbar ready to be used if the description for a level is
  -- too long to fit
  local scrollbar_base = self:addBevelPanel(560, 40, 20, self.num_rows*17, self.col_bg)
  scrollbar_base.lowered = true
  self.details_scrollbar = scrollbar_base:makeScrollbar(col_scrollbar, --[[persistable:menu_list_details_scrollbar_callback]] function()
    self:updateDescriptionOffset()
  end, 1, 1, self.num_rows)

  self.description_offset = 0

  -- Now add the free build button beside the list.
  if not pcall(function()
    local palette = ui.app.gfx:loadPalette("QData", "DrugN01V.pal")
    self.panel_sprites = ui.app.gfx:loadSpriteTable("QData", "DrugN02V", true, palette)
    self.border_sprites = ui.app.gfx:loadSpriteTable("Bitmap", "aux_ui", true)
  end) then
    self:close()
    return
  end

  self:addBevelPanel(280, 230, 140, 20, self.col_bg):setLabel(_S.custom_game_window.free_build).lowered = true
  local button =  self:addPanel(12, 430, 225):makeToggleButton(0, 0, 29, 29, 11, self.buttonFreebuild)
    :setTooltip(_S.tooltip.custom_game_window.free_build)
  if self.ui.app.config.free_build_mode then
    button:toggle()
  end

  -- Finally the load button
  self:addBevelPanel(480, 220, 100, 40, self.col_bg)
    :setLabel(_S.custom_game_window.load_selected_level)
    :makeButton(0, 0, 100, 40, 11, self.buttonLoadLevel)
    :setTooltip(_S.tooltip.custom_game_window.load_selected_level)
end

function UICustomGame:updateDescriptionOffset()
  self.description_offset = self.details_scrollbar.value - 1
end

-- Overrides the function in the UIMenuList, choosing what should happen when the player
-- clicks a choice in the list.
function UICustomGame:buttonClicked(num)
  local item = self.items[num + self.scrollbar.value - 1]
  self.chosen_index = num
  self.chosen_level_name = item.name
  self.chosen_level_description = item.intro
  local filename = item.path
  if self.chosen_level_description then
    local x, y, rows = self.label_font:sizeOf(self.chosen_level_description, details_width)
    local row_height = y / rows
    self.max_rows_shown = math.floor(self.num_rows*17 / row_height)
    self.details_scrollbar:setRange(1, rows, math.min(rows, self.max_rows_shown), 1)
  else
    self.details_scrollbar:setRange(1, 1, 1, 1)
  end
  self.description_offset = 0

  if item.deprecated_variable_used then
    self.ui:addWindow(UIInformation(self.ui, {_S.warnings.levelfile_variable_is_deprecated:format(item.name)}))
  end
end

function UICustomGame:buttonLoadLevel()
  if self.chosen_index then
    -- First make sure the map file exists.
    local item = self.items[self.chosen_index + self.scrollbar.value - 1]
    local app = self.ui.app
    local _, errors = app:readMapDataFile(item.map_file)
    if errors then
      self.ui:addWindow(UIInformation(self.ui, {errors}))
      return
    end
    app:loadLevel(item.level_file, nil, self.chosen_level_name, item.map_file, self.chosen_level_description)
  end
end

function UICustomGame:buttonFreebuild(checked)
  self.ui.app.config.free_build_mode = checked
end

function UICustomGame:draw(canvas, x, y)
  UIMenuList.draw(self, canvas, x, y)
  x, y = self.x + x, self.y + y

  if self.chosen_level_name then
    self.label_font:drawWrapped(canvas, self.chosen_level_name,
                                x + 270, y + 10, details_width)
  end
  if self.chosen_level_description then
    self.label_font:drawWrapped(canvas, self.chosen_level_description,
              x + 270, y + 40, details_width, nil, self.max_rows_shown, self.description_offset)
  end
end
