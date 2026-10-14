--[[ Copyright (c) 2026 Artem Argus "ARGAMX" Gusakov

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
require("class_test_base")
require("corsixth")
require("utility")

require("humanoid_action")

-- walk.lua wraps its handlers in permanent"..."(), which the test harness stubs to
-- return an empty table (it stands in for savegame persistence, which is
-- irrelevant here). That makes the handlers non-callable, so they cannot be
-- tested at all.
--
-- Note permanent"x"(fn) is (permanent("x"))(fn): two calls, so the override has to
-- keep the harness's shape and return the wrapper, not the function.
local saved_permanent = _G.permanent
_G.permanent = function()
  return function(fn) return fn end
end
local walk_start = require("humanoid_actions.walk")
_G.permanent = saved_permanent

---Earthquake can destroys a room while patients are walking to it. (example #3566)
---
---Two crashes came out of that, both covered here.
---
---1. `Room:crashRoom` calls `Door:closeDoor`, which discards the door's queue
---   (`door.queue = nil`), and deactivates the room. A patient still walking to
---   that door reached `navigateDoor`, which dereferenced the discarded queue. The
---   symptom was `attempt to index a nil value (field 'queue')`, which names a
---   field rather than a local because the door itself still existed.
---
---2. `Entity:tick` clears `humanoid.timer_function` as soon as a timer fires, so
---   a walk which has just finished a step, or was force finished by
---   `Room:crashRoom`, has no timer pending. A high priority interrupt of such a
---   walk called the nil function.

---! A callable stub for an action class. Real ones are called as `IdleAction()`.
---! The setters are chainable, as the real ones are: navigateDoor builds a
---! QueueAction with `:setIsLeaving(...):setReserveWhenDone(...)`.
local function stubActionClass(name)
  local cls = {__action_name = name}
  setmetatable(cls, {__call = function(_, ...)
    local instance = {action_name = name, args = {...}, count = nil}
    for _, setter in ipairs({"setCount", "setIsLeaving", "setReserveWhenDone"}) do
      instance[setter] = function(self, value)
        self[setter:match("^set(%w+)$"):lower()] = value
        return self
      end
    end
    return instance
  end})
  return cls
end

describe("earthquake destroys a room mid-walk", function()
  local recorded, saved

  before_each(function()
    recorded = {timers = {}}
    saved = {
      Patient = _G.Patient, Staff = _G.Staff, Handyman = _G.Handyman,
      IdleAction = _G.IdleAction, MeanderAction = _G.MeanderAction,
      SeekRoomAction = _G.SeekRoomAction, QueueAction = _G.QueueAction,
    }
    _G.IdleAction = stubActionClass("IdleAction")
    _G.MeanderAction = stubActionClass("MeanderAction")
    _G.SeekRoomAction = stubActionClass("SeekRoomAction")
    _G.QueueAction = stubActionClass("QueueAction")
    _G.Patient = {__name = "Patient"}
    _G.Staff = {__name = "Staff"}
    _G.Handyman = {__name = "Handyman"}
    -- The live-door path past navigateDoor's guards reads these.
    _G.TheApp = _G.TheApp or {}
    saved.TheApp_objects = _G.TheApp.objects
    saved.TheApp_anim = _G.TheApp.animation_manager
    _G.TheApp.objects = {door = {id = 1}, swing_door_right = {id = 2}}
    _G.TheApp.animation_manager = {getAnimLength = function() return 10 end}
  end)

  after_each(function()
    if saved.TheApp_objects ~= nil or saved.TheApp_anim ~= nil then
      _G.TheApp.objects = saved.TheApp_objects
      _G.TheApp.animation_manager = saved.TheApp_anim
    end
    for k, v in pairs(saved) do
      if k ~= "TheApp_objects" and k ~= "TheApp_anim" then _G[k] = v end
    end
  end)

  local function makeRoom()
    return {
      room_info = {id = "x-ray"},
      crashed = true,
      is_active = false,
      canHumanoidEnter = function() return false end,
      tryAdvanceQueue = function() end,
      getPatient = function() return nil end,
    }
  end

  ---! A door whose queue Door:closeDoor has already discarded.
  local function makeDoor(room, queue)
    return {
      queue = queue,
      reserved_for = nil,
      user = nil,
      getRoom = function() return room end,
      updateDynamicInfo = function() end,
      setUser = function() end,
      removeUser = function() end,
    }
  end

  ---! Names of the actions left in a humanoid's queue.
  local function queueNames(humanoid)
    local names = {}
    for i, action in ipairs(humanoid.action_queue) do
      names[i] = action.action_name or action.name
    end
    return names
  end

  ---! A humanoid of the given class, walking east across a door tile.
  ---!
  ---! The queue methods model the real Humanoid ones closely enough to catch the
  ---! bug this spec exists for, in particular that setNextAction skips over any
  ---! action which must happen and therefore cannot replace it, and that removing
  ---! the current action is a separate call (finishAction). An earlier version of
  ---! this spec merely recorded what was handed to setNextAction, and so passed
  ---! while in game the walk stayed at the head of the queue forever.
  ---!
  ---! startAction is deliberately not modelled: these tests are about the shape
  ---! of the queue, and starting the action would need the whole action registry.
  local function makeHumanoid(opts)
    opts = opts or {}
    local humanoid = {
      name = "test-humanoid",
      tile_x = 1, tile_y = 1,
      humanoid_class = opts.as_staff and "Staff" or "Patient",
      walk_anims = {walk_east = 1, walk_north = 2, entering = 3, leaving = 4,
                    entering_swing = 5, leaving_swing = 6},
      door_anims = {entering = 3, leaving = 4, entering_swing = 5, leaving_swing = 6},
      world = {
        getObjectToNotifyOfOccupants = function() return nil end,
        getObject = function(_, _x, _y, kind)
          if opts.door and kind == "door" then return opts.door end
          return nil
        end,
        -- Enough of a path for walk_start to attach its handlers.
        getPath = function() return {1, 2}, {1, 2} end,
        -- action_walk_tick re-checks each tile for passability.
        map = {th = {getCellFlags = function() return {} end}},
        -- The interrupt handler unreserves any door the walk had claimed.
        getRoom = function() return nil end,
      },
      action_queue = {},
      getRoom = function() return opts.inside_room end,

      getCurrentAction = function(self) return self.action_queue[1] end,

      setNextAction = function(self, action, high_priority)
        local queue = self.action_queue
        local i = 1
        -- Humanoid:setNextAction steps over anything which must happen.
        while queue[i] and queue[i].must_happen do
          i = i + 1
        end
        for j = #queue, i, -1 do
          queue[j] = nil
        end
        queue[i] = action
        for j = 1, i - 1 do
          queue[j].todo_interrupt = high_priority and "high" or true
        end
      end,

      queueAction = function(self, action)
        self.action_queue[#self.action_queue + 1] = action
      end,

      finishAction = function(self, action)
        if action ~= nil then
          assert(action == self.action_queue[1], "Can only finish current action")
        end
        table.remove(self.action_queue, 1)
      end,

      setTilePositionSpeed = function() end,
      setAnimation = function() end,
      unexpectFromRoom = function() end,
      -- Records only. The tests set timer_function themselves, because that is
      -- the state the crash depends on.
      setTimer = function(_, t, f)
        recorded.timers[#recorded.timers + 1] = {time = t, fn = f}
      end,
    }
    -- A walk in progress must always happen: action_walk_start sets this, and
    -- it is why setNextAction cannot simply replace the walk.
    local walk = WalkAction(2, 1)
    walk.must_happen = true
    humanoid.action_queue[1] = walk
    setmetatable(humanoid, {__index = opts.as_staff and _G.Staff or _G.Patient})
    return humanoid
  end

  ---! Drive the exported low level walk across a tile the map calls a door,
  ---which is what delegates to navigateDoor.
  local function walkThroughDoor(humanoid)
    local map = {getCellFlags = function() return {doorWest = true} end}
    HumanoidRawWalk(humanoid, 1, 1, 2, 1, map, function() end)
  end

  ---! A walk action with walk.lua's own handlers attached, as after starting one,
  ---! together with the humanoid it is the current action of. They have to be the
  ---! same humanoid: the handlers reach the action back through
  ---! humanoid:getCurrentAction().
  local function startedWalk()
    local action = WalkAction(2, 1)
    local humanoid = makeHumanoid({})
    humanoid.action_queue = {action}
    walk_start(action, humanoid)
    -- Starting the walk schedules its own timer; drop that so the assertions
    -- below only see what the interrupt does.
    recorded.timers = {}
    return action, humanoid
  end

  describe("walking to a destroyed room", function()
    it("does not raise when the door has no queue", function()
      local room = makeRoom()
      local humanoid = makeHumanoid({door = makeDoor(room, nil)})

      assert.has_no.errors(function() walkThroughDoor(humanoid) end)
    end)

    it("drops the walk to the destroyed room", function()
      -- This is the regression that shipped broken once already: setNextAction
      -- marks a must_happen action for interruption and queues the replacement
      -- behind it, so without an explicit finishAction the walk stayed as the
      -- current action and the patient kept walking to a room that was gone.
      local room = makeRoom()
      local humanoid = makeHumanoid({door = makeDoor(room, nil)})

      walkThroughDoor(humanoid)

      -- Nothing from the old walk survives: the queue is exactly the re-route.
      assert.same({"IdleAction", "SeekRoomAction"}, queueNames(humanoid))
      for _i, name in ipairs(queueNames(humanoid)) do
        assert.are_not.equals("walk", name)
      end
    end)

    it("leaves a patient entering the room idle, then seeking another one", function()
      local room = makeRoom()
      local humanoid = makeHumanoid({door = makeDoor(room, nil)})

      walkThroughDoor(humanoid)

      -- Idle first so that the room is really gone before SeekRoom searches for
      -- a replacement, exactly as Room:crashRoom orders it.
      assert.same({"IdleAction", "SeekRoomAction"}, queueNames(humanoid))
      assert.equals(1, humanoid.action_queue[1].count)
      assert.equals("x-ray", humanoid.action_queue[2].args[1])
    end)

    it("leaves staff meandering rather than after a treatment room", function()
      local room = makeRoom()
      local humanoid = makeHumanoid({door = makeDoor(room, nil), as_staff = true})

      walkThroughDoor(humanoid)

      assert.same({"MeanderAction"}, queueNames(humanoid))
    end)

    it("still uses a live door's queue instead of re-routing", function()
      -- So that the destroyed-room path is not a catch-all masking some unrelated
      -- breakage. The door here still has its queue and is in use by somebody
      -- else, which is the branch that reads door.queue and queues the waiter.
      local room = makeRoom()
      local unexpected, sizes = 0, 0
      local queue = {
        unexpect = function() unexpected = unexpected + 1 end,
        size = function() sizes = sizes + 1; return 1 end,
        expectedSize = function() return 1 end,
      }
      local door = makeDoor(room, queue)
      door.user = {name = "someone-else"}
      local humanoid = makeHumanoid({door = door})

      assert.has_no.errors(function() walkThroughDoor(humanoid) end)

      -- The live door's own bookkeeping still runs.
      assert.equals(1, unexpected)
      assert.is_true(sizes > 0)
      -- And the walk is left alone, because the room was not destroyed.
      assert.same({"walk", "QueueAction"}, queueNames(humanoid))
    end)
  end)

  describe("high priority interrupt of a walk with no timer pending", function()
    it("does not call a nil timer function", function()
      local action, humanoid = startedWalk()
      humanoid.timer_function = nil

      assert.has_no.errors(function()
        action.on_interrupt(action, humanoid, true)
      end)
    end)

    it("still runs the pending timer when there is one", function()
      local ran = 0
      local action, humanoid = startedWalk()
      humanoid.timer_function = function() ran = ran + 1 end

      action.on_interrupt(action, humanoid, true)

      assert.equals(1, ran)
    end)

    it("clears the timer whether or not there was one", function()
      local action, humanoid = startedWalk()
      humanoid.timer_function = nil

      action.on_interrupt(action, humanoid, true)

      assert.is_true(#recorded.timers > 0)
      assert.is_nil(recorded.timers[1].time)
    end)

    it("attaches the interrupt handler when the action is started", function()
      -- Guards the fixture itself: without walk_start, on_interrupt is nil and the
      -- tests above would pass for the wrong reason.
      local action = startedWalk()
      assert.equals("function", type(action.on_interrupt))
    end)
  end)
end)
