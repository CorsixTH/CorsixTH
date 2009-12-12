----  CorsixTH x64 bootstrap code ---------------------------------------------
-- This file prepends some command line arguments so that the CorsixTH.lua and
-- config.txt files, and the Lua and Bitmap directories, of the directory above
-- this one are used.

local pathsep = package.config:sub(1, 1)
return assert(loadfile(".."..pathsep.."CorsixTH.lua"))(
  "--lua-dir=.."..pathsep.."Lua",
  "--bitmap-dir=.."..pathsep.."Bitmap",
  "--config-file=.."..pathsep.."config.txt",
  ...
)
