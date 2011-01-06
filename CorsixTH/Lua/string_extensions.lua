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
  local args = {...}
  
  -- %% and new keywords %[num]% and %[num]:[tab]%
  local found = false
  local proxy_found = false
  local result = TH.stringProxy.gsub(str, "(%%([1-9]?)(:?)([^%%]*)%%)",
    --[[persistable:App_our_format_new]] function(str, key, sep, tab)
    if key == "" and sep == "" and tab == "" then
      return "%"
    end
    local val = args[tonumber(key)]
    if val == nil then return str end -- abort
    if sep == ":" then
      local string_table = _S
      for part in tab:gmatch"[^.]+" do
        string_table = string_table[part]
        if not string_table then return str end -- abort
      end
      if not string_table[val] then return str end -- abort
      val = string_table[val]
    end
    found = true
    proxy_found = proxy_found or type(val) == "userdata"
    return val
  end)
  
  if not found then
    -- Compatibility with old keywords: %d, %s and %%
    local idx = 0
    result = TH.stringProxy.gsub(str, "(%%([ds%%]))",
      --[[persistable:App_our_format_compat]] function(str, key)
      if key == "%" then return "%" end
      idx = idx + 1
      local arg = args[idx]
      if key == "d" and type(arg) == "number"
      -- NB: Numbers are allowed for %s as well to allow concatenation with number.
      -- TODO the third check should really be class.is(arg, TH.stringProxy), but
      -- it doesn't currently work due to TH.stringProxy overriding __index
      or key == "s" and (type(arg) == "string"
                      or type(arg) == "number"
                      or type(arg) == "userdata") then
        proxy_found = proxy_found or type(arg) == "userdata"
        return arg
      end
      return str
    end)
  end
  
  -- Convert result to stringProxy if input string was string but a stringProxy was inserted
  if type(str) == "string" and proxy_found then
    result = TH.stringProxy(result)
  end
  
  return result
end

