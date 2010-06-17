--[[ Copyright (c) 2010 Peter "Corsix" Cawley

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

local LFS = require "lfs"
local pathsep = package.config:sub(1, 1)
local part_pattern = "[^".. pathsep .."]+"
local ISO_FS = require "ISO_FS"

--! Layer for abstracting away differences in file systems
class "FileSystem"

function FileSystem:FileSystem()
end

local function normalise(str)
  return str:upper():gsub("_", "-")
end

function FileSystem:_enumerate()
  self.sub_dirs = {}
  self.files = {}
  for item in lfs.dir(self.physical_path) do
    local path = self.physical_path .. pathsep .. item
    if lfs.attributes(path, "mode") == "directory" then
      self.sub_dirs[normalise(item)] = {physical_path = path}
    else
      self.files[normalise(item)] = path
    end
  end
end

function FileSystem:setRoot(physical_path)
  if physical_path:match"%.[iI][sS][oO]$" or physical_path:match"%.[iI][sS][oO]9660$" then
    self.provider = ISO_FS()
    self.provider:setPathSeparator(pathsep)
    local file, err = io.open(physical_path, "rb")
    if not file then
      return nil, err
    end
    return self.provider:setRoot(file)
  else
    self.provider = nil
  end
  if physical_path:sub(-1) == pathsep then
    -- Trim off the trailing separator (lfs doesn't like querying the mode of a
    -- directory with a trailing slash on win32)
    physical_path = physical_path:sub(1, -2)
  end
  if lfs.attributes(physical_path, "mode") ~= "directory"  then
    return nil, "Specified path ('".. physical_path .. "') is not a directory"
  end
  self.physical_path = physical_path
  self:_enumerate()
  return true
end

function FileSystem:listFiles(virtual_path, ...)
  if ... then
    virtual_path = table.concat({virtual_path, ...}, pathsep)
  end
  if self.provider then
    return self.provider:listFiles(virtual_path)
  elseif not self.sub_dirs then
    return nil, "Filesystem layer not initialised"
  end
  for part in virtual_path:gmatch(part_pattern) do
    local part_u = normalise(part)
    if self.sub_dirs[part_u] then
      self = self.sub_dirs[part_u]
      if not self.files then
        FileSystem._enumerate(self)
      end
    elseif self.files[part_u] then
      return nil, ("Attempt to access file '%s' as if it were a directory while trying to enumerate '%s'"):format(part, virtual_path)
    else
      return nil, ("Unable to find '%s' while trying to enumerate '%s'"):format(part, virtual_path)
    end
  end
  return self.files
end

function FileSystem:readContents(virtual_path, ...)
  if ... then
    virtual_path = table.concat({virtual_path, ...}, pathsep)
  end
  if self.provider then
    return self.provider:readContents(virtual_path)
  elseif not self.sub_dirs then
    return nil, "Filesystem layer not initialised"
  end
  local is_file = false
  for part in virtual_path:gmatch(part_pattern) do
    if is_file then
      return nil, ("Attempt to access file '%s' as if it were a directory while trying to read '%s'"):format(part, virtual_path)
    end
    local part_u = normalise(part)
    if self.sub_dirs[part_u] then
      self = self.sub_dirs[part_u]
      if not self.files then
        FileSystem._enumerate(self)
      end
    elseif self.files[part_u] then
      self = self.files[part_u]
      is_file = true
    else
      return nil, ("Unable to find '%s' while trying to read '%s'"):format(part, virtual_path)
    end
  end
  if not is_file then
    return nil, ("Attempt to access directory '%s' as if it were a file"):format(virtual_path)
  end
  local f, e = io.open(self, "rb")
  if not f then
    return nil, e
  end
  local data = f:read"*a"
  f:close()
  return data
end
