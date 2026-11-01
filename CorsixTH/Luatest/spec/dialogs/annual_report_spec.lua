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

local Hospital = _G["Hospital"]
local Map = _G["Map"]

-- Replicate the trophy logic from annual_report.lua for testing
local function checkRatTrophies(hosp, prices)
  local trophies = {}
  local won_amount = 0
  local rep_amount = 0

  local anybody_cured = hosp.num_cured_ty > 1

  -- Rats Killed Trophy
  if anybody_cured and hosp.rats_killed_ty > prices.RatKillsAbsolute then
    local win_value = prices.RatKillsAbsoluteBonus
    table.insert(trophies, {award_type = "reputation", amount = win_value})
    rep_amount = rep_amount + win_value
  end

  -- Rats Accuracy Trophy (only if killed enough rats for absolute trophy)
  local min_for_accuracy = math.floor(prices.RatKillsAbsolute / 2)
  if anybody_cured and hosp.rats_killed_ty >= min_for_accuracy and hosp.rats_created_ty > 0 then
    local accuracy = math.floor((hosp.rats_killed_ty / hosp.rats_created_ty) * 100)
    if accuracy > prices.RatKillsPercentage then
      local win_value = prices.RatKillsPercentageBonus
      table.insert(trophies, {award_type = "money", amount = win_value})
      won_amount = won_amount + win_value
    end
  end

  return trophies, won_amount, rep_amount
end

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

describe("annual_report.lua - rat trophy logic: ", function()
  local prices
  local world
  local hospital

  before_each(function()
    hospital = createMockHospital()
    world = createMockWorld(hospital)
    prices = world.map.level_config.awards_trophies
  end)

  it("awards Rats Killed trophy when >25 rats killed", function()
    hospital.rats_killed_ty = 30
    hospital.rats_created_ty = 100

    local trophies = checkRatTrophies(hospital, prices)

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

    local trophies = checkRatTrophies(hospital, prices)

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

    local trophies = checkRatTrophies(hospital, prices)

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

    local trophies = checkRatTrophies(hospital, prices)

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

    local trophies = checkRatTrophies(hospital, prices)

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

    local trophies = checkRatTrophies(hospital, prices)

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

    local trophies = checkRatTrophies(hospital, prices)

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

    local trophies = checkRatTrophies(hospital, prices)

    local found = false
    for _, t in ipairs(trophies) do
      if t.award_type == "money" and t.amount == 5000 then
        found = true
      end
    end
    assert.is_true(found, "13% accuracy (floor) should award trophy")

    -- 12 kills / 100 created = 12% -> floor = 12 > 11 = should award
    hospital.rats_killed_ty = 12
    trophies = checkRatTrophies(hospital, prices)
    found = false
    for _, t in ipairs(trophies) do
      if t.award_type == "money" and t.amount == 5000 then
        found = true
      end
    end
    assert.is_true(found, "12% accuracy (floor) should award trophy")

    -- 11 kills / 100 created = 11% -> floor = 11, NOT > 11 = should NOT award
    hospital.rats_killed_ty = 11
    trophies = checkRatTrophies(hospital, prices)
    found = false
    for _, t in ipairs(trophies) do
      if t.award_type == "money" and t.amount == 5000 then
        found = true
      end
    end
    assert.is_false(found, "11% accuracy (floor) should NOT award trophy (not > 11)")
  end)
end)