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
require("corsixth")

require("entity")
require("entities.humanoid")
require("entities.humanoids.staff.doctor")

describe("Doctor:", function()
  local function getDoctor()
    local animation = {setHitTestResult = function() end}
    return Doctor(animation)
  end

  it("Can represent doctor as a string", function()
    local doctor = getDoctor()

    doctor.humanoid_class = "Doctor"
    local name = "WHITMAN"
    local initial = "A"
    doctor.profile = {skill = 0.5, is_psychiatrist = 0.5, name = name, initial = initial}

    doctor.profile.getFullName = function()
      return doctor.profile.initial .. ". " .. doctor.profile.name
    end

    local result = doctor:tostring()

    assert.matches(result, "humanoid.*" .. initial .. ". " .. name .. ".*class.*Doctor")
    assert.matches(result, "Skills.*0%.5.*Psych.*0%.5")
  end)
end)
