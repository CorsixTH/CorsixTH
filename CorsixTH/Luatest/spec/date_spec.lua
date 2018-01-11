--[[ Copyright (c) 2018 Pavel "sofo" Schoffer

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

require("date")

describe("Date", function()
  it("can return correct month last day", function()
    assert.are.equal(Date(1, 1):lastDayOfMonth(), 31)
    assert.are.equal(Date(1, 2):lastDayOfMonth(), 28)
    assert.are.equal(Date(1, 6):lastDayOfMonth(), 30)
    assert.are.equal(Date(1, 12):lastDayOfMonth(), 31)
  end)

  it("default works", function()
    local date = Date(5, 12, 22)
    assert.are.equal(date:dayOfMonth(), 22)
    assert.are.equal(date:monthOfYear(), 12)
    assert.are.equal(date:year(), 5)

    date = Date(4, 12)
    assert.are.equal(date:dayOfMonth(), 1)
    assert.are.equal(date:monthOfYear(), 12)
    assert.are.equal(date:year(), 4)

    date = Date(24)
    assert.are.equal(date:dayOfMonth(), 1)
    assert.are.equal(date:monthOfYear(), 1)
    assert.are.equal(date:year(), 24)

    date = Date()
    assert.are.equal(date:dayOfMonth(), 1)
    assert.are.equal(date:monthOfYear(), 1)
    assert.are.equal(date:year(), 1)
  end)

  it("cannot be wrong date", function()
    local date = Date(1, 14)
    assert.are.equal(date:monthOfYear(), 2)

    date = Date(1, 24)
    assert.are.equal(date:monthOfYear(), 12)
  end)

  it("can add and read months", function()
    local date = Date():plusMonths(1)
    assert.are.equal(date:monthOfYear(), 2)

    date = Date(20, 12):plusMonths(1)
    assert.are.equal(date:monthOfYear(), 1)
  end)

  it("can handle complex adjustments", function()
    local date = Date(2,2,31)
    assert.are.equal("3/3/2", date:tostring())

    -- 31 - January, 28 - February, 7 - March
    date = Date(1,1,66)
    assert.are.equal("7/3/1", date:tostring())
  end)

  it("can print date", function()
    local date = Date(2,12,1)
    assert.are.equal("1/12/2", date:tostring())
  end)
  it("can add days", function()
    local date = Date(2,12,30)
    -- 1 - December, 29 - January
    date = date:plusDays(30)
    assert.are.equal("29/1/3", date:tostring())

    date = Date(1,3,15)
    -- 16 - March, 30 - April, 31 - June, 13 - July
    date = date:plusDays(90)
    assert.are.equal("13/6/1", date:tostring())
  end)
  it("can tell the last days", function()
    local date = Date(1,12,3)
    assert.False(date:isLastDayOfMonth())
    assert.False(date:isLastDayOfYear())

    date = Date(1,1,31)
    assert.True(date:isLastDayOfMonth())
    assert.False(date:isLastDayOfYear())

    date = Date(1,12,31)
    assert.True(date:isLastDayOfMonth())
    assert.True(date:isLastDayOfYear())
  end)
  it("get total elapsed month", function()
    local date = Date(8,11,1)
    assert.are.equals(95, date:monthOfGame())
  end)
  it("can get compared", function()
    local date1 = Date(3,2,1)
    local other_date1 = Date(3,2,1)
    local date2 = Date(1,2,3)
    assert.True(date1 == other_date1)
    assert.False(date1 == date2)
    assert.True(date1 > date2)
    assert.False(date1 < date2)
    assert.True(date1 >= other_date1)
  end)
  it("can clone itself", function()
    local origin_date = Date(12,3,2)
    local clone_date = origin_date:clone()
    assert.True(origin_date == clone_date)
  end)
end)
