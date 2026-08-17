--[[ CorsixTH smoke test for the #1467 deferred-destroy fix. Invoked via:
  corsix-th --interpreter=/home/bruno/CorsixTH/smoketest.lua
--]]
local base_dir = "/home/bruno/CorsixTH/CorsixTH/"

assert(loadfile(base_dir .. "CorsixTH.lua"))()

local render = os.getenv("SMOKE_RENDER") == "1"
local load_only = os.getenv("SMOKE_LOAD_ONLY") == "1"
local heartbeat = os.getenv("SMOKE_HEARTBEAT") == "1"

local function fail(msg)
  print("SMOKE FAIL: " .. msg)
  io.stdout:flush()
  os.exit(1)
end

local function hb(phase, extra)
  if not heartbeat then return end
  local world = TheApp.world
  local entities_alive = world and #world.entities or 0
  local queue_len = (world and world.entities_to_destroy) and #world.entities_to_destroy or 0
  local to_destroy_flags = 0
  if world then
    for _, e in ipairs(world.entities) do
      if e.to_destroy then to_destroy_flags = to_destroy_flags + 1 end
    end
  end
  local mem_kb = collectgarbage("count")
  local tick = world and world.tick_count or 0
  local data = string.format('{"phase":"%s","tick":%d,"entities_alive":%d,"to_destroy_flags":%d,"queue_len":%d,"mem_kb":%.1f}',
    phase, tick, entities_alive, to_destroy_flags, queue_len, mem_kb)
  if extra then
    for k, v in pairs(extra) do
      data = data:gsub('}$', ',"'..k..'":'..v..'}')
    end
  end
  io.stderr:write(data .. "\n")
  io.stderr:flush()
end

local is_demo = TheApp.using_demo_files or false
local difficulty = is_demo and "easy" or "full"
print("SMOKE: using_demo_files=" .. tostring(is_demo) .. ", difficulty=" .. difficulty)
io.stdout:flush()

local ok, err = pcall(TheApp.loadLevel, TheApp, 1, difficulty, nil, nil, nil, nil,
    "SMOKE: ", nil)
print("SMOKE: loadLevel returned ok=" .. tostring(ok) .. ", err=" .. tostring(err))
io.stdout:flush()
if not ok then fail("loadLevel errored: " .. tostring(err)) end
if err == false then fail("loadLevel failed (returned false)") end
print("SMOKE: TheApp.world = " .. tostring(TheApp.world))
io.stdout:flush()

-- Stop any playing movie (intro movie blocks World:onTick)
if TheApp.moviePlayer and TheApp.moviePlayer.playing then
  print("SMOKE: Stopping intro movie...")
  TheApp.moviePlayer:stop()
  print("SMOKE: moviePlayer.playing = " .. tostring(TheApp.moviePlayer.playing))
  io.stdout:flush()
end

local world = TheApp.world
if not world then fail("TheApp.world is nil after loadLevel") end
local hospital = world:getLocalPlayerHospital()
if not hospital then fail("no local player hospital after loadLevel") end
print("SMOKE: level loaded, entities=" .. #world.entities)
io.stdout:flush()
hb("load_complete", {load_ms = TheApp.load_ms or 0})

if load_only then
  print("SMOKE: LOAD_ONLY mode - exiting after load")
  io.stdout:flush()
  os.exit(0)
end

TheApp.config.autosave_frequency = 0

local function addStaff(class_name)
  local profile = StaffProfile(world, class_name, _S.staff_class[class_name:lower()])
  if class_name == "Doctor" then
    profile:initDoctor(0, 0, 0, 1, 0, 0)
  else
    profile:init(0)
  end
  local staff = world:newEntity(profile.humanoid_class, 2, 2)
  staff:setProfile(profile)
  local map = world.map.th
  local map_x_length, map_y_length = map:size()
  local x, y = map:getCameraTile(hospital:getPlayerIndex())
  local map_offset = 10
  local x_safe = math.max(map_offset + 1, math.min(x, map_x_length - map_offset))
  local y_safe = math.max(map_offset + 1, math.min(y, map_y_length - map_offset))
  local x_attempt, y_attempt, attempts = x_safe, y_safe, 0
  repeat
    x_attempt = x_safe + math.random(-map_offset, map_offset)
    y_attempt = y_safe + math.random(-map_offset, map_offset)
    attempts = attempts + 1
  until attempts > 100 or hospital:isInHospital(x_attempt, y_attempt)
  if attempts <= 100 then
    staff:setTile(x_attempt, y_attempt)
  else
    staff:setTile(map_x_length / 2, map_y_length / 2)
  end
  hospital.staff[#hospital.staff + 1] = staff
  staff:setHospital(hospital)
  staff:onPlaceInCorridor()
  return staff
end

addStaff("Receptionist")
addStaff("Doctor")
print("SMOKE: added receptionist and doctor, entities=" .. #world.entities)
io.stdout:flush()
hb("staff_added")
hospital:open()

local function spawnRealPatient()
  local spawns = world.spawn_points
  if #spawns == 0 then return nil end
  local spawn = spawns[math.random(1, #spawns)]
  local patient = world:newEntity("Patient", 2, 1)
  patient:setDisease(world.available_diseases[math.random(1, #world.available_diseases)])
  patient:setNextAction(SpawnAction("spawn", spawn))
  patient:setHospital(hospital)
  return patient
end

local peak_entities = #world.entities
local rendered_frames = 0
local function frame()
  if render then
    local okf, errf = pcall(TheApp.drawFrame, TheApp)
    if not okf then fail("drawFrame error: " .. tostring(errf)) end
    rendered_frames = rendered_frames + 1
  end
end
if render then
  local rd = TheApp.video:getRendererDetails()
  print("SMOKE: renderer=" .. tostring(rd))
  io.stdout:flush()
end
local function runTicks(n, label, patient_every)
  for i = 1, n do
    local ok2, err2 = pcall(TheApp.onTick, TheApp)
    if not ok2 then
      fail(label .. " onTick error at step " .. i .. ": " .. tostring(err2))
    end
    frame()
    if patient_every and i % patient_every == 0 then
      spawnRealPatient()
    end
    peak_entities = math.max(peak_entities, #world.entities)
    if heartbeat and i % 100 == 0 then
      hb(label, {tick_in_phase = i})
    end
  end
  print("SMOKE: " .. label .. " ran " .. n .. " ticks, entities=" .. #world.entities
    .. " (peak " .. peak_entities .. ")")
  io.stdout:flush()
  hb(label .. "_complete")
end

runTicks(700, "warmup-with-patients", 25)
if render then
  print("SMOKE: rendered_frames_after_warmup=" .. rendered_frames)
  io.stdout:flush()
end

local save_path = TheApp.savegame_dir .. "smoketest.sav"
TheApp:save(save_path)
if not lfs.attributes(save_path) then fail("could not save game") end
print("SMOKE: saved to " .. save_path)
io.stdout:flush()
hb("save_complete")
local ok3, err3 = pcall(TheApp.load, TheApp, save_path)
if not ok3 then fail("load savegame errored: " .. tostring(err3)) end
world = TheApp.world
hospital = world:getLocalPlayerHospital()
print("SMOKE: loaded savegame, entities=" .. #world.entities
  .. " queue=" .. tostring(world.entities_to_destroy and #world.entities_to_destroy))
io.stdout:flush()
hb("load_save_complete")

class "SmokeDummy" (Entity)
function SmokeDummy:SmokeDummy(animation)
  self:Entity(animation)
  self.dummy_mode = "none"
  self.a_ticked = false
  self.was_ticked = false
end
function SmokeDummy:onDestroy()
  self.destroyed = true
end
function SmokeDummy:tick()
  if self.dummy_mode == "a" then
    self.a_ticked = true
  elseif self.dummy_mode == "b" then
    self.world:destroyEntity(self.target)
  elseif self.dummy_mode == "c" then
    self.was_ticked = true
  elseif self.dummy_mode == "d" then
    self.world:destroyEntity(self)
  end
end

local dummy_a = world:newEntity("SmokeDummy", 2, 1)
local dummy_b = world:newEntity("SmokeDummy", 2, 1)
local dummy_c = world:newEntity("SmokeDummy", 2, 1)
dummy_a.dummy_mode = "a"
dummy_b.dummy_mode = "b"
dummy_c.dummy_mode = "c"
dummy_b.target = dummy_a
dummy_c.was_ticked = false

local idx_a, idx_b, idx_c
for i, e in ipairs(world.entities) do
  if e == dummy_a then idx_a = i end
  if e == dummy_b then idx_b = i end
  if e == dummy_c then idx_c = i end
end
print("SMOKE: dummy indexes a=" .. idx_a .. " b=" .. idx_b .. " c=" .. idx_c)
io.stdout:flush()
if idx_b ~= idx_a + 1 or idx_c ~= idx_b + 1 then
  fail("dummies not consecutive at the end of entities")
end

local passes = 0
local cap = (world.tick_rate or 4) + 2
while not dummy_a.a_ticked and passes < cap do
  local ok2, err2 = pcall(TheApp.onTick, TheApp)
  if not ok2 then fail("skip-bug-repro onTick error: " .. tostring(err2)) end
  frame()
  passes = passes + 1
end
print("SMOKE: skip-bug-repro ran " .. passes .. " onTick calls (tick_rate=" .. tostring(world.tick_rate) .. ")")
io.stdout:flush()
if not dummy_a.a_ticked then fail("dummy A never ticked") end
if not dummy_c.was_ticked then fail("dummy C was skipped (the #1467 bug)") end
for _, e in ipairs(world.entities) do
  if e == dummy_a then fail("dummy A not removed after tick") end
end
print("SMOKE: mid-loop destroy of earlier entity worked, no entity was skipped")
io.stdout:flush()
hb("skip_bug_repro_complete")

local dummy_d = world:newEntity("SmokeDummy", 2, 1)
dummy_d.dummy_mode = "d"
local passes_d = 0
local cap_d = (world.tick_rate or 4) + 2
while not dummy_d.destroyed and passes_d < cap_d do
  local okd, errd = pcall(TheApp.onTick, TheApp)
  if not okd then fail("self-destroy onTick error: " .. tostring(errd)) end
  frame()
  passes_d = passes_d + 1
end
print("SMOKE: self-destroy ran " .. passes_d .. " onTick calls")
io.stdout:flush()
if not dummy_d.destroyed then fail("dummy D was not destroyed") end
for _, e in ipairs(world.entities) do
  if e == dummy_d then fail("dummy D not removed after self-destroy") end
end
print("SMOKE: self-destroy during own tick worked")
io.stdout:flush()
hb("self_destroy_complete")

runTicks(200, "after-dummy-destroy")

local stale = 0
for _, e in ipairs(world.entities) do
  if e.to_destroy then stale = stale + 1 end
end
local queue = world.entities_to_destroy and #world.entities_to_destroy or "n/a"
print("SMOKE: stale to_destroy flags=" .. stale)
print("SMOKE: entities_to_destroy queue=" .. tostring(queue))
io.stdout:flush()
if stale ~= 0 then fail("found " .. stale .. " stale to_destroy flags") end
if queue ~= 0 then fail("entities_to_destroy queue not empty after ticks") end

world.entities_to_destroy = nil
runTicks(60, "old-save-sim (nil queue)")
local q2 = world.entities_to_destroy
if not q2 then fail("entities_to_destroy not lazily recreated") end
print("SMOKE: old-save simulation OK, queue=" .. #q2)
io.stdout:flush()
local stale2 = 0
for _, e in ipairs(world.entities) do
  if e.to_destroy then stale2 = stale2 + 1 end
end
if stale2 ~= 0 then fail("stale to_destroy flags after old-save sim") end
if render then
  print("SMOKE: total_rendered_frames=" .. rendered_frames)
  io.stdout:flush()
end
print("SMOKE: ALL CHECKS PASSED")
io.stdout:flush()
hb("all_passed")
os.exit(0)
