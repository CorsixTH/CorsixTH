--[[
  NOTES:
  Get rid of window width and height local variables after done.
  
  Simply add one hotkey assignment button for now. After that you can go one to make the rest of them.
  
  First, we need to find out how to get key inputs.
    EX: What function can find out what key I'm pressing at the moment?
]]

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

local hotkeys_backedUp = false
local hotkey_backup = {}

local function hotkey_input(hotkey, hotkey_buttons, app)
  --[[
  TODO:
    - Make "stop movie" and "close window" be assigned to whatever "global_cancel" is.
    -- Make it to where if "=" is called in addKeyHandler(), "+" will also be mapped to it.
          Do the same with "enter" and "keypad enter", if needed.
    -- Need reset to default button
  ]]
  
  -- Join temp_keys_down and noted_keys.
  local table_01 = {}
  local n = 0
  for _, v in pairs(hotkey_buttons[hotkey].noted_keys) do
    n = n+1
    table_01[n] = v
  end
  for _, v in pairs(hotkey_buttons[hotkey].temp_keys_down) do
    n = n+1
    table_01[n] = v
  end

  -- Remove "left" or "right" from any modifier strings.
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
  end
  
  -- Note the table length of table_01
  local table_length = 0
  for _ in pairs(table_01) do
    table_length = table_length + 1
  end
  
  -- Apply or abort according to how many keys are pressed.
  -- If there are multiple keys pressed...
  if table_length > 1 and table_length <= 4 then
    app.hotkeys[hotkey] = table_01
  -- If there is only one key pressed...
  elseif table_length == 1 then
    app.hotkeys[hotkey] = table_01[1]
  -- If too few or too many keys are pressed...
  elseif table_length == 0 or table_length > 4 then
    hotkey_buttons[hotkey]:abort_callback()
  end
  
  -- Set the hotkeybox text.
  hotkey_buttons[hotkey]:setText( string.upper( array_join(app.hotkeys[hotkey], "+") ) )
end

function UIHotkeyAssign:UIHotkeyAssign(ui, mode)
  local w = 640
  local h = 480
  
  local panel_width = 100
  local panel_height = 20
  
  local current_pos_x = 1
  local current_pos_y = 1
  local max_x_pos_step = 3
  local max_y_pos_step = 19
  
  --
  self.hotkey_buttons = {}
  
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

  -- Gets the next x position of the hotkey panels. Easier to use than manually putting it all in.
  local function get_next_pos_x()
    current_pos_x = current_pos_x + 1
    
    if(current_pos_x > max_x_pos_step) then
      current_pos_x=max_x_pos_step
    end
    
    return current_pos_x
  end
  -- Gets the next x position of the hotkey panels.
  local function get_next_pos_y()
    current_pos_y = current_pos_y + 1
    
    if(current_pos_y > max_y_pos_step) then
      current_pos_y = 1
      get_next_pos_x()
    end
    
    return current_pos_y
  end

  self:UIResizable(ui, w, h, col_bg)

  self.ui = ui
  self.mode = mode
  self.modal_class = mode == "menu" and "main menu" or "options" or "folders"
  self.on_top = mode == "menu"
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.25)
  self.default_button_sound = "selectx.wav"
  self.app = ui.app
  
  --
  if not hotkeys_backedUp then
    hotkey_backup = shallow_clone(self.app.hotkeys)
    hotkeys_backedUp = true
  end
  
  -- Title
  self:addBevelPanel(w/2-100, 10, 200, 20, col_caption):setLabel(_S.hotkey_window.caption_main)

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
  
  -- global_confirm_alt02
  self:addBevelPanel(self.panel_pos_table_x[current_pos_x], self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.global_confirm_alt02)
  self.hotkey_buttons["global_confirm_alt02"] = self:addBevelPanel(self.panel_pos_table_x[current_pos_x]+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("global_confirm_alt02") end, nil):setText( string.upper(array_join(ui.app.hotkeys["global_confirm_alt02"], "+")) )
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
  get_next_pos_y()
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
  self:addBevelPanel(self.panel_pos_table_x[1], h-95, 200, 40, col_bg):setLabel(_S.hotkey_window.button_toggleKeys)
    :makeButton(0, 0, 320, 40, nil, self.toggleButton):setTooltip(_S.tooltip.hotkey_window.button_toggleKeys)
  -- Store and recall position assignment window.
  self:addBevelPanel(self.panel_pos_table_x[3], h-95, 200, 40, col_bg):setLabel(_S.hotkey_window.button_recallPosKeys)
    :makeButton(0, 0, 320, 40, nil, self.storeRecallPosButton):setTooltip(_S.tooltip.hotkey_window.button_recallPosKeys)

  -- "Accept" button
  self:addBevelPanel(20, h-50, 280, 40, col_bg):setLabel(_S.hotkey_window.button_accept)
    :makeButton(0, 0, 320, 40, nil, self.buttonAccept):setTooltip(_S.tooltip.hotkey_window.button_accept)
  -- "Cancel" button
  self:addBevelPanel(340, h-50, 280, 40, col_bg):setLabel(_S.hotkey_window.button_cancel)
    :makeButton(0, 0, 320, 40, nil, self.buttonCancel):setTooltip(_S.tooltip.hotkey_window.button_cancel)
  
  self.built_in_font = built_in
end

function UIHotkeyAssign:buttonAccept()
  self.app:saveHotkeys()
  
  self:close()
  local window = UIOptions(self.ui, "menu")
  self.ui:addWindow(window)
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
  local window = UIHotkeyAssign_Toggle(self.ui, "menu")
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

--========================================================================Toggle Assign Menu

--! Customise window used in the main menu and ingame.
class "UIHotkeyAssign_Toggle" (UIResizable)

---@type UIHotkeyAssign
local UIHotkeyAssign_Toggle = _G["UIHotkeyAssign_Toggle"]

function UIHotkeyAssign_Toggle:UIHotkeyAssign_Toggle(ui, mode)
  local w = 240
  local h = 200
  
  local panel_width = 110
  local panel_height = 20
  
  self:UIResizable(ui, w, h, col_bg)
  
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
  for i=1, 5, 1 do
    self.panel_pos_table_y[i] = (i*20)+20
  end
  --
  local panel_x_pos = 10
  local current_pos_y = 1
  
  -- Title
  self:addBevelPanel(10, 10, w-10, 20, col_caption):setLabel(_S.hotkey_window.caption_toggle)
  
  -- "Back" button
  self:addBevelPanel(10, h-50, w-20, 40, col_bg):setLabel(_S.hotkey_window.button_back)
    :makeButton(0, 0, 320, 40, nil, self.buttonBack):setTooltip(_S.tooltip.hotkey_window.button_back_02)
  
  --============
  -- ingame_toggleAnnouncements
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_toggleAnnouncements)
  self.hotkey_buttons["ingame_toggleAnnouncements"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_toggleAnnouncements") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_toggleAnnouncements"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_toggleSounds
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_toggleSounds)
  self.hotkey_buttons["ingame_toggleSounds"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_toggleSounds") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_toggleSounds"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_toggleMusic
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_toggleMusic)
  self.hotkey_buttons["ingame_toggleMusic"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_toggleMusic") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_toggleMusic"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_toggleAdvisor
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_toggleAdvisor)
  self.hotkey_buttons["ingame_toggleAdvisor"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_toggleAdvisor") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_toggleAdvisor"], "+")) )
  current_pos_y = current_pos_y + 1
  -- ingame_toggleInfo
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_shadow, col_bg, col_bg) : setLabel(_S.hotkey_window.ingame_toggleInfo)
  self.hotkey_buttons["ingame_toggleInfo"] = self:addBevelPanel(panel_x_pos+panel_width, self.panel_pos_table_y[current_pos_y], panel_width, panel_height, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_toggleInfo") end, nil):setText( string.upper(array_join(ui.app.hotkeys["ingame_toggleInfo"], "+")) )
end

function UIHotkeyAssign_Toggle:close()
  UIResizable.close(self)
  if self.mode == "menu"  then
    self.ui:addWindow(UIHotkeyAssign(self.ui, "menu"))
  end
end

function UIHotkeyAssign_Toggle:buttonBack()
  self:close()
  local window = UIHotkeyAssign(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIHotkeyAssign_Toggle:confirm_func(hotkey)
  hotkey_input(hotkey, self.hotkey_buttons, self.app)
end

--==============================================================

--! Customise window used in the main menu and ingame.
class "UIHotkeyAssign_storeRecallPos" (UIResizable)

---@type UIHotkeyAssign
local UIHotkeyAssign_storeRecallPos = _G["UIHotkeyAssign_storeRecallPos"]

function UIHotkeyAssign_storeRecallPos:UIHotkeyAssign_storeRecallPos(ui, mode)
  local w = 440
  local h = 320
  
  local panel_width = 100
  local panel_height = 20
  
  self:UIResizable(ui, w, h, col_bg)
  
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
  
  local panel_x_pos = 10
  local current_pos_y = 1
  
  -- Title
  self:addBevelPanel(10, 10, w-10, panel_height, col_caption):setLabel(_S.hotkey_window.caption_toggle)
  
  -- Store Position Panel
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], w/2-20, panel_height, col_caption):setLabel(_S.hotkey_window.panel_storePosKey)
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
  
  --
  current_pos_y = 1
  panel_x_pos = panel_x_pos + 220
  -- Recall Position Panel
  self:addBevelPanel(panel_x_pos, self.panel_pos_table_y[current_pos_y], w/2-20, panel_height, col_caption):setLabel(_S.hotkey_window.panel_recallPosKeys)
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
  
  -- "Back" button
  self:addBevelPanel(10, h-50, w-20, 40, col_bg):setLabel(_S.hotkey_window.button_back)
    :makeButton(0, 0, 320, 40, nil, self.buttonBack):setTooltip(_S.tooltip.hotkey_window.button_back_02)
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