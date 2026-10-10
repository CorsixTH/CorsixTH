--[[ Copyright (c) 2025-2026 "lewri"

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

local col_bg = {red = 54, green = 69, blue = 79}


--! Constructor for the Fatal Error dialog.
--!param ui (ui)
--!param month (number) The month we are in, used for the autosave version guesstimate.
--!param gamelog_dir (string) Path to this session's gamelog.
--!param can_reset (boolean) Determine if this crash allows for an app reset.
function UIFatalError:UIFatalError(ui, day, month, gamelog_dir, can_reset)
  self:Window()
  local app = ui.app
  self.modal_class = "information"
  self.esc_closes = false
  self.on_top = true
  self.ui = ui
  self.draggable = false
  self.must_pause = true
  self.panel_sprites = app.gfx:loadSpriteTable("Data", "PulldV", true)
  self.blue_font = app.gfx:loadFontAndSpriteTable("QData", "Font04V", nil, nil, { apply_ui_scale = true })
  self.file_path_font = app.gfx:loadMenuFont()
  self.file_path_cursor = app.gfx:loadMainCursor("kill_rat")
  self.file_path_cursor_active = app.gfx:loadMainCursor("kill_rat_hover")

  -- Determine autosave name
  local function getAutosaveSuffix()
    local autosave_day = day
    local autosave_month = month
    local autosave_frequency = app.config.autosave_frequency
    if autosave_frequency == 1 then -- Monthly
      autosave_day = 1
    elseif autosave_frequency == 2 then -- Weekly
      -- It is possible to roll back to previous month
      if day < 7 then
        if month == 1 then
          autosave_month = 12
        else
          autosave_month = month - 1
        end
        day = 28
      end
      autosave_day = math.min(math.ceil(day / 7) * 7, 28)
    -- else Daily
    end
    return string.format("-%02d-%02d", autosave_month, autosave_day)
  end

  local autosave_date = getAutosaveSuffix()

  -- Work out what error message to show
  local error_text
  if not can_reset then
    -- Fully unusable state
    error_text = _S.errors.fatal_cant_reset:format(autosave_date)
  elseif app.config.debug then
    -- Some key handlers are still working, some debugging may be possible
    error_text = _S.errors.fatal_can_debug:format(autosave_date)
  else
    -- Some key handlers are working, as player is not in debug we can reset the program
    error_text = _S.errors.fatal_can_reset:format(autosave_date)
  end
  self.text = {error_text, gamelog_dir}
  self.can_reset = can_reset

  -- Window size parameters
  self.text_width = 480
  self.spacing = {
    l = 15,
    r = 15,
    t = 15,
    b = self.can_reset and 18 + 15 or 15, -- Size of close button + padding
  }

  self:onChangeLanguage()
end

function UIFatalError:mustPause()
  return self.must_pause
end

function UIFatalError:onChangeLanguage()
  local s = TheApp.gfx:getUIScale()
  local _, req_height_a = self.blue_font:sizeOf(
      self.text[1], self.text_width * s
  )
  local req_width_b, req_height_b = self.file_path_font:sizeOf(
      self.text[2], self.text_width * s
  )
  local text_height_a = math.ceil(req_height_a / s)
  local text_width_b = math.min(math.ceil(req_width_b / s), self.text_width)
  local text_height_b = math.ceil(req_height_b / s)
  local total_req_height = text_height_a + text_height_b

  self.width = self.spacing.l + self.text_width + self.spacing.r
  self.height = self.spacing.t + total_req_height + self.spacing.b
  self:setDefaultPosition(0.5, 0.5)

  self:removeAllPanels()

  for x = 4, self.width - 4, 4 do
    self:addPanel(12, x, 0, 0, 0, 1)  -- Dialog top and bottom borders
    self:addPanel(16, x, self.height - 4, 0, 0, 1)
  end
  for y = 4, self.height - 4, 4 do
    self:addPanel(18, 0, y, 0, 0, 1)  -- Dialog left and right borders
    self:addPanel(14, self.width - 4, y, 0, 0, 1)
  end
  self:addPanel(11, 0, 0, 0, 0, 1)  -- Border top left corner
  self:addPanel(17, 0, self.height - 4, 0, 0, 1)  -- Border bottom left corner
  self:addPanel(13, self.width - 4, 0, 0, 0, 1)  -- Border top right corner
  self:addPanel(15, self.width - 4, self.height - 4, 0, 0, 1)  -- Border bottom right corner

  -- Work out whether to show the file path link and close button
  if not self.can_reset then return end

  self.file_path_panel = self:addColourPanel(
      self.spacing.l, self.spacing.t + text_height_a,
      text_width_b, text_height_b, 0, 0, 0
  )
  self.file_path_panel.custom_draw =
      --[[persistable:fatal_error_file_path_panel]] function()
    end
  self.file_path_button = self.file_path_panel:makeButton(
      0, 0, text_width_b, text_height_b, nil, self.openFilePath
  )

  self:addPanel(19, self.width - 28, self.height - 28, 18, 18, 1):makeButton(0, 0, 18, 18, 20, self.close)
  .panel_for_sprite.custom_draw = --[[persistable:fatal_error_close_button]] function(panel, canvas, x, y)
      local ds = TheApp.gfx:getUIScale()
      x = x + panel.x * ds
      y = y + panel.y * ds
      panel.window.panel_sprites:draw(canvas, panel.sprite_index, x, y, { scaleFactor = ds })
      if self.active_hover then
        self.panel_sprites:draw(canvas, 20, x, y, { scaleFactor = ds })
      end
    end
end

--! Open the gamelog in the operating system's default application.
function UIFatalError:openFilePath()
local file_path = self.text[2]:gsub('"', '\\"')
openURL(file_path)
end

--! Change the cursor when hovering over the gamelog path.
function UIFatalError:onMouseMove(x, y)
  Window.onMouseMove(self, x, y)

  if self.file_path_button and self:hitTestPanel(x, y, self.file_path_panel) then
    self.ui:setCursor(self.ui.down_count == 0 and self.file_path_cursor or self.file_path_cursor_active)
  end
end

function UIFatalError:onMouseDown(button, x, y)
  Window.onMouseDown(self, button, x, y)
  if self.file_path_button and self:hitTestPanel(x, y, self.file_path_panel) then
    self.ui:setCursor(self.file_path_cursor_active)
  end
end

--! Diverges from Window:onMouseUp(button, x, y)
--! Play an error sound if user clicks outside dialog
function UIFatalError:onMouseUp(button, x, y)
  local s = TheApp.gfx:getUIScale()
  if x < 0 or y < 0 or x >= self.width * s or y >= self.height * s then
    self.ui:playSound("wrong2.wav")
  end
  Window.onMouseUp(self, button, x, y)
end

function UIFatalError:draw(canvas, x, y)
  local s = TheApp.gfx:getUIScale()
  local dx, dy = x + self.x * s, y + self.y * s
  local background = canvas:mapRGB(
      col_bg["red"], col_bg["green"], col_bg["blue"]
  )

  canvas:drawRect(
      background, dx + 4 * s, dy + 4 * s, self.width * s - 8 * s, self.height * s - 8 * s
  )

  local last_y = dy + self.spacing.t * s
  last_y = self.blue_font:drawWrapped(
      canvas, self.text[1], dx + self.spacing.l * s, last_y, self.text_width * s
  )

  self.file_path_font:drawWrapped(
      canvas, self.text[2], dx + self.spacing.l * s, last_y, self.text_width * s
  )

  Window.draw(self, canvas, x, y)
end

--! Diverges from Window:hitTest(x, y)
--! Fake cursor positioning to always 'hit' Window to disable any other interaction
function UIFatalError:hitTest(x, y)
  return true
end

--! Closing this dialog must be via the 'x' button (if available)
function UIFatalError:close()
  Window.close(self)
  if TheApp.config.debug then return end -- Debug mode re-enters the game
  self.ui:resetApp()
end

function UIFatalError:afterLoad(old, new)
  Window.afterLoad(self, old, new)
end
