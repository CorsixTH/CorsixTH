--[[ Copyright (c) 2018 Pavel "sofo" Schoffer

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
require("entities.humanoid")

describe("Humanoid:", function()
  local function getHumanoid()
    local animation = {setHitTestResult = function() end}
    return Humanoid(animation)
  end

  it("Gets the current action", function()
    local humanoid = getHumanoid()

    local action1 = {name = "fake1"}
    local action2 = {name = "fake2"}
    humanoid:queueAction(action1)
    humanoid:queueAction(action2)

    local recievedAction = humanoid:getCurrentAction()

    assert.equal(action1, recievedAction)
  end)
  it("Throws error if no action is queued", function()
    local humanoid = getHumanoid()

    local state, error = pcall(humanoid.getCurrentAction, humanoid)

    assert.False(state)
    local expected_message = "Action queue was empty. This should never happen."
    assert.matches(error, expected_message)
    assert.matches(error, "humanoid %-")
  end)
  it("Can represent itself as a string", function()
    local humanoid = getHumanoid()
    humanoid.humanoid_class = "class"

    local result = humanoid:tostring()

    assert.matches(result, "humanoid.*class.*class")
    assert.matches(result, "Warmth.*Happiness.*Fatigue")
    assert.matches(result, "Actions: %[%]")
  end)
  it("Can add actions to a representation", function()
    local humanoid = getHumanoid()
    humanoid.action_queue = {{name = "A1", room_type = "room"}, {name = "A2"}}

    local result = humanoid:tostring()

    assert.matches(result, "Actions.*%[A1 %- room, A2%]")
  end)

end)
