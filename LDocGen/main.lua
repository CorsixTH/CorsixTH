#!/usr/local/bin/lua
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

local directories = {
  "../CorsixTH/Lua/",
  "../CorsixTH/Src/",
}
local c_files = {
}
local lua_files = {
  "../CorsixTH/CorsixTH.lua"
}

local lfs = require "lfs"
local our_dir = debug.getinfo(1).source
our_dir = our_dir:match("@(.*)"..package.config:sub(1, 1)) or "."
lfs.chdir(our_dir)

dofile "../CorsixTH/Lua/strict.lua"
dofile "../CorsixTH/Lua/class.lua"
require = destrict(require)

require "helpers"
require "c_tokenise"
require "lua_tokenise"
require "lua_code_model"
require "lua_scan"
require "template"

function string.trim(s, what)
  what = what or "%s"
  return s:gsub("^[".. what .."]*(.-)[".. what .."]*$", "%1")
end

-- Identify source files
for _, dir_path in ipairs(directories) do
  for item in lfs.dir(dir_path) do
    if lfs.attributes(dir_path .. item, "mode") == "directory" then
      if item ~= "." and item ~= ".." then
        directories[#directories + 1] = dir_path .. item .. "/"
      end
    else
      local ext = (item:match"%.([^.]+)$" or ""):lower()
      if ext == "c" or ext == "cpp" then
        c_files[#c_files + 1] = dir_path .. item
      elseif ext == "lua" then
        lua_files[#lua_files + 1] = dir_path .. item
      end
    end
  end
end

local function WriteHTML(name, content)
  local f = assert(io.open("output/".. name ..".html", "w"))
  f:write((content:gsub("([\r\n])%s*[\r\n]","%1"):gsub("   *"," ")))
  f:close()
end

local project = MakeLuaCodeModel(lua_files)
local globals = project.globals
WriteHTML("class_hierarchy", template "page" {
  title = "Class Hierarchy",
  tab = "classes",
  section = "hierarchy",
  content = template "lua_class_hierarchy" {globals = globals},
})
WriteHTML("class_list", template "page" {
  title = "Class List",
  tab = "classes",
  section = "list",
  content = template "lua_class_list" {globals = globals},
})
WriteHTML("class_index", template "page" {
  title = "Class Index",
  tab = "classes",
  section = "index",
  content = template "lua_class_index" {globals = globals},
})
for name, var in globals:pairs() do
  if class.is(var, LuaClass) then
    WriteHTML(var:getId(), template "page" {
      title = var:getName() .." Class",
      tab = "classes",
      section = "",
      content = template "class" {class = var},
    })
  end
end
WriteHTML("file_hierarchy", template "page" {
  title = "File Hierarchy",
  tab = "files",
  section = "hierarchy",
  content = template "lua_file_hierarchy" {project = project},
})
WriteHTML("file_globals", template "page" {
  title = "Globals",
  tab = "files",
  section = "globals",
  content = "TODO",
})

do return end
-- Old code, to be integrated into new code at later date:

tokens_gfind_mode "C"
for _, c_filename in ipairs(c_files) do
  local toks = TokeniseC(io.open(c_filename):read"*a")

  -- Identify Lua glue functions and the C functions which they call
  local glue_functions = {}
  for tokens, _, _, i in tokens_gfind(toks,
    "static", "int", "l_.*", "(", "lua_State", "*"
  )do
    local level = 0
    local i_end = i
    while true do
      if tokens[i_end][1] == "}" then
        level = level - 1
        if level == 0 then
          break
        end
      elseif tokens[i_end][1] == "{" then
        level = level + 1
      end
      i_end = i_end + 1
    end
    local methods = {}
    local seen = {}
    local _, var_i, _, fn_i, _, class_i = tokens_gfind(tokens, i,
      ".*", "=", "luaT_.*", "<", ".*", ">"
    )()
    if class_i and (class_i < i_end) then
      local var_name = tokens[var_i][1]
      local fn_name = tokens[fn_i][1]
      local class_name = tokens[class_i][1]
      if fn_name == "luaT_stdnew" then
        methods[#methods + 1] = class_name .. "::" .. class_name
      end
      for _, _, _, method_i in tokens_gfind(tokens, class_i,
        var_name, "->", ".*", {nil, "[%[%(]"}
      )do
        if method_i > i_end then
          break
        end
        if not seen[tokens[method_i][1]] then
          methods[#methods + 1] = class_name .. "::" .. tokens[method_i][1]
          seen[tokens[method_i][1]] = true
        end
      end
    end
    glue_functions[tokens[i][1]] = methods
  end

  -- Identify wrapped classes
  for tokens, _, _, cname_i, _, glue_i, _, lname_i in tokens_gfind(toks,
    "luaT_class", "(", ".*", ",", ".*", ",", {"string", ".*"}, ","
  )do
    local cname = tokens[cname_i][1]
    local glue = tokens[glue_i][1]
    local lname = loadstring("return " .. tokens[lname_i][1])()
    local _, i_end = tokens_gfind(tokens, lname_i, "luaT_endclass")()
    print("\n=== TH." .. lname .. " ===")
    print("Wraps the C++ class " .. code(cname) .. ".\n")
    print("|| *Lua method* || *C++ function(s)* || *Glue function* ||")
    for _, fn_i, _, mglue_i, _, name_i in tokens_gfind(tokens, lname_i,
      "luaT_set.*", "(", ".*", ",", {"string", ".*"}
    )do
      if name_i > i_end then
        break
      end
      local fn = tokens[fn_i][1]
      local mglue = tokens[mglue_i][1]
      local name = loadstring("return " .. tokens[name_i][1])()
      if fn == "luaT_setmetamethod" then
        name = "metamethod " .. code("__" .. name)
      else
        name = code(name)
      end
      print("|| " .. name .. " || " .. table.concat(map(glue_functions[mglue], code), ", ") .. " || " .. code(mglue) .. " ||")
    end
    print("")
  end
end
