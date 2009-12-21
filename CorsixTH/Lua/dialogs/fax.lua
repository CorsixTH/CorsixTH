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

dofile "dialogs/fullscreen"

class "UIFax" (UIFullscreen)

function UIFax:UIFax(ui, message)
  self:UIFullscreen(ui)
  local gfx = ui.app.gfx
  self.background = gfx:loadRaw("Fax01V", 640, 480)
  local palette = gfx:loadPalette("QData", "Fax01V.pal")
  palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
  self.panel_sprites = gfx:loadSpriteTable("QData", "Fax02V", true, palette)
  self.fax_font = gfx:loadFont("QData", "Font51V", false, palette)
  ui:playSound "fax_in.wav"
  if message then
    self.message = message
  else
    self.message = {
      {offset = 0, text = "Welcome to CorsixTH, an open source clone of the classic game Theme Hospital by Bullfrog!"},
      {offset = 36, text = "This is playable beta 1 of CorsixTH. Many rooms, diseases and features have been implemented, but there are still many things missing."},
      {offset = 86, text = "If you like this project, you can help us with development, e.g. by reporting bugs or starting to code something yourself."},
      {offset = 134, text = "But now, have fun with the game! For those who are unfamiliar with Theme Hospital: Start by building a reception desk (from the objects menu) and a GP's office (diagnosis room). Various treatment rooms will also be needed."},
      {offset = 210, text = "-- The CorsixTH team, th.corsix.org"},
      {offset = 232, text = "PS: can you find the easter eggs we included?"},
      {offset = 256, text = "(press escape to close this window)"}
    }
  end
  
  self.code = ""
  
  -- Some faxes can be dismissed by pressing the close button, while others
  -- need to be dismissed by making a choice. For now, just display the close
  -- button.
  if true then
    -- Close button
    self:addPanel(0, 598, 440):makeButton(0, 0, 26, 26, 16, self.close)
  else
    -- Blanker over close button
    self:addPanel(20, 596, 435)
  end
  
  self:addPanel(0, 471, 349):makeButton(0, 0, 87, 20, 14, self.cancel) -- Cancel code button
  self:addPanel(0, 474, 372):makeButton(0, 0, 91, 27, 15, self.validate) -- Validate code button
  
  self:addPanel(0, 168, 348):makeButton(0, 0, 43, 10, 1, self.correct) -- Correction button
  
  local function button(char) return function() self:appendNumber(char) end end
  
  self:addPanel(0, 220, 348):makeButton(0, 0, 43, 10,  2, button"1"):setSound"Fax_1.wav"
  self:addPanel(0, 272, 348):makeButton(0, 0, 44, 10,  3, button"2"):setSound"Fax_2.wav"
  self:addPanel(0, 327, 348):makeButton(0, 0, 43, 10,  4, button"3"):setSound"Fax_3.wav"
  
  self:addPanel(0, 219, 358):makeButton(0, 0, 44, 10,  5, button"4"):setSound"Fax_4.wav"
  self:addPanel(0, 272, 358):makeButton(0, 0, 43, 10,  6, button"5"):setSound"Fax_5.wav"
  self:addPanel(0, 326, 358):makeButton(0, 0, 44, 10,  7, button"6"):setSound"Fax_6.wav"
  
  self:addPanel(0, 218, 370):makeButton(0, 0, 44, 11,  8, button"7"):setSound"Fax_7.wav"
  self:addPanel(0, 271, 370):makeButton(0, 0, 44, 11,  9, button"8"):setSound"Fax_8.wav"
  self:addPanel(0, 326, 370):makeButton(0, 0, 44, 11, 10, button"9"):setSound"Fax_9.wav"
  
  self:addPanel(0, 217, 382):makeButton(0, 0, 45, 12, 11, button"*")
  self:addPanel(0, 271, 382):makeButton(0, 0, 44, 11, 12, button"0"):setSound"Fax_0.wav"
  self:addPanel(0, 326, 382):makeButton(0, 0, 44, 11, 13, button"#")
end

function UIFax:draw(canvas)
  self.background:draw(canvas, self.x, self.y)
  
  if self.message then
    for i = 1, #self.message do
      self.fax_font:drawWrapped(canvas, self.message[i].text, self.x + 170, self.y + 40 + self.message[i].offset, 380)
    end
  end
  return UIFullscreen.draw(self, canvas)
end

function UIFax:cancel()
  self.code = ""
end

function UIFax:correct()
  if self.code ~= "" then
    self.code = string.sub(self.code, 1, -2) --Remove last character
  end
end

function UIFax:validate()
  if self.code == "" then
    return
  end
  local code = self.code
  self.code = ""
  -- Original game cheat code
  if code == "24328" then
    print("Congratulations, you have unlocked cheats!")
    return
  end
  -- Bloaty head patient cheat
  -- Anyone with a 'large' head should be able to spot the required code
  local code_n = (tonumber(code) or 0) / 10^5
  local x = math.abs((code_n ^ 5.00001 - code_n ^ 5) * 10^5 - code_n ^ 5)
  if 0.0006422 < x and x < 0.0006423 then
    local diseases = self.ui.app.world.available_diseases
    diseases[1] = diseases.bloaty_head
    for i = #diseases, 2, -1 do
      diseases[diseases[i].id] = nil
      diseases[i] = nil
    end
    diseases.bloaty_head = diseases[1]
    return
  end
  -- TODO: Other cheats (preferably with slight obfuscation, as above)
  print("Code typed on fax:", code)
end

function UIFax:appendNumber(number)
  self.code = self.code .. number
end
