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

dofile("dialogs/menu_list_dialog")

--! Save Game Window
class "UISaveGame" (UIMenuList)

function UISaveGame:UISaveGame(ui)
  
  -- Scan for savegames
  local saves = ui.app:scanSavegames()
  -- Make the list required by UIMenuList
  local items = {}
  for _, name in ipairs(saves) do
    items[#items + 1] = {
      name = name, 
      tooltip = _S.tooltip.save_game_window.save_game:format(name)
    }
  end
  self:UIMenuList(ui, "game", _S.save_game_window.caption, items, 8)
  
  -- Textbox for entering new savegame name
  self.new_savegame_textbox = self:addBevelPanel(20, 190, 160, 17, self.col_bg):setLabel(_S.save_game_window.new_save_game):setTooltip(_S.tooltip.save_game_window.new_save_game)
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
function UISaveGame:buttonClicked(num)
  local filename = self.items[num + self.scrollbar.value - 1].name
  self:trySave(filename)
end

--! Try to save the game with given filename; if already exists, create confirmation window first.
function UISaveGame:trySave(filename)
  local found = false
  for _, save in ipairs(self.items) do
    if save.name:lower() == filename:lower() then
      found = true
      break
    end
  end
  if found then
    self.ui:addWindow(UIConfirmDialog(self.ui, _S.confirmation.overwrite_save, --[[persistable:save_game_confirmation]] function() self:doSave(filename) end))
  else
    self:doSave(filename)
  end
end

--! Actually do save the game with given filename.
function UISaveGame:doSave(filename)
  filename = filename .. ".sav"
  local ui = self.ui
  self:close()
  
  local status, err = pcall(SaveGameFile, filename)
  if not status then
    err = _S.errors.save_prefix .. err
    print(err)
    ui:addWindow(UIInformation(ui, {err}))
  end
end
