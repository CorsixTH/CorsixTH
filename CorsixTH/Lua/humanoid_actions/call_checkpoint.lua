--[[ Copyright (c) 2010 Sam Wong

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

class "CallCheckPointAction" (HumanoidAction)

---@type CallCheckPointAction
local CallCheckPointAction = _G["CallCheckPointAction"]

function CallCheckPointAction:CallCheckPointAction()
  self:HumanoidAction("call_checkpoint")
  self.call = nil -- Whether the humanoid is on call.
  self.on_remove = nil -- Interrupt handler to use.
end

--! Set whether the humanoid is on call.
--!param call (bool) If set, humanoid is on call.
--!return (action) Returning self, for daisy-chaining.
function CallCheckPointAction:setCall(call)
  self.call = call
  return self
end

--! Set the interrupt handler.
--!param handler (function) Interrupt handler to use.
--!return (action) Returning self, for daisy-chaining.
function CallCheckPointAction:setOnRemove(handler)
  self.on_remove = handler
  return self
end

local function action_call_checkpoint_start(action, humanoid)
  action.must_happen = true
  CallsDispatcher.onCheckpointCompleted(action.call)
  humanoid:finishAction(action)
end

return action_call_checkpoint_start
