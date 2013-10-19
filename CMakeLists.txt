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

PROJECT(CorsixTH_Top_Level)
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
SET(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/CMake)
IF(MSVC)
  SET(CMAKE_EXE_LINKER_FLAGS_RELEASE "/INCREMENTAL" CACHE STRING "Linker flags for release" FORCE)
  SET(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL "/INCREMENTAL" CACHE STRING "Linker flags for minsizerel" FORCE)
ENDIF(MSVC)
INCLUDE(CheckIncludeFiles)
SET(CORSIX_TH_DONE_TOP_LEVEL_CMAKE ON)

IF (APPLE)
	SET(CMAKE_OSX_DEPLOYMENT_TARGET 10.5)
ENDIF()

# Define our options
OPTION(WITH_OPENGL "Activate OpenGL Renderer" OFF)
OPTION(WITH_DIRECTX "Activate DirectX Renderer" OFF)
OPTION(WITH_SDL "Activate SDL Renderer" ON) # our default option
OPTION(WITH_AUDIO "Activate Sound" ON) # enabled by default
OPTION(WITH_MOVIES "Activate in game movies" ON)
OPTION(WITH_FREETYPE2 "Enhanced Font Support" ON)
OPTION(WITH_LUAJIT "Use LuaJIT instead of Lua" ON)
OPTION(BUILD_ANIMVIEWER "Build the animation viewer as part of the build process" OFF)
OPTION(BUILD_MAPEDITOR "Build the map editor as part of the build process" OFF)

# Option handling
IF(WITH_OPENGL)
  SET(CORSIX_TH_USE_DX9_RENDERER OFF)
  SET(CORSIX_TH_USE_SDL_RENDERER OFF)
  SET(CORSIX_TH_USE_OGL_RENDERER ON)
  MESSAGE("Note: Using OpenGL as renderer")
ENDIF(WITH_OPENGL)

IF(WITH_DIRECTX)
# DirectX will only work with win32. If we're not win32, we use OpenGL instead
IF(WIN32)
  SET(CORSIX_TH_USE_DX9_RENDERER ON)
  SET(CORSIX_TH_USE_SDL_RENDERER OFF)
  SET(CORSIX_TH_USE_OGL_RENDERER OFF)
  MESSAGE("Note: Using DirectX as renderer")
ELSE()
  SET(CORSIX_TH_USE_DX9_RENDERER OFF)
  SET(CORSIX_TH_USE_SDL_RENDERER OFF)
  SET(CORSIX_TH_USE_OGL_RENDERER ON)
  MESSAGE("Note: Cannot use DirectX due to OS, using OpenGL instead")
ENDIF(WIN32)
ENDIF(WITH_DIRECTX)

IF(NOT WITH_OPENGL)
IF(NOT WITH_DIRECTX)
IF(WITH_SDL)
  SET(CORSIX_TH_USE_DX9_RENDERER OFF)
  SET(CORSIX_TH_USE_SDL_RENDERER ON)
  SET(CORSIX_TH_USE_OGL_RENDERER OFF)
  MESSAGE("Note: Using SDL as renderer (default)")
ENDIF(WITH_SDL)
ENDIF(NOT WITH_DIRECTX)
ENDIF(NOT WITH_OPENGL)

IF(WITH_AUDIO)
  SET(CORSIX_TH_USE_SDL_MIXER ON)
  MESSAGE("Note: SDL audio is enabled (default)")
ELSE()
  SET(CORSIX_TH_USE_SDL_MIXER OFF)
  MESSAGE("Note: SDL audio is disabled")
ENDIF(WITH_AUDIO)

IF(WITH_MOVIES)
  IF(WITH_AUDIO)
    SET(CORSIX_TH_USE_FFMPEG ON)
    MESSAGE("Note: FFMPEG video is enabled (default)")
  ELSE()
    SET(CORSIX_TH_USE_FFMPEG OFF)
    MESSAGE("Note: FFMPEG video disabled since it requires SDL audio.")
  ENDIF(WITH_AUDIO)
ELSE()
  SET(CORSIX_TH_USE_FFMPEG OFF)
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
