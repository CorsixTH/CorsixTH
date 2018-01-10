# Copyright (c) 2013 Martin Felis &lt;martin@fysx.org&gt;
# License: Public Domain (Unlicense: http://unlicense.org/)
# Modified by Edvin "Lego3" Linge for the CorsixTH project.
#
# Try to find Lua or LuaJIT depending on the variable WITH_LUAJIT.
# Sets the following variables:
#   Lua_FOUND
#   LUA_INCLUDE_DIR
#   LUA_LIBRARY
#
# Use it in a CMakeLists.txt script as:
#
#   OPTION (WITH_LUAJIT "Use LuaJIT instead of default Lua" OFF)
#   UNSET(Lua_FOUND CACHE)
#   UNSET(LUA_INCLUDE_DIR CACHE)
#   UNSET(LUA_LIBRARY CACHE)
#   FIND_PACKAGE (Lua REQUIRED)

set(Lua_FOUND FALSE)
set(LUA_INTERPRETER_TYPE "")

if(WITH_LUAJIT)
  set(LUA_INTERPRETER_TYPE "LuaJIT")
  set(LUA_LIBRARY_NAME luajit-5.1 lua51)
  set(LUA_INCLUDE_DIRS include/luajit-2.0 include)
else()
  set(LUA_INTERPRETER_TYPE "Lua")
  set(LUA_LIBRARY_NAME lua53 lua5.3 lua-5.3 liblua.5.3.dylib lua52 lua5.2 lua-5.2 liblua.5.2.dylib lua51 lua5.1 lua-5.1 liblua.5.1.dylib lua liblua)
  set(LUA_INCLUDE_DIRS include/lua53 include/lua5.3 include/lua-5.3 include/lua52 include/lua5.2 include/lua-5.2 include/lua51 include/lua5.1 include/lua-5.1 include/lua include)
endif()

find_path(LUA_INCLUDE_DIR lua.h
  HINTS
    ENV LUA_DIR
  PATH_SUFFIXES ${LUA_INCLUDE_DIRS}
  PATHS
  /opt/local
  /usr/local
  /usr
  /opt
  /sw
  ~/Library/Frameworks
  /Library/Frameworks
)
find_library(LUA_LIBRARY NAMES ${LUA_LIBRARY_NAME}
  HINTS
    ENV LUA_DIR
  PATH_SUFFIXES lib
  PATHS
  /usr
  /usr/local
  /opt/local
  /opt
  /sw
  ~/Library/Frameworks
  /Library/Frameworks
)

if(NOT LUA_INCLUDE_DIR)
  message(FATAL_ERROR "Could Not Find Lua Include Dir")
endif()

if(NOT LUA_LIBRARY)
  message(FATAL_ERROR "Could Not Find Lua Library")
endif()


if(LUA_INCLUDE_DIR AND LUA_LIBRARY)
  set(Lua_FOUND TRUE)
endif()

if(Lua_FOUND)
  if(NOT Lua_FIND_QUIETLY)
    message(STATUS "Found ${LUA_INTERPRETER_TYPE} library: ${LUA_LIBRARY}")
  endif()
else (Lua_FOUND)
 if(Lua_FIND_REQUIRED)
   MESSAGE(FATAL_ERROR "Could not find ${LUA_INTERPRETER_TYPE}")
 endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Lua  DEFAULT_MSG LUA_LIBRARY LUA_INCLUDE_DIR)

mark_as_advanced(LUA_INCLUDE_DIR LUA_LIBRARY)
