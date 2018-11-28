--[[ Copyright (c) 2013 Mark (Mark L) Lawlor

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
[1] = "return",
[2] = "enter",
[3] = "escape",
[4] = "backspace",
[5] = "tab",
[6] = "space",
[7] = "!",
[8] = "\"",
[9] = "#",
[10] = "%",
[11] = "$",
[12] = "&",
[13] = "\'",
[14] = "(",
[15] = ")",
[16] = "*",
[17] = "+",
[18] = ",",
[19] = "-",
[20] = ".",
[21] = "/",
[22] = "0",
[23] = "1",
[24] = "2",
[25] = "3",
[26] = "4",
[27] = "5",
[28] = "6",
[29] = "7",
[30] = "8",
[31] = "9",
[32] = ":",
[33] = ";",
[34] = "<",
[35] = "=",
[36] = ">",
[37] = "?",
[38] = "@",
[39] = "[",
[40] = "\\",
[41] = "]",
[42] = "^",
[43] = "_",
[44] = "`",
[45] = "a",
[46] = "b",
[47] = "c",
[48] = "d",
[49] = "e",
[50] = "f",
[51] = "g",
[52] = "h",
[53] = "i",
[54] = "j",
[55] = "k",
[56] = "l",
[57] = "m",
[58] = "n",
[59] = "o",
[60] = "p",
[61] = "q",
[62] = "r",
[63] = "s",
[64] = "t",
[65] = "u",
[66] = "v",
[67] = "w",
[68] = "x",
[69] = "y",
[70] = "z",
[71] = "capslock",
[72] = "f1",
[73] = "f2",
[74] = "f3",
[75] = "f4",
[76] = "f5",
[77] = "f6",
[78] = "f7",
[79] = "f8",
[80] = "f9",
[81] = "f10",
[82] = "f11",
[83] = "f12",
[84] = "printscreen",
[85] = "scrolllock",
[86] = "pause",
[87] = "insert",
[88] = "home",
[89] = "pageup",
[90] = "delete",
[91] = "end",
[92] = "pagedown",
[93] = "right",
[94] = "left",
[95] = "down",
[96] = "up",
[97] = "numlock",
[100] = "f13",
[101] = "f14",
[102] = "f15",
[103] = "f16",
[104] = "f17",
[105] = "f18",
[106] = "f19",
[107] = "f20",
[108] = "f21",
[109] = "f22",
[110] = "f23",
[111] = "f24",
[112] = "keypad 0",
[113] = "keypad 1",
[114] = "keypad 2",
[115] = "keypad 3",
[116] = "keypad 4",
[117] = "keypad 6",
[118] = "keypad 7",
[119] = "keypad 8",
[120] = "keypad 9",
[121] = "keypad .",
}

local function hotkey_input(hotkey, hotkey_buttons_table, app)
  --[[
  TODO:
    -- Keypad when numlock is off doesn't work correctly.
        Seems that keypad input isn't working correctly in ui.lua or something.
        Left for future patch.
    -- Disable the "global_exitApp" hotkey while assigning hotkeys?
        Even when "global_exitApp" isn't added at startup Alt+F4 still abandons program. Why?
    -- Modifier keys for other languages nessecary?
        -- Ex: STRG for german's "CTRL".
  ]]

  local table_01 = shallow_clone(hotkey_buttons_table[hotkey].noted_keys)

  -- If the current hotkey being changed is the alternate global confirm key...
  if hotkey == "global_confirm_alt" then
    -- If it's the same as the "global_confirm" key...
    if array_join( app.hotkeys["global_confirm"] ) == array_join(table_01) then
      return
    end
  end

  -- Check if the table even has anything or has too much.
  local table_length = 0
  for _, _ in pairs(table_01) do
    table_length = table_length + 1
  end
  if table_length == 0 or table_length > 4 then
    hotkey_buttons_table[hotkey]:abort()
    return
  end

  -- Go through the new key table and remove "left" or "right" from any modifier strings.
  for k, v in pairs(table_01) do
    -- Ctrl
    if string.find(v, "ctrl", 1, true) then
      table_01[k] = "ctrl"
    end
    -- Alt
    if string.find(v, "alt", 1, true) then
      table_01[k] = "alt"
    end
    -- Shift
    if string.find(v, "shift", 1, true) then
      table_01[k] = "shift"
    end
    -- GUI
    if string.find(v, "gui", 1, true) then
      table_01[k] = "gui"
    end
    -- MENU
    if string.find(v, "menu", 1, true) then
      table_01[k] = "menu"
    end
  end

  -- Go through the table again and organize the modifier keys to have a particluar order.
  --  Use this hierarcy:
  --    CTRL, ALT, SHIFT, GUI, MENU
  local modifier_hierarchy = { [1] = "ctrl", [2] = "alt", [3] = "shift", [4] = "gui", [5] = "menu"}
  local table_02 = {}
  -- Go through and get the modifier keys and set them to the correct order.
  for _, v1 in ipairs(modifier_hierarchy) do
    for _, v2 in ipairs(table_01) do
      if v1 == v2 then
        table_02[#table_02 + 1] = v2
      end
    end
  end

  -- Go through table_01 and only copy the non-modifier keys into table_03.
  local table_03 = {}
  local temp_index = 1
  for _, v in pairs(table_01) do
    if v ~= "ctrl" and v ~= "alt" and v ~= "shift" and v ~= "gui" and v ~= "menu" then
      table_03[temp_index] = v
    end
    temp_index = temp_index + 1
  end

  -- Go through the new table_03 and order it according to the key hairarchy.
  local table_04 = {}
  for _, v1 in ipairs(key_hierarchy) do
    for _, v2 in pairs(table_03) do
      if v1 == v2 then
        table_04[#table_04 + 1] = v2
      end
    end
  end

  -- Then go through table_02 and table_04 and put it all in table_FIN.
  local table_FIN = {}
  for _, v in ipairs(table_02) do
    table_FIN[#table_FIN + 1] = v
  end
  for _, v in ipairs(table_04) do
    table_FIN[#table_FIN + 1] = v
  end

  -- Find out if there is another hotkey with the same key assignment.
  -- Make sure it's not the same key we are currently mapping.
  local hotkey_used = false
  local hotkey_used_key = ""
  local keys_01 = serialize(table_FIN)
  local keys_02 = ""
  -- Go through the app.hotkeys table...
  for k, _ in pairs(app.hotkeys) do
    if type(app.hotkeys[k]) == "table" then
      keys_02 = serialize(app.hotkeys[k])
    elseif type(app.hotkeys[k]) == "string" then
      keys_02 = serialize({app.hotkeys[k]})
    end

    -- If the key(s) that were pressed (table_FIN) match the current key in the "app.hotkey" table...
    if keys_01 == keys_02 then
      hotkey_used = true
      hotkey_used_key = k
    end
  end

  local clone_key = false
  if hotkey_used then
    -- If it is NOT the same key we are currently working with...
    if hotkey ~= hotkey_used_key then
      clone_key = true
    end
  end

  -- Note the table length of table_FIN.
  table_length = 0
  for _ in pairs(table_FIN) do
    table_length = table_length + 1
  end

  -- Apply according to how many keys are pressed.
  -- If there are multiple keys pressed...
  if table_length > 1 then
    if clone_key then
      app.hotkeys[hotkey_used_key] = shallow_clone(app.hotkeys[hotkey])
      if hotkey_buttons_table[hotkey_used_key] then
        hotkey_buttons_table[hotkey_used_key]:setText( string.upper(array_join(app.hotkeys[hotkey_used_key], "+")) )
      end
    end

    app.hotkeys[hotkey] = table_FIN
    -- If the key is "global_cancel_alt"...
    if hotkey == "global_cancel_alt" then
      app.hotkeys["global_stop_movie_alt"] = table_FIN
      app.hotkeys["global_window_close_alt"] = table_FIN
    end
  -- If there is only one key pressed...
  else
    if clone_key then
      app.hotkeys[hotkey_used_key] = shallow_clone(app.hotkeys[hotkey])
      if hotkey_buttons_table[hotkey_used_key] then
        hotkey_buttons_table[hotkey_used_key]:setText( string.upper(array_join(app.hotkeys[hotkey_used_key], "+")) )
      end
    end

    app.hotkeys[hotkey] = table_FIN[1]
    -- If the key is "global_cancel_alt"...
    if hotkey == "global_cancel_alt" then
      app.hotkeys["global_stop_movie_alt"] = table_FIN[1]
      app.hotkeys["global_window_close_alt"] = table_FIN[1]
    end
  end

  -- Set the current hotkeybox text.
  hotkey_buttons_table[hotkey]:setText( string.upper( array_join(app.hotkeys[hotkey], "+") ) )
end

function UIHotkeyAssign:UIHotkeyAssign(ui, mode)
  self:UIResizable(ui, 640, 480, col_bg)

  local panel_width = 100
  local panel_height = 20

  local current_pos_x = 1
  local current_pos_y = 1
  local max_x_pos_step = 3
  local max_y_pos_step = 19

  -- Panel x position table.
  self.panel_pos_table_x = {}
  self.panel_pos_table_x[1] = 10
  self.panel_pos_table_x[2] = 220
  self.panel_pos_table_x[3] = 430
  -- Panel y position table.
  self.panel_pos_table_y = {}
  for i=1, 19, 1 do
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
  -- global_captureMouse
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.global_captureMouse)
  self.hotkey_buttons["global_captureMouse"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("global_captureMouse") end, nil):setText( string.upper(array_join(ui.app.hotkeys["global_captureMouse"], "+")) )
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
  get_next_pos_y()
  get_next_pos_y()
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

  -- Game Speed Keys
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width*2, panel_height, col_caption):setLabel(_S.hotkey_window.panel_gameSpeedKeys)
  get_next_pos_y()
  -- ingame_pause
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_pause)
  self.hotkey_buttons["ingame_pause"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_pause") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_pause"], "+")) )
  get_next_pos_y()
  -- ingame_gamespeed_slowest
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_gamespeed_slowest)
  self.hotkey_buttons["ingame_gamespeed_slowest"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_gamespeed_slowest") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_gamespeed_slowest"], "+")) )
  get_next_pos_y()
  -- ingame_gamespeed_slower
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_gamespeed_slower)
  self.hotkey_buttons["ingame_gamespeed_slower"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_gamespeed_slower") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_gamespeed_slower"], "+")) )
  get_next_pos_y()
  -- ingame_gamespeed_normal
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_gamespeed_normal)
  self.hotkey_buttons["ingame_gamespeed_normal"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_gamespeed_normal") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_gamespeed_normal"], "+")) )
  get_next_pos_y()
  -- ingame_gamespeed_max
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_gamespeed_max)
  self.hotkey_buttons["ingame_gamespeed_max"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_gamespeed_max") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_gamespeed_max"], "+")) )
  get_next_pos_y()
  -- ingame_gamespeed_thensome
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_gamespeed_thensome)
  self.hotkey_buttons["ingame_gamespeed_thensome"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_gamespeed_thensome") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_gamespeed_thensome"], "+")) )
  get_next_pos_y()
  -- ingame_gamespeed_speedup
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_gamespeed_speedup)
  self.hotkey_buttons["ingame_gamespeed_speedup"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_gamespeed_speedup") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_gamespeed_speedup"], "+")) )
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
  -- Store and recall position assignment window.
  self:addBevelPanel(self.panel_pos_table_x[3], 385, 200, 40, col_bg):setLabel(_S.hotkey_window.button_recallPosKeys)
    :makeButton(0, 0, 200, 40, nil, self.storeRecallPosButton):setTooltip(_S.tooltip.hotkey_window.button_recallPosKeys)

  -- "Accept" button
  self:addBevelPanel(10, 430, 180, 40, col_bg):setLabel(_S.hotkey_window.button_accept)
    :makeButton(0, 0, 180, 40, nil, self.buttonAccept):setTooltip(_S.tooltip.hotkey_window.button_accept)
  -- Reset to defaults button.
  self:addBevelPanel(230, 430, 180, 40, col_bg):setLabel(_S.hotkey_window.button_defaults)
    :makeButton(0, 0, 180, 40, nil, self.buttonDefaults):setTooltip(_S.tooltip.hotkey_window.button_defaults)
  -- "Cancel" button
  self:addBevelPanel(450, 430, 180, 40, col_bg):setLabel(_S.hotkey_window.button_cancel)
    :makeButton(0, 0, 180, 40, nil, self.buttonCancel):setTooltip(_S.tooltip.hotkey_window.button_cancel)


  self.built_in_font = built_in
end

function UIHotkeyAssign:buttonAccept()
  self.app:saveHotkeys()

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
  self.app.hotkeys = hotkey_backup
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
  self:addBevelPanel(10, 10, 430, panel_height, col_caption):setLabel(_S.hotkey_window.caption_panels)

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
