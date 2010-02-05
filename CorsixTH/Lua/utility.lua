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

--[[ Iterator factory for iterating over the deep children of a table.
  For example: for fn in values(_G, "*.remove") do fn() end
  Will call os.remove() and table.remove()
  There can be multiple wildcards (asterisks).
--]]
function values(root_table, wildcard)
  local wildcard_parts = {}
  for part in wildcard:gmatch("[^.]+") do
    wildcard_parts[#wildcard_parts + 1] = part
  end
  local keys = {}
  local function f()
    local value = root_table
    local nkey = 1
    for i, part in ipairs(wildcard_parts) do
      if part == "*" then
        local key = keys[nkey]
        if nkey >= #keys then
          key = next(value, key)
          keys[nkey] = key
          if key == nil then
            if nkey == 1 then
              return nil
            else
              return f()
            end
          end
        end
        value = value[key]
        nkey = nkey + 1
      else
        if type(value) ~= "table" then
          local mt = getmetatable(value)
          if not mt or not mt.__index then
            return f()
          end
        end
        value = value[part]
        if value == nil then
          return f()
        end
      end
    end
    return value
  end
  return f
end

-- Helper function to print the contents of a table. Child tables are printed recursively.
function print_table(obj, level)
  assert(type(obj) == "table", "Tried to print ".. tostring(obj) .." with print_table.")
  level = level or 0
--  if level > 0 then
--    return
--  end
  local spacer = ""
  for i = 1, level do
    spacer = spacer .. " "
  end
  for k, v in pairs(obj) do
    print(spacer .. k, v)
    if type(v) == "table" then
      print_table(v, level + 1)
    end
  end
end

-- Variation on loadfile() which allows for the loaded file to have global
-- references resolved in supplied tables. On failure, returns nil and an
-- error. On success, returns the file as a function just like loadfile() does
-- with the difference that the first argument to this function should be a
-- table in which globals are looked up and written to.
function loadfile_envcall(filename)
  if rawget(_G, "loadin") then
    -- Lua 5.2 lacks setfenv(), but does provide loadin()
    -- Unfortunately, loadin() doesn't work with filenames, so the file needs
    -- to be loaded first.
    local f, err = io.open(filename)
    if not f then
      return nil, err
    end
    local result = f:read"*l" or ""
    if result:sub(1, 1) == "#" then
      result = "\n" .. f:read"*a"
    else
      result = result .. "\n" .. f:read"*a"
    end
    f:close()
    -- loadin() still only allows a chunk to have an environment set once, so
    -- we give it an empty environment and use __[new]index metamethods on it
    -- to allow the same effect as changing the actual environment.
    local env_mt = {}
    result, err = loadin(setmetatable({}, env_mt), result, "@".. filename)
    if result then
      return function(env, ...)
        env_mt.__index = env
        env_mt.__newindex = env
        return result(...)
      end
    else
      return result, err
    end
  else
    -- Lua 5.1 has setfenv(), which allows environments to be set at runtime
    local result, err = loadfile(filename)
    if result then
      return function(env, ...)
        setfenv(result, env)
        return result(...)
      end
    else
      return result, err
    end
  end
end
