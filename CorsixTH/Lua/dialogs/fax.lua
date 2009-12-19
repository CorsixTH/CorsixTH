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
  self.panel_sprites = gfx:loadSpriteTable("QData", "Fax02V", true, gfx:loadPalette("QData", "Fax01V.pal"))
  self.fax_font = gfx:loadFont("QData", "Font50V")
  
  if message then
    self.message = message
  else
    self.message = {
      {offset = 0, text = "Welcome to CorsixTH, an open source clone of the classic game Theme Hospital by Bullfrog!"},
      {offset = 30, text = "This is the playable beta 1 of CorsixTH. A number of rooms, diseases and features have already been implemented, but there is also a lot still missing."},
      {offset = 80, text = "If you like this project, you can help us with development, e.g. by reporting bugs or starting to code something yourself."},
      {offset = 120, text = "But now, have fun with the game! For those who are unfamiliar with Theme Hospital: Start by building a reception desk (from the objects menu) and a GP's office (diagnosis room). Then, various treatment rooms will be needed to cure the different diseases."},
      {offset = 200, text = "PS: can you find the easter eggs we included in this release?"},
      {offset = 250, text = "(press escape to close this window)"}
    }
  end
  
  self.code = ""
  
  if false then
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
  
  self:addPanel(0, 220, 348):makeButton(0, 0, 43, 10,  2, button "1") -- Button 1
  self:addPanel(0, 272, 348):makeButton(0, 0, 44, 10,  3, button "2") -- Button 2
  self:addPanel(0, 327, 348):makeButton(0, 0, 43, 10,  4, button "3") -- Button 3
  
  self:addPanel(0, 219, 358):makeButton(0, 0, 44, 10,  5, button "4") -- Button 4
  self:addPanel(0, 272, 358):makeButton(0, 0, 43, 10,  6, button "5") -- Button 5
  self:addPanel(0, 326, 358):makeButton(0, 0, 44, 10,  7, button "6") -- Button 6
  
  self:addPanel(0, 218, 370):makeButton(0, 0, 44, 11,  8, button "7") -- Button 7
  self:addPanel(0, 271, 370):makeButton(0, 0, 44, 11,  9, button "8") -- Button 8
  self:addPanel(0, 326, 370):makeButton(0, 0, 44, 11, 10, button "9") -- Button 9
  
  self:addPanel(0, 217, 382):makeButton(0, 0, 45, 12, 11, button "*") -- Button *
  self:addPanel(0, 271, 382):makeButton(0, 0, 44, 11, 12, button "0") -- Button 0
  self:addPanel(0, 326, 382):makeButton(0, 0, 44, 11, 13, button "#") -- Button #
end

function UIFax:draw(canvas)
  self.background:draw(canvas, self.x, self.y)
  
  if self.message then
    for i = 1, #self.message do
      self.fax_font:drawWrapped(canvas, self.message[i].text, self.x + 180, self.y + 40 + self.message[i].offset, 380)
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
