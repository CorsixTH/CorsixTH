--[[ Copyright (c) 2026 Flavio Diez

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
local TH = require("TH")
require("utility")
require("entity")
require("objects/litter")

describe("litter.lua: ", function()
  local tile_x, tile_y = 5, 7

  -- Minimal stubs
  local function make_world(tile_objects)
    return {
      entities = {},
      objects_on_tile = tile_objects or {},
      anims = {},
      map = { th = {} },
      entity_map = nil,
      getObjects = function(self, x, y) return self.objects_on_tile end,
      addObjectToTile = function(self, obj, x, y)
        self.objects_on_tile[#self.objects_on_tile + 1] = obj
      end,
      removeObjectFromTile = function(self, obj, x, y)
        for i, v in ipairs(self.objects_on_tile) do
          if v == obj then table.remove(self.objects_on_tile, i) return end
        end
      end,
      destroyEntity = function(self, obj)
        for i, v in ipairs(self.entities) do
          if v == obj then table.remove(self.entities, i) return end
        end
      end,
    }
  end

  local function make_hospital(world)
    local tasks = {}
    return {
      world = world,
      tasks = tasks,
      addHandymanTask = function(self, obj, taskType, priority, x, y)
        tasks[#tasks + 1] = {object = obj, taskType = taskType, x = x, y = y}
      end,
      getIndexOfTask = function(self, x, y, taskType, obj)
        for i, t in ipairs(tasks) do
          if t.object == obj then return i end
        end
        return -1
      end,
      removeHandymanTask = function(self, index, taskType)
        if index ~= -1 then table.remove(tasks, index) end
      end,
    }
  end

  local litter_object_type = {ticks = false, id = "litter", thob = 62,
                               count_category = "litter"}

  local function make_litter(world, hospital)
    -- bypass constructor tile registration — set fields manually
    local litter = {}
    setmetatable(litter, getmetatable(Litter(hospital, litter_object_type, nil, nil)))
    litter.th = TH.animation()
    litter.object_type = litter_object_type
    litter.hospital = hospital
    litter.world = world
    litter.tile_x = tile_x
    litter.tile_y = tile_y
    litter.animation_idx = nil
    return litter
  end

  -- helper: place existing litter on tile with a given type already set
  local function place_existing(world, hospital, litter_type)
    local existing = make_litter(world, hospital)
    world.objects_on_tile[#world.objects_on_tile + 1] = existing
    existing:setLitterType(litter_type, 0)
    return existing
  end

  -- ── isCleanable ───────────────────────────────────────────────────────────

  describe("isCleanable", function()
    it("returns true for biohazard types", function()
      local world = make_world()
      local hospital = make_hospital(world)
      for _, t in ipairs({"puke", "pee", "dead_rat"}) do
        local litter = make_litter(world, hospital)
        world.objects_on_tile = {litter}
        litter:setLitterType(t, 0)
        assert.is_true(litter:isCleanable(), t .. " should be cleanable")
      end
    end)

    it("returns true for random trash types", function()
      local world = make_world()
      local hospital = make_hospital(world)
      for _, t in ipairs({"soda_can", "banana", "paper", "bottle"}) do
        local litter = make_litter(world, hospital)
        world.objects_on_tile = {litter}
        litter:setLitterType(t, 0)
        assert.is_true(litter:isCleanable(), t .. " should be cleanable")
      end
    end)

    it("returns false for soot types", function()
      local world = make_world()
      local hospital = make_hospital(world)
      for _, t in ipairs({"soot_floor", "soot_wall", "soot_window"}) do
        local litter = make_litter(world, hospital)
        world.objects_on_tile = {litter}
        litter:setLitterType(t, 0)
        assert.is_false(litter:isCleanable(), t .. " should not be cleanable")
      end
    end)
  end)

  -- ── handyman task registration ─────────────────────────────────────────────

  describe("handyman task", function()
    it("is added for cleanable litter", function()
      local world = make_world()
      local hospital = make_hospital(world)
      local litter = make_litter(world, hospital)
      world.objects_on_tile = {litter}
      litter:setLitterType("puke", 0)
      assert.are.equal(1, #hospital.tasks)
      assert.are.equal(litter, hospital.tasks[1].object)
    end)

    it("is NOT added for soot", function()
      local world = make_world()
      local hospital = make_hospital(world)
      local litter = make_litter(world, hospital)
      world.objects_on_tile = {litter}
      litter:setLitterType("soot_floor", 0)
      assert.are.equal(0, #hospital.tasks)
    end)
  end)

  -- ── precedence: incoming higher ────────────────────────────────────────────

  describe("precedence: higher incoming displaces lower existing", function()
    it("puke displaces banana", function()
      local world = make_world()
      local hospital = make_hospital(world)
      local existing = place_existing(world, hospital, "banana")
      assert.are.equal(1, #hospital.tasks)

      local incoming = make_litter(world, hospital)
      world.objects_on_tile[#world.objects_on_tile + 1] = incoming
      incoming:setLitterType("puke", 0)

      -- existing removed, incoming placed, one task for incoming
      assert.are.equal(1, #hospital.tasks)
      assert.are.equal(incoming, hospital.tasks[1].object)
    end)

    it("pee displaces paper", function()
      local world = make_world()
      local hospital = make_hospital(world)
      local existing = place_existing(world, hospital, "paper")
      local incoming = make_litter(world, hospital)
      world.objects_on_tile[#world.objects_on_tile + 1] = incoming
      incoming:setLitterType("pee", 0)

      assert.are.equal(1, #hospital.tasks)
      assert.are.equal(incoming, hospital.tasks[1].object)
    end)

    it("dead_rat displaces soda_can", function()
      local world = make_world()
      local hospital = make_hospital(world)
      place_existing(world, hospital, "soda_can")
      local incoming = make_litter(world, hospital)
      world.objects_on_tile[#world.objects_on_tile + 1] = incoming
      incoming:setLitterType("dead_rat", 0)

      assert.are.equal(1, #hospital.tasks)
      assert.are.equal(incoming, hospital.tasks[1].object)
    end)
  end)

  -- ── precedence: incoming lower ──────────────────────────────────────────────

  describe("precedence: lower incoming is discarded", function()
    it("banana does not displace puke", function()
      local world = make_world()
      local hospital = make_hospital(world)
      local existing = place_existing(world, hospital, "puke")
      local task_count_before = #hospital.tasks

      local incoming = make_litter(world, hospital)
      world.objects_on_tile[#world.objects_on_tile + 1] = incoming
      incoming:setLitterType("banana", 0)

      -- existing task unchanged, incoming destroyed
      assert.are.equal(task_count_before, #hospital.tasks)
      assert.are.equal(existing, hospital.tasks[1].object)
    end)

    it("paper does not displace pee", function()
      local world = make_world()
      local hospital = make_hospital(world)
      local existing = place_existing(world, hospital, "pee")
      local incoming = make_litter(world, hospital)
      world.objects_on_tile[#world.objects_on_tile + 1] = incoming
      incoming:setLitterType("paper", 0)

      assert.are.equal(1, #hospital.tasks)
      assert.are.equal(existing, hospital.tasks[1].object)
    end)
  end)

  -- ── precedence: equal ───────────────────────────────────────────────────────

  describe("precedence: equal incoming is discarded", function()
    it("banana does not displace banana", function()
      local world = make_world()
      local hospital = make_hospital(world)
      local existing = place_existing(world, hospital, "banana")
      local incoming = make_litter(world, hospital)
      world.objects_on_tile[#world.objects_on_tile + 1] = incoming
      incoming:setLitterType("banana", 0)

      assert.are.equal(1, #hospital.tasks)
      assert.are.equal(existing, hospital.tasks[1].object)
    end)

    it("puke does not displace puke", function()
      local world = make_world()
      local hospital = make_hospital(world)
      local existing = place_existing(world, hospital, "puke")
      local incoming = make_litter(world, hospital)
      world.objects_on_tile[#world.objects_on_tile + 1] = incoming
      incoming:setLitterType("puke", 0)

      assert.are.equal(1, #hospital.tasks)
      assert.are.equal(existing, hospital.tasks[1].object)
    end)
  end)

  -- ── soot immunity ───────────────────────────────────────────────────────────

  describe("soot immunity", function()
    it("soot is not displaced by biohazard", function()
      local world = make_world()
      local hospital = make_hospital(world)
      local existing = make_litter(world, hospital)
      world.objects_on_tile = {existing}
      existing:setLitterType("soot_floor", 0)
      assert.are.equal(0, #hospital.tasks)  -- soot adds no task

      local incoming = make_litter(world, hospital)
      world.objects_on_tile[#world.objects_on_tile + 1] = incoming
      incoming:setLitterType("puke", 0)

      -- soot still there, incoming destroyed, still no task for puke
      assert.are.equal(0, #hospital.tasks)
    end)

    it("soot displaces existing trash", function()
      local world = make_world()
      local hospital = make_hospital(world)
      place_existing(world, hospital, "banana")
      assert.are.equal(1, #hospital.tasks)

      local soot = make_litter(world, hospital)
      world.objects_on_tile[#world.objects_on_tile + 1] = soot
      soot:setLitterType("soot_floor", 0)

      -- soot wins (99 > 1), banana removed, soot not cleanable so no task
      assert.are.equal(0, #hospital.tasks)
    end)
  end)

end)
