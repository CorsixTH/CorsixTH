---
-- This script is responsible for starting a DBGp client for CorsixTH's
-- Lua scripts and then connecting this to a running DBGp server.
-- 
-- It does this in the function it returns.
---
local function run()
  local error_message = is_file_unreadable("CorsixTH/Lua/debugger.lua", true)
  if error_message  then
    print(error_message)
    return "../Lua/debugger.lua is missing or can't be read. Devs are required to download this file: the wiki debugger tutorial has instructions."
  end
  
  print "NOTE: While CorsixTH is connected to an IDE's debugger server,"
  print "text will be printed in its output console instead of here."
  
  if not pcall(require, "socket") then
    print("Can't connect debugger: LuaSocket is not available.")
    return "Can't connect debugger: LuaSocket is not available."
  end
  
  local _, config = dofile("config_finder")
  local connect = dofile("debugger")
  
  local successful, error_message = pcall(connect, config.DBGp_client_idehost,
                                                   config.DBGp_client_ideport,
                                                   config.DBGp_client_idekey,
                                                   config.DBGp_client_transport,
                                                   config.DBGp_client_platform,
                                                   config.DBGp_client_workingdir)
  if not successful then
    print("\nCan't connect DBGp client:\n" .. error_message .. "\n")
    return "Failed to connect debugger, error printed in console."
  end
end
return run

