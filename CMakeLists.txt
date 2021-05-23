# Cmake File for CorsixTH
# OPTIONS AVAILABLE:
# Any of the following: (default)
#   - WITH_AUDIO      : Activate sound (yes)
#   - WITH_FREETYPE2  : Active support for non-Latin script alphabets (yes)
#   - WITH_MOVIES     : Activate movies (requires with_audio, FFmpeg) (yes)
#   - WITH_LUAJIT     : Use LuaJIT instead of Lua (must specify library path) (no)
#   - WITH_LIBAV      : Use Libav instead of FFmpeg when building movies (no)
#   - USE_SOURCE_DATADIRS : Use the source directory for loading resources. Incompatible with the install target (no)

#   - WITH_VLD        : Build with Visual Leak Detector (requires Visual Studio) (no)
#   - USE_PRECOMPILED_DEPS : Use precompiled dependencies on *nix (no)
#   - USE_VCPKG_DEPS : Build vcpkg dependencies locally (requires Visual Studio) (no)
#   - WITH_LUAROCKS : Install required luarocks in the macOS app (requires luarocks)

#   - ENABLE_UNIT_TESTS : Enable Unit Testing Target (requires Catch2) (no)
#   - BUILD_ANIMVIEW : Generate AnimViewer build files (no)

cmake_minimum_required(VERSION 3.5)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/CMake)

option(USE_VCPKG_DEPS "Build vcpkg dependencies locally" OFF)

if(USE_VCPKG_DEPS)
  # This must be before the project for the tool-chain to work correctly
  message("Note: Using locally built vcpkg dependencies.")
  include(VcpkgDeps)
endif()

project(CorsixTH_Top_Level)

if(MINGW)
  set(CMAKE_EXE_LINKER_FLAGS "-static-libgcc -static-libstdc++")
endif()

include(CheckIncludeFiles)

set(CORSIX_TH_DONE_TOP_LEVEL_CMAKE ON)

# Define our options
option(BUILD_CORSIXTH "Builds the main game" ON)
option(WITH_AUDIO "Activate sound" ON)
option(WITH_FREETYPE2 "Enhanced font support" ON)
option(WITH_MOVIES "Activate in game movies" ON)
option(WITH_LUAJIT "Use LuaJIT instead of Lua" OFF)
option(WITH_LIBAV "Use LibAV instead of FFmpeg" OFF)
option(USE_SOURCE_DATADIRS "Use the source directory for loading resources. Incompatible with the install target" OFF)

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

option(ENABLE_UNIT_TESTS "Enables Unit Testing Targets" OFF)
option(BUILD_ANIMVIEW "Build the animation viewer as part of the build process" OFF)

if(WITH_AUDIO)
  set(CORSIX_TH_USE_SDL_MIXER ON)
  message("Note: SDL audio is enabled (default)")
else()
  set(CORSIX_TH_USE_SDL_MIXER OFF)
  message("Note: SDL audio is disabled")
endif()

if(WITH_MOVIES)
  if(WITH_AUDIO)
    if(WITH_LIBAV)
      set(CORSIX_TH_USE_FFMPEG OFF)
      set(CORSIX_TH_USE_LIBAV ON)
      message("Note: LibAV video is enabled")
    else()
      set(CORSIX_TH_USE_FFMPEG ON)
      set(CORSIX_TH_USE_LIBAV OFF)
      message("Note: FFmpeg video is enabled (default)")
    endif()
  else()
    set(CORSIX_TH_USE_FFMPEG OFF)
    set(CORSIX_TH_USE_LIBAV OFF)
    message("Note: FFmpeg video disabled since it requires SDL audio.")
  endif()
else()
  set(CORSIX_TH_USE_FFMPEG OFF)
  set(CORSIX_TH_USE_LIBAV OFF)
  message("Note: FFmpeg video is disabled")
endif()

if(WITH_FREETYPE2)
  set(CORSIX_TH_USE_FREETYPE2 ON)
  message("Note: FreeType2 is enabled (default)")
else()
  set(CORSIX_TH_USE_FREETYPE2 OFF)
  message("Note: FreeType2 is disabled")
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

# We always build CorsixTH otherwise we would miss the generated header
if(BUILD_CORSIXTH)
  message("Building CorsixTH")
  add_subdirectory(CorsixTH)
endif()

if(BUILD_ANIMVIEW)
  message("Building AnimView")
  add_subdirectory(AnimView)
endif()
message("")

# Documentation generation, construct 'doc' target
include(GenerateDoc)
