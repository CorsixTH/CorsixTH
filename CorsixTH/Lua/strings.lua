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

local lfs = require "lfs"
local TH = require "TH"
local type, loadfile, pcall, tostring, setfenv, setmetatable, math_random
    = type, loadfile, pcall, tostring, setfenv, setmetatable, math.random
local rawset, rawget
    = rawset, rawget

class "Strings"

function Strings:Strings(app)
  self.app = app
end

function Strings:init()
  -- Load (but do not execute) everything from the language directory
  -- Note that files are loaded with loadfile_envcall
  self.language_chunks = {}
  local ourpath = debug.getinfo(1, "S").source:sub(2, -12)
  local pathsep = package.config:sub(1,1)
  local path = ourpath .. "languages" .. pathsep
  for file in lfs.dir(path) do
    if file:match"%.lua$" then
      local result, err = loadfile_envcall(path .. file)
      if not result then
        print("Error loading languages" .. pathsep ..  file .. ":\n" .. tostring(err))
      else
        self.language_chunks[result] = "languages" .. pathsep .. file
      end
    end
  end
  
  -- Build the language table from Language() calls
  -- Every file in the languages folder should have a call to Language() near
  -- the start of the file which gives the names for the language. These names
  -- are used to link the user's choice of language to a file, and to link the
  -- names given to Inherit() to a file.
  self.language_to_chunk = {}
  for chunk, filename in pairs(self.language_chunks) do
    -- To allow the file to set global variables without causing an error, it
    -- is given an infinite table as an environment. Reading a non-existant
    -- key from an infinite table returns another infinite table, rather than
    -- the default value of nil.
    local infinite_table_mt
    infinite_table_mt = {
      __index = function(t, k)
        return setmetatable({}, infinite_table_mt)
      end
    }
    -- To abort evaluation of the chunk after Language() is called, a unique
    -- marker is used as an error message. The other alternative would be to
    -- do complex co-routine calls. A freshly made empty table is a suitable
    -- unique marker.
    local good_error_marker = {}
    local env = setmetatable({
      Language = function(...)
        -- Associate every passed name with this file, case-independently
        for _, name in pairs{...} do
          self.language_to_chunk[name:lower()] = chunk
        end
        error(good_error_marker)
      end,
      -- Set Inherit and SetSpeechFile to do nothing
      Inherit = function() end,
      SetSpeechFile = function() end,
      -- Set LoadStrings to return an infinite table
      LoadStrings = infinite_table_mt.__index,
    }, infinite_table_mt)
    -- Actually run the language file
    local status, err = pcall(chunk, env)
    if not status and err ~= good_error_marker then
      print("Error evaluating " .. filename .. ":\n" .. tostring(err))
    end
  end
end

-- String tables are shadowed so that all access to a string table goes
-- through a metamethod (which is desirable to catch invalid reads, provide
-- "__random", and prevent writes). This means that every string table is in
-- fact empty, and has it's keys and values stored in a separate table, called
-- the shadow table. The shadows table is used to associate a shadow table
-- with a string table.
local shadows = setmetatable({}, {__mode = "k"})

-- Metatable which is used for all tables returned by Strings:load()
-- The end effect is to raise errors on accesses to non-existant strings, to
-- add a special string called "__random" to each table (which always resolves
-- to a random string from the table), and to prevent editing or adding to a
-- string table.
local strings_metatable = {
  __index = function(t, k)
    t = shadows[t]
    local v = t[k]
    if v ~= nil then
      return v
    end
    if k ~= "__random" then
      error("Non-existant string: " .. k, 2)
    end
    local candidates = {}
    for k, v in pairs(t) do
      candidates[#candidates + 1] = v
    end
    return candidates[math_random(1, #candidates)]
  end,
  __newindex = function(t, k, v)
    error("String tables are read-only", 2)
  end,
}

function Strings:load(language)
  assert(language ~= "original_strings", "Original strings can not be loaded directly. Please select a proper language.")
  -- env is the table of globals to execute to the language file in, and hence
  -- it also stores the resulting strings.
  local env = {}
  shadows[env] = {}
  -- speech_file holds the result of any call to SetSpeechFile()
  local speech_file
  local functions = {
    -- Calling the Langauage() function should have no effect any more
    Language = function() end,
    -- Inherit() should evaluate the named language in the current environment
    Inherit = function(language, ...)
      self:_loadPrivate(language, env, ...)
    end,
    -- LoadStrings() should return the original game string table
    LoadStrings = function(filename)
      return assert(TH.LoadStrings(self.app:readDataFile(filename)),
                    "Cannot load original string file '"..filename.."'")
    end,
    -- SetSpeechFile() should remember the named file to return to our caller
    SetSpeechFile = function(...)
      speech_file = ...
    end,
  }
  -- The metatable on the environment is set so that the above functions look
  -- like top-level level globals, so that the environment behaves like an
  -- infinite table, and so that assignments are merged into the string table.
  local metatable
  metatable = {
    __index = function(t, k)
      -- Make the functions look like top-level globals
      local shadow = shadows[t]
      local value = ((t == env) and functions[k]) or shadow[k]
      if value == nil then
        value = setmetatable({}, metatable)
        shadow[k] = value
        shadows[value] = {}
      end
      return value
    end,
    __newindex = function(t, k, v)
      if type(v) ~= "table" then
        -- non-table values cannot be merged
        shadows[t][k] = v
      else
        -- v should be merged into t[k]
        -- Perform t[k][k2] = v2 for each (k2, v2) in v to recursively merge
        t = t[k]
        for k2, v2 in pairs(v) do
          t[k2] = v2
        end
      end
    end,
  }
  -- Evaluate the language file
  setmetatable(env, metatable)
  self:_loadPrivate(language, env)
  -- Change the metamethods on every string table to match strings_metatable
  metatable.__index = strings_metatable.__index
  metatable.__newindex = strings_metatable.__newindex
  return env, speech_file
end

function Strings:_loadPrivate(language, env, ...)
  local chunk = self.language_to_chunk[language:lower()]
  if not chunk then
    print_table(self.language_to_chunk)
    error("Language '".. language .."' could not be found.")
  end
  local status, err = pcall(chunk, env, ...)
  if not status then
    print("Error evaluating " .. self.language_chunks[chunk] .. ":\n" .. tostring(err))
  end
end
