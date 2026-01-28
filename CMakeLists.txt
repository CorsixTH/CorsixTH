# Cmake File for CorsixTH
# OPTIONS AVAILABLE:
# Any of the following: (default)

# CorsixTH Features and behaviour
#   - WITH_FONT       : Path of a font that will be used if the user does not set one (empty, Arial on macOS)
#   - WITH_MOVIES     : Activate movies (requires with_audio, FFmpeg) (yes)
#   - WITH_UPDATE_CHECK : Activates support to check for new version on launch (requires libcurl) (yes)
#   - USE_SOURCE_DATADIRS : Use the source directory for loading resources. Incompatible with the install target (no)
#   - SEARCH_LOCAL_DATADIRS : Search resources in the working directory and the
#       program directory where the executable stores. Makes the executable
#       portable (yes for Apple)
#   - WITH_MIDI_DEVICE : Enable MIDI device support (yes)

# Dependency resolution
#   - WITH_LUAJIT     : Use LuaJIT instead of Lua (must specify library path) (no)
#   - WITH_LUAROCKS : Install required luarocks in the macOS app (requires luarocks)
#   - FETCH_CATCH2: Use FetchContent to obtain Catch2 if ENABLE_UNIT_TESTS=yes

# Tests and debug options
#   - ENABLE_UNIT_TESTS : Enable Unit Testing Target (requires Catch2) (no)
#   - ENABLE_SANITIZERS : Build with AddressSanitizer (ASan) and UndefinedBehaviorSanitizer (UBSan) enabled (no)

# Additional build targets
#   - BUILD_ANIMVIEW : Generate AnimView build files (no)
#   - BUILD_TOOLS : Generate cli tools

cmake_minimum_required(VERSION 3.14)

# Define our options
option(BUILD_CORSIXTH "Builds the main game" ON)
option(WITH_MOVIES "Activate in game movies" ON)
option(WITH_LUAJIT "Use LuaJIT instead of Lua" OFF)
option(WITH_UPDATE_CHECK "Check for new versions" ON)
option(WITH_MIDI_DEVICE "Enable MIDI device support" ON)
option(USE_SOURCE_DATADIRS "Use the source directory for loading resources. Incompatible with the install target" OFF)
option(ENABLE_UNIT_TESTS "Enables Unit Testing Targets" OFF)
option(BUILD_ANIMVIEW "Build the animation viewer as part of the build process" OFF)
option(BUILD_TOOLS "Build additional CLI tools (rnc_decode)" OFF)
option(ENABLE_SANITIZERS "Build with ASan and UBSan enabled" OFF)

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
if(WITH_MIDI_DEVICE)
  list(APPEND VCPKG_MANIFEST_FEATURES "midi")
endif()
if(ENABLE_UNIT_TESTS)
  list(APPEND VCPKG_MANIFEST_FEATURES "catch2")
endif()

project(CorsixTH_Top_Level)

if(ENABLE_UNIT_TESTS)
  enable_testing()
endif()

if(MINGW)
  set(CMAKE_EXE_LINKER_FLAGS "-static-libgcc -static-libstdc++")
endif()

if(ENABLE_SANITIZERS)
  if(MSVC)
    # https://learn.microsoft.com/en-us/cpp/build/reference/fsanitize?view=msvc-170
    add_compile_options(/fsanitize=address)
  else()
    add_compile_options(-fsanitize=address,undefined)
    add_link_options(-fsanitize=address,undefined)
  endif()
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

if(APPLE)
  set(WITH_FONT_DEFAULT "/Library/Fonts/Arial Unicode.ttf")
else()
  set(WITH_FONT_DEFAULT "")
endif()
set(WITH_FONT ${WITH_FONT_DEFAULT} CACHE FILEPATH "Use this font if one is not set in the game settings")

# Dependency management
if(APPLE)
  option(WITH_LUAROCKS "Install required luarocks in the app" OFF)
endif()

if(WITH_MOVIES)
  set(CORSIX_TH_USE_FFMPEG ON)
  message("Note: FFmpeg video is enabled (default)")
else()
  set(CORSIX_TH_USE_FFMPEG OFF)
  message("Note: FFmpeg video is disabled")
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
