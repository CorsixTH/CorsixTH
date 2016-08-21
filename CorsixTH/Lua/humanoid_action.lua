--[[ Copyright (c) 2016 Albert "Alberth" Hofkamp

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

--! Humanoid action base class.
class "HumanoidAction"

---@type HumanoidAction
local HumanoidAction = _G["HumanoidAction"]

--! Construct a humanoid action (base class constructor).
--!param name (str) Name of the action.
function HumanoidAction:HumanoidAction(name)
  assert(type(name) == "string", "Invalid value for parameter 'name'")

  self.name = name
  self.count = nil -- 'nil' means 'forever' (until finished), else the number to perform.
  self.must_happen = false -- If true, action cannot be skipped.
  self.loop_callback = nil -- Periodic callback to check for termination conditions.
  self.after_use = nil -- Callback for performing updates afterwards.
  self.is_leaving = false -- Whether the humanoid is leaving.
  self.no_truncate = false -- If set, disable shortening the action.
end

--! Set the number of times the action should happen.
--!param count (int or nil) Set to 'nil' if 'forever', else integer count.
--!return (action) Returning self, for daisy-chaining.
function HumanoidAction:setCount(count)
  assert(count == nil or type(count) == "number", "Invalid value for parameter 'count'")

  self.count = count
  return self
end

--! Set the 'must happen' flag (that is, action cannot be skipped).
--!param must_happen (bool) Whether or not the action must happen.
--!return (action) Returning self, for daisy-chaining.
function HumanoidAction:setMustHappen(must_happen)
  assert(type(must_happen) == "boolean", "Invalid value for parameters 'must_happen'")

  self.must_happen = must_happen
  return self
end

--! Set the callback for checking termination conditions.
--!param loop_callback (func) Callback function that is called each iteration to check for
--! termination conditions.
--!return (action) Returning self, for daisy-chaining.
function HumanoidAction:setLoopCallback(loop_callback)
  assert(loop_callback == nil or type(loop_callback) == "function",
      "Invalid value for parameter 'loop_callback'")

  self.loop_callback = loop_callback
  return self
end

--! Set the callback for performing updates afterwards.
--!param after_use (func) Callback function that is called after the action ends.
--!return (action) Returning self, for daisy-chaining.
function HumanoidAction:setAfterUse(after_use)
  assert(after_use == nil or type(after_use) == "function",
      "Invalid value for parameter 'after_use'")

  self.after_use = after_use
  return self
end

--! Set whether the humanoid is leaving.
--!param is_leaving (bool) Whether or not the humanoid is leaving. If not specified, value is true.
--!return (action) Returning self, for daisy-chaining.
function HumanoidAction:setIsLeaving(is_leaving)
  assert(type(is_leaving) == "boolean", "Invalid value for parameter 'is_leaving'")

  self.is_leaving = is_leaving
  return self
end

--! Do not allow truncating the action.
--!return (action) Returning self, for daisy-chaining.
function HumanoidAction:disableTruncate()
  self.no_truncate = true
  return self
end

function HumanoidAction:afterLoad(old, new)
  if old < 112 then
    self.is_leaving = not not self.is_leaving
    self.must_happen = not not self.must_happen
    self.no_truncate = not not self.no_truncate
    self.saved_must_happen = not not self.saved_must_happen
    self.idle_must_happen = not not self.idle_must_happen

    if self.name == "walk" then
      self.is_entering = not not self.is_entering
    end
  end
end
