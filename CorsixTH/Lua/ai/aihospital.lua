--[[ Copyright (c) 2018 Justin Mugford

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

class "AIHospital" (Hospital)

---@type AIHospital
local AIHospital = _G["AIHospital"]

local daysDelay = {wait = 7, hire = 5, build = 8, buy = 2, money = 10}

local comfortFactors = {
  drinks_machine = {10, 9, 8, 7, 6, 5, 4, 3, 2, 1},
  bench = {5, 4, 4, 3, 3, 2, 2, 2, 1, 1},
  plant = {45, 32, 28, 24, 20, 16, 10, 7, 4, 2, 1},
  extinguisher = {32, 28, 24, 10, 16, 10, 7, 4, 2, 1}
}

function AIHospital:AIHospital(competitor, computer, ...)
  Hospital.Hospital(self, ...)
  if _S.competitor_names[competitor] then
    self.name = _S.competitor_names[competitor]
  else
    self.name = "NONAME"
  end
  self.is_in_world = false
  self.skill = computer.Skill
  self.staffLevels = computer.StaffLevels
  self.luck = computer.Luck
  self.speed = computer.Speed
  self.comfort = computer.Comfort
  --self.guessAt = computer.GuessAt
  self.policies["stop_procedure"] = computer.GuessAt / 100
  self.taskQueue = {}
  -- track staff rather than recalcuating
  self.staff_members = {
    Doctor = {},
    Nurse = {},
    Handyman = {},
    Receptionist = {},
  }
  self.staffcount = 0
  self.objects = {}

  self.patientcount = 0
  self.built_rooms = {}
  self.monthly_expenses = 0

  self.next_phase = "open"
  self.phase = "build"
  self.step = "init"
  self.next_move_date = 0
end

-- override methods that are going to be called if any
function AIHospital:spawnPatient(disease)
  -- TODO: Simulate patient

  local patient = self.world:spawnPatient(disease, self)
  patient.ticks = false

  self:countPatients()
  -- need to remove this
end

function AIHospital:sendPatientToNextDiagnosisRoom(patient)
  if #patient.available_diagnosis_rooms == 0 then
    -- The very rare case where the patient has visited all his/her possible diagnosis rooms
    -- There's not much to do then... Send home
    patient:goHome("kicked")
  else
    local next_room_id = math.random(1, #patient.available_diagnosis_rooms)
    local next_room = patient.available_diagnosis_rooms[next_room_id]
    local room = self.built_rooms[next_room]
    while #patient.available_diagnosis_rooms > 0 and not room do
      room = self.built_rooms[next_room]
      if not room then
        table.remove(patient.available_diagnosis_rooms, next_room_id)
        if #patient.available_diagnosis_rooms > 0 then
          next_room_id = math.random(1, #patient.available_diagnosis_rooms)
          next_room = patient.available_diagnosis_rooms[next_room_id]
        end
      end
    end
    -- exhausted all diagnosis rooms
    if not room then
      patient:goHome("kicked")
      return
    end

    if patient:agreesToPay("diag_" .. next_room) then
      patient.in_room = {room_info = self:getRoomInfo(next_room)}
    else
      patient:goHome("over_priced", "diag_" .. next_room)
    end
  end
end


function AIHospital:dealtWithPatient(patient)
  -- If the patient was sent home while in the room, don't
  -- do anything apart from removing any leading idle action.
  if not patient.hospital then
    return
  end

  if patient.disease then
    if not patient.diagnosed then
      if patient.phase == "gp" then
        self:receiveMoneyForTreatment(patient)
        patient:completeDiagnosticStep(self)

        if patient.diagnosis_progress >= self.policies["stop_procedure"] then
          patient:setDiagnosed()
          if patient:agreesToPay(patient.disease.id) then
            patient.phase = "treatment"
          else
            patient:goHome("over_priced", patient.disease.id)
          end

          -- Check if this disease has just been discovered
          if not self.disease_casebook[patient.disease.id].discovered then
            self.research:discoverDisease(patient.disease)
          end
        else
          self:sendPatientToNextDiagnosisRoom(patient)
        end
      else
      -- Patient not yet diagnosed, hence just been in a diagnosis room.
      -- Increment diagnosis_progress, and send patient back to GP.
        patient:completeDiagnosticStep(self)  -- self.staff_member << need to build an average profile of all staff for each type
        self:receiveMoneyForTreatment(patient)
        if patient:agreesToPay("diag_gp") then
          patient.phase = "gp"
        else
          patient:goHome("over_priced", "diag_gp")
        end
      end
    else
      -- Patient just been in a cure room, so either patient now cured, or needs
      -- to move onto next cure room.
      patient.cure_rooms_visited = patient.cure_rooms_visited + 1
      local next_room = patient.disease.treatment_rooms[patient.cure_rooms_visited]
      if next_room then
        patient.phase = 'treatment'
        patient.in_room = {room_info = self:getRoomInfo(next_room)}
      else
        -- Patient is "done" at the hospital
        patient:treatDisease()
      end
    end
  end
end

function AIHospital:logTransaction()
  -- AI doesn't need a log of transactions, as it is only used for UI purposes
end

function AIHospital:hasStaffedDesk()
  return #self.staff_members.Receptionist > 0 and self.objects.reception_desk > 0
end

function AIHospital:isReputationChangeAllowed(amount)
    return Hospital.isReputationChangeAllowed(self, amount)
end

-- TODO - tweak this
--! Update the Hospital.patientcount variable.
function AIHospital:countPatients()

  self.patientcount = 0
  for _, patient in ipairs(self.patients) do
      if not patient.going_home then
        self.patientcount = self.patientcount + 1
    end
  end
  return self.patientcount
end

function AIHospital:countStaff()
  self.staffcount = #self.staff_members.Receptionist + #self.staff_members.Doctor + #self.staff_members.Nurse + #self.staff_members.Handyman
end

function AIHospital:onEndMonth()
  -- TODO need to receive cash too
  self:spendMoney(self.monthly_expenses)
end


local function getSupportPatientsLevel(category, level)
  local supportedpatients
  if category == 'Nurse' or category == 'Doctor' then
    supportedpatients = 55 - (10.5 * level) + (0.5 * level ^ 2)
  elseif category == 'Handyman' then
    supportedpatients = 10 - level
  elseif category == 'Receptionist' then
    supportedpatients = 40 - (4 * level)
  else
    error("Unknown staff type " .. category)
  end
  return supportedpatients
end

--[[ One per day we check to process AI patients progress
]]--
function AIHospital:onEndDay()
  -- process patients first
  for key, patient in pairs(self.patients) do
    patient:tickDay()
    -- if they died, cured, left or kicked
    if patient.going_home then
      self.patients[key] = nil -- remove them from further processing
    end
  end

  self:countPatients()

  if self.next_move_date == 0 or self.next_move_date < self.world.game_date then
    local aispeed = math.max(1, self.speed - math.random(0, self.skill))

    -- process queued item
    if #self.taskQueue > 0 then
      local task = self:removeTaskFromQueue()
      if task.type == "hire" then
        -- if we attempt to hire more than 1 like surgeons for surgery, if it can hire 1, it will queue the 2nd one up in hire staff to be processed later
        -- if it fails, we'll requeue the original request and attempt a hire later
        if not self:hireStaff(task.val1, task.val2) then
          self:queueTask("hire", task.val1, task.val2)
        end
      elseif task.type == "build" then
        if not self:buyRoom(task.val1, task.val2) then
          self:queueTask(task.type, task.val1, task.val2)
        end
      elseif task.type == "buy" then
        self:buyObject(task.val1)
        task.val2 = task.val2 - 1
        if task.val2 > 0 then
          self:queueNextTask(task.type, task.val1, task.val2)
          self.next_move_date = self.world.game_date:plusHours(math.floor(aispeed * daysDelay.buy / 100 * Date.hoursPerDay()))
          return
        end
      elseif task.type == "money" then
        -- haven't got it adjusting loan/paying back loan
        -- however we can use this as a delay to wait for money to come in
        -- maybe we purge any other "money" tasks if we have a positive account balance
        while self:removeTaskFromQueue("money") do
        end
      end
      -- preparing next
      -- if we process we want to set standard delay of upto 7 days and return
      self.next_move_date = self.world.game_date:plusHours(math.floor(aispeed * daysDelay.wait / 100 * Date.hoursPerDay()))
      return
    end

    -- enqueue tasks for the phase of the build and run of hospital
    if self.phase == "build" then
      -- there should be no financial impediment in meeting these requirements
      self:queueTask("buy", "reception_desk", 1)
      self:queueTask("hire", "Receptionist")
      -- buy simplest comfort objects
      self:queueTask("buy", "bench", 4)
      -- build a gps office - original th would not have a patient visit reception until a gps office was built
      -- they would sit around and wait, corsix they will visit reception desk and then wait for a gps office
      self:addRoom("gp")
      self.phase = "wait"
    elseif self.phase == "open" then
      self.opened = true
      self.world.ui.adviser:say(_A.competitors.hospital_opened:format(self.name))
      self:queueTask("hire", "Doctor")
      self:addRoom("diagnostic")
      self.phase = "wait"
      self.next_phase = "run"
    elseif self.phase == "run" then
      -- this might bind the AI so it needs testing
      if not self:peekTaskFromQueue("hire") then
        -- hire need staff levels... building room will also enqueue a hire task
        local stafftype
        for _, staffType in ipairs({'Nurse', 'Doctor', 'Handyman', 'Receptionist'}) do
          if #self.staff_members[staffType] < math.max(1,math.floor((self.patientcount / getSupportPatientsLevel(staffType, self.staffLevels)))) then
            stafftype = staffType
            break
          end
        end
        if stafftype then
          self:queueTask("hire", stafftype)
          if stafftype == "Receptionist" then
            self:queueTask("buy", "reception_desk")
          end
        end
      end
      if not self:peekTaskFromQueue("build") then
        -- build more rooms, diagnostic in preference to the treatment rooms
        local room = self:addRoom('diagnostic') or self:addRoom('treatment')
        if room then
          if room.required_staff then
            for staffType, count in pairs(room.required_staff) do
              self:queueTask("hire", staffType, count)
            end
          end
        end
      end
      if not self:peekTaskFromQueue("buy") then
        -- increase comfort
        local comfortObj, required
        for _, obj in ipairs({'drinks_machine', 'bench', 'plant', 'extinguisher'}) do
          required = math.max(1,math.floor(self.patientcount / comfortFactors[obj][self.comfort]))
          if (self.objects[obj] and self.objects[obj] or 0) < required then
            comfortObj, required = obj, required - (self.objects[obj] and self.objects[obj] or 0)
            break
          end
        end
        if comfortObj then
          self:queueTask("buy", comfortObj, math.min(4,required))
        end
      end
    else
      -- we are waiting for a phase to complete
      if #self.taskQueue == 0 then
        self.phase = self.next_phase
      end
    end

    -- calculate next queued items delay, from current start of quuee
    local task = self:peekTaskFromQueue()
    -- get delays days from task.type table and create the delay
    aispeed = math.max( 1, self.speed - math.random(0, self.skill))
    if task and task.type ~= "wait" then
      -- just some more variability it probably doesn't have a big effect as we are only processing once per day
      -- but unlucky ones may wipe out some of their skill gain
      aispeed = math.max(100, aispeed + math.random(0, self.luck))
      self.next_move_date = self.world.game_date:plusHours(math.floor(aispeed * daysDelay[task.type] / 100 * Date.hoursPerDay()))
    end
  end
  -- put the hospital build/run moves here instead of tick
end

function AIHospital:hasRequiredStaff(patient)
  if self.built_rooms[patient.disease.treatment_rooms[1]] then
    local skill, staffCount
    -- should loop once
    for k, v in pairs(self.built_rooms[patient.disease.treatment_rooms[1]].required_staff ) do
      skill, staffCount = k, v
    end
    local category = skill
    if category == "Psychiatrist" or category == "Surgeon" or category == "Researcher" then
      category = "Doctor"
    end
    local counter = 0
    for _, staff in ipairs(self.staff_members[category]) do
      if staff and Staff.fulfillsCriterion(staff, skill) then
        counter = counter + 1
      end
    end
    return counter >= staffCount
  end
  return false
end

--! Update the 'cured' counts of the hospital.
--!param patient Patient that was cured.
function AIHospital:updateCuredCounts(patient)
  self:changeReputation("cured", patient.disease)

  self.num_cured = self.num_cured + 1
  self.num_cured_ty = self.num_cured_ty + 1
end

--! Update the 'not cured' counts of the hospital.
--!param patient Patient that was not cured.
--!param reason (string) the reason why the patient is not cured.
--! -"kicked": Patient goes home early (manually sent, no treatment room, etc).
--! -"over_priced": Patient considers the price too high.
function AIHospital:updateNotCuredCounts(patient, reason)
  self:changeReputation(reason, patient.disease)
  self.not_cured = self.not_cured + 1
  self.not_cured_ty = self.not_cured_ty + 1
end

--[[ Determines how much the player should receive after a patient is treated in a room.

!param patient (Patient) The patient that just got treated.
]]
function AIHospital:receiveMoneyForTreatment(patient)
  if not self.world.free_build_mode then
    local disease_id = patient:getTreatmentDiseaseId()
    if disease_id == nil then return end
    local amount = self:getTreatmentPrice(disease_id)

    -- 25% of the payments now go through insurance
    if patient.insurance_company then
      self:addInsuranceMoney(patient.insurance_company, amount)
    else
      -- patient is paying normally (but still, he could feel like it's
      -- under- or over-priced and it could impact happiness and reputation)
      --self:computePriceLevelImpact(patient, casebook)
      self:receiveMoney(amount)
    end
  end
end

local function canAffordCost(self, cost)
  if cost < self.balance and self.balance >= 0 then
    return true
  end
  return false
end

-- convert these 3 functions to local functions

function AIHospital:queueNextTask(taskType, value1, value2)
  local task = {type=taskType,val1=value1, val2=value2}
  table.insert(self.taskQueue, 1, task)
end

function AIHospital:peekTaskFromQueue(taskType)
  if taskType then
    for _, task in ipairs(self.taskQueue) do
      if task.type == taskType then
        return task
      end
    end
  else
    return self.taskQueue[1]
  end
end

function AIHospital:removeTaskFromQueue(taskType)
  if taskType then
    for i, task in ipairs(self.taskQueue) do
      if task.type == taskType then
        table.remove(self.taskQueue, i)
        return task
      end
    end
  else
    local task = self.taskQueue[1]
    table.remove(self.taskQueue, 1)
    return task
  end
end

function AIHospital:queueTask(taskType, value1, value2)
  local task = {type=taskType,val1=value1, val2=value2}
  self.taskQueue[#self.taskQueue + 1] = task
end

function AIHospital:buyObject(objectType)
  local cost = self:getObjectBuildCost(objectType)
  if canAffordCost(self, cost) then
    self:spendMoney(cost)
    self.objects[objectType] = self.objects[objectType] and self.objects[objectType] + 1 or 1
  else
    -- confirm this is needed
    -- fact that the 2nd parameter is 0 means nothing gets done, more of a wait for income type delay
    self:queueTask(4, 0, 0)
  end
end

function AIHospital:buyRoom(roomType, room)
  local cost = self:getRoomBuildCost(roomType)
  if cost and canAffordCost(self, cost) then
    self:spendMoney(cost)
    self.built_rooms[roomType] = room
    for obj, count in pairs(room.objects_needed) do
      self:buyObject(obj, count)
    end
    return true
  else
    return false
  end
end

function AIHospital:hireStaff(category, count)
  local skill = category
  if category == "Psychiatrist" or category == "Surgeon" or category == "Researcher" then
    category = 'Doctor'
  end
  local profile, index
  for i, staff in ipairs(self.world.available_staff[category]) do
    if staff and category == 'Receptionist' or self:fulfillsCriterion(staff, skill) then
      profile, index = staff, i
      break
    end
  end
  if not profile or not canAffordCost(self, profile.wage * 1.2) then
    return false
  end
  table.remove(self.world.available_staff[category], index)
  -- adjust stats - move that staffs profile into self.staff_members[category]
  -- saving a reference to that staff member in the hospital
  self.staffcount = self.staffcount + 1
  self.staff_members[category][#self.staff_members[category]+1] = profile
  self.monthly_expenses = self.monthly_expenses + profile.wage
  if count and count > 1 then
    count = count - 1
    self:queueTask("hire", skill, count)
  end
  return true
end

local profile_attributes = {
  Psychiatrist = "is_psychiatrist",
  Surgeon = "is_surgeon",
  Researcher = "is_researcher",
}

-- Helper function to decide if Staff fulfills a criterion
-- (one of "Doctor", "Nurse", "Psychiatrist", "Surgeon", "Researcher" and "Handyman")
function AIHospital:fulfillsCriterion(staff, criterion)
  local class = staff.humanoid_class
  if criterion == "Doctor" then
    if class == "Doctor" or class == "Surgeon" then
      return true
    end
  elseif criterion == "Nurse" then
    if class == "Nurse" then
      return true
    end
  elseif criterion == "Psychiatrist" or criterion == "Surgeon" or criterion == "Researcher" then
    if staff[profile_attributes[criterion]] == 1.0 then
      return true
    end
  elseif criterion == "Handyman" then
    if class == "Handyman" then
      return true
    end
  else
    error("Unknown criterion " .. criterion)
  end
  return false
end

--[[ Returns how much a given object currently costs to purchase. The cost
may be affected by research progress.

!param name (string) The name (id) of the object to investigate.
]]
function Hospital:getRoomBuildCost(name)
  -- Everything is free in free build mode.
  if self.world.free_build_mode then return 0 end

  local cfg_rooms = self.world.map.level_config.rooms
  local room_def = TheApp.rooms[name]
  -- Get how much this item costs at the start of the level.
  local obj_cost = cfg_rooms[room_def.level_config_id].Cost
  return obj_cost
end

function AIHospital:addRoom(roomType)
  -- get all rooms available
  -- check also if it has been researched etc or built already
-- for each roomType (Diagnostic, Treatment, Facilities), build in the order displayed below
  -- Diagnostic: general diagnosis, xray, cardio, scanner, psych, blood machine, ultrascan, ward
  -- Treatment:  pharmacy, psych, ward, op theatre, inflation, electrolysis, slack tongue, fracture, hair restoration, jelly vat, decontamination, alien
  -- Facilities: staff, research, toilets, training
  local buildroom
  if roomType == 'diagnostic' then
    for _, room in pairs({'general_diag', 'x_ray', 'cardiogram', 'scanner', 'psych', 'blood_machine', 'ultrascan', 'ward'}) do
      if not self:hasRoomOfType(room) then
        for discroom, _ in pairs(self.discovered_rooms) do
          if discroom.id == room then
            buildroom = discroom
            break
          end
        end
      end
      if buildroom then
        break
      end
    end
  elseif roomType == 'treatment' then
    for _, room in pairs({'pharmacy', 'psych', 'ward', 'op_theatre', 'inflation', 'electrolysis', 'slack_tongue', 'fracture_clinic', 'hair_restoration', 'jelly_vat', 'decontamination', 'dna_fixer'}) do
      if not self:hasRoomOfType(room) then
        for discroom, _ in pairs(self.discovered_rooms) do
          if discroom.id == room then
            buildroom = discroom
            break
          end
        end
      end
      if buildroom then
        break
      end
    end
    --[[ these aren't supported in AI, not sure how it does research in later levels if at all
  elseif roomType == 'facilities' or roomType == 2 then
    for _, room in pairs({'toilets', 'staff', 'research', 'training'}) do
      if not self:hasRoomOfType(room) then
        for discroom, _ in pairs(self.discovered_rooms) do
          if discroom.id == room then
            buildroom = room
            break
          end
        end
      end
      if buildroom then
        break
      end
    end
  --]]--
  else
    -- could change this so there is a ratio of like x patients / per gp office
    if not self:hasRoomOfType("gp") then
      for discroom, _ in pairs(self.discovered_rooms) do
        if discroom.id == "gp" then
          buildroom = discroom
          break
        end
      end
    end
  end

  if not buildroom then return end

  local cost = self:getRoomBuildCost(buildroom.id)
  if canAffordCost(self, cost) then
    self:queueTask("build", buildroom.id, buildroom)
  else
    -- need more cash
    self:queueTask(4, 0, 0)
  end
  return buildroom
end

function AIHospital:hasRoomOfType(roomType)
  return not not self.built_rooms[roomType]
end

function AIHospital:getRoomInfo(name)
  return self.built_rooms[name]
end

-- provides the skill profile of the hospital average
function AIHospital:getAvgStaffMember(staffType)
 -- TODO: get average staff skill for progressing diagnosis success
end
