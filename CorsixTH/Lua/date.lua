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
  Date class is meand to encapsulate logic around months, years, days.
  It should be able to do adjustments with regards to days in given month and so on.
--]]

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

function Date.hoursPerDay()
  return hours_per_day
end

-- PUBLIC

function Date:Date(year, month, day, hour)
  self._year = year or 1
  self._month = month or 1
  self._day = day or 1
  self._hour = hour or 0
  self:_adjustOverflow()
end

function Date:lastDayOfMonth()
  return month_length[self._month]
end

function Date:plusMonths(increment)
  local new_month = self._month + increment
  return Date(self._year, new_month, self._day, self._hour)
end

function Date:plusDays(increment)
  local new_day = self._day + increment
  return Date(self._year, self._month, new_day, self._hour)
end

function Date:plusYears(increment)
  local new_year = self._year + increment
  return Date(new_year, self._month, self._day, self._hour)
end

function Date:plusHours(increment)
  local new_hour = self._hour + increment
  return Date(self._year, self._month, self._day, new_hour)
end

function Date:monthOfYear()
  return self._month
end

function Date:dayOfMonth()
  return self._day
end

function Date:year()
  return self._year
end

function Date:hourOfDay()
  return self._hour
end

function Date:tostring()
  return string.format("%d-%02d-%02dT%02d", self._year, self._month, self._day, self._hour)
end

function Date:isLastDayOfMonth()
  return self._day == self:lastDayOfMonth()
end

function Date:isLastDayOfYear()
  return self:isLastDayOfMonth() and self._month == 12
end

function Date:monthOfGame()
  return (self._year - 1) * 12 + self._month
end

function Date:clone()
  return Date(self._year, self._month, self._day, self._hour)
end

-- METAMETHODS

local Date_mt = Date._metatable

function Date_mt.__eq(one, other)
  return one._year == other._year and one._month == other._month and one._day == other._day and one._hour == other._hour
end

function Date_mt.__lt(one, other)
  if one._year == other._year then
    if one._month == other._month then
      if one._day == other._day then
        return one._hour < other._hour
      end
      return one._day < other._day
    end
    return one._month < other._month
  end
  return one._year < other._year
end

-- PRIVATE

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

function Date:_adjustMonthOverflow()
  local monthIx = self._month - 1
  self._year = self._year + math.floor(monthIx / 12)
  self._month = monthIx % 12 + 1
end

function Date:_adjustOverflow()
  self:_adjustMonthOverflow()
  self:_adjustDayOverflow()
  self:_adjustHoursOverflow()
end
