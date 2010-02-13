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

function UICasebook:UICasebook(ui, disease_selection)
  self:UIFullscreen(ui)
  local gfx = ui.app.gfx
  self.background = gfx:loadRaw("DrugN01V", 640, 480)
  local palette = gfx:loadPalette("QData", "DrugN01V.pal")
  palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
  self.panel_sprites = gfx:loadSpriteTable("QData", "DrugN02V", true, palette)
  self.title_font = gfx:loadFont("QData", "Font25V", false, palette)
  self.selected_title_font = gfx:loadFont("QData", "Font26V", false, palette)
  self.drug_font = gfx:loadFont("QData", "Font24V", false, palette)
  
  self.default_button_sound = "selectx.wav"
  
  self.hospital = ui.hospital
  self.casebook = self.hospital.disease_casebook
  -- A sorted list of known diseases and pseudo diseases.
  -- Used to be able to list the diseases in, believe it or not,
  -- alphabetical order.
  -- TODO: update if disease is discovered while window is open
  self.names_sorted = {}
  for n, value in pairs(self.casebook) do
    if value.discovered then
      self.names_sorted[#self.names_sorted + 1] = n
    end
  end
  table.sort(self.names_sorted, function(d1, d2)
    local c1, c2 = self.casebook[d1], self.casebook[d2]
    if c1.pseudo ~= c2.pseudo then
      return c1.pseudo
    end
    return c1.disease.name:upper() < c2.disease.name:upper()
  end)
  
  if disease_selection then
    self:selectDisease(disease_selection)
  else
    self.selected_index = #self.names_sorted
    self.selected_disease = self.names_sorted[self.selected_index]
  end
  
  -- Buttons
  self:addPanel(0, 607, 449):makeButton(0, 0, 26, 26, 3, self.close)
  self:addPanel(0, 439, 29):makeButton(0, 0, 70, 46, 1, self.scrollUp):setSound"pagetur2.wav" -- Scroll up button
  self:addPanel(0, 437, 394):makeButton(0, 0, 77, 53, 2, self.scrollDown):setSound"pagetur2.wav" -- Scroll down button
  self:addPanel(0, 354, 133):makeButton(0, 0, 22, 22, 5, self.increasePay) -- payment up button
  self:addPanel(0, 237, 133):makeButton(0, 0, 22, 22, 4, self.decreasePay) -- payment down button
  
  -- Hotkeys
  self.ui:addKeyHandler(273, self, self.scrollUp)		-- Up
  self.ui:addKeyHandler(274, self, self.scrollDown)		-- Down
  self.ui:addKeyHandler(275, self, self.increasePay)	-- Left
  self.ui:addKeyHandler(276, self, self.decreasePay)	-- Right
  self.ui:enableKeyboardRepeat()						-- To quickly change values
  
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

function UICasebook:close()
  self.ui:removeKeyHandler(273, self)	-- Up
  self.ui:removeKeyHandler(274, self)	-- Down
  self.ui:removeKeyHandler(275, self)	-- Left
  self.ui:removeKeyHandler(276, self)	-- Right
  self.ui:disableKeyboardRepeat()
  Window.close(self)
end

function UICasebook:selectDisease(disease)
  for i = 1, #self.names_sorted do
    if disease == self.names_sorted[i] then
      self.selected_index = i
      self.selected_disease = self.names_sorted[self.selected_index]
      break
    end
  end
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
  titles:draw(canvas, book[disease].reputation, x + 248, y + 92, 114, 0) -- Reputation
  titles:draw(canvas, ("%.0f%%"):format(book[disease].price * 100), x + 262, y + 137, 90, 0) -- Treatment Charge
  titles:draw(canvas, "$" .. book[disease].money_earned, x + 248, y + 181, 114, 0) -- Money Earned
  titles:draw(canvas, book[disease].recoveries, x + 248, y + 225, 114, 0) -- Recoveries
  titles:draw(canvas, book[disease].fatalities, x + 248, y + 269, 114, 0) -- Fatalities
  titles:draw(canvas, book[disease].turned_away, x + 248, y + 313, 114, 0) -- Turned away
  
  -- Icons in the lower part of the screen
  if book[disease].drug then
    self.drug.visible = true
    self.drug_font:draw(canvas, book[disease].cure_effectiveness, x + 310, y + 364, 19, 0)
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
    titles:draw(canvas, book[self.names_sorted[selected - index]].disease.name:upper(), x + 409, y + 203 - index*18)
    index = index + 1
  end
  self.selected_title_font:draw(canvas, book[disease].disease.name:upper(), x + 409, y + 227)
  index = 1
  while index + selected <= #self.names_sorted and index <= 7 do
    titles:draw(canvas, book[self.names_sorted[index + selected]].disease.name:upper(), x + 409, y + 251 + index*18)
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
  local amount = 0.01
  if self.buttons_down.ctrl then
    amount = amount * 25
  elseif self.buttons_down.shift then
    amount = amount * 5
  end
  price = price + amount
  if price > 2 then
    price = 2
  end
  self.casebook[self.selected_disease].price = price
end

function UICasebook:decreasePay()
  local price = self.casebook[self.selected_disease].price
  local amount = 0.01
  if self.buttons_down.ctrl then
    amount = amount * 25
  elseif self.buttons_down.shift then
    amount = amount * 5
  end
  price = price - amount
  if price < 0.5 then
    price = 0.5
  end
  self.casebook[self.selected_disease].price = price
end
