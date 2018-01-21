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
  it("Gets the current action", function()
    local animation = {setHitTestResult = function() end}
    local humanoid = Humanoid(animation)

    local action1 = {name = "fake1"}
    local action2 = {name = "fake2"}
    humanoid:queueAction(action1)
    humanoid:queueAction(action2)

    local recievedAction = humanoid:getCurrentAction()

    assert.equal(action1, recievedAction)
  end)
  it("Throws error if no action is queued", function()
    local animation = {setHitTestResult = function() end}
    local humanoid = Humanoid(animation)

    local state, error = pcall(humanoid.getCurrentAction, humanoid)

    assert.False(state)
    local expected_message = "Action queue was empty. This should never happen."
    assert.are.equal(expected_message, error.message)
    assert.are.equal(humanoid, error.humanoid)
  end)

end)
