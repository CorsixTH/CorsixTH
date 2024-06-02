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
--   numbers from the order of this table.
--   Icon, icon_file and formats are used in the progress report dialog.
local local_criteria_variable = {
  {name = "reputation",       icon = 10, formats = 2},
  {name = "balance",          icon = 11, formats = 2},
  {name = "percentage_cured", icon = 12, formats = 2},
  {name = "num_cured" ,       icon = 13, formats = 2},
  {name = "percentage_killed",icon = 14, formats = 2},
  {name = "value",            icon = 15, formats = 2}, -- Hospital value
}

-- A table of functions for fetching criteria values that cannot be measured
--  directly from a hospital attribute of the same name.
local get_custom_criteria = {
  balance = function(hospital) return hospital.balance - hospital.loan end,
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
    if values.Criteria ~= 0 then
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
--!return report_table (table) Maximum five fields of
-- lose criteria with the smallest gap between current value and boundary,
-- then fill up to five with win criteria in the best group.
function EndConditions:generateReportTable(hospital)
  local count, lose_table, report_table, tmp_table = 0, {}, {}, {}
  local win_group = self.win_goals[self:_findBestWinGroup(hospital)] or {}

  -- Collect lose criteria over the boundary
  for group, tbl in pairs(self.lose_goals) do
    lose_table[group] = self:_checkLoseGroup(hospital, tbl, true)
  end
  -- Get the most relevant of each criterion in all groups
  for _, group_table in pairs(lose_table) do
    for crit_name, crit_table in pairs(group_table) do
      if not tmp_table[crit_name] or tmp_table[crit_name].gap > crit_table.gap then
        tmp_table[crit_name] = crit_table
      end
    end
  end
  -- Move into a numbered table
  for _, crit_table in pairs(tmp_table) do
    table.insert(report_table, crit_table)
    count = count + 1
    if count == 5 then break end
  end

  -- Fill up the report table with win criteria not already present as lose criteria
  for i = 1, #local_criteria_variable do
    local name = local_criteria_variable[i].name
    if win_group[name] and not tmp_table[name] then
      count = count + 1
      report_table[count] = win_group[name]
      if count == 5 then break end
    end
  end

  -- Some criteria icons shouldn't be next to each other
  table.sort(report_table, function(a,b) return a.criterion < b.criterion end)
  return report_table
end

--!param hospital (Hospital) The hospital of the tests.
--!param lose_table (table) A group of lose conditions from level_config.
--!param report (boolean) Whether a report table will be returned.
--!return Losing criteria name and the limit breached,
-- or if report is true, the report table.
function EndConditions:_checkLoseGroup(hospital, lose_table, report)
  local report_table, met_count, total_count, reason, limit = {}, 0, 0
  for crit_name, crit_table in pairs(lose_table) do
    local target = report and crit_table.boundary or crit_table.lose_value
    local max_min = crit_table.max_min == 1 and 1 or -1
    local measure = self:getAttribute(hospital, crit_name)
    if (measure - target) * max_min > 0 then
      if report then -- Collect the criteria that should be reported on
        report_table[crit_name] = crit_table
        report_table[crit_name].gap = math.abs(measure - target)
      else
        reason, limit = crit_name, crit_table.lose_value
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
