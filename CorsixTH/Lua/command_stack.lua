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

class "CommandStack"

function CommandStack:CommandStack()
  self.undo_stack = {}
  self.redo_stack = {}
end

function CommandStack:redo()
  if (#self.redo_stack == 0) then
    print "Nothing left to redo!"
    return
  end
  local cmd = self.redo_stack[#self.redo_stack]
  table.remove(self.redo_stack, #self.redo_stack)
  table.insert(self.undo_stack, #self.undo_stack + 1, cmd)
  cmd:perform()
  return #self.redo_stack == 0
end

function CommandStack:undo()
  if (#self.undo_stack == 0) then
    print "Nothing left to undo!"
    return
  end
  local cmd = self.undo_stack[#self.undo_stack]
  table.remove(self.undo_stack, #self.undo_stack)
  table.insert(self.redo_stack, #self.redo_stack + 1, cmd)
  cmd:undo()
  return #self.undo_stack == 0
end

function CommandStack:add(cmd)
  if not cmd.can_undo then
    self.undo_stack = {}
  end
  self.redo_stack = {}
  table.insert(self.undo_stack, #self.undo_stack + 1, cmd)
end
