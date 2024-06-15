# Cmake File for CorsixTH
# OPTIONS AVAILABLE:
# Any of the following: (default)
#   - WITH_AUDIO      : Activate sound (yes)
#   - WITH_FREETYPE2  : Active support for non-Latin script alphabets (yes)
#   - WITH_MOVIES     : Activate movies (requires with_audio, FFmpeg) (yes)
#   - WITH_LUAJIT     : Use LuaJIT instead of Lua (must specify library path) (no)
#   - USE_SOURCE_DATADIRS : Use the source directory for loading resources. Incompatible with the install target (no)
#   - SEARCH_LOCAL_DATADIRS : Search resources in the working directory and the
#       program directory where the executable stores. Makes the executable
#       portable (yes for Apple)

#   - WITH_VLD        : Build with Visual Leak Detector (requires Visual Studio) (no)
#   - USE_PRECOMPILED_DEPS : Use precompiled dependencies on *nix (no)
#   - WITH_LUAROCKS : Install required luarocks in the macOS app (requires luarocks)

#   - ENABLE_UNIT_TESTS : Enable Unit Testing Target (requires Catch2) (no)
#   - BUILD_ANIMVIEW : Generate AnimView build files (no)
#   - BUILD_TOOLS : Generate cli tools

cmake_minimum_required(VERSION 3.15)

# Define our options
option(BUILD_CORSIXTH "Builds the main game" ON)
option(WITH_AUDIO "Activate sound" ON)
option(WITH_FREETYPE2 "Enhanced font support" ON)
option(WITH_MOVIES "Activate in game movies" ON)
option(WITH_LUAJIT "Use LuaJIT instead of Lua" OFF)
option(WITH_UPDATE_CHECK "Check for new versions" ON)
option(USE_SOURCE_DATADIRS "Use the source directory for loading resources. Incompatible with the install target" OFF)
option(ENABLE_UNIT_TESTS "Enables Unit Testing Targets" OFF)
option(BUILD_ANIMVIEW "Build the animation viewer as part of the build process" OFF)
option(BUILD_TOOLS "Build additional CLI tools (rnc_decode)" OFF)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/CMake)

if(WITH_MOVIES)
  list(APPEND VCPKG_MANIFEST_FEATURES "movies")
endif()
if(BUILD_ANIMVIEW)
  list(APPEND VCPKG_MANIFEST_FEATURES "animview")
endif()
if(WITH_UPDATE_CHECK)
  list(APPEND VCPKG_MANIFEST_FEATURES "updatecheck")
endif()

project(CorsixTH_Top_Level)

if(MINGW)
  set(CMAKE_EXE_LINKER_FLAGS "-static-libgcc -static-libstdc++")
endif()

include(CheckIncludeFiles)

set(CORSIX_TH_DONE_TOP_LEVEL_CMAKE ON)

if(APPLE)
  set(SEARCH_LOCAL_DATADIRS_DEFAULT ON)
else()
  set(SEARCH_LOCAL_DATADIRS_DEFAULT OFF)
endif()

option(SEARCH_LOCAL_DATADIRS
  "Search resources in the working directory and the program directory where the executable stores."
  ${SEARCH_LOCAL_DATADIRS_DEFAULT})

if(MSVC)
  option(WITH_VLD "Build with Visual Leak Detector for Visual Studio" OFF)
endif()
# Dependency management
if(UNIX AND CMAKE_COMPILER_IS_GNU)
  option(USE_PRECOMPILED_DEPS "Use Precompiled Dependencies" OFF) # Make *nix systems opt in
endif()

if(APPLE)
  option(WITH_LUAROCKS "Install required luarocks in the app" OFF)
endif()

if(WITH_AUDIO)
  set(CORSIX_TH_USE_SDL_MIXER ON)
  message("Note: SDL audio is enabled (default)")
else()
  set(CORSIX_TH_USE_SDL_MIXER OFF)
  message("Note: SDL audio is disabled")
endif()

if(WITH_MOVIES)
  if(WITH_AUDIO)
    set(CORSIX_TH_USE_FFMPEG ON)
    message("Note: FFmpeg video is enabled (default)")
  else()
    set(CORSIX_TH_USE_FFMPEG OFF)
    message("Note: FFmpeg video disabled since it requires SDL audio.")
  endif()
else()
  set(CORSIX_TH_USE_FFMPEG OFF)
  message("Note: FFmpeg video is disabled")
endif()

if(WITH_FREETYPE2)
  set(CORSIX_TH_USE_FREETYPE2 ON)
  message("Note: FreeType2 is enabled (default)")
else()
  set(CORSIX_TH_USE_FREETYPE2 OFF)
  message("Note: FreeType2 is disabled")
endif()

if(WITH_UPDATE_CHECK)
  message("Note: Update check is enabled (default)")
else()
  message("Note: Update check is disabled")
endif()

if(VCPKG_TARGET_TRIPLET AND NOT WITH_LUAROCKS)
  set(CORSIX_TH_LINK_LUA_MODULES ON)
else()
  set(CORSIX_TH_LINK_LUA_MODULES OFF)
endif()

if(MSVC)
  if(WITH_VLD)
    set(CORSIX_TH_USE_VLD ON)
    message("Note: Visual Leak Detector is enabled")
  else()
    set(CORSIX_TH_USE_VLD OFF)
    message("Note: Visual Leak Detector is disabled (default)")
  endif()
else()
  set(CORSIX_TH_USE_VLD OFF)
endif()

# Get precompiled dependencies before running the various find modules
if(USE_PRECOMPILED_DEPS)
  message("Note: Using precompiled dependencies.")
  include(PrecompiledDeps)
endif()

include(GNUInstallDirs)

# Include individual projects
message("")

message("Building common libraries")
add_subdirectory("libs")

# We build CorsixTH if BUILD_CORSIXTH is set. This is set by default and should generally be set.
if(BUILD_CORSIXTH)
  message("Building CorsixTH")
  add_subdirectory(CorsixTH)
  set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT CorsixTH)
endif()

if(BUILD_ANIMVIEW)
  message("Building AnimView")
  add_subdirectory(AnimView)
endif()

if(BUILD_TOOLS)
  message("Building Tools")
  add_subdirectory("tools")
endif()

message("")

# Documentation generation, construct 'doc' target
include(GenerateDoc)
