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

dofile "window"

--! Top-level container for all other user-interface components.
class "UI" (Window)

local TH = require "TH"
local WM = require "sdl".wm
local SDL = require "sdl"
local lfs = require "lfs"
local pathsep = package.config:sub(1, 1)

local function invert(t)
  local r = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      for _, v in ipairs(v) do
        r[v] = k
      end
    else
      r[v] = k
      r[k] = v
    end
  end
  return r
end

function UI:initKeyAndButtonCodes()
  self.key_codes = {
    backspace = 8,
    esc = 27,
    [" "] = 32,
    up = 273,
    down = 274,
    right = 275,
    left = 276,
    F8 = 289,
    F9 = 290,
    F10 = 291,
    F11 = 292,
    F12 = 293,
    Enter = 13,
    shift = {303, 304},
    ctrl = {305, 306},
    alt = {307, 308, 313},
  }
  -- Add "A" through "Z"
  for i = string.byte"a", string.byte"z" do
    self.key_codes[string.char(i):lower()] = i
    self.key_codes[string.char(i):upper()] = i
  end
  -- Add "0" through "9"
  for i = string.byte"0", string.byte"9" do
    self.key_codes[string.char(i)] = i
  end
  self.key_codes = invert(self.key_codes)

  self.button_codes = invert {
    left = 1,
    middle = 2,
    right = 3,
  }
end

local LOADED_DIALOGS = false

function UI:UI(app)
  self:Window()
  self:initKeyAndButtonCodes()
  self.app = app
  self.screen_offset_x = 0
  self.screen_offset_y = 0
  self.cursor = nil
  self.cursor_x = 0
  self.cursor_y = 0
  self.cursor_entity = nil
  -- through trial and error, this palette seems to give the desired result (white background, black text)
  -- NB: Need a palette present in both the full game and in the demo data
  local palette = app.gfx:loadPalette("QData", "PREF01V.PAL")
  palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
  self.tooltip_font = app.gfx:loadFont("QData", "Font00V", false, palette)
  self.tooltip = nil
  self.tooltip_counter = 0
  self.background = false
  -- tick_scroll_amount will either hold a table containing x and y values, at
  -- at least one of which being non-zero. If both x and y are zero, then the
  -- value false should be used instead, so that tests to see if there is any
  -- scrolling to be done are quick and simple.
  self.tick_scroll_amount = false
  self.tick_scroll_amount_mouse = false
  self.tick_scroll_mult = 1
  self.modal_windows = {
    -- [class_name] -> window,
  }
  -- Windows can tell UI to pass specific codes forward to them. See addKeyHandler and removeKeyHandler
  self.key_handlers = {}
  
  self.keyboard_repeat_enable_count = 0
  self.down_count = 0
  self.default_cursor = app.gfx:loadMainCursor("default")
  self.down_cursor = app.gfx:loadMainCursor("clicked")
  self.grab_cursor = app.gfx:loadMainCursor("grab")
  self.edit_room_cursor = app.gfx:loadMainCursor("edit_room")
  self.waiting_cursor = app.gfx:loadMainCursor("sleep")
  
  if not LOADED_DIALOGS then
    app:loadLuaFolder("dialogs", true)
    LOADED_DIALOGS = true
  end
  
  self:setCursor(self.default_cursor)
  
end

-- Used for everything except music and announcements
function UI:playSound(name)
  if self.app.audio.play_sounds then
    self.app.audio:playSound(name)
  end
end

-- Used for announcements only
function UI:playAnnouncement(name)
  if self.app.audio.play_announcements then
    self.app.audio:playSound(name, nil, true)
  end
end

function UI.makeVisibleDiamond(scr_w, scr_h)
  local map_w = TheApp.map.width
  local map_h = TheApp.map.height
  assert(map_w == map_h, "UI limiter requires square map")
  
  -- The visible diamond is the region which the top-left corner of the screen
  -- is limited to, and ensures that the map always covers all of the screen.
  -- Its verticies are at (x + w, y), (x - w, y), (x, y + h), (x, y - h).
  return {
    x = - scr_w / 2,
    y = 16 * map_h - scr_h / 2,
    w = 32 * map_h - scr_h - scr_w / 2,
    h = 16 * map_h - scr_h / 2 - scr_w / 4,
  }
end

function UI:debugMakeAdviserTalk()
  local id = 2
  while #_S(54, id):gsub("^%.$", "") == 0 do
    id = math.floor(math.random(3, 115))
  end
  self.adviser:say(_S(54, id))
end

function UI:showBeta1Info()
  local message = {
    {             text = _S.fax.welcome.beta1[1]},
    {offset =  8, text = _S.fax.welcome.beta1[2]},
    {offset =  8, text = _S.fax.welcome.beta1[3]},
    {offset =  8, text = _S.fax.welcome.beta1[4]},
    {offset = 16, text = _S.fax.welcome.beta1[5]},
    {offset =  8, text = _S.fax.welcome.beta1[6]},
  }
  self.bottom_panel:queueMessage("information", message)
end

function UI:setDefaultCursor(cursor)
  if cursor == nil then
    cursor = "default"
  end
  if type(cursor) == "string" then
    cursor = self.app.gfx:loadMainCursor(cursor)
  end
  if self.cursor == self.default_cursor then
    self:setCursor(cursor)
  end
  self.default_cursor = cursor
end

function UI:setCursor(cursor)
  if cursor ~= self.cursor then
    self.cursor = cursor
    if cursor.use then
      -- Cursor is a true C cursor, perhaps even a hardware cursor.
      -- Make the real cursor visible, and use this as it.
      self.simulated_cursor = nil
      WM.showCursor(true)
      cursor:use(self.app.video)
    else
      -- Cursor is a Lua simulated cursor.
      -- Make the real cursor invisible, and simulate it with this.
      WM.showCursor(false)
      self.simulated_cursor = cursor
    end
  end
end

function UI:drawTooltip(canvas)
  if not self.tooltip or not self.tooltip_counter or self.tooltip_counter > 0 then
    return
  end
  
  local x, y = self.tooltip.x, self.tooltip.y
  if not self.tooltip.x then
    -- default to cursor position for (lower left corner of) tooltip
    x, y = self:getCursorPosition()
  end
  
  if self.tooltip_font then
    self.tooltip_font:drawTooltip(canvas, self.tooltip.text, x, y)
  end
end

function UI:draw(canvas)
  local app = self.app
  local config = app.config
  if self.background then
    canvas:fillBlack()
    self.background:draw(canvas, (app.config.width - self.background_width) / 2, (app.config.height - self.background_height) / 2)
  end
  Window.draw(self, canvas, 0, 0)
  self:drawTooltip(canvas)
  if self.simulated_cursor then
    self.simulated_cursor.draw(canvas, self.cursor_x, self.cursor_y)
  end
end

local scroll_keys = {
  up    = {x =   0, y = -10},
  right = {x =  10, y =   0},
  down  = {x =   0, y =  10},
  left  = {x = -10, y =   0},
}

-- Adds a key handler for a window. Code = keycode, callback = which function to call.
function UI:addKeyHandler(code, window, callback, ...)
  code = self.key_codes[code] or code
  if not self.key_handlers[code] then -- No handlers for this code? Create a new table.
    self.key_handlers[code] = {}
  end
  table.insert(self.key_handlers[code], {window = window, callback = callback, ...})
end

-- Remove the key handler for this code.
function UI:removeKeyHandler(code, window)
  code = self.key_codes[code] or code
  if self.key_handlers[code] then
    for index,callback in pairs(self.key_handlers[code]) do
      if callback.window == window then
        table.remove(self.key_handlers[code], index)
      end
    end
    -- If last entry in keyHandlers[code] was removed, delete the (now empty) list
    if #self.key_handlers[code] == 0 then
      self.key_handlers[code] = nil
    end
  end
end

-- Enables a keyboard repeat.
-- Default is 500 delay, interval 30
function UI:enableKeyboardRepeat(delay, interval)
  self.keyboard_repeat_enable_count = self.keyboard_repeat_enable_count + 1
  SDL.modifyKeyboardRepeat(delay or nil, interval or nil)
end

-- Disables the keyboard repeat.
function UI:disableKeyboardRepeat()
  if self.keyboard_repeat_enable_count <= 1 then
    self.keyboard_repeat_enable_count = 0
    SDL.modifyKeyboardRepeat(0, 0)
  else
    self.keyboard_repeat_enable_count = self.keyboard_repeat_enable_count - 1
  end
end

function UI:onChangeResolution()
  -- Inform windows of resolution change
  for _, window in ipairs(self.windows) do
    window:onChangeResolution()
  end
end

function UI:registerTextBox(box)
  self.textboxes[#self.textboxes] = box
end

function UI:unregisterTextBox(box)
  for num, b in pairs(self.textboxes) do
    if b == box then
      self.textboxes[num] = nil
      break
    end
  end
end

function UI:onKeyDown(code)
  -- Are there any text boxes expecting input?
  for _, box in pairs(self.textboxes) do
    if box.enabled and box.active then
      local handled = box:input(code)
      if handled then
        return true
      end
    end
  end

  -- Are there any window-specified keyHandlers that want this code?
  local keyHandlers = self.key_handlers
  if keyHandlers[code] then
    local callback = keyHandlers[code][ #keyHandlers[code] ]    -- Convenience variable.
    callback.callback(callback.window, unpack(callback))        -- Call only the latest (last) handler for this code.
    return true                                                 -- Because sometimes even cursor keys are taken over.
  end
  
  local key = self.key_codes[code]
  if not key then
    return
  end
  if self.buttons_down[key] == false then
    self.buttons_down[key] = true
  end
  if key == "esc" then
    -- Close the topmost window first
    local first = self.windows[1]
    if first.on_top and first.esc_closes then
      first:close()
      return true
    end
    for i = #self.windows, 1, -1 do
      local window = self.windows[i]
      if window.esc_closes then
        window:close()
        return true
      end
    end
  elseif key == "F10" then -- Restart
    debug.getregistry()._RESTART = true
    TheApp.running = false
    return true
  elseif self.buttons_down.alt and key == "Enter" then --Alt + Enter: Toggle Fullscreen
    local modes = self.app.modes
    
    -- Search in modes table if it contains a fullscreen value and keep the index
    -- If not found, we will add an index at end of table
    local index = #modes + 1
    for i=1, #modes do
      if modes[i] == "fullscreen" then
        index = i
        break
      end
    end
    
    -- Toggle Fullscreen mode
    self.app.fullscreen = not self.app.fullscreen
    if self.app.fullscreen then
      modes[index] = "fullscreen"
    else
      modes[index] = ""
    end
    self.app.video:endFrame()
    self.app.video = assert(TH.surface(self.app.config.width, self.app.config.height, unpack(modes))) -- Apply changements
    self.app.gfx:updateTarget(self.app.video)
    self.app.video:startFrame()
    self.cursor:use(self.app.video) -- Redraw cursor
    return true
  elseif key == "S" then -- Take a screenshot
     -- Find an index for screenshot which is not already used
    local i = 0
    local filename
    repeat
      filename = (".%sscreenshot%i.bmp"):format(pathsep, i)
      i = i + 1
    until lfs.attributes(filename, "size") == nil
    self.app.video:takeScreenshot(filename) -- Take screenshot
    return true
  end
end

function UI:onKeyUp(code)
  if self.key_handlers[code] then
    return true
  end

  local key = self.key_codes[code]
  if not key then
    return
  end
  if self.buttons_down[key] == true then
    self.buttons_down[key] = false
  end
end

function UI:onMouseDown(code, x, y)
  local repaint = false
  local button = self.button_codes[code]
  if not button then
    return
  end
  if self.cursor_entity == nil and self.down_count == 0 and
    self.cursor == self.default_cursor then
    self:setCursor(self.down_cursor)
    repaint = true
  end
  self.down_count = self.down_count + 1
  if x >= 3 and y >= 3 and x < self.app.config.width - 3 and y < self.app.config.height - 3 then
    self.buttons_down[button] = true
  end
  
  self:updateTooltip()
  return Window.onMouseDown(self, button, x, y) or repaint
end

function UI:onMouseUp(code, x, y)
  local repaint = false
  local button = self.button_codes[code]
  if not button then
    return
  end
  self.down_count = self.down_count - 1
  if self.down_count <= 0 then
    if self.cursor_entity == nil and self.cursor == self.down_cursor then
      self:setCursor(self.default_cursor)
      repaint = true
    end
    self.down_count = 0
  end
  self.buttons_down[button] = false
  
  if Window.onMouseUp(self, button, x, y) then
    repaint = true
  else
    if self.cursor_entity and self.cursor_entity.onClick then
      self.cursor_entity:onClick(self, button)
      repaint = true
    end
  end
  
  self:updateTooltip()
  return repaint
end

function UI:ScreenToWorld(x, y)
  return self.app.map:ScreenToWorld(self.screen_offset_x + x, self.screen_offset_y + y)
end

function UI:WorldToScreen(x, y)
  x, y = self.app.map:WorldToScreen(x, y)
  x = x - self.screen_offset_x
  y = y - self.screen_offset_y
  return x, y
end

function UI:getScreenOffset()
  return self.screen_offset_x, self.screen_offset_y
end

local tooltip_ticks = 50 -- Amount of ticks until a tooltip is displayed

function UI:updateTooltip()
  if self.buttons_down["left"] then
    -- Disable tooltips altogether while left button is pressed.
    self.tooltip = nil
    self.tooltip_counter = nil
    return
  elseif self.tooltip_counter == nil then
    self.tooltip_counter = tooltip_ticks
  end
  local tooltip = self:getTooltipAt(self.cursor_x, self.cursor_y)
  if tooltip then
    -- NB: Do not set counter if tooltip changes here. This allows quick tooltip reading of adjacent buttons.
    self.tooltip = tooltip
  else
    -- Not hovering over any button with tooltip -> reset
    self.tooltip = nil
    self.tooltip_counter = tooltip_ticks
  end
end

local UpdateCursorPosition = TH.cursor.setPosition

function UI:onMouseMove(x, y, dx, dy)
  local repaint = UpdateCursorPosition(self.app.video, x, y)
  
  self.cursor_x = x
  self.cursor_y = y
  
  if self.drag_mouse_move then
    self.drag_mouse_move(x, y)
    return true
  end
  
  if Window.onMouseMove(self, x, y, dx, dy) then
    repaint = true
  end

  self:updateTooltip()
  
  return repaint
end

function UI:onTick()
  Window.onTick(self)
  local repaint = false
  if self.tooltip_counter and self.tooltip_counter > 0 then
    self.tooltip_counter = self.tooltip_counter - 1
    repaint = (self.tooltip_counter == 0)
  end
  return repaint
end


function UI:addWindow(window)
  if window.closed then
    return
  end
  if window.modal_class then
    if self.modal_windows[window.modal_class] then
      self.modal_windows[window.modal_class]:close()
    end
    self.modal_windows[window.modal_class] = window
  end
  Window.addWindow(self, window)
end

function UI:removeWindow(window)
  if Window.removeWindow(self, window) then
    local class = window.modal_class
    if class and self.modal_windows[class] == window then
      self.modal_windows[class] = nil
    end
    return true
  else
    return false
  end
end

function UI:getCursorPosition(window)
  -- Given no argument, returns the cursor position in screen space
  -- Otherwise, returns the cursor position in the space of the given window
  local x, y = self.cursor_x, self.cursor_y
  while window ~= nil and window ~= self do
    x = x - window.x
    y = y - window.y
    window = window.parent
  end
  return x, y
end
