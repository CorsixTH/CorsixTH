--[[ Copyright (c) 2024 Toby "tobylane"

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

-- The "Winning and Losing Conditions" section of level files uses Criteria
--   numbers from the order of this table. Any Criteria numbers higher than
--   the size of this table will be silently ignored.
--   Icon, icon_file, formats and two_tooltips are used in the progress report dialog.
local local_criteria_variable = {
  {name = "reputation",       icon = 10, formats = 2},
  {name = "balance",          icon = 11, formats = 2},
  {name = "percentage_cured", icon = 12, formats = 2},
  {name = "num_cured" ,       icon = 13, formats = 2},
  {name = "percentage_killed",icon = 14, formats = 2},
  {name = "value",            icon = 15, formats = 2}, -- Hospital value
    -- New criteria
  {name = "staff_happiness",  icon = 16, icon_file = "MPointer", formats = 2, two_tooltips = true},
  {name = "patient_happiness",icon = 18, icon_file = "MPointer", formats = 2, two_tooltips = true},
  {name = "months_played",    icon = 46, icon_file = "Font04V",  formats = 4, two_tooltips = true},
}

-- A table of functions for fetching criteria values that cannot be measured
-- directly from a hospital attribute of the same name.
local get_custom_criteria = {
  staff_happiness = function(hospital) return 100 * hospital:getAverageStaffAttribute("happiness", 0.5) end,
  patient_happiness = function(hospital) return 100 * hospital:getAveragePatientAttribute("happiness", 0.5) end,
  months_played = function(hospital) return hospital.world.game_date:getProgressInMonths() end,
}

class "EndConditions"
---@type EndConditions
local EndConditions = _G["EndConditions"]

--! Collect the end conditions for this level, if they exist
--!param level_config (table) The map's level_config, containing criteria.
--!param level_number (integer) The number of the map, if playing a campaign.
--!param freebuild (boolean) The free build status of the world
function EndConditions:EndConditions(level_config, level_number, freebuild)
  self.win_goals, self.lose_goals, self.highest_group = {}, {}, 0
  if freebuild then return end

  local start, town = {}
  if level_number and level_config.towns[level_number] then
    town = level_config.towns[level_number]
  else
    town = level_config.town
  end
  start.balance = town.StartCash
  start.reputation = town.StartRep

  self:_loadGoals(level_config.win_criteria, self.win_goals, start, true)
  self:_loadGoals(level_config.lose_criteria, self.lose_goals, start)
end

--! Load conditions (goals) to win and lose from the level config,
-- and store them in self.win_goals and self.lose_goals in their groups.
-- Put the highest number of group of conditions in self.highest_group.
-- These groups are often incomplete, possibly empty
-- ie more groups of conditions that lead to loss than win.
--!param criteria_tbl (table) The map's win or lose criteria.
--!param goals (table) The class table to fill
--!param start (table) The starting values of the hospital attributes
--!param win (boolean) If the win goals are being filled this time
function EndConditions:_loadGoals(criteria_tbl, goals, start, win)
  for _, values in pairs(criteria_tbl) do
    if local_criteria_variable[values.Criteria] then
      local crit_name = local_criteria_variable[values.Criteria].name
      if not goals[values.Group] then goals[values.Group] = {} end
      goals[values.Group][crit_name] = {
        name = crit_name,
        boundary = values.Bound,
        criterion = values.Criteria,
        max_min = values.MaxMin,
        icon = local_criteria_variable[values.Criteria].icon,
        icon_file = local_criteria_variable[values.Criteria].icon_file,
        formats = local_criteria_variable[values.Criteria].formats,
        two_tooltips = local_criteria_variable[values.Criteria].two_tooltips,
        start = start[crit_name] or 0,
      }
      if win then
        goals[values.Group][crit_name].win_value = values.Value
      else
        goals[values.Group][crit_name].lose_value = values.Value
      end
      if values.Group > self.highest_group then self.highest_group = values.Group end
    end
  end
end

--! Checks if the player has won or lost by meeting all of any one group.
--!param hospital (Hospital) The hospital of the tests.
--!return state (string) "win" or "nothing", or
--!return reason (string) If the player lost, the latest criteria met
--!return limit (number) If the player lost, the number limit which the player passed
function EndConditions:checkEndGame(hospital)
  -- If there are no goals at all, do nothing.
  if (not self.win_goals or #self.win_goals == 0) and
      (not self.lose_goals or #self.lose_goals == 0) then
    return "nothing"
  end
  for _, tbl in pairs(self.win_goals) do
    local score = self:_checkWinGroup(hospital, tbl)
    if score == 1 and hospital.loan == 0 then return "win" end
  end
  for _, tbl in pairs(self.lose_goals) do
    local reason, limit = self:_checkLoseGroup(hospital, tbl)
    if reason then return reason, limit end
  end

  -- No win or lose group was met, or player has a loan preventing a win
  return "nothing"
end

--! Generate table for the Progress Report dialog and progress advice.
--!param hospital (Hospital) The hospital of the tests.
--!param baseline_start (boolean) Use the start attribute for calculating progress, not boundary
--!return report_table (table) Maximum five fields (unless baseline_start) of
-- lose criteria with the smallest gap between current value and boundary,
-- then fill up to five (unlimited when baseline_start is true) with win criteria in the best group.
function EndConditions:generateReportTable(hospital, baseline_start)
  local count, lose_table, key_lose_goals_table, report_table, unique_criteria_set = 0, {}, {}, {}, {}
  local win_group = self.win_goals[self:_findBestWinGroup(hospital)] or {}

  -- Collect lose criteria over the boundary
  for group, tbl in pairs(self.lose_goals) do
    lose_table[group] = self:_checkLoseGroup(hospital, tbl, true, baseline_start)
  end
  -- Get the most relevant of each criterion in all groups
  for _, group_table in pairs(lose_table) do
    for crit_name, crit_table in pairs(group_table) do
      if not key_lose_goals_table[crit_name] or key_lose_goals_table[crit_name].gap > crit_table.gap then
        key_lose_goals_table[crit_name] = crit_table
      end
    end
  end
  -- Move into a numbered table
  for _, crit_table in pairs(key_lose_goals_table) do
    table.insert(report_table, crit_table)
    count = count + 1
  end
  -- Limit the table to five goals (unless generating advice), ordered by progress towards meeting the lose goal
  if count > 5 and not baseline_start then
    table.sort(report_table, function(a,b) return a.progress > b.progress end)
    for n = 6, #report_table do report_table[n] = nil end
  end

  -- Fill up the report table with win criteria not already present as lose criteria
  for _, crit in pairs(report_table) do unique_criteria_set[crit.name] = true end
  for i = 1, #local_criteria_variable do
    if count == 5 and not baseline_start then break end
    local name = local_criteria_variable[i].name
    if win_group[name] and not unique_criteria_set[name] then
      count = count + 1
      report_table[count] = win_group[name]
    end
  end

  -- Order by criteria number, as some criteria icons shouldn't be next to each other
  table.sort(report_table, function(a,b) return a.criterion < b.criterion end)
  return report_table
end

--!param hospital (Hospital) The hospital of the tests.
--!param lose_table (table) A group of lose conditions from level_config.
--!param report (boolean) Whether a report table will be returned.
--!param baseline_start (boolean) Use the start attribute for calculating progress, not boundary
--!return Losing criteria name and the limit breached,
-- or if report is true, the report table.
function EndConditions:_checkLoseGroup(hospital, lose_table, report, baseline_start)
  local report_table, met_count, total_count, reason, limit = {}, 0, 0
  for crit_name, crit_table in pairs(lose_table) do
    local boundary = baseline_start and crit_table.start or crit_table.boundary
    local lose_value = crit_table.lose_value
    local max_min = crit_table.max_min == 1 and 1 or -1
    local measure = self:getAttribute(hospital, crit_name)
    if report then -- Collect the criteria that should be reported on
      if (measure - boundary) * max_min > 0 then
        report_table[crit_name] = crit_table
        report_table[crit_name].progress = (1 - ((measure - lose_value)/(boundary - lose_value)))
      end
    else
      if (measure - lose_value) * max_min > 0 then
        reason, limit = crit_name, lose_value
        met_count = met_count + 1
      end
    end
    total_count = total_count + 1
  end
  if report then return report_table end
  -- Have all criteria of the group been met?
  if met_count == total_count then
    -- The latest, probably only, criterion met for the lose message
    return reason, limit
  end
end

--!param hospital (Hospital) The hospital of the tests.
--!param win_table (table) A group of win conditions from level_config
--!return (number 0-1) The score of this group. 0 is no goals met, 1 is all met
function EndConditions:_checkWinGroup(hospital, win_table)
  local met_count, total_count = 0, 0
  for crit_name, crit_table in pairs(win_table) do
    local max_min = crit_table.max_min == 1 and 1 or -1
    if (self:getAttribute(hospital, crit_name) - crit_table.win_value) * max_min >= 0 then
      met_count = met_count + 1
    end
    total_count = total_count + 1
  end
  if met_count > 0 then
    return met_count / total_count
  else return 0
  end
end

-- Find the group of win conditions best met by the hospital.
--!param hospital (Hospital) The hospital of the tests.
--!return best (number) The number of the best group.
function EndConditions:_findBestWinGroup(hospital)
  local score, best = 0, 1
  for group = 1, self.highest_group do
    if self.win_goals[group] then
      local test = self:_checkWinGroup(hospital, self.win_goals[group])
      if test and test > score then best = group end
    end
  end
  -- Return the group number of the group that is most met by the hospital
  return best
end

-- Fetch the attribute value, through the get_custom_criteria table of
--  functions if there is one for this attribute.
function EndConditions:getAttribute(hospital, attribute)
  if get_custom_criteria[attribute] then
    return get_custom_criteria[attribute](hospital)
  else
    return hospital[attribute]
  end
end

-- Judge the hospital on the criterion from lose to win
-- Return the judgement as an integer on a scale of -3 to +4
local function progress(measure, target, start)
  if measure == target then return 0 end
  if start then
    measure = measure - start
    target = target - start
  end
  local score = math.floor(measure / target * 4)
  return math.min(math.max(-3, score), 4)
end

-- Map criteria and progress score to strings
local advice = {
  generic = {
    [-3] = { "three_quarters_lost", "hospital_is_rubbish" },
    [-2] = { "halfway_lost" },
    [2] = { "halfway_won" },
    [3] = { "three_quarters_won" },
  },
  reputation = {
    [4] = { "reputation_good_enough" },
    [-1] = { "improve_reputation" },
  },
  balance = {
    [4] = { "financial_criteria_met" },
    [-1] = { "money_low", "cash_low_consider_loan", "financial_trouble" },
    [-2] = { "finanical_trouble2", "money_very_low_take_loan" },
    [-3] = { "bankruptcy_imminent", "financial_trouble3" },
  },
  percentage_cured = {
  },
  num_cured = {
    [4] = { "cured_enough_patients" },
  },
  percentage_killed = {
   [-3] = { "dont_kill_more_patients" },
  },
  value = {
    [4] = { "hospital_value_enough" },
    [3] = { "close_to_win_increase_value" },
  },
  staff_happiness = {
    [-2] = { "staff_unhappy" },
    [-3] = { "staff_unhappy2" },
  },
  patient_happiness = {
    [-2] = { "patients_unhappy" },
    [-3] = { "patients_annoyed" },
  },
}

-- These advice strings come from _A.warnings, everything else from _A.level_progress
local warnings = list_to_set({ "money_low", "cash_low_consider_loan", "financial_trouble", "finanical_trouble2",
  "money_very_low_take_loan", "bankruptcy_imminent", "financial_trouble3",
  "staff_unhappy", "staff_unhappy2",
  "patients_unhappy", "patients_annoyed",
  "hospital_is_rubbish",
})

-- Map strings to the statistic they are formatted with
local format_map = {
  target = list_to_set({ "reputation_good_enough", "financial_criteria_met", "hospital_value_enough" }),
  gap = list_to_set({ "improve_reputation", "close_to_win_increase_value", "financial_trouble",
    "financial_trouble2", "financial_trouble3" }),
  -- measure = list_to_set({""})
}

-- Generate advice for this hospital on achieving the world goals
--!param hospital (hospital) The player's hospital
--!return (table) All relevant advice
--!return (table) All high priority and relevant advice
function EndConditions:generateAdvice(hospital)
  local advice_tbl, priority_advice_tbl = {}, {}
  local function add_advice(string, target, gap, measure, step)
    -- Create full string
    local full_string
    if warnings[string] then
      full_string = _A.warnings[string].text
    else
      full_string = _A.level_progress[string].text
    end
    if format_map.target[string] then full_string = full_string:format(target)
    elseif format_map.gap[string] then full_string = full_string:format(gap)
    -- elseif format_map.measure[string] then full_string = full_string:format(measure)
    end
    table.insert(advice_tbl, {text = full_string})
    -- Collect high priority advice
    if step and step < -2 then
      table.insert(priority_advice_tbl, {text = full_string})
    end
  end

  local crit_data = self:generateReportTable(hospital, true)
  local total, met = 0, 0
  for _, crit_table in ipairs(crit_data) do
    local crit_name = crit_table.name
    local target = crit_table.win_value or crit_table.lose_value
    local measure = self:getAttribute(hospital, crit_name)
    local gap = math.abs(target - measure)
    local step = progress(measure, target, crit_table.start)
    total = total + 1
    if step == 4 then met = met + 1 end
    -- Criterion specific advice
    if advice[crit_name] and advice[crit_name][step] then
      for _, string in pairs(advice[crit_name][step]) do
        add_advice(string, target, gap, measure, step)
      end

    end
    -- Generic advice for progress within a criterion
    if advice.generic[step] then
      for _, string in pairs(advice.generic[step]) do
        add_advice(string, nil, nil, nil, step)
      end
    end
  end

  if met > 1 then
    -- Generic advice on the fraction of goals met
    local goals_met_step = math.floor((met / total) * 4)
    if advice.generic[goals_met_step] then
      for _, string in pairs(advice.generic[goals_met_step]) do
        add_advice(string)
      end
    end
  end

  return advice_tbl, priority_advice_tbl
end
