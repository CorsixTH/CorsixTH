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

local pathsep = package.config:sub(1, 1)
local part_pattern = "[^" .. pathsep .. "]+"

local ISO_FS = require("TH").iso_fs

--! Layer for abstracting away differences in file systems.
--
-- In the traditional case, the FileSystem is associated with a path on the
-- actual filesystem, from which all other operations are considered relative.
--
-- The FileSystem is also able to delegate operations to the ISO_FS library
-- in the engine for reading / listing files off an ISO image instead of a
-- file system.
class "FileSystem"

---@type FileSystem
local FileSystem = _G["FileSystem"]

function FileSystem:FileSystem()
  -- A mapping of normalized file names in the current directory to their
  -- actual path names.
  self.files = nil

  -- A mapping of normalized directory names in the current directory to
  -- an object containing their actual physical path.
  self.sub_dirs = nil

  -- The actual filesystem path that is the basis/root of this FileSystem. Not
  -- used when a provider is specified.
  self.physical_path = nil

  -- The ISO_FS provider if we are reading from an ISO instead of a
  -- filesystem, otherwise nil.
  self.provider = nil
end

--! Convert a file name to a canonical, case insensitive format.
-- The format is based on the limitations of the ISO filesystem.
local function normalise(str)
  return str:upper():gsub("_", "-")
end

--! Populate the files and sub_dirs values for the current FileSystem path.
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

--! Test if file name has an .iso or .dmg extension
function FileSystem:isIso(name)
  if name == nil then
    return false
  end

  local ext = name:lower():match("%.(.+)$")
  return ext == 'iso' or ext == 'iso9660$' or ext == 'dmg'
end

--! Set the root physical path for this FileSystem.
-- If the path is an ISO then set the provider. If the path is a directory
-- then set the physical_path and populate the files and sub_dirs.
--
--!param physical_path (string) a path on the filesystem to either a directory
-- or theme hospital ISO file.
function FileSystem:setRoot(physical_path)
  if self:isIso(physical_path) then
    self.provider = ISO_FS()
    self.provider:setPathSeparator(pathsep)
    return self.provider:setRoot(physical_path)
  end

  if physical_path:sub(-1) == pathsep then
    -- Trim off the trailing separator (lfs doesn't like querying the mode of a
    -- directory with a trailing slash on win32)
    physical_path = physical_path:sub(1, -2)
  end
  if lfs.attributes(physical_path, "mode") ~= "directory"  then
    return nil, "Specified path ('" .. physical_path .. "') is not a directory"
  end

  self.provider = nil
  self.physical_path = physical_path
  self:_enumerate()

  return true
end

--! list the files in the given path.
--
--!param virtual_path (string) a path relative to the FileSystem root.
--!param ... (string) the virtual_path may be split into separate arguments
-- for each level in the filesystem.
--!return (object) a map of normalized names to actual names of files.
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

--! Combine the given path segments into a single path string.
--!param virtual_path (string) a path relative to the FileSystem root.
--!param ... (string) the virtual_path may be split into separate arguments
-- for each level in the filesystem.
local function getFullPath(virtual_path, ...)
  if ... then
    virtual_path = table.concat({virtual_path, ...}, pathsep)
  end
  return virtual_path
end

--! Return the contents of the file at the given path.
--
--!param virtual_path (string) a path relative to the FileSystem root.
--!param ... (string) the virtual_path may be split into separate arguments
-- for each level in the filesystem.
function FileSystem:readContents(virtual_path, ...)
  virtual_path = getFullPath(virtual_path, ...)
  if self.provider then
    return self.provider:readContents(virtual_path)
  end

  local file, err = self:_getFilePath(virtual_path)
  if not file then
    return file, err
  end
  local f, e = io.open(file, "rb")
  if not f then
    return nil, e
  end
  local data = f:read"*a"
  f:close()
  return data
end

--! Determines if the given path points to a real file.
--
--!param virtual_path (string) a path relative to the FileSystem root.
--!param ... (string) the virtual_path may be split into separate arguments
-- for each level in the filesystem.
function FileSystem:fileExists(virtual_path, ...)
  virtual_path = getFullPath(virtual_path, ...)
  if self.provider then
    local found, err = self.provider:fileExists(virtual_path)
    if found then
      return true
    else
      return nil, err
    end
  end

  local s, e = self:_getFilePath(virtual_path)
  return (not not s), e
end

--! Get the size of the file at the given path.
--
--!param virtual_path (string) a path relative to the FileSystem root.
--!param ... (string) the virtual_path may be split into separate arguments
-- for each level in the filesystem.
--!return (numeric) Number of bytes in the given file. Nil if the file doesn't
-- exist.
function FileSystem:fileSize(virtual_path, ...)
  virtual_path = getFullPath(virtual_path, ...)
  if self.provider then
    return self.provider:fileSize(virtual_path)
  end

  local s, e = self:_getFilePath(virtual_path)
  if not s then
    return nil, e
  end
  return lfs.attributes(s, "size")
end

-- If the file exists and we are not using a provider then return a FileSystem
-- rooted in the directory that the directory the file is contained in.
-- Otherwise return nil and an error message.
function FileSystem:_getFilePath(virtual_path, ...)
  virtual_path = getFullPath(virtual_path, ...)
  if self.provider then
    return nil, "This function is not supported for providers"
  end
  if not self.sub_dirs then
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
  return self
end
