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
class "UIMainMenu" (UIResizable)

local col_bg = {
  red = 154,
  green = 146,
  blue = 198,
}

function UIMainMenu:UIMainMenu(ui)
  self:UIResizable(ui, 200, 341, col_bg)

  local app = ui.app
  self.esc_closes = false
  self.modal_class = "main menu"
  self.on_top = true
  self:setDefaultPosition(0.5, 0.25)

  -- The main menu also shows the version number of the player's copy of the game.
  self.label_font = TheApp.gfx:loadFont("QData", "Font01V")
  self.version_number = TheApp:getVersion()

  -- individual buttons
  self.default_button_sound = "selectx.wav"
  self:addBevelPanel(20, 20, 160, 40, col_bg):setLabel(_S.main_menu.new_game):makeButton(0, 0, 160, 40, nil, self.buttonNewGame):setTooltip(_S.tooltip.main_menu.new_game)
  self:addBevelPanel(20, 65, 160, 40, col_bg):setLabel(_S.main_menu.custom_level):makeButton(0, 0, 160, 40, nil, self.buttonCustomGame):setTooltip(_S.tooltip.main_menu.custom_level)
  self:addBevelPanel(20, 110, 160, 40, col_bg):setLabel(_S.main_menu.continue):makeButton(0, 0, 160, 40, nil, self.buttonContinueGame):setTooltip(_S.tooltip.main_menu.continue)
  self:addBevelPanel(20, 155, 160, 40, col_bg):setLabel(_S.main_menu.load_game):makeButton(0, 0, 160, 40, nil, self.buttonLoadGame):setTooltip(_S.tooltip.main_menu.load_game)
  self:addBevelPanel(20, 200, 160, 40, col_bg):setLabel(_S.main_menu.options):makeButton(0, 0, 160, 40, nil, self.buttonOptions):setTooltip(_S.tooltip.main_menu.options)
  self:addBevelPanel(20, 265, 160, 40, col_bg):setLabel(_S.main_menu.exit):makeButton(0, 0, 160, 40, nil, self.buttonExit):setTooltip(_S.tooltip.main_menu.exit)
end

function UIMainMenu:getSavedWindowPositionName()
  return "main_menu_group"
end

local label_y = { 27, 75, 123, 171, 231 }

function UIMainMenu:draw(canvas, x, y)
  UIResizable.draw(self, canvas, x, y)
  x, y = self.x + x, self.y + y

  -- Move the version string up a bit if also showing the savegame version.
  local ly = y + 325
  if TheApp.config.debug then
    self.label_font:draw(canvas, _S.main_menu.savegame_version .. TheApp.savegame_version, x + 5, ly, 190, 0, "right")
    ly = ly - 15
  end
  self.label_font:draw(canvas, _S.main_menu.version .. self.version_number, x + 5, ly, 190, 0, "right")
end

function UIMainMenu:buttonNewGame()
  local window = UINewGame(self.ui)
  self.ui:addWindow(window)

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
  local most_recent_saved_game = FileTreeNode(self.ui.app.savegame_dir):getMostRecentlyModifiedChildFile(".sav")
  if most_recent_saved_game then
    local _, prefix_end_i = string.find(most_recent_saved_game.path, self.ui.app.savegame_dir)
    local path = string.sub(most_recent_saved_game.path, prefix_end_i + 1, string.len(most_recent_saved_game.path))

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

function UIMainMenu:buttonExit()
  self.ui:addWindow(UIConfirmDialog(self.ui,
  _S.tooltip.main_menu.quit,
  --[[persistable:quit_confirm_dialog]]function()
  self.ui.app:exit()
  end
  ))
end
