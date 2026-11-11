local newCosmeticRandom = require("cosmetic_random")

describe("cosmetic_random", function()
  it("is repeatable for the same seed", function()
    local a, b = newCosmeticRandom(42), newCosmeticRandom(42)
    for _ = 1, 100 do
      assert.equal(a(1, 1000), b(1, 1000))
    end
  end)

  it("matches the Park-Miller reference sequence", function()
    -- With seed 1 and multiplier 48271 the states are 48271, 182605794, ...
    local r = newCosmeticRandom(1)
    assert.equal((48271 - 1) / (2147483647 - 1), r())
    assert.equal((182605794 - 1) / (2147483647 - 1), r())
  end)

  it("follows math.random's calling conventions and bounds", function()
    local r = newCosmeticRandom(7)
    for _ = 1, 2000 do
      local u = r()
      assert.is_true(u >= 0 and u < 1)
      local m = r(6)
      assert.is_true(m >= 1 and m <= 6 and m == math.floor(m))
      local n = r(-3, 3)
      assert.is_true(n >= -3 and n <= 3 and n == math.floor(n))
    end
    assert.equal(5, r(5, 5))
  end)

  it("reaches both ends of an integer range", function()
    local r, seen = newCosmeticRandom(123), {}
    for _ = 1, 500 do seen[r(1, 4)] = true end
    assert.is_true(seen[1] and seen[2] and seen[3] and seen[4])
  end)

  it("does not touch the gameplay random stream", function()
    math.randomseed(99)
    local expected = { math.random(1, 1000), math.random(1, 1000) }
    math.randomseed(99)
    local r = newCosmeticRandom(5)
    local first = math.random(1, 1000)
    for _ = 1, 50 do r() end
    local second = math.random(1, 1000)
    assert.same(expected, { first, second })
  end)

  it("rejects an empty interval", function()
    assert.has_error(function() newCosmeticRandom(1)(3, 2) end)
  end)
end)
