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

--! Load Game Window
class "UILoadGame" (UIMenuList)

function UILoadGame:UILoadGame(ui, mode)
  -- Scan for savegames
  local saves = ui.app:scanSavegames()
  -- Make the list required by UIMenuList
  local items = {}
  for _, name in ipairs(saves) do
    items[#items + 1] = {
      name = name, 
      tooltip = _S.tooltip.load_game_window.load_game:format(name)
    }
  end
  self:UIMenuList(ui, mode, _S.load_game_window.caption, items)
end

function UILoadGame:buttonClicked(num)
  local filename = self.items[num + self.scrollbar.value - 1].name .. ".sav"
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
