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
    local date = Date(5, 12, 22, 5)
    assert.are.equal(date:hourOfDay(), 5)
    assert.are.equal(date:dayOfMonth(), 22)
    assert.are.equal(date:monthOfYear(), 12)
    assert.are.equal(date:year(), 5)

    date = Date(5, 12, 22)
    assert.are.equal(date:hourOfDay(), 0)
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

  it("can handle hour adjustmentse", function()
    local date = Date(1, 1, 5, 50)
    assert.are.equal(6, date:dayOfMonth())
    assert.are.equal(0, date:hourOfDay())

    date = Date(1, 1, 1, 55)
    assert.are.equal(2, date:dayOfMonth())
    assert.are.equal(5, date:hourOfDay())
  end)

  it("can add and read months", function()
    local date = Date():plusMonths(1)
    assert.are.equal(date:monthOfYear(), 2)

    date = Date(20, 12):plusMonths(1)
    assert.are.equal(date:monthOfYear(), 1)
  end)

  it("can handle complex adjustments", function()
    local date = Date(2,2,31,55)
    assert.are.equal("2-03-04T05", date:tostring())

    date = Date(1,12,31,55)
    assert.are.equal("2-01-01T05", date:tostring())

    -- 31 - January, 28 - February, 7 - March
    date = Date(1,1,66)
    assert.are.equal("1-03-07T00", date:tostring())
  end)

  it("can print date", function()
    local date = Date(2,12,1,6)
    assert.are.equal("2-12-01T06", date:tostring())
  end)
  it("can add days", function()
    local date = Date(2,12,30)
    -- 1 - December, 29 - January
    date = date:plusDays(30)
    assert.are.equal("3-01-29T00", date:tostring())

    date = Date(1,3,15)
    -- 16 - March, 30 - April, 31 - June, 13 - July
    date = date:plusDays(90)
    assert.are.equal("1-06-13T00", date:tostring())
  end)
  it("can add years", function()
    local date = Date(3, 2, 1, 6)
    local expected_date = Date(8, 2, 1, 6)

    local adjusted_date = date:plusYears(5)
    assert.True(expected_date == adjusted_date)
  end)
  it("can add hours", function()
    local date = Date(1,1,1,5)

    local adjusted_date = date:plusHours(50)
    assert.are.equals(2, adjusted_date:dayOfMonth())
    assert.are.equals(5, adjusted_date:hourOfDay())
  end)
  it("can add negative hours", function()
    local date = Date(3,1,1,0)
    local expected_date = Date(2,12,31,49)

    local adjusted_date = date:plusHours(-1)
    assert.True(expected_date == adjusted_date)
  end)
  it("can add negative days", function()
    local date = Date(3,1,1)
    local adjusted_date = date:plusDays(-40)
    local expected_date = Date(2,11,22)

    assert.True(expected_date == adjusted_date)
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
    local date_with_different_hour = Date(3,2,1,40)
    assert.True(date1 == other_date1)
    assert.False(date1 == date2)
    assert.True(date1 > date2)
    assert.False(date1 < date2)
    assert.False(date1 < other_date1)
    assert.True(date1 <= other_date1)
    assert.False(date1 <= date2)
    assert.True(date1 >= other_date1)
    assert.False(date_with_different_hour == date1)
    assert.True(date_with_different_hour > date1)
  end)
  it("can clone itself", function()
    local origin_date = Date(12,3,2,6)
    local clone_date = origin_date:clone()
    assert.True(origin_date == clone_date)
  end)
  it("can provide hours per day", function()
    assert.equals(50, Date.hoursPerDay())
  end)
  it("can check if two days are the same", function()
    assert.True(Date(1,2,3,5):isSameDay(Date(1,2,3,9)))
    assert.False(Date(1,2,3):isSameDay(Date(1,4,3)))
  end)
end)
