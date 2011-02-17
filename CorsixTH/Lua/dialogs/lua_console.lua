--[[ Copyright (c) 2010 Manuel "Roujin" Wolf

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

dofile("dialogs/resizable")

strict_declare_global "_"
_ = nil

--! Interactive Lua Console for ingame debugging.
class "UILuaConsole" (UIResizable)

local col_bg = {
  red = 46,
  green = 186,
  blue = 60,
}

local col_textbox = {
  red = 0,
  green = 0,
  blue = 0,
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

function UILuaConsole:UILuaConsole(ui)
  self:UIResizable(ui, 320, 240, col_bg)

  local app = ui.app
  self.modal_class = "console"
  self.esc_closes = true
  self.resizable = true
  self:setDefaultPosition(0.1, 0.1)
  
  -- Window parts definition
  self.default_button_sound = "selectx.wav"
  
  -- Textbox for entering code
  self.textbox = self:addBevelPanel(20, 20, 280, 140, col_textbox, col_highlight, col_shadow)
    :setLabel("", app.gfx:loadBuiltinFont()):setTooltip(_S.tooltip.lua_console.textbox)
    :makeTextbox():allowedInput("all"):setText({""})
  
  self.textbox:setActive(true) -- activated by default
  
  -- "Execute" button
  self:addBevelPanel(20, self.height - 60, 130, 40, col_bg):setLabel(_S.lua_console.execute_code)
    :makeButton(0, 0, 130, 40, nil, self.buttonExecute):setTooltip(_S.tooltip.lua_console.execute_code)
  -- "Back" button
  self:addBevelPanel(170, self.height - 60, 130, 40, col_bg):setLabel(_S.lua_console.close)
    :makeButton(0, 0, 130, 40, nil, self.buttonBack):setTooltip(_S.tooltip.lua_console.close)
end

function UILuaConsole:buttonExecute()
  print("Loading UserFunction...")
  local func, err

  _ = TheApp.ui and TheApp.ui.debug_cursor_entity

  local i = 0
  func, err = load(function()
    i = i + 1
    if type(self.textbox.text) == "table" then
      return self.textbox.text[i] and self.textbox.text[i] .. "\n"
    else
      return i < 2 and self.textbox.text
    end
  end, "=UserFunction")

  if not func then
    print("Error while loading UserFunction:")
    print(err)
  else
    print("Executing UserFunction...")
    local s, err = pcall(func)
    if not s then
      print("Error while executing UserFunction:")
      print(err)
    end
  end
end

function UILuaConsole:buttonBack()
  self:close()
end
