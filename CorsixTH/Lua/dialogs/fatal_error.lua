--[[ Copyright (c) 2025 "lewri"

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

-- The UIFatalError window should be presented only when a fatal, non-recoverable error
-- of the program occurs and needs to be restarted.
class "UIFatalError" (Window)

---@type UIFatalError
local UIFatalError = _G["UIFatalError"]

local col_bg = {red = 204, green = 41, blue = 0}

--! Constructor for the Fatal Error dialog.
--!param ui (ui)
--!param month (number) The month we are in, used for the autosave version guesstimate.
--!param gamelog_dir (string) Path to this session's gamelog.
--!param can_reset (boolean) Determine if this crash allows for an app reset.
function UIFatalError:UIFatalError(ui, month, gamelog_dir, can_reset)
  self:Window()
  TheApp.config.debug = false

  local app = ui.app
  self.modal_class = "information"
  self.esc_closes = false
  self.on_top = true
  self.ui = ui
  self.draggable = false
  self.must_pause = true
  self:systemPause()
  self.panel_sprites = app.gfx:loadSpriteTable("Data", "PulldV", true)
  self.blue_font = app.gfx:loadFont("QData", "Font04V")
  self.built_in_font = app.config.unicode and self.blue_font or app.gfx:loadMenuFont()

  -- Work out what error message to show
  local error_text
  if not can_reset then
    -- Fully unusable state
    error_text = _S.errors.fatal_cant_reset:format(month)
  elseif app.config.debug then
    -- Some key handlers are still working, some debugging may be possible
    error_text = _S.errors.fatal_can_debug:format(month)
  else
    -- Some key handlers are working, as player is not in debug we can reset the program
    error_text = _S.errors.fatal_can_reset:format(month)
  end
  self.text = {error_text, gamelog_dir}
  self.can_reset = can_reset

  -- Window size parameters
  self.text_width = 480
  self.spacing = {
    l = 15,
    r = 15,
    t = 15,
    b = ui.app.config.debug and 18 + 15 or 15, -- Size of close button + padding
  }

  self:onChangeLanguage()
end

function UIFatalError:mustPause()
  return self.must_pause
end

function UIFatalError:systemPause()
  TheApp.world:setSystemPause(true)
end

function UIFatalError:onChangeLanguage()
  local total_req_height = 0
    local _, req_height_a = self.blue_font:sizeOf(self.text[1], self.text_width)
    local _, req_height_b = self.built_in_font:sizeOf(self.text[2], self.text_width)
    total_req_height = total_req_height + req_height_a + req_height_b

  self.width = self.spacing.l + self.text_width + self.spacing.r
  self.height = self.spacing.t + total_req_height + self.spacing.b
  self:setDefaultPosition(0.5, 0.5)

  self:removeAllPanels()

  for x = 4, self.width - 4, 4 do
    self:addPanel(12, x, 0)  -- Dialog top and bottom borders
    self:addPanel(16, x, self.height - 4)
  end
  for y = 4, self.height - 4, 4 do
    self:addPanel(18, 0, y)  -- Dialog left and right borders
    self:addPanel(14, self.width - 4, y)
  end
  self:addPanel(11, 0, 0)  -- Border top left corner
  self:addPanel(17, 0, self.height - 4)  -- Border bottom left corner
  self:addPanel(13, self.width - 4, 0)  -- Border top right corner
  self:addPanel(15, self.width - 4, self.height - 4)  -- Border bottom right corner

  -- Work out whether to show the close button
  if not self.can_reset then return end
  self:addPanel(19, self.width - 28, self.height - 28):makeButton(0, 0, 18, 18, 20, self.close)
end

--! Diverges from Window:onMouseUp(button, x, y)
--! Play an error sound if user clicks outside dialog
function UIFatalError:onMouseUp(button, x, y)
  if x < 0 or y < 0 or x >= self.width or y >= self.height then
    self.ui:playSound("wrong2.wav")
  end
  Window.onMouseUp(self, button, x, y)
end

function UIFatalError:draw(canvas, x, y)
  local dx, dy = x + self.x, y + self.y
  local background = self.black_background and canvas:mapRGB(0, 0, 0) or
      canvas:mapRGB(col_bg["red"], col_bg["green"], col_bg["blue"])
  canvas:drawRect(background, dx + 4, dy + 4, self.width - 8, self.height - 8)
  local last_y = dy + self.spacing.t
    last_y = self.blue_font:drawWrapped(canvas, self.text[1], dx + self.spacing.l, last_y, self.text_width)
    last_y = self.built_in_font:drawWrapped(canvas, self.text[2], dx + self.spacing.l, last_y, self.text_width)

  Window.draw(self, canvas, x, y)
end

--! Diverges from Window:hitTest(x, y)
--! Fake cursor positioning to always 'hit' Window to disable any other interaction
function UIFatalError:hitTest(x, y)
  return true
end

--! Closing this dialog must be via the 'x' button (if available)
function UIFatalError:close()
  TheApp.world:setSystemPause(false)
  Window.close(self)
  if TheApp.config.debug then return end -- Debug mode re-enters the game
  self.ui:resetApp()
end

function UIFatalError:afterLoad(old, new)
  Window.afterLoad(self, old, new)
end
