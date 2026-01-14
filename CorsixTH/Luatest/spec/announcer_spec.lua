require("corsixth")

require("class_test_base")

require("announcer")

local Announcer = _G["Announcer"]
local AnnouncementPriority = _G["AnnouncementPriority"]

local function create_date_mock_type()
  local date_mock = {}
  local date_mock_mt = { __index = date_mock }

  function date_mock.new(value)
    local self = {
      value = value or 0
    }

    setmetatable(self, date_mock_mt)

    return self
  end

  function date_mock:clone()
    return date_mock.new(self.value)
  end

  function date_mock:plusHours(hours)
    return date_mock.new(self.value + hours)
  end

  function date_mock_mt.__lt(left, right)
    return left.value < right.value
  end

  function date_mock_mt.__le(left, right)
    return left.value <= right.value
  end

  return date_mock.new
end

local create_date_mock = create_date_mock_type()

local function create_app_mock(speed_set, desk_set)
  local world_mock = {}
  world_mock.mock_game_date = create_date_mock()
  world_mock.date = function() return world_mock.mock_game_date end
  world_mock.isCurrentSpeed = function() return speed_set end
  world_mock.getLocalPlayerHospital = function()
    return {
      hasStaffedDesk = function() return desk_set end
    }
  end

  local ui_mock = {}
  local subtitles_mock = {
    queueSubtitle = function() end,
  }
  ui_mock.subtitles = subtitles_mock

  local config_mock = {
    play_announcements = true
  }

  local played_sounds = {}

  local audio_mock = {
    __played_sounds__ = played_sounds,
    playSound = function(_, name, where, is_announcement, played_callback, played_callback_delay)
      table.insert(played_sounds, {
        name = name,
        where = where,
        is_announcement = is_announcement,
        played_callback = played_callback,
        played_callback_delay = played_callback_delay
      })
    end,
    __mark_sounds_played__ = function()
      for k,v in pairs(played_sounds) do
        v.played_callback()
        played_sounds[k] = nil -- clear
      end
    end,
    resolveFilenameWildcard = function(_, name)
      return name
    end
  }

  local app = {
    world = world_mock,
    ui = ui_mock,
    config = config_mock,
    audio = audio_mock
  }

  return app
end

--[[
Test formats for the announcer should be as follows (empty lines should be used as indicated):
it("description of what is expected/tested", function()
  local app_mock = create_app_mock(speed_set, desk_set)
  local announcer = Announcer(app_mock)

  Insert config settings here
  Followed by announcements to queue

  announcer:onTick --group ticks with each test
  Some test

  announcer:onTick
  Some test etc...
end)

speed_set is whether to obey the requested speed check in announcer.lua
desk_set is whether we have a staffed desk
]]--

describe("Announcer", function()
  it("nothing is played with an empty queue", function()
    local app_mock = create_app_mock(false, true)
    local announcer = Announcer(app_mock)

    announcer:onTick()

    assert.equal(0, #app_mock.audio.__played_sounds__)
  end)

  it("an announcement is played", function()
    local app_mock = create_app_mock(false, true)
    local announcer = Announcer(app_mock)

    announcer:playAnnouncement("sound.wav")

    announcer:onTick()
    assert.equal(1, #app_mock.audio.__played_sounds__)
    assert.equal("sound.wav", app_mock.audio.__played_sounds__[1].name)
  end)

  it("announcements shouldn't play when disabled", function()
    local app_mock = create_app_mock(false, true)
    local announcer = Announcer(app_mock)

    app_mock.config.play_announcements = false
    announcer:playAnnouncement("normal.wav")

    announcer:onTick()
    assert.equal(0, #app_mock.audio.__played_sounds__)
  end)

  it("duplicate announcements should be discarded", function()
    local app_mock = create_app_mock(false, true)
    local announcer = Announcer(app_mock)

    announcer:playAnnouncement("sound.wav")
    announcer:playAnnouncement("sound.wav")
    announcer:playAnnouncement("sound.wav")

    announcer:onTick()
    announcer:onTick()
    announcer:onTick()
    assert.equal(1, #app_mock.audio.__played_sounds__)
  end)

  it("announcements are played priority-wise", function()
    local app_mock = create_app_mock(false, true)
    local announcer = Announcer(app_mock)

    announcer:playAnnouncement("low.wav", AnnouncementPriority.Low)
    announcer:playAnnouncement("critical.wav", AnnouncementPriority.Critical)
    announcer:playAnnouncement("normal.wav", AnnouncementPriority.Normal)
    announcer:playAnnouncement("high.wav", AnnouncementPriority.High)

    announcer:onTick()
    assert.equal(1, #app_mock.audio.__played_sounds__)
    assert.equal("critical.wav", app_mock.audio.__played_sounds__[1].name)
    app_mock.audio.__mark_sounds_played__()

    announcer:onTick()
    assert.equal(1, #app_mock.audio.__played_sounds__)
    assert.equal("high.wav", app_mock.audio.__played_sounds__[1].name)
    app_mock.audio.__mark_sounds_played__()

    announcer:onTick()
    assert.equal(1, #app_mock.audio.__played_sounds__)
    assert.equal("normal.wav", app_mock.audio.__played_sounds__[1].name)
    app_mock.audio.__mark_sounds_played__()

    announcer:onTick()
    assert.equal(1, #app_mock.audio.__played_sounds__)
    assert.equal("low.wav", app_mock.audio.__played_sounds__[1].name)
    app_mock.audio.__mark_sounds_played__()
  end)

  it("announcements shouldn't play when not relevant anymore", function()
    local app_mock = create_app_mock(false, true)
    local announcer = Announcer(app_mock)

    announcer:playAnnouncement("normal.wav")
    app_mock.world.mock_game_date = app_mock.world.mock_game_date:plusHours(1000) -- time must be after announcement

    announcer:onTick()
    assert.equal(0, #app_mock.audio.__played_sounds__)
  end)

  it("only critical announcements play when paused", function()
    local app_mock = create_app_mock(true, true)
    local announcer = Announcer(app_mock)

    announcer:playAnnouncement("low.wav", AnnouncementPriority.Low)
    announcer:playAnnouncement("critical.wav", AnnouncementPriority.Critical)
    announcer:playAnnouncement("normal.wav", AnnouncementPriority.Normal)
    announcer:playAnnouncement("high.wav", AnnouncementPriority.High)

    announcer:onTick()
    assert.equal(1, #app_mock.audio.__played_sounds__)
    assert.equal("critical.wav", app_mock.audio.__played_sounds__[1].name)
    app_mock.audio.__mark_sounds_played__()

    announcer:onTick()
    assert.equal(0, #app_mock.audio.__played_sounds__)
  end)

  it("critical announcements play without a staffed desk", function()
    local app_mock = create_app_mock(false, false)
    local announcer = Announcer(app_mock)

    announcer:playAnnouncement("critical.wav", AnnouncementPriority.Critical)

    announcer:onTick()
    assert.equal(1, #app_mock.audio.__played_sounds__)
    assert.equal("critical.wav", app_mock.audio.__played_sounds__[1].name)
    app_mock.audio.__mark_sounds_played__()
  end)
end)
