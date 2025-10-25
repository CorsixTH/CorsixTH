--[[ Copyright (c) 2010-2014 Manuel "Roujin" Wolf, Edvin "Lego3" Linge

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
class "UIMainMenu" (UIResizable)

---@type UIMainMenu
local UIMainMenu = _G["UIMainMenu"]

local col_bg = {
  red = 154,
  green = 146,
  blue = 198,
}

local label_ttf_col = { -- slightly translucent
  red = 255,
  green = 255,
  blue = 255,
  alpha = 192,
}

local menu_item_height = 40

function UIMainMenu:UIMainMenu(ui)

  -- First define all menu entries with a label, a callback and a tooltip.
  -- That way we can call the UIResizable constructor with a good height argument.
  local menu_items = {
    {_S.main_menu.new_game,        self.buttonNewGame,        _S.tooltip.main_menu.new_game},
    {_S.main_menu.custom_campaign, self.buttonCustomCampaign, _S.tooltip.main_menu.custom_campaign},
    {_S.main_menu.custom_level,    self.buttonCustomGame,     _S.tooltip.main_menu.custom_level},
    {_S.main_menu.continue,        self.buttonContinueGame,   _S.tooltip.main_menu.continue},
    {_S.main_menu.load_game,       self.buttonLoadGame,       _S.tooltip.main_menu.load_game},
    {_S.main_menu.options,         self.buttonOptions,        _S.tooltip.main_menu.options},
    {_S.main_menu.map_edit,        self.buttonMapEdit,        _S.tooltip.main_menu.map_edit},
    -- {_S.main_menu.exit,            self.buttonExit,           _S.tooltip.main_menu.exit}
  }
  self.no_menu_entries = #menu_items

  --! Work out the size of non-false items in array
  --!param items (list) what is to be checked
  --!return calculated size
  local function computeSize(items)
    local size = 0
    for _, item in pairs(items) do
      size = item and (size + 1) or size
    end
    return size
  end

  -- Work out the menu's height, giving extra space for the version information
  local line_height = 15
  local top_padding = 20
  local release_string = TheApp:getReleaseString()
  local num_lines = computeSize({TheApp:isUpdateCheckDisabledByConfig(), TheApp.config.debug, release_string}) -- see UIMainMenu:draw for how these are used
  local bottom_text_height = (line_height * num_lines)
  self.height = top_padding + ((menu_item_height + 10) * #menu_items) + bottom_text_height

  self:UIResizable(ui, 200, self.height, col_bg)

  self.esc_closes = false
  self.modal_class = "main menu"
  self.on_top = true
  self:setDefaultPosition(0.5, 0.25)

  -- The main menu also shows the version number of the player's copy of the game.
  self.label_font = TheApp.gfx:loadFontAndSpriteTable("QData", "Font01V", nil, nil, {ttf_color = label_ttf_col})
  self.release_string = release_string

  -- individual buttons
  self.default_button_sound = "selectx.wav"

  local next_y = 20
  for _, item in ipairs(menu_items) do
    next_y = self:addMenuItem(item[1], item[2], item[3], next_y)
  end
end

--! Adds a single menu item to the main menu.
--!param label (string) The (localized) label to use for the new button.
--!param callback (function) Function to call when the user clicks the button.
--!param tooltip (string) Text to show when the player hovers over the button.
--!param y_pos (integer) Y-position from where to add the menu item.
--!return (integer) Y-position below which more items can be added.
--        This function has added a menu item between y_pos and the return value.
function UIMainMenu:addMenuItem(label, callback, tooltip, y_pos)
  self:addBevelPanel(20, y_pos, 160, menu_item_height, col_bg)
      :setLabel(label):makeButton(0, 0, 160, menu_item_height, nil, callback)
      :setTooltip(tooltip)
  return y_pos + menu_item_height + 10
end

function UIMainMenu:getSavedWindowPositionName()
  return "main_menu_group"
end

function UIMainMenu:draw(canvas, x, y)
  UIResizable.draw(self, canvas, x, y)
  x, y = self.x + x, self.y + y

  -- The following strings are drawn in reverse order
  local ly = y + self.height - 15
  -- Move the version string up a bit if showing check for updates disabled warning.
  if TheApp:isUpdateCheckDisabledByConfig() then
    self.label_font:draw(canvas, _S.main_menu.updates_off, x + 5, ly, 190, 0, "right")
    ly = ly - 15
  end
  -- Move if also showing the savegame version.
  if TheApp.config.debug then
    self.label_font:draw(canvas, _S.main_menu.savegame_version .. TheApp.savegame_version, x + 5, ly, 190, 0, "right")
    ly = ly - 15
  end
  self.label_font:draw(canvas, _S.main_menu.version .. self.release_string, x + 5, ly, 190, 0, "right")
end

function UIMainMenu:onTick()
  TheApp:idle()
end

function UIMainMenu:onMouseMove(x, y, dx, dy)
  TheApp:resetIdle()
  UIResizable.onMouseMove(self, x, y, dx, dy)
end

function UIMainMenu:buttonNewGame()
  local window = UINewGame(self.ui)
  self.ui:addWindow(window)
end

function UIMainMenu:buttonCustomCampaign()
  if TheApp.using_demo_files then
    self.ui:addWindow(UIInformation(self.ui, {_S.information.no_custom_game_in_demo}))
  else
    local window = UICustomCampaign(self.ui)
    self.ui:addWindow(window)
  end
end

function UIMainMenu:buttonCustomGame()
  if TheApp.using_demo_files then
    self.ui:addWindow(UIInformation(self.ui, {_S.information.no_custom_game_in_demo}))
  else
    local window = UICustomGame(self.ui)
    self.ui:addWindow(window)
  end
end

function UIMainMenu:buttonContinueGame()
  local most_recent_saved_game = FileTreeNode(self.ui.app.savegame_dir):getMostRecentlyModifiedChildFile(".%.sav$")
  if most_recent_saved_game then
    local path = most_recent_saved_game.path
    local app = self.ui.app
    local status, err = pcall(app.load, app, path)
    if not status then
      err = _S.errors.load_prefix .. err
      print(err)
      app.ui:addWindow(UIInformation(self.ui, {err}))
    end
  else
    local error = _S.errors.load_prefix .. _S.errors.no_games_to_contine
    print(error)
    self.ui.app.ui:addWindow(UIInformation(self.ui, {error}))
  end
end

function UIMainMenu:buttonLoadGame()
  local window = UILoadGame(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIMainMenu:buttonOptions()
  local window = UIOptions(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIMainMenu:buttonMapEdit()
  self.ui.app:mapEdit()
end

function UIMainMenu:buttonExit()
  self.ui:addWindow(UIConfirmDialog(self.ui, false,
  _S.tooltip.main_menu.quit,
  --[[persistable:quit_confirm_dialog]]function()
  self.ui.app:exit()
  end
  ))
end
