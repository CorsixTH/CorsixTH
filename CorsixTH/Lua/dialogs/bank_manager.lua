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
  
  -- TODO: The bank manager's eyes, eyebrows and mouth
  -- TODO: Add the insurance companies "for real" and draw graphs
end

local function sum(t)
  local sum = 0
  for _, entry in ipairs(t) do 
    sum = sum + entry
  end
  return sum
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
      font:draw(canvas, values.day .. " " .. _S.months[values.month], x + 48, current_y)
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
      ui:setCursor(ui.app.gfx:loadMainCursor("bank")) -- Set dollar cursor
    else
      ui:setCursor(ui.default_cursor) -- Return to default cursor
    end
end

function UIBankManager:close()
    local ui = self.ui
    ui:setCursor(ui.default_cursor) -- Return to default cursor
    UIFullscreen.close(self)
end

function UIBankManager:showStatistics()
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
  -- The close button has been slightly moved.
  local panel = self.close_panel
  panel.x = panel.x - 6
  panel.y = panel.y - 6
  local btn = self.close_button
  btn.x = btn.x - 6
  btn.y = btn.y - 6
  -- Change tooltip to say that the statement screen is closed.
  btn:setTooltip(_S.tooltip.statement.close)
end

function UIBankManager:hideStatistics()
  self.ui:playSound("selectx.wav")
  self.showingStatistics = false
  self.return_from_stat_button.enabled = false
  self.stat_button.enabled = true
  -- return the close button again
  local panel = self.close_panel
  panel.x = panel.x + 6
  panel.y = panel.y + 6
  local btn = self.close_button
  btn.x = btn.x + 6
  btn.y = btn.y + 6
  -- Change the tooltip back
  btn:setTooltip(_S.tooltip.bank_manager.close)
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
