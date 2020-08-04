--[[ Copyright (c) 2020 <tbc>

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

require("entity")
require("entities.humanoid")
require("entities.humanoids.vip")

local function getVip()
  local animation = {setHitTestResult = function() end}
  return Vip(animation)
end

local function create_room(name, args)

  local room = {
    door = {queue = nil},
    room_info = {id = name},
    objects = { }, --set
    getPatient = function() return args.has_patient end
  }

  if args.alive_plants then
    for _=1,args.alive_plants do
      room.objects[{object_type = {id = "plant"}, isDying = function() return false end}] = true
    end
  end

  if args.dying_plants then
    for _=1,args.dying_plants do
      room.objects[{object_type = {id = "plant"}, isDying = function() return true end}] = true
    end
  end

  if args.working_machines then
    for _=1,args.working_machines do
      room.objects[{object_type = {id = "machine", default_strength=12}, strength=10}] = true
    end
  end

  if args.breaking_machines then
    for _=1,args.breaking_machines do
      room.objects[{object_type = {id = "machine", default_strength=12}, strength=2}] = true
    end
  end

  if args.extinguisher then
    room.objects[{object_type = {id = "extinguisher"}}] = true
  end

  if args.bin then
    room.objects[{object_type = {id = "bin"}}] = true
  end

  return room
end

describe("Vip", function()
    local vip
    local base_rating

    before_each(function()
        vip = getVip()
        -- We'll set the next room manually so stub this function
        stub(vip, "getNextRoom")

        vip.humanoid_class =  'vip'
        base_rating = vip.vip_rating
        -- Base rating range to account for randomness
        assert.True(base_rating <= 12 and base_rating >= 7)
        assert.are.equal(0, vip.room_eval)
    end)

  it("Can represent vip as a string", function()

    local result = vip:tostring()
    assert.matches(result, "humanoid[ -]*class.*vip")
    assert.matches(result, "Warmth.*Happiness.*Fatigue")
    assert.matches(result, "Actions: %[%]")
  end)

  it("Single room evaluation", function()
    vip.next_room = create_room("research",
                                {dying_plants=2,
                                 alive_plants=1,
                                 bin=true,
                                 extinguisher=true,
                                 working_machines=1})


    vip:evaluateRoom()

    -- Total rating unchanged
    assert.are.equal(base_rating, vip.vip_rating)
    -- Room eval has changed: plants -1, bin +1, extinguisher: +1
    assert.are.equal(2, vip.room_eval)

    -- Next room was fetched (not sure why though??)
    assert.stub(vip.getNextRoom).was.called_with(vip)
  end)

  it("Evaluate multiple rooms", function()

    local rooms = {
        create_room("gp", {alive_plants=3, dying_plants=1}), -- +1 to room rating
        create_room("research",{has_patient=true}),  -- +6 to vip rating (about to kill a live patient)
        create_room("ultrascan",{breaking_machines=1, bin=true}), -- no change
    }

    for _, room in pairs(rooms) do
      vip.next_room = room
      vip:evaluateRoom()
    end

    assert.are.equal(base_rating+6, vip.vip_rating)
    -- Room eval has changed: plants -1, bin +1, extinguisher: +1
    assert.are.equal(1, vip.room_eval)
    assert.stub(vip.getNextRoom).was.called(3)

  end)
end)
