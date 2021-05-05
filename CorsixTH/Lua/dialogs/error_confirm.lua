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

--! Clone of UIConfirmDialog. Handles errors requiring a confirmation with a forced pause.
class "UIErrConfirm" (Window)

---@type UIErrConfirm
local UIErrConfirm = _G["UIErrConfirm"]

local top_frame = 357
local top_frame_height = 22
local middle_frame = 358
local middle_frame_height = 11
local bottom_frame = 359
local text_width = 153

function UIErrConfirm:UIErrConfirm(ui, text, callback_ok, callback_cancel)
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
  local _, text_height = self.white_font:sizeOf(text, text_width)

  self:addPanel(top_frame, 0, 0)  -- Dialog header
  local last_y = top_frame_height

  for _ = 1, math.ceil(text_height / middle_frame_height) do
    self:addPanel(middle_frame, 0, last_y)  -- Dialog background
    self.height = self.height + middle_frame_height
    last_y = last_y + middle_frame_height
  end

  self:addPanel(bottom_frame, 0, last_y)  -- Dialog footer
  self:addPanel(360, 0, last_y + 10):makeButton(8, 10, 82, 34, 361, self.cancel)
    :setTooltip(_S.tooltip.window_general.cancel):setSound"No4.wav"
  self:addPanel(362, 90, last_y + 10):makeButton(0, 10, 82, 34, 363, self.ok)
    :setTooltip(_S.tooltip.window_general.confirm):setSound"YesX.wav"

  self:registerKeyHandlers()
  self:forcedPause()
end

-- Errors confirmations are used for errors and require the game to pause
function UIErrConfirm:mustPause()
  return true
end

-- Errors force pausing
function UIErrConfirm:forcedPause()
  TheApp.world:systemPause(true)
end

function UIErrConfirm:registerKeyHandlers()
  self:addKeyHandler("global_confirm", self.ok)
  self:addKeyHandler("global_confirm_alt", self.ok)
end

function UIErrConfirm:cancel()
  self:close(false)
end

function UIErrConfirm:ok()
  self:close(true)
end

--! Closes the confirm dialog
--!param ok (boolean or nil) whether to call the confirm callback (true) or cancel callback (false/nil)
function UIErrConfirm:close(ok)
  -- NB: Window is closed before executing the callback in order to not save the confirmation dialog in a savegame
  TheApp.world:systemPause(false) -- Error dealt with
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

function UIErrConfirm:draw(canvas, x, y)
  Window.draw(self, canvas, x, y)

  x, y = x + self.x, y + self.y
  self.white_font:drawWrapped(canvas, self.text, x + 17, y + 17, text_width)
end

function UIErrConfirm:afterLoad(old, new)
  Window.afterLoad(self, old, new)
  self:registerKeyHandlers()
end
