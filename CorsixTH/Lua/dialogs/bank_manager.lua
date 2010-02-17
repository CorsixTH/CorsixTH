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

class "UIBankManager" (UIFullscreen)

function UIBankManager:UIBankManager(ui)
  self:UIFullscreen(ui)
  local gfx = ui.app.gfx
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
  
  self.default_button_sound = "selectx.wav"
  
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
  self.close_button = self.close_panel:makeButton(0, 0, 26, 26, 4, self.close)
  
  self:addPanel(0, 192, 265):makeButton(0, 0, 21, 21, 6, self.increaseLoan)
  self:addPanel(0, 50, 265):makeButton(0, 0, 21, 21, 5, self.decreaseLoan)
  
  self:addPanel(0, 547, 157):makeButton(0, 0, 42, 23, 3, self.showGraph1)
  self:addPanel(0, 547, 217):makeButton(0, 0, 42, 23, 3, self.showGraph2)
  self.third_graph_button = self:addPanel(0, 547, 277)
    :makeButton(0, 0, 42, 23, 3, self.showGraph3)
  
  self.graph = self:addPanel(1, 417, 150)
  self.graph.visible = false
  self.return_from_graph_button = self:addPanel(0, 547, 277)
  self.return_from_graph_button:makeButton(0, 0, 42, 23, 2, self.returnFromGraph)
  self.return_from_graph_button.visible = false
  
  -- TODO: The bank manager's eyes, eyebrows and mouth
  -- TODO: Add the insurance companies "for real" and draw graphs
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
      font:draw(canvas, "$ 0", x + 430, y + 162, 100, 0)
      font:draw(canvas, hospital.insurance[2], x + 430, y + 192, 158, 0)
      font:draw(canvas, "$ 0", x + 430, y + 222, 100, 0)
      font:draw(canvas, hospital.insurance[3], x + 430, y + 252, 158, 0)
      font:draw(canvas, "$ 0", x + 430, y + 282, 100, 0)
    end
    font:draw(canvas, _S.bank_manager.inflation_rate, x + 430, y + 312, 100, 0)
    font:draw(canvas, hospital.inflation_rate*100 .. " %", x + 550, y + 313, 38, 0)
    font:draw(canvas, _S.bank_manager.interest_rate, x + 430, y + 342, 100, 0)
    font:draw(canvas, hospital.interest_rate*100 .. " %", x + 550, y + 342, 38, 0)
  end
end

function UIBankManager:showStatistics()
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
end

function UIBankManager:hideStatistics()
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
end

function UIBankManager:showGraph()
  self.graph.visible = true
  self.return_from_graph_button.visible = true
  -- In order for the return button to function, disable the one behind it.
  self.third_graph_button.enabled = false
end

function UIBankManager:showGraph1()
  self:showGraph()
  self.chosen_insurance = 1
end

function UIBankManager:showGraph2()
  self:showGraph()
  self.chosen_insurance = 2
end

function UIBankManager:showGraph3()
  self:showGraph()
  self.chosen_insurance = 3
end

function UIBankManager:returnFromGraph()
  self.graph.visible = false
  self.return_from_graph_button.visible = false
  self.third_graph_button.enabled = true
end

function UIBankManager:increaseLoan()
  local hospital = self.ui.hospital
  if hospital.loan < 20000 then -- TODO: Variate this based on something?
    hospital.loan = hospital.loan + 5000
    hospital:receiveMoney(5000, _S.transactions.bank_loan)
  end
end

function UIBankManager:decreaseLoan()
  local hospital = self.ui.hospital
  if hospital.loan > 0 and hospital.balance > 5000 then
    hospital.loan = hospital.loan - 5000
    hospital:spendMoney(5000, _S.transactions.loan_repayment)
  end
end
