--[[ Copyright (c) 2013 William "sadger" Gatens

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

class "VaccinateAction" (HumanoidAction)

---@type VaccinateAction
local VaccinateAction = _G["VaccinateAction"]

-- Vaccinate action constructor for a nurse.
--!param patient (Patient) Patient to vaccinate.
--!param fee Amount of money to pay.
function VaccinateAction:VaccinateAction(patient, fee)
  assert(class.is(patient, Patient), "Invalid value for parameter 'patient'")
  assert(type(fee) == "number", "Invalid value for parameter 'fee'")

  self:HumanoidAction("vaccinate")
  self.patient = patient -- Patient to vaccinate.
  self.vaccination_fee = fee -- Money to get from the patient.
  self:setMustHappen(true)
end

local is_in_adjacent_square = permanent"vacc_adjacent_square"(
function (patient,nurse)
  local x1, y1 = patient.tile_x, patient.tile_y
  local x2, y2 = nurse.tile_x, nurse.tile_y

  if not x1 or not x2 or not y1 or not y2 then
    return false
  end

  -- Determine if they are in an adjacent square
  local x_diff = math.abs(x1-x2)
  local y_diff = math.abs(y1-y2)
  if (x_diff + y_diff == 1) then
  -- And neither of them are in a room so must be outside
   return (not patient:getRoom() and not nurse:getRoom())
  end
end)

local find_face_direction = permanent"vacc_find_face_direction"(
function(nurse, patient)
  local nx, ny = nurse.tile_x, nurse.tile_y
  local px, py = patient.tile_x, patient.tile_y

  local x_diff = px - nx
  local y_diff = py - ny

  if x_diff == 1 then
    return "east"
  elseif x_diff == -1 then
    return "west"
  elseif y_diff == -1 then
    return "north"
  elseif y_diff == 1 then
    return "south"
  end
end)


local interrupt_vaccination = permanent"action_interrupt_vaccination"(
function(action, humanoid)
  local epidemic = humanoid.hospital.epidemic
  epidemic:interruptVaccinationActions(humanoid)
  humanoid:setTimer(1, humanoid.finishAction)
end)


local function vaccinate(action, nurse)
  assert(nurse.humanoid_class == "Nurse")

  local patient = action.patient

  local perform_vaccination = --[[persistable:action_perform_vaccination]] function(humanoid)
    -- Check if they STILL are in an adjacent square
    if is_in_adjacent_square(nurse, patient) then
      CallsDispatcher.queueCallCheckpointAction(nurse)
      nurse:queueAction(AnswerCallAction())
      -- Disable either vaccination icon that may be present (edge case)
      patient:setMood("epidemy2", "deactivate")
      patient:setMood("epidemy3", "deactivate")
      patient:setMood("epidemy1", "activate")
      patient.vaccinated = true
      patient.hospital:spendMoney(action.vaccination_fee, _S.transactions.vaccination)
      patient:updateDynamicInfo()
    else
      patient:setMood("epidemy3", "deactivate")
      patient:setMood("epidemy2", "activate")
      -- Drop it they may not even be the vacc candidate anymore
      CallsDispatcher.queueCallCheckpointAction(nurse)
      nurse:queueAction(AnswerCallAction())
      patient.reserved_for = nil
    end
  end

  if is_in_adjacent_square(nurse,patient) then
    local face_direction = find_face_direction(nurse,patient)
    nurse:queueAction(IdleAction():setDirection(face_direction):setCount(5)
        :setAfterUse(perform_vaccination):setOnInterrupt(interrupt_vaccination):setMustHappen(true))

  else
    patient:removeVaccinationCandidateStatus()
    nurse:setCallCompleted()
    patient.reserved_for = nil
    nurse:queueAction(MeanderAction())
  end
  nurse:finishAction()
end

return vaccinate

