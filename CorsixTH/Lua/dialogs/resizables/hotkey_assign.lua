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

local col_textbox = {
  red = 0,
  green = 0,
  blue = 0,
}


local col_hotkeybox = {
  red = 200,
  green = 0,
  blue = 190,
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

function UIHotkeyAssign:UIHotkeyAssign(ui, mode)
  local w = 480
  local h = 320

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
  
  -- Window parts definition
  -- Title
  self:addBevelPanel(w/2-100, 10, 200, 20, col_caption):setLabel(_S.hotkey_window.caption)

  -- Location of original game
  local built_in = self.app.gfx:loadMenuFont()

  self.textbox_01 = self:addBevelPanel(32, 32, 70, 20, col_textbox, col_highlight, col_shadow)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText( "TEXTBOX" )

  --[[
  self.hotkeybox_01 = self:addBevelPanel(32, 64, 100, 20, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox():setText("HOTKEY BOX")
    ]]

  self:addBevelPanel(32, 132, 420, 20, col_shadow, col_bg, col_bg):setLabel("Click pink box, then press a key to change the jukebox hotkey. ")
  self:addBevelPanel(32, 64+32, 100, 20, col_shadow, col_bg, col_bg) : setLabel("Jukebox")
  self.hotkeybox_02 = self:addBevelPanel(32+100, 64+32, 100, 20, col_hotkeybox, col_highlight, col_shadow)
    :makeHotkeyBox(function() self:confirm_func("ingame_jukebox") end, function() self:abort_func() end):setText( string.upper(serialize(self.app.hotkeys["ingame_jukebox"])) )
  
  --print

  -- "Back" button
  self:addBevelPanel(w/2-320/2, 280, 320, 40, col_bg):setLabel(_S.hotkey_window.back)
    :makeButton(0, 0, 320, 40, nil, self.buttonAccept):setTooltip(_S.tooltip.hotkey_window.back)
  self.built_in_font = built_in
end

function UIHotkeyAssign:buttonAccept()
  self.app:saveHotkeys()
  
  self:close()
  local window = UIOptions(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIHotkeyAssign:close()
  UIResizable.close(self)
  if self.mode == "menu"  then
    self.ui:addWindow(UIMainMenu(self.ui))
  end
end

function UIHotkeyAssign:confirm_func(hotkey)
  --[[
  print("CONFIRM")
  print( self.hotkeybox_02.temp_keys_down[1] )
  print("HOTKEY == ", hotkey)
  print("HOTKEY VALUE == ", self.app.hotkeys[hotkey])
  ]]
  -- PLAN: If the hotkey being changed is currently in use while we are still in the options menu (not in-game), then that means that most keys have not been added using "addKeyHandler".
  --       So we can see if it's a currently used key handler or not before proceeding.
  --       We need to be able to save to the hotkey.txt file and reinitialize the adding of the hotkeys when the user presses the "Accept" button on the bottom of the hotkey menu.
  --         That may simply mean removing all key handlers and calling " UI:setupGlobalKeyHandlers()" and what not, as that may be the only key handlers in use in the hotkey menu.
  --         Will have to check to make sure.
  --       Will also need to write to the hotkey.txt file.
  --       And we will need to have the program reread the hotkey file and return "hotkeys_values" again when the user presses accept.
  
  -- For now lets just change the jukebox hotkey.
  
  --self.app:fixHotkeys()
  self.app.hotkeys[hotkey] = self.hotkeybox_02.temp_keys_down
  
  self.hotkeybox_02:setText(string.upper(serialize(self.app.hotkeys[hotkey])))
  --print("*********", serialize(self.app.hotkeys[hotkey]) )
  --print("*********", self.hotkeybox_02.text)
end

function UIHotkeyAssign:abort_func()
  print("abort")
end
