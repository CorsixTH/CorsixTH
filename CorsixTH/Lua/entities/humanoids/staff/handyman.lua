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

function Handyman:die()
  self:unassignTask()
  Staff.die(self)
  self.hospital:handymanDeath(self)
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

  print("Cleaning: " .. self:getAttribute("cleaning"),
        "Watering: " .. self:getAttribute("watering"),
        "Repairing: " .. self:getAttribute("repairing"))

  Humanoid.dump(self)
end

function Handyman:setProfile(profile)
  Staff.setProfile(self, profile)

  self.attributes["cleaning"] = 0.333
  self.attributes["watering"] = 0.333
  self.attributes["repairing"] = 0.333
end

function Handyman:goToStaffRoom()
  Staff.goToStaffRoom(self)
  self:unassignTask()
end

function Handyman:onPlaceInCorridor()
  self:unassignTask()
  Staff.onPlaceInCorridor(self)
end

-- Helper function to decide if Handyman fulfills a criterion
-- (one of "Doctor", "Nurse", "Psychiatrist", "Surgeon", "Researcher" and "Handyman", "Receptionist", "Junior", "Consultant")
function Handyman:fulfillsCriterion(criterion)
  return criterion == "Handyman"
end

function Handyman:afterLoad(old, new)
  if old < 163 then
    self.leave_priority = AnnouncementPriority.High
    self.leave_sounds = {"sack006.wav"}
  end
  Staff.afterLoad(self, old, new)
end

function Handyman:interruptHandymanTask()
  self:setDynamicInfoText("")
  if self.on_call then
    self.on_call.assigned = nil
    self.on_call = nil
  end
  self.task = nil
  self:setNextAction(AnswerCallAction())
end

function Handyman:searchForHandymanTask()
  self.task = nil
  local nr = math.random()
  local task, task2, task3
  local assignedTask = false
  if nr < self:getAttribute("cleaning") then
    task, task2, task3 = "cleaning", "watering", "repairing"
  elseif nr < self:getAttribute("cleaning") + self:getAttribute("watering") then
    task, task2, task3 = "watering", "cleaning", "repairing"
  else
    task, task2, task3 = "repairing", "watering", "cleaning"
  end
  local index = self.hospital:searchForHandymanTask(self, task)
  if index ~= -1 then
    self:assignHandymanTask(index, task)
    assignedTask = true
  else
    if self:getAttribute(task) < 1 then
      local sum = self:getAttribute(task2) + self:getAttribute(task3)
      if math.random(0, math.floor(sum * 100)) > math.floor(self:getAttribute(task2) * 100) then
        task2, task3 =  task3, task2
      end
      index = self.hospital:searchForHandymanTask(self, task2)
      if index ~= -1 then
        self:assignHandymanTask(index, task2)
        assignedTask = true
      elseif self:getAttribute(task3) > 0 then
        index = self.hospital:searchForHandymanTask(self, task3)
        if index ~= -1 then
          self:assignHandymanTask(index, task3)
          assignedTask = true
        end
      end
    end
  end
  if assignedTask == false then
    -- Make sure that the handyman isn't meandering already.
    for _, action in ipairs(self.action_queue) do
      if action.name == "meander" then
        return false
      end
    end
    if self:getRoom() then
      self:queueAction(self:getRoom():createLeaveAction())
    end
    self:queueAction(MeanderAction())
  end
  return assignedTask
end

function Handyman:assignHandymanTask(taskIndex, taskType)
  self.hospital:assignHandymanToTask(self, taskIndex, taskType)
  local task = self.hospital:getTaskObject(taskIndex, taskType)
  self.task = task
  if taskType == "cleaning" then
    if self:getRoom() then
      self:setNextAction(self:getRoom():createLeaveAction())
      self:queueAction(WalkAction(task.tile_x, task.tile_y))
    else
      self:setNextAction(WalkAction(task.tile_x, task.tile_y))
    end
    self:queueAction(SweepFloorAction(task.object))
    self:queueAction(AnswerCallAction())
  else
    if task.call.dropped then
      task.call.dropped = nil
    end
    task.call.dispatcher:executeCall(task.call, self)
  end
end

-- If the staff member had a task outstanding, unassigning them from that task.
-- Tasks with no handyman assigned will be eligible for reassignment by the hospital.
function Handyman:unassignTask()
  if self.task then
    self.task.assignedHandyman = nil
    self.task = nil
  end
end
