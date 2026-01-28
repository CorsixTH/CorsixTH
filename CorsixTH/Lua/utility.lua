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
    for _, part in ipairs(wildcard_parts) do
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

-- Can return the length of any table, where as #table_name is only suitable for use with arrays of one contiguous part without nil values.
function table_length(table)
  local count = 0
  for _,_ in pairs(table) do
    count = count + 1
  end
  return count
end

--! Get a random item from an array.
--!param array Array with 0 or more items.
--!return (nil or an item)
function getRandomEntryFromArray(array)
  if #array == 0 then return nil end
  if #array == 1 then return array[1] end
  return array[math.random(1, #array)]
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

if _G._VERSION == "Lua 5.1" then
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
else
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
end

-- Make pairs() and ipairs() respect metamethods (they already do in Lua 5.2)
do
  local metamethod_called = false
  pairs(setmetatable({}, {__pairs = function() metamethod_called = true end}))
  if not metamethod_called then
    local next = next
    local getmetatable = getmetatable
    pairs = function(t) -- luacheck: ignore 121
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
    ipairs = function(t) -- luacheck: ignore 121
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
DrawFlags.Nearest         = 2^14

-- Order of animations within a tile. Animations with a smaller number are
-- drawn first.
DrawingLayers = {}
DrawingLayers.Litter = 0
DrawingLayers.Door = 0
DrawingLayers.RatHole = 0
DrawingLayers.NorthSideObject = 1
DrawingLayers.WestSideObject = 2
DrawingLayers.AtomAnalyser = 3
DrawingLayers.ReceptionistFacingUser = 3 -- Facing east or south.
DrawingLayers.Entity = 4 -- All 'normal' animations.
DrawingLayers.ReceptionistFacingAway = 5 -- Facing west or north.
DrawingLayers.MachineSmoke = 6 -- smoke animation should be in front of machine (entity)
DrawingLayers.FloatingDollars = 7
DrawingLayers.EastSideObject = 8
DrawingLayers.SouthSideObject = 9

-- Keep in sync with animation_effect in th_gfx_common.h
AnimationEffect = {}
AnimationEffect.None = 0
AnimationEffect.Glowing = 1
AnimationEffect.Jelly = 2

-- Compare values of two simple (non-nested) tables
function compare_tables(t1, t2)
  local count1 = 0
  for k, v in pairs(t1) do
    count1 = count1 + 1
    if t2[k] ~= v then return false end
  end
  local count2 = 0
  for _, _ in pairs(t2) do
    count2 = count2 + 1
  end
  if count1 ~= count2 then return false end
  return true
end

-- Convert a list to a set
function list_to_set(list)
  local set = {}
  for _, v in ipairs(list) do
    set[v] = true
  end
  return set
end

--! Find the smallest bucket with its upper value less or equal to a given number,
--! and return the value of the bucket, or its index.
--!param number (number) Value to accept by the bucket.
--!param buckets (list) Available buckets, pairs of {upper=x, value=y} tables,
--  in increasing x value, where nil is taken as infinite. The y value is
--  returned for the first bucket in the list where number <= x (in normal mode).
--  If y is nil, the index of the bucket in the list is returned.
--!param alt_mode (boolean) If true, the comparison becomes number < x instead.
--!return (number) Value or index of the matching bucket.
function rangeMapLookup(number, buckets, alt_mode)
  local function boundaryCheck(upper)
    return alt_mode and upper > number or upper >= number
  end

  for index, bucket in ipairs(buckets) do
    if not bucket.upper or boundaryCheck(bucket.upper) then
      return bucket.value or index
    end
  end
  assert(false) -- Should never get here.
end

-- this is a pseudo bitwise OR operation
-- assumes value2 is always a power of 2 (limits carry errors in the addition)
-- mimics the logic of hasBit with the addition if bit not set
--!param value1 (int) value to check set bit of
--!param value2 (int) power of 2 value - bit enumeration
--!return (int) value1 and value2 'bitwise' or.
function bitOr(value1, value2)
  return value1 % (value2 + value2) >= value2 and value1 or value1 + value2
end

--! Check bit is set
--!param value (int) value to check set bit of
--!param bit (int) 0-base index of bit to check
--!return (boolean) true if bit is set.
function hasBit(value, bit)
  local p = 2 ^ bit
  return value % (p + p) >= p
end

--! Convert an array table to a string.
--! Joins each elements by the provided separator. As a convenience feature
--! if the input is not an array it will be converted to a string and
--! returned.
--!param array (table) array to join.
--!param separator (string) separator between elements.
--!return (string) The joined string.
function array_join(array, separator)
  separator = separator or ","

  if type(array) ~= "table" then
    return tostring(array)
  end

  if array[1] == nil then
    return ""
  end

  local result = tostring(array[1])
  local i = 2
  while array[i] ~= nil do
    result = result .. separator
    result = result .. tostring(array[i])
    i = i + 1
  end

  return result
end

local function serialize_string(val, options)
  local level = options and options.long_bracket_level_start or 0
  while string.find(val, ']' .. string.rep('=', level) .. ']') do
    level = level + 1
  end

  return '[' .. string.rep('=', level) .. '[' .. val .. ']' .. string.rep('=', level) .. ']'
end

-- Helper function to print the contents of a table. Child tables are printed recursively.
-- Call without specifying depth, only obj and (if wished) max_depth.
local function serialize_table(obj, options, depth, pt_reflist)
  -- Used to prevent infinite loops
  pt_reflist = pt_reflist or {}
  options = options or {detect_cycles = true} -- By default, don't crash on cycles.
  depth = depth or 1

  if options.max_depth and depth > options.max_depth then
    return "{...}"
  end

  for _, ref in ipairs(pt_reflist) do
    if ref == obj then
      if options.detect_cycles then
        return "<reference loop>"
      elseif not options.max_depth then
        assert("Infinite loop detected. Specify detect_cycles or max_depth when serializing tables that may contain cycles")
      end
    end
  end
  pt_reflist[#pt_reflist + 1] = obj

  local first = true
  local indent = string.rep(" ", depth * 2)
  local result = "{"
  local max_array_index = 0
  for i, v in ipairs(obj) do
    max_array_index = i
    if not first then
      result = result .. ","
    end
    first = false
    if options.pretty then
      result = result .. "\n" .. indent
    end
    result = result .. serialize(v, options, depth + 1, pt_reflist)
  end

  for k, v in pairs(obj) do
    if not(type(k) == "number" and k >= 1 and k <= max_array_index) then
      if not first then
        result = result .. ','
      end
      first = false
      if options.pretty then
        result = result .. '\n' .. indent
      end

      result = result .. "[ "
      result = result .. serialize(k, options, depth + 1, pt_reflist)
      result = result .. " ]="
      result = result .. serialize(v, options, depth + 1, pt_reflist)
    end
  end
  indent = string.rep(" ", (depth - 1) * 2)

  if options.pretty then
    result = result .. '\n' .. indent
  end
  result = result .. "}"

  return result
end

--! Serialize a value. Call it with the value to serialize and print the output.
--  By default it will end recursion when a cycle is detected.
--!param val Value to serialize.
--!param options Option settings, table, 'detect_cycles' field boolean that
--  ends recursion on a cycle, and 'max_depth' integer that ends recursion at the
--  specified depth. By default initialized with "{detect_cycles = True}"
--  'long_bracket_level_start' field integer that sets the starting long bracket level for escaping strings.
--  If not set, level zero is used.
--!param depth Recursion depth, should be omitted.
--!param pt_reflist Seen nodes, should be omitted.
--!return The serialized output.
function serialize(val, options, depth, pt_reflist)
  if type(val) == "string" then
    return serialize_string(val, options)
  elseif type(val) == "table" then
    return serialize_table(val, options, depth, pt_reflist)
  else
    return tostring(val)
  end
end

--! Simplified interface for serializing a value with option for depth
-- See serialize for further explanation
-- Output is dumped to the console
--!param value A table or string to inspect
--!param depth (num) Optional, defaults at 1
function inspect(value, depth)
  print(serialize(value, {detect_cycles = true, max_depth = depth or 1, pretty = true}))
end

-- Clones a table, but only the first level.
function shallow_clone(tbl)
  if type(tbl) ~= "table" then return tbl end
  local meta = getmetatable(tbl)
  local target = {}
  for k, v in pairs(tbl) do
    target[k] = v
  end
  setmetatable(target, meta)
  return target
end

--! Complete key removal and pause collection for the duration of the function
--! call.
--!
--! Note that the function is run as a pcall, so any error will be caught and
--! returned.
--!param fn (function) Function to call while GC is paused.
--!param ... Arguments to pass to fn.
function pause_gc_and_use_weak_keys(fn, ...)
  -- In Lua 5.2 and later tables with weak keys (__mode = "k") may hold keys
  -- that have already been finalized. According to the Lua reference manual
  -- the objects are marked and finalized in one cycle and collected and
  -- removed from the weak table keys in the next cycle. So to ensure that
  -- all finalized keys are removed from weak tables we need to run GC for 2
  -- complete cycles. We then stop the GC to prevent it from running during
  -- the function call to ensure that pairs on weak tables work as expected.
  -- Finally we restart the GC after the function call.
  collectgarbage()
  collectgarbage()
  collectgarbage("stop")
  local res = {pcall(fn, ...)}
  collectgarbage("restart")

  return unpack(res)
end
