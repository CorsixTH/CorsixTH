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

class "LuaVariable"
class "LuaFunction" (LuaVariable)
class "LuaTable" (LuaVariable)
class "LuaClass" (LuaTable)

function LuaVariable:LuaVariable()
  self.type = nil
  self.name = nil
  self.parent = nil
end

function LuaVariable:setName(name)
  self.name = name
  return self
end

function LuaVariable:getName(name)
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

function LuaVariable:getParent()
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
end

function LuaFunction:setIsMethod(is)
  self.is_method = is
  return self
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
