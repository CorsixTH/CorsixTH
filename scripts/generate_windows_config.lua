--[[ Copyright (c) 2021 Toby "tobylane"

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

function serialize() end
function loadstring_envcall() end
local pathsep = package.config:sub(1, 1)
local function path(tbl)
  return table.concat(tbl, pathsep)
end

local config_path = path({"CorsixTH", "Lua", "config_finder.lua"})
local config_data = select(6, dofile(config_path))

local template_path = path({"WindowsInstaller", "config_template.txt"})
local f, err = io.open(template_path, "w")

if err then
  print("Error:", err)
else
  f:write(config_data)
  f:close()
end
