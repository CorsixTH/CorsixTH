# Cmake File for CorsixTH
# OPTIONS AVAILABLE:
# At most, one of the following:
#   - WITH_SDL     : Activate SDL Renderer (default)
#   - WITH_OPENGL  : Activate OpenGL Renderer
#   - WITH_DIRECTX : Activate DirectX Renderer (Windows only)
# Any of the following:
#   - WITH_AUDIO   : Activate Sound (enabled by default)
#   - WITH_FREETYPE2
#   - WITH_MOVIES  : Activate movies (requires Sound)
#   - BUILD_ANIMVIEWER
#   - BUILD_MAPEDITOR
#   - WITH_LUAJIT  : Whether to use LuaJIT 2 instead of Lua51 (default is LuaJIT 2)
#   - WITH_LIBAV  : Whether to use LibAV (as opposed to FFMEPG) when building movies

PROJECT(CorsixTH_Top_Level)
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
SET(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/CMake)
IF(MSVC)
  SET(CMAKE_EXE_LINKER_FLAGS_RELEASE "/INCREMENTAL" CACHE STRING "Linker flags for release" FORCE)
  SET(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL "/INCREMENTAL" CACHE STRING "Linker flags for minsizerel" FORCE)
ENDIF(MSVC)
IF (MINGW)
  set(CMAKE_EXE_LINKER_FLAGS "-static-libgcc -static-libstdc++")
ENDIF(MINGW)
INCLUDE(CheckIncludeFiles)
SET(CORSIX_TH_DONE_TOP_LEVEL_CMAKE ON)

IF(APPLE)
  SET(CMAKE_OSX_DEPLOYMENT_TARGET 10.7)
  SET(CMAKE_OSX_ARCHITECTURES x86_64)
ENDIF()

# Define our options
OPTION(WITH_SDL "Activate SDL Renderer" ON) # our default option
OPTION(WITH_AUDIO "Activate Sound" ON) # enabled by default
OPTION(WITH_MOVIES "Activate in game movies" ON)
OPTION(WITH_FREETYPE2 "Enhanced Font Support" ON)
OPTION(WITH_LUAJIT "Use LuaJIT instead of Lua" ON)
OPTION(WITH_LIBAV "Use LibAV instead of FFmpeg" OFF)
OPTION(BUILD_ANIMVIEWER "Build the animation viewer as part of the build process" OFF)
OPTION(BUILD_MAPEDITOR "Build the map editor as part of the build process" OFF)

IF(WITH_AUDIO)
  SET(CORSIX_TH_USE_SDL_MIXER ON)
  MESSAGE("Note: SDL audio is enabled (default)")
ELSE()
  SET(CORSIX_TH_USE_SDL_MIXER OFF)
  MESSAGE("Note: SDL audio is disabled")
ENDIF(WITH_AUDIO)

IF(WITH_MOVIES)
  IF(WITH_AUDIO)
    IF(WITH_LIBAV)
      SET(CORSIX_TH_USE_FFMPEG OFF)
      SET(CORSIX_TH_USE_LIBAV ON)
      MESSAGE("Note: LibAV video is enabled")
    ELSE()
      SET(CORSIX_TH_USE_FFMPEG ON)
      SET(CORSIX_TH_USE_LIBAV OFF)
      MESSAGE("Note: FFMPEG video is enabled (default)")
    ENDIF(WITH_LIBAV)
  ELSE()
    SET(CORSIX_TH_USE_FFMPEG OFF)
    SET(CORSIX_TH_USE_LIBAV OFF)
    MESSAGE("Note: FFMPEG video disabled since it requires SDL audio.")
  ENDIF(WITH_AUDIO)
ELSE()
  SET(CORSIX_TH_USE_FFMPEG OFF)
  SET(CORSIX_TH_USE_LIBAV OFF)
  MESSAGE("Note: FFMPEG video is disabled")
ENDIF(WITH_MOVIES)

IF(WITH_FREETYPE2)
  SET(CORSIX_TH_USE_FREETYPE2 ON)
  MESSAGE("Note: FreeType2 is enabled (default)")
ELSE()
  SET(CORSIX_TH_USE_FREETYPE2 OFF)
  MESSAGE("Note: FreeType2 is disabled")
ENDIF(WITH_FREETYPE2)

# Environment handling

CHECK_INCLUDE_FILES(stdint.h CORSIX_TH_HAS_STDINT_H)
CHECK_INCLUDE_FILES(malloc.h CORSIX_TH_HAS_MALLOC_H)
CHECK_INCLUDE_FILES(alloca.h CORSIX_TH_HAS_ALLOCA_H)
CHECK_INCLUDE_FILES(inttypes.h CORSIX_TH_HAS_INTTYPES_H)

# Include individual projects
message("")
# We always build CorsixTH otherwise we would miss the generated header
message("Building CorsixTH")
add_subdirectory(CorsixTH)

IF(BUILD_ANIMVIEWER)
  message("Building AnimView")
  add_subdirectory(AnimView)
ENDIF(BUILD_ANIMVIEWER)

IF(BUILD_MAPEDITOR)
  IF(WITH_OPENGL)
    message("Building MapEdit")
    add_subdirectory(MapEdit)
  ELSE(WITH_OPENGL)
    message(FATAL_ERROR "The map editor can only be built when using OpenGL as renderer")
  ENDIF(WITH_OPENGL)
ENDIF(BUILD_MAPEDITOR)
