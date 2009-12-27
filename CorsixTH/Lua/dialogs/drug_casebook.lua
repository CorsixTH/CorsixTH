--[[ Copyright (c) 2009 Edvin "Lego3" Linge

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

class "UICasebook" (UIFullscreen)

function UICasebook:UICasebook(ui, message)
  self:UIFullscreen(ui)
  local gfx = ui.app.gfx
  self.background = gfx:loadRaw("DrugN01V", 640, 480)
  local palette = gfx:loadPalette("QData", "DrugN01V.pal")
  palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
  self.panel_sprites = gfx:loadSpriteTable("QData", "DrugN02V", true, palette)
  self.title_font = gfx:loadFont("QData", "Font25V", false, palette)
  self.selected_title_font = gfx:loadFont("QData", "Font26V", false, palette)
  self.drug_font = gfx:loadFont("QData", "Font24V", false, palette)
  
  self.hospital = ui.app.world:getLocalPlayerHospital()
  self.casebook = self.hospital.disease_casebook
  -- A sorted list of known diseases and pseudo diseases.
  -- Used to be able to list the diseases in, believe it or not,
  -- alphabetical order.
  self.names_sorted = {}
  for n,value in pairs(self.casebook) do 
    if value.discovered then
      table.insert(self.names_sorted, n) 
      self.selected_disease = n
    end
  end
  table.sort(self.names_sorted)

  for i,n in ipairs(self.names_sorted) do 
    if n == self.selected_disease then
      self.selected_index = i
    end
  end
  
  -- Buttons
  self:addPanel(0, 607, 449):makeButton(0, 0, 26, 26, 3, self.close)
  self:addPanel(0, 439, 29):makeButton(0, 0, 70, 46, 1, self.scrollUp) -- Scroll up button
  self:addPanel(0, 437, 394):makeButton(0, 0, 77, 53, 2, self.scrollDown) -- Scroll down button
  self:addPanel(0, 354, 133):makeButton(0, 0, 22, 22, 5, self.increasePay) -- payment up button
  self:addPanel(0, 237, 133):makeButton(0, 0, 22, 22, 4, self.decreasePay) -- payment down button
  
  -- Icons representing cure effectiveness and other important information.
  self.machinery = self:addPanel(6, 306, 352)
  self.machinery.visible = false
  self.drug = self:addPanel(7, 306, 352)
  self.drug.visible = false
  self.surgery = self:addPanel(8, 306, 352)
  
  self.curable = self:addPanel(11, 335, 352)
  -- TODO: Add situations when a disease is known but cannot be cured
  self.not_curable = self:addPanel(12, 335, 352)
  self.not_curable.visible = false
end

function UICasebook:draw(canvas)
  self.background:draw(canvas, self.x, self.y)
  UIFullscreen.draw(self, canvas)
  
  local x, y = self.x, self.y
  local titles = self.title_font
  local book = self.casebook
  local disease = self.selected_disease
  local selected = self.selected_index
  
  -- All titles
  titles:draw(canvas, _S(29, 1), x + 278, y + 68) -- Reputation
  titles:draw(canvas, _S(29, 2), x + 260, y + 113) -- Treatment Charge
  titles:draw(canvas, _S(29, 3), x + 265, y + 157) -- Money Earned
  titles:draw(canvas, _S(29, 4), x + 276, y + 201) -- Recoveries
  titles:draw(canvas, _S(29, 5), x + 279, y + 245) -- Fatalities
  titles:draw(canvas, _S(29, 6), x + 270, y + 289) -- Turned away
  titles:draw(canvas, _S(29, 8), x + 255, y + 354) -- Cure
  
  -- Specific disease information
  if book[disease].concentrate_research then  -- Concentrate research
    self.selected_title_font:draw(canvas, _S(29, 7), x + 245, y + 398)
  else
    titles:draw(canvas, _S(29, 7), x + 245, y + 398)
  end
  local width = self.title_font.sizeOf(self.title_font, book[disease].reputation)
  titles:draw(canvas, book[disease].reputation, x + 305 - width/2, y + 92) -- Reputation
  width = self.title_font.sizeOf(self.title_font, book[disease].price)
  titles:draw(canvas, book[disease].price * 100 .. "%", x + 295 - width/2, y + 137) -- Treatment Charge
  width = self.title_font.sizeOf(self.title_font, book[disease].money_earned)
  titles:draw(canvas, "$" .. book[disease].money_earned, x + 300 - width/2, y + 181) -- Money Earned
  width = self.title_font.sizeOf(self.title_font, book[disease].recoveries)
  titles:draw(canvas, book[disease].recoveries, x + 305 - width/2, y + 225) -- Recoveries
  width = self.title_font.sizeOf(self.title_font, book[disease].fatalities)
  titles:draw(canvas, book[disease].fatalities, x + 305 - width/2, y + 269) -- Fatalities
  width = self.title_font.sizeOf(self.title_font, book[disease].turned_away)
  titles:draw(canvas, book[disease].turned_away, x + 305 - width/2, y + 313) -- Turned away
  
  -- Icons in the lower part of the screen
  if book[disease].drug then
    self.drug.visible = true
    width = self.drug_font.sizeOf(self.drug_font, book[disease].cure_effectiveness)
    self.drug_font:draw(canvas, book[disease].cure_effectiveness, x + 320 - width/2, y + 364)
  else
    self.drug.visible = false
  end
  if book[disease].machine or book[disease].psychiatrist then 
    -- TODO: Differentiate psychiatrists and machines with tooltip texts
    self.machinery.visible = true
  else
    self.machinery.visible = false
  end
  if book[disease].surgeon then
    self.surgery.visible = true
  else
    self.surgery.visible = false
  end
  if book[disease].pseudo then
    self.curable.visible = false
  else
    self.curable.visible = true
  end
  
  -- Right-hand side list of diseases (and pseudo diseases)
  local index = 1
  while selected - index > 0 and index <= 7 do
    titles:draw(canvas, string.upper(self.names_sorted[selected - index]), x + 409, y + 203 - index*18)
    index = index + 1
  end
  self.selected_title_font:draw(canvas, string.upper(disease), x + 409, y + 227)
  index = 1
  while index + selected <= #self.names_sorted and index <= 7 do
    titles:draw(canvas, string.upper(self.names_sorted[index + selected]), x + 409, y + 251 + index*18)
    index = index + 1
  end
end

function UICasebook:scrollUp()
  if self.selected_index > 1 then
    self.selected_index = self.selected_index - 1
    self.selected_disease = self.names_sorted[self.selected_index]
  end
end

function UICasebook:scrollDown()
  if self.selected_index < #self.names_sorted then
    self.selected_index = self.selected_index + 1
    self.selected_disease = self.names_sorted[self.selected_index]
  end
end

function UICasebook:increasePay()
  local price = self.casebook[self.selected_disease].price
  if price < 2 then
    self.casebook[self.selected_disease].price = price + 0.01
  end
end

function UICasebook:decreasePay()
  local price = self.casebook[self.selected_disease].price
  if price > 0.5 then
    self.casebook[self.selected_disease].price = price - 0.01
  end
end