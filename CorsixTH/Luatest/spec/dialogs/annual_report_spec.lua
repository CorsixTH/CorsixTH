--[[ Copyright (c) 2026

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

require("corsixth")
require("class_test_base")
require("utility")
require("map")
require("hospital")
require("window")
require("dialogs/fullscreen")
require("dialogs/fullscreen/annual_report")

local Hospital = _G["Hospital"]
local Map = _G["Map"]
local UIAnnualReport = _G["UIAnnualReport"]

-- Mock _S (strings) table with trophy text
_G._S = _G._S or {}
_G._S.trophy_room = _G._S.trophy_room or {}
_G._S.trophy_room.rats_killed = {trophies = {"Rats Killed Trophy 1", "Rats Killed Trophy 2", "Rats Killed Trophy 3"}}
_G._S.trophy_room.rats_accuracy = {trophies = {"Rats Accuracy Trophy 1", "Rats Accuracy Trophy 2", "Rats Accuracy Trophy 3"}}
_G._S.trophy_room.sold_drinks = {trophies = {"Drinks Trophy"}}
_G._S.trophy_room.happy_vips = {trophies = {"VIP Trophy"}}
_G._S.trophy_room.consistant_rep = {trophies = {"Rep Trophy"}}
_G._S.trophy_room.all_cured = {trophies = {"All Cured Trophy"}}
_G._S.trophy_room.no_deaths = {awards = {"No Deaths Award 1", "No Deaths Award 2"}, penalty = {"No Deaths Penalty 1", "No Deaths Penalty 2"}}
_G._S.trophy_room.many_cured = {awards = {"Many Cured Award 1", "Many Cured Award 2"}, penalty = {"Many Cured Penalty 1", "Many Cured Penalty 2"}}
_G._S.trophy_room.high_rep = {awards = {"High Rep Award"}, penalty = {"High Rep Penalty"}}
_G._S.trophy_room.hosp_value = {awards = {"Hosp Value Award"}, penalty = {"Hosp Value Penalty"}}
_G._S.trophy_room.curesvdeaths = {awards = {"CuresVDeaths Award"}, penalty = {"CuresVDeaths Penalty"}}
_G._S.trophy_room.wait_times = {award = {"Wait Times Award"}, penalty = {"Wait Times Penalty"}}
_G._S.trophy_room.happy_patients = {awards = {"Happy Patients Award"}, penalty = {"Happy Patients Penalty"}}
_G._S.trophy_room.pop_percentage = {awards = {"Pop Percentage Award"}, penalty = {"Pop Percentage Penalty"}}
_G._S.trophy_room.gen_repairs = {awards = {"Gen Repairs Award"}, penalty = {"Gen Repairs Penalty"}}
_G._S.trophy_room.healthy_plants = {awards = {"Healthy Plants Award"}, trophies = {"Healthy Plants Trophy"}}
_G._S.trophy_room.research = {awards = {"Research Award"}, penalty = {"Research Penalty"}}
_G._S.trophy_room.emergencies = {award = {"Emergencies Award"}, penalty = {"Emergencies Penalty"}}
_G._S.trophy_room.cash = "CASH"
_G._S.trophy_room.reputation = "REPUTATION"

local function createMockHospital(opts)
  opts = opts or {}
  local map = {
    th = {getCellFlags = function() return {roomId = 0, buildable = true} end},
    width = 10,
    height = 10,
    WorldToScreen = function(_, x, y) return x * 10, y * 10 end,
    level_config = {
      awards_trophies = {
        RatKillsAbsolute = 25,
        RatKillsPercentage = 11,
        RatKillsAbsoluteBonus = 5,
        RatKillsPercentageBonus = 5000,
        Reputation = 400,
        TrophyMayorBonus = 5,
        TrophyReputationBonus = 2000,
        CansofCoke = 100,
        CansofCokeBonus = 1000,
        ReputationAward = 600,
        ReputationPoor = 200,
        AwardReputationBonus = 1000,
        AwardReputationPenalty = -1000,
        HospValueAward = 100000,
        HospValuePoor = 10000,
        HospValueBonus = 100,
        HospValuePenalty = -100,
        CuresAward = 50,
        CuresPoor = 10,
        CuresBonus = 1000,
        CuresPenalty = -1000,
        DeathsAward = 5,
        DeathsPoor = 20,
        DeathsBonus = 1000,
        DeathsPenalty = -1000,
        AllCuresBonus = 2000,
        TrophyAllCuredBonus = 2000,
        TrophyDeathBonus = 1000,
        TrophyCuresBonus = 500,
        CuresVDeathsAward = 10,
        CuresVDeathsPoor = 2,
        CuresVDeathsBonus = 1000,
        CuresVDeathsPenalty = -1000,
      },
    },
  }
  setmetatable(map, {__index = Map})

  local hospital = setmetatable({
    ratholes = {},
    world = {
      map = map,
      date = function() return {year = function() return 0 end} end,
    },
    isInHospital = function() return true end,
    getWallsAround = function() return {} end,
    rats_killed = 0,
    rats_created = 0,
    rats_killed_ty = opts.rats_killed_ty or 0,
    rats_created_ty = opts.rats_created_ty or 0,
    rats_adviser_shown = false,
    reputation = 500,
    reputation_min = 0,
    reputation_max = 1000,
    has_impressive_reputation = true,
    num_visitors = 0,
    num_cured = 10,
    sodas_sold = 0,
    num_vips_ty = 0,
    pleased_vips_ty = 0,
    num_cured_ty = opts.num_cured_ty or 10,
    not_cured_ty = 0,
    num_visitors_ty = 0,
    num_deaths_this_year = 0,
    value = 50000,
  }, {__index = Hospital})

  return hospital
end

local function createMockWorld(hospital)
  return setmetatable({
    map = hospital.world.map,
    hospitals = {hospital},
    date = function() return {year = function() return 0 end} end,
  }, {__index = {}})
end

local function createMockAnnualReport(hospital)
  local mock_ui = {
    hospital = hospital,
    app = _G["TheApp"],
  }
  local report = setmetatable({
    ui = mock_ui,
    won_amount = 0,
    rep_amount = 0,
    award_won_amount = 0,
    trophies = {},
    no_trophies = 0,
    awards = {},
    no_awards = 0,
  }, {__index = UIAnnualReport})

  function report:addTrophy(text, award_type, amount)
    local no = self.no_trophies + 1
    -- Store all trophies for testing (real UI only shows first 3)
    self.trophies[no] = {
      info = {
        text = text,
        award_type = award_type,
        amount = math.floor(amount)
      }
    }
    self.no_trophies = no
  end

  function report:addAward(text, award_type, amount)
    local no = self.no_awards + 1
    if no <= 6 then
      self.awards[no] = {
        info = {
          text = text,
          award_type = award_type,
          amount = math.floor(amount)
        }
      }
    end
    self.no_awards = no
  end

  return report
end

describe("annual_report.lua - rat trophy logic: ", function()
  local world
  local hospital
  local report

  before_each(function()
    hospital = createMockHospital()
    world = createMockWorld(hospital)
    report = createMockAnnualReport(hospital)
  end)

  local function getRatTrophies()
    local result = {}
    for i = 1, report.no_trophies do
      local t = report.trophies[i]
      if t and t.info then
        table.insert(result, t.info)
      end
    end
    return result
  end

  it("awards Rats Killed trophy when >25 rats killed", function()
    hospital.rats_killed_ty = 30
    hospital.rats_created_ty = 100

    report:checkTrophiesAndAwards(world)

    local trophies = getRatTrophies()
    local found = false
    for _, t in ipairs(trophies) do
      if t.award_type == "reputation" and t.amount == 5 then
        found = true
      end
    end
    assert.is_true(found, "Rats Killed trophy should be awarded (+5 reputation)")
  end)

  it("does NOT award Rats Killed trophy when <=25 rats killed", function()
    hospital.rats_killed_ty = 25
    hospital.rats_created_ty = 100

    report:checkTrophiesAndAwards(world)

    local trophies = getRatTrophies()
    local found = false
    for _, t in ipairs(trophies) do
      if t.award_type == "reputation" and t.amount == 5 then
        found = true
      end
    end
    assert.is_false(found, "Rats Killed trophy should NOT be awarded at exactly 25")
  end)

  it("awards Rats Accuracy trophy when accuracy >11% and min kills met", function()
    hospital.rats_killed_ty = 30
    hospital.rats_created_ty = 100

    report:checkTrophiesAndAwards(world)

    local trophies = getRatTrophies()
    local found = false
    for _, t in ipairs(trophies) do
      if t.award_type == "money" and t.amount == 5000 then
        found = true
      end
    end
    assert.is_true(found, "Rats Accuracy trophy should be awarded (+$5000)")
  end)

  it("does NOT award Rats Accuracy trophy when accuracy <=11%", function()
    hospital.rats_killed_ty = 10
    hospital.rats_created_ty = 100

    report:checkTrophiesAndAwards(world)

    local trophies = getRatTrophies()
    local found = false
    for _, t in ipairs(trophies) do
      if t.award_type == "money" and t.amount == 5000 then
        found = true
      end
    end
    assert.is_false(found, "Rats Accuracy trophy should NOT be awarded at 10% accuracy")
  end)

  it("does NOT award Rats Accuracy trophy when min kills not met", function()
    hospital.rats_killed_ty = 10
    hospital.rats_created_ty = 100

    report:checkTrophiesAndAwards(world)

    local trophies = getRatTrophies()
    local found = false
    for _, t in ipairs(trophies) do
      if t.award_type == "money" and t.amount == 5000 then
        found = true
      end
    end
    assert.is_false(found, "Rats Accuracy trophy should NOT be awarded when min kills (12) not met")
  end)

  it("does NOT award Rats Accuracy trophy when no rats created", function()
    hospital.rats_killed_ty = 30
    hospital.rats_created_ty = 0

    report:checkTrophiesAndAwards(world)

    local trophies = getRatTrophies()
    local found = false
    for _, t in ipairs(trophies) do
      if t.award_type == "money" and t.amount == 5000 then
        found = true
      end
    end
    assert.is_false(found, "Rats Accuracy trophy should NOT be awarded when no rats created")
  end)

  it("requires anybody_cured (num_cured_ty > 1)", function()
    hospital.rats_killed_ty = 30
    hospital.rats_created_ty = 100
    hospital.num_cured_ty = 1

    report:checkTrophiesAndAwards(world)

    local trophies = getRatTrophies()
    local found = false
    for _, t in ipairs(trophies) do
      if t.award_type == "reputation" and t.amount == 5 then
        found = true
      end
    end
    assert.is_false(found, "Rats Killed trophy should NOT be awarded when nobody cured (num_cured_ty <= 1)")
  end)

  it("accuracy calculation uses floor", function()
    -- 13 kills / 100 created = 13% -> floor = 13 > 11 = should award
    hospital.rats_killed_ty = 13
    hospital.rats_created_ty = 100
    hospital.num_cured_ty = 10

    report:checkTrophiesAndAwards(world)

    local trophies = getRatTrophies()
    local found = false
    for _, t in ipairs(trophies) do
      if t.award_type == "money" and t.amount == 5000 then
        found = true
      end
    end
    assert.is_true(found, "13% accuracy (floor) should award trophy")

    -- 12 kills / 100 created = 12% -> floor = 12 > 11 = should award
    hospital.rats_killed_ty = 12
    report = createMockAnnualReport(hospital)
    report:checkTrophiesAndAwards(world)
    trophies = getRatTrophies()
    found = false
    for _, t in ipairs(trophies) do
      if t.award_type == "money" and t.amount == 5000 then
        found = true
      end
    end
    assert.is_true(found, "12% accuracy (floor) should award trophy")

    -- 11 kills / 100 created = 11% -> floor = 11, NOT > 11 = should NOT award
    hospital.rats_killed_ty = 11
    report = createMockAnnualReport(hospital)
    report:checkTrophiesAndAwards(world)
    trophies = getRatTrophies()
    found = false
    for _, t in ipairs(trophies) do
      if t.award_type == "money" and t.amount == 5000 then
        found = true
      end
    end
    assert.is_false(found, "11% accuracy (floor) should NOT award trophy (not > 11)")
  end)
end)