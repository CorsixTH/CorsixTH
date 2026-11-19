require("corsixth")

require("class_test_base")

-- audio.lua loads native modules at require time; stub the ones that are not
-- needed for these tests.
if not package.loaded["sdl"] and not package.preload["sdl"] then
  package.preload["sdl"] = function() return {} end
end
if not package.loaded["rnc"] and not package.preload["rnc"] then
  package.preload["rnc"] = function() return {} end
end

require("audio")

local Audio = _G["Audio"]

local function create_audio()
  local app = {
    config = {
      play_music = true,
      audio = true,
      play_own_music = false,
    },
  }
  local audio = Audio(app)
  -- Playlist entries with filenames as built by Audio:init. Music data is
  -- filled in by playback in the real game, so it is nil here.
  audio.background_playlist = {
    {title = "Alpha", filename = "ALPHA.MID", enabled = true},
    {title = "Beta", filename = "BETA.MID", enabled = true},
    {title = "Gamma", filename = "GAMMA.MID", enabled = true},
  }
  return audio
end

describe("Audio:reinitAudioSystem", function()
  local function stub_reinit(audio, on_init)
    local calls = {}
    -- Keep the playlist and played track across the mocked reinit so the
    -- restore logic can be checked without SDL or the filesystem.
    audio.app.ui = {getWindow = function() return nil end}
    audio.app.initLanguage = function() end
    audio.stopBackgroundTrack = function(self)
      calls[#calls + 1] = "stop"
      self.background_music = nil
    end
    audio.destroy = function() calls[#calls + 1] = "destroy" end
    audio.init = function(self)
      calls[#calls + 1] = "init"
      if on_init then on_init(self) end
    end
    audio.playBackgroundTrack = function(self, index)
      calls[#calls + 1] = "play:" .. index
      self.background_music = self.background_playlist[index].music or index
    end
    audio.playRandomBackgroundTrack = function(self)
      calls[#calls + 1] = "random"
    end
    return calls
  end

  it("resumes the track that was playing instead of a random one", function()
    local audio = create_audio()
    local calls = stub_reinit(audio, function(self)
      -- Audio:init rebuilds the playlist from disk; simulate the same tracks.
      self.background_playlist = {
        {title = "Alpha", filename = "ALPHA.MID", enabled = true},
        {title = "Beta", filename = "BETA.MID", enabled = true},
        {title = "Gamma", filename = "GAMMA.MID", enabled = true},
      }
    end)
    audio.background_playlist[2].music = 42
    audio.background_music = 42

    audio:reinitAudioSystem()

    assert.same({"stop", "destroy", "init", "play:2"}, calls)
  end)

  it("falls back to a random track when the previous track is not known", function()
    local audio = create_audio()
    local calls = stub_reinit(audio)
    audio.background_music = nil

    audio:reinitAudioSystem()

    assert.same({"stop", "destroy", "init", "random"}, calls)
  end)

  it("falls back to a random track when the previous track is now disabled", function()
    local audio = create_audio()
    local calls = stub_reinit(audio, function(self)
      self.background_playlist = {
        {title = "Alpha", filename = "ALPHA.MID", enabled = true},
        {title = "Beta", filename = "BETA.MID", enabled = false},
      }
    end)
    audio.background_playlist[2].music = 42
    audio.background_music = 42

    audio:reinitAudioSystem()

    assert.same({"stop", "destroy", "init", "random"}, calls)
  end)
end)
