# Cmake File for CorsixTH
# OPTIONS AVAILABLE:
# At most, one of the following:
#   - WITH_SDL     : Activate SDL Renderer (default)
#   - WITH_OPENGL  : Activate OpenGL Renderer
#   - WITH_DIRECTX : Activate DirectX Renderer (Windows only)
# Any of the following:
#   - WITH_AUDIO   : Activate Sound (enabled by default)

CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
INCLUDE(CheckIncludeFiles)

# Project Declaration
PROJECT(CorsixTH)

# Generate source files list
FILE(GLOB_RECURSE source_files
    CorsixTH/Src/*.cpp
    CorsixTH/Src/*.c
    CorsixTH/Src/*.h
    CorsixTH/Lua/api_version.lua
    CorsixTH/CorsixTH.rc
    LFS/lfs.c
)
CHECK_INCLUDE_FILES(stdint.h CORSIX_TH_HAS_STDINT_H)

# Define our options
OPTION(WITH_OPENGL "Activate OpenGL Renderer" OFF)
OPTION(WITH_DIRECTX "Activate DirectX Renderer" OFF)
OPTION(WITH_SDL "Activate SDL Renderer" ON) # our default option
OPTION(WITH_AUDIO "Activate Sound" ON) # enabled by default

# Include current directory to CMAKE_MODULE_PATH to help cmake find FindLua5.1.cmake
SET(
  CMAKE_MODULE_PATH ".;${CMAKE_MODULE_PATH}"
)

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

# Option handling
IF(WITH_OPENGL)
  SET(CORSIX_TH_USE_DX9_RENDERER OFF)
  SET(CORSIX_TH_USE_SDL_RENDERER OFF)
  SET(CORSIX_TH_USE_OGL_RENDERER ON)
  MESSAGE(Note: " Using OpenGL as renderer")
ENDIF(WITH_OPENGL)

IF(WITH_DIRECTX)
# DirectX will only work with win32. If we're not win32, we use OpenGL instead
IF(WIN32)
  SET(CORSIX_TH_USE_DX9_RENDERER ON)
  SET(CORSIX_TH_USE_SDL_RENDERER OFF)
  SET(CORSIX_TH_USE_OGL_RENDERER OFF)
  MESSAGE(Note: " Using DirectX as renderer")
ELSE()
  SET(CORSIX_TH_USE_DX9_RENDERER OFF)
  SET(CORSIX_TH_USE_SDL_RENDERER OFF)
  SET(CORSIX_TH_USE_OGL_RENDERER ON)
  MESSAGE(Note: " Cannot use DirectX due to OS, using OpenGL instead")
ENDIF(WIN32)
ENDIF(WITH_DIRECTX)

IF(WITH_SDL)
  SET(CORSIX_TH_USE_DX9_RENDERER OFF)
  SET(CORSIX_TH_USE_SDL_RENDERER ON)
  SET(CORSIX_TH_USE_OGL_RENDERER OFF)
  MESSAGE(Note: " Using SDL as renderer (default)")
ENDIF(WITH_SDL)

IF(WITH_AUDIO)
  FIND_PACKAGE(SDL_mixer REQUIRED)
  LINK_LIBRARIES(${SDLMIXER_LIBRARY})
  INCLUDE_DIRECTORIES(${SDLMIXER_INCLUDE_DIR})
  SET(CORSIX_TH_USE_SDL_MIXER ON)
  MESSAGE(Note: " SDL audio is enabled (default)")
ELSE()
  SET(CORSIX_TH_USE_SDL_MIXER OFF)
  MESSAGE(Note: " SDL audio is disabled")
ENDIF(WITH_AUDIO)

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

# Find Lua
FIND_PACKAGE(Lua51 REQUIRED)
LINK_LIBRARIES(${LUA_LIBRARY})
INCLUDE_DIRECTORIES(${LUA_INCLUDE_DIR})


# Modify the config.h based upon our selection of options
CONFIGURE_FILE(CorsixTH/Src/config.h.in CorsixTH/Src/config.h)


# Declaration of the executable
add_executable( CorsixTH ${source_files} )
set_target_properties(CorsixTH PROPERTIES RUNTIME_OUTPUT_DIRECTORY CorsixTH)
IF(WIN32)
  # Release-mode executables should be created at CorsixTH/CorsixTH.exe, not CorsixTH/Release/CorsixTH.exe
  set_target_properties(CorsixTH PROPERTIES OUTPUT_NAME_RELEASE ../CorsixTH)
ENDIF(UNIX)
install(DIRECTORY CorsixTH/Lua DESTINATION . PATTERN "svn" EXCLUDE)
install(DIRECTORY CorsixTH/Bitmap DESTINATION . PATTERN "svn" EXCLUDE)
install(FILES CorsixTH/config.txt DESTINATION . )
install(FILES CorsixTH/CorsixTH.lua DESTINATION . )
install(FILES CorsixTH/LICENSE.txt DESTINATION . )
