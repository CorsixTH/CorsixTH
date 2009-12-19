# Project Declaration
PROJECT(CorsixTH)

# Basic platform dependant stuff
IF(UNIX)
  IF(APPLE)
    # fruit goes here
  ELSE(APPLE)
    # regular unix/linux
  ENDIF(APPLE)
ELSE()
  IF(WIN32)
    # Win32 specific
    
    # We want to bind against the very latest versions of the MSVC runtimes
    add_definitions(/D "_BIND_TO_CURRENT_VCLIBS_VERSION=1")
  ELSE(WIN32)
    # other OS (not UNIX, not 32/64 bit Windows)
  ENDIF(WIN32)
ENDIF(UNIX)

# Finding libraries

# Find SDL
FIND_PACKAGE(SDL REQUIRED)
INCLUDE_DIRECTORIES(${SDL_INCLUDE_DIR})
IF(WIN32)
LINK_LIBRARIES (
  # The builtin SDL_main is used on Win32
  ${SDL_LIBRARY}
)
ELSE()
LINK_LIBRARIES (
  SDLmain # Not included in SDL_LIBRARY variable
  ${SDL_LIBRARY}
)
ENDIF(WIN32)

# Find SDL_mixer
IF(CORSIX_TH_USE_SDL_MIXER)
  FIND_PACKAGE(SDL_mixer REQUIRED)
  LINK_LIBRARIES(${SDLMIXER_LIBRARY})
  INCLUDE_DIRECTORIES(${SDLMIXER_INCLUDE_DIR})
ENDIF(CORSIX_TH_USE_SDL_MIXER)

# Find OpenGL
IF(CORSIX_TH_USE_OGL_RENDERER)
FIND_PACKAGE(OpenGL REQUIRED)
LINK_LIBRARIES(${OPENGL_gl_LIBRARY})
INCLUDE_DIRECTORIES(${OPENGL_INCLUDE_DIR})
ENDIF(CORSIX_TH_USE_OGL_RENDERER)

# Find Lua
FIND_PACKAGE(Lua51 REQUIRED)
LINK_LIBRARIES(${LUA_LIBRARY})
INCLUDE_DIRECTORIES(${LUA_INCLUDE_DIR})

# Modify the config.h based upon our selection of options
IF("${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}" GREATER 2.6)
# CMake 2.8 seems to interpret both <in-file> and <out-file> as relative to
# this directory.
CONFIGURE_FILE(Src/config.h.in Src/config.h)
ELSE()
# CMake 2.6 seems to interpret <in-file> as relative to this directory, but
# <out-file> as relative to the top-level directory.
CONFIGURE_FILE(Src/config.h.in CorsixTH/Src/config.h)
ENDIF("${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}" GREATER 2.6)

# Generate source files list
# Note: Done after generating config.h
FILE(GLOB_RECURSE corsixth_source_files
    Src/*.cpp
    Src/*.c
    Src/*.h
    Lua/api_version.lua
    CorsixTH.rc
    ../LFS/lfs.c
)

# Declaration of the executable
add_executable( CorsixTH ${corsixth_source_files} )
install(TARGETS CorsixTH RUNTIME DESTINATION CorsixTH)
install(DIRECTORY Lua DESTINATION CorsixTH PATTERN "*svn" EXCLUDE)
install(DIRECTORY Bitmap DESTINATION CorsixTH PATTERN "*svn" EXCLUDE)
install(FILES config.txt DESTINATION CorsixTH )
install(FILES CorsixTH.lua DESTINATION CorsixTH )
install(FILES LICENSE.txt DESTINATION CorsixTH )

