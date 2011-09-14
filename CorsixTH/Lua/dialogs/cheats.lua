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

--! A dialog for activating cheats
class "UICheats" (UIResizable)

local col_bg = {
  red = 154,
  green = 146,
  blue = 198,
}

local col_caption = {
  red = 174,
  green = 166,
  blue = 218,
}

local col_border = {
  red = 134,
  green = 126,
  blue = 178,
}

local col_cheated_no = {
  red = 36,
  green = 154,
  blue = 36,
}

local col_cheated_yes = {
  red = 224,
  green = 36,
  blue = 36,
}

--[[ Constructs the cheat dialog.
!param ui (UI) The active ui.
]]
function UICheats:UICheats(ui)
  self.cheats = {
    {name = "money",          func = self.cheatMoney},
    {name = "all_research",   func = self.cheatResearch},
    {name = "emergency",      func = self.cheatEmergency},
    {name = "vip",            func = self.cheatVip},
    {name = "create_patient", func = self.cheatPatient},
    {name = "end_month",      func = self.cheatMonth},
    {name = "end_year",       func = self.cheatYear},
    {name = "lose_level",     func = self.cheatLose},
    {name = "win_level",      func = self.cheatWin},
  }
  
  
  self:UIResizable(ui, 300, 200, col_bg)

  self.default_button_sound = "selectx.wav"
  
  local app = ui.app
  self.modal_class = "cheats"
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.2, 0.4)
  
  local y = 10
  self:addBevelPanel(20, y, 260, 20, col_caption):setLabel(_S.cheats_window.caption)
    .lowered = true
  
  y = y + 30
  self:addColourPanel(20, y, 260, 40, col_bg.red, col_bg.green, col_bg.blue):setLabel({_S.cheats_window.warning})
  
  y = y + 40
  self.cheated_panel = self:addBevelPanel(20, y, 260, 18, col_cheated_no, col_border, col_border)
  
  local function button_clicked(num)
    return --[[persistable:cheats_button]] function(self)
      self:buttonClicked(num)
    end
  end
  
  self.item_panels = {}
  self.item_buttons = {}

  y = y + 30
  for num = 1, #self.cheats do
    self.item_panels[num] = self:addBevelPanel(20, y, 260, 20, col_bg)
      :setLabel(_S.cheats_window.cheats[self.cheats[num].name])
    self.item_buttons[num] = self.item_panels[num]:makeButton(0, 0, 260, 20, nil, button_clicked(num))
      :setTooltip(_S.tooltip.cheats_window.cheats[self.cheats[num].name])
    y = y + 20
  end
  
  y = y + 20
  self:addBevelPanel(20, y, 260, 40, col_bg):setLabel(_S.cheats_window.close)
    :makeButton(0, 0, 260, 40, nil, self.buttonBack):setTooltip(_S.tooltip.cheats_window.close)
  
  y = y + 60
  self:setSize(300, y)
  self:updateCheatedStatus()
end

function UICheats:updateCheatedStatus()
  local cheated = self.ui.hospital.cheated
  self.cheated_panel:setLabel(cheated and _S.cheats_window.cheated.yes or _S.cheats_window.cheated.no)
  self.cheated_panel:setColour(cheated and col_cheated_yes or col_cheated_no)
end

function UICheats:buttonClicked(num)
  local announcements = self.ui.app.world.cheat_announcements
  if announcements then
    self.ui:playSound(announcements[math.random(1, #announcements)])
  end
  self.ui.hospital.cheated = true
  self:updateCheatedStatus()
  self.cheats[num].func(self)
end

function UICheats:cheatMoney()
  self.ui.hospital:receiveMoney(10000, _S.transactions.cheat)
end

function UICheats:cheatResearch()
  local hosp = self.ui.hospital
  for _, cat in ipairs({"diagnosis", "cure"}) do
    while hosp.research.research_policy[cat].current do
      hosp.research:discoverObject(hosp.research.research_policy[cat].current)
    end
  end
end

function UICheats:cheatEmergency()
  if not self.ui.hospital:createEmergency() then
    self.ui:addWindow(UIInformation(self.ui, {_S.misc.no_heliport}))
  end
end

function UICheats:cheatVip()
  self.ui.hospital:createVip()
end

function UICheats:cheatPatient()
  self.ui.app.world:spawnPatient()
end

function UICheats:cheatMonth()
  self.ui.app.world:setEndMonth()
end

function UICheats:cheatYear()
  self.ui.app.world:setEndYear()
end

function UICheats:cheatLose()
  self.ui.app.world:loseGame(1) -- TODO adjust for multiplayer
end

function UICheats:cheatWin()
  self.ui.app.world:winGame(1) -- TODO adjust for multiplayer
end

function UICheats:buttonBack()
  self:close()
end
