--[[ Copyright (c) 2025 Stephen Baker

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

local TH = require("TH")
local lfsext = TH.lfsExt()

local file_extensions = {".sf2", ".sf3"}

--! Window where the user can choose a soundfont file.
class "UIChooseSoundfont" (UIFileBrowser)

---@type UIChooseSoundfont
local UIChooseSoundfont = _G["UIChooseSoundfont"]

function UIChooseSoundfont:UIChooseSoundfont(ui, mode, soundOptionsUI, choiceCallback)
  self.soundOptionsUI = soundOptionsUI
  self.choiceCallback = choiceCallback

  -- Create the root item (or items, on Windows).
  local root
  local roots = lfsext.volumes()
  if #roots > 1 then
    for k, v in pairs(roots) do
      roots[k] = FilteredFileTreeNode(v, file_extensions)
    end
    root = DummyRootNode(roots)
  else
    root = FilteredFileTreeNode(roots[1], file_extensions)
  end
  self:UIFileBrowser(ui, mode, _S.audio_window.soundfont_location_caption:format(".sf2, .sf3"), 265, root)
end

--! Callback when a file is chosen
function UIChooseSoundfont:choiceMade(name)
  if self.choiceCallback then
    self.choiceCallback(self.soundOptionsUI, name)
  end
  self:close()
end

--! Close the dialog and return to the previous dialog
function UIChooseSoundfont:close()
  UIResizable.close(self)
  if self.mode == "menu" then
    self.ui:addWindow(UISoundSettings(self.ui, "menu"))
  end
end
