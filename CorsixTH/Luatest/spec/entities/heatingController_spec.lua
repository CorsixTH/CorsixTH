--[[ Copyright (c) 2018  David Zingg

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


require("class_test_base")

require("entity")
require("HeatingController")
require("date")

class "FakeWorld"

local FakeWorld = _G["FakeWorld"]

function FakeWorld:FakeWorld(nbRadiators,disasterLaunch)
  self.object_counts = {
    extinguisher = 0,
    radiator = nbRadiators,
    plant = 0,
    reception_desk = 0,
    bench = 0,
    general = 0,
  }
  self.map = {
    level_config = 
    {
      gbv = {DisasterLaunch = disasterLaunch}
    }
  }
end

function FakeWorld:date()
  return Date(1,1)
end


describe("HeatingController:", function()
  it("check monthly heating costs", function()
    local heatingController = HeatingController(FakeWorld(10,100))
    
    assert.equal(375,heatingController:calculateExpectedMonthlyHeatingCosts())
    
    heatingController:setRadiatorHeat(1)
    assert.equal(750,heatingController:calculateExpectedMonthlyHeatingCosts())
    
    heatingController:setRadiatorHeat(0)
    assert.equal(0,heatingController:calculateExpectedMonthlyHeatingCosts())
    
    heatingController:setRadiatorHeat(2)
    assert.equal(750,heatingController:calculateExpectedMonthlyHeatingCosts())
    
    heatingController:setRadiatorHeat(-1)
    assert.equal(0,heatingController:calculateExpectedMonthlyHeatingCosts())
    
    heatingController:setRadiatorHeat(0.5)
    heatingController:increaseHeat()
    assert.equal(450,heatingController:calculateExpectedMonthlyHeatingCosts())
    heatingController:decreaseHeat()
    assert.equal(375,heatingController:calculateExpectedMonthlyHeatingCosts())
    
  end)
  
  it("check increase / decrease heating", function()
    local heatingController = HeatingController(FakeWorld(10,100))
    --start with heating 0.5
    
    heatingController:increaseHeat()
    assert.equal(0.6,heatingController:getRadiatorHeat())
    heatingController:decreaseHeat()
    assert.equal(0.5,heatingController:getRadiatorHeat())
    
    --set maximum heat and try to increase
    heatingController:setRadiatorHeat(1)
    heatingController:increaseHeat()
    assert.equal(1,heatingController:getRadiatorHeat())
    heatingController:decreaseHeat()
    assert.equal(0.9,heatingController:getRadiatorHeat())
    
    --set minimum heat and try to decrease
    heatingController:setRadiatorHeat(0.1)
    heatingController:decreaseHeat()
    assert.equal(0.1,heatingController:getRadiatorHeat())
    heatingController:increaseHeat()
    assert.equal(0.2,heatingController:getRadiatorHeat())
  end)
  
  it("check accumulated heatingcosts", function()
    local heatingController = HeatingController(FakeWorld(10,100))
    -- January 1st year
    -- no costs after 0 days
    assert.equal(0,heatingController:getHeatingCostsForActualMonth())

    heatingController:onEndDay(100,true)
    assert.equal(12,heatingController:getHeatingCostsForActualMonth())
    heatingController:onEndDay(100,true)
    heatingController:onEndDay(100,true)
    heatingController:onEndDay(100,true)
    heatingController:onEndDay(100,true)
    assert.equal(60,heatingController:getHeatingCostsForActualMonth())

    heatingController:onEndDay(100,true)
    -- round up after 6 days
    assert.equal(73,heatingController:getHeatingCostsForActualMonth())
    
    --check if 0 after reset
    heatingController:resetHeatingCostsForActualMonth()
    assert.equal(0,heatingController:getHeatingCostsForActualMonth())
  end)
  
  it("check Boiler Breakdown counter", function()
    -- 66% chance for boiler breakdown every 2nd day
    local heatingController = HeatingController(FakeWorld(10,3))

    assert.equal(3,heatingController.days_until_boiler_breakdown)

    -- no handyman, set player hospital to false to disable any messages which will cause fail of this test
    -- counter is 0 after 3 days
    heatingController:onEndDay(0,false)
    heatingController:onEndDay(0,false)
    heatingController:onEndDay(0,false)
    assert.equal(0,heatingController.days_until_boiler_breakdown)
    heatingController:onEndDay(0,false)

    --reset counter after breakdown
    assert.equal(3,heatingController.days_until_boiler_breakdown)
  end)

  it("check Boiler Breakdown and repair", function()
    -- 66% chance for boiler breakdown every 2nd day
    local heatingController = HeatingController(FakeWorld(10,3))

    --heating should work when start new game
    assert.equal(false,heatingController.heating_broke)
    heatingController:boilerBreakdown(false)
    assert.equal(true,heatingController.heating_broke)
    assert.are_not.equal(0.5,heatingController:getRadiatorHeat())

    heatingController:boilerFixed(false)
    assert.equal(false,heatingController.heating_broke)
    assert.equal(0.5,heatingController:getRadiatorHeat())

  end)
  
  it("check staff and patients warmth ", function()
    -- 66% chance for boiler breakdown every 2nd day
    local heatingController = HeatingController(FakeWorld(10,3))
    local OK_VALUE = 0.29
    local HOT_VALUE = 0.37
    local COLD_VALUE = 0.21

    assert.equal(false,heatingController.warmth_msg)
    
    --check if patiens feel ok
    heatingController:checkHeatingFacilities(false,15,OK_VALUE, OK_VALUE)
    assert.equal(false,heatingController.warmth_msg)
    
    --check if patiens feel too hot
    heatingController:checkHeatingFacilities(false,15,HOT_VALUE, HOT_VALUE)
    assert.equal(true,heatingController.warmth_msg)
    heatingController:resetWarmthMsgFlag()

    --check if patiens feel too cold
    heatingController:checkHeatingFacilities(false,15,COLD_VALUE, COLD_VALUE)
    assert.equal(true,heatingController.warmth_msg)
    heatingController:resetWarmthMsgFlag()

    --check if staff feel ok
    heatingController:checkHeatingFacilities(false,20,OK_VALUE, OK_VALUE)
    assert.equal(false,heatingController.warmth_msg)
    
    --check if staff feel too hot
    heatingController:checkHeatingFacilities(false,20,HOT_VALUE, HOT_VALUE)
    assert.equal(true,heatingController.warmth_msg)
    heatingController:resetWarmthMsgFlag()

    --check if staff feel too cold
    heatingController:checkHeatingFacilities(false,20,COLD_VALUE, COLD_VALUE)
    assert.equal(true,heatingController.warmth_msg)
  end)
end)
