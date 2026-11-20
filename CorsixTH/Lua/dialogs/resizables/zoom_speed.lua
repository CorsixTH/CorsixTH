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

--! Window to set the zoom speed of the scroll wheel while in-game.
class "UIZoomSpeed" (UIResizable)

---@class UIZoomSpeed: UIResizable
---@operator call: UIZoomSpeed
local UIZoomSpeed = _G["UIZoomSpeed"] ---@type UIZoomSpeed

function UIZoomSpeed:UIZoomSpeed(ui, callback)
  self:UIResizable(ui, 200, 140, col.bg)

  self.on_top = true
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.5)
  self.default_button_sound = "selectx.wav"
  self.zoomspeed_temp = 80

  self.callback = callback

  --
  self:addBevelPanel(20, 10, 160, 20, col.title):setLabel(_S.accessibility_window.zoom_speed).lowered = true

  --
  self:addBevelPanel(20, 50, 90, 20, col.caption, col.bg, col.bg):setLabel(_S.accessibility_window.zoom_speed)

  --
  self.zoomspeed_textbox = self:addBevelPanel(110, 50, 70, 20, col.textbox, col.bg, col.bg)
    :setTooltip(_S.tooltip.accessibility_window.zoom_speed)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText( tostring(self.ui.app.config.zoom_speed) )

  --Apply and cancel.
  self:addBevelPanel(20, 90, 80, 40, col.button):setLabel(_S.options_window.apply)
    :makeButton(0, 0, 80, 40, nil, self.ok):setTooltip(_S.tooltip.accessibility_window.apply_zoomspeed)
  self:addBevelPanel(100, 90, 80, 40, col.button):setLabel(_S.options_window.cancel)
    :makeButton(0, 0, 80, 40, nil, self.cancel):setTooltip(_S.tooltip.accessibility_window.cancel_zoomspeed)
end

function UIZoomSpeed:ok()
  self.zoomspeed_temp = tonumber( self.zoomspeed_textbox.text ) or 80

  if self.zoomspeed_temp < 10 then
    self.zoomspeed_temp = 10
  elseif self.zoomspeed_temp > 1000 then
    self.zoomspeed_temp = 1000
  end

  self:close(true)
end

function UIZoomSpeed:cancel()
  self:close(false)
end

function UIZoomSpeed:onMouseUp(button, x, y)
  if not self:hitTest(x, y) then
    self:close(false)
  end
  UIResizable.onMouseUp(self, button, x, y)
end

--!param ok (boolean or nil) whether the resolution entry was confirmed (true) or aborted (false)
function UIZoomSpeed:close(ok)
  UIResizable.close(self)

  if ok then
    self.zoomspeed_textbox.text = self.zoomspeed_temp or 2
    self.ui.app.config.zoom_speed = self.zoomspeed_textbox.text
    self.callback(self.zoomspeed_textbox.text)
  else
    self.callback(self.ui.app.config.zoom_speed)
  end
end

return UIZoomSpeed
