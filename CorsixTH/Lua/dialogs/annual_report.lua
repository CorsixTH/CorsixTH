--[[ Copyright (c) 2010 Edvin "Lego3" Linge

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
local TH = require "TH"

--! Annual Report fullscreen window shown at the start of each year.
class "UIAnnualReport" (UIFullscreen)

function UIAnnualReport:UIAnnualReport(ui, world)

  self:UIFullscreen(ui)

  self.ui = ui
  local hosp = ui.hospital
  local gfx   = ui.app.gfx

  if not pcall(function()
    local palette   = gfx:loadPalette("QData", "Award02V.pal")
    palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent

    -- Right now the statistics are first
    --self.background = gfx:loadRaw("Fame01V", 640, 480)
    self.award_background = gfx:loadRaw("Award01V", 640, 480)
    self.stat_background = gfx:loadRaw("Award02V", 640, 480)
    self.background = self.stat_background

    self.stat_font = gfx:loadFont("QData", "Font45V", false, palette)
    self.write_font = gfx:loadFont("QData", "Font47V", false, palette)
    self.stone_font = gfx:loadFont("QData", "Font46V", false, palette)

    self.panel_sprites = gfx:loadSpriteTable("QData", "Award03V", true, palette)
  end) then
    ui:addWindow(UIInformation(ui, {_S.errors.dialog_missing_graphics}))
    self:close()
    return
  end
  -- The current state the dialog is in.
  -- Possible values are 1, 2 and 3 = fame, statistics and awards pages respectively
  -- TODO: The dialog has some preparations for the fame screen, but as long as there are no
  -- competitor scores and the player's own score isn't increased anywhere there's no use in
  -- showing it. Only hall of fame is there right now too, and maybe it should be a
  -- stand alone dialog since it has (2) sprites in another sprite file?
  self.state = 2
  self.default_button_sound = "selectx.wav"
  
  -- Close button, in the future different behaviours for different screens though
  --self.first_close = self:addPanel(0, 609, 449):makeButton(0, 0, 26, 26, 1, self.changePage)
  self.second_close = self:addPanel(0, 608, 449):makeButton(0, 0, 26, 26, 1, self.close)
  self:setActive(self.second_close, true)
  
  -- Change page buttons for the second and third pages
  local --[[persistable:annual_report_change_page]] function change() self:changePage(3) end
  self.second_change = self:addPanel(0, 274, 435):makeButton(0, 0, 91, 42, 3, change)
  self:setActive(self.second_change, true)
  
  self.third_change = self:addPanel(0, 272, 367):makeButton(0, 0, 91, 42, 3, self.changePage)
  self:setActive(self.third_change, false)
  
  -- The plaque
  local plaque = {}
  plaque[1] = self:addPanel(19, 206, 87)
  plaque[2] = self:addPanel(20, 206, 161)
  plaque[3] = self:addPanel(21, 206, 233)
  plaque[4] = self:addPanel(22, 206, 321)
  plaque.is_table = true
  self.plaque = plaque
  self:setActive(self.plaque, false)
  
  -- Close button for the award motivations
  self.third_close = self:addPanel(0, 389, 378):makeButton(0, 0, 26, 26, 2, self.showMotivation)
  self:setActive(self.third_close, false)
  
  -- Trophies. Currently the soda and the reputation award have been implemented
  local trophies = {}
  trophies[1] = self:addPanel(12, 142, 324)
  trophies[2] = self:addPanel(13, 407, 324)
  trophies[3] = self:addPanel(14, 466, 331)
  trophies[4] = trophies[1]:makeButton(0, 0, 61, 144, 12, self.reputationTrophy)
  trophies[5] = trophies[2]:makeButton(0, 0, 60, 144, 13, self.sodaTrophy)
  trophies[6] = trophies[3]:makeButton(0, 0, 72, 145, 14, self.nodeathsTrophy)
  trophies.is_table = true
  self.trophies = trophies
  self:setActive(self.trophies, false)

  -- "Activate" awards and trophies won
  if hosp.win_awards then
    local won_amount = 0
    if hosp.sodas_sold > world.map.level_config.awards_trophies.CansofCoke then
      self.soda_trophy_won = world.map.level_config.awards_trophies.CansofCokeBonus
      won_amount = self.soda_trophy_won
    end
    if hosp.reputation_above_threshold then
      self.rep_trophy_won = world.map.level_config.awards_trophies.TrophyReputationBonus
      won_amount = won_amount + self.rep_trophy_won
    end
    if hosp.num_deaths_this_year == 0 then
      self.no_deaths_trophy_won = world.map.level_config.awards_trophies.TrophyDeathBonus
      won_amount = won_amount + self.no_deaths_trophy_won
    end
    if won_amount > 0 then
      hosp:receiveMoney(won_amount, _S.transactions.eoy_trophy_bonus)
    end
  end
  
  -- Get and sort values used on the statistics screen.
  -- The six categories. The extra tables are used to be able to sort the values. 
    self.money = {}
    self.money_sort = {}
    self.visitors = {}
    self.visitors_sort = {}
    self.salary = {}
    self.salary_sort = {}
    self.deaths = {}
    self.deaths_sort = {}
    self.cures = {}
    self.cures_sort = {}
    self.value = {}
    self.value_sort = {}
    
    -- TODO: Right now there are no real competitors, they all have initial values.
    for i, hospital in ipairs(world.hospitals) do
      self.money[hospital.name] = hospital.balance - hospital.loan
      self.money_sort[i] = hospital.balance - hospital.loan
      self.visitors[hospital.name] = hospital.num_visitors
      self.visitors_sort[i] = hospital.num_visitors
      self.deaths[hospital.name] = hospital.num_deaths
      self.deaths_sort[i] = hospital.num_deaths
      self.cures[hospital.name] = hospital.num_cured
      self.cures_sort[i] = hospital.num_cured
      self.value[hospital.name] = hospital.value
      self.value_sort[i] = hospital.value
      self.salary[hospital.name] = hospital.player_salary
      self.salary_sort[i] = hospital.player_salary
    end
    
    local sort_order = function(a,b) return a>b end
    table.sort(self.money_sort, sort_order)
    table.sort(self.visitors_sort, sort_order)
    table.sort(self.deaths_sort) -- We want this to be in increasing order
    table.sort(self.cures_sort, sort_order)
    table.sort(self.value_sort, sort_order)
    table.sort(self.salary_sort, sort_order)
    
  -- Pause the game to allow the player plenty of time to check all statistics and trophies won
  world:setSpeed("Pause")
end

--! When the player clicks the reputation trophy this function is called.
function UIAnnualReport:reputationTrophy()
  if not self.rep_trophy then
    self.rep_trophy = _S.trophy_room.high_rep.awards[math.random(1, 2)]
  end
  self.trophy_money = self.rep_trophy_won
  self:showMotivation(self.rep_trophy)
end
--! When the player clicks the no deaths trophy this function is called.
function UIAnnualReport:nodeathsTrophy()
  if not self.no_deaths_trophy then
    self.no_deaths_trophy = _S.trophy_room.no_deaths.trophies[math.random(1, 2)]
  end
  self.trophy_money = self.no_deaths_trophy_won
  self:showMotivation(self.no_deaths_trophy)
end
--! When the player clicks the soda trophy this function is called.
function UIAnnualReport:sodaTrophy()
  if not self.soda_trophy then
    self.soda_trophy = _S.trophy_room.sold_drinks.trophies[math.random(1, 3)]
  end
  self.trophy_money = self.soda_trophy_won
  self:showMotivation(self.soda_trophy)
end

--! Activate the motivation plaque with the given text on it.
--!param text_to_show The text that should be shown on the plaque.
function UIAnnualReport:showMotivation(text_to_show)
  -- TODO: Awards will be shown on some kind of "paper".
  if text_to_show then
    self:setActive(self.plaque, true)
    self:setActive(self.third_close, true)
    self:setActive(self.third_change, false)
    self.showing_motivation = text_to_show
  else
    self:setActive(self.plaque, false)
    self:setActive(self.third_close, false)
    self:setActive(self.third_change, true)
    self.showing_motivation = nil
  end
end

--! Helper function that enables and makes visible button or table of buttons/panels.
--!param button The button or table of buttons that should be activated/deactivated. If
-- a table is given it needs to have the is_table flag set to true.
--!param active Defines if the new state is active (true) or inactive (false).
function UIAnnualReport:setActive(button, active)
  if button.is_table then
    for _, btn in ipairs(button) do
      btn.enabled = active
      btn.visible = active
    end
  else
    button.enabled = active
    button.visible = active
  end
end

--! Overridden close function. The game should be unpaused again when closing the dialog.
function UIAnnualReport:close()
  if TheApp.world:isCurrentSpeed("Pause") then
    TheApp.world:setSpeed(TheApp.world.prev_speed)
  end
  Window.close(self)
end

--! Changes the page of the annual report
--!param page_no The page to go to, either page 1, 2 or 3. Default is currently page 2.
function UIAnnualReport:changePage(page_no)
  -- Can only go to page 2 from page 1, and then only between page 2 and 3
  --self:setActive(self.first_close, false)
  self:setActive(self.second_close, true)
  self.second_close.visible = true
  if page_no == 2 or not page_no then -- Statistics page.
    self.background = self.stat_background
    self:setActive(self.third_change, false)
    self:setActive(self.second_change, true)
    self:setActive(self.trophies, false)
    self.state = 2
  else -- Awards and trophies
    self.background = self.award_background
    self:setActive(self.third_change, true)
    self:setActive(self.second_change, false)
    
    -- Show trophies only if the corresponding criterias are met.
    local hosp = self.ui.hospital
    if hosp.win_awards then
      if self.rep_trophy_won then
        self:setActive(self.trophies[1], true)
        self:setActive(self.trophies[4], true)
      end
      if self.no_deaths_trophy_won then
        self:setActive(self.trophies[3], true)
        self:setActive(self.trophies[6], true)
      end  
      if self.soda_trophy_won then
        self:setActive(self.trophies[2], true)
        self:setActive(self.trophies[5], true)
      end
    end
    self.state = 3
  end
end

function UIAnnualReport:draw(canvas, x, y)
  self.background:draw(canvas, self.x + x, self.y + y)
  UIFullscreen.draw(self, canvas, x, y)
  
  x, y = self.x + x, self.y + y
  local font = self.stat_font
  local world = self.ui.app.world
    
  if self.state == 1 then -- Fame screen
    -- Title and column names
    font:draw(canvas, _S.high_score.best_scores, x + 220, y + 104, 200, 0)
    font:draw(canvas, _S.high_score.pos, x + 218, y + 132)
    font:draw(canvas, _S.high_score.player, x + 260, y + 132)
    font:draw(canvas, _S.high_score.score, x + 360, y + 132)
    
    -- Players and their score
    local i = 1
    local dy = 0
    --for i = 1, 10 do
      font:draw(canvas, i .. ".", x + 220, y + 160 + dy)
      font:draw(canvas, world.hospitals[1].name:upper(), x + 260, y + 160 + dy)
      font:draw(canvas, "NA", x + 360, y + 160 + dy)
      dy = dy + 25
    --end
  elseif self.state == 2 then -- Statistics screen
    self:drawStatisticsScreen(canvas, x, y)
  else -- Award screen
    -- Write motivation if appropriate
    if self.showing_motivation then
      self.stone_font:drawWrapped(canvas, self.showing_motivation, x + 225, y + 105, 185, "center")
      -- Right now only money can be given from trophies.
      self.stone_font:draw(canvas, _S.trophy_room.cash, x + 220, y + 330, 200, 0)
      self.stone_font:draw(canvas, "+" .. self.trophy_money, x + 220, y + 355, 200, 0)
    end
  end
end

function UIAnnualReport:drawStatisticsScreen(canvas, x, y)

  local font = self.stat_font
  local world = self.ui.app.world
  
  -- Draw titles
  font:draw(canvas, _S.menu.charts .. " " 
  .. (world.year + 1999), x + 210, y + 30, 200, 0)
  font:draw(canvas, _S.high_score.categories.money, x + 140, y + 98, 170, 0)
  font:draw(canvas, _S.high_score.categories.salary, x + 328, y + 98, 170, 0)
  font:draw(canvas, _S.high_score.categories.cures, x + 140, y + 205, 170, 0)
  font:draw(canvas, _S.high_score.categories.deaths, x + 328, y + 205, 170, 0)
  font:draw(canvas, _S.high_score.categories.visitors, x + 140, y + 310, 170, 0)
  font:draw(canvas, _S.high_score.categories.total_value, x + 328, y + 310, 170, 0)
  
  -- TODO: Add possibility to right align text.

  -- Helper function to find where the person is in the array.
  -- TODO: This whole sorting thing, it should be possible to do it in a better way?
  local getindex = function(tablename, val)
    local i = 0
    local index
    for ind, value in ipairs(tablename) do
      if value == val then
        if not index then
          index = ind
        end
        i = i + 1
      end
    end
    return index, i
  end

  local row_y = 128
  local row_dy = 15
  local col_x = 190
  local row_no_y = 106
  local dup_money = 0
  local dup_salary = 0
  local dup_cures = 0
  local dup_deaths = 0
  local dup_visitors = 0
  local dup_value = 0
  for _, player in ipairs(world.hospitals) do
    local name = player.name
    
    -- Most Money
    local index, dup_m = getindex(self.money_sort, self.money[name])
    -- index is the returned value of the sorted place for this player.
    -- However there might be many players with the same value, so each iteration a
    -- duplicate has been found, one additional row lower is the right place to be.
    font:draw(canvas, name:upper(), x + 140, 
      y + row_y + row_dy*(index-1) + row_dy*(dup_money))
    font:draw(canvas, self.money[name], x + 240, 
      y + row_y + row_dy*(index-1) + row_dy*(dup_money), 70, 0, "right")
    
    -- Highest Salary
    local index, dup_s = getindex(self.salary_sort, self.salary[name])
    font:draw(canvas, name:upper(), x + 140 + col_x, 
      y + row_y + row_dy*(index-1) + row_dy*(dup_salary))
    font:draw(canvas, self.salary[name], x + 240 + col_x, 
      y + row_y + row_dy*(index-1) + row_dy*(dup_salary), 70, 0, "right")
    
    -- Most Cures
    local index, dup_c = getindex(self.cures_sort, self.cures[name])
    font:draw(canvas, name:upper(), x + 140, 
      y + row_y + row_no_y + row_dy*(index-1) + row_dy*(dup_cures))
    font:draw(canvas, self.cures[name], x + 240, 
      y + row_y + row_no_y + row_dy*(index-1) + row_dy*(dup_cures), 70, 0, "right")
    
    -- Most Deaths
    local index, dup_d = getindex(self.deaths_sort, self.deaths[name])
    font:draw(canvas, name:upper(), x + 140 + col_x, 
      y + row_y + row_no_y + row_dy*(index-1) + row_dy*(dup_deaths))
    font:draw(canvas, self.deaths[name], x + 240 + col_x, 
      y + row_y + row_no_y + row_dy*(index-1) + row_dy*(dup_deaths), 70, 0, "right")
    
    -- Most Visitors
    local index, dup_v = getindex(self.visitors_sort, self.visitors[name])
    font:draw(canvas, name:upper(), x + 140, 
      y + row_y + row_no_y*2 + row_dy*(index-1) + row_dy*(dup_visitors))
    font:draw(canvas, self.visitors[name], x + 240, 
      y + row_y + row_no_y*2 + row_dy*(index-1) + row_dy*(dup_visitors), 70, 0, "right")
    
    -- Highest Value
    local index, dup_v2 = getindex(self.value_sort, self.value[name])
    font:draw(canvas, name:upper(), x + 140 + col_x, 
      y + row_y + row_no_y*2 + row_dy*(index-1) + row_dy*(dup_value))
    font:draw(canvas, self.value[name], x + 240 + col_x, 
      y + row_y + row_no_y*2 + row_dy*(index-1) + row_dy*(dup_value), 70, 0, "right")
    
    if dup_m > 1 then dup_money = dup_money + 1 else dup_money = 0 end
    if dup_s > 1 then dup_salary = dup_salary + 1 else dup_salary = 0 end
    if dup_c > 1 then dup_cures = dup_cures + 1 else dup_cures = 0 end
    if dup_d > 1 then dup_deaths = dup_deaths + 1 else dup_deaths = 0 end
    if dup_v > 1 then dup_visitors = dup_visitors + 1 else dup_visitors = 0 end
    if dup_v2 > 1 then dup_value = dup_value + 1 else dup_value = 0 end
  end
end
