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
    end
  end
  return r
end

function UI:initKeyAndButtonCodes()
  local key_remaps = {}
  local button_remaps = {}
  local key_to_button_remaps = {}
  local key_norms = setmetatable({
    space = " ",
    escape = "esc",
  }, {__index = function(t, k)
    k = tostring(k):lower()
    return rawget(t, k) or k
  end})
  do
    local ourpath = debug.getinfo(1, "S").source:sub(2, -7)
    local result, err = loadfile_envcall(ourpath .. "key_mapping.txt")
    if not result then
      print("Cannot load key mapping:" .. err)
    else
      local env = {
        key_remaps = function(t)
          for k, v in pairs(t) do
            key_remaps[key_norms[k]] = key_norms[v]
          end
        end,
        button_remaps = function(t)
          for k, v in pairs(t) do
            k = key_norms[k]
            if k == "left" or k == "middle" or k == "right" then
              button_remaps[k] = key_norms[v]
            else
              key_to_button_remaps[k] = key_norms[v]
            end
          end
        end,
      }
      setmetatable(env, {__index = function(t, k)
        return k
      end})
      result(env)
    end
  end

  self.key_codes = {
    backspace = 8,
    delete = 127,
    esc = 27,
    up = 273,
    down = 274,
    right = 275,
    left = 276,
    x = 120,
    z = 122,
    f1 = 282,
    f2 = 283,
    f3 = 284,
    f4 = 285,
    f5 = 286,
    f6 = 287,
    f7 = 288,
    f8 = 289,
    f9 = 290,
    f10 = 291,
    f11 = 292,
    f12 = 293,
    enter = 13,
    home = 278,
    end_key = 279,
    shift = {303, 304},
    ctrl = {305, 306},
    alt = {307, 308, 313},
  }
  self.key_remaps = key_remaps
  self.key_to_button_remaps = key_to_button_remaps
  self.key_codes = invert(self.key_codes)

  self.button_codes = {
    left = 1,
    middle = 2,
    right = 3,
  }

  -- Apply button remaps directly to codes, as mouse button codes are reliable
  -- (keyboard key codes are not).
  local original_button_codes = {}
  for input, behave_as in pairs(button_remaps) do
    local code = original_button_codes[input] or self.button_codes[input] or {}
    if not original_button_codes[input] then
      original_button_codes[input] = code
      self.button_codes[input] = nil
    end
    if not original_button_codes[behave_as] then
      original_button_codes[behave_as] = self.button_codes[behave_as]
    end
    self.button_codes[behave_as] = code
  end

  self.button_codes = invert(self.button_codes)
end

local LOADED_DIALOGS = false

function UI:UI(app, minimal)
  self:Window()
  self:initKeyAndButtonCodes()
  self.app = app
  self.screen_offset_x = 0
  self.screen_offset_y = 0
  self.cursor = nil
  self.cursor_x = 0
  self.cursor_y = 0
  self.cursor_entity = nil
  self.debug_cursor_entity = nil
  -- through trial and error, this palette seems to give the desired result (white background, black text)
  -- NB: Need a palette present in both the full game and in the demo data
  if minimal then
    self.tooltip_font = app.gfx:loadBuiltinFont()
  else
    local palette = app.gfx:loadPalette("QData", "PREF01V.PAL")
    palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
    self.tooltip_font = app.gfx:loadFont("QData", "Font00V", false, palette)
  end
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
  self.key_code_to_rawchar = {}

  self.keyboard_repeat_enable_count = 0
  SDL.modifyKeyboardRepeat(0, 0)
  self.down_count = 0
  if not minimal then
    self.default_cursor = app.gfx:loadMainCursor("default")
    self.down_cursor = app.gfx:loadMainCursor("clicked")
    self.grab_cursor = app.gfx:loadMainCursor("grab")
    self.edit_room_cursor = app.gfx:loadMainCursor("edit_room")
    self.waiting_cursor = app.gfx:loadMainCursor("sleep")
  end
  self.editing_allowed = true

  if not LOADED_DIALOGS then
    app:loadLuaFolder("dialogs", true)
    app:loadLuaFolder("dialogs/fullscreen", true)
    app:loadLuaFolder("dialogs/resizables", true)
    app:loadLuaFolder("dialogs/resizables/menu_list_dialogs", true)
    app:loadLuaFolder("dialogs/resizables/file_browsers", true)
    LOADED_DIALOGS = true
  end

  self:setCursor(self.default_cursor)

  -- to avoid a bug which causes open fullscreen windows to display incorrectly, load
  -- the sprite sheet associated with all fullscreen windows so they are correctly cached.
  -- Darrell: Only do this if we have a valid data directory otherwise we won't be able to
  -- display the directory browser to even find the data directory.
  -- Edvin: Also, the demo does not contain any of the dialogs.
  if self.app.good_install_folder and not self.app.using_demo_files then
    local gfx = self.app.gfx
    local palette
    -- load drug casebook sprite table
    palette = gfx:loadPalette("QData", "DrugN01V.pal")
    palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
    gfx:loadSpriteTable("QData", "DrugN02V", true, palette)
    -- load fax sprite table
    palette = gfx:loadPalette("QData", "Fax01V.pal")
    palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
    gfx:loadSpriteTable("QData", "Fax02V", true, palette)
    -- load town map sprite table
    palette = gfx:loadPalette("QData", "Town01V.pal")
    palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
    gfx:loadSpriteTable("QData", "Town02V", true, palette)
    -- load hospital policy sprite table
    palette = gfx:loadPalette("QData", "Pol01V.pal")
    palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
    gfx:loadSpriteTable("QData", "Pol02V", true, palette)
    -- load bank manager sprite table
    palette = gfx:loadPalette("QData", "Bank01V.pal")
    palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
    gfx:loadSpriteTable("QData", "Bank02V", true, palette)
    -- load research screen sprite table
    palette = gfx:loadPalette("QData", "Res01V.pal")
    palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
    gfx:loadSpriteTable("QData", "Res02V", true, palette)
    -- load progress report sprite table
    palette = gfx:loadPalette("QData", "Rep01V.pal")
    palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
    gfx:loadSpriteTable("QData", "Rep02V", true, palette)
    -- load annual report sprite table
    palette = gfx:loadPalette("QData", "Award02V.pal")
    palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
    gfx:loadSpriteTable("QData", "Award03V", true, palette)
  end

  self:setupGlobalKeyHandlers()
end

function UI:runDebugScript()
  print("Executing Debug Script...") 
  local path_sep = package.config:sub(1, 1)
  local lua_dir = debug.getinfo(1, "S").source:sub(2, -8)
  _ = TheApp.ui and TheApp.ui.debug_cursor_entity
  local script = assert(loadfile(lua_dir .. path_sep .. "debug_script.lua"))
  script()
end

function UI:setupGlobalKeyHandlers()
  -- Add some global keyhandlers
  self:addKeyHandler("esc", self, self.closeWindow)
  self:addKeyHandler("esc", self, self.stopMovie)
  self:addKeyHandler(" ", self, self.stopMovie)
  self:addKeyHandler({"ctrl", "s"}, self, self.makeScreenshot)
  self:addKeyHandler({"alt", "enter"}, self, self.toggleFullscreen)
  self:addKeyHandler({"alt", "f4"}, self, self.exitApplication)
  self:addKeyHandler({"shift", "f10"}, self, self.resetApp)

  if self.app.config.debug then
    self:addKeyHandler("f12", self, self.showLuaConsole)
    self:addKeyHandler({"shift", "d"}, self, self.runDebugScript)
  end
end

-- Used for everything except music and announcements
function UI:playSound(name, played_callback, played_callback_delay)
  if self.app.config.play_sounds then
    self.app.audio:playSound(name, nil, false, played_callback, played_callback_delay)
  end
end

-- Used for announcements only
function UI:playAnnouncement(name, played_callback, played_callback_delay)
  if self.app.config.play_announcements then
    self.app.audio:playSound(name, nil, true, played_callback, played_callback_delay)
  end
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
    local bg_w, bg_h = self.background_width, self.background_height
    local screen_w, screen_h = app.config.width, app.config.height
    local factor = math.max(screen_w / bg_w, screen_h / bg_h)
    if canvas:scale(factor, "bitmap") or canvas:scale(factor) then
      self.background:draw(canvas, (screen_w / factor - bg_w) / 2, (screen_h / factor - bg_h) / 2)
      canvas:scale(1)
    else
      canvas:fillBlack()
      self.background:draw(canvas, (screen_w - bg_w) / 2, (screen_h - bg_h) / 2)
    end
  end
  Window.draw(self, canvas, 0, 0)
  self:drawTooltip(canvas)
  if self.simulated_cursor then
    self.simulated_cursor.draw(canvas, self.cursor_x, self.cursor_y)
  end
end

--! Register a key handler / hotkey for a window.
--!param keys (string or table) The keyboard key which should trigger the callback (for
-- example, "left" or "z" or "F9"), or a list with modifier(s) and the key (e.g. {"ctrl", "s"}).
--!param window (Window) The UI window which should receive the callback.
--!param callback (function) The method to be called on `window` when `key` is
-- pressed.
--!param ... Additional arguments to `callback`.
function UI:addKeyHandler(keys, window, callback, ...)
  keys = (type(keys) == "table") and keys or {keys}

  local key = table.remove(keys, #keys):lower()
  local modifiers = list_to_set(keys) -- SET of modifiers
  if not self.key_handlers[key] then
    -- No handlers for this key? Create a new table.
    self.key_handlers[key] = {}
  end
  table.insert(self.key_handlers[key], {
    modifiers = modifiers,
    window = window,
    callback = callback,
    ...
  })
end

--! Unregister a key handler previously registered by `addKeyHandler`.
--!param keys (string or table) The key or list of modifiers+key of a key / window
-- pair previously passed to `addKeyHandler`.
--!param window (Window) The window of a key / window pair previously passed
-- to `addKeyHandler`.
function UI:removeKeyHandler(keys, window)
  keys = (type(keys) == "table") and keys or {keys}

  local key = table.remove(keys, #keys):lower()
  local modifiers = list_to_set(keys) -- SET of modifiers
  if self.key_handlers[key] then
    for index, info in ipairs(self.key_handlers[key]) do
      if info.window == window and compare_tables(info.modifiers, modifiers) then
        table.remove(self.key_handlers[key], index)
      end
    end
    -- If last key handler was removed, delete the (now empty) list.
    if #self.key_handlers[key] == 0 then
      self.key_handlers[key] = nil
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

local menu_bg_sizes = { -- Available menu background sizes
  {1920, 1080},
}

function UI:setMenuBackground()
  local bg_size = menu_bg_sizes[1]
  self.background = self.app.gfx:loadRaw("mainmenu" .. bg_size[2], bg_size[1], bg_size[2], "Bitmap")
  self.background_width = bg_size[1]
  self.background_height = bg_size[2]
end

function UI:onChangeResolution()
  -- If we are in the main menu (== no world), reselect the background
  if not self.app.world then
    self:setMenuBackground()
  end
  -- Inform windows of resolution change
  for _, window in ipairs(self.windows) do
    window:onChangeResolution()
  end
end

function UI:registerTextBox(box)
  self.textboxes[#self.textboxes + 1] = box
end

function UI:unregisterTextBox(box)
  for num, b in ipairs(self.textboxes) do
    if b == box then
      table.remove(self.textboxes, num)
      break
    end
  end
  -- If the textbox was active at time of unregistering, disable keyboard repeat
  if box.active then
    self:disableKeyboardRepeat()
  end
end

function UI:resetVideo()
  local width, height = self.app.config.width, self.app.config.height

  self.app.video:endFrame()
  self.app.video = TH.surface(width, height, unpack(self.app.modes))
  self.app.gfx:updateTarget(self.app.video)
  self.app.video:startFrame()
  -- Redraw cursor
  local cursor = self.cursor
  self.cursor = nil
  self:setCursor(cursor)
end

function UI:changeResolution(width, height)
  local old_width, old_height = self.app.config.width, self.app.config.height
  self.app.video:endFrame()
  local video, error_message = TH.surface(width, height, unpack(self.app.modes))
  if video then
    self.app.config.width = width
    self.app.config.height = height
  else
    print("Warning: Could not change resolution to " .. width .. "x" .. height .. ". Reverting to previous resolution.")
    print("The error was: ")
    print(error_message)
    video = TH.surface(old_width, old_height, unpack(self.app.modes))
    return false
  end
  self.app.video = video
  self.app.gfx:updateTarget(self.app.video)
  self.app.video:startFrame()
  -- Redraw cursor
  local cursor = self.cursor
  self.cursor = nil
  self:setCursor(cursor)
  -- Save new setting in config
  self.app:saveConfig()

  self:onChangeResolution()

  return true
end

function UI:toggleFullscreen()
  local modes = self.app.modes

  local function toggleMode(index)
    self.app.fullscreen = not self.app.fullscreen
    if self.app.fullscreen then
      modes[index] = "fullscreen"
    else
      modes[index] = ""
    end
  end

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
  toggleMode(index)
  self.app.video:endFrame()
  self.app.moviePlayer:deallocatePictureBuffer();

  local success = true
  local video = TH.surface(self.app.config.width, self.app.config.height, unpack(modes))
  if not video then
    success = false
    local mode_string = modes[index] or "windowed"
    print("Warning: Could not toggle to " .. mode_string .. " mode with resolution of " .. self.app.config.width .. "x" .. self.app.config.height .. ".")
    -- Revert fullscreen mode modifications
    toggleMode(index)
    video = TH.surface(self.app.config.width, self.app.config.height, unpack(self.app.modes))
  end

  self.app.video = video -- Apply changes
  self.app.gfx:updateTarget(self.app.video)
  self.app.moviePlayer:allocatePictureBuffer();
  self.app.video:startFrame()
  -- Redraw cursor
  local cursor = self.cursor
  self.cursor = nil
  self:setCursor(cursor)

  -- Save new setting in config
  self.app.config.fullscreen = self.app.fullscreen
  self.app:saveConfig()

  return success
end

function UI:_translateKeyCode(code, rawchar)
  local key = self.key_codes[code] or rawchar:lower()
  return self.key_remaps[key] or key
end

--! Table with chars and corresponding chars when shift is pressed (qwerty keyboard layout)
local workaround_shift = {
  ["1"] = "!",
  ["2"] = "@",
  ["3"] = "#",
  ["4"] = "$",
  ["5"] = "%",
  ["6"] = "^",
  ["7"] = "&",
  ["8"] = "*",
  ["9"] = "(",
  ["0"] = ")",
  ["-"] = "_",
  ["="] = "+",
  ["["] = "{",
  ["]"] = "}",
  [";"] = ":",
  ["'"] = "\"",
  ["\\"] = "|",
  [","] = "<",
  ["."] = ">",
  ["/"] = "?",
}

-- ! Returns the numpad value (0, 1, 2, etc.) 
-- ! from key-code (256, 257, etc.) (as string)
-- ! If key-code is not from the numpad, returns nil
-- !param code (integer) The hardware key-code
function UI:numPadValue(code)
  if (self:isCodeFromNumPad(code)) then
    return tostring(code - 256)
  end
end

-- ! Test if key-code is from numpad
-- !param code (integer) The hardware key-code 
function UI:isCodeFromNumPad(code)
  return 256 <= code and code <= 265
end

--! Called when the user presses a key on the keyboard
--!param code (integer) The hardware key-code for the pressed key. Note that
-- these codes only coincide with ASCII for certain keyboard layouts.
--!param rawchar (string) The unicode character corresponding to the pressed
-- key, encoded as UTF8 in a Lua string (for non-character keys, this value is
-- "\0"). This value is affected by shift/caps-lock keys, but is not affected
-- by any key-remappings.
function UI:onKeyDown(code, rawchar)
  -- Workaround bad SDL implementations and/or old binaries
  if rawchar == nil or rawchar == "\0" then
    if code < 128 then
      rawchar = string.char(code)
      if self.buttons_down.shift then
        if 97 <= code and code <= 122 then -- letters
          rawchar = rawchar:upper()
        else
          rawchar = workaround_shift[rawchar] or rawchar
        end
      end
    else
      if self:isCodeFromNumPad(code) then
        rawchar = self:numPadValue(code)
      end
    end
  end
  -- Remember the raw character associated with the code, as when the key is
  -- released, we only get given the code.
  self.key_code_to_rawchar[code] = rawchar

  -- Apply key-remapping and normalisation
  local key = self.key_codes[code] or rawchar:lower()
  do
    local mapped_button = self.key_to_button_remaps[key]
    if mapped_button then
      self:onMouseDown(mapped_button, self.cursor_x, self.cursor_y)
      return true
    end
    key = self.key_remaps[key] or key
  end

  -- If there is one, the current textbox gets the key
  for _, box in ipairs(self.textboxes) do
    if box.enabled and box.active then
      local handled = box:input(key, rawchar, code)
      if handled then
        return true
      end
    end
  end

  -- Otherwise, if there is a key handler bound to the given key, then it gets
  -- the key.

  -- For some reason the rawchar used above is not good if Ctrl is being pressed
  local key_down = key
  if self.buttons_down.ctrl and code < 128 then
    key_down = string.char(code)
  end

  local keyHandlers = self.key_handlers[key_down]
  if keyHandlers then
    -- Iterate over key handlers and call each one whose modifier(s) are pressed
    -- NB: Only if the exact correct modifiers are pressed will the shortcut get processed.
    local handled = false
    for _, handler in ipairs(keyHandlers) do
      if compare_tables(handler.modifiers, self.buttons_down) then
        handler.callback(handler.window, unpack(handler))
        handled = true
      end
    end
    if handled then
      return true
    end
  end

  self.buttons_down[key] = true
end

--! Called when the user releases a key on the keyboard
--!param code (integer) The hardware key-code for the pressed key. Note that
-- these codes only coincide with ASCII for certain keyboard layouts.
function UI:onKeyUp(code)
  local rawchar = self.key_code_to_rawchar[code] or ""
  self.key_code_to_rawchar[code] = nil
  local key = self.key_codes[code] or rawchar:lower()
  do
    local mapped_button = self.key_to_button_remaps[key]
    if mapped_button then
      self:onMouseUp(mapped_button, self.cursor_x, self.cursor_y)
      return true
    end
    key = self.key_remaps[key] or key
  end
  self.buttons_down[key] = nil
end

function UI:onMouseDown(code, x, y)
  local repaint = false
  local button = self.button_codes[code] or code
  if self.app.moviePlayer.playing then
    if button == "left" then
      self.app.moviePlayer:stop()
    end
    return true
  end
  if self.cursor_entity == nil and self.down_count == 0
  and self.cursor == self.default_cursor then
    self:setCursor(self.down_cursor)
    repaint = true
  end
  self.down_count = self.down_count + 1
  if x >= 3 and y >= 3 and x < self.app.config.width - 3 and y < self.app.config.height - 3 then
    self.buttons_down["mouse_"..button] = true
  end

  self:updateTooltip()
  return Window.onMouseDown(self, button, x, y) or repaint
end

function UI:onMouseUp(code, x, y)
  local repaint = false
  local button = self.button_codes[code] or code
  self.down_count = self.down_count - 1
  if self.down_count <= 0 then
    if self.cursor_entity == nil and self.cursor == self.down_cursor then
      self:setCursor(self.default_cursor)
      repaint = true
    end
    self.down_count = 0
  end
  self.buttons_down["mouse_"..button] = nil

  if Window.onMouseUp(self, button, x, y) then
    repaint = true
  else
    if self:ableToClickEntity(self.cursor_entity) then
      self.cursor_entity:onClick(self, button)
      repaint = true
    end
  end

  self:updateTooltip()
  return repaint
end

--[[ Determines if a cursor entity can be clicked
@param entity (Entity,nil) cursor entity clicked on if any
@return true if can be clicked on, false otherwise (boolean) ]]
function UI:ableToClickEntity(entity)
  if self.cursor_entity and self.cursor_entity.onClick then
    local hospital = entity.hospital
    local epidemic = hospital and hospital.epidemic

    return self.app.world.user_actions_allowed and not epidemic or
      (epidemic and not epidemic.vaccination_mode_active)
  else
    return false
  end
end


function UI:getScreenOffset()
  return self.screen_offset_x, self.screen_offset_y
end

local tooltip_ticks = 30 -- Amount of ticks until a tooltip is displayed

function UI:updateTooltip()
  if self.buttons_down.mouse_left then
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

--! Called when the mouse enters or leaves the game window.
function UI:onWindowActive(gain)
end

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
  -- If a tooltip is currently shown, update each tick (may be dynamic)
  if self.tooltip then
    self:updateTooltip()
  end
  return repaint
end


function UI:addWindow(window)
  if window.closed then
    return
  end
  if window.modal_class then
    -- NB: while instead of if in case of another window being created during the close function
    while self.modal_windows[window.modal_class] do
      self.modal_windows[window.modal_class]:close()
    end
    self.modal_windows[window.modal_class] = window
  end
  if window.modal_class == "main"  or window.modal_class == "fullscreen" then
    self.editing_allowed = false -- do not allow editing rooms if main windows (build, furnish, hire) are open
  end
  Window.addWindow(self, window)
end

function UI:removeWindow(window)
  if Window.removeWindow(self, window) then
    local class = window.modal_class
    if class and self.modal_windows[class] == window then
      self.modal_windows[class] = nil
    end
    if window.modal_class == "main" or window.modal_class == "fullscreen" then
      self.editing_allowed = true -- allow editing rooms again when main window is closed
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

function UI:addOrRemoveDebugModeKeyHandlers()
  self:removeKeyHandler("f12", self)
  self:removeKeyHandler({"shift", "d"}, self)
  if self.app.config.debug then
    self:addKeyHandler("f12", self, self.showLuaConsole)
    self:addKeyHandler({"shift", "d"}, self, self.runDebugScript)
  end
end

function UI:afterLoad(old, new)
  if old < 5 then
    self.editing_allowed = true
  end
  if old < 13 then
    self.key_code_to_rawchar = {}
  end
  if old < 63 then
    -- modifiers have been added to key handlers
    for key, handlers in pairs(self.key_handlers) do
      for _, handler in ipairs(handlers) do
        handler.modifiers = {}
      end
    end
    -- some global key shortcuts were converted to use keyHandlers
    self:removeKeyHandler("f12", self)
    self:removeKeyHandler({"shift", "d"}, self)
    self:setupGlobalKeyHandlers()
  end

  -- disable keyboardrepeat after loading a game just in case
  -- (might be transferred from before loading, or broken savegame)
  repeat
    self:disableKeyboardRepeat()
  until self.keyboard_repeat_enable_count == 0
  if old < 70 then
    self:removeKeyHandler("f10", self)
    self:addKeyHandler({"shift", "f10"}, self, self.resetApp)
    self:removeKeyHandler("a", self)
  end
  -- changing this so that it is quit application and Shift + Q is quit to main menu
  if old < 71 then
    self:removeKeyHandler({"alt", "f4"}, self, self.quit)
    self:addKeyHandler({"alt", "f4"}, self, self.exitApplication)
  end

  Window.afterLoad(self, old, new)
end

-- Stub to allow the function to be called in e.g. the information
-- dialog without having to worry about a GameUI being present
function UI:tutorialStep(...)
end

function UI:makeScreenshot()
   -- Find an index for screenshot which is not already used
  local i = 0
  local filename
  repeat
    filename = TheApp.screenshot_dir .. ("screenshot%i.bmp"):format(i)
    i = i + 1
  until lfs.attributes(filename, "size") == nil
  print("Taking screenshot: " .. filename)
  local res, err = self.app.video:takeScreenshot(filename) -- Take screenshot
  if not res then
    print("Screenshot failed: " .. err)
  else
    self.app.audio:playSound("SNAPSHOT.WAV")
  end
end

--! Closes one window (the topmost / active window, if possible)
--!return true iff a window was closed
function UI:closeWindow()
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
end

--! Shows the Lua console
function UI:showLuaConsole()
  self:addWindow(UILuaConsole(self))
end

--! Triggers reset of the application (reloads .lua files)
function UI:resetApp()
  debug.getregistry()._RESTART = true
  TheApp.running = false
end
-- Added this function as quit does not exit the application, it only exits the game to the menu screen
function UI:exitApplication()
  self.app:abandon()
end

--! Triggers quitting the application
function UI:quit()
  self.app:exit()
end

--! Tries to stop a video, if one is currently playing
function UI:stopMovie()
  if self.app.moviePlayer.playing then
    self.app.moviePlayer:stop()
  end
end

-- Stub for compatibility with savegames r1896-1921
function UI:stopVideo() end
