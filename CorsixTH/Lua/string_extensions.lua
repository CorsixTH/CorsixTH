--[[ Copyright (c) 2011 Manuel "Roujin" Wolf

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

local TH = require "TH"
local lpeg = require "lpeg"
local type = type
local _unwrap = TH.stringProxy._unwrap

function TH.stringProxy.gsub(str, patt, repl)
  local str_was_proxy, patt_was_proxy, repl_was_proxy
  str, str_was_proxy = _unwrap(str)
  patt, patt_was_proxy = _unwrap(patt)
  local result
  local t = type(repl)
  if t == "table" then
    result = str:gsub(patt, function(cap)
      local res, was_proxy = _unwrap(repl[cap])
      if was_proxy then
        repl_was_proxy = true
      end
      return res
    end)
  elseif t == "function" then
    result = str:gsub(patt, function(...)
      local res, was_proxy = _unwrap(repl(...))
      if was_proxy then
        repl_was_proxy = true
      end
      return res
    end)
  else
    repl, repl_was_proxy = _unwrap(repl)
    result = str:gsub(patt, repl)
  end
  if str_was_proxy or patt_was_proxy or repl_was_proxy then
    result = TH.stringProxy(result, TH.stringProxy.gsub, str, patt, repl)
  end
  return result
end

local format_pattern = lpeg.Cs(
  (
    (
      -- %% to %
      lpeg.P"%%" / "%%" +
      -- Old-style (%s) and (%d)
      lpeg.C("%" * lpeg.S"sd" * lpeg.Carg(1)) / function(key, args)
        local idx = args.idx + 1
        args.idx = idx
        local arg, proxy_found = _unwrap(args[idx])
        local t = type(arg)
        if key == "%d" and t == "number"
        -- NB: Numbers are allowed for %s as well to allow concatenation with number.
        -- TODO the third check should really be class.is(arg, TH.stringProxy), but
        -- it doesn't currently work due to TH.stringProxy overriding __index
        or key == "%s" and (t == "string"
                         or t == "number"
                         or t == "userdata") then
          if proxy_found then
            args.proxy_found = true
          end
          return arg
        end
        return key
      end +
      -- New-style %([1-9])% and %([1-9]):([a-zA-Z0-9_.]-)%
      lpeg.C("%" * lpeg.C(lpeg.R"19") *
        (":" * lpeg.C(lpeg.R("az","AZ","09","__","..")^1) + lpeg.Cc(nil))
      * "%" * lpeg.Carg(1)) / function(str, key, tab, args)
        local val, proxy_found = _unwrap(args[tonumber(key)])
        if val == nil then return str end -- abort
        if tab then
          local string_table = _S
          for part in tab:gmatch"[^.]+" do
            string_table = string_table[part]
            if not string_table then return str end -- abort
          end
          if not string_table[val] then return str end -- abort
          val = _unwrap(string_table[val])
          proxy_found = true
        end
        if proxy_found then
          args.proxy_found = true
        end
        return val
      end
    ) + 1
  ) ^ 0
)

--! Custom format function for our proxy strings.
--! Keywords for replacing are: %s, %d, %%, %[num]% and %[num]:[tab]%
--! NB: %s and %d are only replaced if none of the new keywords (%[num]% and %[num]:[tab]%) are present.
--! NB: Always escape percent sign (i.e. use %% instead of %) in strings with formatting keywords! Failure
--!     to do so can cause unwanted behavior.
--! 
--! Keywords:
--!  %s, %d        : replaced with the n-th parameter, if the type matches (%s = string, %d = number).
--!  %%            : replaced by single percent sign "%". Needed for escaping.
--!  %[num]%       : ([num] between 1-9) replaced by [num]-th parameter.
--!  %[num]:[tab]% : replaced by string obtained by indexing string table _S.[tab] with [num]-th parameter.
--!param str (string, stringProxy) the string that contains keywords to be replaced
--!param ... (string, stringProxy, number) parameters to be inserted in the string (or used for lookup)
--!return formatted stringProxy, if any of the result's components was a stringProxy, else formatted string
function TH.stringProxy.format(str, ...)
  local args = {idx = 0, ...}
  local str_was_proxy
  str, str_was_proxy = _unwrap(str)
  local result = format_pattern:match(str, 1, args)
  if str_was_proxy or args.proxy_found then
    result = TH.stringProxy(result, TH.stringProxy.format, str, ...)
  end
  return result
end

for _, method_name in ipairs{"gsub", "format"} do
  permanent("TH.stringProxy.".. method_name, TH.stringProxy[method_name])
end
