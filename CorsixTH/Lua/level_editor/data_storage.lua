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

--! A nummeric value to be edited.
class "LevelValue"

--@type LevelValue
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

  self._text_box = nil -- Text box for the value in the editor.
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

  if self._text_box then -- Avoid a crash when updated without having a text box.
    self._text_box:setText(tostring(self.current_value))
  end
end

--! Callback that the user confirmed entering a new value. Apply it.
function LevelValue:confirm()
  self.current_value = tonumber(self._text_box.text) or self.current_value
  self:setBoxValue()
end

--! Callback that the user aborted editing, revert to the last stored value.
function LevelValue:abort()
  self:setBoxValue()
end

