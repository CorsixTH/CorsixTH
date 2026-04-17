--[[ Copyright (c) 2009 Peter "Corsix" Cawley

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

corsixth.require("announcer")
corsixth.require("entities.humanoids.staff")

local AnnouncementPriority = _G["AnnouncementPriority"]

--! A Doctor, Nurse, Receptionist, Handyman, or Surgeon
class "Handyman" (Staff)

---@type Handyman
local Handyman = _G["Handyman"]

--!param ... Arguments to base class constructor.
function Handyman:Handyman(...)
  self:Staff(...)
  self.leave_sounds = {"sack006.wav"}
end

-- Set task type priority value
--!param task_type (string) task type
--!param priority (float) priority to set
function Handyman:setPriority(task_type, priority)
  self.attributes[task_type] = priority
end

-- Get task type priority value
--!param task_type (string) task type
--!return (float) priority
function Handyman:getPriority(task_type)
  return self:getAttribute(task_type)
end

function Handyman:dump()
  print("-----------------------------------")
  if self.on_call then
    print("On call: ")
    CallsDispatcher.dumpCall(self.on_call)
  else
    print('On call: no')
  end
  print("Busy: ", (self:isIdle() and "idle" or "busy") .. (self.pickup and " and picked up" or ''))
  if self.going_to_staffroom then print("Going to staffroom") end
  if self.last_room then
      print("Last room: ", self.last_room.room_info.id .. '@' .. self.last_room.x ..','.. self.last_room.y)
  end

  print("Cleaning: " .. self:getPriority("cleaning"),
        "Watering: " .. self:getPriority("watering"),
        "Repairing: " .. self:getPriority("repairing"))

  Humanoid.dump(self)
end

function Handyman:setProfile(profile)
  Staff.setProfile(self, profile)

  -- Set Handyman priorities by default
  self:setPriority("cleaning", 0.333)
  self:setPriority("watering", 0.333)
  self:setPriority("repairing", 0.333)
end

function Handyman:goToStaffRoom()
  self:unassignTask()
  Staff.goToStaffRoom(self)
end

-- Helper function to decide if Handyman fulfills a criterion
-- (one of "Doctor", "Nurse", "Psychiatrist", "Surgeon", "Researcher" and "Handyman", "Receptionist", "Junior", "Consultant")
function Handyman:fulfillsCriterion(criterion)
  return criterion == "Handyman"
end

function Handyman:onPickup()
  self:releaseHandymanFromTask(false)
  Staff.onPickup(self)
end

-- Deattaches the handyman from the task and forces him to search for a new one.
--!param reset_action_queue (bool) Should the handyman interrupt
-- the current action to search for a new task
function Handyman:releaseHandymanFromTask(reset_action_queue)
  self:setDynamicInfoText("")
  self:unassignTask()
  -- Lets find another task
  if reset_action_queue then
    self:setNextAction(AnswerCallAction())
  else
    self:queueAction(AnswerCallAction())
  end
end

function Handyman:searchForHandymanTask()
  self.task = nil
  local nr = math.random()
  local task_type_1, task_type_2, task_type_3
  local task_found = false
  -- Let's determine what type of tasks will be a priority for that handyman.
  if nr < self:getPriority("cleaning") then
    task_type_1, task_type_2, task_type_3 = "cleaning", "watering", "repairing"
  elseif nr < self:getPriority("cleaning") + self:getPriority("watering") then
    task_type_1, task_type_2, task_type_3 = "watering", "cleaning", "repairing"
  else
    task_type_1, task_type_2, task_type_3 = "repairing", "watering", "cleaning"
  end
  -- Let's search First priority type taks.
  local index = self.hospital:searchForHandymanTask(self, task_type_1)
  if index ~= -1 then
    -- Found a task for the handyman
    self:assignHandymanTask(index, task_type_1)
    task_found = true
  else
    -- Unable find any first type priority tasks for the handyman.
    if self:getPriority(task_type_1) < 1 then
      local sum = self:getPriority(task_type_2) + self:getPriority(task_type_3)
      if math.random(0, math.floor(sum * 100)) > math.floor(self:getPriority(task_type_2) * 100) then
        task_type_2, task_type_3 = task_type_3, task_type_2
      end
      -- Let's search again but for Second priority type tasks now.
      index = self.hospital:searchForHandymanTask(self, task_type_2)
      if index ~= -1 then
        self:assignHandymanTask(index, task_type_2)
        task_found = true
      elseif self:getPriority(task_type_3) > 0 then
        -- Let's search again but for Third priority type tasks now.
        index = self.hospital:searchForHandymanTask(self, task_type_3)
        if index ~= -1 then
          self:assignHandymanTask(index, task_type_3)
          task_found = true
        end
      end
    end
  end
  if task_found == false then
    -- Unable to find any task for the handyman. So let him meandering.
    self:doMeandering()
  end
  return task_found
end

function Handyman:doMeandering()
  -- Make sure that the handyman isn't meandering already.
  if self:isMeandering() then
    return
  end
  if self:getRoom() then
    self:queueAction(self:getRoom():createLeaveAction())
  end
  self:queueAction(MeanderAction())
end

-- Assign a handyman to a task
--!param task_index (integer) task index
--!param task_type (string) task type
function Handyman:assignHandymanTask(task_index, task_type)
  local task_object = self.hospital:assignHandymanToTask(self, task_index, task_type)
  if task_object then
    if task_type == "cleaning" then
      self:processCleaningTask(task_object)
    else
      if task_object.call.dropped then
        task_object.call.dropped = nil
      end
      task_object.call.dispatcher:executeCall(task_object.call, self)
    end
  end
end

function Handyman:processCleaningTask(task)
  if self:getRoom() then
    self:setNextAction(self:getRoom():createLeaveAction())
    self:queueAction(WalkAction(task.tile_x, task.tile_y))
  else
    self:setNextAction(WalkAction(task.tile_x, task.tile_y))
  end
  self:queueAction(SweepFloorAction(task.object))
  -- After cleaning find next task
  self:queueAction(AnswerCallAction())
end

-- If the staff member had a task outstanding, unassigning them from that task.
-- Tasks with no handyman assigned will be eligible for reassignment by the hospital.
function Handyman:unassignTask()
  self:unassignCall()
  if self.task then
    self.task.assignedHandyman = nil
    self.task = nil
  end
end

function Handyman:unassignCall()
  if self.on_call then
    CallsDispatcher.unassignCall(self.on_call, false)
  end
end

function Handyman:die()
  Staff.die(self)
  self:unassignTask()
  self.hospital:unassignHandymanTasks(self)
end

function Handyman:afterLoad(old, new)
  if old < 163 then
    self.leave_priority = AnnouncementPriority.High
    self.leave_sounds = {"sack006.wav"}
  end
  Staff.afterLoad(self, old, new)
end

