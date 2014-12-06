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

require("entity")
require("entities/object")

describe("object.lua: ", function()
  local stub_world = {map = {}}
  local fake_object_type = {ticks = false, idle_animations = {west = true}}
  local tile_x, tile_y, direction = 10, 10, "west"

  local function createObjectWithFakeInput()
    stub(stub_world, "getLocalPlayerHospital")
    stub(stub_world, "addObjectToTile")
    stub(stub_world, "clearCaches")
    return Object(stub_world, fake_object_type, tile_x, tile_y, direction)
  end

  it("can create Object objects", function()
    local object = createObjectWithFakeInput()

    assert.are.equal(fake_object_type, object.object_type)
    assert.are.equal(stub_world.map, object.world.map)
  end)
end)
