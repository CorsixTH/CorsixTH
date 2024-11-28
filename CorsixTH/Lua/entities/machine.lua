--[[ Copyright (c) 2009 Edvin "Lego3" Linge

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

local TH = require("TH")

--! An `Object` which needs occasional repair (to prevent explosion).
class "Machine" (Object)

---@type Machine
local Machine = _G["Machine"]

function Machine:Machine(hospital, object_type, x, y, direction, etc)
  self.total_usage = -1 -- Incremented in the constructor of Object.
  self:Object(hospital, object_type, x, y, direction, etc)

  if object_type.default_strength then
    -- Only for the main object. The slave doesn't need any strength
    local progress = self.hospital.research.research_progress[object_type]
    self.strength = progress.start_strength
  end

  -- We actually don't want any dynamic info just yet
  self:clearDynamicInfo()
  -- Change hover cursor once the room has been finished.
  self.waiting_for_finalize = true -- Waiting until the room is completed (reset by new-room callback).

  self:setHandymanRepairPosition(direction)
end

function Machine:notifyNewRoom(room)
  if self.waiting_for_finalize and room.objects[self] then
    self:finalize(room)
    self.waiting_for_finalize = false
  end
end

function Machine:setCrashedAnimation()
  self:setAnimation(self.object_type.crashed_animation)
end

--! Calculates the number of times the machine can be used before crashing (unless repaired first)
function Machine:getRemainingUses()
  return self.strength - self.times_used
end

--! Returns true if a machine is smoking/needs repair
function Machine:isBreaking()
  local threshold = self:getRemainingUses()
  return threshold < 4
end

--! Set whether the smoke animation should be showing
local function setSmoke(self, isSmoking)
  -- If turning smoke on for this machine
  if isSmoking then
    -- If there is no smoke animation for this machine, make one
    if not self.smokeInfo then
      self.smokeInfo = TH.animation()
      -- Note: Set the location of the smoke to that of the machine
      -- rather than setting the machine to the parent so that the smoke
      -- doesn't get hidden with the machine during use
      self.smokeInfo:setTile(self.th:getTile())
      -- Always show the first smoke layer
      self.smokeInfo:setLayer(10, 2)
      -- tick to animate over all frames
      self.ticks = true
    end
    -- TODO: select the smoke icon based on the type of machine
    self.smokeInfo:setAnimation(self.world.anims, 3424)
  else -- Otherwise, turning smoke off
    -- If there is currently a smoke animation, remove it
    if self.smokeInfo then
      self.smokeInfo:setTile(nil)
    end
    self.smokeInfo = nil
  end
end

--! Call on machine use. Handles crashing the machine & queueing repairs
function Machine:machineUsed(room)
  -- Do nothing if the room has already crashed
  if room.crashed then
    return
  end
  -- Update dynamic info (strength & times used)
  self:updateDynamicInfo()
  -- How many uses this machine has left until it explodes
  local threshold = self:getRemainingUses()
  -- Find a queued task for a handyman coming to repair this machine
  local taskIndex = self.hospital:getIndexOfTask(self.tile_x, self.tile_y, "repairing")
  local num_extinguishers = 0
  local explosion_chance
  local explode = false
  -- Room is set to explode
  if threshold < 1 then
    -- If a fire extinguisher in the room, room has chance not to explode
    for object, _ in pairs(room.objects) do
      if object.object_type.id == "extinguisher" and num_extinguishers < 4 then
        num_extinguishers = num_extinguishers + 1
      end
    end
    if num_extinguishers == 0 or threshold < -3 then
      -- If no extinguisher in room, or machine used 5 times over its strength always explode
      explode = true
    else
      -- Explosion chance increases 20% with every use over strength, and reduced by 5% for every additional extinguisher (up to 3 extra) in the room bar the first one
      explosion_chance = (2 / self.strength) + (threshold * -0.2) - (num_extinguishers * 0.05) + 0.05
      -- Cap it until guaranteed explosion
      explosion_chance = explosion_chance > 0.95 and 0.95 or explosion_chance
      explosion_chance = explosion_chance < 0.05 and 0.05 or explosion_chance
      explode = math.random() < explosion_chance
    end
  end
  -- Room failed to be saved, or no extinguishers were present
  if explode then
    -- Clean up any task of handyman coming to repair the machine
    self.hospital:removeHandymanTask(taskIndex, "repairing")
    -- Blow up the room
    room:crashRoom()
    self:setCrashedAnimation()
    -- No special cursor required when hovering over the crashed room
    self.hover_cursor = nil
    -- Clear dynamic info (tracks machine usage which is no longer required)
    self:clearDynamicInfo()
    -- Prevent the machine from smoking, it's now just a pile of rubble
    setSmoke(self, false)
    -- If we have the window for this machine open, close it
    local window = self.world.ui:getWindow(UIMachine)
    if window and window.machine == self then
      window:close()
    end
    -- Clear the icon showing a handyman is coming to repair the machine
    self:setRepairing(nil)
    return true
  -- Else if urgent repair needed or room didn't explode
  elseif threshold < 4 then
    -- If the job of repairing the machine isn't queued, queue it now (higher priority)
    if taskIndex == -1 then
      local call = self.world.dispatcher:callForRepair(self, true, false, true)
      self.hospital:addHandymanTask(self, "repairing", 2, self.tile_x, self.tile_y, call)
      self.hospital:announceRepair(room)
    else -- Otherwise the task is already queued. Increase the priority to above that of machines with at least 4 uses left
       -- Upgrades task from low (1) priority to high (2) priority
       -- This does not lock the room, as happens when the task call starts at high priority
      if self.hospital:getHandymanTaskPriority(taskIndex, "repairing") == 1 then
        self.hospital:modifyHandymanTaskPriority(taskIndex, 2, "repairing")
        self.hospital:announceRepair(room)
      end
    end
  -- Else if repair is needed, but not urgently
  elseif threshold < 6 then
    -- If the job of repairing the machine isn't queued, queue it now (low priority)
    if taskIndex == -1 then
      local call = self.world.dispatcher:callForRepair(self)
      self.hospital:addHandymanTask(self, "repairing", 1, self.tile_x, self.tile_y, call)
    end
  end

  -- Update whether smoke gets displayed for this machine (and if so, how much)
  self:calculateSmoke(room)
end

--! Calculates whether smoke gets displayed for this machine (and if so, how much)
function Machine:calculateSmoke(room)
  -- Do nothing if the room has already crashed
  if room.crashed then
    return
  end

  -- How many uses this machine has left until it explodes
  local threshold = self:getRemainingUses()

  -- Machines needing urgent repair show smoke
  if threshold < 4 then
    -- Display smoke, up to three animations per machine
    -- i.e. < 4 one plume, < 3 two plumes or < 2 three plumes of smoke
    setSmoke(self, true)
    -- turn on additional layers of the animation for extra smoke plumes, depending on how damaged the machine is
    if threshold < 3 then
      self.smokeInfo:setLayer(11, 2)
    end
    if threshold < 2 then
      self.smokeInfo:setLayer(12, 2)
    end
  end
end

function Machine:getRepairTile()
  local x = self.tile_x + self.handyman_position[1]
  local y = self.tile_y + self.handyman_position[2]
  return x, y
end

function Machine:createHandymanActions(handyman)
  local ux, uy = self:getRepairTile()
  local this_room = self:getRoom()
  local handyman_room = handyman:getRoom()
  assert(this_room, "machine should always in a room")

  self.repairing = handyman
  self:setRepairingMode()

  local --[[persistable:handyman_repair_after_use]] function repair_after_use()
    handyman:setCallCompleted()
    handyman:setDynamicInfoText("")
    self:machineRepaired(self:getRoom())
  end

  local action = WalkAction(ux, uy):setIsEntering(this_room and true or false)

  local repair_action = UseObjectAction(self):setProlongedUsage(false)
      :setAfterUse(repair_after_use)
  repair_action.min_length = 20

  if handyman_room and handyman_room ~= this_room then
    handyman:setNextAction(handyman_room:createLeaveAction())
    handyman:queueAction(action)
  else
    handyman:setNextAction(action)
  end

  local meander_loop_callback = --[[persistable:handyman_meander_repair_loop_callback]] function()
    -- Wait until the machine is not in use and not about to be used
    local patient = self:getRoom():getPatient()
    if not self.user and (not patient or patient:isLeaving()) then
      -- The machine is ready to be repaired.
      -- The following statement will finish the meander action in the handyman's
      -- action queue.
      handyman:finishAction()
    end
    -- Otherwise do nothing and let the meandering continue.
  end

  -- Before the actual repair action, insert a meander action to wait for the machine
  -- to become free for use.
  handyman:queueAction(MeanderAction():setLoopCallback(meander_loop_callback))

  -- The last one is another walk action to the repair tile. If the handyman goes directly
  -- to repair it will simply complete in an instant.
  handyman:queueAction(action)
  handyman:queueAction(repair_action)
  CallsDispatcher.queueCallCheckpointAction(handyman)
  handyman:queueAction(AnswerCallAction())
  handyman:setDynamicInfoText(_S.dynamic_info.staff.actions.going_to_repair
    :format(self.object_type.name))
end

--! Replace this machine (make it pretend it's brand new)
--!param cost (int) Cost to replace the machine
function Machine:replaceMachine(cost)
  -- Pay for the new machine
  self.hospital:spendMoney(cost, _S.transactions.machine_replacement)

  -- Reset usage stats
  self.total_usage = 0
  self.times_used = 0

  -- Update strength to match the current level of research for it
  self.strength = self.hospital.research.research_progress[self.object_type].start_strength

  -- Remove any queued repair jobs
  local index = self.hospital:getIndexOfTask(self.tile_x, self.tile_y, "repairing")
  if index ~= -1 then
    self.hospital:removeHandymanTask(index, "repairing")
  end

  -- Clear icon showing handyman is coming to repair the machine
  self:setRepairing(nil)
  -- Clear smoke
  setSmoke(self, false)
end

function Machine:machineRepaired(room)
  room.needs_repair = nil
  self:reduceStrengthOnRepair(room)
  self.times_used = 0
  self:setRepairing(nil)
  setSmoke(self, false)
  local taskIndex = self.hospital:getIndexOfTask(self.tile_x, self.tile_y, "repairing")
  self.hospital:removeHandymanTask(taskIndex, "repairing")
end

--! Calculates if machine strength should be reduced as a result of repair
--!param room (object) machine room
function Machine:reduceStrengthOnRepair(room)
  local minimum_possible_strength = 2
  if self.strength <= minimum_possible_strength then return end

  local current_strength = self.strength
  local used_out_rate = self.times_used / current_strength

  -- calculate chance of strength reducing
  local should_reduce_strength = math.random() < used_out_rate
  if should_reduce_strength then
    self.strength = current_strength - 1
  end
end

--! Tells the machine to start showing the icon that it needs repair.
--!   also lock the room from patient entering
--!param handyman The handyman heading to this machine. nil if repairing is finished
function Machine:setRepairing(handyman)
  -- If mode is set to true manually through the dialog, boost the urgency despite of the strength
  local anim = {icon = 4564} -- The only icon for machinery
  local room = self:getRoom()
  self:setMoodInfo(handyman and anim or nil)
  room.needs_repair = handyman
  if handyman then
    self.ticks = true
  else
    self.ticks = self.object_type.ticks
    self.world.dispatcher:dropFromQueue(self)
    if not room.crashed then
      self:updateDynamicInfo(true)
      self:getRoom():tryAdvanceQueue()
    end
  end
end

function Machine:setRepairingMode(lock_room)
  if lock_room ~= nil then
    self.repairing_lock_room = lock_room
  end
  if self.repairing and self.repairing_lock_room then
    self:setRepairing(self.repairing)
  end
end

function Machine.slaveMixinClass(class_method_table)
  local slave_to_master, master_to_slave = Object.slaveMixinClass(class_method_table)
  master_to_slave("finalize")
  master_to_slave("setCrashedAnimation")
  slave_to_master("createRepairAction")
  slave_to_master("getRepairTile")
  return slave_to_master, master_to_slave
end

-- Currently used to make the hover cursor of the machine be special
-- only if the room is active at the moment (e.g. not being edited)
function Machine:finalize(room)
  if room.is_active then
    self.hover_cursor = TheApp.gfx:loadMainCursor("repair")
    self:updateDynamicInfo(true)
  else
    self:clearDynamicInfo()
    self.hover_cursor = nil
  end
end

function Machine:updateDynamicInfo(only_update)
  if not only_update then
    self.times_used = self.times_used + 1
    self.total_usage = self.total_usage + 1
  end
  if self.strength then
    if self.world.ui.app.config.new_machine_extra_info then
      local hosp = self.world:getLocalPlayerHospital()
      self:setDynamicInfo("text", {
        self.object_type.name,
        _S.dynamic_info.object.strength_extra_info:format(self.strength, hosp.research.research_progress[self.object_type].start_strength),
        _S.dynamic_info.object.times_used:format(self.times_used),
      })
    else
      self:setDynamicInfo("text", {
        self.object_type.name,
        _S.dynamic_info.object.strength:format(self.strength),
        _S.dynamic_info.object.times_used:format(self.times_used),
      })
    end
  end
end

function Machine:onClick(ui, button)
  local room = self:getRoom()
  if button == "left" and room.is_active then
    -- If the room is crashed is_active is false.
    ui:addWindow(UIMachine(ui, self, room))
  else
    Object.onClick(self, ui, button)
  end
end

function Machine:onDestroy()
  local room = self:getRoom()
  if room then
    room.needs_repair = nil
  end
  local index = self.hospital:getIndexOfTask(self.tile_x, self.tile_y, "repairing")
  if index ~= -1 then
    self.hospital:removeHandymanTask(index, "repairing")
  end

  -- Stop this machine from smoking
  setSmoke(self, false)

  Object.onDestroy(self)
end

function Machine:afterLoad(old, new)
  if old < 15 then
    if self.object_type.id == "cardio" then
      -- Fix THOB value being wrong
      self.world.map.th:setCellFlags(self.tile_x, self.tile_y, {
        thob = self.object_type.thob
      })
    end
  end
  if old < 54 then
    local room = self:getRoom()
    if room.crashed then
      local taskIndex = room.hospital:getIndexOfTask(self.tile_x, self.tile_y, "repairing")
      room.hospital:removeHandymanTask(taskIndex, "repairing")
    end
  end
  self:updateDynamicInfo(true)
  return Object.afterLoad(self, old, new)
end

function Machine:tick()
  -- Tick any smoke animation
  if self.smokeInfo then
    self.smokeInfo:tick()
  end

  return Object.tick(self)
end

--[[ Gets the state of a machine

! In addition to the object implementation this includes total_usage
!return (table) state
]]
function Machine:getState()
  local state = Object.getState(self)
  state.total_usage = self.total_usage
  state.strength = self.strength
  return state
end

--[[ Sets the state of a machine

! Adds total_usage
!param state (table) table holding the state
!return (void)
]]
function Machine:setState(state)
  Object.setState(self, state)
  if state then
    self.total_usage = state.total_usage
    self.strength = state.strength
  end
end

--[[ Sets the handyman use position of a machine

! Calculate handyman use position based on object orientation
! or the normal use position if one not available
!param direction (string) orientation of object
!return (void)
]]
function Machine:setHandymanRepairPosition(direction)
  local orientation = self.object_type.orientations[direction]
  local handyman_position = orientation.handyman_position
  if handyman_position then
  -- If there are many possible handyman tiles, choose one that is accessible from the use_position.
    if type(handyman_position[1]) == "table" then
      for _, position in ipairs(handyman_position) do
        local hx, hy = self.tile_x + position[1], self.tile_y + position[2]
        local ux, uy = self.tile_x + orientation.use_position[1], self.tile_y + orientation.use_position[2]
        if self.world.pathfinder:findDistance(hx, hy, ux, uy) then
          -- Also make sure the tile is not in another room or in the corridor.
          local room = self.world:getRoom(hx, hy)
          if room and room == self:getRoom() then
            self.handyman_position = {position[1], position[2]}
            break
          end
        end
      end
    else
      self.handyman_position = {handyman_position[1], handyman_position[2]}
    end
  else
    self.handyman_position = {orientation.use_position[1], orientation.use_position[2]}
  end
end

-- Dummy callbacks for savegame compatibility
local callbackNewRoom = --[[persistable:machine_build_callback]] function() end
local repair_loop_callback = --[[persistable:handyman_repair_loop_callback]] function() end
