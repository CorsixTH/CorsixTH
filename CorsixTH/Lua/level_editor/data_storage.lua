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

local TEXT_BG = {red = 20, green = 150, blue = 200}
local TEXT_FG = {red = 20, green = 20, blue = 20}
local PANEL_BG = {red = 130, green = 70, blue= 43}
local PANEL_FG = {red= 80, green = 170, blue = 100}

local TITLE_LABEL_SETTINGS = {
  fg = {red = 120, green = 100, blue = 80},
  bg = {red = 80, green = 20, blue = 30},
  align = "center"
}
local NAME_LABEL_SETTINGS = {
  fg = {red = 20, green = 100, blue = 180},
  bg = {red = 80, green = 120, blue = 80},
  align = "left"
}

--! Get a translated string by name.
--!param name (str) Name of the translated string to get.
--!return (text) The retrieved translated string.
local function getTranslatedText(name)
  print("Getting translated text: " .. name)
  return TreeAccess.readTree(_S, name)
end

--! Make a bevel for some text.
--!param window Window to attach the panel to.
--!param widgets (Array of Panel) Storage for created panels. Appended in-place.
--!param x (int) X position of the top-left corner.
--!param y (int) Y position of the top-left corner.
--!param size (Size) Width and height of the panel.
--!param name_path (string) String path for the text to display.
--!param tooltip_path (string) String path for the tooltip to show.
--!param settings Optional settings to override the defaults (foreground,
--  background, alignment).
local function _makeLabel(window, widgets, x, y, size, name_path, tooltip_path, settings)
  local fg = settings and settings.fg or PANEL_FG
  local bg = settings and settings.bg or PANEL_BG
  local align = settings and settings.align or "left"
  local panel = window:addBevelPanel(x, y, size.w, size.h, fg, bg)
  if name_path then
    panel:setLabel(getTranslatedText(name_path), nil, align)
    if tooltip_path then
      panel:setTooltip(getTranslatedText(tooltip_path))
    end
  end
  widgets[#widgets + 1] = panel
  return panel
end

--! Make a textbox for entering a number.
--!param window Window to attach the panel to.
--!param widgets (Array of Panel) Storage for created text boxes. Appended in-place.
--!param text_boxes (array of text boxes) Storage for created text boxes, appended in-place.
--!param x (int) X position of the top-left corner.
--!param y (int) Y position of the top-left corner.
--!param size (Size) Width and height of the panel.
--!param value (LevelValue) Value displayed and edited in the box.
local function _makeTextBox(window, text_boxes, x, y, size, value)
  local text_box = window:addBevelPanel(x, y, size.w, size.h, TEXT_BG, TEXT_FG)
  local function confirm_cb() value:confirm() end
  local function abort_cb() value:abort() end
  text_box = text_box:makeTextbox(confirm_cb, abort_cb)
  text_boxes[#text_boxes + 1] = text_box

  value.text_box = text_box
  value:setBoxValue()
end

--! Make a button for the tab page.
--!param window Window to attach the panel to.
--!param widgets (Array of Panel) Storage for created buttons. Appended in-place.
--!param x (int) X position of the top-left corner.
--!param y (int) Y position of the top-left corner.
--!param size (Size) Width and height of the panel.
--!param callback Function to call when clicked.
--!param text_path Name of the translated string to display at the button.
local function _makeButton(window, widgets, x, y, size, callback, text_path)
  local panel = window:addBevelPanel(x, y, size.w, size.h, PANEL_BG, PANEL_FG)
  local button = panel:makeButton(0, 0, size.w, size.h, nil, callback, nil, nil)
  button.panel_lowered_active = false
  if text_path then button:setLabel(getTranslatedText(text_path)) end
  widgets[#widgets + 1] = button
end

--! A nummeric value to be edited.
class "LevelValue"

---@type LevelValue
local LevelValue = _G["LevelValue"]

--! Integer level configuration value in the level config editor.
--!param level_cfg_path (str) Absolute path in the level configuration file for
--    this value.
--!param name_path (nil str) Optional absolute path to the name string in the
--    language files for this value.
--!param tooltip_path (nil str) If present, absolute path to the tooltip
--    string in the language files for this value.
--!param min_value (nil integer) If present the lowest allowed value of this
--    value.
--!param max_value (nil integer) If present the highest allowed value of this
--    value.
function LevelValue:LevelValue(level_cfg_path, name_path, tooltip_path,
    min_value, max_value)
  self.level_cfg_path = level_cfg_path
  self.name_path = name_path
  self.tooltip_path = tooltip_path
  self.min_value = min_value
  self.max_value = max_value
  assert(not self.min_value or not self.max_value or self.min_value <= self.max_value)

  self.text_box = nil -- Text box for the value in the editor, set in _makeTextBox.
  self.current_value = nil -- Current value.
end

--! Load the value from the level config file or write the value into a *new* level
--  config file.
--!param cfg (nested tables with values) Level config file to read or create.
--!param store (bool) If, write the value to a new spot in the level config, else
--  read the value and update the current value.
function LevelValue:loadSaveConfig(cfg, store)
  if store then
    -- Save the value to the configuration.
    TreeAccess.addTree(cfg, self.level_cfg_path, self.current_value)
  else
    -- Load the value from the configuration.
    local number = TreeAccess.readTree(cfg, self.level_cfg_path)
    self:setBoxValue(number)
    if TheApp.config.debug and not number then
      -- Warn developers about non-existing entries in the loaded file.
      print("Warning: Level configuration \"" .. self.level_cfg_path ..
          "\" does not exist in the file.")
    end
  end
end

--! Set the value of the setting to the supplied value or to a default value.
--!param value (optional integer) Value to use if supplied.
function LevelValue:setBoxValue(value)
  if not value then value = self.current_value end

  if type(value) ~= "number" then value = 0 end
  if self.min_value and value < self.min_value then value = self.min_value end
  if self.max_value and value > self.max_value then value = self.max_value end
  self.current_value = math.floor(value) -- Ensure it's an integer even if the bounds are not.

  self.text_box:setText(tostring(self.current_value))
end

--! Callback that the user confirmed entering a new value. Apply it.
function LevelValue:confirm()
  self.current_value = tonumber(self.text_box.text) or self.current_value
  self:setBoxValue()
end

--! Callback that the user aborted editing, revert to the last stored value.
function LevelValue:abort()
  self:setBoxValue()
end

--! Common base class for an editable area in the level editor.
class "LevelSection"

---@type LevelSection
local LevelSection = _G["LevelSection"]

--! Base class for editing a group of values.
--!param title_path (str) Language path to the title name string.
function LevelSection:LevelSection(title_path)
  assert(title_path, "Missing title path")
  self.title_path = title_path -- Displayed name of the section.
  self._widgets = {} -- Widgets of the section.
  self._text_boxes = {} -- Text boxes of the section.

  self.title_size = Size(100, 25)
end

--! Set visibility of the widgets to the value of the parameter.
--!param is_visible (bool) Whether the widgets and/or text boxes should be visible.
function LevelSection:setVisible(is_visible)
  for _, widget in ipairs(self._widgets) do
    widget:setVisible(is_visible)
  end
  for _, box in ipairs(self._text_boxes) do
    box:setVisible(is_visible)
  end
end

--! Configure the size of the title area.
--!param sz Desired size of the title area.
function LevelSection:setTitleSize(sz)
  self.title_size = sz
  return self
end

--! Construct the elements displayed at the window.
--!param window (Window) Window to add the new widgets.
--!param pos (Pos) Position of the to-left corner available to use.
--!return (Pos) Bottom of the used area.
function LevelSection:layout(window, pos)
  assert(false, "Implement me in " .. class.type(self))
end

--! Section with one or more related values.
class "LevelValuesSection" (LevelSection)

---@type LevelValuesSection
local LevelValuesSection = _G["LevelValuesSection"]

LevelValuesSection.LABEL_WIDTH = 100
LevelValuesSection.VALUE_HEIGHT = 15
LevelValuesSection.VALUE_WIDTH = 50

--! Section with one or more related values.
--!param title_path (str) Language path to the title name string.
--!param values (array of LevelValue), values descriptions.
function LevelValuesSection:LevelValuesSection(title_path, values)
  LevelSection.LevelSection(self, title_path)
  self.values = values -- Array.

  self.label_size = Size(LevelValuesSection.LABEL_WIDTH, LevelValuesSection.VALUE_HEIGHT)
  self.value_size = Size(LevelValuesSection.VALUE_WIDTH, LevelValuesSection.VALUE_HEIGHT)
  self.title_sep = 5
  self.value_sep = 1 -- Vertical separator between values.
  self.label_sep = 2 -- Horizontal space after label.
end

--! Set the size of the "label" text box of each value in the section.
--!param sz (Size) Desired size of each the label area of each value.
function LevelValuesSection:setLabelSize(sz)
  assert(class.type(sz) == "Size")
  self.label_size = sz
  return self
end

--! Set the size of the "value" text box of each value in the section.
--!param sz (Size) Desired size of each the value text-box of each value.
function LevelValuesSection:setValueSize(sz)
  assert(class.type(sz) == "Size")
  self.value_size = sz
  return self
end

--! Configure vertical spacing.
--!param title_sep (int) Vertical empty space between the title box and the values.
--!param value_sep (int) Vertical empty space between two adjacent values in the section.
function LevelValuesSection:setVertSep(title_sep, value_sep)
  assert(type(title_sep, "number"))
  assert(type(value_sep, "number"))
  self.title_sep = title_sep
  self.value_sep = value_sep
  return self
end

--! Construct widgets in the window, with the top-left corner of the section at pos.
--!param window Window to add the new widgets.
--!param pos Top-left position of the area.
function LevelValuesSection:layout(window, pos)
  -- Clear widgets and text boxes.
  self._widgets = {}
  self._text_boxes = {}

  local x, y = pos.x, pos.y
  -- Title.
  if self.title_path then
    _makeLabel(window, self._widgets, x, y, self.title_size, self.title_path, nil, TITLE_LABEL_SETTINGS)
    y = y + self.title_size.h + self.title_sep
  end
  -- Editable values below the title.
  local label_x = x
  local val_x = label_x + self.label_size.w + self.value_sep
  for idx, val in ipairs(self.values) do
    if idx > 1 then y = y + self.value_sep end
    _makeLabel(window, self._widgets, label_x, y, self.label_size, val.name_path, val.tooltip_path, NAME_LABEL_SETTINGS)
    _makeTextBox(window, self._text_boxes, val_x, y, self.value_size, val)
    y = y + self.label_size.h
  end
  self:setVisible(false) -- Initially hide all.

  return y
end

--! Load the values from the level config or write the values into a *new*
--  level config.
--!param cfg (nested tables with values) Level config file to read or create.
--!param store (bool) If set, write the value to a new spot in the level config,
--  else read the value and update the current value.
function LevelValuesSection:loadSaveConfig(cfg, store)
  for _, val in ipairs(self.values) do val:loadSaveConfig(cfg, store) end
end

--! Section with a 2D table of editable values.
class "LevelTableSection" (LevelSection)

---@type LevelTableSection
local LevelTableSection = _G["LevelTableSection"]

--! Section that associates one or more values for each index in a domain.
--!param title_path (str) Language path to the title name string.
--!param row_name_paths String names for row labels.
--!param row_tooltip_paths String names for row label tooltips.
--!param col_name_paths String names for column labels.
--!param col_tooltip_paths String names for column tooltips.
--!param values (array of column array of Value) Values in the table.
function LevelTableSection:LevelTableSection(title_path, row_name_paths,
    row_tooltip_paths, col_name_paths, col_tooltip_paths, values)
  LevelSection.LevelSection(self, title_path)
  self.row_name_paths = row_name_paths or {}
  self.row_tooltip_paths = row_tooltip_paths or {}
  self.col_name_paths = col_name_paths or {}
  self.col_tooltip_paths = col_tooltip_paths or {}
  self.values = values -- Array of column arrays.

  assert(values)

  local table_rows_cols = self:_getTableColsRows()
  -- Verify dimensions (hor, vert).
  assert(#self.row_name_paths == table_rows_cols.h,
      "Unequal number of rows: names = " .. #self.row_name_paths
      .. ", values height = " .. table_rows_cols.h)
  assert(#self.col_name_paths == table_rows_cols.w,
      "Unequal number of columns: names = " .. #self.col_name_paths
      .. ", values width = " .. table_rows_cols.w)

  for i, c in ipairs(values) do
    assert(#c == table_rows_cols.h,
        "Column " .. i .. ": count=" .. #c .. ", height=" .. table_rows_cols.h)
  end

  self.title_size = Size(200, 25) -- Size of the title.
  self.title_sep = 10 -- Amount of vertical space between the title and the column names,
  self.row_label_sep = 5 -- Amount of vertical space between the column names and the first row.
  self.col_label_sep = 10 -- Amount of horizontal space between the row names and the first column.
  self.label_col_width = 100 -- Width of the label column.
  self.data_col_width = self.label_col_width -- Width of columns.
  self.row_height = 18 -- Height of a row values (also sets the row label).
  self.intercol_sep = 5 -- Horizontal space between two columns in the table.
  self.interrow_sep = 2 -- Vertical space between two rows in the table.
end

--! Get the number of rows and columns of the table.
--!return (Size) Number of columns, number of rows.
function LevelTableSection:_getTableColsRows()
  -- 'values' has column arrays.
  local num_cols = #self.values
  local num_rows = #self.values[1]
  return Size(num_cols, num_rows)
end

--! Set the amount of vertical space between the title and the column labels.
--!param sep (int) Vertical space between the title and the column labels.
function LevelTableSection:setTitleSep(sep)
  self.title_sep = sep
  return self
end

--! Construct widgets in the window for displaying and editing values in the table.
--!param window (Window) Window to add the new widgets.
--!param pos (Pos) Position of the to-left corner.
function LevelTableSection:layout(window, pos)
  self._widgets = {}
  self._text_boxes = {}

  local x, y = pos.x, pos.y
  local max_x = x
  -- Title.
  if self.title_path then
    _makeLabel(window, self._widgets, x, y, self.title_size, self.title_path, nil, TITLE_LABEL_SETTINGS)
    y = y + self.title_size.h + self.title_sep
    max_x = math.max(max_x, x + self.title_size.w)
  end

  local table_rows_cols = self:_getTableColsRows()

  local label_size = Size(self.label_col_width, self.row_height) -- Size of the first column.
  local datacol_size = Size(self.data_col_width, self.row_height) -- Size of the other columns.
  -- Column headers above the data values (2nd row and further).
  x = pos.x + label_size.w + self.col_label_sep -- Skip space for the row labels
  for col = 1, table_rows_cols.w do
    _makeLabel(window, self._widgets, x, y, datacol_size, self.col_name_paths[col],
        self.col_tooltip_paths[col], NAME_LABEL_SETTINGS)
    x = x + datacol_size.w
    if col < table_rows_cols.w then x = x + self.intercol_sep end
  end
  max_x = math.max(max_x, x)
  y = y + self.row_height + self.row_label_sep

  -- Rows (label at the left as well as all data columns).
  for row = 1, table_rows_cols.h do
    x = pos.x
    _makeLabel(window, self._widgets, x, y, label_size, self.row_name_paths[row],
        self.row_tooltip_paths[row], NAME_LABEL_SETTINGS)
    x = x + label_size.w + self.col_label_sep
    for col = 1, table_rows_cols.w do
      assert(self.values[col][row], "No value found at row " .. row .. ", column " .. col)
      _makeTextBox(window, self._text_boxes, x, y, datacol_size, self.values[col][row])
      x = x + datacol_size.w
      if col < table_rows_cols.w then x = x + self.intercol_sep end
    end
    max_x = math.max(max_x, x)
    y = y + self.row_height
    if row < table_rows_cols.h then y = y + self.interrow_sep end
  end
  self:setVisible(false) -- Initially hide all.

  return y
end

--! Load the values from the level config or write the values into a *new*
--  level config.
--!param cfg (nested tables with values) Level config file to read or create.
--!param store (bool) If set, write the value to a new spot in the level config,
--  else read the value and update the current value.
function LevelTableSection:loadSaveConfig(cfg, store)
  for _, vals_col in ipairs(self.values) do
    for _, val in ipairs(vals_col) do val:loadSaveConfig(cfg, store) end
  end
end

--! An abstract "page" at the screen for editing level configuration values.
class "LevelPage"
local LevelPage = _G["LevelPage"]

-- Abstract base class.
function LevelPage:LevelPage()
  self._widgets = {}
end

--! Load the values from the level config or write the values into a *new*
--  level config.
--!param cfg (nested tables with values) Level config file to read or create.
--!param store (bool) If set, write the value to a new spot in the level config,
--  else read the value and update the current value.
function LevelPage:loadSaveConfig(cfg, store)
  error("Implement me in " .. class.type(self))
end

--! Set visibility of the widgets to the value of the parameter.
--!param is_visible (bool) Whether the widgets and/or text boxes should be visible.
function LevelPage:setVisible(is_visible)
  error("Implement me in " .. class.type(self))
end

--! A "screen" with displayed sections that can be edited.
class "LevelEditPage" (LevelPage)

---@type LevelEditPage
local LevelEditPage = _G["LevelEditPage"]

--! A 'screen' with values that can be modified.
--!param tab_name_path Path in _S with the tab-name of the page.
--!param sections (array of LevelSection) Sections of settings that can be
--    edited in this screen.
function LevelEditPage:LevelEditPage(tab_name_path, sections)
  LevelPage.LevelPage(self)

  assert(tab_name_path, "Missing string name of the tab-name text.")
  self.tab_name_path = tab_name_path -- Name of the page in a tab of a tab-page.
  self.sections = sections -- Array of sections displayed at the page.

  self._widgets = {} -- Widgets of the page.
end

--! Set visibility of the widgets to the value of the parameter.
--!param is_visible (bool) Whether the widgets and/or text boxes should be visible.
function LevelEditPage:setVisible(is_visible)
  for _, widget in ipairs(self._widgets) do
    widget:setVisible(is_visible)
  end
  for _, section in ipairs(self.sections) do
    section:setVisible(is_visible)
  end
end

local INTER_SECTION_VERT_SPACE = 10 -- Vertical space between two editable sections.

--! Compute layout of the elements at the page.
--!param window Window to add the new widgets.
--!param pos (Pos) Position of the to-left corner.
--!param size (Size) Size if the page.
function LevelEditPage:layout(window, pos, size)
  self._widgets = {}

  -- As the displayed sections have a title, the edit page itself does not need
  -- to display a title.

  -- Naively assume that all sections together fit in the available space.
  local top_pos = pos.y
  for _, section in ipairs(self.sections) do
    local bottom_pos = section:layout(window, Pos(pos.x, top_pos))
    top_pos = bottom_pos + INTER_SECTION_VERT_SPACE
  end
  self:setVisible(false) -- Initially hide the edit page.
end

--! Load the value from the level config or write the value into a *new* level
--  config file.
--!param cfg (nested tables with values) Level config file to read or create.
--!param store (bool) If, write the value to a new spot in the level config, else
--  read the value and update the current value.
function LevelEditPage:loadSaveConfig(cfg, store)
  for _, sect in ipairs(self.sections) do sect:loadSaveConfig(cfg, store) end
end

--! Class with tabs to select a child editpage, and room to display the selected page.
class "LevelTabPage" (LevelPage)

---@type LevelTabPage
local LevelTabPage = _G["LevelTabPage"]

function LevelTabPage:LevelTabPage(edit_pages)
  LevelPage.LevelPage(self)

  self._level_pages = edit_pages -- Array of LevelPage.
  self._selected_page = nil -- Index of selected page in edit_pages.

  self._page_tab_size = Size(90, 20) -- Size of a tab with a edit page name

  -- Amount of vertical space between the page tab rows and the top of a
  -- displayed edit page.
  self._edit_sep = 10
end

--! Compute layout of the elements at the page.
--!param window Window to add the new widgets.
--!param pos (Pos) Position of the to-left corner.
--!param size (Size) Size if the page.
function LevelTabPage:layout(window, pos, size)
  local tabs_per_row = math.floor(size.w / self._page_tab_size.w)
  tabs_per_row = (tabs_per_row < 1) and 1 or tabs_per_row
  local remaining_hor = math.max(0, size.w - tabs_per_row * self._page_tab_size.w)
  local indent = math.floor(remaining_hor / 2)

  -- Add edit-page tabs.
  local ypos = pos.y
  local xpos =indent + pos.x
  local placed_tabs = 0
  for i, level_page in ipairs(self._level_pages) do
    if placed_tabs >= tabs_per_row then -- Row full.
      ypos = ypos + self._page_tab_size.h
      xpos = indent + pos.x
      placed_tabs = 0
    end
    local callback = --[[persistable:LevelTabPage_onClickTab]] function() self:onClickTab(i) end
    _makeButton(window, self._widgets, xpos, ypos, self._page_tab_size, callback, level_page.tab_name_path)
    xpos = xpos + self._page_tab_size.w
    placed_tabs = placed_tabs + 1
  end
  ypos = ypos + self._page_tab_size.h + self._edit_sep -- Top of edit pages.

  -- Add the level pages.
  local edit_page_pos = Pos(pos.x, ypos)
  local edit_page_size = Size(size.w, size.h - (ypos - pos.y))
  assert(edit_page_size.h > 0)
  for _, level_page in ipairs(self._level_pages) do
    level_page:layout(window, edit_page_pos, edit_page_size)
  end
end

-- User selected a page to display.
--!param page_num Selected page.
function LevelTabPage:onClickTab(page_num)
  if page_num ~= self._selected_page then
    if page_num >= 1 and page_num <= #self._level_pages then
      if self._selected_page then -- Hide previous selection, first time there is none.
        self._level_pages[self._selected_page]:setVisible(false)
      end
      self._selected_page = page_num -- And select/show new selection.
      self._level_pages[self._selected_page]:setVisible(true)
    end
  end
end

function LevelTabPage:loadSaveConfig(cfg, store)
  for _, page in ipairs(self._level_pages) do
    page:loadSaveConfig(cfg, store)
  end
end
