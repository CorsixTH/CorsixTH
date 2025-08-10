--[[ Copyright (c) 2014 Pavel "sofo" Schoffer

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
require("corsixth")

require("class_test_base")

require("utility")
require("announcer")
require("entity")
require("entities/object")
require("entities/machine")

describe("object.lua: ", function()
  local stub_world = {map = {}}
  local stub_hospital = {world = stub_world}
  _G["Hospital"] = stub_hospital

  local tile_x, tile_y, direction = 10, 10, "west"

  local function createMachineWithFakeInput()
    stub(stub_world, "addObjectToTile")
    stub(stub_world, "clearCaches")
    local offset = {0, 0}
    local orientation = {
      render_attach_position = offset,
      use_position = {0, 0}
      }
    local fake_object_type = {
      ticks = false,
      idle_animations = {west = true},
      orientations = {west = orientation}
      }
    return Machine(stub_hospital, fake_object_type, tile_x, tile_y, direction)
  end

  it("can update dynamic Info", function()
    local machine = createMachineWithFakeInput()
    machine:incrementUsedCount()
    machine:updateDynamicInfo()
    assert.are.equal(1, machine.times_used)
    assert.are.equal(1, machine.total_usage)
  end)
  it("can transfer state", function()
    local machine1 = createMachineWithFakeInput()
    machine1:updateDynamicInfo()
    local machine2 = createMachineWithFakeInput()

    machine2:setState(machine1:getState())

    assert.are.equal(machine1.times_used, machine2.times_used)
    assert.are.equal(machine1.total_usage, machine2.total_usage)
  end)
  it("setting null state doesn't clear values", function()
    local machine = createMachineWithFakeInput()
    machine:incrementUsedCount()
    machine:updateDynamicInfo()

    assert.are.equal(1, machine.times_used)
    assert.are.equal(1, machine.total_usage)

    machine:setState(nil)

    assert.are.equal(1, machine.times_used)
    assert.are.equal(1, machine.total_usage)
  end)
end)
