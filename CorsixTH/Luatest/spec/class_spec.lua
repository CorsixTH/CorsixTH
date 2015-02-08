--[[ Copyright (c) 2014 Edvin "Lego3" Linge

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

require("class_test_base")

class "ParentClass"

function ParentClass:ParentClass(name)
  self.class_name = name
end

class "ChildClass" (ParentClass)

function ChildClass:ChildClass(name)
  self:ParentClass(name)
end

describe("A class in CorsixTH ", function()
  local child_class, parent_class

  setup(function()
    child_class = ChildClass("TheChild")
    parent_class = ParentClass("TheParent")
  end)

  it("should be instansiatable", function()
    assert.are.equal("TheChild", child_class.class_name)
    assert.are.equal("TheParent", parent_class.class_name)
  end)

  it("should be the same for many instances of the same type, including inheritance", function()
    assert.truthy(class.is(child_class, ChildClass))
    assert.falsy(class.is(parent_class, ChildClass))

    assert.truthy(class.is(child_class, ParentClass))
    assert.truthy(class.is(parent_class, ParentClass))
  end)

  it("should have a name", function()
    assert.are.equal("ChildClass", class.name(ChildClass))
    assert.are.equal("ParentClass", class.name(ParentClass))
    assert.are.equal(nil, class.name(NoRealClass))
  end)

  it("should know if it has a superclass", function()
    assert.are.equal(ParentClass, class.superclass(ChildClass))
    assert.are.equal(nil, class.superclass(ParentClass))
    assert.has_error(class.superclass, NoRealClass)
  end)

  it("should have a type", function()
    assert.are.equal("ChildClass", class.type(child_class))
    assert.are.equal("ParentClass", class.type(parent_class))
  end)
end)
