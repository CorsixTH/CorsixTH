--[[ Copyright (c) 2020 Albert "Alberth" Hofkamp

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

--! Storage of a parsed translation file.
--! The file is line-based, with some room in writing a translation string.
-- The language contained in the file is defined in a "##language <lang-names>"
-- line, where '<lang-names>' is a list of space-separated double quoted names
-- (of the langnuage).
-- The language to use for missing translations is given by a "##inherit
-- <lang-name>" line, where <lang-name> is the double quoted name of the fallback
-- language.
-- A translated string starts with "<string-name> =". The string name has the
-- form of a Lua expression to access a field in a nested table, for example
-- "field.subfield.entry[2]". After the equal sign must follow the translation
-- text, either at the same line, or on the next line. Long translation texts
-- may also be split for easier editing. The (part of the) translation text
-- must be written as  "<double-quoted-text>", that is, the text surrounded by
-- double quotes. The program strips the leading and trailing double quote, and
-- copies the remainder verbatim as translation text. This means double quotes
-- inside the text should be written as double quotes without escaping them.
-- For example, "She shouted "hey, you there!"" is the text >She shouted "hey,
-- you there!"< (except for the triangular brackets).
-- If more than one double quoted text is used in a string, the content is
-- simply concatenated, in particular, no white space is added by the program.
class "Translation"

---@type Translation
local Translation = _G["Translation"]

--! Class for storing a translation, named strings in a language.
--! The translated strings are stored in self.lang_strings, an array of
--  {name, text} tables, where the 'name' is an array of string-pieces that are
--  either an "<identifier>" or a "[<number>]", eg {"information", "level_lost",
--  "[2]"} to express the lua path "information.level_lost[2]", and 'text' is
--  the translated message, eg "Bummer, you lost the level, better luck next time!".
--!param fname File name of the file that contained the translation.
function Translation:Translation(fname)
  self.fname = fname -- Name of the file containing the translation.
  self.lang_names = nil -- Names of the language.
  self.inherit = nil -- Language to use for missing translations
  self.lang_strings = {} -- Strings of the translation.
end

--! Debug function for displaying the content of the language strings.
function Translation:dump()
  for _, lstr in ipairs(self.lang_strings) do
    print("Line " .. lstr.lineno .. ": " .. table.concat(lstr.name, ".") .. " ::= " .. lstr.text)
  end
end

--! Set the names of the language.
--!param lang_names Array of strings expressing the name of the language.
function Translation:set_lang_names(lang_names)
  self.lang_names = lang_names
end

--! Set the name of the language to copy missing translations from.
--!param lang_name Name of the language to fallback to for missing translations.
function Translation:set_inherit(lang_name)
  self.inherit = lang_name
end

--! Add a translation.
--!param name Name of the translation, array with "<identifier>" and "[<number>]" strings.
--!param text Text of the translation.
function Translation:add_string(name, lineno, text)
  local entry = {name = name, lineno = lineno, text = text}
  self.lang_strings[#self.lang_strings + 1] = entry
  return entry
end

--! Construct a nested table for the string names.
--!param errors If supplied, add found errors.
--!return The nested table, with strings attached.
function Translation:create_nested_table(errors)
  local root = {}

  -- Fill root table with the translated strings.
  for i, lstr in ipairs(self.lang_strings) do
    -- Unfold string name recursively into the root table.
    local last_name = nil
    local last_table = nil
    for name in ipairs(lstr.name) do
      if last_table == nil then
        last_table = root
      elseif last_table[last_name] then
        if type(last_table[last_name]) == "string" then
          local msg = ("String name " .. table.concat(lstr.name, "", i - 1) ..
                       "leads to a string")
          errors:report("Error", msg, lstr.lineno)
        else
          last_table = last_table[last_name]
        end
      else
        local new_table = {}
        last_table[last_name] = new_table
        last_table = new_table
      end

      if name:sub(1) == '[' then
        last_name = tonumber(name:sub(2, -2))
      else
        last_name = name
      end
    end
    -- Attach string to the entry
    assert(last_table)
    assert(last_name)
    last_table[last_name] = lstr.text
  end
  return root
end


--! Class for storing reported errors.
class "Errors"
--
---@type Errors
local Errors = _G["Errors"]

function Errors:Errors()
  self.errors = {}
end

--! Store an error.
--!param err_type Kind of error, can be "Error", "Warning".
--!param msg Text of the error message.
--!param lineno Optional line number of the error.
--!param col Optional column number of the error.
function Errors:report(err_type, msg, lineno, col)
  local err_msg = {err_type=err_type, msg=msg, lineno=lineno, col=col}
  self.errors[#self.errors + 1] = err_msg
end

--! Dump all errors to the console, mostly for debugging.
function Errors:dump()
  for _, err in ipairs(self.errors) do
    if err.lineno then
      print(err.err_type .. ": " .. err.msg .. " at line " .. err.lineno)
    else
      print(err.err_type .. ": " .. err.msg)
    end
  end
end

--! Are there any errors reported?
--!return Whether the instance contains at least one error.
function Errors:hasErrors()
  return self.errors:len() > 0
end

--
-- Parsing functions.
--

--! Get some text (probably a word) between double quotes.
--!param line Line to parse.
--!param column First position in the line to examine.
--!return The found text without quotes and the column behind the last quote,
--  or both nil if no double quoted text exists.
local function get_quoted_text(line, column)
  local first, last = line:find("\"[^\"]+\"", column)
  if first then
    return line:sub(first + 1, last - 1), last + 1
  else
    return nil, nil
  end
end

-- Recognize empty or comment lines.
--!param line Line of text to inspect.
--!return Whether the line was processed.
local function _recognize_empty_and_comment(line)
  local first, last = line:find("^[ \t]*")
  assert(first) -- Optionally finding white space doesn't fail.
  return last == line:len() or line:sub(last + 1, last + 2) == "--"
end

--! Function to recognize and process the "##language" line.
--!param transl Translation object for storing found results.
--!param line Line of text to inspect.
--!param lineno Line number of 'line'.
--!param errors Error message storage.
--!return Whether the line was processed.
local function _recognize_language_names(transl, line, lineno, errors)
  local first, last = line:find("^[ \t]*##language")
  if first == nil then return false end

  -- Collect language names.
  local column = last + 1
  local lang_names = {}
  local lname
  while true do
    lname, column = get_quoted_text(line, column)
    if lname == nil then break end

    lang_names[#lang_names + 1] = lname
  end
  if #lang_names == 0 then
    errors:report("Error", "Missing names of the language.", lineno)
  end
  return true
end

--! Recognize and process the ##inherit "<fallback-language>" line.
--!param transl Stored translation data so far.
--!param line Current line being parsed.
--!param lineno Line number of line in the input file.
--!param errors Error message storage.
--!return Whether the '##inherit' line was found and processed.
local function _recognize_inherit(transl, line, lineno, errors)
  local first, last = line:find("^[ \t]*##inherit")
  if first == nil then return false end
  -- There is only one inherit language name.
  local lname, _column = get_quoted_text(line, last + 1)
  if lname then
    transl:set_inherit(lname)
  else
    self:report("Error", "Missing name of the inherited language.", lineno)
  end
  return true
end

--! Check whether the line is empty after column. Raises an error otherwise.
--!param line Text line being parsed.
--!param column First position in the line to examine.
--!param line Text line being parsed.
--!param errors Error message storage.
local function _check_empty(line, column, lineno, errors)
  local _first, last = line:find("^[ \t]*", column)
  if last + 1 <= line:len() then
    if line:sub(last + 1, last + 2) ~= "--" then
      -- Not empty and not comment, raise an error
      errors:report("Error", "Unexpected text found.", lineno, last + 1)
    end
  end
end

--! Parse the name of the string at the indicated position.
--! To assist in building the dictionary structure containing the text, the
--  returned name is an array of strings of the form "<identifier>" and
--  "[<number>]". The first form is for field selection, the second form is
--  for array index selection. For the latter, a string to number conversion
--  is still required.
--!param line Line of text (probably) containing the name.
--!param column First position of the name in the line.
--!return Found name parts or nil, column position after them.
local function _get_name_parts(line, column, lineno, errors)
  -- Skip any whitespace before the name.
  local _first, last = line:find("^[ \t]*", column)
  local col = last + 1 -- Keep original column in case it's needed again.

  local str_name = {}
  while true do
    local first, last = line:find("^%a[%a%d_]*", col)
    if first == nil then
      if #str_name ~= 0 then
        -- Found a "." before, a name is expected here
        errors:report("Error", "Expected a name after the dot.", lineno, col)
      end
      return nil, column -- No match, return original column
    end
    str_name[#str_name + 1] = line:sub(first, last)
    col = last + 1

    -- Check for [x] indices.
    while true do
      first, last = line:find("^%[%d+%]", col)
      if not first then break end
      str_name[#str_name + 1] = line:sub(first, last)
      col = last + 1
    end

    if line:sub(col, col) ~= "." then
      return str_name, col -- No '.', found a match
    else
      col = col + 1
    end
  end
end

--! Get the translation text from the line if it exists.
--!param line Text line being parsed.
--!param column First position in the line to examine.
--!return the translation text if it exists, and the column after the text.
local function _get_translation_text(line, column)
  local col = column
  local first, last = line:find("^[ \t]+", col) -- Skip any white space.
  if first then col = last + 1 end

  -- Translation text must be a string between double quotes. Note this is a
  -- greedy match that doesn't care about the final " being part of a comment..
  first, last = line:find("\".*\"", col)
  if first then
    return line:sub(first + 1, last - 1), last + 1
  else
    return nil, column
  end
end

--! Recognize a string name and/or translation text. Note that 'string name'
--  also includes the '=' after it.
--! Function also checks that no other text exists at the line.
--!param line Line to parse.
--!param lineno Line number of the line.
--!param errors Error message storage.
--!return The found string name if any, and the found translation text if any.
local function _recognize_translated_string(line, lineno, errors)
  local column = 0
  -- Does a name exist?
  local parts
  local parts, column = _get_name_parts(line, column, lineno, errors)
  if parts ~= nil then
    local first, last = line:find("^[ \t]*=", column) -- Match the '=' that should follow.
    if first == nil then
      errors:report("Error", "Missing '=' behind the string name", lineno, column)
    else
      column = last + 1
    end
  end
  -- Does a translation text exist?
  local text
  text, column = _get_translation_text(line, column)
  _check_empty(line, column, lineno, errors) -- Should be no text after it.

  -- No need to actually check if there was some valid text here. The line is
  -- not empty (or _recognize_empty_and_comment would have been successful),
  -- Text at this line thus must meet the requirements or _check_empty would
  -- report an error.
  return parts, text
end

--! Entry point for loading a language file.
--!param fname Name of the file to load.
--!return Loaded language if any, and found errors.
function parse_file(fname)
  local errors = Errors()

  local handle = io.open(fname, "r")
  if handle == nil then
    errors:report("Error", "Cannot open language file '" .. fname .. "'.")
    return nil, errors
  end

  local transl = Translation(fname)
  local lineno = 0

  local last_string_parts = nil
  local last_lineno = nil
  local last_text = {}

  while true do
    -- Read a line.
    local line = handle:read("l")
    lineno = lineno + 1
    if line == nil then break end

    -- Got a line, check if it makes sense.
    local parsed = _recognize_empty_and_comment(line)

    if not parsed then
      parsed = _recognize_language_names(transl, line, lineno, errors)
    end

    if not parsed then
      parsed = _recognize_inherit(transl, line, lineno, errors)
    end

    if not parsed then
      local parts, text = _recognize_translated_string(line, lineno, errors)
      -- New string name found, switch to it.
      if parts ~= nil then
        if last_string_parts ~= nil then
          -- Store the previous string.
          transl:add_string(last_string_parts, last_lineno,
                            table.concat(last_text))
        end
        last_string_parts = parts
        last_lineno = lineno
        last_text = {}
      end
      -- New text found, belongs to the last encountered string name.
      if text then
        if last_string_parts == nil then
          errors:report("Error", "String text cannot be attached to a string name.",
                        lineno)
        else
          last_text[#last_text + 1] = text
        end
      end
    end
  end

  -- Rescue last started string.
  if last_string_parts ~= nil then
    transl:add_string(last_string_parts, last_lineno, table.concat(last_text))
  end

  handle:close()
  return transl, errors
end
