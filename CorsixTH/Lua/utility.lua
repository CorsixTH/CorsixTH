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

-- Used to prevent infinite loops
local pt_reflist = {}

-- Helper function to print the contents of a table. Child tables are printed recursively.
-- Call without specifying level, only obj and (if wished) max_level.
function print_table(obj, max_level, level)
  assert(type(obj) == "table", "Tried to print " .. tostring(obj) .. " with print_table.")
  pt_reflist[#pt_reflist + 1] = obj
  level = level or 0
  local spacer = ""
  for i = 1, level do
    spacer = spacer .. " "
  end
  for k, v in pairs(obj) do
    print(spacer .. tostring(k), v)
    if type(k) == "table" then
      -- a set, recurse further into k, instead of v
      v = k
    end
    if type(v) == "table" and (not max_level or max_level > level) then
      -- check for reference loops
      local found_ref = false
      for _, ref in ipairs(pt_reflist) do
        if ref == v then
          found_ref = true
        end
      end
      if found_ref then
        print(spacer .. " " .. "<reference loop>")
      else
        print_table(v, max_level, level + 1)
      end
    end
  end
  pt_reflist[#pt_reflist] = nil
end

-- Can return the length of any table, where as #table_name is only suitable for use with arrays of one contiguous part without nil values.
function table_length(table)
  local count = 0
  for _,_ in pairs(table) do
    count = count + 1
  end
  return count
end

--! Checks if a file exists and is readable.
--!param path (string)
--!param root_path (boolean) Optional, default: false. If true the file's path
-- will be appended to the CorsixTH root directory's path. 
--!return (String) Returns an error message for the file read error or nil.
function is_file_unreadable(path, root_path)
  if root_path then
    local root_dir = debug.getinfo(1, "S").source:sub(2, -26) .. package.config:sub(1, 1)
    path = root_dir .. path
  end
  local file, error_message = io.open(path, "r")
  if file then
    io.close(file)
  else
    return error_message
  end
end

-- Variation on loadfile() which allows for the loaded file to have global
-- references resolved in supplied tables. On failure, returns nil and an
-- error. On success, returns the file as a function just like loadfile() does
-- with the difference that the first argument to this function should be a
-- table in which globals are looked up and written to.
-- Note: Unlike normal loadfile, this version also accepts files which start
-- with the UTF-8 byte order marker
function loadfile_envcall(filename)
  -- Read file contents
  local f, err = io.open(filename)
  if not f then
    return nil, err
  end
  local result = f:read(4)
  if result == "\239\187\191#" then
    -- UTF-8 BOM plus Unix Shebang
    result = f:read("*a"):gsub("^[^\r\n]*", "", 1)
  elseif result:sub(1, 3) == "\239\187\191" then
    -- UTF-8 BOM
    result = result:sub(4,4) .. f:read("*a")
  elseif result:sub(1, 1) == "#" then
    -- Unix Shebang
    result = (result .. f:read("*a")):gsub("^[^\r\n]*", "", 1)
  else
    -- Normal
    result = result .. f:read("*a")
  end
  f:close()
  return loadstring_envcall(result, "@" .. filename)
end

if _G._VERSION == "Lua 5.2" or _G._VERSION == "Lua 5.3" then
  function loadstring_envcall(contents, chunkname)
    -- Lua 5.2+ lacks setfenv()
    -- load() still only allows a chunk to have an environment set once, so
    -- we give it an empty environment and use __[new]index metamethods on it
    -- to allow the same effect as changing the actual environment.
    local env_mt = {}
    local result, err = load(contents, chunkname, "bt", setmetatable({}, env_mt))
    if result then
      return function(env, ...)
        env_mt.__index = env
        env_mt.__newindex = env
        return result(...)
      end
    else
      return result, err
    end
  end
else
  function loadstring_envcall(contents, chunkname)
    -- Lua 5.1 has setfenv(), which allows environments to be set at runtime
    local result, err = loadstring(contents, chunkname)
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

-- Make pairs() and ipairs() respect metamethods (they already do in Lua 5.2)
do
  local metamethod_called = false
  pairs(setmetatable({}, {__pairs = function() metamethod_called = true end}))
  if not metamethod_called then
    local next = next
    local getmetatable = getmetatable
    pairs = function(t)
      local mt = getmetatable(t)
      if mt then
        local __pairs = mt.__pairs
        if __pairs then
          return __pairs(t)
        end
      end
      return next, t
    end
  end
  metamethod_called = false
  ipairs(setmetatable({}, {__ipairs = function() metamethod_called = true end}))
  if not metamethod_called then
    local ipairs_orig = ipairs
    ipairs = function(t)
      local mt = getmetatable(t)
      if mt then
        local __ipairs = mt.__ipairs
        if __ipairs then
          return __ipairs(t)
        end
      end
      return ipairs_orig(t)
    end
  end
end

-- Helper functions for flags
-- NB: flag must be a SINGLE flag, i.e. a power of two: 1, 2, 4, 8, ...

-- Check if flag is set in flags
function flag_isset(flags, flag)
  flags = flags % (2*flag)
  return flags >= flag
end

-- Set flag in flags and return new flags (unchanged if flag was already set).
function flag_set(flags, flag)
  if not flag_isset(flags, flag) then
    flags = flags + flag
  end
  return flags
end

-- Clear flag in flags and return new flags (unchanged if flag was already cleared).
function flag_clear(flags, flag)
  if flag_isset(flags, flag) then
    flags = flags - flag
  end
  return flags
end

-- Toggle flag in flags, i.e. set if currently cleared, clear if currently set.
function flag_toggle(flags, flag)
  return flag_isset(flags, flag) and flag_clear(flags, flag) or flag_set(flags, flag)
end

-- Various constants
DrawFlags = {}
DrawFlags.FlipHorizontal  = 2^0
DrawFlags.FlipVertical    = 2^1
DrawFlags.Alpha50         = 2^2
DrawFlags.Alpha75         = 2^3
DrawFlags.AltPalette      = 2^4
DrawFlags.EarlyList       = 2^10
DrawFlags.ListBottom      = 2^11
DrawFlags.BoundBoxHitTest = 2^12
DrawFlags.Crop            = 2^13

-- Compare values of two simple (non-nested) tables
function compare_tables(t1, t2)
  local count1 = 0
  for k, v in pairs(t1) do
    count1 = count1 + 1
    if t2[k] ~= v then return false end
  end
  local count2 = 0
  for k, v in pairs(t2) do
    count2 = count2 + 1
  end
  if count1 ~= count2 then return false end
  return true
end

-- Convert a list to a set
function list_to_set(list)
  local set = {}
  for i, v in ipairs(list) do
    set[v] = true
  end
  return set
end

--! Find the smallest bucket with its upper value less or equal to a given number,
--! and return the value of the bucket, or its index.
--!param number (number) Value to accept by the bucket.
--!param buckets (list) Available buckets, pairs of {upper=x, value=y} tables,
--  in increasing x value, where nil is taken as infinite. The y value is
--  returned for the first bucket in the list where number <= x. If y is nil,
--  the index of the bucket in the list is returned.
--!return (number) Value or index of the matching bucket.
function rangeMapLookup(number, buckets)
  for index, bucket in ipairs(buckets) do
    if not bucket.upper or bucket.upper >= number then
      return bucket.value or index
    end
  end
  assert(false) -- Should never get here.
end
