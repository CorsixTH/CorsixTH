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

--! The weighted reputation accounting of the original game.
--!
--! The original never adjusts the reputation a player sees. It keeps an
--! accumulated credit and an accumulated weight, and the rating is calculated
--! from the two:
--!
--!     rating = clamp(trunc(500 * credit / weight), 0, 1000)
--!
--! with a neutral 500 whenever the weight is not positive. Both start at 20, so
--! a new hospital opens at 500, and the non-zero starting weight is a buffer:
--! the first patient a hospital takes on moves it a long way, and the same
--! event matters less and less as the hospital grows. A single credit is worth
--! 500/weight points, so +1 credit is about +25 at weight 20 and about +2 at
--! weight 250.
--!
--! Two consequences of the model are easy to get wrong:
--!
--!   - Registering a patient raises the weight without raising credit, so
--!     reputation can *fall* without anything bad happening. That is the whole
--!     of the decline a hospital sees while it is taking on more work than it
--!     has yet cured.
--!   - Percentage events change credit by a percentage *of the weight*, not of
--!     the rating, and the figure truncates toward zero. A +4% event at weight
--!     20 is worth exactly nothing.
--!
--! The weight is only ever raised, so a rating that cannot be reached by
--! arithmetic should be treated as a bug in the caller rather than clamped
--! silently here.

class "ReputationAccount"

---@class ReputationAccount
---@operator call: ReputationAccount
local ReputationAccount = _G["ReputationAccount"] ---@type ReputationAccount

-- The event identifiers, named for the call sites that use them.
ReputationAccount.event_patient_registered = 1
ReputationAccount.event_patient_diagnosed = 2
ReputationAccount.event_patient_cured = 3
ReputationAccount.event_patient_death = 4
ReputationAccount.event_machine_explosion = 5
ReputationAccount.event_emergency_won = 6
ReputationAccount.event_emergency_lost = 7
ReputationAccount.epidemic_gave_up = 8
ReputationAccount.epidemic_inspection_failed = 9
ReputationAccount.event_vip_best = 10
ReputationAccount.event_vip_middle = 11
ReputationAccount.event_vip_poor = 12
ReputationAccount.event_autopsy_discovered = 13

-- The neutral starting accounting. 20/20 gives 500, and the starting weight
-- keeps the first events from dominating the rating.
ReputationAccount.start_credit = 20
ReputationAccount.start_weight = 20

-- The bounds of the rating the panel displays, and the value used when there is
-- no weight to divide by.
ReputationAccount.rating_min = 0
ReputationAccount.rating_max = 1000
ReputationAccount.rating_neutral = 500

-- How each reputation event changes the accounting. An event describes at most
-- one of each kind of change, and the three are cumulative:
--
--   credit    a flat signed change to credit
--   weight    a flat signed change to weight
--   percent   a change to credit worth this percentage of the weight the event
--             scales from, truncated toward zero
--   amount    the caller's own signed figure multiplies `percent`
--
local event_changes = {
  [ReputationAccount.event_patient_registered] = {weight = 1}, -- a patient is registered
  [ReputationAccount.event_patient_diagnosed] = {credit = 1}, -- a diagnosis is newly established
  [ReputationAccount.event_patient_cured] = {credit = 1}, -- a patient is cured
  [ReputationAccount.event_patient_death] = {credit = -1}, -- a patient dies
  [ReputationAccount.event_machine_explosion] = {percent = -10}, -- machine disaster
  [ReputationAccount.event_emergency_won] = {percent = 2}, -- emergency met its cure requirement
  [ReputationAccount.event_emergency_lost] = {percent = -4, amount = true}, -- emergency fell short
  [ReputationAccount.epidemic_gave_up] = {percent = -2}, -- epidemic reported and fined
  [ReputationAccount.epidemic_inspection_failed] = {percent = -10}, -- severe concealed-epidemic inspection
  [ReputationAccount.event_vip_best] = {percent = 4}, -- best VIP outcome
  [ReputationAccount.event_vip_middle] = {percent = 2}, -- middle VIP outcome
  [ReputationAccount.event_vip_poor] = {percent = -4}, -- poor VIP outcome
  [ReputationAccount.event_autopsy_discovered] = {percent = -20}, -- an autopsy is discovered
}

--! Truncate toward zero, as the original's integer division does.
--!math.floor rounds toward negative infinity, which would turn -2.5 into -3
--! rather than -2, and bias every negative percentage event.
--!param value (number) The value to truncate
--!return (integer) The value with its fraction discarded, toward zero
local function trunc(value)
  if value < 0 then
    return -math.floor(-value)
  end
  return math.floor(value)
end

--! The rating a given credit and weight produce.
--!param credit (integer) The accumulated credit
--!param weight (integer) The accumulated weight
--!return (integer) The rating, 0 to 1000
function ReputationAccount.calculate(credit, weight)
  if weight <= 0 then
    return ReputationAccount.rating_neutral
  end

  local rating = trunc(500 * credit / weight)
  if rating < ReputationAccount.rating_min then
    return ReputationAccount.rating_min
  elseif rating > ReputationAccount.rating_max then
    return ReputationAccount.rating_max
  end
  return rating
end

--! The change an event makes to the accounting.
--!
--! The delta is calculated from the weight *before* the event, and it is
--! returned rather than applied so that the same figure can be given to the
--! hospital and, when the event names a disease, to that disease. Their two
--! histories differ, so the same delta produces two different rating changes.
--!
--! The weight to scale from is the caller's choice. Percentage events use the
--! hospital's weight.
--!param event (integer) The event identifier, 0 to 24
--!param weight (integer) The weight to scale a percentage event from
--!param amount (integer) The caller's signed figure, for the events that use one
--!return (integer, integer) The change to credit and the change to weight
function ReputationAccount.eventDelta(event, weight, amount)
  local change = event_changes[event]
  if not change then
    error("Unknown reputation event: " .. tostring(event))
  end

  local delta_credit = change.credit or 0
  local delta_weight = change.weight or 0

  if change.percent then
    local percent = change.percent
    if change.amount then
      percent = percent * (amount or 0)
    end
    delta_credit = delta_credit + trunc(percent * weight / 100)
  end

  return delta_credit, delta_weight
end

--! The credit that moves a rating by a given number of points.
--!
--! The rating is `500 * credit / weight`, so one point of rating is worth
--! `weight / 500` of credit.
--!param points (integer) The signed number of rating points
--!param weight (integer) The weight to convert against
--!return (integer) The change to credit that moves the rating by that much
function ReputationAccount.pointsToCredit(points, weight)
  return trunc(points * weight / ReputationAccount.rating_neutral)
end

--! A credit and weight that show a given rating at a plausible scale.
--!
--! Calculate a credit and a weight based on a known rating and outcomes.
--!param rating (integer) The rating to reproduce, defaulting to neutral
--!param outcomes (integer) How many outcomes have been seen, which sets the
--! scale.
--!return (integer, integer) The credit and the weight to restore
function ReputationAccount.accountingForRating(rating, outcomes)
  rating = rating or ReputationAccount.rating_neutral

  local weight = ReputationAccount.start_weight + math.max(0, outcomes or 0)

  -- Solve the credit that gives this weight the wanted ratio, then try the
  -- neighbouring integers either side, because the rating truncates and the
  -- exact figure is often not reachable.
  local solved = rating * weight / ReputationAccount.rating_neutral
  local best_credit, best_gap
  for _, credit in ipairs({math.floor(solved + 0.5), math.floor(solved), math.ceil(solved)}) do
    if credit >= 0 then
      local gap = math.abs(ReputationAccount.calculate(credit, weight) - rating)
      if not best_gap or gap < best_gap then
        best_credit, best_gap = credit, gap
      end
    end
  end

  return best_credit, weight
end

--! Create an account.
--!param credit (integer) The starting credit, defaulting to 20
--!param weight (integer) The starting weight, defaulting to 20
function ReputationAccount:ReputationAccount(credit, weight)
  self.credit = credit or ReputationAccount.start_credit
  self.weight = weight or ReputationAccount.start_weight
end

--! The rating this account currently shows.
--!return (integer) The rating, 0 to 1000
function ReputationAccount:rating()
  return ReputationAccount.calculate(self.credit, self.weight)
end

--! Move the accounting by a given amount.
--!param delta_credit (integer) The change to credit
--!param delta_weight (integer) The change to weight
--!return (integer) The rating after the change
function ReputationAccount:applyDelta(delta_credit, delta_weight)
  self.credit = self.credit + delta_credit
  self.weight = self.weight + (delta_weight or 0)
  return self:rating()
end

--! Apply one reputation event to this account.
--!param event (integer) The event identifier, 0 to 24
--!param weight (integer) The weight to scale a percentage event from
--!param amount (integer) The caller's signed figure, for the events that use one
--!return (integer) The rating after the event
function ReputationAccount:applyEvent(event, weight, amount)
  local delta_credit, delta_weight = ReputationAccount.eventDelta(event, weight, amount)
  return self:applyDelta(delta_credit, delta_weight)
end
