require("utility")
if _VERSION ~= "Lua 5.1" then
  loadstring = load
end

describe("serialize", function()
  it("serializes a basic string", function()
    local res = serialize('hello')
    assert.equal('[[hello]]', res)
  end)

  it("serializes a string that includes ]]", function()
    local res = serialize('he]]o')
    assert.equal('[=[he]]o]=]', res)
  end)

  it("serializes an array of primitives", function()
    local res = serialize({'hello', 'happy', 'people', 'everywhere', 42, false})
    assert.equal('{[[hello]],[[happy]],[[people]],[[everywhere]],42,false}', res)
  end)

  it("serializes a pretty array", function()
    local res = serialize({'hello', 'happy', 'people', 'everywhere', 42, false}, {pretty = true})
    assert.equal([=[{
  [[hello]],
  [[happy]],
  [[people]],
  [[everywhere]],
  42,
  false
}]=], res)
  end)

  it("serializes a simple key value table", function()
    local test_tbl = {foo='bar', [true]='candy', bar=42}
    local res = serialize(test_tbl)
    local res_tbl = loadstring_envcall("return " .. res)({})
    assert.same(test_tbl, res_tbl)
  end)

  it("serializes a nested table", function()
    local test_tbl = {foo='bar', bar={hello='world'}}
    local res = serialize(test_tbl)
    local res_tbl = loadstring_envcall("return " .. res)({})
    assert.same(test_tbl, res_tbl)
  end)

  it("serializes a table with nested keys", function()
    local test_tbl = {[{hello='world'}] = true, [1] = 'tree'}
    local res = serialize(test_tbl)
    local res_tbl = loadstring_envcall("return " .. res)({})

    local found_tbl = false
    for k, _ in pairs(res_tbl) do
      if type(k) == 'table' then
        assert.same({hello='world'}, k)
        found_tbl = true
        break
      end
    end

    if not found_tbl then
      assert("table key not found")
    end

    assert.equals(test_tbl[1], res_tbl[1])
  end)

  it("respects max_depth if set", function()
    local test_tbl = {[{hello='world'}] = true, [1] = 'tree'}
    local res = serialize(test_tbl, {max_depth=1})

    assert.has.match('{...}', res, nil, true)

    res = serialize(test_tbl, {max_depth=2})
    assert.has_no.match('{...}', res, nil, true)
  end)

  it("detects cycles", function()
    local test_tbl = {[{hello='world'}] = true, [1] = 'tree'}
    test_tbl[2] = test_tbl

    local res = serialize(test_tbl, {detect_cycles=true})
    assert.has.match('<reference loop>', res, nil, true)
  end)

  it("doesn't report cycles with only max_depth", function()
    local test_tbl = {[{hello='world'}] = true, [1] = 'tree'}
    test_tbl[2] = test_tbl

    local res = serialize(test_tbl, {max_depth=4})
    assert.has_no.match('<reference loop>', res, nil, true)
    assert.has.match('{...}', res, nil, true)
  end)
end)

describe("array_join", function()
  it("joins a basic array of numbers to a comma separated string", function()
    local res = array_join({5,3,1,0})
    assert.equals("5,3,1,0", res)
  end)

  it("joins a string array with custom separator", function()
    local res = array_join({"a"," long"," hard","able"}," very")
    assert.equals("a very long very hard veryable", res)
  end)

  it("converts a non-table to a string", function()
    local res = array_join(1)
    assert.equals("1", res)
  end)
end)
