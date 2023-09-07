--[[ Copyright (c) 2023 Albert "Alberth" Hofkamp

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

local _VALUE_HEIGHT = 18
local _VALUE_WIDTH = 30
local _LABEL_WIDTH = 100

local _TITLE_WIDTH = 500
local _TITLE_HEIGHT = 25
local _TITLE_SIZE = Size(_TITLE_WIDTH, _TITLE_HEIGHT)

--! Construct a language string name if path_value is set.
--!param path_value (nil true string) If true a name is constructed from the given
--  config path, else if set the string name to use.
--!param suffix (str) The suffix after the level configuration path to make the
--  name unique,
--!param level_cfg_path (str) The path in the level configuration file.
--!return (nil or string) The Name of the string in the language file if set.
local function _make_path(path_value, suffix, level_cfg_path)
  if path_value == true then
    return "level_editor.values." .. level_cfg_path .. "." .. suffix
  elseif path_value then
    return path_value
  else
    return nil
  end
end

--! Construct a LevelValue instance (an elementary editable numeric value).
--!param settings (table) Settings for the instance.
--!return (LevelValue) The constructed level value.
local function _makeValue(settings)
  -- settings fields:
  --  * "level_cfg_path" Obligatory path in the level configuration.
  --  * "name_path" The path of the name string in the language file or "true"
  --    to construct a name string from the level_cfg_path.
  --  * "tooltip_path" The path of the tooltip string in the language file or
  --    "true" to construct a tooltip string from the level_cfg_path.
  --  * "min_value" If set, the smallest value that is allowed.
  --  * "max_value" If set, the largest value that is allowed.
  local name_path = _make_path(settings.name_path, "name", settings.level_cfg_path)
  local tooltip_path = _make_path(settings.tooltip_path, "tooltip", settings.level_cfg_path)
  local unit_path = _make_path(settings.unit_path, "unit", settings.level_cfg_path)
  return LevelValue(settings.level_cfg_path, name_path, tooltip_path, unit_path,
      settings.min_value, settings.max_value)
end

--! Construct a LevelValueSection instance.
--!param settings (table) Settings for the instance.
--!return (LevelValueSection) The constructed instance.
local function _makeValuesSection(settings)
  assert(settings.title_path)
  -- settings fields:
  --  * The array of the settings contains the values of the section.
  --  * "title_path" (string) Language string with the title of the section.
  --  * "label_size" (Size nil) Optional size of the value name part. If not
  --    specified, a default is used.
  --  * "value_size" (Size nil) Optional size of the numeric value part. If not
  --    specified, a default is used.
  --  * "title_sep" (int nil) Optional vertical space below the title. If not
  --    specified a default is used.
  --  * "value_sep" (int nil) Optional vertical space between the values. If not
  --    specified a default is used.
  local section = LevelValuesSection(settings.title_path, settings)
  section:setLabelSize(settings.label_size or section.label_size)
  section:setValueSize(settings.value_size or section.value_size)
  section:setTitleSize(settings.title_size or section.title_size)
  section:setVertSep(settings.title_sep or section.title_sep,
      settings.value_sep or section.value_sep)
  return section
end

--! Construct a table with values for each index in a domain.
--!param settings (table) Settings for the instance.
--!return (LevelTableSection) The constructed table with index rows and value columns.
local function _makeTableSection(settings)
  -- settings fields:
  --  * "row_names" (array) String names for all rows.
  --  * "row_tooltips" (array) Optional string names for all rows.
  --  * "col_names" (array) String names for all columns.
  --  * "col_tooltips" (array) Optional tooltip string names.
  --  * "title_height" (int) Optional height of the title.
  --  * "title_sep" (int) Vertical space below the title
  --  * "row_label_sep" (int) Optional vertical space between rows.
  --  * "col_label_sep" (int) Optional horizontal space between column labels.
  --  * "col_width" (int) Optional with of a column (including the row names column).
  --  * "row_height" (int) Optional height of a row.
  --  * "intercol_sep" (int) Optional horizontal space between columns.
  --  * "interrow_sep" (int) Optional vertical space between rows.
  assert(settings.title_path)
  local row_names = settings.row_names
  local row_tooltips = settings.row_tooltips
  local col_names = settings.col_names
  local col_tooltips = settings.col_tooltips
  local col_values = settings.col_values
  local section = LevelTableSection(settings.title_path, row_names, row_tooltips,
      col_names, col_tooltips, col_values)
  section.title_height = settings.title_height or section.title_height
  section.title_sep = settings.title_sep or section.title_sep
  section.row_label_sep = settings.row_label_sep or section.row_label_sep
  section.col_label_sep = settings.col_label_sep or section.col_label_sep
  section.col_width = settings.col_width or section.col_width
  section.row_height = settings.row_height or section.row_height
  section.intercol_sep = settings.intercol_sep or section.intercol_sep
  section.interrow_sep = settings.interrow_sep or section.interrow_sep
  return section
end


--! Construct an editable page with the given edit sections.
--!param settings (table) Settings and content for the edit page.
local function _makeEditPageSection(settings)
  -- settings fields:
  --  * The array of the settings contains the edit sections of the page.
  --  * "tab_name_path" (string) Language string with the tab-name of the section.
  local section = LevelEditPage(settings.tab_name_path, settings)
  return section
end


--! Make a LevelTabPage instance.
--!param settings (table) Settings and content for the tab page.
--!return (LevelTabPage) The constructed instance.
local function _makeTabPageSection(settings)
  -- settings fields:
  --  * The array of the settings contains the values of the section.
  --  " "page_tab_size" (Size) Optional size of a tab. If not specified, a
  --    default is used.
  --  * "edit_sep" (int) Optional vertical space between the rows of tabs and
  --    the editable sections. If not specified, a default is used.
  local section = LevelTabPage(settings)
  section.page_tab_size = settings.page_tab_size or section.page_tab_size
  section.edit_sep = settings.edit_sep or section.edit_sep
  return section
end

class "UILevelEditor" (UIResizable)

---@type UILevelEditor
local UILevelEditor = _G["UILevelEditor"]


local col_bg = {red = 154, green = 146, blue = 198}

local EDITOR_WINDOW_XSIZE = 640
local EDITOR_WINDOW_YSIZE = 480

function UILevelEditor:UILevelEditor(ui)
  self:UIResizable(ui, EDITOR_WINDOW_XSIZE, EDITOR_WINDOW_YSIZE, col_bg)
  self.resizable = false

  self.ui = ui
  self.on_top = true

  self.edit_pages = self:_makeMainTabPage()
  self.edit_pages:layout(self,
      Pos(5, 5), Size(EDITOR_WINDOW_XSIZE - 10, EDITOR_WINDOW_YSIZE - 10))
  self:setDefaultPosition(0.1, 0.1)
end

function UILevelEditor:_makeTownEditPage()
  local local_town = _makeValuesSection({
    title_path = "level_editor.titles.local_town",
    title_size = _TITLE_SIZE,
    label_size = Size(300, LevelValuesSection.VALUE_HEIGHT),
    _makeValue({level_cfg_path = "town.StartCash", name_path = true}),
    _makeValue({level_cfg_path = "town.InterestRate", name_path = true}),
    _makeValue({level_cfg_path = "town.StartRep", name_path = true}),
    _makeValue({level_cfg_path = "town.OverdraftDiff", name_path = true, tooltip_path = true}),
    _makeValue({level_cfg_path = "gbv.MayorLaunch", name_path = true}),
    _makeValue({level_cfg_path = "gbv.AllocDelay", name_path = true}),
    _makeValue({level_cfg_path = "gbv.ScoreMaxInc", name_path = true}),
  })

  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.local_town",
    local_town,
  })
end

function UILevelEditor:_makeTownLevelssEditPage()
  local towns_col1 = {
    _makeValue({level_cfg_path = "gbv.towns[0].StartCash"}),
    _makeValue({level_cfg_path = "gbv.towns[1].StartCash"}),
    _makeValue({level_cfg_path = "gbv.towns[2].StartCash"}),
    _makeValue({level_cfg_path = "gbv.towns[3].StartCash"}),
    _makeValue({level_cfg_path = "gbv.towns[4].StartCash"}),
    _makeValue({level_cfg_path = "gbv.towns[5].StartCash"}),
    _makeValue({level_cfg_path = "gbv.towns[6].StartCash"}),
    _makeValue({level_cfg_path = "gbv.towns[7].StartCash"}),
    _makeValue({level_cfg_path = "gbv.towns[8].StartCash"}),
    _makeValue({level_cfg_path = "gbv.towns[9].StartCash"}),
    _makeValue({level_cfg_path = "gbv.towns[10].StartCash"}),
    _makeValue({level_cfg_path = "gbv.towns[11].StartCash"}),
    _makeValue({level_cfg_path = "gbv.towns[12].StartCash"}),
  }
  local towns_col2 = {
    _makeValue({level_cfg_path = "gbv.towns[0].InterestRate"}),
    _makeValue({level_cfg_path = "gbv.towns[1].InterestRate"}),
    _makeValue({level_cfg_path = "gbv.towns[2].InterestRate"}),
    _makeValue({level_cfg_path = "gbv.towns[3].InterestRate"}),
    _makeValue({level_cfg_path = "gbv.towns[4].InterestRate"}),
    _makeValue({level_cfg_path = "gbv.towns[5].InterestRate"}),
    _makeValue({level_cfg_path = "gbv.towns[6].InterestRate"}),
    _makeValue({level_cfg_path = "gbv.towns[7].InterestRate"}),
    _makeValue({level_cfg_path = "gbv.towns[8].InterestRate"}),
    _makeValue({level_cfg_path = "gbv.towns[9].InterestRate"}),
    _makeValue({level_cfg_path = "gbv.towns[10].InterestRate"}),
    _makeValue({level_cfg_path = "gbv.towns[11].InterestRate"}),
    _makeValue({level_cfg_path = "gbv.towns[12].InterestRate"}),
  }
  local towns_col3 = {
    _makeValue({level_cfg_path = "gbv.towns[0].StartRep"}),
    _makeValue({level_cfg_path = "gbv.towns[1].StartRep"}),
    _makeValue({level_cfg_path = "gbv.towns[2].StartRep"}),
    _makeValue({level_cfg_path = "gbv.towns[3].StartRep"}),
    _makeValue({level_cfg_path = "gbv.towns[4].StartRep"}),
    _makeValue({level_cfg_path = "gbv.towns[5].StartRep"}),
    _makeValue({level_cfg_path = "gbv.towns[6].StartRep"}),
    _makeValue({level_cfg_path = "gbv.towns[7].StartRep"}),
    _makeValue({level_cfg_path = "gbv.towns[8].StartRep"}),
    _makeValue({level_cfg_path = "gbv.towns[9].StartRep"}),
    _makeValue({level_cfg_path = "gbv.towns[10].StartRep"}),
    _makeValue({level_cfg_path = "gbv.towns[11].StartRep"}),
    _makeValue({level_cfg_path = "gbv.towns[12].StartRep"}),
  }
  local towns_col4 = {
    _makeValue({level_cfg_path = "gbv.towns[0].OverdraftDiff"}),
    _makeValue({level_cfg_path = "gbv.towns[1].OverdraftDiff"}),
    _makeValue({level_cfg_path = "gbv.towns[2].OverdraftDiff"}),
    _makeValue({level_cfg_path = "gbv.towns[3].OverdraftDiff"}),
    _makeValue({level_cfg_path = "gbv.towns[4].OverdraftDiff"}),
    _makeValue({level_cfg_path = "gbv.towns[5].OverdraftDiff"}),
    _makeValue({level_cfg_path = "gbv.towns[6].OverdraftDiff"}),
    _makeValue({level_cfg_path = "gbv.towns[7].OverdraftDiff"}),
    _makeValue({level_cfg_path = "gbv.towns[8].OverdraftDiff"}),
    _makeValue({level_cfg_path = "gbv.towns[9].OverdraftDiff"}),
    _makeValue({level_cfg_path = "gbv.towns[10].OverdraftDiff"}),
    _makeValue({level_cfg_path = "gbv.towns[11].OverdraftDiff"}),
    _makeValue({level_cfg_path = "gbv.towns[12].OverdraftDiff"}),
  }

  local towns_row_names = {}
  for i = 0, 12 do
    towns_row_names[#towns_row_names + 1] = "level_editor.town_levels.row_names[" .. i .. "]"
  end
  local towns_col_names = {
    "level_editor.town_levels.col_names.start_cash",
    "level_editor.town_levels.col_names.interest_rate",
    "level_editor.town_levels.col_names.start_rep",
    "level_editor.town_levels.col_names.overdraft_diff",
  }

  local town_level_values = _makeTableSection({
    title_path = "level_editor.titles.town_levels",
    row_names = towns_row_names,
    col_values = {towns_col1, towns_col2, towns_col3, towns_col4},
    col_names = towns_col_names
  })

  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.town_levels",
    town_level_values,
  })
end

function UILevelEditor:_makeHospitalEditPage1()
  local research_section = _makeValuesSection({
    title_path = "level_editor.titles.research",
    title_size = _TITLE_SIZE,
    label_size = Size(300, LevelValuesSection.VALUE_HEIGHT),
    _makeValue({level_cfg_path = "gbv.ResearchPointsDivisor", name_path = true, tooltip_path = true}),
    _makeValue({level_cfg_path = "gbv.ResearchIncrement", name_path = true}),
    _makeValue({level_cfg_path = "gbv.StartRating", name_path = true}),
    _makeValue({level_cfg_path = "gbv.StartCost", name_path = true}),
    _makeValue({level_cfg_path = "gbv.MinDrugCost", name_path = true}),
    _makeValue({level_cfg_path = "gbv.DrugImproveRate", name_path = true}),
    _makeValue({level_cfg_path = "gbv.MaxObjectStrength", name_path = true}),
    _makeValue({level_cfg_path = "gbv.AutopsyRschPercent", name_path = true}),
    _makeValue({level_cfg_path = "gbv.AutopsyRepHitPercent", name_path = true}),
    _makeValue({level_cfg_path = "gbv.RschImproveCostPercent", name_path = true}),
    _makeValue({level_cfg_path = "gbv.RschImproveIncrementPercent", name_path = true}),
  })
  local training_section = _makeValuesSection({
    title_path = "level_editor.titles.training",
    title_size = _TITLE_SIZE,
    label_size = Size(300, LevelValuesSection.VALUE_HEIGHT),
    _makeValue({level_cfg_path = "gbv.TrainingRate", name_path = true}),
    _makeValue({level_cfg_path = "gbv.TrainingValue[0]", name_path = true}),
    _makeValue({level_cfg_path = "gbv.TrainingValue[1]", name_path = true}),
    _makeValue({level_cfg_path = "gbv.TrainingValue[2]", name_path = true}),
    _makeValue({level_cfg_path = "gbv.AbilityThreshold[0]", name_path = true}),
    _makeValue({level_cfg_path = "gbv.AbilityThreshold[1]", name_path = true}),
    _makeValue({level_cfg_path = "gbv.AbilityThreshold[2]", name_path = true}),
    _makeValue({level_cfg_path = "gbv.DoctorThreshold", name_path = true}),
    _makeValue({level_cfg_path = "gbv.ConsultantThreshold", name_path = true}),
  })

  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.hospital1",
    research_section,
    training_section,
  })
end

function UILevelEditor:_makeHospitalEditPage2()
  local epidemics_section = _makeValuesSection({
    title_path = "level_editor.titles.epidemics",
    title_size = _TITLE_SIZE,
    label_size = Size(300, LevelValuesSection.VALUE_HEIGHT),
    _makeValue({level_cfg_path = "gbv.HowContagious", name_path = true}),
    _makeValue({level_cfg_path = "gbv.ContagiousSpreadFactor", name_path = true}),
    _makeValue({level_cfg_path = "gbv.ReduceContMonths", name_path = true}),
    _makeValue({level_cfg_path = "gbv.ReduceContPeepCount", name_path = true}),
    _makeValue({level_cfg_path = "gbv.ReduceContRate", name_path = true}),
    _makeValue({level_cfg_path = "gbv.HoldVisualMonths", name_path = true}),
    _makeValue({level_cfg_path = "gbv.HoldVisualPeepCount", name_path = true}),
    _makeValue({level_cfg_path = "gbv.Vaccost", name_path = true}),
    _makeValue({level_cfg_path = "gbv.EpidemicFine", name_path = true}),
    _makeValue({level_cfg_path = "gbv.EpidemicCompLo", name_path = true}),
    _makeValue({level_cfg_path = "gbv.EpidemicCompHi", name_path = true}),
    _makeValue({level_cfg_path = "gbv.EpidemicRepLossMinimum", name_path = true}),
    _makeValue({level_cfg_path = "gbv.EpidemicEvacMinimum", name_path = true}),
    _makeValue({level_cfg_path = "gbv.EpidemicConcurrentLimit", name_path = true}),
  })

  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.hospital2",
    epidemics_section
  })
end

function UILevelEditor:_makeStaffEditPage1()
  local min_salaries_section = _makeValuesSection({
    title_path = "level_editor.titles.min_salaries",
    title_size = _TITLE_SIZE,
    label_size = Size(300, LevelValuesSection.VALUE_HEIGHT),
    _makeValue({level_cfg_path = "staff[0].MinSalary", name_path = true}),
    _makeValue({level_cfg_path = "staff[1].MinSalary", name_path = true}),
    _makeValue({level_cfg_path = "staff[2].MinSalary", name_path = true}),
    _makeValue({level_cfg_path = "staff[3].MinSalary", name_path = true}),
    _makeValue({level_cfg_path = "gbv.SalaryAbilityDivisor", name_path = true, tooltip_path = true}),
    _makeValue({level_cfg_path = "payroll.MaxSalary", name_path = true}),
  })
  local medical_bonuses_section = _makeValuesSection({
    title_path = "level_editor.titles.medical_bonuses",
    title_size = _TITLE_SIZE,
    label_size = Size(300, LevelValuesSection.VALUE_HEIGHT),
    _makeValue({level_cfg_path = "gbv.SalaryAdd[3]", name_path = true, tooltip_path = true}),
    _makeValue({level_cfg_path = "gbv.SalaryAdd[4]", name_path = true}),
    _makeValue({level_cfg_path = "gbv.SalaryAdd[5]", name_path = true}),
    _makeValue({level_cfg_path = "gbv.SalaryAdd[6]", name_path = true}),
    _makeValue({level_cfg_path = "gbv.SalaryAdd[7]", name_path = true}),
    _makeValue({level_cfg_path = "gbv.SalaryAdd[8]", name_path = true}),
  })

  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.staff1",
    min_salaries_section,
    medical_bonuses_section
  })
end

function UILevelEditor:_makeRoomsCostEditPage()
  local rooms_cost_edit_section = _makeValuesSection({
    title_path = "level_editor.titles.rooms_cost",
    title_size = _TITLE_SIZE,
    label_size = Size(300, LevelValuesSection.VALUE_HEIGHT),
    _makeValue({level_cfg_path = "rooms[7].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[8].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[9].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[10].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[11].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[12].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[13].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[14].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[15].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[16].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[17].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[18].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[19].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[20].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[21].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[22].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[23].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[24].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[25].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[26].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[27].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[28].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[29].Cost", name_path = true}),
    _makeValue({level_cfg_path = "rooms[30].Cost", name_path = true}),
  })

  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.rooms_cost",
    rooms_cost_edit_section,
  })
end

function UILevelEditor:_makeGlobalAwardsTrophiesEditPage()
  local global_trophies_bonuses = _makeValuesSection({
    title_path = "level_editor.titles.global_trophies",
    title_size = _TITLE_SIZE,
    label_size = Size(300, LevelValuesSection.VALUE_HEIGHT),
    _makeValue({level_cfg_path = "awards_trophies.TrophyAllCuredBonus", name_path = true}),
    _makeValue({level_cfg_path = "awards_trophies.TrophyDeathBonus", name_path = true}),
    _makeValue({level_cfg_path = "awards_trophies.TrophyCuresBonus", name_path = true}),
    _makeValue({level_cfg_path = "awards_trophies.TrophyMayorBonus", name_path = true}),
  })
  local global_award_bonuses = _makeValuesSection({
    title_path = "level_editor.titles.global_awards",
    title_size = _TITLE_SIZE,
    label_size = Size(300, LevelValuesSection.VALUE_HEIGHT),
    _makeValue({level_cfg_path = "awards_trophies.AllCuresBonus", name_path = true}),
    _makeValue({level_cfg_path = "awards_trophies.NewTechAward", name_path = true}),
    _makeValue({level_cfg_path = "awards_trophies.NewTechPoor", name_path = true}),
    _makeValue({level_cfg_path = "awards_trophies.ResearchBonus", name_path = true}),
    _makeValue({level_cfg_path = "awards_trophies.ResearchPenalty", name_path = true}),
  })

  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.global_awards_trophies",
    global_trophies_bonuses,
    global_award_bonuses,
  })
end

function UILevelEditor:_makeMainTabPage()
  return _makeTabPageSection({
    self:_makeTownEditPage(),
    self:_makeTownLevelssEditPage(),
    self:_makeHospitalEditPage1(), self:_makeHospitalEditPage2(),
    self:_makeStaffEditPage1(),
    self:_makeRoomsCostEditPage(),
    self:_makeGlobalAwardsTrophiesEditPage(),
  })
end

