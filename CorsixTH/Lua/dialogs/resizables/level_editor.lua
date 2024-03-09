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

local _TITLE_WIDTH = 500
local _TITLE_HEIGHT = 25
local _TITLE_SIZE = Size(_TITLE_WIDTH, _TITLE_HEIGHT)

local _LABEL_COL_WIDTH = 200
local _DATA_COL_WIDTH = 150

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
  --  * "col_values" (array) Array of column arrays of values.
  --  * "title_size" (Size) Optional size of the title.
  --  * "title_sep" (int) Vertical space below the title
  --  * "row_label_sep" (int) Optional vertical space between rows.
  --  * "col_label_sep" (int) Optional horizontal space between column labels.
  --  * "label_col_width" (int) Optional with of the left-most column.
  --  * "data_col_width" (int) Optional with of a column (excluding the row
  --    names column at the left).
  --  * "value_width" Width of a value. Defaults to "data_col_width". If less,
  --    table headers gets stacked two rows in order to reduce width.
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
  section.title_size = settings.title_size or section.title_size
  section.title_sep = settings.title_sep or section.title_sep
  section.row_label_sep = settings.row_label_sep or section.row_label_sep
  section.col_label_sep = settings.col_label_sep or section.col_label_sep
  section.data_col_width = settings.data_col_width or section.data_col_width
  section.label_col_width = settings.label_col_width or section.label_col_width
  section.value_width = settings.value_width or section.value_width
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
    value_size = Size(70, LevelValuesSection.VALUE_HEIGHT),
    label_size = Size(250, LevelValuesSection.VALUE_HEIGHT),
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
  local towns_col1 = {}
  local towns_col2 = {}
  local towns_col3 = {}
  local towns_col4 = {}
  local town_row_names = {}

  for i = 0,12 do
    local prefix = "gbv.towns[" .. i .. "]."
    towns_col1[#towns_col1 + 1] = _makeValue({level_cfg_path = prefix .. "StartCash"})
    towns_col2[#towns_col2 + 1] = _makeValue({level_cfg_path = prefix .. "InterestRate"})
    towns_col3[#towns_col3 + 1] = _makeValue({level_cfg_path = prefix .. "StartRep"})
    towns_col4[#towns_col4 + 1] = _makeValue({level_cfg_path = prefix .. "OverdraftDiff"})

    town_row_names[#town_row_names + 1] = "level_editor.town_levels.row_names[" .. i .. "]"
  end

  local towns_col_names = {
    "level_editor.town_levels.col_names.start_cash",
    "level_editor.town_levels.col_names.interest_rate",
    "level_editor.town_levels.col_names.start_rep",
    "level_editor.town_levels.col_names.overdraft_diff",
  }

  local town_level_section = _makeTableSection({
    title_path = "level_editor.titles.town_levels",
    title_size = _TITLE_SIZE,
    label_col_width = 100, data_col_width = 100,
    row_names = town_row_names,
    col_values = {towns_col1, towns_col2, towns_col3, towns_col4},
    col_names = towns_col_names
  })

  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.town_levels",
    town_level_section,
  })
end

function UILevelEditor:_makePopulationEditPage()
  local popn_col1 = {
    _makeValue({level_cfg_path = "gbv.popn[0].Month"}),
    _makeValue({level_cfg_path = "gbc.popn[1].Month"}),
    _makeValue({level_cfg_path = "gbc.popn[2].Month"}),
  }
  local popn_col2 = {
    _makeValue({level_cfg_path = "gbv.popn[0].Change"}),
    _makeValue({level_cfg_path = "gbc.popn[1].Change"}),
    _makeValue({level_cfg_path = "gbc.popn[2].Change"}),
  }
  local popn_row_names = {
    "level_editor.popn.row_names.gbv.popn[0]",
    "level_editor.popn.row_names.gbv.popn[1]",
    "level_editor.popn.row_names.gbv.popn[2]",
  }
  local popn_col_names = {
    "level_editor.popn.col_names.gbv.popn.month",
    "level_editor.popn.col_names.gbv.popn.change",
  }

  local popn_section = _makeTableSection({
    title_path = "level_editor.titles.popn",
    title_size = _TITLE_SIZE,
    label_col_width = 100, data_col_width = _DATA_COL_WIDTH,
    row_names = popn_row_names,
    col_values = {popn_col1, popn_col2},
    col_names = popn_col_names
  })

  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.popn",
    popn_section,
  })
end

function UILevelEditor:_makeHospitalEditPage1()
  local research_section = _makeValuesSection({
    title_path = "level_editor.titles.research",
    title_size = _TITLE_SIZE,
    label_size = Size(300, LevelValuesSection.VALUE_HEIGHT),
    title_sep = 4,
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

  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.hospital1",
    research_section,
  })
end

function UILevelEditor:_makeHospitalEditPage2()
  local training_section = _makeValuesSection({
    title_path = "level_editor.titles.training",
    title_size = _TITLE_SIZE,
    label_size = Size(300, LevelValuesSection.VALUE_HEIGHT),
    title_sep = 4,
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
    tab_name_path = "level_editor.tab_names.hospital2",
    training_section,
  })
end

function UILevelEditor:_makeHospitalEditPage3()
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
    tab_name_path = "level_editor.tab_names.hospital3",
    epidemics_section
  })
end

function UILevelEditor:_makeStaffEditPage()
  local min_salaries_section = _makeValuesSection({
    title_path = "level_editor.titles.min_salaries",
    title_size = _TITLE_SIZE,
    label_size = Size(100, LevelValuesSection.VALUE_HEIGHT),
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
    label_size = Size(100, LevelValuesSection.VALUE_HEIGHT),
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

function UILevelEditor:_makeStaffLevelsEditPage12()
  local staff_levels_row_names = {}
  local staff_levels_col_month = {}
  local staff_levels_col_nurses = {}
  local staff_levels_col_doctors = {}
  local staff_levels_col_handymen = {}
  local staff_levels_col_receptionist = {}
  local staff_levels_col_psychs_rate = {}
  local staff_levels_col_surgs_rate = {}
  local staff_levels_col_researchs_rate = {}
  local staff_levels_col_consults_rate = {}
  local staff_levels_col_juniors_rate = {}

  for i = 0, 8 do
    staff_levels_row_names[i + 1] = "level_editor.staff_levels.row_names[" .. i .. "]"

    staff_levels_col_month[i + 1] =
        _makeValue({level_cfg_path = "staff_levels[" .. i .. "].Month"})
    staff_levels_col_nurses[i + 1] =
        _makeValue({level_cfg_path = "staff_levels[" .. i .. "].Nurses"})
    staff_levels_col_doctors[i + 1] =
        _makeValue({level_cfg_path = "staff_levels[" .. i .. "].Doctors"})
    staff_levels_col_handymen[i + 1] =
        _makeValue({level_cfg_path = "staff_levels[" .. i .. "].Handymen"})
    staff_levels_col_receptionist[i + 1] =
        _makeValue({level_cfg_path = "staff_levels[" .. i .. "].Receptionists"})
    staff_levels_col_psychs_rate[i + 1] =
        _makeValue({level_cfg_path = "staff_levels[" .. i .. "].ShrkRate"})
    staff_levels_col_surgs_rate[i + 1] =
        _makeValue({level_cfg_path = "staff_levels[" .. i .. "].SurgRate"})
    staff_levels_col_researchs_rate[i +
        1] = _makeValue({level_cfg_path = "staff_levels[" .. i .. "].RschRate"})
    staff_levels_col_consults_rate[i +
        1] = _makeValue({level_cfg_path = "staff_levels[" .. i .. "].ConsRate"})
    staff_levels_col_juniors_rate[i +
        1] = _makeValue({level_cfg_path = "staff_levels[" .. i .. "].JrRate"})
  end

  local staff_levels1 = _makeTableSection({
    title_path = "level_editor.titles.staff_level1",
    title_size = _TITLE_SIZE,
    label_col_width = 80, data_col_width = 130, value_width = 95,
    col_names = {
      "level_editor.staff_levels.col_names.Month",
      "level_editor.staff_levels.col_names.Nurses",
      "level_editor.staff_levels.col_names.Doctors",
      "level_editor.staff_levels.col_names.Handymen",
      "level_editor.staff_levels.col_names.Receptionists"
    },
    row_names = staff_levels_row_names,
    col_values = {staff_levels_col_month, staff_levels_col_nurses,
        staff_levels_col_doctors, staff_levels_col_handymen,
        staff_levels_col_receptionist}
  })
  staff_levels1 = _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.staff_level1",
    staff_levels1
  })

  local staff_levels2 = _makeTableSection({
    title_path = "level_editor.titles.staff_level2",
    title_size = _TITLE_SIZE,
    label_col_width = 80, data_col_width = 130, value_width = 95,
    col_names = {
      "level_editor.staff_levels.col_names.ShrkRate",
      "level_editor.staff_levels.col_names.SurgRate",
      "level_editor.staff_levels.col_names.RschRate",
      "level_editor.staff_levels.col_names.ConsRate",
      "level_editor.staff_levels.col_names.JrRate"
    },
    row_names = staff_levels_row_names,
    col_values = {staff_levels_col_psychs_rate, staff_levels_col_surgs_rate,
        staff_levels_col_researchs_rate, staff_levels_col_consults_rate,
        staff_levels_col_juniors_rate}
  })
  staff_levels2 = _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.staff_level2",
    staff_levels2
  })

  return staff_levels1, staff_levels2
end

--! Expand an array of {first, last} pairs to all numbers in the ranges.
--!param ranges (array) Array of {first, last} pairs.
--!return (array) Array of all numbers expressed in the pairs.
local function _xpandRanges(ranges)
  local result = {}
  for _, val in ipairs(ranges) do
    if type(val) == "number" then
      result[#result + 1] = val
    else
      for i = val[1], val[2] do result[#result + 1] = i end
    end
  end
  return result
end

function UILevelEditor:_makeDiseaseExpertiseEditPage(ranges, sect_num)
  local col1 = {}
  local col2 = {}
  local col3 = {}
  local col4 = {}
  local section_row_names = {}

  for _, i in ipairs(_xpandRanges(ranges)) do
    section_row_names[#section_row_names + 1] =
        "level_editor.expertise_diseases.row_names[" .. i .. "]"

    col1[#col1 + 1] = _makeValue({
      level_cfg_path = "expertise[" .. i .. "].StartPrice"
    })
    col2[#col2 + 1] = _makeValue({
      level_cfg_path = "expertise[" .. i .. "].Known",
      min_value = 0,
      max_value = 1
    })
    col3[#col3 + 1] = _makeValue({
      level_cfg_path = "expertise[" .. i .. "].RschReqd"
    })
    col4[#col4 + 1] = _makeValue({
      level_cfg_path = "expertise[" .. i .. "].MaxDiagDiff"
    })
  end
  local section = _makeTableSection({
    title_path = "level_editor.titles.expertise_diseases" .. sect_num,
    title_size = _TITLE_SIZE,
    label_col_width = 135, data_col_width = 115,
    row_names = section_row_names,
    col_values = {col1, col2, col3, col4},
    col_names = {
      "level_editor.expertise_diseases.col_names.StartPrice",
      "level_editor.expertise_diseases.col_names.Known",
      "level_editor.expertise_diseases.col_names.RschReqd",
      "level_editor.expertise_diseases.col_names.MaxDiagDiff",
    }
  })

  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.expertise_diseases" .. sect_num,
    section
  })
end

--! Make an edit page for disease availability.
--!param kind (str) Kind of disease, either "visuals" or "nonvisuals"
--!param first Index of the first disease to include.
--!param last Index of the last disease to include.
--!param sect_num Number of the section.
function UILevelEditor:_makeDiseasesExistenceEditPage(kind, first, last, sect_num)
  local col1 = {}
  local col2 = {}
  local section_row_names = {}
  for i = first, last do
    section_row_names[#section_row_names + 1] =
        "level_editor." .. kind .. ".row_names[" .. i .. "]"

    col1[#col1 + 1] = _makeValue({
      level_cfg_path = kind .. "[" .. i .. "]",
      min_value = 0,
      max_value = 1
    })
    col2[#col2 + 1] = _makeValue({
      level_cfg_path = kind .. "_available[" .. i .. "]"
    })
  end
  local section = _makeTableSection({
    title_path = "level_editor.titles." .. kind .. sect_num,
    title_size = _TITLE_SIZE,
    label_col_width = 200, data_col_width = 120,
    row_names = section_row_names,
    col_values = {col1, col2},
    col_names = {
      "level_editor." .. kind .. ".col_names.month",
      "level_editor." .. kind .. ".col_names.exists",
    }
  })

  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names." .. kind .. sect_num,
    section
  })
end

function UILevelEditor:_makeRoomExpertiseEditPage()
  local col1 = {}
  local col2 = {}
  local col3 = {}
  local section_row_names = {}
  for _, i in ipairs(_xpandRanges({{1, 1}, {36, 46}})) do
    section_row_names[#section_row_names + 1] =
        "level_editor.expertise_rooms.row_names[" .. i .. "]"

    col1[#col1 + 1] = _makeValue({
      level_cfg_path = "expertise[" .. i .. "].StartPrice"
    })
    col2[#col2 + 1] = _makeValue({
      level_cfg_path = "expertise[" .. i .. "].Known",
      min_value = 0,
      max_value = 1
    })
    col3[#col3 + 1] = _makeValue({
      level_cfg_path = "expertise[" .. i .. "].RschReqd"
    })
  end

  local expertise_rooms = _makeTableSection({
    title_path = "level_editor.titles.expertise_rooms",
    title_size = _TITLE_SIZE,
    label_col_width = 200, data_col_width = 130,
    row_names = section_row_names,
    col_values = {col1, col2, col3},
    col_names = {
      "level_editor.expertise_rooms.col_names.StartPrice",
      "level_editor.expertise_rooms.col_names.Known",
      "level_editor.expertise_rooms.col_names.RschReqd",
    }
  })

  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.expertise_rooms",
    expertise_rooms
  })
end

function UILevelEditor:_makeObjectsEditPage(ranges, sect_num)
  -- ENHANCEMENT: Shuffle objects between table sections so similar objects are at a single page.
  -- ENHANCEMENT: Eliminate the unused objects.
  -- ENHANCEMENT: Having a left and a right door as separate objects is just silly for a user.
  local col1 = {}
  local col2 = {}
  local col3 = {}
  local col4 = {}
  local col5 = {}
  local sect_row_names = {}

  for _, i in ipairs(_xpandRanges(ranges)) do
    sect_row_names[#sect_row_names + 1] =
        "level_editor.objects.row_names[" .. i .. "]"

    col1[#col1 + 1] = _makeValue({
      level_cfg_path = "objects[" .. i .. "].AvailableForLevel"
    })
    col2[#col2 + 1] = _makeValue({
      level_cfg_path = "objects[" .. i .. "].StartStrength"
    })
    col3[#col3 + 1] = _makeValue({
      level_cfg_path = "objects[" .. i .. "].WhenAvail"
    })
    col4[#col4 + 1] = _makeValue({
      level_cfg_path = "objects[" .. i .. "].StartAvail"
    })
    col5[#col5 + 1] = _makeValue({
      level_cfg_path = "objects[" .. i .. "].StartCost"
    })
  end

  local objects_section = _makeTableSection({
    title_path = "level_editor.titles.objects" .. sect_num,
    title_size = _TITLE_SIZE,
    label_col_width = 130, data_col_width = 92,
    row_names = sect_row_names,
    col_values = {col1, col2, col3, col4, col5},
    col_names = {
      "level_editor.objects.col_names.AvailableForLevel",
      "level_editor.objects.col_names.StartStrength",
      "level_editor.objects.col_names.WhenAvail",
      "level_editor.objects.col_names.StartAvail",
      "level_editor.objects.col_names.StartCost",
    }
  })

  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.objects" .. sect_num,
    objects_section
  })
end

function UILevelEditor:_makeRoomsCostEditPage(ranges, page_num)
  local section_data = {
    title_path = "level_editor.titles.rooms_cost" .. page_num,
    title_size = _TITLE_SIZE,
    label_size = Size(200, LevelValuesSection.VALUE_HEIGHT),
  }

  for _, i in ipairs(_xpandRanges(ranges)) do
    section_data[#section_data + 1] = _makeValue({
      level_cfg_path = "rooms[" .. i .. "].Cost",
      name_path = true
    })
  end

  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.rooms_cost" .. page_num,
    _makeValuesSection(section_data)
  })
end

function UILevelEditor:_makeEmergencyControlEditPage()
  local col1 = {}
  local col2 = {}
  local col3 = {}
  local col4 = {}
  local col5 = {}
  local col6 = {}
  local col7 = {}
  local emergency_control_row_names = {}

  for i = 0, 8 do
    emergency_control_row_names[#emergency_control_row_names + 1] =
        "level_editor.emergency_control.row_names[" .. i .. "]"

    col1[#col1 + 1] =  _makeValue({
      level_cfg_path = "level_editor.emergency_control.row_names[" .. i .. "].StartMonth",
      min_value = 0
    })
    col2[#col2 + 1] =  _makeValue({
      level_cfg_path = "level_editor.emergency_control.row_names[" .. i .. "].EndMonth",
      min_value = 0
    })
    col3[#col3 + 1] =  _makeValue({
      level_cfg_path = "level_editor.emergency_control.row_names[" .. i .. "].Min",
      min_value = 0
    })
    col4[#col4 + 1] =  _makeValue({
      level_cfg_path = "level_editor.emergency_control.row_names[" .. i .. "].Max",
      min_value = 0
    })
    col5[#col5 + 1] =  _makeValue({
      level_cfg_path = "level_editor.emergency_control.row_names[" .. i .. "].Illness"
    })
    col6[#col6 + 1] =  _makeValue({
      level_cfg_path = "level_editor.emergency_control.row_names[" .. i .. "].PercWin",
      min_value = 0
    })
    col7[#col7 + 1] =  _makeValue({
      level_cfg_path = "level_editor.emergency_control.row_names[" .. i .. "].Bonus"
    })
  end

  local section = _makeTableSection({
    title_path = "level_editor.titles.emergency_control",
    title_size = _TITLE_SIZE,
    label_col_width = 90, data_col_width = 90, value_width = 65,
    row_names = emergency_control_row_names,
    col_names = {
      "level_editor.emergency_control.col_names.StartMonth",
      "level_editor.emergency_control.col_names.EndMonth",
      "level_editor.emergency_control.col_names.Min",
      "level_editor.emergency_control.col_names.Max",
      "level_editor.emergency_control.col_names.Illness",
      "level_editor.emergency_control.col_names.PercWin",
      "level_editor.emergency_control.col_names.Bonus"
    },
    col_values = {col1, col2, col3, col4, col5, col6, col7},
  })

  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.emergency_control",
    section
  })
end

-- {{{ Awards (good_cond, bad_cond, good_bonus, bad_bonus, bonus_kind
local _awards = {
  {
    name = "Cures",
    good_cond = "awards_trophies.CuresAward",
    bad_cond = "awards_trophies.CuresPoor",
    good_bonus = "awards_trophies.CuresBonus",
    bad_bonus = "awards_trophies.CuresPenalty",
    bonus_kind = "money",
  }, {
    name = "Deaths",
    good_cond = "awards_trophies.DeathsAward",
    bad_cond = "awards_trophies.DeathsPoor",
    good_bonus = "awards_trophies.DeathsBonus",
    bad_bonus = "awards_trophies.DeathsPenalty",
    bonus_kind = "money",
  }, {
    name = "PopulationPercentage",
    good_cond = "awards_trophies.PopulationPercentageAward",
    bad_cond = "awards_trophies.PopulationPercentagePoor",
    good_bonus = "awards_trophies.PopulationPercentageBonus",
    bad_bonus = "awards_trophies.PopulationPercentagePenalty",
    bonus_kind = "reputation",
  }, {
    name = "CuresVDeaths",
    good_cond = "awards_trophies.CuresVDeathsAward",
    bad_cond = "awards_trophies.CuresVDeathsPoor",
    good_bonus = "awards_trophies.CuresVDeathsBonus",
    bad_bonus = "awards_trophies.CuresVDeathsPenalty",
    bonus_kind = "money",
  }, {
    name = "AwardReputation",
    good_cond = "awards_trophies.ReputationAward",
    bad_cond = "awards_trophies.ReputationPoor",
    good_bonus = "awards_trophies.AwardReputationBonus",
    bad_bonus = "awards_trophies.AwardReputationPenalty",
    bonus_kind = "money",
  }, {
    name = "HospValue",
    good_cond = "awards_trophies.HospValueAward",
    bad_cond = "awards_trophies.HospValuePoor",
    good_bonus = "awards_trophies.HospValueBonus",
    bad_bonus = "awards_trophies.HospValuePenalty",
    bonus_kind = "reputation",
  }, {
    name = "Cleanliness",
    good_cond = "awards_trophies.CleanlinessAward",
    bad_cond = "awards_trophies.CleanlinessPoor",
    good_bonus = "awards_trophies.CleanlinessBonus",
    bad_bonus = "awards_trophies.CleanlinessPenalty",
    bonus_kind = "reputation",
  }, {
    name = "Emergency",
    good_cond = "awards_trophies.EmergencyAward",
    bad_cond = "awards_trophies.EmergencyPoor",
    good_bonus = "awards_trophies.EmergencyBonus",
    bad_bonus = "awards_trophies.EmergencyPenalty",
    bonus_kind = "reputation",
  }, {
    name = "AwardStaffHappiness",
    good_cond = "awards_trophies.StaffHappinessAward",
    bad_cond = "awards_trophies.StaffHappinessPoor",
    good_bonus = "awards_trophies.AwardStaffHappinessBonus",
    bad_bonus = "awards_trophies.AwardStaffHappinessPenalty",
    bonus_kind = "reputation",
  }, {
    name = "PeepHappiness",
    good_cond = "awards_trophies.PeepHappinessAward",
    bad_cond = "awards_trophies.PeepHappinessPoor",
    good_bonus = "awards_trophies.PeepHappinessBonus",
    bad_bonus = "awards_trophies.PeepHappinessPenalty",
    bonus_kind = "reputation",
  }, {
    name = "WaitingTimes",
    good_cond = "awards_trophies.WaitingTimesAward",
    bad_cond = "awards_trophies.WaitingTimesPoor",
    good_bonus = "awards_trophies.WaitingTimesBonus",
    bad_bonus = "awards_trophies.WaitingTimesPenalty",
    bonus_kind = "reputation",
  }, {
    name = "WellKeptTech",
    good_cond = "awards_trophies.WellKeptTechAward",
    bad_cond = "awards_trophies.WellKeptTechPoor",
    good_bonus = "awards_trophies.WellKeptTechBonus",
    bad_bonus = "awards_trophies.WellKeptTechPenalty",
    bonus_kind = "reputation",
  }, {
    name = "NewTech",
    good_cond = "awards_trophies.NewTechAward",
    bad_cond = "awards_trophies.NewTechPoor",
    good_bonus = "awards_trophies.ResearchBonus",
    bad_bonus = "awards_trophies.ResearchPenalty",
    bonus_kind = "reputation",
  }
}
-- }}}
-- {{{ Trophies (optional good_cond, good_bonus, bonus_kind
local _trophies = {
  {
    name = "RatKillsAbsolute",
    good_cond = "awards_trophies.RatKillsAbsolute",
    good_bonus = "awards_trophies.RatKillsAbsoluteBonus",
    bonus_kind = "reputation",
  }, {
    name = "CansofCoke",
    good_cond = "awards_trophies.CansofCoke",
    good_bonus = "awards_trophies.CansofCokeBonus",
    bonus_kind = "money",
  }, {
    name = "TrophyReputation",
    good_cond = "awards_trophies.Reputation",
    good_bonus = "awards_trophies.TrophyReputationBonus",
    bonus_kind = "money",
  }, {
    name = "Plant",
    good_cond = "awards_trophies.Plant",
    good_bonus = "awards_trophies.PlantBonus",
    bonus_kind = "reputation",
  }, {
    name = "TrophyStaffHappiness",
    good_cond = "awards_trophies.TrophyStaffHappiness",
    good_bonus = "awards_trophies.TrophyStaffHappinessBonus",
    bonus_kind = "reputation",
  }, {
    name = "RatKillsPercentage",
    good_cond = "awards_trophies.RatKillsPercentage",
    good_bonus = "awards_trophies.RatKillsPercentageBonus",
    bonus_kind = "money",
  }, {
    name = "Mayor",
    good_cond = "awards_trophies.TrophyMayor",
    good_bonus = "awards_trophies.TrophyMayorBonus",
    bonus_kind = "reputation",
  }, {
    name = "Death",
    good_cond = nil, -- No deaths in a year.
    good_bonus = "awards_trophies.TrophyDeathBonus",
    bonus_kind = "money",
  }, {
    name = "Cures",
    good_cond = nil, -- Over 90% cure rate.
    good_bonus = "awards_trophies.TrophyCuresBonus",
    bonus_kind = "money",
  }, {
    name = "AllCures",
    good_cond = nil, -- No sent home and no deaths
    good_bonus = "awards_trophies.TrophyAllCuresBonus",
    bonus_kind = "money",
  }
}
-- }}}

local function _makeFixedCnditionBonusesSection()
  local values = {}
  for _, trophy in ipairs(_trophies) do
    if not trophy.good_cond then
      values[#values + 1] = _makeValue({level_cfg_path = trophy.good_bonus, name_path = true})
    end
  end

  values.title_path = "level_editor.titles.fixed_cond_trophies"
  values.title_size = _TITLE_SIZE
  values.label_size = Size(200, LevelValuesSection.VALUE_HEIGHT)
  return _makeValuesSection(values)
end

local function _makeRegularTrohpiesSection()
  local col1 = {}
  local col2 = {}
  local rows = {}
  for _, trophy in ipairs(_trophies) do
    if trophy.good_cond then
      rows[#rows + 1] = "level_editor.trophies.row_names." .. trophy.name
      col1[#col1 + 1] = _makeValue({level_cfg_path = trophy.good_condition})
      col2[#col2 + 1] = _makeValue({level_cfg_path = trophy.good_bonus})
    end
  end

  return _makeTableSection({
    title_path = "level_editor.titles.trophies",
    title_size = _TITLE_SIZE,
    label_col_width = _LABEL_COL_WIDTH, data_col_width = 100,
    col_names = {
      "level_editor.trophies.col_names.condition",
      "level_editor.trophies.col_names.bonus",
    },
    col_values = {col1, col2},
    row_names = rows
  })
end

local function _makeAwardsSection()
  local col1 = {}
  local col2 = {}
  local col3 = {}
  local col4 = {}
  local rows = {}
  for _, award in ipairs(_awards) do
    rows[#rows + 1] = "level_editor.awards.row_names." .. award.name
    col1[#col1 + 1] = _makeValue({level_cfg_path = award.good_condition})
    col2[#col2 + 1] = _makeValue({level_cfg_path = award.good_bonus})
    col3[#col3 + 1] = _makeValue({level_cfg_path = award.bad_condition})
    col4[#col4 + 1] = _makeValue({level_cfg_path = award.bad_bonus})
  end

  return _makeTableSection({
    title_path = "level_editor.titles.awards",
    title_size = _TITLE_SIZE,
    label_col_width = 200, data_col_width = _DATA_COL_WIDTH, value_width = 70,
    col_names = {
      "level_editor.awards.col_names.award_condition",
      "level_editor.awards.col_names.bonus",
      "level_editor.awards.col_names.poor_condition",
      "level_editor.awards.col_names.penalty",
    },
    col_values = {col1, col2, col3, col4},
    row_names = rows
  })
end

function UILevelEditor:_makeTrophiesEditPage()
  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.trophies",
    _makeFixedCnditionBonusesSection(),
    _makeRegularTrohpiesSection(),
  })
end

function UILevelEditor:_makeAwardsEditPage()
  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.awards",
    _makeAwardsSection()
  })
end

function UILevelEditor:_makeWinLoseCriteriaEditPage(kind)
  -- ENHANCEMENT: Make a drop-down for values with fixed range.
  -- ENHANCEMENT: Use a check-mark for on/off values.
  -- ENHANCEMENT: For a really nice UX, have groups to edit.
  local col1 = {}
  local col2 = {}
  local col3 = {}
  local col4 = {}
  local col5 = {}
  local sect_row_names = {}
  for i = 0, 5 do
    sect_row_names[#sect_row_names + 1] =
        "level_editor." .. kind .. "_criteria.row_names[" .. i .. "]"

    local crit_text = kind .. "_criteria[" .. i .."]"
    col1[#col1 + 1] = _makeValue({
      level_cfg_path = "level_editor." .. crit_text .. ".Criteria",
      min_value = 1,
      max_value = 6
    })
    col2[#col2 + 1] = _makeValue({
      level_cfg_path = "level_editor." .. crit_text .. ".MaxMin",
      min_value = 0,
      max_value = 1
    })
    col3[#col3 + 1] = _makeValue({
      level_cfg_path = "level_editor." .. crit_text .. ".Value"
    })
    col4[#col4 + 1] = _makeValue({
      level_cfg_path = "level_editor." .. crit_text .. ".Group"
    })
    col5[#col5 + 1] = _makeValue({
      level_cfg_path = "level_editor." .. crit_text .. ".Bound"
    })
  end

  local section = _makeTableSection({
    title_path = "level_editor.titles." .. kind .. "_criteria",
    row_names = sect_row_names,
    label_col_width = 100, data_col_width = 90,
    col_values = {col1, col2, col3, col4, col5},
    col_names = {
      "level_editor." .. kind .. "_criteria.col_names.Criteria",
      "level_editor." .. kind .. "_criteria.col_names.MaxMin",
      "level_editor." .. kind .. "_criteria.col_names.Value",
      "level_editor." .. kind .. "_criteria.col_names.Group",
      "level_editor." .. kind .. "_criteria.col_names.Bound"
    }
  })

  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names." .. kind .. "_criteria",
    section
  })
end

function UILevelEditor:_makeAiPlayersEditPage()
  local col1 = {}
  local col2 = {}
  local ai_row_names = {}
  for i = 0, 14 do
    ai_row_names[#ai_row_names + 1] = "level_editor.ai_players.row_names[" .. i .. "]"

    col1[#col1 + 1] = _makeValue({
      level_cfg_path = "computer[" .. i .. "].Playing",
      min_value = 0,
      max_value = 1
    })
    col2[#col2 + 1] = _makeValue({level_cfg_path = "computer[" .. i .. "].Name"})
  end

  local ai_platers_section = _makeTableSection({
    title_path = "level_editor.titles.ai_players",
    title_size = _TITLE_SIZE,
    label_col_width = 150, data_col_width = 130,
    row_names = ai_row_names,
    col_values = {col1, col2},
    col_names = {
      "level_editor.ai_players.col_names.playing",
      "level_editor.ai_players.col_names.name"
    }
  })

  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.ai_players",
    ai_platers_section
  })
end

function UILevelEditor:_makeMainTabPage()
  local staff_levels1, staff_levels2 = self:_makeStaffLevelsEditPage12()

  return _makeTabPageSection({
    self:_makeTownEditPage(),
    self:_makeTownLevelssEditPage(),
    self:_makePopulationEditPage(),
    self:_makeHospitalEditPage1(),
    self:_makeHospitalEditPage2(),
    self:_makeHospitalEditPage3(),
    self:_makeStaffEditPage(), staff_levels1, staff_levels2,
    self:_makeObjectsEditPage({{1, 12}}, 1),
    self:_makeObjectsEditPage({{13, 24}}, 2),
    self:_makeObjectsEditPage({{25, 36}}, 3),
    self:_makeObjectsEditPage({{36, 47}}, 4),
    self:_makeObjectsEditPage({{48, 61}}, 5),
    self:_makeRoomsCostEditPage({{7, 10}, 16, 22, {25, 29}}, 1),
    self:_makeRoomsCostEditPage({{12, 14}}, 2),
    self:_makeRoomsCostEditPage({11, 15, 15, {17, 24}, 30}, 3),
    self:_makeRoomExpertiseEditPage(),
    self:_makeDiseaseExpertiseEditPage({{2, 13}}, 1),
    self:_makeDiseaseExpertiseEditPage({{14, 25}}, 2),
    self:_makeDiseaseExpertiseEditPage({{26, 35}}, 3),
    self:_makeDiseasesExistenceEditPage("visuals", 0, 13, 1),
    self:_makeDiseasesExistenceEditPage("non_visuals", 0, 9, 1),
    self:_makeDiseasesExistenceEditPage("non_visuals", 10, 19, 2),
    self:_makeEmergencyControlEditPage(),
    self:_makeTrophiesEditPage(),
    self:_makeAwardsEditPage(),
    self:_makeWinLoseCriteriaEditPage("win"),
    self:_makeWinLoseCriteriaEditPage("lose"),
    self:_makeAiPlayersEditPage()
  })
end
