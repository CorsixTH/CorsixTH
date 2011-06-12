--[[ Copyright (c) 2011 Edvin "Lego3" Linge

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

--[[ Notes about research speed.
Original game times at 20 % in all categories with a medium doctor at level 3:
Slicer discovered in about 120 days. (10000 points)
Pump improved in about 60 days. (30000 points * 20 % as first improvement)
Invisibility improved in about 90 days. (10000 points)
Note that the original requires a nurse and a pharmacy before drugs 
get improved. On the other hand it appears that the research is 
stored for future use anyway.
--]]

--! Manages all things related to research for one hospital.
class "ResearchDepartment"

function ResearchDepartment:ResearchDepartment(hospital)
  self.hospital = hospital
  self.world = hospital.world
  -- This list contains a lot of information.
  -- Progress of object discovery, object improvement, drug improvement
  -- dito costs and room build costs.
  self.research_progress = {}
  self.level_config = hospital.world.map.level_config
  self:initResearch()
end

-- Initialize research for the level.
function ResearchDepartment:initResearch()
  local hospital = self.hospital
  local config = self.level_config.objects
  local cure, diagnosis, improve, drug
  -- Initialize object research
  for _, object in ipairs(TheApp.objects) do
    if config[object.thob] and (config[object.thob].AvailableForLevel == 1)
    and object.research_category then
      self.research_progress[object] = {
        points = 0, 
        start_strength = config[object.thob].StartStrength,
        cost = object.build_cost,
        discovered = config[object.thob].StartAvail == 1,
        strength_imp = 0,
        cost_imp = 0,
      }
      if config[object.thob].StartAvail == 0 then
        if object.research_category == "cure" then
          cure = object
        elseif object.research_category == "diagnosis" then
          diagnosis = object
        end
      end
      -- TODO: Do we want some kind of specific order here, e.g.
      -- the same as in the original?
      if object.default_strength and config[object.thob].StartAvail == 1 then
        improve = object
      end
    end
  end
  -- Now add drug research
  for _, disease in pairs(hospital.disease_casebook) do
    if disease.drug then
      self.research_progress[disease] = {
        points = 0,
        effect_imp = 1,
        cost_imp = 1,
      }
      if disease.discovered then
        drug = disease
      end
    end
  end
  -- Add a dummy to specialisation. The difference is that while it still says
  -- 20 % in that area it doesn't cost anything to the player
  local drain = {dummy = true}
  self.research_progress[drain] = {points = 0}
  self.drain = drain
  
  local policy = {
    cure = {frac = cure and 20 or 0, current = cure},
    diagnosis = {frac = diagnosis and 20 or 0, current = diagnosis},
    drugs = {frac = drug and 20 or 0, points = 0, current = drug},
    improvements = {frac = improve and 20 or 0, points = 0, current = improve},
    specialisation = {frac = 20, points = 0, current = drain},
  }
  local sum = 0
  for _, cat in pairs(policy) do
    sum = sum + cat.frac
  end
  if sum == 20 then
    -- No research to be done
    policy.specialisation.frac = 0
    policy.global = 0
  else
    -- If some category is already done, put the free points in another one.
    if sum < 100 then
      for _, tab in pairs(policy) do
        if tab.frac > 0 then
          tab.frac = tab.frac + 100 - sum
          sum = 100
          break
        end
      end
    end
    policy.global = sum
  end
  self.research_policy = policy

  if not hospital.research_dep_built then
    hospital.research_dep_built = false
  end
end

function ResearchDepartment:checkAutomaticDiscovery(month)
  for object, progress in pairs(self.research_progress) do
    -- Only check objects
    if object.default_strength then
      local avail_at = self.level_config.objects[object.thob].WhenAvail
      if not progress.discovered and avail_at ~= 0 and month >= avail_at then
        self:discoverObject(object, true)
      end
    end
  end
end

--[[! Finds out what to research next in the given research area.
!param category The research area. One of cure, diagnosis, drugs,
improvements and specialisation
--]]
function ResearchDepartment:nextResearch(category)
  local current = self.research_policy[category].current
  -- First make sure that the current research target actually has been discovered.
  -- Otherwise don't do anything.
  if not (current.drug or self.research_progress[current].discovered) then
    return
  end
  local hospital = self.hospital
  self.research_policy[category].current = nil
  local found_one = false
  if category == "drugs" then
    local worst_effect = 100
    for _, disease in pairs(hospital.disease_casebook) do
      if disease.cure_effectiveness < worst_effect then
        found_one = true
        if disease.discovered then
          self.research_policy[category].current = disease
          worst_effect = disease.cure_effectiveness
        end
      end
    end
  elseif category == "improvements" then
    -- Find the object which needs improvements the most.
    local min_strength = self.level_config.gbv.MaxObjectStrength
    local max_strength = self.level_config.gbv.MaxObjectStrength
    for object, progress in pairs(self.research_progress) do
      if object.default_strength then
        -- Don't improve those that already have the max strength
        if progress.start_strength < max_strength then
          if progress.discovered and progress.start_strength < min_strength then
            self.research_policy[category].current = object
            min_strength = progress.start_strength
          else
            found_one = true
          end
        end
      end
    end
  else
    for object, progress in pairs(self.research_progress) do
      if object.research_category == category and not progress.discovered then
        self.research_policy[category].current = object
      end
    end
  end
  if found_one and not self.research_policy[category].current then
    -- There is a drug or machine which needs improving, but it 
    -- has not been discovered yet.
    self.research_policy[category].current = self.drain
    self.research_progress[self.drain] = {points = 0}
  end
  if not self.research_policy[category].current then
    local cat = self.research_policy[category]
    -- Nothing more to research
    cat.current = nil
    self.research_policy.global = self.research_policy.global - cat.frac
    cat.frac = 0
    if self.hospital == self.world.ui.hospital then
      self.world.ui.adviser:say(_S.adviser.research.drug_fully_researched
      :format(_S.research.categories[category]))
    end
    -- Notify any research window
    local window = self.world.ui:getWindow(UIResearch)
    if window then
      window:updateCategories()
    end
  end
end

--[[ Returns how many points are required to discover something
about the given thing.
It may be an object or a drug, being improved or researched.
If this thing cannot be processed nil is returned.
!param thing The thing to check, either a drug or an object.
--]]
function ResearchDepartment:getResearchRequired(thing)
  local required
  local level_config = self.level_config
  local objects = level_config.objects
  local expert = level_config.expertise
  local research_info = self.research_progress[thing]

  if thing.thob then
    -- An object
    required = objects[thing.thob].RschReqd
    if not required then
      -- It didn't know, so use the fallback instead.
      if not thing.research_fallback then
        -- This object is not researchable!
        print(("Warning: %s has been defined as "):format(thing.id)
        .. "researchable, but no requirements to fulfil could be found.")
      else
        required = expert[thing.research_fallback].RschReqd
      end
    end
    -- Actually want to know how much to improve?
    if research_info.discovered then
      local improve_percent = level_config.gbv.RschImproveCostPercent
      local increment = level_config.gbv.RschImproveIncrementPercent
      improve_percent = improve_percent + increment*research_info.cost_imp
      required = required * improve_percent/100
    end
  elseif thing.drug then
    -- A drug
    required = expert[thing.disease.expertise_id].RschReqd
  end
  return required
end

--[[ Add some more research points to research progress. If 
autopsy_room is specified points are not used. Instead research
progresses according to the level config for autopsies. 
Otherwise they will be divided according to the research policy 
into the different research areas.
!param points (integer) The total amount of points (before applying
any level specific divisors to add to research.
!param autopsy_room (string) If a specific room should get points following
an autopsy, then this is the id of that room.
]]
function ResearchDepartment:addResearchPoints(points, autopsy_room)

  local level_config = self.level_config
  local objects = level_config.objects
  local expert = level_config.expertise
  local areas = self.research_policy
  local hospital = self.hospital

  ---------------------- An autopsy has been done ---------------------------
  if autopsy_room then
    -- Do something only if the room is among those not yet discovered.
    for room, value in pairs(hospital.undiscovered_rooms) do
      if room.id == autopsy_room then
        -- Find an object within this room that needs research points.
        for object, _ in pairs(room.objects_needed) do
          local research = self.research_progress[TheApp.objects[object]]
          if research and not research.discovered then
            local required = self:getResearchRequired(TheApp.objects[object])
            local advance = required * level_config.gbv.AutopsyRschPercent/100
            research.points = research.points + advance
            
            -- Maybe we now have enough to discover the object?
            if research.points > required then
              self:discoverObject(TheApp.objects[object])
            end
            break
          end
        end
      end
    end
  else
    --------------------------- General research ------------------------------
    -- Divide the points into the different areas. If global is not at 100 % 
    -- the total amount is lowered, but then cost is also reduced.

    -- Fetch the level research divisor.
    local divisor = level_config.gbv.ResearchPointsDivisor or 5

    points = math.ceil(points*self.research_policy.global/(100*divisor))

    -- Divide the points into the different categories and check if 
    -- it is time to discover something
    for name, info in pairs(areas) do
      -- Don't touch the value "global".
      if type(info) == "table" then
        -- Some categories may be finished
        if info.current then
          -- Add new points to this category's current focus. 
          local research_info = self.research_progress[info.current]
          local stored = research_info.points
          -- Add just a little randomness
          research_info.points = stored + math.n_random(1, 0.2)*points*info.frac/100
          local required = self:getResearchRequired(info.current)
          if required and required < research_info.points then
            research_info.points = 0
            -- On the specialisation pass any of these categories are eligible.
            ---------------- Discovering objects ----------------------
            if info.current.thob and not research_info.discovered then
              self:discoverObject(info.current)
            ----------------- Improving drugs -------------------------
            elseif info.current.drug then
              self:improveDrug(info.current)
            --------------- Improving machines ------------------------
            elseif info.current.thob then
              self:improveMachine(info.current)
            end
          end
        end
      end
    end
  end
end

--[[ Called when it is time to improve a drug's strength or cost.
!param drug The drug to improve, table taken from world.available_diseases
--]]
function ResearchDepartment:improveDrug(drug)
  local research_info = self.research_progress[drug]
  local disease = self.hospital.disease_casebook[drug.disease.id]

  -- Improving effectiveness and cost should alternate
  if research_info.effect_imp > research_info.cost_imp then
    -- Time to improve cost
    disease.drug_cost = disease.drug_cost - 10
    research_info.cost_imp = research_info.cost_imp + 1
    if disease.cure_effectiveness == 100 then
      -- Did the researchers concentrate on this drug?
      if self.research_policy.specialisation.current == drug then
        self.research_policy.specialisation.current = self.drain
      end
    end
    if self.research_policy.drugs.current == drug then
      self:nextResearch("drugs")
    end
  else
    -- Time to improve effectiveness
    local improve_rate = self.level_config.gbv.DrugImproveRate
    disease.cure_effectiveness = math.min(100, 
      disease.cure_effectiveness + improve_rate)
    research_info.effect_imp = research_info.effect_imp + 1
  end
  if self.hospital == self.world.ui.hospital then
    self.world.ui.adviser:say(_S.adviser.research.drug_improved
    :format(drug.disease.name))
  end
end

--[[ Called when it is time to improve a machine's strength or cost.
!param machine The machine to improve, table taken from TheApp.objects
--]]
function ResearchDepartment:improveMachine(machine)
  local research_info = self.research_progress[machine]
  -- Improving strength and cost should alternate
  if research_info.strength_imp > research_info.cost_imp then
    -- Time to improve cost
    -- TODO: This is now 12.5%, based on observations by
    -- Mark L. Maybe add a new config option for this?
    local decrease = math.round(research_info.cost*0.125/10)*10
    research_info.cost = research_info.cost - decrease
    -- Now find rooms where this object is used and lower the build_cost for them.
    for _, room in ipairs(self.world.available_rooms) do
      for obj, no in pairs(room.objects_needed) do
        if TheApp.objects[obj] == machine then
          local progress = self.research_progress[room]
          progress.build_cost = progress.build_cost - decrease * no
          -- Each room only defines the same object once, so break
          -- from the inner loop.
          break
        end
      end
    end
    research_info.cost_imp = research_info.cost_imp + 1
    local max = self.level_config.gbv.MaxObjectStrength
    if research_info.start_strength >= max then
      if self.research_policy.specialisation.current == machine then
        self.research_policy.specialisation.current = self.drain
      end
    end
    -- No matter what, check if another machine needs improvements more urgently.
    if self.research_policy.improvements.current == machine then
      self:nextResearch("improvements")
    end
  else
    -- Time to improve strength
    local improve_rate = self.level_config.gbv.ResearchIncrement
    research_info.start_strength = research_info.start_strength
      + improve_rate
    research_info.strength_imp = research_info.strength_imp + 1
  end
  -- Tell the player that something has been improved
  if self.hospital == self.world.ui.hospital then
    self.world.ui.adviser:say(_S.adviser.research.machine_improved
    :format(machine.name))
  end
end

--[[ Called when it is time to discoer an object. This may currently only
happen from research.
!param object The object to discover, a table from TheApp.objects
!param automatic If true the discovery was not made by 
the player's research department.
--]]
function ResearchDepartment:discoverObject(object, automatic)
  self.research_progress[object].discovered = true

  -- Go through all rooms to see if another one can be made available.
  for room, _ in pairs(self.hospital.undiscovered_rooms) do
    local discovery = true
    for needed, _ in pairs(room.objects_needed) do
      if self.research_progress[TheApp.objects[needed]] 
      and not self.research_progress[TheApp.objects[needed]].discovered then
        discovery = false
        break
      end
    end
    if discovery then
      self.hospital.discovered_rooms[room] = true
      self.hospital.undiscovered_rooms[room] = nil
      if self.hospital == self.world.ui.hospital then
        if automatic then
          self.world.ui.adviser:say(_S.adviser.research.new_available
          :format(object.name))
        else
          self.world.ui.adviser:say(_S.adviser.research.new_machine_researched
          :format(object.name))
        end
      end
      -- It may now be possible to continue researching machine improvements
      if self.research_policy.improvements.current
      and self.research_policy.improvements.current.dummy
      and object.default_strength then
        self.research_policy.improvements.current = object
      end
    end
  end
  -- Now find out what to do next.
  self:nextResearch(object.research_category)
end

--[[ Called when it is time to discover a disease (i.e. after diagnosis in the GP)
!param disease The disease to discover, a table from world.available_diseases
--]]
function ResearchDepartment:discoverDisease(disease)
  -- Generate a message about the discovery
  local message = {
    {text = _S.fax.disease_discovered.discovered_name:format(disease.name)},
    {text = disease.cause, offset = 12},
    {text = disease.symptoms, offset = 12},
    {text = disease.cure, offset = 12},
    choices = {
      {text = _S.fax.disease_discovered.close_text, choice = "close"},
    },
  }
  self.world.ui.bottom_panel:queueMessage("disease", message, nil, 25*24, 1)
  self.hospital.disease_casebook[disease.id].discovered = true
  local index = #self.hospital.discovered_diseases + 1
  self.hospital.discovered_diseases[index] = disease.id
  -- If the drug casebook is open, update it.
  local window = self.world.ui:getWindow(UICasebook)
  if window then
    window:updateDiseaseList()
  end

  -- It may now be possible to continue researching drug improvements
  local casebook_disease = self.hospital.disease_casebook[disease.id]
  local current_drug_research = self.research_policy.drugs.current
  -- If we're not researching any drug right now, and the newest discovery was
  -- a disease that requires a drug, switch the current policy.
  if (not current_drug_research or current_drug_research.dummy)
  and casebook_disease.drug then
    self.research_policy.drugs.current = casebook_disease
  end
end

--[[! It also costs to research.
TODO: This is now just $3 per day and doctor (if at 100%), 
what should it be?
--]]
function ResearchDepartment:researchCost()
  local acc_cost = self.hospital.acc_research_cost
  local fraction = 0
  for _, tab in pairs(self.research_policy) do
    -- Don't pay for categories where nothing is really researched at the moment.
    if type(tab) == "table" then
      if tab.current and not tab.current.dummy then
        fraction = fraction + tab.frac
      end
    end
  end
  -- Find out how many doctors are currently doing research
  local doctors = 0
  for _, room in pairs(self.world.rooms) do
    if room.room_info.id == "research" then
      for _, _ in pairs(room.staff_member_set) do
        doctors = doctors + 1
      end
    end
  end
  acc_cost = acc_cost + math.ceil(3 * doctors * fraction/100)
  self.hospital.acc_research_cost = acc_cost
end

--[[ Concentrates research on a given disease.
Concentrating on a machine will improve it if it's been discovered
and help researching it otherwise.
Concentrating on a drug will improve the drug provided the pharmacy
is discovered. Otherwise it will research the cabinet.
TODO: Make it possible to concentrate on psychological diseases
if the psychiatry hasn't been discovered.
!param disease_id The id of the disease to focus on.
--]]
function ResearchDepartment:concentrateResearch(disease_id)
  local book_entry = self.hospital.disease_casebook[disease_id]
  -- First set flags so that the casebook shows the right thing.
  if book_entry.concentrate_research then
    -- Already concentrated, we actually just want to cancel that.
    book_entry.concentrate_research = nil
    -- Make specialisation a dummy again
    self.research_policy.specialisation.current = self.drain
  else
    for key, disease in pairs(self.hospital.disease_casebook) do
      -- Set flag on previously concentrated disease
      if disease.concentrate_research then
        self.hospital.disease_casebook[key].concentrate_research = nil
      end
    end
    -- Concentrate on the new one
    book_entry.concentrate_research = true

    -- Now, find the object related to the disease.
    -- TODO: This assumes it is the last room in the treatment_rooms list
    -- which is the one to concentrate on.
    local room
    if book_entry.disease.treatment_rooms then
      local index = #book_entry.disease.treatment_rooms
      room = book_entry.disease.treatment_rooms[index]
    else
      -- This is a pseudo-disease, it should represent a piece of diagnosis
      -- machinery that we can improve via research.
      assert(book_entry.disease.id:sub(1, 5) == "diag_", "Trying to " ..
      "concentrate research on disease without treatment rooms that " ..
      "isn't a diagnosis machine pseudodisease")
      room = book_entry.disease.id:sub(6)
    end
    local object
    -- TODO: Can these loops be improved upon?
    for obj, _ in pairs(self.world.available_rooms[room].objects_needed) do
      for research, _ in pairs(self.research_progress) do
        if research.id == obj then
          object = research
          break
        end
      end
    end
    assert(object, "An object that was about to be improved or discovered"..
    "could not be found")
    if book_entry.drug and self.research_progress[object].discovered then
      -- A drug should be improved
      self.research_policy.specialisation.current = book_entry
    else
      -- No matter if it's a drug or some machine - 
      -- we want to discover (including the cabinet) or improve it.
      self.research_policy.specialisation.current = object
    end
  end
end
