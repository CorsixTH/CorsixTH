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

-- Force local variables to be used for everything (except for explicity
-- declared variables and any code running in derestriced mode). This helps to
-- catch typos in variable names, and promotes usage of locals over globals
-- (which improves speed).

local rawset, error, tostring
    = rawset, error, tostring
local strict_mt = {}
local allowed_globals = setmetatable({}, {__mode = "k"})

local function newindex(t, k, v)
  if allowed_globals[k] then
    rawset(t, k, v)
  else
    error("assign to undeclared variable \'" .. tostring(k) .. "\'", 2)
  end
end

local function index(t, k)
  if allowed_globals[k] then
    return nil
  else
    error("use of undeclared variable \'" .. tostring(k) .. "\'", 2)
  end
end

local function restrict(ni, i, ...)
  strict_mt.__newindex = ni
  strict_mt.__index = i
  return ...
end
restrict(newindex, index)

--!! Wrap a function so that it is freely able to set global variables
--[[ Some existing functions (for example, `require`) should be allowed to read
     and write global variables without having to worry about declaring them
     with `strict_declare_global`.
    !param fn The function which should be able to freely set globals
    !return A new function which acts just as `fn` and is free to set globals
    !example
     require = destrict(require) ]]
function destrict(fn)
  return function(...)
    local ni, i = strict_mt.__newindex, strict_mt.__index
    strict_mt.__newindex, strict_mt.__index = nil
    return restrict(ni, i, fn(...))
  end
end

--!! Declare a global variable so that it can later be used
--[[!param name The name of the global to declare
    !example
     strict_declare_global "some_var"
     some_var = 42 ]]
function strict_declare_global(name)
  allowed_globals[name] = true
end

setmetatable(_G, strict_mt)
