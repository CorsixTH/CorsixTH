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

dofile("dialogs/file_browser")

--! Save Game Window
class "UISaveGame" (UIFileBrowser)

local pathsep = package.config:sub(1, 1)

local col_textbox = {
  red = 0,
  green = 0,
  blue = 0,
}

local col_highlight = {
  red = 174,
  green = 166,
  blue = 218,
}

local col_shadow = {
  red = 134,
  green = 126,
  blue = 178,
}

function UISaveGame:UISaveGame(ui)

  self:UIFileBrowser(ui, "game", _S.save_game_window.caption, 265)
  
  -- Textbox for entering new savegame name
  self.new_savegame_textbox = self:addBevelPanel(5, 310, self.width - 10, 17, col_textbox, col_highlight, col_shadow)
    :setLabel(_S.save_game_window.new_save_game, nil, "left"):setTooltip(_S.tooltip.save_game_window.new_save_game)
    :makeTextbox(--[[persistable:save_game_new_savegame_textbox_confirm_callback]] function() self:confirmName() end,
    --[[persistable:save_game_new_savegame_textbox_abort_callback]] function() self:abortName() end)
end

--! Function called when textbox is aborted (e.g. by pressing escape)
function UISaveGame:abortName()
  self.new_savegame_textbox.text = ""
  self.new_savegame_textbox.panel:setLabel(_S.save_game_window.new_save_game)
end

--! Function called when textbox is confirmed (e.g. by pressing enter)
function UISaveGame:confirmName()
  local filename = self.new_savegame_textbox.text
  if filename == "" then
    self:abortName()
    return
  end
  self:trySave(filename)
end

--! Function called by clicking button of existing save #num
function UISaveGame:choiceMade(name)
  self:trySave(name)
end

--! Try to save the game with given filename; if already exists, create confirmation window first.
function UISaveGame:trySave(filename)
  if lfs.attributes(self.ui.app.savegame_dir .. filename .. ".sav", "size") ~= nil then
    self.ui:addWindow(UIConfirmDialog(self.ui, _S.confirmation.overwrite_save, --[[persistable:save_game_confirmation]] function() self:doSave(filename) end))
  else
    self:doSave(filename)
  end
end

--! Actually do save the game with given filename.
function UISaveGame:doSave(filename)
  filename = filename .. ".sav"
  local ui = self.ui
  local app = ui.app
  self:close()
  
  local status, err = pcall(app.save, app, filename)
  if not status then
    err = _S.errors.save_prefix .. err
    print(err)
    ui:addWindow(UIInformation(ui, {err}))
  end
end
