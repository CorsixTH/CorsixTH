--[[ Copyright (c) 2013 Edvin "Lego3" Linge

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

local TH = require "TH"
local lfsext = TH.lfsExt()

--! Window where the user can choose a font file.
class "UIChooseFont" (UIFileBrowser)

---@type UIChooseFont
local UIChooseFont = _G["UIChooseFont"]

function UIChooseFont:UIChooseFont(ui, mode)
  -- Create the root item (or items, on Windows).
  local root
  local roots = lfsext.volumes()
  if #roots > 1 then
    for k, v in pairs(roots) do
      roots[k] = FilteredFileTreeNode(v, {".ttc", ".otf", ".ttf"})
    end
    root = DummyRootNode(roots)
  else
    root = FilteredFileTreeNode(roots[1], {".ttc", ".otf", ".ttf"})
  end
  self:UIFileBrowser(ui, mode, _S.font_location_window.caption:format(".ttc, .otf, .ttf"), 265, root)
end

--! Function called by clicking button of existing save #num
function UIChooseFont:choiceMade(name)
  local app = TheApp
  app.config.unicode_font = name
  app:saveConfig()
  app.gfx:loadFontFile()
  if class.is(self.parent, UIOptions) then
    self.parent:checkForAvailableLanguages()
  end
  self:close()
end

function UIChooseFont:close()
  UIResizable.close(self)
  if self.mode == "menu" then
    self.ui:addWindow(UIOptions(self.ui, self.mode))
  end
end
