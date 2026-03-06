--[[
Copyright (c) 2021 Toby "tobylane"
Copyright (c) 2026 Stephen "TheCycoONE" Baker

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
SOFTWARE.

This will write the default configuration to WindowsInstaller/config_template.txt
--]]

local do_not_wrap = {}
do_not_wrap['SCREEN_FULLSCREEN'] = true
do_not_wrap['SCREEN_SIZE_WIDTH'] = true
do_not_wrap['SCREEN_SIZE_HEIGHT'] = true

function serialize(s)
  if type(s) ~= 'string' or do_not_wrap[s] then
    return tostring(s)
  end

  return '[[' .. s .. ']]'
end
function loadstring_envcall() end
local pathsep = package.config:sub(1, 1)
local function path(tbl)
  return table.concat(tbl, pathsep)
end

local config_path = path({"CorsixTH", "Lua", "config_finder.lua"})
local config_finder = dofile(config_path)
local config_values = config_finder.config_defaults()
config_values.fullscreen = [[SCREEN_FULLSCREEN]]
config_values.width = [[SCREEN_SIZE_WIDTH]]
config_values.height = [[SCREEN_SIZE_HEIGHT]]
config_values.language = [[LANGUAGE_CHOSEN]]
config_values.theme_hospital_install = [[ORIGINAL_HOSPITAL_DIRECTORY]]

local template_path = path({"WindowsInstaller", "config_template.txt"})
local _, err = config_finder.save_config(template_path, config_values)
if err then
  print("Error:", err)
end
