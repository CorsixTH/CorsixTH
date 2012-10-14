--[[ Copyright (c) 2010 Peter "Corsix" Cawley

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

local function transform(code)
  local parts = {}
  local c_end_pos = 1
  local c_start_pos = code:find("<!", 1, true)
  while c_start_pos do
    parts[#parts + 1] = (" do end(...)(%q);"):format(code:sub(c_end_pos, c_start_pos - 1))
    local extra = ""
    if code:sub(c_start_pos + 2, c_start_pos + 2) == "=" then
      parts[#parts + 1] = " do end(...)("
      extra = ");"
      c_start_pos = c_start_pos + 1
    end
    c_end_pos = c_start_pos
    while true do
      local com_pos = code:find("--", c_end_pos, true)
      local str_pos, _, str_mkr = code:find("([\'\"])", c_end_pos)
      local lng_pos, _, lng_mkr = code:find("%[(=+)%[", c_end_pos)
      local end_pos = code:find("!>", c_end_pos, true) or (#code + 1)
      c_end_pos = math.min(com_pos or end_pos, str_pos or end_pos, lng_pos or end_pos, end_pos)
      if end_pos == c_end_pos then
        parts[#parts + 1] = code:sub(c_start_pos + 2, c_end_pos - 1) .. extra
        break
      end
      if lng_pos and com_pos and lng_pos == com_pos + 2 and com_pos == c_end_pos then
        c_end_pos = lng_pos
      end
      if com_pos == c_end_pos then
        c_end_pos = code:find("[\r\n]", c_end_pos) or (#code + 1)
      elseif str_pos == c_end_pos then
        local patt = "[\\"..str_mkr.."]"
        repeat
          str_pos, _, str_mkr = code:find(patt, str_pos + 1)
        until not str_pos or str_mkr ~= "\\"
        c_end_pos = (str_pos or #code) + 1
      else
        c_end_pos = (code:find("]" .. lng_mkr .. "]", c_end_pos, true) or #code) + 1
      end
    end
    c_end_pos = c_end_pos + 2
    c_start_pos = code:find("<!", c_end_pos, true)
  end
  return table.concat(parts) .. (" do end(...)(%q)"):format(code:sub(c_end_pos, -1))
end

local templates = setmetatable({}, {__index = function(t, fname)
  local f = assert(io.open("templates/".. fname ..".htlua", "r"))
  local data = f:read"*a"
  if data:sub(1, 1) == "#" then
    data = data:sub(data:find"[\r\n]", -1)
  end
  data = transform(data)
  f:close()
  local wrapper
  if not rawget(_G, "setfenv") then
    data = "return function(_ENV, ...) local _template = template local function template(name) local t = _template(name) return function(args) return t(args, _ENV) end end ".. data .." end"
    local template = assert(loadstring(data, "@".. fname ..".htlua"))()
    wrapper = function(env, caller_env)
      caller_env = caller_env or _G
      local env_wrap = setmetatable({}, {__index = function(t, k)
        return env[k] or caller_env[k]
      end})
      local output = {}
      template(env_wrap, function(x) output[#output + 1] = tostring(x) end)
      return table.concat(output)
    end
  else
    local template = assert(loadstring(data, "@".. fname ..".htlua"))
    wrapper = function(env)
      local old_env = getfenv(template)
      local caller_env = getfenv(2)
      local env_wrap = setmetatable({}, {__index = function(t, k)
        return env[k] or caller_env[k]
      end})
      setfenv(template, env_wrap)
      local output = {}
      template(function(x) output[#output + 1] = tostring(x) end)
      setfenv(template, old_env)
      return table.concat(output)
    end
  end
  t[fname] = wrapper
  return t[fname]
end})

function template(name)
  return templates[name]
end
