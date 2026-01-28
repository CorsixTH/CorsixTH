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

corsixth.require("window")

--! Top-level container for all other user-interface components.
class "UI" (Window)

---@type UI
local UI = _G["UI"]

local TH = require("TH")
local SDL = require("sdl")
local WM = SDL.wm
local lfs = require("lfs")

local function invert(t)
  local r = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      for _, val in ipairs(v) do
        r[val] = k
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
    [" "] = "space",
    esc = "escape",
  }, {__index = function(t, k)
    k = tostring(k):lower()
    return rawget(t, k) or k
  end})
  --[===[
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
      setmetatable(env, {__index = function(_, k)
        return k
      end})
      result(env)
    end
  end
  ]===]

  local keypad = {
    ["Keypad 0"] = "insert",
    ["Keypad 1"] = "end",
    ["Keypad 2"] = "down",
    ["Keypad 3"] = "pagedown",
    ["Keypad 4"] = "left",
    ["Keypad 6"] = "right",
    ["Keypad 7"] = "home",
    ["Keypad 8"] = "up",
    ["Keypad 9"] = "pageup",
    ["Keypad ."] = "delete",
  }

  -- Apply keypad remapping
  for k, v in pairs(keypad) do
    key_remaps[key_norms[k]] = key_norms[v]
  end

  self.key_remaps = key_remaps
  self.key_to_button_remaps = key_to_button_remaps

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
  self.cursor_entity = nil
  self.debug_cursor_entity = nil
  -- through trial and error, this palette seems to give the desired result (white background, black text)
  -- NB: Need a palette present in both the full game and in the demo data
  if minimal then
    self.tooltip_font = app.gfx:loadBuiltinFont()
  else
    local palette = app.gfx:loadPalette("QData", "PREF01V.PAL", true)
    self.tooltip_font = app.gfx:loadFontAndSpriteTable("QData", "Font00V", false, palette, { apply_ui_scale = true })
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
  -- For use in onKeyUp when assigning hotkeys in the "Assign Hotkeys" window.
  self.temp_button_down = false
  --
  self.key_noted = false
  self.mouse_released = false

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


  self:setupGlobalKeyHandlers()
end

function UI:runDebugScript()
  -- luacheck: ignore 111 _ is set in debug code
  print("Executing Debug Script...")
  local debug_script = self.app:getFullPath({"Lua", "debug_script.lua"})
  _ = TheApp.ui and TheApp.ui.debug_cursor_entity
  local script = assert(loadfile(debug_script))
  script()
  -- Clear _ after the script to prevent save corruption
  _ = nil
end

function UI:setupGlobalKeyHandlers()
  -- Add some global keyhandlers
  self:addKeyHandler("global_cancel", self, self.closeWindow)
  self:addKeyHandler("global_cancel_alt", self, self.closeWindow)
  self:addKeyHandler("global_stop_movie", self, self.stopMovie)
  self:addKeyHandler("global_stop_movie_alt", self, self.stopMovie)
  self:addKeyHandler("global_pause_movie", self, self.pauseMovie)
  self:addKeyHandler("global_screenshot", self, self.makeScreenshot)
  self:addKeyHandler("global_fullscreen_toggle", self, self.fullscreenHotkey)
  self:addKeyHandler("global_exitApp", self, self.exitApplication)
  self:addKeyHandler("global_resetApp", self, self.resetApp)
  self:addKeyHandler("global_releaseMouse", self, self.releaseMouse)

  self:addOrRemoveDebugModeKeyHandlers()
end

--! Play a sound effect
--!param name (string) The name of the sound to be played. Can include
--  wildcards (*).
--!param played_callback (function) A function to be called when the sound has
--  finished playing. Can be nil.
--!param played_callback_delay (integer) An optional delay in milliseconds
--  before the played_callback is called.
--!param loops (integer) number of times to play the audio. -1 for infinite.
--!return (table) A `sound` table for passing into functions that act on the
--  playing sound. The fields are an implementation detail that should not be
--  used outside of the Audio class.
function UI:playSound(name, played_callback, played_callback_delay, loops)
  if self.app.config.play_sounds then
    return self.app.audio:playSound(name, nil, false, played_callback, played_callback_delay, loops)
  end
end

--! Stop the given sound
-- see Audio:stopSound
--!param sound (table) sound to stop
function UI:stopSound(sound)
  self.app.audio:stopSound(sound)
end

-- Stub with args for subclass GameUI.
function UI:playAnnouncement(name, priority, played_callback, played_callback_delay)
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
      WM.showCursor(self.mouse_released)
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
    self.tooltip_font:drawTooltip(canvas, self.tooltip.text, x, y, 200 * TheApp.config.ui_scale)
  end
end

function UI:draw(canvas)
  local app = self.app
  if self.background then
    local bg_w, bg_h = self.background_width, self.background_height
    local screen_w, screen_h = app.config.width, app.config.height
    local factor = math.max(screen_w / bg_w, screen_h / bg_h)
    if canvas:scale(factor, "bitmap") or canvas:scale(factor) then
      self.background:draw(canvas, math.floor((screen_w - bg_w * factor) / 2), math.floor((screen_h - bg_h * factor) / 2))
      canvas:scale(1)
    else
      canvas:fillBlack()
      self.background:draw(canvas, math.floor((screen_w - bg_w) / 2), math.floor((screen_h - bg_h) / 2))
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
  -- It is necessary to clone the key table into another temporary table, as if we don't the original table that we take it from will lose
  -- the last key of that table permanently in the next line of code after this one, until the program is restarted.
  -- I.E. if the "ingame_quitLevel" hotkey from the "hotkeys_values" table in "config_finder.lua" is a table that looks like this:
  --   {"shift", "q"}
  -- We would lose the "q" element until we restarted the game and the "hotkey.txt" was read from again, causing the "ingame_quitLevel"
  -- table to be reset back to {"shift, "q"}
  local temp_keys = {}

  -- Check to see if "keys" key exist in the hotkeys table.
  if self.app.hotkeys[keys] ~= nil then
    if type(self.app.hotkeys[keys]) == "table" then
      temp_keys = shallow_clone(self.app.hotkeys[keys])
    elseif type(self.app.hotkeys[keys]) == "string" then
      temp_keys = shallow_clone({self.app.hotkeys[keys]})
    end
  else
    if type(keys) == "string" then
      print(string.format("\"%s\" does not exist in the hotkeys configuration file.", keys))
    else
      print("Usage of addKeyHandler() requires the first argument to be a string of a key that can be found in the hotkeys configuration file.")
    end
  end

  if temp_keys ~= nil then
    local has_enterOrPlus
    local temp_keys_copy = {}

    if type(temp_keys) == "table" then
      temp_keys_copy = shallow_clone(temp_keys)
    elseif type(temp_keys) == "string" then
      temp_keys_copy = {temp_keys}
    end

    for _, v in pairs(temp_keys_copy) do
      if v == "enter" then
        has_enterOrPlus = true
      elseif v == "return" then
        has_enterOrPlus = true
      elseif v == "+" then
        has_enterOrPlus = true
      elseif v == "=" then
        has_enterOrPlus = true
      else
        has_enterOrPlus = false
      end
    end

    local key = table.remove(temp_keys, #temp_keys):lower()
    local modifiers = list_to_set(temp_keys) -- SET of modifiers
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

    -- If the handler added has enter, return, plus, or minus in it...
    if has_enterOrPlus then
      for k, _ in pairs(temp_keys_copy) do
        if temp_keys_copy[k] == "enter" then
          temp_keys_copy[k] = "return"
        elseif temp_keys_copy[k] == "return" then
          temp_keys_copy[k] = "enter"
        elseif temp_keys_copy[k] == "+" then
          temp_keys_copy[k] = "="
        elseif temp_keys_copy[k] == "=" then
          temp_keys_copy[k] = "+"
        end
      end

      local key_02 = table.remove(temp_keys_copy, #temp_keys_copy):lower()
      local modifiers_02 = list_to_set(temp_keys_copy) -- SET of modifiers
      if not self.key_handlers[key_02] then
        -- No handlers for this key? Create a new table.
        self.key_handlers[key_02] = {}
      end

      -- Then make the same handler, but with the complementary button.
      --  i.e. If it asks for "enter", it will also add "return".
      table.insert(self.key_handlers[key_02], {
        modifiers = modifiers_02,
        window = window,
        callback = callback,
        ...
      })
    end
  else
    print("addKeyHandler() failed.")
  end
end

--! Unregister a key handler previously registered by `addKeyHandler`.
--!param keys (string or table) The key or list of modifiers+key of a key / window
-- pair previously passed to `addKeyHandler`.
--!param window (Window) The window of a key / window pair previously passed
-- to `addKeyHandler`.
function UI:removeKeyHandler(keys, window)
  local temp_keys = nil

  -- Check to see if "keys" key exist in the hotkeys table.
  if self.app.hotkeys[keys] ~= nil then
    if type(self.app.hotkeys[keys]) == "table" then
      temp_keys = shallow_clone(self.app.hotkeys[keys])
    elseif type(self.app.hotkeys[keys]) == "string" then
      temp_keys = shallow_clone({self.app.hotkeys[keys]})
    end
  else
    if type(keys) == "string" then
      print(string.format("\"%s\" does not exist in the \"ui.key_handlers\" table.", keys))
    else
      print("Usage of removeKeyHandler() requires the first argument to be a string of a key that can be found in the \"ui.key_handlers\" table.")
    end
  end

  if temp_keys ~= nil then
    local has_enterOrPlus
    local temp_keys_copy = {}

    if type(temp_keys) == "table" then
      temp_keys_copy = shallow_clone(temp_keys)
    elseif type(temp_keys) == "string" then
      temp_keys_copy = shallow_clone({temp_keys})
    end

    for _, v in pairs(temp_keys_copy) do
      if v == "enter" then
        has_enterOrPlus = true
      elseif v == "return" then
        has_enterOrPlus = true
      elseif v == "+" then
        has_enterOrPlus = true
      elseif v == "=" then
        has_enterOrPlus = true
      else
        has_enterOrPlus = false
      end
    end

    local key = table.remove(temp_keys, #temp_keys):lower()
    local modifiers = list_to_set(temp_keys) -- SET of modifiers
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

    -- If the handler added has enter, return, plus, or minus in it...
    if has_enterOrPlus then
      for k, _ in pairs(temp_keys_copy) do
        if temp_keys_copy[k] == "enter" then
          temp_keys_copy[k] = "return"
        elseif temp_keys_copy[k] == "return" then
          temp_keys_copy[k] = "enter"
        elseif temp_keys_copy[k] == "+" then
          temp_keys_copy[k] = "="
        elseif temp_keys_copy[k] == "=" then
          temp_keys_copy[k] = "+"
        end
      end

      local key_02 = table.remove(temp_keys_copy, #temp_keys_copy):lower()
      local modifiers_02 = list_to_set(temp_keys_copy) -- SET of modifiers
      if self.key_handlers[key_02] then
        for index, info in ipairs(self.key_handlers[key_02]) do
          if info.window == window and compare_tables(info.modifiers, modifiers_02) then
            table.remove(self.key_handlers[key_02], index)
          end
        end
        -- If last key handler was removed, delete the (now empty) list.
        if #self.key_handlers[key_02] == 0 then
          self.key_handlers[key_02] = nil
        end
      end
    end
  end
end

--! Set the menu background image
--!
--! The menu size closest to, but no larger than the height of the currently
--! set game window is selected. If no image fits that criteria the smallest
--! available image is used.
function UI:setMenuBackground()
  local screen_h = self.app.config.height
  local bg_size_idx = 1

  -- Available mainmenu*.bmp sizes
  local menu_bg_sizes = {
    {640, 480},
    {1280, 720},
    {1920, 1080},
  }

  for i, bg_size in ipairs(menu_bg_sizes) do
    if screen_h >= bg_size[2] then
      bg_size_idx = i
    else
      break
    end
  end

  local bg_size = menu_bg_sizes[bg_size_idx]
  self.background_width = bg_size[1]
  self.background_height = bg_size[2]
  self.background = self.app.gfx:loadRaw("mainmenu" .. bg_size[2], bg_size[1], bg_size[2], "Bitmap")
end

function UI:onChangeResolution()
  -- If we are in the main menu (== no world), reselect the background
  if not self.app.world then
    self:setMenuBackground()
  end
  -- Inform windows of resolution change
  if not self.windows then
    return
  end
  for _, window in ipairs(self.windows) do
    window:onChangeResolution()
  end
  self.app.audio:setSoundStage()
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
end

function UI:registerHotkeyBox(box)
  self.hotkeyboxes[#self.hotkeyboxes + 1] = box
end

function UI:unregisterHotkeyBox(box)
  for num, b in ipairs(self.hotkeyboxes) do
    if b == box then
      table.remove(self.hotkeyboxes, num)
      break
    end
  end
end

function UI:changeResolution(width, height)
  self.app:prepareVideoUpdate()
  local error_message = self.app.video:update(
      width,
      height,
      App.MIN_WINDOW_WIDTH * TheApp.config.ui_scale,
      App.MIN_WINDOW_HEIGHT * TheApp.config.ui_scale,
      unpack(self.app.modes))
  self.app:finishVideoUpdate()

  if error_message then
    print("Warning: Could not change resolution to " .. width .. "x" .. height .. ".")
    print("The error was: ")
    print(error_message)
    return false
  end

  self.app.config.width = width
  self.app.config.height = height

  -- Redraw cursor
  local cursor = self.cursor
  self.cursor = nil
  self:setCursor(cursor)
  -- Save new setting in config
  self.app:saveConfig()

  self:onChangeResolution()

  return true
end

function UI:toggleCaptureMouse()
  self.app.capturemouse = not self.app.capturemouse
  self.app.video:setCaptureMouse(self.app.capturemouse)
end

function UI:setMouseReleased(released)
  if released == self.mouse_released then
    return
  end

  self.mouse_released = released

  -- If we are using a software cursor, show the hardware cursor on release
  -- and hide it again on capture.
  if self.cursor and not self.cursor.use then
    WM.showCursor(released)
  end

  self.app.video:setCaptureMouse(self.app.capturemouse and not self.app.mouse_released)
end

function UI:releaseMouse()
  self:setMouseReleased(true)
end

--! Dedicated hotkey function for toggling fullscreen
function UI:fullscreenHotkey()
  local toggle = self:toggleFullscreen()
  if not toggle then
    local err = {_S.errors.unavailable_screen_size}
    self:addWindow(UIInformation(self, err))
  end
  -- Update the Options window, if open
  local window = self:getWindow(UIOptions)
  if window then
    if toggle then window.fullscreen_button:toggle() end
    window.fullscreen_panel:setLabel(self.app.fullscreen and _S.options_window.option_on or _S.options_window.option_off)
  end
end

--! Turns fullscreen on and off
--!return success true if toggle succeeded
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

  local success = true
  self.app:prepareVideoUpdate()
  local error_message = self.app.video:update(self.app.config.width, self.app.config.height,
      self.app.MIN_WINDOW_WIDTH * self.app.config.ui_scale,
      self.app.MIN_WINDOW_HEIGHT * self.app.config.ui_scale,
      unpack(self.app.modes))
  self.app:finishVideoUpdate()

  if error_message then
    success = false
    local mode_string = modes[index] or "windowed"
    print("Warning: Could not toggle to " .. mode_string .. " mode with resolution of " .. self.app.config.width .. "x" .. self.app.config.height .. ".")
    -- Revert fullscreen mode modifications
    toggleMode(index)
  end

  -- Redraw cursor
  local cursor = self.cursor
  self.cursor = nil
  self:setCursor(cursor)

  if success then
    -- Save new setting in config
    self.app.config.fullscreen = self.app.fullscreen
    self.app:saveConfig()
  end

  return success
end

--! Called when the user presses a key on the keyboard
--!param rawchar (string) The name of the key the user pressed.
function UI:onKeyDown(rawchar, modifiers)
  local handled = false
  -- Apply key-remapping and normalisation
  rawchar = string.sub(rawchar,1,6) == "Keypad" and
            modifiers["numlockactive"] and string.sub(rawchar,8) or rawchar
  local key = rawchar:lower()
  do
    local mapped_button = self.key_to_button_remaps[key]
    if mapped_button then
      self:onMouseDown(mapped_button, self.cursor_x, self.cursor_y)
      return true
    end
    key = self.key_remaps[key] or key
  end

  -- Remove numlock modifier
  modifiers["numlockactive"] = nil
  -- If there is one, the current textbox gets the key.
  -- It will not process any text at this point though.
  for _, box in ipairs(self.textboxes) do
    if box.enabled and box.active and not handled then
      handled = box:keyInput(key, rawchar)
    end
  end

  -- If there is a hotkey box
  for _, hotkeybox in ipairs(self.hotkeyboxes) do
    if hotkeybox.enabled and hotkeybox.active and not handled then
      handled = hotkeybox:keyInput(key, rawchar, modifiers)
    end
  end

  -- Otherwise, if there is a key handler bound to the given key, then it gets
  -- the key.
  if not handled then
    local keyHandlers = self.key_handlers[key]
    if keyHandlers then
      -- Iterate over key handlers and call each one whose modifier(s) are pressed
      -- NB: Only if the exact correct modifiers are pressed will the shortcut get processed.
      for _, handler in ipairs(keyHandlers) do
        if compare_tables(handler.modifiers, modifiers) then
          handler.callback(handler.window, unpack(handler))
          handled = true
        end
      end
    end
  end

  self.buttons_down[key] = true
  self.modifiers_down = modifiers
  self.key_press_handled = handled
  return handled
end

--! Called when the user releases a key on the keyboard
--!param rawchar (string) The name of the key the user pressed.
function UI:onKeyUp(rawchar)
  rawchar = SDL.getKeyModifiers().numlockactive and
            string.sub(rawchar,1,6) == "Keypad" and string.sub(rawchar,8) or
            rawchar
  local key = rawchar:lower()

  self.buttons_down[key] = nil

  -- Go through all the hotkeyboxes.
  for _, hotkeybox in ipairs(self.hotkeyboxes) do
    -- If one is enabled and active...
    if hotkeybox.enabled and hotkeybox.active then
      -- If the key lifted is escape...
      if(key == "escape") then
        hotkeybox:abort()
        hotkeybox.noted_keys = {}
      else
        -- Check if the current key lifted has already been noted.
        self.key_noted = false
        for _, v in pairs(hotkeybox.noted_keys) do
          if v == key then
            self.key_noted = true
          end
        end

        -- If the current key hasn't been noted...
        if self.key_noted == false then
          hotkeybox.noted_keys[#hotkeybox.noted_keys + 1] = key
        end

        -- Says if there is still a button being pressed.
        self.temp_button_down = false

        -- Go through and check if there are still any buttons pressed. If so...
        for _, _ in pairs(self.buttons_down) do
          -- Then toggle the corresponding bool.
          self.temp_button_down = true
        end

        --If there ISN'T still a button down when a button was released...
        if self.temp_button_down == false then
          -- Activate the confirm function on the hotkey box.
          hotkeybox:confirm()
          hotkeybox.noted_keys = {}
        end
      end
    end
  end
end

function UI:onEditingText(text, start, length)
  -- Does nothing at the moment. We are handling text input ourselves.
end

--! Called in-between onKeyDown and onKeyUp. The argument 'text' is a
--! string containing the input localized according to the keyboard layout
--! the user uses.
function UI:onTextInput(text)
  -- It's time for any active textbox to get input.
  for _, box in ipairs(self.textboxes) do
    if box.enabled and box.active then
      box:textInput(text)
    end
  end

  -- Finally it might happen that a hotkey was not recognized because of
  -- differing local keyboard layout. Give it another shot.
  if not self.key_press_handled then
    local keyHandlers = self.key_handlers[text]
    if keyHandlers then
      -- Iterate over key handlers and call each one whose modifier(s) are pressed
      -- NB: Only if the exact correct modifiers are pressed will the shortcut get processed.
      for _, handler in ipairs(keyHandlers) do
        if compare_tables(handler.modifiers, self.modifiers_down) then
          handler.callback(handler.window, unpack(handler))
        end
      end
    end
  end
end

function UI:onMouseDown(code, x, y)
  self:setMouseReleased(false)
  local repaint = false
  local button = self.button_codes[code] or code
  if self.app.moviePlayer.playing then
    if button == "left" then
      self.app.moviePlayer:stop()
    end
    return true
  end
  if self.cursor_entity == nil and self.down_count == 0 and
      self.cursor == self.default_cursor then
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

function UI:onMouseWheel(x, y)
  Window.onMouseWheel(self, x, y)
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

--! Called when focus changes on game window.
--!param gain (number) 1 for in-focus, 0 for out-of-focus
function UI:onWindowActive(gain)
  self:setWindowActiveStatus(gain == 1)
end

--! Stores the game window active status
--!param state (boolean) true for in-focus, false for out-of-focus
function UI:setWindowActiveStatus(state)
  self.app.window_active_status = state
end

--! Gets the game window active status
--!return true for in-focus, false for out-of-focus
function UI:getWindowActiveStatus()
  return self.app.window_active_status
end

--! Window has been resized by the user
--!param width (integer) New window width
--!param height (integer) New window height
function UI:onWindowResize(width, height)
  if not self.app.config.fullscreen then
    self:changeResolution(width, height)
  end
end

function UI:onMouseMove(x, y, dx, dy)
  if self.mouse_released then
    return false
  end

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

--! Process SDL_MULTIGESTURE events.
--!
--!return (boolean) event processed indicator
function UI:onMultiGesture()
  return false
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
  if self.app.world and window:mustPause() then
    self.app.world:setSpeed("Pause")
    self.app.video:setBlueFilterActive(false) -- mustPause windows shouldn't cause tainting
  end
  if window.modal_class == "main" or window.modal_class == "fullscreen" then
    self.editing_allowed = false -- do not allow editing rooms if main windows (build, furnish, hire) are open
  end
  Window.addWindow(self, window)
end

function UI:removeWindow(closing_window)
  if Window.removeWindow(self, closing_window) then
    local class = closing_window.modal_class
    if class and self.modal_windows[class] == closing_window then
      self.modal_windows[class] = nil
    end
    if self.app.world and self.app.world:isCurrentSpeed("Pause") then
      local pauseGame = self:checkForMustPauseWindows()
      if not pauseGame and closing_window:mustPause() then
        self.app.world:setSpeed(self.app.world.prev_speed)
      end
    end
    if closing_window.modal_class == "main" or closing_window.modal_class == "fullscreen" then
      self.editing_allowed = true -- allow editing rooms again when main window is closed
    end
    return true
  else
    return false
  end
end

--! Function to check if we have any must pause windows open
--!return (bool) Returns true if a must pause window is found
function UI:checkForMustPauseWindows()
  for _, window in pairs(self.windows) do
    if window:mustPause() then return true end
  end
  return false
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
  self:removeKeyHandler("global_showLuaConsole", self)
  self:removeKeyHandler("global_runDebugScript", self)
  if self.app.config.debug then
    self:addKeyHandler("global_showLuaConsole", self, self.showLuaConsole)
    self:addKeyHandler("global_runDebugScript", self, self.runDebugScript)
  end
end

function UI:afterLoad(old, new)
  -- Get rid of old key handlers from save file.
  self.key_handlers = {}
  if old < 5 then
    self.editing_allowed = true
  end
  if old < 179 then
    if self.app.good_install_folder and not self.app.using_demo_files then
      local gfx = self.app.gfx
      gfx.cache.raw = {}
      gfx.cache.tabled = {}
      gfx.cache.palette = {}
      gfx.cache.palette_greyscale_ghost = {}
      gfx.cache.language_fonts = {}
      gfx.builtin_font = nil
    end
  end
  if old < 236 then
    local gfx = self.app.gfx
    local palette = gfx:loadPalette("QData", "PREF01V.PAL", true)
    self.tooltip_font = gfx:loadFontAndSpriteTable("QData", "Font00V", false, palette, { apply_ui_scale = true })
  end

  self:setupGlobalKeyHandlers()

  -- Cancel any saved screen movement from edge scrolling
  self.tick_scroll_amount_mouse = nil

  Window.afterLoad(self, old, new)
end

-- Stub to allow the function to be called in e.g. the information
-- dialog without having to worry about a GameUI being present
function UI:tutorialStep(...)
end

--! Perform the Screenshot action (usually by key bind 'global_screenshot')
function UI:makeScreenshot()
  -- Generate filename
  local timestamp = os.date("%Y%m%d-%H%M%S")
  local filename = TheApp.screenshot_dir .. ("Screenshot_%s.png"):format(timestamp)

  -- It's very unlikely you intentionally want multiple screenshots a second
  if lfs.attributes(filename, "size") ~= nil then
    print("Screenshot failed: File already exists")
    return
  end

  -- Take screenshot
  local res, err = self.app.video:takeScreenshot(filename)
  if not res then
    print("Screenshot failed: " .. err)
  else
    self.app.audio:playSound("SNAPSHOT.WAV")
  end
end

--! Closes one window (the topmost / active window, if possible)
--!return true if a window was closed
function UI:closeWindow()
  if not self.windows then
    return false
  end

  -- Stop the lose message being closed prematurely because we pressed "Escape" on the lose movie
  if self.app.moviePlayer.playing then
    return false
  end

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

function UI:pauseMovie()
  if self.app.moviePlayer.playing then
    self.app.moviePlayer:togglePause()
  end
end

-- Stub for compatibility with savegames r1896-1921
function UI:stopVideo() end
