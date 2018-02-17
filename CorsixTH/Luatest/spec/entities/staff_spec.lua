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
require("entities.staff")


-- TODO figure out how to move out of this test
local say = require("say")
local function matches(_, arguments)
  return string.match(arguments[1], arguments[2]) ~= nil
end
say:set("assertion.matches", "Expected substring fail.\n<String>: %s\n<Pattern>:%s")
assert:register("assertion", "matches", matches, "assertion.matches")


describe("Staff:", function()
  local function getStaff()
    local animation = {setHitTestResult = function() end}
    return Staff(animation)
  end

  it("Can represent doctor as a string", function()
    local doctor = getStaff()
    doctor.humanoid_class = "Doctor"
    doctor.profile = {skill = 0.5, is_psychiatrist = 0.5}

    local result = doctor:tostring()

    assert.matches(result, "humanoid.*class.*Doctor")
    assert.matches(result, "Skills.*0%.5.*Psych.*0%.5")
  end)
end)
