--[[ Copyright (c) 2018 Pavel "sofo" Schoffer

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

--[[
  Path is meant to unify the logic connected with file path operations.
--]]

class "Path"

---@type Path
local Path = _G["Path"]

local _separator = package.config:sub(1, 1)

--[[
  Returns correct separator for current OS.
]]
function Path.getSeparator()
  return _separator
end

function Path.concat(...)
  local path = select(1, ...)
  for i = 2, select("#", ...) do
    path = Path._concatTwo(path, select(i, ...))
  end
  return path
end

-- PRIVATE

function Path._concatTwo(a, b)
  if a:sub(-1) == _separator then
    return a .. b
  else
    return a .. _separator .. b
  end
end
