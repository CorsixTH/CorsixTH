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
--! This dialog is also used for errors and requires some special handling
class "UIConfirmDialog" (Window)

---@type UIConfirmDialog
local UIConfirmDialog = _G["UIConfirmDialog"]

local top_frame = 357
local top_frame_height = 22
local middle_frame = 358
local middle_frame_height = 11
local bottom_frame = 359
local text_width = 153

--! Initialise the Confirmation Dialog
--!param ui The UI
--!param must_pause (boolean) set whether this dialog should pause the game
--!param text (string) message to show
--!param callback_ok (function) what to do on yes/ok
--!param callback_cancel (function) what to do on no/cancel/close
function UIConfirmDialog:UIConfirmDialog(ui, must_pause, text, callback_ok, callback_cancel)
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
  self.white_font = app.gfx:loadFontAndSpriteTable("QData", "Font01V")
  self.text = text
  self.callback_ok = callback_ok  -- Callback function to launch if user chooses ok
  self.callback_cancel = callback_cancel -- Callback function to launch if user chooses cancel
  self.must_pause = must_pause

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
    :setTooltip(_S.tooltip.window_general.cancel):setSound("No4.wav")
  self:addPanel(362, 90, last_y + 10):makeButton(0, 10, 82, 34, 363, self.ok)
    :setTooltip(_S.tooltip.window_general.confirm):setSound("YesX.wav")

  self:registerKeyHandlers()
  if self.must_pause then self:systemPause() end
end

-- Confirm dialogs are used for errors, if it is an error then pause the game
function UIConfirmDialog:mustPause()
  return self.must_pause
end

--! Function to tell the game a system pause is needed
function UIConfirmDialog:systemPause()
  TheApp.world:setSystemPause(true)
end

function UIConfirmDialog:registerKeyHandlers()
  self:addKeyHandler("global_confirm", self.ok)
  self:addKeyHandler("global_confirm_alt", self.ok)
end

function UIConfirmDialog:cancel()
  self:close(false)
end

function UIConfirmDialog:ok()
  self:close(true)
end

--! Closes the confirm dialog
--!param confirmed (boolean or nil) whether to call the confirm callback (true) or cancel callback (false/nil)
function UIConfirmDialog:close(confirmed)
  -- NB: Window is closed before executing the callback in order to not save the confirmation dialog in a savegame
  if self.must_pause then TheApp.world:setSystemPause(false) end -- Error dealt with
  Window.close(self)
  if confirmed then
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
  self.white_font:drawWrapped(canvas, self.text, x + 17, y + 17, text_width)
end

function UIConfirmDialog:afterLoad(old, new)
  Window.afterLoad(self, old, new)
  self:registerKeyHandlers()
end
