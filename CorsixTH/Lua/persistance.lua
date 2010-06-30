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

local persist = require "persist"
local saved_permanents = {}

strict_declare_global "permanent"
strict_declare_global "unpermanent"

function permanent(name, ...)
  if select('#', ...) == 0 then
    return function (...) return permanent(name, ...) end
  end
  local value = ...
  assert(value ~= nil)
  assert(saved_permanents[name] == nil)
  saved_permanents[name] = value
  return value
end

function unpermanent(name)
  assert(saved_permanents[name] ~= nil)
  saved_permanents[name] = nil
end

local --[[persistable:persistance_global_fetch]] function global_fetch(...)
  local val = _G
  for _, k in ipairs{...} do
    val = val[k]
  end
  return val
end

local function MakePermanentObjectsTable(inverted)
  local return_val = setmetatable({}, {})
  local permanent = return_val
  if inverted then
    getmetatable(permanent).__newindex = function(t, k, v)
      rawset(t, v, k)
    end
  end
  
  -- Global functions
  for k, v in pairs(_G) do
    if type(v) == "function" then
      permanent[v] = k
    end
  end
   
  -- Lua class methods
  for name, class in pairs(_G) do repeat
    if type(class) ~= "table" then
      break -- continue
    end
    local class_mt = getmetatable(class)
    if not class_mt or class_mt.__class_name ~= name then
      break -- continue
    end
    permanent[class] = name .. ".1"
    permanent[class_mt] = name .. ".2"
    for k, v in pairs(class) do
      if type(v) == "function" then
        permanent[v] = name ..".".. k
      end
    end
  until true end
  
  -- C/class/library methods
  for name, lib in pairs(package.loaded) do
    if not name:find(".", 1, true) then
      permanent[lib] = name
    end
    for k, v in pairs(lib) do
      local type = type(v)
      if type == "function" or type == "table" or type == "userdata" then
        permanent[v] = name ..".".. k
        if name == "TH" and type == "table" then
          -- C class metatables
          permanent[debug.getfenv(getmetatable(v).__call)] = name ..".".. k ..".<mt>"
        end
      end
    end
  end
  
  -- Bits of the app
  permanent[TheApp] = "TheApp"
  for _, key in ipairs{"config", "modes", "video", "strings", "audio", "gfx", "fs"} do
    permanent[TheApp[key]] = inverted and "TheApp.".. key or {global_fetch, "TheApp", key}
  end
  for _, collection in ipairs{"walls", "objects", "rooms", "humanoid_actions", "diseases"} do
    for k, v in pairs(TheApp[collection]) do
      if type(k) == "string" then
        permanent[v] = inverted and "TheApp.".. collection ..".".. k or {global_fetch, "TheApp", collection, k}
      end
    end
  end
  -- If loading a game from the main menu, there will be no menu bar, so make one
  local menu_bar = TheApp.ui and TheApp.ui.menu_bar
  if not menu_bar then
    -- The menu bar wants a UI, but it is happy with just something naming an App
    menu_bar = UIMenuBar({app = TheApp})
  end
  permanent[menu_bar] = "TheApp.ui.menu_bar"
  
  -- Graphics bits are persisted as instructions to reload them or re-use if already loaded
  if inverted then
    -- as the object was persisted as a table, we need to add some magic to
    -- the __index metamethod to interpret this table as a function call
    getmetatable(return_val).__index = function(t, k)
      if type(k) == "table" then
        return k[1](unpack(k, 2))
      end
    end
  else
    -- load_info is a table containing a method and parameters to load obj
    for obj, load_info in pairs(TheApp.gfx.load_info) do
      permanent[obj] = load_info
    end
  end
  
  -- Things requested to be permanent by other bits of code
  for name, value in pairs(saved_permanents) do
    permanent[value] = name
  end
  
  return return_val
end

local function NameOf(obj) -- Debug aid
  local explored = {[_G] = true}
  local to_explore = {[_G] = "_G"}
  
  while true do
    local exploring, name = next(to_explore)
    if exploring == nil then
      break
    end
    to_explore[exploring] = nil
    if exploring == obj then
      return name
    end
    
    if type(exploring) == "table" then
      for key, val in pairs(exploring) do
        if not explored[val] then
          to_explore[val] = name .."."..tostring(key)
          explored[val] = true
        end
      end
    elseif type(exploring) == "function" then
      local i = 0
      while true do
        i = i + 1
        local name, val = debug.getupvalue(exploring, i)
        if not name then
          break
        end
        if val ~= nil and not explored[val] then
          to_explore[val] = name ..".<upvalue-"..i..tostring(name)..">"
          explored[val] = true
        end
      end
    end
    local mt = debug.getmetatable(exploring)
    if mt and not explored[mt] then
      to_explore[mt] = name ..".<metatable>"
      explored[mt] = true
    end
    mt = debug.getfenv(exploring)
    if mt and not explored[mt] then
      to_explore[mt] = name ..".<env>"
      explored[mt] = true
    end
  end
  
  return "<no name>"
end

strict_declare_global "SaveGame"
strict_declare_global "SaveGameFile"
strict_declare_global "LoadGame"
strict_declare_global "LoadGameFile"

function SaveGame()
  local state = {
    ui = TheApp.ui,
    world = TheApp.world,
    map = TheApp.map,
    random = math.randomdump(),
  }
  state.map:prepareForSave()
  --local status, res = xpcall(function()
  local result, err, obj = persist.dump(state, MakePermanentObjectsTable(false))
  state.map:afterSave()
  if not result then
    print(obj, NameOf(obj)) -- for debugging
    error(err)
  else
    return result
  end
  --end, persist.errcatch)
end

function SaveGameFile(filename)
  local data = SaveGame()
  local f = assert(io.open(filename, "wb"))
  f:write(data)
  f:close()
end

function LoadGame(data)
  --local status, res = xpcall(function()
  local state = assert(persist.load(data, MakePermanentObjectsTable(true)))
  state.ui:resync(TheApp.ui)
  TheApp.ui = state.ui
  TheApp.world = state.world
  TheApp.map = state.map
  math.randomseed(state.random)
  
  local cursor = TheApp.ui.cursor
  TheApp.ui.cursor = nil
  TheApp.ui:setCursor(cursor)
  -- The menu bar is a permanent object, so its ui field needs updating to
  -- the depersisted ui value.
  TheApp.ui.menu_bar.ui = TheApp.ui
  TheApp.ui.menu_bar:onChangeLanguage()
  --end, persist.errcatch)
  TheApp:afterLoad()
  TheApp.ui:onChangeResolution()
end

function LoadGameFile(filename)
  local f = assert(io.open(filename, "rb"))
  local data = f:read"*a"
  f:close()
  LoadGame(data)
end
