--[[ Copyright (c) 2023 Albert "Alberth" Hofkamp

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

class "UILevelEditor" (UIResizable)

---@type UILevelEditor
local UILevelEditor = _G["UILevelEditor"]


local col_bg = {red = 154, green = 146, blue = 198}

local EDITOR_WINDOW_XSIZE = 640
local EDITOR_WINDOW_YSIZE = 480

function UILevelEditor:UILevelEditor(ui)
  self:UIResizable(ui, EDITOR_WINDOW_XSIZE, EDITOR_WINDOW_YSIZE, col_bg)
  self.resizable = false

  self.ui = ui
  self.on_top = true

  self:setDefaultPosition(0.1, 0.1)
end

