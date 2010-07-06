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

---- Primitive class system ---------------------------------------------------
-- Declaring a class:
--  class "Name"
-- OR
--  class "Name" (SuperclassName)
--
--  function Name:Name(arguments)
--    self:SuperclassName(arguments) -- required when there is a superclass
--    --(constructor)--
--  end
--  function Name:method(arguments)
--    --(generic method)--
--  end
--
-- Creating a class instance:
--  variable = Name(constructor_arguments)
--
-- Classes can also be made by "adopting" a table - taking an existing table
-- and turning it into a class instance, rather than always creating a new
-- table when the constructor is called. To enable this, put "{}" after the
-- class declaration, as in:
--  class "NameWhichAdopts" {}
-- Then the first argument to the constructor is treated as a table to turn
-- into an instance of the class, as in:
--  variable = NameWhichAdopts{named_constructor_argument = 42, another = 43}
--
-- Using a class instance:
--  variable:method(arguments)
-- OR
--  Name.method(variable, arguments)
--
-- The latter form can be used to call a method of a superclass when the
-- subclass overrides it with a method of the same name.
-- C code does not use this file, but does use the same syntax for creating a
-- class instance and calling methods on it.

local setmetatable, getmetatable, type
    = setmetatable, getmetatable, type

local function define_class(name, super, adopts_self)
  local mt = {}
  local methods = {}
  local methods_mt = {}
  
  local function new_class(methods, ...)
    local constructor = methods[name]
    local self
    if adopts_self and ... then
      self = setmetatable(..., mt)
      constructor(...)
    else
      self = setmetatable({}, mt)
      constructor(self, ...)
    end
    return self
  end
  
  mt.__index = methods
  setmetatable(methods, methods_mt)
  if super ~= nil then
    methods_mt.__index = super
  end
  methods_mt.__call = new_class
  methods_mt.__class_name = name
  
  _G[name] = methods
end

strict_declare_global "class"
class = destrict(function(_, name)
  define_class(name)
  local adopts_self = false
  local super = nil
  
  local function extend(arg)
    if type(arg) == "table" and next(arg) == nil and not getmetatable(arg) then
      -- {} decorator
      adopts_self = true
    else
      -- (Superclass) decorator
      if arg == nil then
        error "Superclass not defined at subclass definition"
      end
      super = arg
    end
    define_class(name, super, adopts_self)
    return extend
  end
  return extend
end)
class = setmetatable({}, {__call = class})

-- class.is - Tests if a given class object (first parameter) is an instance
-- of (something derived from) a given type (second parameter).
-- For example:
-- class "something" (base)
-- class "something_else"
-- variable = something()
-- class.is(variable, something) --> true
-- class.is(variable, base) --> true
-- class.is(variable, something_else) --> false
function class.is(instance, class)
  local typ = type(instance)
  if typ ~= "table" and typ ~= "userdata" then
    return false
  end
  local methods = instance
  while methods do
    if methods == class then
      return true
    end
    local mt = getmetatable(methods)
    methods = mt and mt.__index
  end
  return false
end

-- class.name - Get the name of a class
-- For example:
-- class "something"
-- class.name(something) --> "something"
function class.name(class)
  local mt = getmetatable(class)
  return mt and mt.__class_name
end

-- class.superclass - Get the superclass of a class
-- For example:
-- class "something" (base)
-- class.superclass(something) --> base
function class.superclass(class)
  return getmetatable(class).__index
end

-- class.type - Get the typename of a class instance
-- For example:
-- class "something" (base)
-- variable = something()
-- class.type(variable) --> "something"
function class.type(instance)
  local mt = getmetatable(instance)
  if not mt then
    return nil
  end
  local methods_mt = getmetatable(mt.__index)
  if not methods_mt then
    return nil
  end
  return methods_mt.__class_name
end
