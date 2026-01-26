--[[ Copyright (c) 2018 Rick "Feanathiel" Megens

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

corsixth.require("date")

--! Pr
local AnnouncementPriority = {
  Critical = 1,
  High = 2,
  Normal = 3,
  Low = 4
}

strict_declare_global "AnnouncementPriority"
_G["AnnouncementPriority"] = AnnouncementPriority

local default_announcement_priority = AnnouncementPriority.Normal
local hoursPerDay = Date.hoursPerDay()

local default_announcement_decay_hours = {
  [AnnouncementPriority.Critical] = -1, -- never decay
  [AnnouncementPriority.High] = 31 * hoursPerDay,
  [AnnouncementPriority.Normal] = 7 * hoursPerDay,
  [AnnouncementPriority.Low] = 3 * hoursPerDay
}

--! An announcement queue based on priority
class "AnnouncementQueue"

---@type AnnouncementQueue
local AnnouncementQueue = _G["AnnouncementQueue"]

--! Creates an announcement queue: a collection of announcements with queue semantics.
function AnnouncementQueue:AnnouncementQueue()
  -- might want to use a single table for this
  self.priorities = {
    [AnnouncementPriority.Critical] = {},
    [AnnouncementPriority.High] = {},
    [AnnouncementPriority.Normal] = {},
    [AnnouncementPriority.Low] = {}
  }

  self.count = 0
end

--! Adds the announcement entry to the queue.
--!param priority (int) the priority of the announcement
--!param entry (AnnouncementEntry) the announcement entry
function AnnouncementQueue:push(priority, entry)
  local entries = self.priorities[priority]
  table.insert(entries, entry)
  self.count = self.count + 1
end

--! Dequeues the announcement with the highest priority, nil if the queue is empty.
function AnnouncementQueue:pop()
  for _, entries in ipairs(self.priorities) do
    if entries[1] ~= nil then
      local entry = table.remove(entries, 1)
      self.count = self.count - 1
      return entry
    end
  end

  return nil
end

--! Returns true if the queue is empty, false otherwise.
function AnnouncementQueue:isEmpty()
  return self.count == 0
end

--! Checks for duplicates in the announcement queue and refreshes the announcement's created_date
--!param sound the announcement to check
--!param date the date to use, usually the current date
function AnnouncementQueue:checkForDuplicates(sound, date)
  for _, entries in ipairs(self.priorities) do
    for _, entry in ipairs(entries) do
      if entry.name == sound then
        entry.created_date = date
        return true
      end
    end
  end
  return false
end


--! An announcement.
class "AnnouncementEntry"

---@type AnnouncementEntry
local AnnouncementEntry = _G["AnnouncementEntry"]

--! Creates an announcement
function AnnouncementEntry:AnnouncementEntry()
  self.name = nil -- filename to play
  self.priority = default_announcement_priority
  self.created_date = nil -- when it has been created
  self.decay_hours = nil -- how long until the announcement isn't relevant anymore
  self.played_callback = nil -- call me whenever the sound was played, ...
  self.played_callback_delay = nil -- but not until delay has passed
end

--! Announces audible messages to the player.
--! The announcer plays announcements based on their priority. If the caller requests an
-- announcement to be played, it will be played directly if there are no announcements
-- currently being announced. Note that announcements are only played if there is
-- a worker at the reception desk and announcements are enabled in the settings.
class "Announcer"

---@type Announcer
local Announcer = _G["Announcer"]

--! Constructor.
--!param app (App) The CorsixTH app
function Announcer:Announcer(app)
  self.app = app
  self.entries = AnnouncementQueue()
  self.playing = false
  self.ticks_since_last_announcement = 0

  self:_setRandomAnnouncementTarget()
end

--! Requests the announcer to play an announcement.
--!param name (string) The filename to play.
--!param priority (int | nil) The priority of the announcement. See AnnouncementPriority.
--!param decay_hours (float | nil) After this amount of hours the announcement should be considered irrelevant.
-- Provide nil for a decay time based on the provided priority.
--!param played_callback (function | nil) The callback to trigger when the announcement was successfully played.
--!param played_callback_delay (int | nil) Delay the callback with this amount of milliseconds.
function Announcer:playAnnouncement(name, priority, decay_hours, played_callback, played_callback_delay)
  -- Announcements use the in-game time instead of ticks.
  -- For example, if an employee is sacked, the announcement should
  -- have played in a reasonable amount of time (on his way out).
  -- We don't want the game to play the announcement if it took too long to
  -- actually start it, as more important announcements must be played before that.
  -- It doesn't make sense to play the sacked announcement when the employee
  -- already has had several other jobs and has died already [joke].

  -- Check for duplicate announcements, if there is we refresh the existing one
  local created_date = self.app.world:date()
  local duplicate_announcement = self.entries:checkForDuplicates(name, created_date)
  if duplicate_announcement then
    return
  end

  local new_priority = priority or default_announcement_priority

  local new_decay_hours = decay_hours or default_announcement_decay_hours[new_priority]

  local entry = AnnouncementEntry()
  entry.name = name
  entry.priority = new_priority
  entry.created_date = created_date
  entry.decay_hours = new_decay_hours
  entry.played_callback = played_callback
  entry.played_callback_delay = played_callback_delay

  if self.app.world:getLocalPlayerHospital():hasStaffedDesk() or priority == AnnouncementPriority.Critical then
    self.entries:push(new_priority, entry)
  end
end

--! The announcer's (game) tick handler.
-- Plays the actual sound of the announcements, if available.
-- Also queues random announcements if no announcements have been played for a while.
function Announcer:onTick()
  local staffedDesk = self.app.world:getLocalPlayerHospital():hasStaffedDesk()
  local criticalAnnounces = #self.entries.priorities[AnnouncementPriority.Critical]
  if not self.app.world:isCurrentSpeed("Pause") then
    local ticks_since_last_announcement = self.ticks_since_last_announcement
    if ticks_since_last_announcement >= self.random_announcement_ticks_target then
      self:playAnnouncement("rand*.wav", AnnouncementPriority.Low)
      self:_setRandomAnnouncementTarget()
    else
      self.ticks_since_last_announcement = ticks_since_last_announcement + 1
    end

    -- Wait for an occupied desk or announcement is critical
    if staffedDesk or criticalAnnounces > 0 then
      while not self.playing and not self.entries:isEmpty() do
        local entry = self.entries:pop()
        local game_date = self.app.world:date()

        if entry.decay_hours == -1 or game_date <= entry.created_date:plusHours(entry.decay_hours) then
          if self.app.config.play_announcements then
            self:_play(entry)
          end
          -- Drain the queue otherwise
        end
      end
    end
  -- The game is paused
  else
    -- Only play critical announcements when paused
    while not self.playing and not self.entries:isEmpty() and criticalAnnounces > 0 do
      local entry = self.entries:pop()
      if self.app.config.play_announcements then
        self:_play(entry)
      end
    end
  end
end

--! Private function. Sets the new time (in ticks) when a random announcement should be played.
function Announcer:_setRandomAnnouncementTarget()
  -- Note that random announcement are measured in ticks.
  -- This ensures that on fast game speeds random announcements aren't
  -- spammed, or on lower game speeds random announcements are never played.

  -- Every tick is 18ms, so ~3333 ticks is 1 minute at normal speed
  local tick_chunk = 3333
  -- Set a target of 4 - 6 minutes (chunks)
  self.random_announcement_ticks_target = math.random(tick_chunk * 4, tick_chunk * 6)
end

--! Private function. Plays the actual sound of an announcement.
--!param entry (AnnouncementEntry) The announcement to play.
function Announcer:_play(entry)
  self.playing = true
  local name = self.app.audio:resolveFilenameWildcard(entry.name)
  self.app.audio:playSound(name, nil, true, function () self:_onPlayed(entry) end, entry.played_callback_delay)
  self.app.ui.subtitles:queueSubtitle(name)
  self.ticks_since_last_announcement = 0
end

--! Private function. Handles the playSound completed event. Also calls the callback of the announcement.
--!param entry (AnnouncementEntry) The announcement that has been played.
function Announcer:_onPlayed(entry)
  self.playing = false

  if entry.played_callback ~= nil then
    entry.played_callback()
  end
end
