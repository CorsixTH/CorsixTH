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

local TH = require "TH"

--! Annual Report fullscreen window shown at the start of each year.
class "UIAnnualReport" (UIFullscreen)

function UIAnnualReport:UIAnnualReport(ui, world)

  self:UIFullscreen(ui)

  self.ui = ui
  local gfx   = ui.app.gfx
  self.won_amount = 0
  self.award_won_amount = 0
  self.rep_amount = 0

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
  ------------------------ The current state the dialog is in.  ---------------------------
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
  
  -- The plaque showed after the player has clicked on a trophy
  local plaque = {}
  plaque[1] = self:addPanel(19, 206, 87)
  plaque[2] = self:addPanel(20, 206, 161)
  plaque[3] = self:addPanel(21, 206, 233)
  plaque[4] = self:addPanel(22, 206, 321)
  plaque.is_table = true
  self.plaque = plaque
  self:setActive(self.plaque, false)

  -- Close button for the trophy motivations
  self.third_close = self:addPanel(0, 389, 378):makeButton(0, 0, 26, 26, 2, self.showTrophyMotivation)
  self:setActive(self.third_close, false)

  -- The scroll showed after the player has clicked on an award
  local scroll = {}
  scroll[1] = self:addPanel(16, 206, 87)
  scroll[2] = self:addPanel(17, 206, 200)
  scroll[3] = self:addPanel(18, 206, 304)
  scroll[4] = self:addPanel(15, 300, 341)
  scroll.is_table = true
  self.scroll = scroll
  self:setActive(self.scroll, false)

  -- Close button for the award motivations
  self.fourth_close = self:addPanel(0, 369, 358):makeButton(0, 0, 26, 26, 2, self.showAwardMotivation)
  self:setActive(self.fourth_close, false)

  -- How many awards the player got this year. Will increase after the checkup.
  self.no_awards = 0
  self.awards = {}

  -- Trophies. Currently the soda and the reputation award have been implemented
  self.no_trophies = 0
  self.trophies = {}

  -- Check which awards and trophies the player should get.
  self:checkTrophiesAndAwards(world)

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
  if world and world:isCurrentSpeed("Speed Up") then
    world:setSpeed("Pause")
  end
  TheApp.video:setBlueFilterActive(false)
end

--! Finds out which awards and/or trophies the player has been awarded this year.
function UIAnnualReport:checkTrophiesAndAwards(world)

  local hosp = self.ui.hospital
  local prices = world.map.level_config.awards_trophies

  -- Check CuresAward so that we know the new config settings are available
  if hosp.win_awards and prices.TrophyMayorBonus then
    self.won_amount = 0
    self.rep_amount = 0
    self.award_won_amount = 0


    -- The trophies and certificated awards/penalties available at this time --


    -------------------------------- Trophies ---------------------------------


    -- Coke sales
    if hosp.sodas_sold > prices.CansofCoke then
      self:addTrophy(_S.trophy_room.sold_drinks.trophies[math.random(1, 3)], "money", prices.CansofCokeBonus)
      self.won_amount = self.won_amount + prices.CansofCokeBonus
    end
    -- Impressive VIP visits
    if  hosp.num_vips_ty > 0 and hosp.pleased_vips_ty == hosp.num_vips_ty then
      -- added some here so you get odd amounts as in TH!
      local win_value = (prices.TrophyMayorBonus * hosp.pleased_vips_ty) + math.random(1, 5)
      self:addTrophy(_S.trophy_room.happy_vips.trophies[math.random(1, 3)], "reputation", win_value)
      self.rep_amount = self.rep_amount + win_value
    end
    -- Impressive Reputation in the year (above a threshold throughout the year)
    if hosp.reputation_above_threshold then
      self:addTrophy(_S.trophy_room.consistant_rep.trophies[math.random(1, 2)], "money", prices.TrophyReputationBonus)
      self.won_amount = self.won_amount + prices.TrophyReputationBonus
    end
    -- No deaths or around a 100% Cure rate in the year
    if hosp.num_deaths_this_year == 0 then
      self:addTrophy(_S.trophy_room.no_deaths.trophies[math.random(1, 3)], "money", prices.TrophyDeathBonus)
      self.won_amount = self.won_amount + prices.TrophyDeathBonus
    elseif hosp.num_cured_ty > (hosp.not_cured_ty * 0.9)  then
      self:addTrophy(_S.trophy_room.many_cured.trophies[math.random(1, 3)], "money", prices.TrophyCuresBonus)
      self.won_amount = self.won_amount + prices.TrophyCuresBonus
    end


    -------------------- Certificate Awards or Penalties ---------------------


    -- Reputation
    if hosp.reputation > prices.ReputationAward then
      self:addAward(_S.trophy_room.high_rep.awards[math.random(1, 2)], "money", prices.AwardReputationBonus)
      self.award_won_amount = self.award_won_amount + prices.AwardReputationBonus
    elseif hosp.reputation < prices.ReputationPoor then
      self:addAward(_S.trophy_room.high_rep.penalty[math.random(1, 2)], "money", prices.AwardReputationPenalty)
      self.award_won_amount = self.award_won_amount + prices.AwardReputationPenalty
    end

    -- Hospital Value
    if hosp.value > prices.HospValueAward then
      -- added some here so you get odd amounts as in TH!
      local win_value = prices.HospValueBonus * math.random(1, 15)
      self:addAward(_S.trophy_room.hosp_value.awards[1], "reputation", win_value)
      self.rep_amount = self.rep_amount + win_value
    elseif hosp.value < prices.HospValuePoor then
      -- added some here so you get odd amounts as in TH!
      local lose_value = prices.HospValuePenalty * math.random(1, 15)  
      self:addAward(_S.trophy_room.hosp_value.penalty[1], "reputation", lose_value)
      self.rep_amount = self.rep_amount + lose_value
    end

    -- Should these next few be linked so that you can only get one or should you get more than one if you met the targets?

    -- Cures
    if hosp.num_cured_ty > prices.CuresAward then
      self:addAward(_S.trophy_room.many_cured.awards[math.random(1, 2)], "money", prices.CuresBonus)
      self.award_won_amount = self.award_won_amount + prices.CuresBonus
    elseif hosp.num_cured_ty < prices.CuresPoor then
      self:addAward(_S.trophy_room.many_cured.penalty[math.random(1, 2)], "money", prices.CuresPenalty)
      self.award_won_amount = self.award_won_amount + prices.CuresPenalty
    end

    -- Deaths
    if hosp.num_deaths_this_year < prices.DeathsAward then
      self:addAward(_S.trophy_room.no_deaths.awards[math.random(1, 2)], "money", prices.DeathsBonus)
      self.award_won_amount = self.award_won_amount + prices.DeathsBonus
    elseif hosp.num_deaths_this_year > prices.DeathsPoor then
      self:addAward(_S.trophy_room.no_deaths.penalty[math.random(1, 2)], "money", prices.DeathsPenalty)
      self.award_won_amount = self.award_won_amount + prices.DeathsPenalty
    end

    -- Cures V Deaths
    -- This value is not really a ratio since the level files cannot contain decimal values.
    local cure_ratio = 100
    if hosp.num_deaths_this_year > 0 then
      cure_ratio = hosp.num_cured_ty / hosp.num_deaths_this_year
    end
    if cure_ratio > prices.CuresVDeathsAward then
      self:addAward(_S.trophy_room.curesvdeaths.awards[1], "money", prices.CuresVDeathsBonus)
      self.award_won_amount = self.award_won_amount + prices.CuresVDeathsBonus
    elseif cure_ratio <= prices.CuresVDeathsPoor then
      self:addAward(_S.trophy_room.curesvdeaths.penalty[1], "money", prices.CuresVDeathsPenalty)
      self.award_won_amount = self.award_won_amount + prices.CuresVDeathsPenalty
    end
  end
end

function UIAnnualReport:updateAwards()
  -- Now apply the won/lost values.
  local hosp = self.ui.hospital
  if self.won_amount ~= 0 then
    hosp:receiveMoney(self.won_amount, _S.transactions.eoy_trophy_bonus)
  end
  if self.award_won_amount ~= 0 then
    hosp:receiveMoney(self.award_won_amount, _S.transactions.eoy_bonus_penalty)
  end
  if self.rep_amount ~= 0 then
    hosp:changeReputation("year_end", nil, math.floor(self.rep_amount))
  end
end  
    
-- A table defining which type of shadow each award should have.
local award_shadows = {
  { shadow = 4 },
  { shadow = 4 },
  { shadow = 4 },
  { shadow = 7 },
  { shadow = 7 },
  { shadow = 9 },
}

-- Another table defining some properties of the three trophies.
local trophy_prop = {
  {
    sprite = 12,
    x = 142,
    y = 324,
    w = 61,
    h = 144,
  },
  {
    sprite = 14,
    x = 466,
    y = 331,
    w = 72,
    h = 145,
  },
  {
    sprite = 13,
    x = 407,
    y = 324,
    w = 60,
    h = 144,
  },
}

--! Adds a trophy figure with some text if the player clicks on it.
--!param text (string) The text to show as motivation.
--!param award_type (string) Should be one of "reputation" or "money"
--!param amount (integer) How much the player got/lost.
function UIAnnualReport:addTrophy(text, award_type, amount)
  local no = self.no_trophies + 1
  -- Only show up to three trophies visually.
  if no <= 3 then
    local prop = trophy_prop[no]
    -- The actual figure and a button on it.
    local trophy_parts = {}
    trophy_parts.is_table = true
    -- Insert the info for later reference
    trophy_parts.info = {
      text = text,
      award_type = award_type,
      amount = amount
    }

    local --[[persistable:annual_report_show_trophy_motivation]] function change() self:showTrophyMotivation(no) end
    trophy_parts[1] = self:addPanel(prop.sprite, prop.x, prop.y)
    trophy_parts[2] = trophy_parts[1]:makeButton(0, 0, prop.w, prop.h, prop.sprite, change)

    self:setActive(trophy_parts, false)
    self.trophies[no] = trophy_parts
  end
  self.no_trophies = no
end

--! Adds an award frame with some text if the player clicks on it.
--!param text (string) The text to show as motivation.
--!param award_type (string) Should be one of "reputation" or "money"
--!param amount (integer) How much the player got/lost.
function UIAnnualReport:addAward(text, award_type, amount)
  -- How many awards the player has got up to this point.
  local no = self.no_awards + 1
  if no <= 6 then
    -- Only visually show the first six awards.
    -- Add them one column at a time from the left.
    local x = no <= 3 and 16 or 525
    local y = 74
    if no % 3 == 2 then
      y = 189
    elseif no % 3 == 0 then
      y = 304
    end
    local award_parts = {}
    award_parts.is_table = true
    -- Insert the info for later reference
    award_parts.info = {
      text = text,
      award_type = award_type,
      amount = amount
    }

    -- The plaque
    if amount > 0 then
      -- A positive award
      award_parts[1] = self:addPanel(10, x + 12, y + 11)
    else
      -- A bad award
      award_parts[1] = self:addPanel(11, x + 12, y + 11)
    end
    -- The frame
    award_parts[2] = self:addPanel(23, x, y)
    -- The shadow
    award_parts[3] = self:addPanel(award_shadows[no].shadow, x, y)
    -- Make a button so that the player can click and see the motivation
    local --[[persistable:annual_report_show_award_motivation]] function change() self:showAwardMotivation(no) end
    award_parts[4] = award_parts[3]:makeButton(0, 0, 105, 103, award_shadows[no].shadow, change)
    self.awards[no] = award_parts
    self:setActive(award_parts, false)
  end

  -- The economic part of the award.
  self.no_awards = no
end

--! Activates the motivation scroll with the given text on it.
--!param text_index_to_show The index of the award to show info from.
function UIAnnualReport:showAwardMotivation(text_index_to_show)
  if text_index_to_show then
    -- Make sure no trophy motivation is shown
    self:showTrophyMotivation()
    self:setActive(self.scroll, true)
    -- Possibly hide the black award symbol
    if self.awards[text_index_to_show].info.amount > 0 then
      self:setActive(self.scroll[4], false)
    end
    self:setActive(self.fourth_close, true)
    self:setActive(self.third_change, false)
    self.award_motivation = text_index_to_show
  else
    self:setActive(self.scroll, false)
    self:setActive(self.fourth_close, false)
    self:setActive(self.third_change, true)
    self.award_motivation = nil
  end
end

--! Activates the motivation plaque with the given text on it.
--!param text_index_to_show The index of the trophy to show info from.
function UIAnnualReport:showTrophyMotivation(text_index_to_show)
  if text_index_to_show then
    -- Make sure no award motivation is shown
    self:showAwardMotivation()
    self:setActive(self.plaque, true)
    self:setActive(self.third_close, true)
    self:setActive(self.third_change, false)
    self.trophy_motivation = text_index_to_show
  else
    self:setActive(self.plaque, false)
    self:setActive(self.third_close, false)
    self:setActive(self.third_change, true)
    self.trophy_motivation = nil
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
  if TheApp.world:getLocalPlayerHospital().game_won then
    if not TheApp.world:isCurrentSpeed("Pause") then
      TheApp.world:setSpeed("Pause")
      TheApp.video:setBlueFilterActive(false)
    end
    TheApp.world.ui.bottom_panel:openLastMessage()
  elseif TheApp.world:isCurrentSpeed("Pause") then
    TheApp.world:setSpeed(TheApp.world.prev_speed)
  end
  self:updateAwards()
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
    for i, _ in ipairs(self.trophies) do
      self:setActive(self.trophies[i], false)
    end
    for i, _ in ipairs(self.awards) do
      self:setActive(self.awards[i], false)
    end
    self.state = 2
  else -- Awards and trophies
    self.background = self.award_background
    self:setActive(self.third_change, true)
    self:setActive(self.second_change, false)
    -- Show awards given.
    for i, _ in ipairs(self.awards) do
      self:setActive(self.awards[i], true)
    end
    -- And trophies given.
    for i, _ in ipairs(self.trophies) do
      self:setActive(self.trophies[i], true)
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
  else -- Award and trophy screen
    -- Write out motivation if appropriate
    if self.trophy_motivation then
      -- If it is a plaque showing we write in stone text.
      local info = self.trophies[self.trophy_motivation].info
      self.stone_font:drawWrapped(canvas, info.text, x + 225, y + 105, 185, "center")
      -- Type of award
      local award_type = _S.trophy_room.cash
      if info.award_type == "reputation" then
        award_type = _S.trophy_room.reputation
      end
      self.stone_font:draw(canvas, award_type, x + 220, y + 330, 200, 0)
      -- Amount won/lost
      self.stone_font:draw(canvas, "+" .. info.amount, x + 220, y + 355, 200, 0)
    elseif self.award_motivation then
      local info = self.awards[self.award_motivation].info
      self.write_font:drawWrapped(canvas, info.text, x + 235, y + 125, 165, "center")
      -- Type of award
      local award_type = _S.trophy_room.cash
      if info.award_type == "reputation" then
        award_type = _S.trophy_room.reputation
      end
      self.write_font:draw(canvas, award_type, x + 220, y + 290, 200, 0)
      -- The amount won/lost
      local text = ""
      if info.amount > 0 then
        text = "+"
      end
      self.write_font:draw(canvas, text .. info.amount, x + 220, y + 315, 200, 0)
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
