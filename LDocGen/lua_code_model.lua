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

class "LuaNode"
class "LuaVariable" (LuaNode)
class "LuaFunction" (LuaVariable)
class "LuaTable" (LuaVariable)
class "LuaClass" (LuaTable)
class "LuaFile" (LuaNode)
class "LuaDirectory" (LuaNode)
class "LuaProject" (LuaNode)

function LuaProject:LuaProject()
  self:LuaNode()
  self.globals = LuaTable()
  self.files = LuaDirectory()
end

function LuaNode:LuaNode()
  self.name = nil
  self.parent = nil
  self.short_desc = nil
  self.long_desc = nil
  self.file = nil
  self.line = nil
end

function LuaVariable:LuaVariable()
  self:LuaNode()
  self.type = nil
end

function LuaNode:setFile(file, line)
  self.file = file
  self.line = line
  return self
end

function LuaNode:getFile()
  return self.file
end

function LuaNode:getLine()
  return self.line
end

function LuaNode:setName(name)
  self.name = name
  return self
end

function LuaNode:getName(name)
  return self.name
end

function LuaVariable:getId()
  local id
  if self.name then
    id = self.name:gsub("_","__"):gsub("[A-Z]", function(c) return "_" .. c:lower() end)
  else
    id = "_0"
  end
  if self.parent then
    id = self.parent:getId() .."_1".. id
  end
  return id
end

function LuaNode:setShortDesc(desc)
  self.short_desc = desc
  return self
end

function LuaNode:getShortDesc()
  return self.short_desc
end

function LuaNode:setLongDesc(desc)
  self.long_desc = desc
  return self
end

function LuaNode:getLongDesc()
  return self.long_desc
end

function LuaVariable:setParent(parent)
  assert(self.parent == nil)
  if class.is(parent, LuaTable) then
    parent:addMember(self)
  else
    error "Unknown parent type"
  end
  self.parent = parent
  return self
end

function LuaNode:getParent()
  return self.parent
end

function LuaFunction:LuaFunction()
  self:LuaVariable()
  self.type = "function"
  self.return_type = nil
  self.parameters = {}
  self.return_values = {}
  self.short_desc = nil
  self.long_desc = nil
  self.examples = {}
  self.is_method = false
  self.is_vararg = false
  self.vararg_parameter = nil
  self.is_dummy = false
end

function LuaFunction:setIsDummy(is)
  self.is_dummy = is
  return self
end

function LuaFunction:setIsMethod(is)
  self.is_method = is
  return self
end

function LuaFunction:isMethod()
  return self.is_method
end

function LuaFunction:setIsVararg(is)
  self.is_vararg = is
  if is then
    self.vararg_parameter = LuaVariable():setName("...")
  else
    self.vararg_parameter = nil
  end
  return self
end

function LuaFunction:addParameter(p)
  p.parent = self
  self.parameters[#self.parameters + 1] = p
  return self
end

function LuaFunction:parameterPairs()
  local i = 0
  return function()
    i = i + 1
    local p = self.parameters[i]
    if not p then
      if self.is_vararg and i - 1 == #self.parameters then
        return "...", self.vararg_parameter
      end
      return
    end
    return p:getName(), p
  end
end

function LuaFunction:getParameter(name)
  for _, param in ipairs(self.parameters) do
    if param:getName() == name then
      return param
    end
  end
  if name == "..." then
    return self.vararg_parameter
  end
end

function LuaTable:LuaTable()
  self:LuaVariable()
  self.type = "table"
  self.members = {}
  self.members_sorted = true
  self.inherits_from = nil
end

function LuaTable:inheritFrom(other)
  self.inherits_from = other
end

function LuaTable:addMember(member)
  assert(member.parent == nil)
  member.parent = self
  self.members[#self.members + 1] = member
  self.members_sorted = false
  return self
end

function LuaTable:removeMember(member)
  assert(member.parent == self)
  for i, val in ipairs(self.members) do
    if val == member then
      table.remove(self.members, i)
      member.parent = nil
      return true
    end
  end
  return false
end

function LuaTable:get(name)
  for _, member in ipairs(self.members) do
    if member.name == name then
      return member
    end
  end
  if self.inherits_from then
    return self.inherits_from:get(name)
  end
end

function LuaTable:pairs()
  if not self.members_sorted then
    table.sort(self.members, function(m1, m2)
      return m1.name < m2.name
    end)
    self.members_sorted = true
  end
  local n = 0
  local inh = self.inherits_from and self.inherits_from:pairs()
  local inh_name, inh_val
  if inh then
    inh_name, inh_val = inh()
  end
  return function()
    local oldn = n
    repeat
      n = n + 1
      local member = self.members[n]
      if member and member.name then
        if inh_name then
          if inh_name < member.name then
            n = oldn
            local n, v = inh_name, inh_val
            inh_name, inh_val = inh()
            return n, v
          elseif inh_name > member.name then
            return member.name, member
          else
            inh_name, inh_val = inh()
            return member.name, member
          end
        else
          return member.name, member
        end
      end
    until not member
    if inh_name then
      n = oldn
      local n, v = inh_name, inh_val
      inh_name, inh_val = inh()
      return n, v
    end
  end
end

function LuaClass:LuaClass()
  self:LuaTable()
  self.super_class = nil
  self.subclasses = {}
  self.subclasses_sorted = false
end

function LuaClass:setSuperClass(super)
  if type(super) == "string" then
    assert(self.super_class == nil)
    self.super_class = super
  else
    assert(self.super_class == nil or type(self.super_class) == "string")
    self.super_class = super
    self:inheritFrom(super)
    super.subclasses[#super.subclasses + 1] = self
    super.subclasses_sorted = false
  end
  return self
end

function LuaClass:getSuperClass()
  return self.super_class
end

function LuaClass:hasSubclasses()
  return self.subclasses[1] ~= nil
end

function LuaClass:subclassPairs()
  if not self.subclasses_sorted then
    table.sort(self.subclasses, function(m1, m2)
      return m1.name < m2.name
    end)
    self.subclasses_sorted = true
  end
  local n = 0
  return function()
    repeat
      n = n + 1
      local member = self.subclasses[n]
      if member and member.name then
        return member.name, member
      end
    until not member
  end
end

function LuaFile:LuaFile()
  self:LuaNode()
end

function LuaDirectory:LuaDirectory()
  self:LuaNode()
  self.children = {}
  self.children_sorted = true
end

function LuaDirectory:getId()
  local id
  if self.name then
    id = self.name:gsub("_","__"):gsub("[A-Z]", function(c) return "_" .. c:lower() end)
  else
    id = "_2"
  end
  if self.parent then
    id = self.parent:getId() .."_1".. id
  end
  return id
end

function LuaFile:getId()
  local id = self.name:gsub("_","__"):gsub("[A-Z]", function(c) return "_" .. c:lower() end)
  id = self.parent:getId() .."_1".. id
  return id
end

function LuaDirectory:get(name)
  for _, member in ipairs(self.children) do
    if member.name == name then
      return member
    end
  end
end

function LuaDirectory:addMember(child)
  self.children[#self.children + 1] = child
  self.children_sorted = false
  return self
end

function LuaDirectory:setParent(parent)
  assert(self.parent == nil)
  if class.is(parent, LuaDirectory) then
    parent:addMember(self)
  else
    error "Unknown parent type"
  end
  self.parent = parent
  return self
end

function LuaDirectory:pairs()
  if not self.children_sorted then
    table.sort(self.children, function(m1, m2)
      return m1.name < m2.name
    end)
    self.children_sorted = true
  end
  local n = 0
  return function()
    repeat
      n = n + 1
      local member = self.children[n]
      if member and member.name then
        return member.name, member
      end
    until not member
  end
end

function LuaFile:setParent(parent)
  assert(self.parent == nil)
  if class.is(parent, LuaDirectory) then
    parent:addMember(self)
  else
    error "Unknown parent type"
  end
  self.parent = parent
  return self
end
