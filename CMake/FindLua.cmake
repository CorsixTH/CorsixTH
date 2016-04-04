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

SET (Lua_FOUND FALSE)

SET (LUA_INTERPRETER_TYPE "")

IF (WITH_LUAJIT)
    SET (LUA_INTERPRETER_TYPE "LuaJIT")
    SET (LUA_LIBRARY_NAME luajit-5.1 lua51)
    SET (LUA_INCLUDE_DIRS include/luajit-2.0 include)
ELSE (WITH_LUAJIT)
    SET (LUA_INTERPRETER_TYPE "Lua")
    SET (LUA_LIBRARY_NAME lua53 lua52 lua5.1 lua51 lua lua-5.1 liblua liblua.5.3.dylib)
    SET (LUA_INCLUDE_DIRS include include/lua include/lua5.1 include/lua51 include/lua-5.1 include/lua5.3 include/lua-5.3)
ENDIF(WITH_LUAJIT)

FIND_PATH (LUA_INCLUDE_DIR lua.h
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
FIND_LIBRARY (LUA_LIBRARY NAMES ${LUA_LIBRARY_NAME}
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

IF (NOT LUA_INCLUDE_DIR)
    MESSAGE(FATAL_ERROR "Could Not Find Lua Include Dir")
ENDIF (NOT LUA_INCLUDE_DIR)

IF (NOT LUA_LIBRARY)
    MESSAGE(FATAL_ERROR "Could Not Find Lua Library")
ENDIF (NOT LUA_LIBRARY)


IF (LUA_INCLUDE_DIR AND LUA_LIBRARY)
    SET (Lua_FOUND TRUE)
ENDIF (LUA_INCLUDE_DIR AND LUA_LIBRARY)

IF (Lua_FOUND)
    IF (NOT Lua_FIND_QUIETLY)
        MESSAGE(STATUS "Found ${LUA_INTERPRETER_TYPE} library: ${LUA_LIBRARY}")
    ENDIF (NOT Lua_FIND_QUIETLY)
ELSE (Lua_FOUND)
   IF (Lua_FIND_REQUIRED)
       MESSAGE(FATAL_ERROR "Could not find ${LUA_INTERPRETER_TYPE}")
   ENDIF (Lua_FIND_REQUIRED)
ENDIF (Lua_FOUND)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Lua  DEFAULT_MSG LUA_LIBRARY LUA_INCLUDE_DIR)

MARK_AS_ADVANCED ( LUA_INCLUDE_DIR LUA_LIBRARY)
