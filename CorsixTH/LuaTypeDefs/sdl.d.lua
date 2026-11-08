--[[ Copyright (c) 2026 Stephen Baker

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
---@meta sdl

---@class KeyModifiers
---@field public shift? boolean
---@field public alt? boolean
---@field public ctrl? boolean
---@field public gui? boolean
---@field public numlockactive? boolean
local KeyModifiers = {}

---@class SDLMusic
local SDLMusic = {}

---@class SDLWM
local SDLWM = {}

--- Not implemented
---@return boolean # True on success
function SDLWM.setIconWin32() end

---@param show boolean # True to show the cursor and false to hide it.
function SDLWM.showCursor(show) end


---@class SDLAudio
local SDLAudio = {}

--- Initialize the SDL audio subsystem.
--- This function must be called before any other SDL audio functions.
function SDLAudio.init() end


---@param file THFile # The XMI file to transcode to MIDI.
---@return string # The MIDI data
function SDLAudio.transcodeXmiToMid(file) end

--- Destroy the SDL audio subsystem.
--- This function must be called when the SDL audio subsystem is no longer
--- needed, or before reinitializing.
function SDLAudio.destroy() end

---@param file THFile
---@return SDLMusic? music
---@return string? error
function SDLAudio.loadMusic(file) end

---@param file THFile
---@param callback fun(music: SDLMusic?, error: string?): nil
function SDLAudio.loadMusicAsync(file, callback) end

--- Play the given music.
---@param music SDLMusic
function SDLAudio.playMusic(music) end

--- Stop the currently playing music.
---@return nil
---@return string? # Error message if stopping music failed
function SDLAudio.stopMusic() end

--- Pause the currently playing music.
---@return boolean paused True if music was paused, false if no music was playing
---@return string? error
function SDLAudio.pauseMusic() end

--- Resume the currently playing music.
---@return boolean resumed True if music was resumed, false if the music wasn't paused
---@return string error
function SDLAudio.resumeMusic() end

--- Set the music volume.
---@param vol number # The volume level from 0.0 (silent) to 1.0 (full volume).
function SDLAudio.setMusicVolume(vol) end


---@class SDL
---@field public wm SDLWM
---@field public audio SDLAudio
local SDL = {}

--- Init SDL subsystems. This function must be called before any other SDL functions.
---@return boolean # True if SDL is initialized, false otherwise.
function SDL.init() end

--- Send signal to quit the game.
function SDL.quit() end

---@return integer # Number of milliseconds since the SDL library initialization.
function SDL.getTicks() end

---@return KeyModifiers # The current state of the keyboard modifiers.
function SDL.getKeyModifiers() end

--- Indicate to SDL that the application expects text input. e.g. the user has clicked on a text field.
---@param canvas THRenderTarget
function SDL.startTextInput(canvas) end

--- Indicate to SDL that the application no longer expects text input.
---@param canvas THRenderTarget
function SDL.stopTextInput(canvas) end

---@return integer? fps # The number of frames in the last second, or nil if FPS tracking is not enabled.
function SDL.getFPS() end

---@param enabled? boolean # Whether to enable or disable FPS tracking. True if unspecified.
function SDL.trackFPS(enabled) end

---@param enabled? boolean # Whether to enable or disable FPS limiting. True if unspecified.
function SDL.limitFPS(enabled) end

return SDL
