--[[ Copyright (c) 2010 Peter "Corsix" Cawley

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

--! Base class for all low-level and medium-level `Humanoid` animation and
-- position controllers.
class "Action" {}

--! Constructor
--! Constructors for derived classes should just take a vararg list and pass it
-- down to the base class constructor. Fields may be initialised to default
-- values in the constructor, but anything non-trivial should only be done once
-- the action is added to a queue (i.e. in `onAddToQueue`).
function Action:Action()
end

--! Create a copy of the action.
--! This can only be called on actions which have not yet been inserted into
-- an action queue (from a technical point of view, cloning an action once
-- it is in a queue is difficult, as it will have accumulated some state). This
-- method only needs overriding if the action constructor does something
-- interesting.
--!return (Action) A new instance of an `Action` which will behave in the same
-- way once inserted into an action queue.
function Action:clone()
  assert(not self.humanoid, "Cannot clone an action which is in a queue")
  
  -- Create a copy of the parameters to the action. This assumes that the
  -- constructor didn't do something clever with parameters.
  local new = {}
  for k, v in pairs(self) do
    new[k] = v
  end
  
  -- Turn the copy into a class instance. This assumes that class instances
  -- are done purely by metatable and that the constructor doesn't do anything.
  return setmetatable(new, getmetatable(self))
end

--! Called immediately after the action reaches the front of a `Humanoid`'s
-- action queue.
--! Dervied classes should override this to implement the logic for the action,
-- but the override must call the base class' onStart() method.
function Action:onStart()
  assert(self.humanoid.action_queue[1] == self, "Action:onStart called wrongly")
  assert(not self.is_actve, "Action:onStart called twice")
  self.is_active = true  
end

--! Called immediately before the action leaves the front of a `Humanoid`'s
-- action queue.
--! Dervied classes may override this to implement cleanup logic for the
-- action, but the override must call the base class' onFinish() method.
function Action:onFinish() 
  if not self.humanoid then
    -- This typically occurs because a derived class didn't call onAddToQueue()
    -- in overridden onAddToQueue(), hence include the name of the derived
    -- class.
    error(class.type(self) .. ":onFinish called when not in queue")
  end
  if self.humanoid.action_queue[1] ~= self then
    error("Action:onFinish called wrongly")
  end
  if not self.is_active then
    -- This typically occurs because a derived class didn't call onStart() in
    -- an overridden onStart(), hence include the name of the derived class.
    local what = class.type(self)
    error(what..":onFinish called without matching Action:onStart")
  end
  self.is_active = false
  
  -- Timers should only be set by the active action, and are almost always tied
  -- to the action, so ensure that the timer is cleared.
  self.humanoid:callTimer()
  if self.humanoid.timer_function then
    -- The timer set another timer, which it shouldn't have.
    error("Timer left hanging")
  end
end

--! Query if the action can be immediately removed from the action queue which
-- it is currently in.
--! Derived classes may override this, but if they do so, then the overridden
-- method should return false or do a tail call to the base class' method, as
-- directly returning true may contradict the wishes of a base class.
--!param is_high_priority (boolean) true if the action is being cancelled due
-- to a user action which should have immediate result, false if the action is
-- being cancelled for less important reason.
--!return (boolean) true if the action can be removed from the queue, which
-- will likely result in onRemoveFromQueue() (and if at the head of the queue,
-- onFinish()) being called. false if the action should not be removed from the
-- queue, which will likely result in truncate() being called.
function Action:canRemoveFromQueue(is_high_priority)
  return true
end

--! Attempt to make the action finish faster than it normally would.
--! Note that if the action hasn't started yet, then this is an instruction
-- to finish quickly once it does start. Also note that this method may be
-- called multiple times with different values for is_high_priority. Derived
-- classes should override this even if they can always be cancelled, as a base
-- class may return false for canRemoveFromQueue().
--!param is_high_priority (boolean) true if the action is being truncated due
-- to a user action which should have immediate result, false if the action is
-- being truncated for a less important reason.
function Action:truncate(is_high_priority)
end

--! Attempt to insert a relatively unimportant action into the action queue
-- immediately before this one.
--! This is used for tasking `Humanoid`s to drink machines, and similar things
-- which aren't critical. Derived classes must override this method if they are
-- unimportant enough to be postponable. Note that this method is only called
-- when this action is in a queue.
--!param action (Action) The action which should be inserted before this one in
-- the action queue (or not, as the case may be).
--!param index_in_queue (integer) The index of this action in the action queue
-- of the `Humanoid` whose queue it is currently in.
--!return (boolean) true if `action` was inserted into the action queue, false
-- otherwise.
function Action:postponeFor(action, index_in_queue)
  return false
end

--! Called immediately before the action is inserted into a `Humanoid`'s action
-- queue.
--! Note that an action can only ever be in a single action queue at a time.
-- Dervied classes may override this to implement initialisation logic for the
-- action, but the override must call the base class' onAddToQueue() method.
--!param humanoid (Humanoid) The humanoid whose action queue the action is
-- about to be inserted into.
function Action:onAddToQueue(humanoid)
  assert(self.humanoid == nil, "Action cannot be in multiple queues")
  self.humanoid = humanoid
  if self.attr_while_in_queue then
    humanoid[self.attr_while_in_queue] = true
  end
end

--! Called immediately after the action is removed from a `Humanoid`'s action
-- queue.
--! Dervied classes may override this to implement cleanup logic for the
-- action, but the override must call the base class' onRemoveFromQueue()
-- method. If an overridden version of this method modifies the action queue
-- which it was in, then it should only modify the tail of the queue which came
-- after the action, and not touch anything which came before it.
function Action:onRemoveFromQueue()
  assert(self.humanoid ~= nil, "Action is not in any action queue")
  if self.is_active then
    error(class.type(self) .. " removed from action queue while active")
  end
  if self.attr_while_in_queue then
    self.humanoid[self.attr_while_in_queue] = nil
  end
  self.humanoid = nil
end

--! Generate a short (non-localised) string describing the action for debugging
-- purposes.
--! Derived classes should override this and incluce any important state in the
-- resulting string, as this default implemenation only returns the name of the
-- action.
--!return (string)
function Action:toString()
  local name = class.type(self)
  if #name > 6 and name:sub(-6, -1) == "Action" then
    name = name:sub(1, -7)
  end
  return name
end
