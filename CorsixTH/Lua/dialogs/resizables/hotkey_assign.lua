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

--! Custom key bindings
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
  "ctrl", "alt", "shift",
  "gui", "menu", "return", "enter", "escape", "backspace", "tab", "space",
  "!", "\"", "#", "%", "$", "&", "\'", "(", ")", "*", "+", ",", "-", ".", "/",
  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
  ":", ";", "<", "=", ">", "?", "@", "[", "\\", "]", "^", "_", "`",
  "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o",
  "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
  "capslock",
  "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10", "f11", "f12",
  "printscreen", "scrolllock", "pause", "insert", "home", "pageup", "delete",
  "end", "pagedown", "right", "left", "down", "up", "numlock",
  "f13", "f14", "f15", "f16", "f17", "f18", "f19", "f20", "f21", "f22", "f23",
  "f24",
  "keypad 0", "keypad 1", "keypad 2", "keypad 3", "keypad 4", "keypad 6",
  "keypad 7", "keypad 8", "keypad 9", "keypad .",
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

  local current_pos_y = 1

  -- Panel x position table.
  self.panel_pos_table_x = {}
  self.panel_pos_table_x[1] = 10
  self.panel_pos_table_x[2] = 220
  self.panel_pos_table_x[3] = 430

  -- Panel y button position table.
  self.panel_pos_table_y = {}
  for i=1, 12, 1 do
    self.panel_pos_table_y[i] = (i*30)+15
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

  self.key_pane = nil
  self.key_options = {{
      id = "global",
      title = _S.hotkey_window.panel_globalKeys,
      tooltip = _S.hotkey_window.panel_globalKeys,
      sections = {{
          title = _S.hotkey_window.panel_globalKeys,
          keys = {
            "global_exitApp",
            "global_resetApp",
            "global_screenshot",
            "global_releaseMouse",
            "global_confirm_alt",
            "global_cancel_alt" }}}},
    {
      id = "ingame",
      title = _S.hotkey_window.panel_generalInGameKeys,
      tooltip = _S.hotkey_window.panel_generalInGameKeys,
      sections = {{
          title = _S.hotkey_window.panel_generalInGameKeys,
          keys = {
            "ingame_showmenubar",
            "ingame_saveMenu",
            "ingame_loadMenu",
            "ingame_jukebox",
            "ingame_openFirstMessage",
            "ingame_quickSave",
            "ingame_quickLoad",
            "ingame_restartLevel",
            "ingame_quitLevel",
            "ingame_rotateobject",
            "ingame_patient_gohome",
            "ingame_setTransparent" }}}},
    {
      id = "speed",
      title = _S.hotkey_window.button_gameSpeedKeys,
      tooltip = _S.tooltip.hotkey_window.button_gameSpeedKeys,
      sections = {{
          title = _S.hotkey_window.panel_gameSpeedKeys,
          keys = {
            "ingame_pause",
            "ingame_gamespeed_slowest",
            "ingame_gamespeed_slower",
            "ingame_gamespeed_normal",
            "ingame_gamespeed_max",
            "ingame_gamespeed_thensome",
            "ingame_gamespeed_speedup" }}}},
    {
      id = "zoom",
      title = _S.hotkey_window.panel_zoomKeys,
      tooltip = _S.hotkey_window.panel_generalInGameKeys,
      sections = {{
          title = _S.hotkey_window.panel_zoomKeys,
          keys = {
            "ingame_zoom_in",
            "ingame_zoom_in_more",
            "ingame_zoom_out",
            "ingame_zoom_out_more",
            "ingame_reset_zoom" }}}},
    {
      id = "toggle",
      title = _S.hotkey_window.panel_toggleKeys,
      tooltip = _S.hotkey_window.panel_toggleKeys,
      sections = {{
          title = _S.hotkey_window.panel_toggleKeys,
          keys = {
            "ingame_toggleAnnouncements",
            "ingame_toggleSounds",
            "ingame_toggleMusic",
            "ingame_toggleAdvisor",
            "ingame_toggleInfo" }}}},
    {
      id = "panels",
      title = _S.hotkey_window.caption_panels,
      tooltip = _S.tooltip.hotkey_window.caption_panels,
      sections = {{
          title = _S.hotkey_window.caption_panels,
          keys = {
            "ingame_panel_bankManager",
            "ingame_panel_bankStats",
            "ingame_panel_staffManage",
            "ingame_panel_townMap",
            "ingame_panel_casebook",
            "ingame_panel_research",
            "ingame_panel_status",
            "ingame_panel_charts",
            "ingame_panel_policy",
            "ingame_panel_buildRoom",
            "ingame_panel_furnishCorridor",
            "ingame_panel_editRoom",
            "ingame_panel_hireStaff",
            "ingame_panel_map_alt",
            "ingame_panel_research_alt",
            "ingame_panel_casebook_alt",
            "ingame_panel_casebook_alt02" }}}},
    {
      id = "recall",
      title = _S.hotkey_window.button_recallPosKeys,
      tooltip = _S.tooltip.hotkey_window.button_recallPosKeys,
      sections = {{
          title = _S.hotkey_window.panel_storePosKeys,
          keys = {
            "ingame_storePosition_1",
            "ingame_storePosition_2",
            "ingame_storePosition_3",
            "ingame_storePosition_4",
            "ingame_storePosition_5",
            "ingame_storePosition_6",
            "ingame_storePosition_7",
            "ingame_storePosition_8",
            "ingame_storePosition_9",
            "ingame_storePosition_0" }},
        {
          title = _S.hotkey_window.panel_recallPosKeys,
          keys = {
            "ingame_recallPosition_1",
            "ingame_recallPosition_2",
            "ingame_recallPosition_3",
            "ingame_recallPosition_4",
            "ingame_recallPosition_5",
            "ingame_recallPosition_6",
            "ingame_recallPosition_7",
            "ingame_recallPosition_8",
            "ingame_recallPosition_9",
            "ingame_recallPosition_0" }}}}}

  if self.ui.app.config.debug then
    table.insert(self.key_options, {
        id = "debug",
        title = _S.hotkey_window.panel_debugKeys,
        tooltip = _S.hotkey_window.panel_debugKeys,
        sections = {{
            title = _S.hotkey_window.panel_debugKeys,
            keys = {
              "global_connectDebugger",
              "global_showLuaConsole",
              "global_runDebugScript",
              "ingame_showCheatWindow",
              "ingame_poopLog",
              "ingame_poopStrings" }}}})
  end

  -- Title
  self:addBevelPanel(220, 10, 200, 20, col_caption):setLabel(_S.hotkey_window.caption_main)

  -- Location of original game
  local built_in = self.app.gfx:loadMenuFont()

  self.key_windows = {}
  for _, key_opt_set in ipairs(self.key_options) do
    local win = UIHotkeyAssignKeyPane(220, 0, ui, key_opt_set, self.app.hotkeys)
    self:addWindow(win)

    local btn_x = self.panel_pos_table_x[1]
    local btn_y = self.panel_pos_table_y[current_pos_y]
    local btn = self:addBevelPanel(btn_x, btn_y, 200, 30, col_bg):setLabel(key_opt_set.title)
        :makeButton(0, 0, 200, 30, nil, function(s) s:showKeyPane(key_opt_set.id) end)
        :makeToggle()
        :setTooltip(key_opt_set.tooltip)

    self.key_windows[key_opt_set.id] = { window = win, button = btn }
    current_pos_y = current_pos_y + 1
  end

  self:showKeyPane("global")

  -- "Accept" button
  self:addBevelPanel(self.panel_pos_table_x[1], 430, 200, 40, col_bg)
      :setLabel(_S.hotkey_window.button_accept)
      :makeButton(0, 0, 180, 40, nil, self.buttonAccept)
      :setTooltip(_S.tooltip.hotkey_window.button_accept)
  -- Reset to defaults button.
  self:addBevelPanel(self.panel_pos_table_x[2], 430, 200, 40, col_bg)
      :setLabel(_S.hotkey_window.button_defaults)
      :makeButton(0, 0, 180, 40, nil, self.buttonDefaults)
      :setTooltip(_S.tooltip.hotkey_window.button_defaults)
  -- "Cancel" button
  self:addBevelPanel(self.panel_pos_table_x[3], 430, 200, 40, col_bg)
      :setLabel(_S.hotkey_window.button_cancel)
      :makeButton(0, 0, 180, 40, nil, self.buttonCancel)
      :setTooltip(_S.tooltip.hotkey_window.button_cancel)

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

function UIHotkeyAssign:showKeyPane(pane)
  self.key_pane = pane
  for k, v in pairs(self.key_windows) do
    v.window:setVisible(k == pane)
    v.button:setToggleState(k == pane)
  end
end

--! Child window for setting key bindings
class "UIHotkeyAssignKeyPane" (Window)

---@type UIHotkeyAssignKeyPane
local UIHotkeyAssignKeyPane = _G["UIHotkeyAssignKeyPane"]

function UIHotkeyAssignKeyPane:UIHotkeyAssignKeyPane(x, y, ui, key_options, app_hotkeys)
  self:Window()

  self.x = x
  self.y = y
  self.ui = ui
  self.hotkey_buttons = {}

  local panel_width = 100
  local panel_height = 20

  -- Panel x position table.
  self.panel_pos_table_x = {}
  self.panel_pos_table_x[1] = 0
  self.panel_pos_table_x[2] = 210
  if #key_options.sections == 1 then
    panel_width = 205
  elseif #key_options.sections == 2 then
    panel_width = 100
  end

  -- Panel y position table.
  self.panel_pos_table_y = {}
  for i=1, 20, 1 do
    self.panel_pos_table_y[i] = (i*20)+25
  end

  local current_pos_x = 1
  for _, section in ipairs(key_options.sections) do
    local current_pos_y = 1
    local pos_x = self.panel_pos_table_x[current_pos_x]
    local pos_y = self.panel_pos_table_y[current_pos_y]
    self:addBevelPanel(pos_x, pos_y, panel_width*2, panel_height, col_caption):setLabel(section.title)
    current_pos_y = current_pos_y + 1
    for _, key in ipairs(section.keys) do
      pos_x = self.panel_pos_table_x[current_pos_x]
      pos_y = self.panel_pos_table_y[current_pos_y]
      self:addBevelPanel(pos_x, pos_y, panel_width, panel_height, col_shadow, col_bg, col_bg):setLabel(_S.hotkey_window[key])
      self.hotkey_buttons[key] = self:addBevelPanel(
          pos_x + panel_width, pos_y, panel_width, panel_height, col_hotkeybox,
          col_highlight, col_shadow)
          :makeHotkeyBox(function() self:confirm_func(key) end, nil)
          :setText(string.upper(array_join(app_hotkeys[key], "+")))
      current_pos_y = current_pos_y + 1
    end
    current_pos_x = current_pos_x + 1
  end
end

function UIHotkeyAssignKeyPane:setVisible(visibility)
  self.visible = visibility
end

function UIHotkeyAssignKeyPane:confirm_func(hotkey)
  hotkey_input(hotkey, self.hotkey_buttons, _G.TheApp)
end
