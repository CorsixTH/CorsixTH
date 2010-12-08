# Project Declaration
PROJECT(MapEdit)
# 2.8.3 is required for the wxWidgets finder to know about ribbon
CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

# Generate source files list
# Note: Done after generating config.h
INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR}/CorsixTH/Src/)
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/agg/include/)
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/CorsixTH/Src/)
FILE(GLOB_RECURSE mapedit_source_files
  ${CMAKE_SOURCE_DIR}/MapEdit/Src/*.cpp
  ${CMAKE_SOURCE_DIR}/MapEdit/Src/*.c
  ${CMAKE_SOURCE_DIR}/MapEdit/Src/*.h
  ${CMAKE_SOURCE_DIR}/CorsixTH/Src/*.h
  ${CMAKE_SOURCE_DIR}/CorsixTH/Src/*.c
  ${CMAKE_SOURCE_DIR}/CorsixTH/Src/*.cpp
  ${CMAKE_SOURCE_DIR}/LFS/*.c
  ${CMAKE_SOURCE_DIR}/LPEG/*.c
)

# Declaration of the executable
add_executable(MapEdit 
  WIN32 
  ${mapedit_source_files}
)

# Basic platform dependant stuff
IF(UNIX)
  IF(APPLE)
    # fruit goes here
  ELSE(APPLE)
    # regular unix/linux
  ENDIF(APPLE)
  IF(WIN32)
    # Win32 specific
    IF(MSVC)
      # We want to bind against the very latest versions of the MSVC runtimes
      add_definitions(/D "_BIND_TO_CURRENT_VCLIBS_VERSION=1")
    ELSE(MSVC)
      IF(MSYS)
        # MSYS stuff
      ELSE(MSYS)
        # What's left? MINGW? CYGWIN? BORLAND?
      ENDIF(MSYS)
    ENDIF(MSVC)
  ELSE(WIN32)
    # other OS (not UNIX, not 32/64 bit Windows)
  ENDIF(WIN32)
ENDIF(UNIX)

# Finding libraries

# Find SDL
FIND_PACKAGE(SDL REQUIRED)
IF(SDL_FOUND)
  INCLUDE_DIRECTORIES(${SDL_INCLUDE_DIR})
  TARGET_LINK_LIBRARIES(MapEdit ${SDL_LIBRARY})
  message( "  SDL found" )
ELSE(SDL_FOUND)
  message( FATAL_ERROR "error: SDL library not found, it is required to build")
  message( "Make sure the path is correctly defined or set the envirnomental variable SDLDIR to the correct location" )
ENDIF(SDL_FOUND)

# Find SDL_mixer
IF(CORSIX_TH_USE_SDL_MIXER)
  FIND_PACKAGE(SDL_mixer REQUIRED)
  IF(SDLMIXER_FOUND)
    TARGET_LINK_LIBRARIES(MapEdit ${SDLMIXER_LIBRARY})
    INCLUDE_DIRECTORIES(${SDLMIXER_INCLUDE_DIR})
  message( "  SDL_mixer found" )
  ELSE(SDLMIXER_FOUND)
    message( "error: SDL_mixer library not found, it was selected to be included")
  ENDIF(SDLMIXER_FOUND)
ENDIF(CORSIX_TH_USE_SDL_MIXER)

# Find OpenGL
IF(CORSIX_TH_USE_OGL_RENDERER)
  FIND_PACKAGE(OpenGL REQUIRED)
  IF(OPENGL_FOUND)
    TARGET_LINK_LIBRARIES( MapEdit ${OPENGL_gl_LIBRARY})
    INCLUDE_DIRECTORIES(${OPENGL_INCLUDE_DIR})
    message( "  OpenGL found" )
  ELSE(OPENGL_FOUND)
    message( FATAL_ERROR "error: OpenGL library not found, it is required to build")
  ENDIF(OPENGL_FOUND)
ENDIF(CORSIX_TH_USE_OGL_RENDERER)

# Find Lua
FIND_PACKAGE(Lua51 REQUIRED)
IF(LUA51_FOUND)
  TARGET_LINK_LIBRARIES( MapEdit ${LUA_LIBRARY})
  INCLUDE_DIRECTORIES(${LUA_INCLUDE_DIR})
  message( "  Lua 5.1 found" )
ELSE(LUA51_FOUND)
  message( FATAL_ERROR "error: Lua library not found, it is required to build")
ENDIF(LUA51_FOUND)

# Find WxWidgets
SET(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}")
SET(wxWidgets_USE_LIBS gl base core ribbon) # optionally: more than wx std libs
FIND_PACKAGE(wxWidgets REQUIRED)
IF(wxWidgets_FOUND)
  LINK_LIBRARIES(${wxWidgets_LIBRARIES})
  INCLUDE_DIRECTORIES(${wxWidgets_INCLUDE_DIRS})
  INCLUDE(${wxWidgets_USE_FILE})
  TARGET_LINK_LIBRARIES(MapEdit ${wxWidgets_LIBRARIES})
  message("  wxWidgets found")
ELSE(wxWidgets_FOUND)
  message( FATAL_ERROR "error: wxWdigets library (or one of it's components) not found, it is required to build")
  message( "Make sure the path is correctly defined or set the envirnomental variable WXWIN to the correct location" )
ENDIF(wxWidgets_FOUND)

install(TARGETS MapEdit RUNTIME DESTINATION MapEdit)
install(FILES LICENSE.txt DESTINATION MapEdit )

