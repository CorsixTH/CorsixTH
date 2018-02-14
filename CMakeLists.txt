# Cmake File for CorsixTH
# OPTIONS AVAILABLE:
# At most, one of the following:
#   - WITH_SDL     : Activate SDL Renderer (default)
# Any of the following:
#   - WITH_AUDIO   : Activate Sound (enabled by default)
#   - WITH_FREETYPE2
#   - WITH_MOVIES  : Activate movies (requires Sound)
#   - BUILD_ANIMVIEWER
#   - WITH_LUAJIT  : Whether to use LuaJIT 2 instead of Lua51 (default is LuaJIT 2)
#   - WITH_LIBAV   : Whether to use LibAV (as opposed to FFMEPG) when building movies
#   - WITH_VLD     : Build with Visual Leak Detector (requires Visual Studio)

cmake_minimum_required(VERSION 3.2)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/CMake)

if(CMAKE_GENERATOR MATCHES "^Visual Studio 14 2015" OR CMAKE_GENERATOR MATCHES "^Visual Studio 15 2017")
  option(USE_VCPKG_DEPS "Build vcpkg dependencies locally" OFF)
endif()

if(USE_VCPKG_DEPS)
  message("Note: Using locally built vcpkg dependencies.")
  include(VcpkgDeps)
endif()

project(CorsixTH_Top_Level)

include(CheckCXXCompilerFlag)
check_cxx_compiler_flag("-std=c++11" COMPILER_SUPPORTS_CXX11)
check_cxx_compiler_flag("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
if(COMPILER_SUPPORTS_CXX11)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
elseif(COMPILER_SUPPORTS_CXX0X)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
endif()

if(MINGW)
  set(CMAKE_EXE_LINKER_FLAGS "-static-libgcc -static-libstdc++")
endif()

include(CheckIncludeFiles)

set(CORSIX_TH_DONE_TOP_LEVEL_CMAKE ON)

# Dependency management
if(UNIX AND CMAKE_COMPILER_IS_GNU)
  option(USE_PRECOMPILED_DEPS "Use Precompiled Dependencies" OFF) # Make *nix systems opt in
endif()

# Define our options
option(USE_SOURCE_DATADIRS "Use the source directory for loading resources. Incompatible with the install target" OFF)
option(WITH_SDL "Activate SDL Renderer" ON) # our default option
option(WITH_AUDIO "Activate Sound" ON) # enabled by default
option(WITH_MOVIES "Activate in game movies" ON)
option(WITH_FREETYPE2 "Enhanced Font Support" ON)
option(WITH_LUAJIT "Use LuaJIT instead of Lua" OFF)
option(WITH_LIBAV "Use LibAV instead of FFmpeg" OFF)
option(BUILD_ANIMVIEWER "Build the animation viewer as part of the build process" OFF)
if(MSVC)
  option(WITH_VLD "Build with Visual Leak Detector for Visual Studio" OFF)
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
    if(WITH_LIBAV)
      set(CORSIX_TH_USE_FFMPEG OFF)
      set(CORSIX_TH_USE_LIBAV ON)
      message("Note: LibAV video is enabled")
    else()
      set(CORSIX_TH_USE_FFMPEG ON)
      set(CORSIX_TH_USE_LIBAV OFF)
      message("Note: FFMPEG video is enabled (default)")
    endif()
  else()
    set(CORSIX_TH_USE_FFMPEG OFF)
    set(CORSIX_TH_USE_LIBAV OFF)
    message("Note: FFMPEG video disabled since it requires SDL audio.")
  endif()
else()
  set(CORSIX_TH_USE_FFMPEG OFF)
  set(CORSIX_TH_USE_LIBAV OFF)
  message("Note: FFMPEG video is disabled")
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
# We always build CorsixTH otherwise we would miss the generated header
message("Building CorsixTH")
add_subdirectory(CorsixTH)

if(BUILD_ANIMVIEWER)
  message("Building AnimView")
  add_subdirectory(AnimView)
endif()

# Documentation generation, construct 'doc' target (or a message it is disabled).

# Try to find 'lua'
if(WITH_LUAJIT)
  set(LUA_PROGRAM_NAMES luajit-2.0.3 luajit)
else()
  set(LUA_PROGRAM_NAMES lua53 lua5.3 lua-5.3 lua52 lua5.2 lua-5.2 lua51 lua5.1 lua-5.1 lua)
endif()

find_program(LUA_PROGRAM_PATH ${LUA_PROGRAM_NAMES}
  PATHS
    ENV LUA_DIR
    /opt
    /opt/local
    ~
    ~/Library/Frameworks
    /Library/Frameworks
)

if(LUA_PROGRAM_PATH)
  set(LUA_PROGRAM_FOUND TRUE)
else()
  set(LUA_PROGRAM_FOUND FALSE)
endif()

include(GenerateDoc)
