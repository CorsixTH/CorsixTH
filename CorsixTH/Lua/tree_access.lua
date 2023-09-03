--[[ Copyright (c) 2023 Albert "Alberth" Hofkamp

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

--! Decide whether a value counts as table.
local function typeIsTable(v)
  local t = type(v)
  return t == "table" or t == "userdata"
end

-- Static class for extracting translated text strings by name.
class "TreeAccess"

-- @type TreeAccess
local TreeAccess = _G["TreeAccess"]

--! Collect policy function that stores all name parts in the same given outer
--  container.
--  Eg "x.y[2]" is stored as {"x", "y", "[2]"}.
--!param outer_value Outermost container table for storing all the name parts.
function TreeAccess.collectFlat(outer_value)
  return outer_value
end

--! Collect policy function that stores name parts between dots in different
--  containers inside the give outer container.
--  Eg "x.y[2]" is stored as {{"x"}, {"y", "[2]"}}.
--!param outer_value Outermost container table for storing all the name parts.
function TreeAccess.collectDottedParts(outer_value)
  local inner_value = {}
  outer_value[#outer_value + 1] = inner_value
  return inner_value
end

--! Parse the name of the string, breaking it into a sequence of nested table
--  key names. Such a key name is ".identifier" (leading dot is skipped the
--  first time), followed by zero or more "[number]" table indices.
--!param name (str) Name to parse.
--!param collect_func Function deciding how to collect the parts of each key-name.
--  See TreeAccess.collectFlat and TreeAccess.collectDottedParts above.
--!return (array of str, or nil) Parts of the name as an array, or nil if
--  parsing fails.
function TreeAccess.getNameParts(name, collect_func)
  local start = 1
  local outer = {}

  while start <= #name do
    local inner = collect_func(outer)
    local first, last
    -- Match the identifier.
    if start == 1 then
      first, last = name:find("^%a[%a%d_]*", start)
    else
      -- Non-first names are prefixed with a "."
      first, last = name:find("^%.%a[%a%d_]*", start)
      if first then first = first + 1 end -- Drop the leading ".".
    end
    if not first then return nil end -- Parsing failed.

    inner[#inner + 1] = name:sub(first, last)
    start = last + 1

    -- Match "[number]" parts if they exist.
    first, last = name:find("^(%[%d+%])", start)
    while first do
      inner[#inner + 1] = name:sub(first, last)
      start = last + 1

      first, last = name:find("^(%[%d+%])", start)
    end
  end
  return outer
end

--! Decode the key name to a string or a number.
--!param name Key name to decode.
--!return The value to use for indexing.
function TreeAccess.normalizeKey(name)
  if name:sub(1, 1) == "[" then return tonumber(name:sub(2, -2)) end
  return name
end

--! Walk through the existing tree following the path in name_parts, and return the
--  node at the end of the path.
--!param tree (nested hash tables) Tree to explore.
--!param name_parts (array of strings) Names or indices of the path to follow.
--!return Node in the tree at the end of the path, or nil if the path does not exist.
function TreeAccess.getFromTree(tree, name_parts)
  if not name_parts then return nil end -- Invalid selection keys.

  local value = tree
  for _, name_part in ipairs(name_parts) do
    -- Make a sub-selection if possible, else bail out.
    if typeIsTable(value) then
      value = value[TreeAccess.normalizeKey(name_part)]
    else
      return nil
    end
  end
  return value
end

--! Walk through the tree following the existing path or making a new path from
--  name_parts, and store the new_value at the end of the path.
--!param tree (nested tables) Tree to explore and/or extend.
--!param name_parts (array of strings) Names or indices of the path to follow of create.
--!param new_value (lua value) Value to write in the tree at the end of the path.
--!param allow_overwrite (boolean) If set, allow overwriting existing values in the tree.
function TreeAccess.addToTree(tree, name_parts, new_value, allow_overwrite)
  assert(#name_parts >= 1, "Cannot add a value at the end of an empty path.")

  -- Walk the tree adding a new branch when the path does not exist.
  for name_index = 1, #name_parts - 1 do
    local name_part = TreeAccess.normalizeKey(name_parts[name_index])
    -- Grab the next selected part, if a table we're done, else it must be a new branch.
    local child_tree = rawget(tree, name_part)
    if type(child_tree) ~= "table" then
      -- Not a child-table, make sure we don't cut down existing tree parts.
      assert(allow_overwrite or child_tree == nil,
          "Attempt to erase a part of the tree detected.")
      -- Make a new branch.
      child_tree = {}
      tree[name_part] = child_tree
    end
    tree = child_tree
  end

  -- Arrived at the deepest table, add the value.
  local normalized_key = TreeAccess.normalizeKey(name_parts[#name_parts])
  -- Last element may also be a sub-tree that needs to be preserved.
  assert(allow_overwrite or rawget(tree, normalized_key) == nil,
      "Attempt to erase a part of the tree detected.")
  tree[normalized_key] = new_value
end

--! Read a value from the tree.
--!param tree (nested tables) Tree to read.
--!param name (string) Name of the element to retrieve, may point at a non-leaf value.
--!return Data at tree[decoded-name], or nil if such a value does not exist.
function TreeAccess.readTree(tree, name)
  assert(typeIsTable(tree), "'table' is not a table.")
  assert(type(name) == "string", "'name' is not a string.")
  local name_parts = TreeAccess.getNameParts(name, TreeAccess.collectFlat)
  return TreeAccess.getFromTree(tree, name_parts)
end

--! Add a new value to the tree while keeping all existing values.
--!param tree (nested tables) Tree to extend.
--!param name (string) Name of the element to retrieve, may point at a non-leaf value.
--!param new_value (lua value) Value to write in the tree at the end of the path.
--!param allow_overwrite (boolean) If set, allow overwriting existing values in the tree.
function TreeAccess.addTree(tree, name, new_value, allow_overwrite)
  print("Adding " .. name)
  assert(typeIsTable(tree), "'table' is not a table.")
  assert(type(name) == "string", "'name' is not a string.")
  local name_parts = TreeAccess.getNameParts(name, TreeAccess.collectFlat)
  TreeAccess.addToTree(tree, name_parts, new_value, allow_overwrite)
end
