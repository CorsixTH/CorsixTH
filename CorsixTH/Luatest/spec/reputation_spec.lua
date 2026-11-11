--[[ Copyright (c) 2026 Artem Argus "ARGAMX" Gusakov

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
require("reputation")

local ReputationAccount = _G["ReputationAccount"]

describe("reputation.lua: ", function()
  -- The four sequences below are measurements the results of observations
  -- of the original game They are the ground truth this module has
  -- to reproduce: question of what a cure is worth.
  --
  -- The three actions a patient takes, as the model reads them.
  local function arrive()
    -- Nothing at all. A patient's arrival does not register them; that happens
    -- at diagnosis or on departure.
  end

  local function registerPatient(account)
    account:applyEvent(ReputationAccount.event_patient_registered, account.weight)
  end

  local function diagnose(account)
    -- A newly established diagnosis credits +1 and also registers the patient,
    -- which raises the weight. The two together can move the rating either way.
    account:applyEvent(ReputationAccount.event_patient_diagnosed, account.weight)
    registerPatient(account)
  end

  local function cure(account)
    account:applyEvent(ReputationAccount.event_patient_cured, account.weight)
  end

  local function leaveUntreated(account)
    registerPatient(account)
  end

  describe("rating calculation", function()
    it("starts at the neutral rating", function()
      assert.are.same(500, ReputationAccount():rating())
      assert.are.same(20, ReputationAccount().credit)
      assert.are.same(20, ReputationAccount().weight)
    end)

    it("is the credit over the weight, scaled to 500", function()
      assert.are.same(500, ReputationAccount.calculate(100, 100))
      assert.are.same(250, ReputationAccount.calculate(50, 100))
      assert.are.same(750, ReputationAccount.calculate(150, 100))
    end)

    it("truncates the ratio rather than rounding it", function()
      -- 500 * 24 / 23 is 521.7, and the original truncates toward zero.
      assert.are.same(521, ReputationAccount.calculate(24, 23))
      assert.are.same(525, ReputationAccount.calculate(21, 20))
      assert.are.same(476, ReputationAccount.calculate(20, 21))
      -- 500 * 26 / 24 is 541.7.
      assert.are.same(541, ReputationAccount.calculate(26, 24))
    end)

    it("falls back to neutral when the weight is not positive", function()
      assert.are.same(500, ReputationAccount.calculate(0, 0))
      assert.are.same(500, ReputationAccount.calculate(40, 0))
      -- Defensive: the original never reduces weight in normal play, but its
      -- evaluator guards against it rather than dividing.
      assert.are.same(500, ReputationAccount.calculate(40, -5))
    end)

    it("clamps the rating to the display bounds", function()
      assert.are.same(0, ReputationAccount.calculate(-50, 20))
      assert.are.same(0, ReputationAccount.calculate(-1, 20))
      assert.are.same(1000, ReputationAccount.calculate(100, 20))
    end)

    it("keeps the accounting when the rating is clamped", function()
      local account = ReputationAccount()
      -- A discovered autopsy costs a fifth of the weight, which is four credit
      -- at this hospital's weight of 20. Six of them take the credit negative.
      for _ = 1, 6 do
        account:applyEvent(ReputationAccount.event_autopsy_discovered, account.weight)
      end

      assert.are.same(0, account:rating())
      -- The rating is pinned, but the history behind it is not discarded, and a
      -- later cure still moves the hospital back up.
      assert.are.same(-4, account.credit)
      assert.are.same(20, account.weight)
      account:applyEvent(ReputationAccount.event_patient_cured, account.weight)
      assert.are.same(-3, account.credit)
    end)
  end)

  describe("event deltas", function()
    it("credits one point for a cure and for a new diagnosis", function()
      assert.are.same(1, ReputationAccount.eventDelta(ReputationAccount.event_patient_cured, 20))
      assert.are.same(1, ReputationAccount.eventDelta(ReputationAccount.event_patient_diagnosed, 20))
    end)

    it("credits one point for a death, and weights nothing", function()
      local delta_credit, delta_weight = ReputationAccount.eventDelta(ReputationAccount.event_patient_death, 20)
      assert.are.same(-1, delta_credit)
      assert.are.same(0, delta_weight)
    end)

    it("raises only the weight for a registration", function()
      local delta_credit, delta_weight = ReputationAccount.eventDelta(ReputationAccount.event_patient_registered, 20)
      assert.are.same(0, delta_credit)
      assert.are.same(1, delta_weight)
    end)

    it("takes a percentage event from the weight, not from the rating", function()
      -- 10% of a weight of 100 is 10 credit, which is +50 rating.
      local account = ReputationAccount(100, 100)
      account:applyEvent(ReputationAccount.event_machine_explosion, account.weight)
      assert.are.same(90, account.credit)
      assert.are.same(450, account:rating())
    end)

    it("scales a percentage event down to nothing at low weight", function()
      -- 4% of 20 is 0.8, which truncates away. The original awards nothing here,
      -- which is why a small hospital can see a positive award do nothing at all.
      assert.are.same(0, (ReputationAccount.eventDelta(ReputationAccount.event_vip_best, 20)))
      assert.are.same(4, (ReputationAccount.eventDelta(ReputationAccount.event_vip_best, 100)))
    end)

    it("truncates a negative percentage toward zero", function()
      -- -2% of 20 is -0.4 and vanishes entirely; -5% of 30 is -1.5 and becomes
      -- -1, not the -2 that math.floor would give.
      assert.are.same(0, (ReputationAccount.eventDelta(ReputationAccount.epidemic_gave_up, 20)))
      -- -10% of 45 is -4.5, which becomes -4 and not the -5 math.floor gives.
      assert.are.same(-4, (ReputationAccount.eventDelta(ReputationAccount.event_machine_explosion, 45)))
      assert.are.same(-5, (ReputationAccount.eventDelta(ReputationAccount.event_machine_explosion, 50)))
    end)

    it("multiplies a percentage by the caller's figure", function()
      -- An emergency that fell one patient short costs four percent of the
      -- weight; two short costs eight.
      assert.are.same(-4, (ReputationAccount.eventDelta(ReputationAccount.event_emergency_lost, 100, 1)))
      assert.are.same(-8, (ReputationAccount.eventDelta(ReputationAccount.event_emergency_lost, 100, 2)))
      assert.are.same(0, (ReputationAccount.eventDelta(ReputationAccount.event_emergency_lost, 100, 0)))
    end)

    it("refuses an event it does not know", function()
      assert.has_error(function()
        ReputationAccount.eventDelta(25, 20)
      end)
      assert.has_error(function()
        ReputationAccount.eventDelta(-1, 20)
      end)
    end)
  end)

  describe("the original measurements", function()
    it("reproduces original test, a patient leaving untreated then three cures", function()
      local account = ReputationAccount()

      assert.are.same(500, account:rating())

      arrive()
      assert.are.same(500, account:rating())

      leaveUntreated(account)
      assert.are.same(476, account:rating())

      arrive()
      assert.are.same(476, account:rating())

      diagnose(account)
      assert.are.same(477, account:rating())

      cure(account)
      assert.are.same(500, account:rating())

      arrive()
      assert.are.same(500, account:rating())

      diagnose(account)
      assert.are.same(500, account:rating())

      cure(account)
      assert.are.same(521, account:rating())

      arrive()
      assert.are.same(521, account:rating())

      diagnose(account)
      assert.are.same(520, account:rating())

      cure(account)
      assert.are.same(541, account:rating())
    end)

    it("reproduces original test, three patients diagnosed and cured", function()
      local account = ReputationAccount()

      assert.are.same(500, account:rating())

      arrive()
      assert.are.same(500, account:rating())

      diagnose(account)
      assert.are.same(500, account:rating())

      cure(account)
      assert.are.same(523, account:rating())

      arrive()
      assert.are.same(523, account:rating())

      -- A diagnosis can lower the rating: the weight rises faster than the
      -- credit while the hospital is small.
      diagnose(account)
      assert.are.same(522, account:rating())

      cure(account)
      assert.are.same(545, account:rating())

      arrive()
      assert.are.same(545, account:rating())

      diagnose(account)
      assert.are.same(543, account:rating())

      cure(account)
      assert.are.same(565, account:rating())
    end)

    it("reproduces original test, five patients leaving one at a time", function()
      local account = ReputationAccount()
      assert.are.same(500, account:rating())

      leaveUntreated(account)
      assert.are.same(476, account:rating())
      leaveUntreated(account)
      assert.are.same(454, account:rating())
      leaveUntreated(account)
      assert.are.same(434, account:rating())
      leaveUntreated(account)
      assert.are.same(416, account:rating())
      leaveUntreated(account)
      assert.are.same(400, account:rating())
    end)

    it("reproduces original test, a patient refusing to pay", function()
      -- A refusal never reaches diagnosis or the departure path that carries the
      -- registration, so nothing is applied at all: not a credit change, and not
      -- the weight increase that a departure would have caused.
      local account = ReputationAccount()
      assert.are.same(500, account:rating())

      arrive()
      assert.are.same(500, account:rating())
      assert.are.same(500, account:rating())

      assert.are.same(20, account.credit)
      assert.are.same(20, account.weight)
    end)

    it("reproduces original test, a room destroyed after five patients", function()
      -- The reading that tells a percentage event apart from a flat penalty.
      --
      -- At a fresh hospital the two cannot be told apart, because a tenth of
      -- the weight is worth exactly fifty rating points whatever the weight is.
      -- Once five patients have registered the weight is 25 and they part by
      -- ten: a tenth of 25 truncates to 2 credit, which is 360, where a flat
      -- -50 would give 350.
      local account = ReputationAccount()
      assert.are.same(500, account:rating())

      for _ = 1, 5 do
        leaveUntreated(account)
      end
      assert.are.same(400, account:rating())

      account:applyEvent(ReputationAccount.event_machine_explosion, account.weight)
      assert.are.same(360, account:rating())
      assert.are.same(18, account.credit)
      assert.are.same(25, account.weight)
    end)
  end)

  describe("per-disease accounting", function()
    it("gives a disease its own history from the same starting point", function()
      local hospital = ReputationAccount()
      local disease = ReputationAccount()

      assert.are.same(500, hospital:rating())
      assert.are.same(500, disease:rating())

      -- One patient is treated for this disease and nothing else.
      diagnose(disease)
      cure(disease)

      assert.are.same(500, hospital:rating())
      assert.are.same(523, disease:rating())
    end)

    it("applies one delta to both, and lets them diverge", function()
      local hospital = ReputationAccount()
      local disease = ReputationAccount()

      -- The caller works out the delta once, from the weight the event scales
      -- from, and gives the same figures to both accounts.
      local delta_credit, delta_weight =
          ReputationAccount.eventDelta(ReputationAccount.event_patient_cured, hospital.weight)
      hospital:applyDelta(delta_credit, delta_weight)
      disease:applyDelta(delta_credit, delta_weight)

      assert.are.same(21, hospital.credit)
      assert.are.same(21, disease.credit)
      assert.are.same(525, hospital:rating())

      -- The same credit, but a disease that has seen more patients divides by a
      -- larger weight, so the two ratings pull apart from one delta.
      disease:applyDelta(0, 5)
      assert.are.same(420, disease:rating())
      assert.are.same(525, hospital:rating())
    end)
  end)

  describe("the shape of the model", function()
    it("makes one credit worth less as the hospital grows", function()
      local small = ReputationAccount(20, 20)
      local large = ReputationAccount(100, 100)

      assert.are.same(25, small:applyEvent(ReputationAccount.event_patient_cured, small.weight) - 500)
      assert.are.same(5, large:applyEvent(ReputationAccount.event_patient_cured, large.weight) - 500)
    end)

    it("never reduces the weight on its own", function()
      -- Only registration raises it, so weight is monotonic.
      local account = ReputationAccount()
      local before = account.weight

      for _, event in ipairs({
        ReputationAccount.event_patient_cured,
        ReputationAccount.event_patient_death,
        ReputationAccount.event_machine_explosion,
        ReputationAccount.event_autopsy_discovered,
        ReputationAccount.event_patient_diagnosed,
      }) do
        account:applyEvent(event, account.weight)
      end

      assert.are.same(before, account.weight)
    end)
  end)

  describe("reproducing a saved rating for an old savegame", function()
    it("reproduces a rating above neutral", function()
      -- The bug this covers: holding the credit at 20 gives 500 or below for
      -- every possible weight, so a hospital that saved at 990 came back at 500.
      for _, rating in ipairs({500, 520, 750, 900, 990, 1000}) do
        local credit, weight = ReputationAccount.accountingForRating(rating, 300)
        local restored = ReputationAccount.calculate(credit, weight)
        assert.are.same(rating, restored,
            "rating " .. rating .. " restored as " .. restored)
      end
    end)

    it("reproduces a rating below neutral", function()
      for _, rating in ipairs({0, 100, 250, 400, 476}) do
        local credit, weight = ReputationAccount.accountingForRating(rating, 300)
        local restored = ReputationAccount.calculate(credit, weight)
        assert.are.same(rating, restored,
            "rating " .. rating .. " restored as " .. restored)
      end
    end)

    it("lands within a few points across the whole range", function()
      -- Not every rating is reachable exactly, because it truncates. Sweep the
      -- range so that no band can quietly collapse the way the upper half did.
      for rating = 0, 1000 do
        local credit, weight = ReputationAccount.accountingForRating(rating, 300)
        local restored = ReputationAccount.calculate(credit, weight)
        assert.is_true(math.abs(restored - rating) <= 12,
            "rating " .. rating .. " came back as " .. restored)
      end
    end)

    it("still lands within a few points with no history to go on", function()
      -- Without a record of outcomes the weight falls back to its starting
      -- value, where the rating moves in steps of 25, so this is the coarsest
      -- case rather than the typical one.
      for rating = 0, 1000 do
        local credit, weight = ReputationAccount.accountingForRating(rating)
        local restored = ReputationAccount.calculate(credit, weight)
        assert.is_true(math.abs(restored - rating) <= 12,
            "rating " .. rating .. " came back as " .. restored)
      end
    end)

    it("sets the weight from the outcomes alone, whatever the rating", function()
      -- The weight is the scale, not the rating. Holding it fixed is what stops
      -- a rebuilt hospital behaving like a newborn one.
      for _, rating in ipairs({0, 250, 500, 900, 1000}) do
        local _, weight = ReputationAccount.accountingForRating(rating, 300)
        assert.are.same(320, weight, "weight for rating " .. rating)
      end
    end)

    it("treats a missing rating as neutral", function()
      local credit, weight = ReputationAccount.accountingForRating(nil)
      assert.are.same(ReputationAccount.rating_neutral,
          ReputationAccount.calculate(credit, weight))
    end)

    it("gives a long established hospital a weight its history implies", function()
      -- The weight is what the number of outcomes implies, so that one credit
      -- stays worth roughly what it is worth in play.
      local credit, weight = ReputationAccount.accountingForRating(1000, 300)
      assert.are.same(320, weight)
      assert.are.same(1000, ReputationAccount.calculate(credit, weight))

      local fresh_credit, fresh_weight = ReputationAccount.accountingForRating(1000, 0)
      assert.are.same(20, fresh_weight)
      assert.are.same(1000, ReputationAccount.calculate(fresh_credit, fresh_weight))
    end)

    it("does not bleed a high rating away over ordinary play", function()
      -- The bug this covers: a save at 1000 rebuilt at weight 20 fell towards
      -- neutral within twenty patients, purely as an artefact of the rebuild.
      -- At the weight its own history implies it barely moves.
      for _, rating in ipairs({700, 850, 1000}) do
        local account = ReputationAccount(
            ReputationAccount.accountingForRating(rating, 300))

        -- Thirty patients, each registered and cured: one weight, three credits.
        for _ = 1, 30 do
          account:applyDelta(2, 0)
          account:applyDelta(0, 1)
          account:applyDelta(1, 0)
        end

        assert.is_true(account:rating() >= rating - 10,
            "rating " .. rating .. " fell to " .. account:rating())
      end
    end)
  end)

  describe("converting a number of rating points into credit", function()
    --! A neutral account sitting at a given weight. Built through the real
    --! restoration path so the credit matches the weight, rather than forcing
    --! one without the other and landing on the 1000 clamp.
    local function accountAt(weight)
      return ReputationAccount(ReputationAccount.accountingForRating(
          ReputationAccount.rating_neutral, weight - ReputationAccount.start_weight))
    end

    --! The rating moved by converting and applying a signed number of points.
    --! Because credit is integral, one credit is worth 500/weight points, and
    --! the answer can only be that close.
    local function movedBy(weight, points)
      local account = accountAt(weight)
      local before = account:rating()
      account:applyDelta(ReputationAccount.pointsToCredit(points, weight), 0)
      return account:rating() - before
    end

    it("moves the rating by about that many points", function()
      -- Two truncations compound: one turning points into credit, one turning
      -- credit into the rating. So the answer is within one credit of rating,
      -- plus the rating's own discarded fraction.
      for _, weight in ipairs({20, 100, 320}) do
        local slack = ReputationAccount.rating_neutral / weight + 1
        for _, points in ipairs({1, 3, 15, 45, 90}) do
          for _, signed in ipairs({points, -points}) do
            assert.is_true(math.abs(movedBy(weight, signed) - signed) <= slack,
                "weight " .. weight .. ": asked for " .. signed ..
                ", moved " .. movedBy(weight, signed))
          end
        end
      end
    end)

    it("does not inflate a year-end award fivefold", function()
      -- The bug this covers: the configured award is a number of rating points
      -- (3 to 45, and -6 to -90), and handing it to the original's percentage
      -- award event turned 45 points into 225 and -90 into -450.
      for _, weight in ipairs({20, 100, 320, 640}) do
        local slack = ReputationAccount.rating_neutral / weight + 1
        assert.is_true(math.abs(movedBy(weight, 45) - 45) <= slack,
            "weight " .. weight .. ": award of 45 moved " .. movedBy(weight, 45))
        assert.is_true(math.abs(movedBy(weight, -90) + 90) <= slack,
            "weight " .. weight .. ": penalty of 90 moved " .. movedBy(weight, -90))
      end
    end)

    it("truncates toward zero, so a small award on a young hospital rounds away", function()
      -- A point is worth a twentieth of the weight at the starting weight of 20,
      -- so small awards lose their fraction. That is the model, not a defect.
      assert.are.same(0, ReputationAccount.pointsToCredit(2, 20))
      assert.are.same(1, ReputationAccount.pointsToCredit(25, 20))
      assert.are.same(-1, ReputationAccount.pointsToCredit(-25, 20))
    end)
  end)
end)
