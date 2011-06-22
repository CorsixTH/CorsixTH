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

--! Layer which handles the loading of localised text.
class "Strings"

function Strings:Strings(app)
  self.app = app
end

local utf8conv
local cp437conv
local function id(...) return ... end

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
  -- names given to Inherit() to a file. The first name is used as the official
  -- name for this language, the others may be abbreviations or such.
  self.languages = {}
  self.language_to_chunk = {}
  self.chunk_to_font = {}
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
      utf8 = id,
      cp437 = cp437conv,
      pairs = pairs,
      Language = function(...)
        local names = {...}
        -- Use the first name for display purposes (case-dependent!).
        if names[1] ~= "original_strings" then
          self.languages[#self.languages + 1] = names[1]
        end
        -- Associate every passed name with this file, case-independently
        for _, name in pairs(names) do
          self.language_to_chunk[name:lower()] = chunk
        end
        error(good_error_marker)
      end,
      Font = function(...)
        self.chunk_to_font[chunk] = ...
      end,
      -- Set Inherit and SetSpeechFile to do nothing
      Inherit = function() end,
      SetSpeechFile = function() end,
      Encoding = function() end,
      -- Set LoadStrings to return an infinite table
      LoadStrings = infinite_table_mt.__index,
    }, infinite_table_mt)
    -- Actually run the language file
    local status, err = pcall(chunk, env)
    if not status and err ~= good_error_marker then
      print("Error evaluating " .. filename .. ":\n" .. tostring(err))
    end
  end
  table.sort(self.languages)
end

-- String tables are shadowed so that all access to a string table goes
-- through a metamethod (which is desirable to catch invalid reads, provide
-- "__random", and prevent writes). This means that every string table is in
-- fact empty, and has it's keys and values stored in a separate table, called
-- the shadow table. The shadows table is used to associate a shadow table
-- with a string table.
local shadows = setmetatable({}, {__mode = "k"})

-- Metatable which is used for all tables returned by Strings:load()
-- The end effect is to raise errors on accesses to non-existant strings
-- (unless no_restriction is set to true), to add a special string called
-- "__random" to each table (which always resolves to a random string from
-- the table), and to prevent editing or adding to a string table.
local strings_metatable = function(no_restriction) return {
  __index = function(t, k)
    t = shadows[t]
    local v = t[k]
    if v ~= nil then
      return v
    end
    if k ~= "__random" then
      if no_restriction then return nil end
      error("Non-existant string: " .. tostring(k), 2)
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
  __pairs = function(t)
    return pairs(shadows[t])
  end,
  __ipairs = function(t)
    return ipairs(shadows[t])
  end,
} end

-- no_restriction disables errors on access to non-existant strings (for debug purposes)
-- no_inheritance disables inheritance except original_strings (for debug purposes)
function Strings:load(language, no_restriction, no_inheritance)
  assert(language ~= "original_strings", "Original strings can not be loaded directly. Please select a proper language.")
  -- env is the table of globals to execute to the language file in, and hence
  -- it also stores the resulting strings.
  local env = {}
  shadows[env] = {}
  -- speech_file holds the result of any call to SetSpeechFile()
  local speech_file
  local default_encoding = id
  local encoding = default_encoding
  local language_called = false
  local functions; functions = {
    -- Convert UTF-8 to the file's default encoding
    utf8 = function(s)
      if encoding == cp437conv then
        return utf8conv(s)
      else
        return s
      end
    end,
    -- Convert CP437 to the file's default encoding
    cp437 = function(s)
      if encoding == cp437conv then
        return s
      else
        return cp437conv(s)
      end
    end,
    ipairs = ipairs,
    pairs = pairs,
    -- Calling the Langauage() function should have no effect any more
    Language = function()
      language_called = true
    end,
    Font = function()
      if language_called then
        error("Font declaration must occur before Language declaration")
      end
    end,
    -- Inherit() should evaluate the named language in the current environment
    -- NB: Inheritance of any but original_strings disabled when no_inheritance set
    Inherit = function(language, ...)
      if no_inheritance and language ~= "original_strings" then return end
      local old_encoding = encoding
      encoding = default_encoding
      local old_language_called = language_called
      language_called = false
      self:_loadPrivate(language, env, ...)
      encoding = old_encoding
      language_called = old_language_called
    end,
    -- Encoding() should set the default encoding for the remainder of the file
    Encoding = function(new_encoding)
      if new_encoding == functions.utf8 then
        encoding = id
      elseif new_encoding == functions.cp437 then
        encoding = cp437conv
      else
        error("Invalid encoding; expected utf8 or cp437")
      end
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
    _G = env,
    type = type,
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
      local ty = type(v)
      if ty ~= "table" then
        -- non-table values cannot be merged
        if ty == "string" then
          -- convert from file's default encoding to UTF-8
          v = encoding(v)
        end
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
  metatable.__pairs = strings_metatable(no_restriction).__pairs
  -- Evaluate the language file
  setmetatable(env, metatable)
  self:_loadPrivate(language, env)
  -- Change the metamethods on every string table to match strings_metatable
  for k, v in pairs(strings_metatable(no_restriction)) do
    metatable[k] = v
  end
  return env, speech_file
end

--! Get the Font() declaration of a language, if there was one.
function Strings:getFont(language)
  local chunk = self.language_to_chunk[language:lower()]
  return chunk and self.chunk_to_font[chunk]
end

function Strings:_loadPrivate(language, env, ...)
  local chunk = self.language_to_chunk[language:lower()]
  if not chunk then -- If selected language could not be found, try to revert to English
    print_table(self.language_to_chunk)
    print("Language '".. language .."' could not be found. Reverting to English.")
    chunk = self.language_to_chunk["english"]
    if not chunk then -- If english could not be found, raise an error
      error("Language 'English' could not be found. Please verify your installation.")
    end
  end
  local status, err = pcall(chunk, env, ...)
  if not status then
    print("Error evaluating " .. self.language_chunks[chunk] .. ":\n" .. tostring(err))
  end
end

-- Primitive system to map UTF-8 characters onto Code Page 437.
-- Provided so that language scripts can encode text in a modern and well
-- supported manner, and have the text automatically transcoded into the
-- encoding which the Theme Hospital fonts use.

local codepoints_to_cp437 = {
  -- Below 0x80 need no translation
  [0xC7] = 0x80, -- majuscule c-cedilla
  [0xFC] = 0x81, -- minuscule u-umlaut
  [0xE9] = 0x82, -- minuscule e-acute
  [0xE2] = 0x83, -- minuscule a-circumflex
  [0xE4] = 0x84, -- minuscule a-umlaut
  [0xE0] = 0x85, -- minuscule a-grave
  [0xE5] = 0x86, -- minuscule a-ring
  [0xE7] = 0x87, -- minuscule c-cedilla
  [0xEA] = 0x88, -- minuscule e-circumflex
  [0xEB] = 0x89, -- minuscule e-umlaut
  [0xE8] = 0x8A, -- minuscule e-grave
  [0xEF] = 0x8B, -- minuscule i-umlaut
  [0xEE] = 0x8C, -- minuscule i-circumflex
  [0xEC] = 0x8D, -- minuscule i-grave
  [0xC4] = 0x8E, -- majuscule a-umlaut
  [0xC5] = 0x8F, -- majuscule a-ring
  [0xC9] = 0x90, -- majuscule e-acute
  [0xE6] = 0x91, -- minuscule ae
  [0xC6] = 0x91, -- majuscule ae (not in TH fonts - mapped to minuscule ae)
  [0xF4] = 0x93, -- minuscule o-circumflex
  [0xF6] = 0x94, -- minuscule o-umlaut
  [0xF2] = 0x95, -- minuscule o-grave
  [0xFB] = 0x96, -- minuscule u-circumflex
  [0xF9] = 0x97, -- minuscule u-grave
  [0xFF] = 0x98, -- minuscule y-umlaut
  [0xD6] = 0x99, -- majuscule o-umlaut
  [0xDC] = 0x9A, -- majuscule u-umlaut
  -- 0x9B through 0x9F are currency symbols and not present in TH fonts
  [0xE1] = 0xA0, -- minuscule a-acute
  [0xED] = 0xA1, -- minuscule i-acute
  [0xF3] = 0xA2, -- minuscule o-acute
  [0xFA] = 0xA3, -- minuscule u-acute
  [0xF1] = 0xA4, -- minuscule n-tilde
  [0xD1] = 0xA5, -- majuscule n-tilde
  -- 0xA6 and 0xA7 are ordinal indicators and not present in TH fonts
  [0xBF] = 0xA8, -- inverted question mark
  -- 0xA9 through 0xAC are not present in TH fonts
  [0xA1] = 0xAD, -- inverted exclaimation mark
  -- 0xAE through 0xE0 are not present in TH fonts
  [0xDF] = 0xE1, -- eszett / sharp-S / lowercase-beta
  -- 0xE2 through 0xFF are not present in TH fonts
}

local cp437_to_codepoints = {
  [0x91] = 0xE6, -- minuscule ae
  [0x9B] = 0xA2, -- cent sign
  [0x9C] = 0xA3, -- pound sign
  [0x9D] = 0xA5, -- yen sign
  [0x9E] = 0x20A7, -- peseta sign
  [0x9F] = 0x192, -- florin sign
  [0xA6] = 0xAA, -- a ordinal indicator
  [0xA7] = 0xBA, -- o ordinal indicator
  [0xA9] = 0x2310, -- negation
  [0xAA] = 0xAC, -- negation
  [0xAB] = 0xBD, -- 1/2
  [0xAC] = 0xBC, -- 1/4
  [0xAE] = 0xAB, -- << guillemets
  [0xAF] = 0xBB, -- >> guillemets
  -- 0xB0 through 0xDF omitted
  [0xE0] = 0x3B1, -- alpha
  [0xE2] = 0x393, -- gamma
  [0xE3] = 0x3C0, -- pi
  [0xE4] = 0x3A3, -- majuscule sigma
  [0xE5] = 0x3C3, -- minuscule sigma
  [0xE6] = 0x3BC, -- minuscule mu
  [0xE7] = 0x3C4, -- tau
  [0xE8] = 0x3A6, -- majuscule phi
  [0xE9] = 0x398, -- theta
  [0xEA] = 0x3A9, -- omega
  [0xEB] = 0x3B4, -- delta
  [0xEC] = 0x221E, -- infinity
  [0xED] = 0x3C6, -- minuscule phi
  [0xEE] = 0x3B5, -- epsilon
  [0xEF] = 0x2229, -- set intersection
  [0xF0] = 0x2261, -- modular congruence / triple equals
  [0xF1] = 0xB1, -- plus / minus
  [0xF2] = 0x2265, -- >=
  [0xF3] = 0x2264, -- <=
  [0xF4] = 0x2320, -- upper integral sign
  [0xF5] = 0x2321, -- lower integral sign
  [0xF6] = 0xF7, -- obelus
  [0xF7] = 0x2248, -- approximate equality
  [0xF8] = 0xB0, -- degree symbol
  [0xF9] = 0x2219, -- bullet
  [0xFA] = 0xB7, -- interpunct
  [0xFB] = 0x221A, -- square root
  [0xFC] = 0x207F, -- exponentiation
  [0xFD] = 0xB2, -- superscript 2
  [0xFE] = 0x25A0, -- filled square
  [0xFF] = 0xA0, -- non-breaking space
}

local function utf8encode(codepoint)
  if codepoint <= 0x7F then
    return string.char(codepoint)
  elseif codepoint <= 0x7FF then
    local sextet = codepoint % 64
    codepoint = (codepoint - sextet) / 64
    return string.char(0xC0 + codepoint, 0x80 + sextet)
  elseif codepoint <= 0xFFFF then
    local sextet2 = codepoint % 64
    codepoint = (codepoint - sextet2) / 64
    local sextet1 = codepoint % 64
    codepoint = (codepoint - sextet2) / 64
    return string.char(0xE0 + codepoint, 0x80 + sextet1, 0x80 + sextet2)
  else
    local sextet3 = codepoint % 64
    codepoint = (codepoint - sextet3) / 64
    local sextet2 = codepoint % 64
    codepoint = (codepoint - sextet2) / 64
    local sextet1 = codepoint % 64
    codepoint = (codepoint - sextet2) / 64
    return string.char(0xF0 + codepoint, 0x80 + sextet1, 0x80 + sextet2,
                       0x80 + sextet3)
  end
end

local cp437_to_utf8_pattern = {"["}
local cp437_to_utf8_replacement = {}
for codepoint, cp437 in pairs(codepoints_to_cp437) do
  if not cp437_to_codepoints[cp437] then
    cp437_to_utf8_pattern[#cp437_to_utf8_pattern + 1] = string.char(cp437)
    cp437_to_utf8_replacement[string.char(cp437)] = utf8encode(codepoint)
  end
end
for cp437, codepoint in pairs(cp437_to_codepoints) do
  cp437_to_utf8_pattern[#cp437_to_utf8_pattern + 1] = string.char(cp437)
  cp437_to_utf8_replacement[string.char(cp437)] = utf8encode(codepoint)
end
cp437_to_utf8_pattern[#cp437_to_utf8_pattern + 1] = "]"
cp437_to_utf8_pattern = table.concat(cp437_to_utf8_pattern)
cp437conv = function(s)
  return (s:gsub(cp437_to_utf8_pattern, cp437_to_utf8_replacement))
end

-- Table which maps a single character and a single unicode combining
-- diacritical mark to a single unicode codepoint
local circumflex = 0x302
local cedilla = 0x327
local umlaut = 0x308
local acute = 0x301
local grave = 0x300
local ring = 0x30A
local tilde = 0x303
local combine_diacritical_marks = {
  a = {
    [grave] = 0xE0,
    [acute] = 0xE1,
    [circumflex] = 0xE2,
    [umlaut] = 0xE4,
    [ring] = 0xE5,
  },
  e = {
    [grave] = 0xE8,
    [acute] = 0xE9,
    [circumflex] = 0xEA,
    [umlaut] = 0xEB,
  },
  i = {
    [grave] = 0xEC,
    [acute] = 0xED,
    [circumflex] = 0xEE,
    [umlaut] = 0xEF,
  },
  o = {
    [grave] = 0xF2,
    [acute] = 0xF3,
  },
  u = {
    [grave] = 0xF9,
    [acute] = 0xFA,
    [circumflex] = 0xFB,
    [umlaut] = 0xFC,
  },
  c = {
    [cedilla] = 0xE7,
  },
  n = {
    [tilde] = 0xF1,
  },
  y = {
    [umlaut] = 0xFF,
  },
  A = {
    [umlaut] = 0xC4,
    [ring] = 0xC5,
  },
  E = {
    [acute] = 0xC9,
  },
  O = {
    [umlaut] = 0xD6,
  },
  U = {
    [umlaut] = 0xDC,
  },
  C = {
    [cedilla] = 0xC7,
  },
  N = {
    [tilde] = 0xD1,
  },
}

local function utf8char(c)
  -- Test for presence of a normal character prior to the utf-8 character
  local prechar
  if c:byte() < 128 then
    prechar = c:sub(1, 1)
    c = c:sub(2, -1)
  end
  -- Extract the codepoint of the utf-8 character
  local codepoint = 0
  local multiplier = 1
  for i = #c, 2, -1 do
    codepoint = codepoint + (c:byte(i) - 128) * multiplier
    multiplier = multiplier * 2^6
  end
  codepoint = codepoint + (c:byte(1) % 2^(7 - #c)) * multiplier
  -- If the utf-8 character is a combining diacritical mark, merge it with the
  -- preceeding normal character
  if prechar and (0x300 <= codepoint and codepoint < 0x370) then
    if combine_diacritical_marks[prechar] then
      if combine_diacritical_marks[prechar][codepoint] then
        codepoint = combine_diacritical_marks[prechar][codepoint]
        prechar = nil
      else
        return prechar
      end
    else
      return prechar
    end
  end
  -- Convert to Code Page 437
  return (prechar or "") .. string.char(codepoints_to_cp437[codepoint] or 0x3F)
end

utf8conv = function(s)
  -- Pull out each individual utf-8 character and pass it through utf8char
  -- [\1-\127] picks up a preceeding ASCII character to combine diacritics
  -- [\192-\253] picks up the first byte of a utf-8 character (technically
  --   only 194 through 244 should be used)
  -- [\128-\191] picks up the remaining bytes of a utf-8 character
  return (s:gsub("[\1-\127]?[\192-\253][\128-\191]*", utf8char))
end

-- Fix string.upper and string.lower to work with CP437 rather than current locale
local lower_to_upper, upper_to_lower = {}, {}
local function case(lower, upper)
  lower = cp437conv(string.char(lower))
  upper = cp437conv(string.char(upper))
  lower_to_upper[lower] = upper
  lower_to_upper[upper] = upper
  upper_to_lower[lower] = lower
  upper_to_lower[upper] = lower
end
case(0x87, 0x80) -- c-cedilla
case(0x81, 0x9A) -- u-umlaut
case(0x82, 0x90) -- e-acute
case(0x84, 0x8E) -- a-umlaut
case(0x86, 0x8F) -- a-ring
case(0x94, 0x99) -- o-umlaut
case(0xA4, 0xA5) -- n-tilde
local case_pattern = "\195[\128-\191]" -- Unicode range [0xC0, 0xFF] as UTF-8
local orig_upper = string.upper
function string.upper(s)
  return orig_upper(s:gsub(case_pattern, lower_to_upper))
end
local orig_lower = string.lower
function string.lower(s)
  return orig_lower(s:gsub(case_pattern, upper_to_lower))
end
