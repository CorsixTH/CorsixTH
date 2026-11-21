--[[ Copyright (c) 2026 Toby "tobylane"

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

local UIResizable = cth_require("dialogs.resizable")

local col = {
   bg = Colours.PanelDefault,
   setting = Colours.Setting,
   title = Colours.Title,
   caption = Colours.Caption,
   button = Colours.PanelDefault,
   textbox = Colours.Textbox
}

--! A window for setting the scroll speed of the camera while pressing the SHIFT key..
class "UIShiftScrollSpeed" (UIResizable)

---@class UIShiftScrollSpeed: UIResizable
---@operator call: UIShiftScrollSpeed
local UIShiftScrollSpeed = _G["UIShiftScrollSpeed"] ---@type UIShiftScrollSpeed

function UIShiftScrollSpeed:UIShiftScrollSpeed(ui, callback)
  self:UIResizable(ui, 200, 140, col.bg)

  self.on_top = true
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.5)
  self.default_button_sound = "selectx.wav"
  self.shift_scrollspeed_temp = 4

  self.callback = callback

  self:addBevelPanel(20, 10, 160, 20, col.title):setLabel(_S.accessibility_window.shift_scroll_speed).lowered = true

  self:addBevelPanel(20, 50, 120, 20, col.caption, col.bg, col.bg):setLabel(_S.accessibility_window.shift_scroll_speed)
  --
  self.shift_scrollspeed_textbox = self:addBevelPanel(140, 50, 40, 20, col.textbox, col.bg, col.bg)
    :setTooltip(_S.tooltip.accessibility_window.shift_scroll_speed)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText(tostring(self.ui.app.config.shift_scroll_speed))

  --Apply and cancel.
  self:addBevelPanel(20, 90, 80, 40, col.button):setLabel(_S.options_window.apply)
    :makeButton(0, 0, 80, 40, nil, self.ok):setTooltip(_S.tooltip.accessibility_window.apply_shift_scrollspeed)
  self:addBevelPanel(100, 90, 80, 40, col.button):setLabel(_S.options_window.cancel)
    :makeButton(0, 0, 80, 40, nil, self.cancel):setTooltip(_S.tooltip.accessibility_window.cancel_shift_scrollspeed)
end

function UIShiftScrollSpeed:ok()
  self.shift_scrollspeed_temp = tonumber(self.shift_scrollspeed_textbox.text) or 4

  if self.shift_scrollspeed_temp < 1 then
    self.shift_scrollspeed_temp = 1
  elseif self.shift_scrollspeed_temp > 10 then
    self.shift_scrollspeed_temp = 10
  end

  self:close(true)
end

function UIShiftScrollSpeed:cancel()
  self:close(false)
end

function UIShiftScrollSpeed:onMouseUp(button, x, y)
  if not self:hitTest(x, y) then
    self:close(false)
  end
  UIResizable.onMouseUp(self, button, x, y)
end

--!param ok (boolean or nil) whether the resolution entry was confirmed (true) or aborted (false)
function UIShiftScrollSpeed:close(ok)
  UIResizable.close(self)

  if ok then
    self.shift_scrollspeed_textbox.text = self.shift_scrollspeed_temp or 4
    self.ui.app.config.shift_scroll_speed = self.shift_scrollspeed_textbox.text
    self.callback(self.shift_scrollspeed_textbox.text)
  else
    self.callback(self.ui.app.config.shift_scroll_speed)
  end
end

return UIShiftScrollSpeed
