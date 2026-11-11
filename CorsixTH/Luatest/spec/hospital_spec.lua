--[[ Copyright (c) 2026 Joshua "gojomoso1" DeVries

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
require("reputation")

local Hospital = _G["Hospital"]
local ReputationAccount = _G["ReputationAccount"]

-- Hospital:humanoidDeath reaches updatePercentages, which uses math.round. The
-- game defines that in app.lua, which these tests do not load. Copy it, and only
-- if it is absent, so the real method can be driven rather than stubbed out.
if not math.round then
  math.round = function(input)
    return math.floor(input + 0.5)
  end
end

describe("hospital.lua: ", function()
  -- Build a minimal duck-typed hospital that reuses the real rathole/debug
  -- rat methods, with only the map and world primitives stubbed out.
  local function createHospital(opts)
    opts = opts or {}
    local map = {
      th = {getCellFlags = function() return {roomId = 0, buildable = true} end},
      width = 10,
      height = 10,
      WorldToScreen = function(_, x, y) return x * 10, y * 10 end,
    }
    setmetatable(map, {__index = Map})

    local rat_spawns = {}
    local hospital = setmetatable({
      ratholes = opts.ratholes or {},
      world = {
        map = map,
        newObject = function() return {} end,
        newEntity = function()
          return {
            setTile = function(_, x, y) rat_spawns[#rat_spawns + 1] = {x = x, y = y} end,
            setTilePositionSpeed = function() end,
            init = function() end,
          }
        end,
      },
      isInHospital = function() return true end,
      getWallsAround = opts.get_walls_around or function() return {} end,
    }, {__index = Hospital})
    return hospital, rat_spawns
  end

  it("does not spawn a debug rat when no rathole can be found or created", function()
    local hospital, rat_spawns = createHospital()
    hospital:makeDebugRat(0, 0, 100, 100)
    assert.are.equal(0, #rat_spawns)
  end)

  it("does not fall back to an off-screen rathole for the debug spawn", function()
    local off_screen_hole = {x = 50, y = 50, wall = "north"}
    local hospital, rat_spawns = createHospital({ratholes = {off_screen_hole}})
    hospital:makeDebugRat(0, 0, 10, 10)
    assert.are.equal(0, #rat_spawns)
  end)

  it("spawns from a newly created visible hole", function()
    local get_walls_around = function(_, x, y)
      if x == 1 and y == 1 then return {{wall = "north", parcel = 1}} end
      return {}
    end
    local hospital, rat_spawns = createHospital({get_walls_around = get_walls_around})
    hospital:makeDebugRat(0, 0, 100, 100)
    assert.are.equal(1, #rat_spawns)
    assert.are.equal(1, rat_spawns[1].x)
    assert.are.equal(1, rat_spawns[1].y)
  end)

  it("spawns from an existing visible hole without adding new ones", function()
    local hole_a = {x = 2, y = 2, wall = "north"}
    local hole_b = {x = 3, y = 3, wall = "west"}
    local hospital, rat_spawns = createHospital({ratholes = {hole_a, hole_b}})
    hospital:makeDebugRat(0, 0, 100, 100)
    assert.are.equal(2, #hospital.ratholes) -- no new holes were created
    assert.are.equal(1, #rat_spawns)
    assert.is_true((rat_spawns[1].x == hole_a.x and rat_spawns[1].y == hole_a.y) or
        (rat_spawns[1].x == hole_b.x and rat_spawns[1].y == hole_b.y))
  end)

  -- A minimal duck-typed hospital carrying just the reputation accounting, so
  -- that these tests describe the accounting rather than a whole hospital.
  local function createReputationHospital()
    local hospital = setmetatable({
      reputation_account = ReputationAccount(),
      disease_casebook = {},
      has_impressive_reputation = false,
      world = {map = {level_config = {}}},
    }, {__index = Hospital})
    hospital:updateReputation()
    return hospital
  end

  it("opens on the neutral rating", function()
    local hospital = createReputationHospital()
    assert.are.equal(20, hospital.reputation_account.credit)
    assert.are.equal(20, hospital.reputation_account.weight)
    assert.are.equal(500, hospital.reputation)
  end)

  it("drops the rating when a patient is registered", function()
    local hospital = createReputationHospital()
    hospital.disease_casebook.flu = {reputation_account = ReputationAccount()}

    hospital:registerPatient({disease = {id = "flu"}})

    -- Registration adds weight but no credit: 20 over 21, truncated.
    assert.are.equal(20, hospital.reputation_account.credit)
    assert.are.equal(21, hospital.reputation_account.weight)
    assert.are.equal(476, hospital.reputation)
  end)

  it("registers a patient only once", function()
    local hospital = createReputationHospital()
    hospital.disease_casebook.flu = {reputation_account = ReputationAccount()}
    local patient = {disease = {id = "flu"}}

    hospital:registerPatient(patient)
    hospital:registerPatient(patient)

    assert.are.equal(21, hospital.reputation_account.weight)
    assert.are.equal(21, hospital.disease_casebook.flu.reputation_account.weight)
  end)

  it("does not register a debug patient", function()
    local hospital = createReputationHospital()
    hospital:registerPatient({disease = {id = "flu"}, is_debug = true})
    assert.are.equal(20, hospital.reputation_account.weight)
  end)

  it("leaves the rating alone when a patient is diagnosed", function()
    -- A diagnosis is a credit and a weight together, which cancel at a neutral
    -- hospital. Registering without the credit drops it to 476 instead, which is
    -- what a fresh hospital did in game before this was caught.
    local hospital = createReputationHospital()
    hospital.disease_casebook.flu = {reputation_account = ReputationAccount()}

    hospital:recordDiagnosis({disease = {id = "flu"}})

    assert.are.equal(21, hospital.reputation_account.credit)
    assert.are.equal(21, hospital.reputation_account.weight)
    assert.are.equal(500, hospital.reputation)
  end)

  it("does not record a diagnosis for a debug patient", function()
    local hospital = createReputationHospital()
    hospital:recordDiagnosis({disease = {id = "flu"}, is_debug = true})
    assert.are.equal(20, hospital.reputation_account.credit)
    assert.are.equal(20, hospital.reputation_account.weight)
  end)

  it("registers a patient only once even across diagnosis and departure", function()
    local hospital = createReputationHospital()
    hospital.disease_casebook.flu = {reputation_account = ReputationAccount()}
    local patient = {disease = {id = "flu"}}

    hospital:recordDiagnosis(patient)
    hospital:registerPatient(patient)

    assert.are.equal(21, hospital.reputation_account.weight)
    assert.are.equal(21, hospital.reputation_account.credit)
  end)

  it("pulls a poorly regarded hospital up towards neutral on each diagnosis", function()
    -- Equal additions to credit and weight always move the ratio towards 1, so
    -- a diagnosis earns a hospital below 500 and costs one above it. This is the
    -- behaviour behind the 523 to 522 move observed in the original.
    local hospital = createReputationHospital()
    hospital.reputation_account:applyDelta(0, 20) -- 20 credit over 40 weight
    hospital:updateReputation()
    assert.are.equal(250, hospital.reputation)

    hospital:recordDiagnosis({disease = {id = "flu"}})

    assert.are.equal(256, hospital.reputation) -- 21 over 41, truncated
  end)

  it("registers a patient who dies without having been diagnosed", function()
    -- First send the death credit and then, if the patient was not
    -- already registered, registers them. Skipping the registration would make
    -- an undiagnosed death cost only a credit, which is the wrong shape.
    --
    -- Driven through Hospital:humanoidDeath rather than by calling the two
    -- events separately, so that removing either call from it fails the test.
    local hospital = createReputationHospital()
    hospital.disease_casebook.flu = {
      reputation_account = ReputationAccount(), fatalities = 0,
    }
    hospital.num_cured, hospital.num_deaths, hospital.not_cured = 0, 0, 0
    hospital.num_deaths_this_year = 0

    hospital:humanoidDeath({disease = {id = "flu"}})

    assert.are.equal(19, hospital.reputation_account.credit)
    assert.are.equal(21, hospital.reputation_account.weight)
  end)

  it("does not register twice when a diagnosed patient dies", function()
    local hospital = createReputationHospital()
    hospital.disease_casebook.flu = {
      reputation_account = ReputationAccount(), fatalities = 0,
    }
    hospital.num_cured, hospital.num_deaths, hospital.not_cured = 0, 0, 0
    hospital.num_deaths_this_year = 0
    local patient = {disease = {id = "flu"}}

    hospital:recordDiagnosis(patient)
    hospital:humanoidDeath(patient)

    -- Registered once, at diagnosis: 20 + 1 diagnosis credit - 1 death credit.
    assert.are.equal(20, hospital.reputation_account.credit)
    assert.are.equal(21, hospital.reputation_account.weight)
  end)

  it("raises the rating by one credit when a patient is cured", function()
    local hospital = createReputationHospital()
    hospital:reputationEvent(ReputationAccount.event_patient_cured, {id = "flu"})
    -- 21 over 20.
    assert.are.equal(525, hospital.reputation)
  end)

  it("keeps a separate accounting per disease", function()
    local hospital = createReputationHospital()
    hospital.disease_casebook.flu = {reputation_account = ReputationAccount()}
    hospital.disease_casebook.measles = {reputation_account = ReputationAccount()}

    hospital:reputationEvent(ReputationAccount.event_patient_cured, {id = "flu"})

    assert.are.equal(525, hospital.reputation)
    assert.are.equal(525, hospital:getDiseaseReputation("flu"))
    -- Untouched, so still neutral.
    assert.are.equal(500, hospital:getDiseaseReputation("measles"))
  end)

  it("has a pseudo disease follow the hospital", function()
    local hospital = createReputationHospital()
    -- A pseudo disease has no accounting of its own.
    hospital.disease_casebook.vaccination = {}

    hospital:reputationEvent(ReputationAccount.event_patient_cured)

    assert.are.equal(525, hospital.reputation)
    assert.are.equal(525, hospital:getDiseaseReputation("vaccination"))
  end)
end)
