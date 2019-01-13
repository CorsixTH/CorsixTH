--[[ Copyright (c) 2009 Peter "Corsix" Cawley

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

--! Dialog for "Are you sure you want to quit?" and similar yes/no questions.
class "UIConfirmDialog" (Window)

---@type UIConfirmDialog
local UIConfirmDialog = _G["UIConfirmDialog"]

function UIConfirmDialog:UIConfirmDialog(ui, text, callback_ok, callback_cancel)
  self:Window()

  local app = ui.app
  self.modal_class = "information"
  self.esc_closes = true
  self.on_top = true
  self.ui = ui
  self.width = 183
  self.height = 199
  self:setDefaultPosition(0.5, 0.5)
  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req04V", true)
  self.white_font = app.gfx:loadFont("QData", "Font01V")
  self.text = text
  self.callback_ok = callback_ok  -- Callback function to launch if user chooses ok
  self.callback_cancel = callback_cancel -- Callback function to launch if user chooses cancel

  -- Check how "high" the dialog must be
  local w, h = self.white_font:sizeOf(text)

  self:addPanel(357, 0, 0)  -- Dialog header
  local last_y = 22
  -- Rough estimate of how many rows it will be when drawn.
  for y = 22, h * (w / 160) * 1.4, 11 do -- Previous value: 136
    self:addPanel(358, 0, y)  -- Dialog background
    self.height = self.height + 11
    last_y = last_y + 11
  end

  self:addPanel(359, 0, last_y)  -- Dialog footer
  self:addPanel(360, 0, last_y + 10):makeButton(8, 10, 82, 34, 361, self.cancel)
    :setTooltip(_S.tooltip.window_general.cancel):setSound"No4.wav"
  self:addPanel(362, 90, last_y + 10):makeButton(0, 10, 82, 34, 363, self.ok)
    :setTooltip(_S.tooltip.window_general.confirm):setSound"YesX.wav"

  self:addKeyHandler("return", self.ok)
  self:addKeyHandler("keypad enter", self.ok)
end

function UIConfirmDialog:cancel()
  self:close(false)
end

function UIConfirmDialog:ok()
  self:close(true)
end

--! Closes the confirm dialog
--!param ok (boolean or nil) whether to call the confirm callback (true) or cancel callback (false/nil)
function UIConfirmDialog:close(ok)
  -- NB: Window is closed before executing the callback in order to not save the confirmation dialog in a savegame
  Window.close(self)
  if ok then
    if self.callback_ok then
      self.callback_ok()
    end
  else
    if self.callback_cancel then
      self.callback_cancel()
    end
  end
end

function UIConfirmDialog:draw(canvas, x, y)
  Window.draw(self, canvas, x, y)

  x, y = x + self.x, y + self.y
  self.white_font:drawWrapped(canvas, self.text, x + 17, y + 17, 153)
end

function UIConfirmDialog:afterLoad(old, new)
  if old < 101 then
    self:removeKeyHandler("enter")
    self:addKeyHandler("return", self.ok)
  end
  if old < 104 then
    self:addKeyHandler("keypad enter", self.ok)
  end
end
