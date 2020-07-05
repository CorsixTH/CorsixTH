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

--[[
  Date class is meant to encapsulate logic around months, years, days, hours.
  It should be able to do adjustments with regards to days in given month and so on.

  Date objects should be immutable and that is why date adjustments return new objects
  instead of modifying the current one.
]]

class "Date"

---@type Date
local Date = _G["Date"]

local month_length = {
  31, -- Jan
  28, -- Feb (29 in leap years, but TH doesn't have leap years)
  31, -- Mar
  30, -- Apr
  31, -- May
  30, -- Jun
  31, -- Jul
  31, -- Aug
  30, -- Sep
  31, -- Oct
  30, -- Nov
  31, -- Dec
}

local hours_per_day = 50

-- STATIC

--[[ Method returns the number of game hours in one day

! This should be use everywhere we query this information

!return (number) number of hours in a day.
]]
function Date.hoursPerDay()
  return hours_per_day
end

-- PUBLIC

--[[ Date constructor

! Date is initialized by setting year, month day and hour in this order
the default day is 1-01-01T00 - if any of the components isn't set the
default value is used.

!param year (number) year of the new date
!param month (number) month of the new date
!param day (number) day of the new date
!param hour (number) hour of the new date

!return (Date) created object.
]]
function Date:Date(year, month, day, hour)
  self._year = year or 1
  self._month = month or 1
  self._day = day or 1
  self._hour = hour or 0
  self:_adjustOverflow()
end

--[[ Returns the last day of the current month

! This method finds the correct last day for current month of self. This number
is also the number of days within a month. Ignores leap years.

!return (number)
]]
function Date:lastDayOfMonth()
  return month_length[self._month]
end

--[[ Adds months

! Creates a copy of self with adjusted months.

!param increment (number) number to adjust, can be negative

!return (Date)
]]
function Date:plusMonths(increment)
  local new_month = self._month + increment
  return Date(self._year, new_month, self._day, self._hour)
end

--[[ Adds days

! Creates a copy of self with adjusted days.

!param increment (number) number to adjust, can be negative

!return (Date)
]]
function Date:plusDays(increment)
  local new_day = self._day + increment
  return Date(self._year, self._month, new_day, self._hour)
end

--[[ Adds years

! Creates a copy of self with adjusted years.

!param increment (number) number to adjust, can be negative

!return (Date)
]]
function Date:plusYears(increment)
  local new_year = self._year + increment
  return Date(new_year, self._month, self._day, self._hour)
end

--[[ Adds hours

! Creates a copy of self with adjusted hours.

!param increment (number) number to adjust, can be negative

!return (Date)
]]
function Date:plusHours(increment)
  local new_hour = self._hour + increment
  return Date(self._year, self._month, self._day, new_hour)
end

--[[ Returns the month of year

! Finds out what is a month of this year (1-12)

!return (number)
]]
function Date:monthOfYear()
  return self._month
end

--[[ Returns the day of month

! Finds out what is a current day in a date (1-31)

!return (number)
]]
function Date:dayOfMonth()
  return self._day
end

--[[ Returns the year

! Finds out what is a current year of this date (1-X)

!return (number)
]]
function Date:year()
  return self._year
end

--[[ Returns the hour of the day

! Finds out what is an hour of this date starting on 0

!return (number)
]]
function Date:hourOfDay()
  return self._hour
end

--[[ Return string representation

! Returns string representation of the date in format y-mm-ddThh

!return (string)
]]
function Date:tostring()
  return string.format("%d-%02d-%02dT%02d", self._year, self._month, self._day, self._hour)
end

--[[ Checks if date is a last day of a month

! Finds out if the current day is a last day in current month with respect to
different month lengths.

!return (boolean)
]]
function Date:isLastDayOfMonth()
  return self._day == self:lastDayOfMonth()
end

--[[ Checks if date is a last day of a year

! Finds out if the current day is a last day in current month and current month
is a last month in a year.

!return (boolean)
]]
function Date:isLastDayOfYear()
  return self:isLastDayOfMonth() and self._month == 12
end

--[[ Returns the month of the game

! Returns the number of months started since the start of the game. This
converts all the years to months and add them together with the started
months.

!return (number)
]]
function Date:monthOfGame()
  return (self._year - 1) * 12 + self._month
end

--[[ Clone the date

! Creates another instance of date with a same value

!return (Date)
]]
function Date:clone()
  return Date(self._year, self._month, self._day, self._hour)
end

--[[ Checks the date

! Checks the date with another passed as a parameter, but ignores time

!param other (Date) The other day to be compared

!return (boolean)
]]
function Date:isSameDay(other)
  return self._year == other._year and self._month == other._month and self._day == other._day
end

-- METAMETHODS

local Date_mt = Date._metatable

function Date_mt.__eq(one, other)
  return one:isSameDay(other) and one._hour == other._hour
end

function Date_mt.__lt(one, other)
  if one._year ~= other._year then return one._year < other._year end
  if one._month ~= other._month then return one._month < other._month end
  if one._day ~= other._day then return one._day < other._day end
  return one._hour < other._hour
end

function Date_mt.__le(one, other)
  if one._year ~= other._year then return one._year < other._year end
  if one._month ~= other._month then return one._month < other._month end
  if one._day ~= other._day then return one._day < other._day end
  return one._hour <= other._hour
end

-- PRIVATE

--[[ PRIVATE Adjusts the hours overflows

! Method to deal with hour being more or less than valid value
]]
function Date:_adjustHoursOverflow()
  while self._hour < 0 do
    self._hour = self._hour + hours_per_day
    self._day = self._day - 1
  end
  while self._hour >= hours_per_day do
    self._hour = self._hour - hours_per_day
    self._day = self._day + 1
  end
  self:_adjustDayOverflow()
end

--[[ PRIVATE Adjusts the days overflows

! Method to deal with day being more or less than valid value
]]
function Date:_adjustDayOverflow()
  while self._day < 1 do
    self._month = self._month - 1
    self:_adjustMonthOverflow()
    self._day = self._day + self:lastDayOfMonth()
  end
  while self._day > self:lastDayOfMonth() do
    self._day = self._day - self:lastDayOfMonth()
    self._month = self._month + 1
    self:_adjustMonthOverflow()
  end
end

--[[ PRIVATE Adjusts the months overflows

! Method to deal with month being more or less than valid value
]]
function Date:_adjustMonthOverflow()
  local monthIx = self._month - 1
  self._year = self._year + math.floor(monthIx / 12)
  self._month = monthIx % 12 + 1
end

--[[ PRIVATE Adjusts all the overflows

! Normalize date to fix all the overflows of hours, days and months. This
method is a key to date adjustments.
]]
function Date:_adjustOverflow()
  self:_adjustMonthOverflow()
  self:_adjustDayOverflow()
  self:_adjustHoursOverflow()
end
