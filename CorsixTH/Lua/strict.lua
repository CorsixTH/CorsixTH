--[[ Copyright (c) 2009 Peter "Corsix" Cawley

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

-- Force local variables to be used for everything except functions (and for
-- any code running in derestriced mode). This helps to catch typos in variable
-- names, and promotes usage of locals over globals (which improves speed).

local type, rawset, error, tostring
    = type, rawset, error, tostring
local strict_mt = {}

local function newindex(t, k, v)
  if type(v) == "function" then
    rawset(t, k, v)
  else
    error("assign to undeclared variable \'" .. tostring(k) .. "\'", 2)
  end
end

local function index(t, k)
  error("use of undeclared variable \'" .. tostring(k) .. "\'", 2)
end

local function restrict(...)
  strict_mt.__newindex = newindex
  strict_mt.__index = index
  return ...
end
restrict()

function destrict(fn)
  return function(...)
    strict_mt.__newindex = nil
    strict_mt.__index = nil
    return restrict(fn(...))
  end
end

setmetatable(_G, strict_mt)
