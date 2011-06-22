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

--! Bank manager (for loans / insurance companies) and bank statement fullscreen windows.
class "UIBankManager" (UIFullscreen)

function UIBankManager:UIBankManager(ui)
  self:UIFullscreen(ui)
  local gfx = ui.app.gfx
  if not pcall(function()
    self.background = gfx:loadRaw("Bank01V", 640, 480)
    self.stat_background = gfx:loadRaw("Stat01V", 640, 480)
    local palette = gfx:loadPalette("QData", "Bank01V.pal")
    palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
    self.panel_sprites = gfx:loadSpriteTable("QData", "Bank02V", true, palette)
    self.font = gfx:loadFont("QData", "Font36V", false, palette)
  
    -- The statistics font 
    palette = gfx:loadPalette("QData", "Stat01V.pal")
    palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
    self.stat_font = gfx:loadFont("QData", "Font37V", false, palette)
  end) then
    ui:addWindow(UIInformation(ui, {_S.errors.dialog_missing_graphics}))
    self:close()
    return
  end
  -- counters for the animations of the bank manager
  self.counter = 0
  self.browsclk = 0
  self.smilesclk = 0
  self.eyesclk = 0
  
   -- sprites for the animation
  self.smiles = self:addPanel(12, 303, 199)
  self.eyesblink = self:addPanel(7, 298, 173)
  self.browslift = self:addPanel(9, 296, 165)
  
  -- Button so that the user can click in the middle and get the statistics page and
  -- vice versa
  self.stat_button = self:addPanel(0, 230, 100)
    :makeButton(0, 0, 160, 300, 0, self.showStatistics)
  self.return_from_stat_button = self:addPanel(0, 0, 0)
    :makeButton(0, 0, 640, 440, 0, self.hideStatistics)
  self.return_from_stat_button.enabled = false
  
  -- Buttons
  -- The close button needs to be movable
  self.close_panel = self:addPanel(0, 607, 448)
  self.close_button = self.close_panel:makeButton(0, 0, 26, 26, 4, self.close):setTooltip(_S.tooltip.bank_manager.close)
  
  self:addPanel(0, 250, 390):makeButton(0, 0, 200, 50, 0, self.openTownMap):setTooltip(_S.tooltip.toolbar.town_map)
  self:addPanel(0, 192, 265):makeButton(0, 0, 21, 21, 6, self.increaseLoan):setTooltip(_S.tooltip.bank_manager.borrow_5000)
  self:addPanel(0, 50, 265):makeButton(0, 0, 21, 21, 5, self.decreaseLoan):setTooltip(_S.tooltip.bank_manager.repay_5000)
  
  self.graph_buttons = {
    self:addPanel(0, 547, 157):makeButton(0, 0, 42, 23, 3, self.showGraph1):setTooltip(_S.tooltip.bank_manager.show_graph:format(self.ui.hospital.insurance[1])),
    self:addPanel(0, 547, 217):makeButton(0, 0, 42, 23, 3, self.showGraph2):setTooltip(_S.tooltip.bank_manager.show_graph:format(self.ui.hospital.insurance[2])),
    self:addPanel(0, 547, 277):makeButton(0, 0, 42, 23, 3, self.showGraph3):setTooltip(_S.tooltip.bank_manager.show_graph:format(self.ui.hospital.insurance[3]))
  }
  
  self.graph = self:addPanel(1, 417, 150)
  
  self.graph.visible = false
  self.graph.enabled = false
  self.return_from_graph_button = self:addPanel(0, 547, 277)
  self.return_from_graph_button:makeButton(0, 0, 42, 23, 2, self.returnFromGraph):setTooltip(_S.tooltip.bank_manager.graph_return)
  self.return_from_graph_button.visible = false
  self.return_from_graph_button.enabled = false
  
  self:makeTooltip(_S.tooltip.bank_manager.hospital_value,   60, 105, 203, 157)
  self:makeTooltip(_S.tooltip.bank_manager.balance,          60, 170, 203, 222)
  self:makeTooltip(_S.tooltip.bank_manager.current_loan,     60, 235, 203, 287)
  self:makeTooltip(_S.tooltip.bank_manager.interest_payment, 60, 300, 203, 352)
  
  local --[[persistable:insurance_tooltip_template]] function insurance_tooltip(i)
    return --[[persistable:insurance_tooltip]] function()
      if not self.graph.visible then
        return _S.tooltip.bank_manager.insurance_owed:format(self.ui.hospital.insurance[i])
      end
    end
  end
  
  self:makeDynamicTooltip(insurance_tooltip(1), 430, 128, 589, 180)
  self:makeDynamicTooltip(insurance_tooltip(2), 430, 188, 589, 240)
  self:makeDynamicTooltip(insurance_tooltip(3), 430, 248, 589, 300)

  self:makeTooltip(_S.tooltip.bank_manager.inflation_rate, 430, 308, 589, 331)
  self:makeTooltip(_S.tooltip.bank_manager.interest_rate, 430, 337, 589, 360)
  -- TODO: Add the graphs
end

function UIBankManager:afterLoad(old, new)
  if old < 36 then
    -- adds the new variables for bank manager animation
    self.browsclk = 0
    self.smilesclk = 0
    self.eyesclk = 0
    self.counter = 0
    self.smiles = self:addPanel(12, 303, 199)
    self.eyesblink = self:addPanel(7, 298, 173)
    self.browslift = self:addPanel(9, 296, 165)
  end
  UIFullscreen.afterLoad(self, old, new)
end

local function sum(t)
  local sum = 0
  for _, entry in ipairs(t) do 
    sum = sum + entry
  end
  return sum
end

-- animation function
function UIBankManager:onTick()
  self.counter = self.counter + 1
  -- animate the eyes to blink
  local function animateEyes()
    self.eyesclk = self.eyesclk + 1
    if self.eyesclk > 2 then
      self.eyesclk = 0
      self.eyesblink.sprite_index = self.eyesblink.sprite_index + 1
      if self.eyesblink.sprite_index > 8 then 
        self.eyesblink.sprite_index = 7
      end
    end
  end
  -- animate the eyebrows to raise and lower
  local function animateBrows()
    self.browsclk = self.browsclk + 1
    if self.browsclk > 3 then
      self.browsclk = 0
      self.browslift.sprite_index = self.browslift.sprite_index + 1
      if self.browslift.sprite_index > 11 then
        self.browslift.sprite_index = 9
      end
    end
  end
  -- animate the smile to frown and back again
  local function animateSmile()
    self.smilesclk = self.smilesclk + 1
    if self.smilesclk > 3 then
      self.smilesclk = 0
      self.smiles.sprite_index = self.smiles.sprite_index + 1
      if self.smiles.sprite_index > 15 then 
        self.smiles.sprite_index = 12
      end
    end
  end
  -- counters to determine when to start and stop the animations
  -- two blinks
  if self.counter  >= 24 and self.counter < 36 then
    animateEyes()
  -- one blink
  elseif self.counter  >= 49 and self.counter < 55 then
    animateEyes()
  -- one blink
  elseif self.counter  >= 70 and self.counter < 76 then
    animateEyes()
  -- up and down once
  elseif self.counter  >= 88 and self.counter < 100 then
    animateBrows()
  -- smile 
  elseif self.counter  >= 132 and  self.counter < 140 then
    animateSmile()
  -- two blinks
  elseif self.counter  >= 164 and self.counter < 176 then
    animateEyes()
  -- one blink
  elseif self.counter  >= 189 and self.counter < 195 then
    animateEyes()
  -- one blink
  elseif self.counter  >= 219 and self.counter < 225 then
    animateEyes()
  -- brows  up and down once
  elseif self.counter  >= 248 and self.counter < 260 then
    animateBrows()
  --smiles
  elseif self.counter  >= 272 and self.counter < 280 then
    animateSmile()
  -- brows up and down twice
  elseif self.counter  >= 298 and self.counter < 322 then
    animateBrows()
  -- two blinks
  elseif self.counter  >= 340 and self.counter < 352 then 
    animateEyes()
  end
  -- reset the animation counter
  if self.counter > 420 then
    self.counter = 0
  end
end

function UIBankManager:draw(canvas, x, y)
  local hospital = self.ui.hospital
  
  -- Either draw the statistics page or the normal bank page
  if self.showingStatistics then
    local font = self.stat_font
    self.stat_background:draw(canvas, self.x + x, self.y + y)
    UIFullscreen.draw(self, canvas, x, y)
    x, y = self.x + x, self.y + y
    
    -- Titles
    font:draw(canvas, _S.bank_manager.statistics_page.date, x + 44, y + 37, 65, 0)
    font:draw(canvas, _S.bank_manager.statistics_page.details, x + 125, y + 40, 230, 0)
    font:draw(canvas, _S.bank_manager.statistics_page.money_out, x + 373, y + 42, 70, 0)
    font:draw(canvas, _S.bank_manager.statistics_page.money_in, x + 449, y + 41, 70, 0)
    font:draw(canvas, _S.bank_manager.statistics_page.balance, x + 525, y + 40, 70, 0)
    
    -- Each transaction
    -- A for loop going backwards
    for no = 1, #hospital.transactions do
      local values = hospital.transactions[#hospital.transactions - no + 1]
      local current_y = no * 15 + y + 60
      font:draw(canvas, _S.date_format.daymonth:format(values.day, values.month), x + 48, current_y)
      font:draw(canvas, values.desc, x + 129, current_y)
      if values.spend then
        font:draw(canvas, "$ " .. values.spend, x + 377, current_y)
      else
        font:draw(canvas, "$ " .. values.receive, x + 453, current_y)
      end
      font:draw(canvas, "$ " .. values.balance, x + 529, current_y)
    end
    
    -- Summary
    font:draw(canvas, _S.bank_manager.statistics_page.current_balance, x + 373, y + 420, 140, 0)
    font:draw(canvas, "$ " .. hospital.balance, x + 526, y + 421, 70, 0)
  else
    local font = self.font
    self.background:draw(canvas, self.x + x, self.y + y)
    UIFullscreen.draw(self, canvas, x, y)
    x, y = self.x + x, self.y + y
    
    -- The left side
    font:draw(canvas, _S.bank_manager.hospital_value, x + 60, y + 109, 143, 0)
    font:draw(canvas, "$ " .. hospital.value, x + 60, y + 139, 143, 0)
    font:draw(canvas, _S.bank_manager.balance, x + 60, y + 174, 143, 0)
    font:draw(canvas, "$ " .. hospital.balance, x + 60, y + 204, 143, 0)
    font:draw(canvas, _S.bank_manager.current_loan, x + 60, y + 239, 143, 0)
    font:draw(canvas, "$ " .. hospital.loan, x + 60, y + 269, 143, 0)
    font:draw(canvas, _S.bank_manager.interest_payment, x + 60, y + 305, 143, 0)
    local interest = math.floor(hospital.loan * hospital.interest_rate / 12)
    font:draw(canvas, "$ " .. interest, x + 60, y + 334, 143, 0)
    
    -- The right side
    font:draw(canvas, _S.bank_manager.insurance_owed, x + 430, y + 102, 158, 0)
    if self.graph.visible then
      font:draw(canvas, hospital.insurance[self.chosen_insurance], x + 430, y + 132, 158, 0)
    else
      font:draw(canvas, hospital.insurance[1], x + 430, y + 132, 158, 0)
      font:draw(canvas, "$ ".. sum(hospital.insurance_balance[1]), x + 430, y + 162, 100, 0)
      font:draw(canvas, hospital.insurance[2], x + 430, y + 192, 158, 0)
      font:draw(canvas, "$ ".. sum(hospital.insurance_balance[2]), x + 430, y + 222, 100, 0)
      font:draw(canvas, hospital.insurance[3], x + 430, y + 252, 158, 0)
      font:draw(canvas, "$ ".. sum(hospital.insurance_balance[3]), x + 430, y + 282, 100, 0)
    end
    font:draw(canvas, _S.bank_manager.inflation_rate, x + 430, y + 312, 100, 0)
    font:draw(canvas, hospital.inflation_rate*100 .. " %", x + 550, y + 313, 38, 0)
    font:draw(canvas, _S.bank_manager.interest_rate, x + 430, y + 342, 100, 0)
    font:draw(canvas, hospital.interest_rate*100 .. " %", x + 550, y + 342, 38, 0)
  end
end

function UIBankManager:onMouseMove(x, y, ...)
    local ui = self.ui
    if x > 0 and x < 640 and y > 0 and y < 480 then
      if self.showingStatistics then
        ui:setCursor(ui.app.gfx:loadMainCursor("banksummary")) -- Set pie chart cursor
      else
        ui:setCursor(ui.app.gfx:loadMainCursor("bank")) -- Set dollar cursor
      end
    else
      ui:setCursor(ui.default_cursor) -- Return to default cursor
    end
end

function UIBankManager:close()
    local ui = self.ui
    ui:setCursor(ui.default_cursor) -- Return to default cursor
    UIFullscreen.close(self)
end

function UIBankManager:showStatistics(keep_cursor)
  if self.closed then
    return
  end
  self.ui:playSound("selectx.wav")
  -- close any open graphs
  if self.graph.visible then
    self:returnFromGraph()
  end
  self.showingStatistics = true
  self.return_from_stat_button.enabled = true
  self.stat_button.enabled = false
  -- hides the animated parts of the bank manager when viewing the statement  
  self.smiles.visible = false
  self.eyesblink.visible = false
  self.browslift.visible = false  
  -- The close button has been slightly moved.
  local panel = self.close_panel
  panel.x = panel.x - 6
  panel.y = panel.y - 6
  local btn = self.close_button
  btn.x = btn.x - 6
  btn.y = btn.y - 6
  -- Change tooltip to say that the statement screen is closed.
  btn:setTooltip(_S.tooltip.statement.close)
  -- Set pie chart cursor, unless coming here from right click on the dollar sign.
  if not keep_cursor then
    self.ui:setCursor(self.ui.app.gfx:loadMainCursor("banksummary"))
  end
end

function UIBankManager:hideStatistics()
  self.ui:playSound("selectx.wav")
  self.showingStatistics = false
  self.return_from_stat_button.enabled = false
  self.stat_button.enabled = true
  -- shows the animated parts of the bank manager when viewing the main screen
  self.smiles.visible = true
  self.eyesblink.visible = true
  self.browslift.visible = true  
  -- resets the animation counter if the screen is switched to the statement and back 
  self.counter = -1  
  -- return the close button again
  local panel = self.close_panel
  panel.x = panel.x + 6
  panel.y = panel.y + 6
  local btn = self.close_button
  btn.x = btn.x + 6
  btn.y = btn.y + 6
  -- Change the tooltip back
  btn:setTooltip(_S.tooltip.bank_manager.close)
  -- Set dollar cursor
  self.ui:setCursor(self.ui.app.gfx:loadMainCursor("bank"))
end

function UIBankManager:showGraph()
  self.ui:playSound("selectx.wav")
  self.graph:setTooltip(_S.tooltip.bank_manager.graph:format(self.ui.hospital.insurance[self.chosen_insurance]))
  self.graph.visible = true
  self.return_from_graph_button.visible = true
  self.return_from_graph_button.enabled = true

  for i = 1, 3 do
    self.graph_buttons[i].visible = false
    self.graph_buttons[i].enabled = false
  end
end

function UIBankManager:showGraph1()
  self.chosen_insurance = 1
  self:showGraph()
end

function UIBankManager:showGraph2()
  self.chosen_insurance = 2
  self:showGraph()
end

function UIBankManager:showGraph3()
  self.chosen_insurance = 3
  self:showGraph()
end

function UIBankManager:returnFromGraph()
  self.ui:playSound("selectx.wav")
  self.graph.visible = false
  self.return_from_graph_button.visible = false
  self.return_from_graph_button.enabled = false
  for i = 1, 3 do
    self.graph_buttons[i].enabled = true
    self.graph_buttons[i].visible = true
  end
end

function UIBankManager:increaseLoan()
  local hospital = self.ui.hospital
  local max_loan = (math.floor((hospital.value * 0.33) / 5000) * 5000) + 10000
  if hospital.loan + 5000 <= max_loan  then
    local amount = self.buttons_down.ctrl and max_loan - hospital.loan or 5000
    hospital.loan = hospital.loan + amount
    hospital:receiveMoney(amount, _S.transactions.bank_loan)
    self.ui:playSound("selectx.wav")
  else
    self.ui:playSound("Wrong2.wav")
  end
end

function UIBankManager:decreaseLoan()
  local hospital = self.ui.hospital
  local amount = 5000
  if self.buttons_down.ctrl then
    -- Repay as much as possible in increments of 5000
    if hospital.balance > 5000 then
      amount = math.min(hospital.loan, math.floor(hospital.balance / 5000) * 5000)
    end
  end
  if hospital.loan > 0 and hospital.balance >= amount then
    hospital.loan = hospital.loan - amount
    hospital:spendMoney(amount, _S.transactions.loan_repayment)
    self.ui:playSound("selectx.wav")
  else
    self.ui:playSound("Wrong2.wav")
  end
end

function UIBankManager:openTownMap()
  local dlg = UITownMap(self.ui)
  self.ui:addWindow(dlg)
end
