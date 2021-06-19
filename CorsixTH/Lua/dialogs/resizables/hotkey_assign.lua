--[[ Copyright (c) 2019 James "leiget" Russell

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

--! Customise window used in the main menu and ingame.
class "UIHotkeyAssign" (UIResizable)

---@type UIHotkeyAssign
local UIHotkeyAssign = _G["UIHotkeyAssign"]

local col_bg = {
  red = 154,
  green = 146,
  blue = 198,
}

local col_hotkeybox = {
  red = 81,
  green = 76,
  blue = 150,
}

local col_highlight = {
  red = 174,
  green = 166,
  blue = 218,
}

local col_shadow = {
  red = 134,
  green = 126,
  blue = 178,
}

local col_caption = {
  red = 174,
  green = 166,
  blue = 218,
}

local hotkey_backup = {}
local hotkeys_backedUp = false
local hotkey_buttons = {}

local key_hierarchy = {
  "ctrl",
  "alt",
  "shift",
  "gui",
  "menu",
  "return",
  "enter",
  "escape",
  "backspace",
  "tab",
  "space",
  "!",
  "\"",
  "#",
  "%",
  "$",
  "&",
  "\'",
  "(",
  ")",
  "*",
  "+",
  ",",
  "-",
  ".",
  "/",
  "0",
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
  "7",
  "8",
  "9",
  ":",
  ";",
  "<",
  "=",
  ">",
  "?",
  "@",
  "[",
  "\\",
  "]",
  "^",
  "_",
  "`",
  "a",
  "b",
  "c",
  "d",
  "e",
  "f",
  "g",
  "h",
  "i",
  "j",
  "k",
  "l",
  "m",
  "n",
  "o",
  "p",
  "q",
  "r",
  "s",
  "t",
  "u",
  "v",
  "w",
  "x",
  "y",
  "z",
  "capslock",
  "f1",
  "f2",
  "f3",
  "f4",
  "f5",
  "f6",
  "f7",
  "f8",
  "f9",
  "f10",
  "f11",
  "f12",
  "printscreen",
  "scrolllock",
  "pause",
  "insert",
  "home",
  "pageup",
  "delete",
  "end",
  "pagedown",
  "right",
  "left",
  "down",
  "up",
  "numlock",
  "f13",
  "f14",
  "f15",
  "f16",
  "f17",
  "f18",
  "f19",
  "f20",
  "f21",
  "f22",
  "f23",
  "f24",
  "keypad 0",
  "keypad 1",
  "keypad 2",
  "keypad 3",
  "keypad 4",
  "keypad 6",
  "keypad 7",
  "keypad 8",
  "keypad 9",
  "keypad .",
}

--! Removes qualifiers like left and right from modifier keys
--! e.g. left shift becomes shift.
--!
--!param noted_keys (table) Array of keys to normalize
--!return (table) New array of normalized keys
local function normalize_modifiers(noted_keys)
  local res = shallow_clone(noted_keys)

  -- Go through the new key table and remove "left" or "right" from any modifier strings.
  for k, v in ipairs(res) do
    -- Ctrl
    if string.find(v, "ctrl", 1, true) then
      res[k] = "ctrl"
    end
    -- Alt
    if string.find(v, "alt", 1, true) then
      res[k] = "alt"
    end
    -- Shift
    if string.find(v, "shift", 1, true) then
      res[k] = "shift"
    end
    -- GUI
    if string.find(v, "gui", 1, true) then
      res[k] = "gui"
    end
    -- MENU
    if string.find(v, "menu", 1, true) then
      res[k] = "menu"
    end
  end

  return res
end

--! Return an array of the keys from the given array, sorted into a
--! deterministic order.
local function sort_noted_keys(noted_keys)
  -- Go through the new noted_keys and order it according to the key hairarchy.
  local result = {}
  local idx = 1

  for _, v1 in ipairs(key_hierarchy) do
    for _, v2 in ipairs(noted_keys) do
      if v1 == v2 then
        result[idx] = v2
        idx = idx + 1
      end
    end
  end

  return result
end

--! Return an array with the modifier keys removed.
--! Used when assigning the scroll keys.
--!
--!param noted_keys (table) Array of keys to check for modifiers
--!return (table) New array of keys without modifiers
local function remove_modifiers(noted_keys)
  local res = shallow_clone(noted_keys)

  for k, v in ipairs(res) do
    -- Ctrl
    if string.find(v, "ctrl", 1, true) then
      table.remove(res, k)
    end
    -- Alt
    if string.find(v, "alt", 1, true) then
      table.remove(res, k)
    end
    -- Shift
    if string.find(v, "shift", 1, true) then
      table.remove(res, k)
    end
    -- GUI
    if string.find(v, "gui", 1, true) then
      table.remove(res, k)
    end
    -- MENU
    if string.find(v, "menu", 1, true) then
      table.remove(res, k)
    end
  end

  return res
end

--! Determine if the given key sequence is already being used for an action in
--! the app.
--!
--!param keys (table) A sorted array of the key sequence to test
--!param app (App) The App
--!return (boolean,string) Whether the key is used, and if so, for what action
local function is_hotkey_used(keys, app)
  -- Find out if there is another hotkey with the same key assignment.
  -- Make sure it's not the same key we are currently mapping.
  local our_key_str = serialize(keys)
  local key_str = ""
  -- Go through the app.hotkeys table...
  for k, _ in pairs(app.hotkeys) do
    if type(app.hotkeys[k]) == "table" then
      key_str = serialize(app.hotkeys[k])
    elseif type(app.hotkeys[k]) == "string" then
      key_str = serialize({app.hotkeys[k]})
    end

    -- If the key(s) that were pressed match the current key in the "app.hotkey" table...
    if our_key_str == key_str then
      return true, k
    end
  end

  return false
end

--! Assign the given key sequence to a hotkey.
--!
--! Validates a given key sequence and applies it to the given hotkey.
--! If the key sequence is already used, first swap that hotkey with the given
--! one to prevent duplicates.
--!
--!param hotkey (string) The hotkey to change
--!param hotkey_buttons_table (table) Configuration table of all hotkeys
--!param app (App) The App
local function hotkey_input(hotkey, hotkey_buttons_table, app)
  --[[
  TODO:
    -- Keypad when numlock is off doesn't work correctly.
        Seems that keypad input isn't working correctly in ui.lua or something.
        Left for future patch.
    -- Disable the "global_exitApp" hotkey while assigning hotkeys?
        Even when "global_exitApp" isn't added at startup Alt+F4 still abandons program. Why?
    -- Modifier keys for other languages necessary?
        -- Ex: STRG for german's "CTRL".
  ]]

  local noted_keys = hotkey_buttons_table[hotkey].noted_keys

  -- Check if the table even has anything or has too much.
  local table_length = #noted_keys
  if table_length == 0 or table_length > 4 then
    hotkey_buttons_table[hotkey]:abort()
    return
  end

  -- If the noted key input is "enter", "return", or "escape"...
  if array_join(noted_keys) == array_join( {"enter"} ) or
      array_join(noted_keys) == array_join( {"return"} ) or
      array_join(noted_keys) == array_join( {"escape"} ) then
    -- Abort, as we don't want the enter or esc key used for anything other
    --  than "global_confirm" and "global_cancel".
    hotkey_buttons_table[hotkey]:abort()
    return
  end

  noted_keys = normalize_modifiers(noted_keys)
  noted_keys = sort_noted_keys(noted_keys)

  -- If the current hotkey is a scroll key...
  if hotkey == "ingame_scroll_up" or
      hotkey == "ingame_scroll_down" or
      hotkey == "ingame_scroll_left" or
      hotkey == "ingame_scroll_right" then
    -- Get rid of any modifiers, as they won't work correctly, anyway.
    noted_keys = remove_modifiers(noted_keys)
  end

  local hotkey_used, hotkey_used_key = is_hotkey_used(noted_keys, app)

  -- If this hotkey was used for a different action, swap with current assignment
  if hotkey_used and hotkey ~= hotkey_used_key then
    app.hotkeys[hotkey_used_key] = shallow_clone(app.hotkeys[hotkey])
    if hotkey_buttons_table[hotkey_used_key] then
      hotkey_buttons_table[hotkey_used_key]:setText( string.upper(array_join(app.hotkeys[hotkey_used_key], "+")) )
    end
  end

  if #noted_keys == 1 then
    noted_keys = noted_keys[1]
  end

  app.hotkeys[hotkey] = noted_keys
  -- If the key is "global_cancel_alt"...
  if hotkey == "global_cancel_alt" then
    app.hotkeys["global_stop_movie_alt"] = noted_keys
    app.hotkeys["global_window_close_alt"] = noted_keys
  end

  hotkey_buttons_table[hotkey]:setText( string.upper( array_join(app.hotkeys[hotkey], "+") ) )
end

function UIHotkeyAssign:UIHotkeyAssign(ui, mode)
  self:UIResizable(ui, 640, 480, col_bg)

  local panel_width = 100
  local panel_height = 20

  local current_pos_x = 1
  local current_pos_y = 1
  local max_x_pos_step = 3
  local max_y_pos_step = 17

  -- Panel x position table.
  self.panel_pos_table_x = {}
  self.panel_pos_table_x[1] = 10
  self.panel_pos_table_x[2] = 220
  self.panel_pos_table_x[3] = 430
  -- Panel y position table.
  self.panel_pos_table_y = {}
  for i=1, 17, 1 do
    self.panel_pos_table_y[i] = (i*20)+20
  end

  -- Gets the next x position of the hotkey panels.
  -- Easier to use than manually putting it all in.
  local function get_next_pos_x()
    current_pos_x = current_pos_x + 1
    if(current_pos_x > max_x_pos_step) then
      current_pos_x=max_x_pos_step
    end
    return current_pos_x
  end
  -- Gets the next y position for the hotkey panels.
  local function get_next_pos_y()
    current_pos_y = current_pos_y + 1
    if(current_pos_y > max_y_pos_step) then
      current_pos_y = 1
      get_next_pos_x()
    end
    return current_pos_y
  end

  self.ui = ui
  self.mode = mode
  self.modal_class = mode == "menu" and "main menu" or "options" or "folders"
  self.on_top = mode == "menu"
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.25)
  self.default_button_sound = "selectx.wav"
  self.app = ui.app
  self.hotkey_buttons = hotkey_buttons

  if not hotkeys_backedUp then
    hotkey_backup = shallow_clone(self.app.hotkeys)
    hotkeys_backedUp = true
  end

  -- Title
  self:addBevelPanel(220, 10, 200, 20, col_caption):setLabel(_S.hotkey_window.caption_main)

  -- Location of original game
  local built_in = self.app.gfx:loadMenuFont()

  -- Global Keys
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width*2, panel_height, col_caption):setLabel(_S.hotkey_window.panel_globalKeys)
  get_next_pos_y()
  -- global_exitApp
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.global_exitApp)
  self.hotkey_buttons["global_exitApp"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("global_exitApp") end, nil):setText( string.upper(array_join(ui.app.hotkeys["global_exitApp"], "+")) )
  get_next_pos_y()
  -- global_resetApp
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.global_resetApp)
  self.hotkey_buttons["global_resetApp"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("global_resetApp") end, nil):setText( string.upper(array_join(ui.app.hotkeys["global_resetApp"], "+")) )
  get_next_pos_y()
  -- global_screenshot
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.global_screenshot)
  self.hotkey_buttons["global_screenshot"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("global_screenshot") end, nil):setText( string.upper(array_join(ui.app.hotkeys["global_screenshot"], "+")) )
  get_next_pos_y()
  -- global_releaseMouse
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.global_releaseMouse)
  self.hotkey_buttons["global_releaseMouse"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("global_releaseMouse") end, nil):setText( string.upper(array_join(ui.app.hotkeys["global_releaseMouse"], "+")) )
  get_next_pos_y()

  -- global_confirm_alt
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.global_confirm_alt)
  self.hotkey_buttons["global_confirm_alt"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("global_confirm_alt") end, nil):setText( string.upper(array_join(ui.app.hotkeys["global_confirm_alt"], "+")) )
  get_next_pos_y()
  -- global_cancel_alt
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.global_cancel_alt)
  self.hotkey_buttons["global_cancel_alt"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("global_cancel_alt") end, nil):setText( string.upper(array_join(ui.app.hotkeys["global_cancel_alt"], "+")) )
  get_next_pos_y()

  -- General In-Game Keys
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width*2, panel_height, col_caption):setLabel(_S.hotkey_window.panel_generalInGameKeys)
  get_next_pos_y()
  -- ingame_showmenubar
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_showmenubar)
  self.hotkey_buttons["ingame_showmenubar"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_showmenubar") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_showmenubar"], "+")) )
  get_next_pos_y()
  -- ingame_saveMenu
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_saveMenu)
  self.hotkey_buttons["ingame_saveMenu"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_saveMenu") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_saveMenu"], "+")) )
  get_next_pos_y()
  -- ingame_loadMenu
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_loadMenu)
  self.hotkey_buttons["ingame_loadMenu"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_loadMenu") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_loadMenu"], "+")) )
  get_next_pos_y()
  -- ingame_jukebox
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_jukebox)
  self.hotkey_buttons["ingame_jukebox"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_jukebox") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_jukebox"], "+")) )
  get_next_pos_y()
  -- ingame_openFirstMessage
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_openFirstMessage)
  self.hotkey_buttons["ingame_openFirstMessage"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_openFirstMessage") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_openFirstMessage"], "+")) )
  get_next_pos_y()
  -- ingame_quickSave
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_quickSave)
  self.hotkey_buttons["ingame_quickSave"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_quickSave") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_quickSave"], "+")) )
  get_next_pos_y()
  -- ingame_quickLoad
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_quickLoad)
  self.hotkey_buttons["ingame_quickLoad"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_quickLoad") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_quickLoad"], "+")) )
  get_next_pos_y()
  -- ingame_restartLevel
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_restartLevel)
  self.hotkey_buttons["ingame_restartLevel"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_restartLevel") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_restartLevel"], "+")) )
  get_next_pos_y()
  -- ingame_quitLevel
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_quitLevel)
  self.hotkey_buttons["ingame_quitLevel"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_quitLevel") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_quitLevel"], "+")) )
  get_next_pos_y()

  -- Scroll keys.
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width*2, panel_height, col_caption):setLabel(_S.hotkey_window.panel_scrollKeys)
  get_next_pos_y()
  -- ingame_scroll_up
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_scroll_up)
  self.hotkey_buttons["ingame_scroll_up"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_scroll_up") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_scroll_up"], "+")) )
  get_next_pos_y()
  -- ingame_scroll_down
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_scroll_down)
  self.hotkey_buttons["ingame_scroll_down"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_scroll_down") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_scroll_down"], "+")) )
  get_next_pos_y()
  -- ingame_scroll_left
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_scroll_left)
  self.hotkey_buttons["ingame_scroll_left"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_scroll_left") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_scroll_left"], "+")) )
  get_next_pos_y()
  -- ingame_scroll_right
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_scroll_right)
  self.hotkey_buttons["ingame_scroll_right"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_scroll_right") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_scroll_right"], "+")) )
  get_next_pos_y()
  -- ingame_scroll_shift
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_scroll_shift)
  self.hotkey_buttons["ingame_scroll_shift"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_scroll_shift") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_scroll_shift"], "+")) )
  get_next_pos_y()

  -- Zoom Keys
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width*2, panel_height, col_caption):setLabel(_S.hotkey_window.panel_zoomKeys)
  get_next_pos_y()
  -- ingame_zoom_in
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_zoom_in)
  self.hotkey_buttons["ingame_zoom_in"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_zoom_in") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_zoom_in"], "+")) )
  get_next_pos_y()
  -- ingame_zoom_in_more
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_zoom_in_more)
  self.hotkey_buttons["ingame_zoom_in_more"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_zoom_in_more") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_zoom_in_more"], "+")) )
  get_next_pos_y()
  -- ingame_zoom_out
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_zoom_out)
  self.hotkey_buttons["ingame_zoom_out"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_zoom_out") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_zoom_out"], "+")) )
  get_next_pos_y()
  -- ingame_zoom_out_more
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_zoom_out_more)
  self.hotkey_buttons["ingame_zoom_out_more"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_zoom_out_more") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_zoom_out_more"], "+")) )
  get_next_pos_y()
  -- ingame_reset_zoom
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_reset_zoom)
  self.hotkey_buttons["ingame_reset_zoom"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_reset_zoom") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_reset_zoom"], "+")) )
  get_next_pos_y()

  -- Misc. In-Game Keys
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width*2, panel_height, col_caption):setLabel(_S.hotkey_window.panel_miscInGameKeys)
  get_next_pos_y()
  -- ingame_rotateobject
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_rotateobject)
  self.hotkey_buttons["ingame_rotateobject"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_rotateobject") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_rotateobject"], "+")) )
  get_next_pos_y()
  -- ingame_patient_gohome
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_patient_gohome)
  self.hotkey_buttons["ingame_patient_gohome"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_patient_gohome") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_patient_gohome"], "+")) )
  get_next_pos_y()
  -- ingame_setTransparent
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_setTransparent)
  self.hotkey_buttons["ingame_setTransparent"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_setTransparent") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_setTransparent"], "+")) )
  get_next_pos_y()
  get_next_pos_y()

  -- Toggle Keys
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width*2, panel_height, col_caption):setLabel(_S.hotkey_window.panel_toggleKeys)
  get_next_pos_y()
  -- ingame_toggleAnnouncements
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_toggleAnnouncements)
  self.hotkey_buttons["ingame_toggleAnnouncements"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_toggleAnnouncements") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_toggleAnnouncements"], "+")) )
  get_next_pos_y()
  -- ingame_toggleSounds
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_toggleSounds)
  self.hotkey_buttons["ingame_toggleSounds"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_toggleSounds") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_toggleSounds"], "+")) )
  get_next_pos_y()
  -- ingame_toggleMusic
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_toggleMusic)
  self.hotkey_buttons["ingame_toggleMusic"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_toggleMusic") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_toggleMusic"], "+")) )
  get_next_pos_y()
  -- ingame_toggleAdvisor
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_toggleAdvisor)
  self.hotkey_buttons["ingame_toggleAdvisor"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_toggleAdvisor") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_toggleAdvisor"], "+")) )
  get_next_pos_y()
  -- ingame_toggleInfo
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_toggleInfo)
  self.hotkey_buttons["ingame_toggleInfo"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_toggleInfo") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_toggleInfo"], "+")) )
  get_next_pos_y()

  if self.ui.app.config.debug then
    -- Debug Keys
    self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width*2, panel_height, col_caption):setLabel(_S.hotkey_window.panel_debugKeys)
    get_next_pos_y()
    -- global_connectDebugger
    self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.global_connectDebugger)
    self.hotkey_buttons["global_connectDebugger"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
      :makeHotkeyBox(function() self:confirm_func("global_connectDebugger") end, nil):setText( string.upper(array_join(ui.app.hotkeys["global_connectDebugger"], "+")) )
    get_next_pos_y()
    -- global_showLuaConsole
    self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.global_showLuaConsole)
    self.hotkey_buttons["global_showLuaConsole"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
      :makeHotkeyBox(function() self:confirm_func("global_showLuaConsole") end, nil):setText( string.upper(array_join(ui.app.hotkeys["global_showLuaConsole"], "+")) )
    get_next_pos_y()
    -- global_runDebugScript
    self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.global_runDebugScript)
    self.hotkey_buttons["global_runDebugScript"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
      :makeHotkeyBox(function() self:confirm_func("global_runDebugScript") end, nil):setText( string.upper(array_join(ui.app.hotkeys["global_runDebugScript"], "+")) )
    get_next_pos_y()
    -- ingame_showCheatWindow
    self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_showCheatWindow)
    self.hotkey_buttons["ingame_showCheatWindow"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
      :makeHotkeyBox(function() self:confirm_func("ingame_showCheatWindow") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_showCheatWindow"], "+")) )
    get_next_pos_y()
    -- ingame_poopLog
    self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_poopLog)
    self.hotkey_buttons["ingame_poopLog"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
      :makeHotkeyBox(function() self:confirm_func("ingame_poopLog") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_poopLog"], "+")) )
    get_next_pos_y()
    -- ingame_poopStrings
    self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_poopStrings)
    self.hotkey_buttons["ingame_poopStrings"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
      :makeHotkeyBox(function() self:confirm_func("ingame_poopStrings") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_poopStrings"], "+")) )
    get_next_pos_y()
  end

  -- Toggle keys assignment window.
  self:addBevelPanel(self.panel_pos_table_x[1], 385, 200, 40, col_bg):setLabel(_S.hotkey_window.caption_panels)
    :makeButton(0, 0, 200, 40, nil, self.toggleButton):setTooltip(_S.tooltip.hotkey_window.caption_panels)
  -- Toggle game speed assignment window.
  self:addBevelPanel(self.panel_pos_table_x[2], 385, 200, 40, col_bg):setLabel(_S.hotkey_window.button_gameSpeed)
    :makeButton(0, 0, 200, 40, nil, self.gameSpeedButton):setTooltip(_S.tooltip.hotkey_window.button_gameSpeed)
  -- Store and recall position assignment window.
  self:addBevelPanel(self.panel_pos_table_x[3], 385, 200, 40, col_bg):setLabel(_S.hotkey_window.button_recallPosKeys)
    :makeButton(0, 0, 200, 40, nil, self.storeRecallPosButton):setTooltip(_S.tooltip.hotkey_window.button_recallPosKeys)

  -- "Accept" button
  self:addBevelPanel(self.panel_pos_table_x[1], 430, 200, 40, col_bg):setLabel(_S.hotkey_window.button_accept)
    :makeButton(0, 0, 180, 40, nil, self.buttonAccept):setTooltip(_S.tooltip.hotkey_window.button_accept)
  -- Reset to defaults button.
  self:addBevelPanel(self.panel_pos_table_x[2], 430, 200, 40, col_bg):setLabel(_S.hotkey_window.button_defaults)
    :makeButton(0, 0, 180, 40, nil, self.buttonDefaults):setTooltip(_S.tooltip.hotkey_window.button_defaults)
  -- "Cancel" button
  self:addBevelPanel(self.panel_pos_table_x[3], 430, 200, 40, col_bg):setLabel(_S.hotkey_window.button_cancel)
    :makeButton(0, 0, 180, 40, nil, self.buttonCancel):setTooltip(_S.tooltip.hotkey_window.button_cancel)


  self.built_in_font = built_in
end

function UIHotkeyAssign:buttonAccept()
  self.app:saveHotkeys()
  hotkeys_backedUp = false

  self:close()
  local window = UIOptions(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIHotkeyAssign:buttonDefaults()
  -- Copy the default hotkeys into the app's current hotkey table.
  self.app.hotkeys = shallow_clone(select(5, corsixth.require("config_finder")))

  -- Reload all hotkey boxes' text.
  for k, _ in pairs(self.hotkey_buttons) do
    self.hotkey_buttons[k]:setText( string.upper(array_join(self.app.hotkeys[k], "+")) )
  end
end

function UIHotkeyAssign:buttonCancel()
  --Reset all keys back to what they were before opening the hotkey window.
  self.app.hotkeys = shallow_clone(hotkey_backup)
  hotkeys_backedUp = false

  self:close()
  local window = UIOptions(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIHotkeyAssign:close()
  UIResizable.close(self)
  if self.mode == "menu"  then
    self.ui:addWindow(UIOptions(self.ui, "menu"))
  end
end

function UIHotkeyAssign:toggleButton()
  self:close()
  local window = UIHotkeyAssign_Panels(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIHotkeyAssign:gameSpeedButton()
  self:close()
  local window = UIHotkeyAssign_GameSpeed(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIHotkeyAssign:storeRecallPosButton()
  self:close()
  local window = UIHotkeyAssign_storeRecallPos(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIHotkeyAssign:confirm_func(hotkey)
  hotkey_input(hotkey, self.hotkey_buttons, self.app)
end

--! Assign panel keys window.
class "UIHotkeyAssign_Panels" (UIResizable)

---@type UIHotkeyAssign_Panels
local UIHotkeyAssign_Panels = _G["UIHotkeyAssign_Panels"]

function UIHotkeyAssign_Panels:UIHotkeyAssign_Panels(ui, mode)
  self:UIResizable(ui, 240, 460, col_bg)

  local panel_width = 110
  local panel_height = 20
  local panel_x_pos = 10
  local current_pos_y = 1

  self.ui = ui
  self.mode = mode
  self.modal_class = mode == "menu" and "main menu" or "options" or "folders"
  self.on_top = mode == "menu"
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.25)
  self.default_button_sound = "selectx.wav"
  self.app = ui.app
  self.hotkey_buttons = {}

  -- Panel y position table.
  self.panel_pos_table_y = {}
  for i=1, 18, 1 do
    self.panel_pos_table_y[i] = (i*20)+20
  end

  -- Title
  self:addBevelPanel(10, 10, 220, 20, col_caption):setLabel(_S.hotkey_window.caption_panels)

  -- "Back" button
  self:addBevelPanel(10, 410, 220, 40, col_bg):setLabel(_S.hotkey_window.button_back)
    :makeButton(0, 0, 220, 40, nil, self.buttonBack):setTooltip(_S.tooltip.hotkey_window.button_back_02)

  -- ingame_panel_bankManager
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_panel_bankManager)
  self.hotkey_buttons["ingame_panel_bankManager"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_panel_bankManager") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_panel_bankManager"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_panel_bankStats
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_panel_bankStats)
  self.hotkey_buttons["ingame_panel_bankStats"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_panel_bankStats") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_panel_bankStats"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_panel_staffManage
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_panel_staffManage)
  self.hotkey_buttons["ingame_panel_staffManage"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_panel_staffManage") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_panel_staffManage"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_panel_townMap
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_panel_townMap)
  self.hotkey_buttons["ingame_panel_townMap"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_panel_townMap") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_panel_townMap"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_panel_casebook
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_panel_casebook)
  self.hotkey_buttons["ingame_panel_casebook"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_panel_casebook") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_panel_casebook"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_panel_research
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_panel_research)
  self.hotkey_buttons["ingame_panel_research"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_panel_research") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_panel_research"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_panel_status
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_panel_status)
  self.hotkey_buttons["ingame_panel_status"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_panel_status") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_panel_status"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_panel_charts
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_panel_charts)
  self.hotkey_buttons["ingame_panel_charts"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_panel_charts") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_panel_charts"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_panel_policy
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_panel_policy)
  self.hotkey_buttons["ingame_panel_policy"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_panel_policy") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_panel_policy"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_panel_buildRoom
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_panel_buildRoom)
  self.hotkey_buttons["ingame_panel_buildRoom"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_panel_buildRoom") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_panel_buildRoom"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_panel_furnishCorridor
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_panel_furnishCorridor)
  self.hotkey_buttons["ingame_panel_furnishCorridor"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_panel_furnishCorridor") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_panel_furnishCorridor"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_panel_editRoom
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_panel_editRoom)
  self.hotkey_buttons["ingame_panel_editRoom"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_panel_editRoom") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_panel_editRoom"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_panel_hireStaff
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_panel_hireStaff)
  self.hotkey_buttons["ingame_panel_hireStaff"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_panel_hireStaff") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_panel_hireStaff"], "+")) )
  current_pos_y = current_pos_y + 1

  --
  self:addBevelPanel(10, self.panel_pos_table_y[current_pos_y], panel_width*2, panel_height, col_bg):setLabel(_S.hotkey_window.panel_altPanelKeys)
  current_pos_y = current_pos_y + 1
  -- ingame_panel_map_alt
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_panel_map_alt)
  self.hotkey_buttons["ingame_panel_map_alt"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_panel_map_alt") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_panel_map_alt"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_panel_research_alt
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_panel_research_alt)
  self.hotkey_buttons["ingame_panel_research_alt"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_panel_research_alt") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_panel_research_alt"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_panel_casebook_alt
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_panel_casebook_alt)
  self.hotkey_buttons["ingame_panel_casebook_alt"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_panel_casebook_alt") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_panel_casebook_alt"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_panel_casebook_alt02
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_panel_casebook_alt02)
  self.hotkey_buttons["ingame_panel_casebook_alt02"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_panel_casebook_alt02") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_panel_casebook_alt02"], "+")) )
end

function UIHotkeyAssign_Panels:close()
  UIResizable.close(self)
  if self.mode == "menu"  then
    self.ui:addWindow(UIHotkeyAssign(self.ui, "menu"))
  end
end

function UIHotkeyAssign_Panels:buttonBack()
  self:close()
  local window = UIHotkeyAssign(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIHotkeyAssign_Panels:confirm_func(hotkey)
  hotkey_input(hotkey, self.hotkey_buttons, self.app)
end

--! Assign panel keys window.
class "UIHotkeyAssign_GameSpeed" (UIResizable)

---@type UIHotkeyAssign_GameSpeed
local UIHotkeyAssign_GameSpeed = _G["UIHotkeyAssign_GameSpeed"]

function UIHotkeyAssign_GameSpeed:UIHotkeyAssign_GameSpeed(ui, mode)
  self:UIResizable(ui, 240, 260, col_bg)

  local panel_width = 110
  local panel_height = 20
  local panel_x_pos = 10
  local current_pos_y = 1

  self.ui = ui
  self.mode = mode
  self.modal_class = mode == "menu" and "main menu" or "options" or "folders"
  self.on_top = mode == "menu"
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.25)
  self.default_button_sound = "selectx.wav"
  self.app = ui.app
  self.hotkey_buttons = {}

  -- Panel y position table.
  self.panel_pos_table_y = {}
  for i=1, 9, 1 do
    self.panel_pos_table_y[i] = (i*20)+20
  end

  -- Title
  self:addBevelPanel(10, 10, 220, 20, col_caption):setLabel(_S.hotkey_window.panel_gameSpeedKeys)

  -- "Back" button
  self:addBevelPanel(10, 210, 220, 40, col_bg):setLabel(_S.hotkey_window.button_back)
    :makeButton(0, 0, 220, 40, nil, self.buttonBack):setTooltip(_S.tooltip.hotkey_window.button_back_02)

    -- Game Speed Keys
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width*2, panel_height, col_caption):setLabel(_S.hotkey_window.panel_gameSpeedKeys)
  current_pos_y = current_pos_y + 1
  -- ingame_pause
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_pause)
  self.hotkey_buttons["ingame_pause"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_pause") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_pause"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_gamespeed_slowest
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_gamespeed_slowest)
  self.hotkey_buttons["ingame_gamespeed_slowest"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_gamespeed_slowest") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_gamespeed_slowest"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_gamespeed_slower
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_gamespeed_slower)
  self.hotkey_buttons["ingame_gamespeed_slower"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_gamespeed_slower") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_gamespeed_slower"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_gamespeed_normal
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_gamespeed_normal)
  self.hotkey_buttons["ingame_gamespeed_normal"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_gamespeed_normal") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_gamespeed_normal"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_gamespeed_max
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_gamespeed_max)
  self.hotkey_buttons["ingame_gamespeed_max"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_gamespeed_max") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_gamespeed_max"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_gamespeed_thensome
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_gamespeed_thensome)
  self.hotkey_buttons["ingame_gamespeed_thensome"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_gamespeed_thensome") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_gamespeed_thensome"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_gamespeed_speedup
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_gamespeed_speedup)
  self.hotkey_buttons["ingame_gamespeed_speedup"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_gamespeed_speedup") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_gamespeed_speedup"], "+")) )
end

function UIHotkeyAssign_GameSpeed:close()
  UIResizable.close(self)
  if self.mode == "menu"  then
    self.ui:addWindow(UIHotkeyAssign(self.ui, "menu"))
  end
end

function UIHotkeyAssign_GameSpeed:buttonBack()
  self:close()
  local window = UIHotkeyAssign(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIHotkeyAssign_GameSpeed:confirm_func(hotkey)
  hotkey_input(hotkey, self.hotkey_buttons, self.app)
end

--! Customise window used in the main menu and ingame.
class "UIHotkeyAssign_storeRecallPos" (UIResizable)

---@type UIHotkeyAssign_storeRecallPos
local UIHotkeyAssign_storeRecallPos = _G["UIHotkeyAssign_storeRecallPos"]

function UIHotkeyAssign_storeRecallPos:UIHotkeyAssign_storeRecallPos(ui, mode)
  self:UIResizable(ui, 440, 320, col_bg)

  local panel_width = 100
  local panel_height = 20
  local panel_x_pos = 10
  local current_pos_y = 1

  self.ui = ui
  self.mode = mode
  self.modal_class = mode == "menu" and "main menu" or "options" or "folders"
  self.on_top = mode == "menu"
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.25)
  self.default_button_sound = "selectx.wav"
  self.app = ui.app
  self.hotkey_buttons = {}

  -- Panel y position table.
  self.panel_pos_table_y = {}
  for i=1, 11, 1 do
    self.panel_pos_table_y[i] = (i*20)+20
  end

  -- Title
  self:addBevelPanel(10, 10, 420, panel_height, col_caption):setLabel(_S.hotkey_window.panel_recallPosKeys)

  -- "Back" button
  self:addBevelPanel(10, 270, 420, 40, col_bg):setLabel(_S.hotkey_window.button_back)
    :makeButton(0, 0, 420, 40, nil, self.buttonBack):setTooltip(_S.tooltip.hotkey_window.button_back_02)

  -- Store Position Panel
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], 200, panel_height, col_caption):setLabel(_S.hotkey_window.panel_storePosKey)
  current_pos_y = current_pos_y + 1
  -- ingame_storePosition_1
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_storePosition_1)
  self.hotkey_buttons["ingame_storePosition_1"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_storePosition_1") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_storePosition_1"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_storePosition_2
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_storePosition_2)
  self.hotkey_buttons["ingame_storePosition_2"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_storePosition_2") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_storePosition_2"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_storePosition_3
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_storePosition_3)
  self.hotkey_buttons["ingame_storePosition_3"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_storePosition_3") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_storePosition_3"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_storePosition_4
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_storePosition_4)
  self.hotkey_buttons["ingame_storePosition_4"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_storePosition_4") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_storePosition_4"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_storePosition_5
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_storePosition_5)
  self.hotkey_buttons["ingame_storePosition_5"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_storePosition_5") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_storePosition_5"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_storePosition_6
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_storePosition_6)
  self.hotkey_buttons["ingame_storePosition_6"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_storePosition_6") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_storePosition_6"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_storePosition_7
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_storePosition_7)
  self.hotkey_buttons["ingame_storePosition_7"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_storePosition_7") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_storePosition_7"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_storePosition_8
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_storePosition_8)
  self.hotkey_buttons["ingame_storePosition_8"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_storePosition_8") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_storePosition_8"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_storePosition_9
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_storePosition_9)
  self.hotkey_buttons["ingame_storePosition_9"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_storePosition_9") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_storePosition_9"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_storePosition_0
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_storePosition_0)
  self.hotkey_buttons["ingame_storePosition_0"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_storePosition_0") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_storePosition_0"], "+")) )

  --Go to the next column.
  current_pos_y = 1
  panel_x_pos = panel_x_pos + 220
  -- Recall Position Panel
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], 200, panel_height, col_caption):setLabel(_S.hotkey_window.panel_recallPosKeys)
  current_pos_y = current_pos_y + 1
  -- ingame_recallPosition_1
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_recallPosition_1)
  self.hotkey_buttons["ingame_recallPosition_1"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_recallPosition_1") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_recallPosition_1"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_recallPosition_2
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_recallPosition_2)
  self.hotkey_buttons["ingame_recallPosition_2"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_recallPosition_2") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_recallPosition_2"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_recallPosition_3
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_recallPosition_3)
  self.hotkey_buttons["ingame_recallPosition_3"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_recallPosition_3") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_recallPosition_3"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_recallPosition_4
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_recallPosition_4)
  self.hotkey_buttons["ingame_recallPosition_4"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_recallPosition_4") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_recallPosition_4"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_recallPosition_5
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_recallPosition_5)
  self.hotkey_buttons["ingame_recallPosition_5"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_recallPosition_5") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_recallPosition_5"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_recallPosition_6
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_recallPosition_6)
  self.hotkey_buttons["ingame_recallPosition_6"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_recallPosition_6") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_recallPosition_6"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_recallPosition_7
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_recallPosition_7)
  self.hotkey_buttons["ingame_recallPosition_7"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_recallPosition_7") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_recallPosition_7"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_recallPosition_8
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_recallPosition_8)
  self.hotkey_buttons["ingame_recallPosition_8"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_recallPosition_8") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_recallPosition_8"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_recallPosition_9
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_recallPosition_9)
  self.hotkey_buttons["ingame_recallPosition_9"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_recallPosition_9") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_recallPosition_9"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_recallPosition_0
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_recallPosition_0)
  self.hotkey_buttons["ingame_recallPosition_0"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_recallPosition_0") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_recallPosition_0"], "+")) )
end

function UIHotkeyAssign_storeRecallPos:close()
  UIResizable.close(self)
  if self.mode == "menu"  then
    self.ui:addWindow(UIHotkeyAssign(self.ui, "menu"))
  end
end

function UIHotkeyAssign_storeRecallPos:buttonBack()
  self:close()
  local window = UIHotkeyAssign(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIHotkeyAssign_storeRecallPos:confirm_func(hotkey)
  hotkey_input(hotkey, self.hotkey_buttons, self.app)
end
