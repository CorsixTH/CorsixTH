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

--! Drug Casebook fullscreen window (view disease statistics and set prices).
class "UICasebook" (UIFullscreen)

function UICasebook:UICasebook(ui, disease_selection)
  self:UIFullscreen(ui)
  local gfx = ui.app.gfx
  if not pcall(function()
    self.background = gfx:loadRaw("DrugN01V", 640, 480)
    local palette = gfx:loadPalette("QData", "DrugN01V.pal")
    palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
    self.panel_sprites = gfx:loadSpriteTable("QData", "DrugN02V", true, palette)
    self.title_font = gfx:loadFont("QData", "Font25V", false, palette)
    self.selected_title_font = gfx:loadFont("QData", "Font26V", false, palette)
    self.drug_font = gfx:loadFont("QData", "Font24V", false, palette)
  end) then
    ui:addWindow(UIInformation(ui, {_S.errors.dialog_missing_graphics}))
    self:close()
    return
  end
  
  self.hospital = ui.hospital
  self.casebook = self.hospital.disease_casebook
  self:updateDiseaseList()
  
  -- Buttons
  self:addPanel(0, 607, 449):makeButton(0, 0, 26, 26, 3, self.close):setTooltip(_S.tooltip.casebook.close)
  self:addPanel(0, 439, 29):makeRepeatButton(0, 0, 70, 46, 1, self.scrollUp):setTooltip(_S.tooltip.casebook.up)
  self:addPanel(0, 437, 394):makeRepeatButton(0, 0, 77, 53, 2, self.scrollDown):setTooltip(_S.tooltip.casebook.down)
  self:addPanel(0, 354, 133):makeRepeatButton(0, 0, 22, 22, 5, self.increasePay):setTooltip(_S.tooltip.casebook.increase)
  self:addPanel(0, 237, 133):makeRepeatButton(0, 0, 22, 22, 4, self.decreasePay):setTooltip(_S.tooltip.casebook.decrease)
  self:addPanel(0, 235, 400):makeButton(0, 0, 140, 20, 0, self.concentrateResearch)
    :setTooltip(_S.tooltip.casebook.research)
  
  -- Hotkeys
  self:addKeyHandler("up", self.scrollUp)
  self:addKeyHandler("down", self.scrollDown)
  self:addKeyHandler("right", self.increasePay)
  self:addKeyHandler("left", self.decreasePay)
  self.ui:enableKeyboardRepeat() -- To quickly change values
  
  -- Icons representing cure effectiveness and other important information.
  self.machinery = self:addPanel(6, 306, 352):setTooltip(_S.tooltip.casebook.cure_type.machine)
  self.machinery.visible = false
  self.drug = self:addPanel(7, 306, 352):setDynamicTooltip(--[[persistable:casebook_drug_tooltip]] function()
    return _S.tooltip.casebook.cure_type.drug_percentage:format(self.casebook[self.selected_disease].cure_effectiveness)
  end)
  self.drug.visible = false
  self.surgery = self:addPanel(8, 306, 352):setTooltip(_S.tooltip.casebook.cure_type.surgery)
  self.surgery.visible = false
  self.unknown = self:addPanel(9, 306, 352):setTooltip(_S.tooltip.casebook.cure_type.unknown)
  self.unknown.visible = false
  self.psychiatry = self:addPanel(10, 306, 352):setTooltip(_S.tooltip.casebook.cure_type.psychiatrist)
  self.psychiatry.visible = false
  
  self.curable = self:addPanel(11, 335, 352):setTooltip(_S.tooltip.casebook.cure_requirement.possible)
  self.curable.visible = false
  self.not_curable = self:addPanel(12, 335, 352):setTooltip(_S.tooltip.casebook.cure_requirement.not_possible) -- TODO: split up in more specific requirements
  self.not_curable.visible = false
  
  self.percentage_counter = false -- Counter for displaying cure price percentage for a certain time before switching to price.
  
  self:makeTooltip(_S.tooltip.casebook.reputation,       249,  72, 362, 117)
  self:makeTooltip(_S.tooltip.casebook.treatment_charge, 249, 117, 362, 161)
  self:makeTooltip(_S.tooltip.casebook.earned_money,     247, 161, 362, 205)
  self:makeTooltip(_S.tooltip.casebook.cured,            247, 205, 362, 249)
  self:makeTooltip(_S.tooltip.casebook.deaths,           247, 249, 362, 293)
  self:makeTooltip(_S.tooltip.casebook.sent_home,        247, 293, 362, 337)
  
  if disease_selection then
    self:selectDisease(disease_selection)
  else
    self.selected_index = #self.names_sorted
    self.selected_disease = self.names_sorted[self.selected_index]
    self:updateIcons()
  end
end

function UICasebook:close()
  self.ui:disableKeyboardRepeat()
  Window.close(self)
end

function UICasebook:updateDiseaseList()
  -- A sorted list of known diseases and pseudo diseases.
  -- Used to be able to list the diseases in, believe it or not,
  -- alphabetical order.
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
end

function UICasebook:selectDisease(disease)
  for i = 1, #self.names_sorted do
    if disease == self.names_sorted[i] then
      self.selected_index = i
      self.selected_disease = self.names_sorted[self.selected_index]
      break
    end
  end
  self:updateIcons()
end

local staffclass_to_string = {
  Nurse        = _S.staff_title.nurse,
  Doctor       = _S.staff_title.doctor,
  Surgeon      = _S.staff_title.surgeon,
  Psychiatrist = _S.staff_title.psychiatrist,
  Researcher   = _S.staff_title.researcher,
}

--! Function that is called when a new entry is selected in some way
--! It updates all icons etc. that react to what is selected
function UICasebook:updateIcons()
  local disease = self.selected_disease
  local hosp = self.hospital
  local world = hosp.world
  
  local known = true
  -- Curable / not curable icons and their tooltip
  if self.casebook[disease].pseudo then
    self.curable.visible = false
    self.not_curable.visible = false
  else
    local req = hosp:checkDiseaseRequirements(disease)
    if not req then
      self.curable.visible = true
      self.not_curable.visible = false
    else
      self.curable.visible = false
      self.not_curable.visible = true
      
      -- Strings for the tooltip
      local research = false
      local build = false
      local staff = false
      -- Room requirements
      if #req.rooms > 0 then
        for i, room_id in ipairs(req.rooms) do
          -- Not researched yet?
          if not hosp.discovered_rooms[world.available_rooms[room_id]] then
            known = false
            research = (research and (research .. ", ") or " (") .. TheApp.rooms[room_id].name
          end
          -- Researched, but not built. TODO: maybe make this an else clause to not oversize the tooltip that much
          build = (build and (build .. ", ") or " (") .. TheApp.rooms[room_id].name
        end
      end
      research = research and (_S.tooltip.casebook.cure_requirement.research_machine .. research .. "). ") or ""
      build    = build    and (_S.tooltip.casebook.cure_requirement.build_room .. build .. "). ") or ""
      
      -- Staff requirements
      for sclass, amount in pairs(req.staff) do
        staff = (staff and (staff .. ", ") or " (") .. staffclass_to_string[sclass] .. ": " .. amount
      end
      staff = staff and (_S.tooltip.casebook.cure_requirement.hire_staff .. staff .. "). ") or ""
      
      self.not_curable:setTooltip(research .. build .. staff)
    end
  end
  
  self.unknown.visible    = not known
  self.drug.visible       = known and not not self.casebook[disease].drug
  self.machinery.visible  = known and not not self.casebook[disease].machine and not self.casebook[disease].pseudo
  self.psychiatry.visible = known and not not self.casebook[disease].psychiatrist
  self.surgery.visible    = known and not not self.casebook[disease].surgeon
  
  self.ui:updateTooltip() -- for the case that mouse is hovering over icon while player scrolls through list with keys
  self.percentage_counter = 50
end

function UICasebook:draw(canvas, x, y)
  self.background:draw(canvas, self.x + x, self.y + y)
  UIFullscreen.draw(self, canvas, x, y)
  
  x, y = self.x + x, self.y + y
  local titles = self.title_font
  local book = self.casebook
  local disease = self.selected_disease
  local selected = self.selected_index
  
  -- All titles
  titles:draw(canvas, _S.casebook.reputation,       x + 278, y + 68)
  titles:draw(canvas, _S.casebook.treatment_charge, x + 260, y + 113)
  titles:draw(canvas, _S.casebook.earned_money,     x + 265, y + 157)
  titles:draw(canvas, _S.casebook.cured,            x + 276, y + 201)
  titles:draw(canvas, _S.casebook.deaths,           x + 279, y + 245)
  titles:draw(canvas, _S.casebook.sent_home,        x + 270, y + 289)
  titles:draw(canvas, _S.casebook.cure,             x + 255, y + 354)
  
  -- Specific disease information
  if book[disease].machine or book[disease].drug then
    if book[disease].concentrate_research then  -- Concentrate research
      self.selected_title_font:draw(canvas, _S.casebook.research, x + 245, y + 398)
    else
      titles:draw(canvas, _S.casebook.research, x + 245, y + 398)
    end
  end
  local rep = book[disease].reputation or self.hospital.reputation
  if rep < self.hospital.reputation_min then
    rep = self.hospital.reputation_min
  elseif rep > self.hospital.reputation_max then
    rep = self.hospital.reputation_max
  end

  titles:draw(canvas, rep, x + 248, y + 92, 114, 0) -- Reputation

  -- Treatment Charge is either displayed in percent, or normally
  local price_text = self.percentage_counter and ("%.0f%%"):format(book[disease].price * 100)
                      or "$" .. self.hospital:getTreatmentPrice(disease)
  titles:draw(canvas, price_text, x + 262, y + 137, 90, 0) -- Treatment Charge
  
  titles:draw(canvas, "$" .. book[disease].money_earned, x + 248, y + 181, 114, 0) -- Money Earned
  titles:draw(canvas, book[disease].recoveries, x + 248, y + 225, 114, 0) -- Recoveries
  titles:draw(canvas, book[disease].fatalities, x + 248, y + 269, 114, 0) -- Fatalities
  titles:draw(canvas, book[disease].turned_away, x + 248, y + 313, 114, 0) -- Turned away
  
  -- Cure percentage
  if self.drug.visible then
    self.drug_font:draw(canvas, book[disease].cure_effectiveness, x + 313, y + 364, 16, 0)
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
    if self.buttons_down.ctrl then
      self.selected_index = 1
    else
      self.selected_index = self.selected_index - 1
    end

    self.selected_disease = self.names_sorted[self.selected_index]
    self.ui:playSound("pagetur2.wav")
  else
    self.ui:playSound("Wrong2.wav")
  end
  self:updateIcons()
end

function UICasebook:scrollDown()
  if self.selected_index < #self.names_sorted then
    if self.buttons_down.ctrl then
      self.selected_index = #self.names_sorted
    else
      self.selected_index = self.selected_index + 1
    end

    self.selected_disease = self.names_sorted[self.selected_index]
    self.ui:playSound("pagetur2.wav")
  else
    self.ui:playSound("Wrong2.wav")
  end
  self:updateIcons()
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
    self.ui:playSound("Wrong2.wav")
  else
    self.ui:playSound("selectx.wav")
  end
  self.casebook[self.selected_disease].price = price
  self.percentage_counter = 50
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
    self.ui:playSound("Wrong2.wav")
  else
    self.ui:playSound("selectx.wav")
  end
  self.casebook[self.selected_disease].price = price
  self.percentage_counter = 50
end

function UICasebook:concentrateResearch()
  if self.casebook[self.selected_disease].machine 
  or self.casebook[self.selected_disease].drug then
    self.hospital.research:concentrateResearch(self.selected_disease)
  end
end

function UICasebook:onMouseDown(button, x, y)
  -- Normal window operations if outside the disease list
  if x < 395 or x > 540 or y < 77 or y > 394 then
    return UIFullscreen.onMouseDown(self, button, x, y)
  end

  local index_diff
  if y < 203 then
    index_diff = -7 + math.floor((y - 77) / 18)
  elseif y > 269 then
    index_diff = math.floor((y - 269) / 18) + 1
  else
    return
  end

  -- Clicking on a disease name scrolls to the disease
  local new_index = self.selected_index + index_diff
  if new_index >= 1 and new_index <= #self.names_sorted then
    self.selected_index = new_index
    self.selected_disease = self.names_sorted[self.selected_index]
    self.ui:playSound("pagetur2.wav")
    self:updateIcons()
  end
end

function UICasebook:onMouseUp(code, x, y)
  if not UIFullscreen.onMouseUp(self, code, x, y) then
    if self:hitTest(x, y) then
      if code == 4 then
        -- Mouse wheel, scroll.
        self:scrollUp()
        return true
      elseif code == 5 then
        self:scrollDown()
        return true
      end
    end
    return false
  else
    return true
  end
end

function UICasebook:onTick()
  -- Decrease counter for showing percentage of cure price, if applicable
  if self.percentage_counter then
    self.percentage_counter = self.percentage_counter - 1
    if self.percentage_counter <= 0 then
      self.percentage_counter = false
    end
  end
  return UIFullscreen.onTick(self)
end
