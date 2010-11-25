# Sanity check
IF(CORSIX_TH_DONE_TOP_LEVEL_CMAKE)
ELSE(CORSIX_TH_DONE_TOP_LEVEL_CMAKE)
message(FATAL_ERROR "Please run cmake on the top-level directory, not this one.")
ENDIF(CORSIX_TH_DONE_TOP_LEVEL_CMAKE)

# Project Declaration
PROJECT(CorsixTH)

# Basic platform dependant stuff
IF(UNIX)
  IF(APPLE)
    # fruit goes here
    add_subdirectory(SDLMain)
  ELSE(APPLE)
    # regular unix/linux
  ENDIF(APPLE)
ELSE()
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

# Modify the config.h based upon our selection of options
CONFIGURE_FILE(${CMAKE_SOURCE_DIR}/CorsixTH/Src/config.h.in ${CMAKE_BINARY_DIR}/CorsixTH/Src/config.h)
INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR}/CorsixTH/Src/)
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/agg/include/)

# Generate source files list
# Note: Done after generating config.h
FILE(GLOB_RECURSE corsixth_source_files
  ${CMAKE_SOURCE_DIR}/CorsixTH/SrcUnshared/*.cpp
  ${CMAKE_SOURCE_DIR}/CorsixTH/SrcUnshared/*.c
  ${CMAKE_SOURCE_DIR}/CorsixTH/SrcUnshared/*.h
  ${CMAKE_SOURCE_DIR}/CorsixTH/SrcUnshared/*.hpp
  ${CMAKE_SOURCE_DIR}/CorsixTH/Src/*.cpp
  ${CMAKE_SOURCE_DIR}/CorsixTH/Src/*.c
  ${CMAKE_SOURCE_DIR}/CorsixTH/Src/*.hpp
  ${CMAKE_SOURCE_DIR}/CorsixTH/Src/*.h
  ${CMAKE_BINARY_DIR}/CorsixTH/Src/config.h
  ${CMAKE_SOURCE_DIR}/CorsixTH/Lua/api_version.lua
  ${CMAKE_SOURCE_DIR}/CorsixTH/CorsixTH.rc
  ${CMAKE_SOURCE_DIR}/LFS/*.c
  ${CMAKE_SOURCE_DIR}/LPEG/*.c
  ${CMAKE_SOURCE_DIR}/agg/src/agg_image_filters.cpp
)

# Declaration of the executable
add_executable(CorsixTH ${corsixth_source_files})

IF(APPLE)
  target_link_libraries(CorsixTH SDLmain)
  INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR}/CorsixTH/SDLMain/)
ENDIF(APPLE)

# Finding libraries

# Find SDL
FIND_PACKAGE(SDL REQUIRED)
IF(SDL_FOUND)
  INCLUDE_DIRECTORIES(${SDL_INCLUDE_DIR})
  IF(SDLMAIN_LIBRARY STREQUAL "")
    IF(WIN32)
      # SDLmain not being found is not fatal, as the win32 SDLmain.c is distributed with CorsixTH
    ELSE(WIN32)
      message(FATAL_ERROR "Error: SDL was found but SDLmain was not")
      message("Make sure the path is correctly defined or set the environment variable SDLDIR to the correct location")
    ENDIF(WIN32)
  ENDIF(SDLMAIN_LIBRARY STREQUAL "")
  # No need to specify sdlmain seperately, the FindSDL.cmake file will take care of that. If not we get an error about it
  TARGET_LINK_LIBRARIES(CorsixTH ${SDL_LIBRARY})
  message("  SDL found")
ELSE(SDL_FOUND)
  message(FATAL_ERROR "Error: SDL library not found, it is required to build. Make sure the path is correctly defined or set the environment variable SDLDIR to the correct location")
ENDIF(SDL_FOUND)

# Find Lua
FIND_PACKAGE(Lua51 REQUIRED)
IF(LUA51_FOUND)
  TARGET_LINK_LIBRARIES(CorsixTH ${LUA_LIBRARY})
  INCLUDE_DIRECTORIES(${LUA_INCLUDE_DIR})
  message("  Lua 5.1 found")
ELSE(LUA51_FOUND)
  message(FATAL_ERROR "Error: Lua library not found, it is required to build")
ENDIF(LUA51_FOUND)

# Find SDL_mixer
IF(CORSIX_TH_USE_SDL_MIXER)
  FIND_PACKAGE(SDL_mixer REQUIRED)
  IF(SDLMIXER_FOUND)
    TARGET_LINK_LIBRARIES(CorsixTH ${SDLMIXER_LIBRARY})
    INCLUDE_DIRECTORIES(${SDLMIXER_INCLUDE_DIR})
    message("  SDL_mixer found")
  ELSE(SDLMIXER_FOUND)
    message("Error: SDL_mixer library not found, even though it was selected to be included")
  ENDIF(SDLMIXER_FOUND)
ENDIF(CORSIX_TH_USE_SDL_MIXER)

# Find OpenGL
IF(CORSIX_TH_USE_OGL_RENDERER)
  FIND_PACKAGE(OpenGL REQUIRED)
  IF(OPENGL_FOUND)
    TARGET_LINK_LIBRARIES(CorsixTH ${OPENGL_gl_LIBRARY})
    INCLUDE_DIRECTORIES(${OPENGL_INCLUDE_DIR})
    message("  OpenGL found")
  ELSE(OPENGL_FOUND)
    message(FATAL_ERROR "Error: OpenGL library not found, it is required to build (consider changing choice of renderer)")
  ENDIF(OPENGL_FOUND)
ENDIF(CORSIX_TH_USE_OGL_RENDERER)

# Declaration of the install process
install(TARGETS CorsixTH RUNTIME DESTINATION CorsixTH)
install(DIRECTORY Lua DESTINATION CorsixTH PATTERN "*svn" EXCLUDE)
install(DIRECTORY Bitmap DESTINATION CorsixTH PATTERN "*svn" EXCLUDE)
install(DIRECTORY Levels DESTINATION CorsixTH PATTERN "*svn" EXCLUDE)
install(FILES config.txt DESTINATION CorsixTH )
install(FILES CorsixTH.lua DESTINATION CorsixTH )
install(FILES LICENSE.txt DESTINATION CorsixTH )

