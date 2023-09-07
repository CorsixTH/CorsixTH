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

function UILevelEditor:_makeTownSection()
  return _makeValuesSection({
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
end

function UILevelEditor:_makeTownEditPage()
  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.town",
    self:_makeTownSection(),
  })
end

function UILevelEditor:_makeHospitalResearchSection()
  return _makeValuesSection({
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
end

function UILevelEditor:_makeHospitalTrainingSection()
  return _makeValuesSection({
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
end

function UILevelEditor:_makeHospitalEpidemicsSection()
  return _makeValuesSection({
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
end

function UILevelEditor:_makeHospitalEditPage1()
  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.hospital1",
    self:_makeHospitalResearchSection(),
    self:_makeHospitalTrainingSection()
  })
end

function UILevelEditor:_makeHospitalEditPage2()
  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.hospital2",
    self:_makeHospitalEpidemicsSection()
  })
end

function UILevelEditor:_makeStaffMinSalariesSection()
  return _makeValuesSection({
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
end

function UILevelEditor:_makeStaffAdditionalSalariesSection()
  return _makeValuesSection({
    title_path = "level_editor.titles.medical_bonuses",
    title_size = _TITLE_SIZE,
    label_size = Size(300, LevelValuesSection.VALUE_HEIGHT),
  name_path = "level_editor.doctor_add_salaries.name",
  _makeValue({level_cfg_path = "gbv.SalaryAdd[3]", name_path = true, tooltip_path = true}),
  _makeValue({level_cfg_path = "gbv.SalaryAdd[4]", name_path = true}),
  _makeValue({level_cfg_path = "gbv.SalaryAdd[5]", name_path = true}),
  _makeValue({level_cfg_path = "gbv.SalaryAdd[6]", name_path = true}),
  _makeValue({level_cfg_path = "gbv.SalaryAdd[7]", name_path = true}),
  _makeValue({level_cfg_path = "gbv.SalaryAdd[8]", name_path = true}),
})
end

function UILevelEditor:_makeStaffEditPage1()
  return _makeEditPageSection({
    tab_name_path = "level_editor.tab_names.staff1",
    self:_makeStaffMinSalariesSection(),
    self:_makeStaffAdditionalSalariesSection(),
  })
end

function UILevelEditor:_makeMainTabPage()
  return _makeTabPageSection({
    self:_makeTownEditPage(),
    self:_makeHospitalEditPage1(),
    self:_makeHospitalEditPage2(),
    self:_makeStaffEditPage1(),
  })
end
