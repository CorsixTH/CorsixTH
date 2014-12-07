--[[ Copyright (c) 2013 Alan Woolley

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

class "CompoundCommand" (Command)

---@type CompoundCommand
local CompoundCommand = _G["CompoundCommand"]

function CompoundCommand:CompoundCommand()
  self:Command(true)
  self.command_list = {}
end

function CompoundCommand:addCommand(cmd)
  table.insert(self.command_list, #self.command_list + 1, cmd)
end

function CompoundCommand:perform()
  for i = 1 , #self.command_list do
    local cmd = self.command_list[i]
    cmd:perform()
  end
end

function CompoundCommand:undo()
  for i = #self.command_list, 1, -1 do
    local cmd = self.command_list[i]
    cmd:undo()
  end
end

