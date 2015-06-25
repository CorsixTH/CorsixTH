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
#   - WITH_LIBAV   : Whether to use LibAV (as opposed to FFMEPG) when building movies
#   - WITH_VLD     : Build with Visual Leak Detector (requires Visual Studio)

PROJECT(CorsixTH_Top_Level)
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
SET(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/CMake)
INCLUDE(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
IF(COMPILER_SUPPORTS_CXX11)
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
ELSEIF(COMPILER_SUPPORTS_CXX0X)
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
ENDIF(COMPILER_SUPPORTS_CXX11)
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
IF(MSVC)
  OPTION(WITH_VLD "Build with Visual Leak Detector for Visual Studio" OFF)
ENDIF(MSVC)

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

IF(MSVC)
  IF(WITH_VLD)
    SET(CORSIX_TH_USE_VLD ON)
    MESSAGE("Note: Visual Leak Detector is enabled")
  ELSE()
    SET(CORSIX_TH_USE_VLD OFF)
    MESSAGE("Note: Visual Leak Detector is disabled (default)")
  ENDIF(WITH_VLD)
ELSE()
  SET(CORSIX_TH_USE_VLD OFF)
ENDIF(MSVC)

# Environment handling

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

# Documentation generation, construct 'doc' target (or a message it is disabled).

# Try to find 'lua'
IF (WITH_LUAJIT)
    SET (LUA_PROGRAM_NAMES luajit-2.0.3 luajit)
ELSE (WITH_LUAJIT)
    SET (LUA_PROGRAM_NAMES lua53 lua5.3 lua-5.3 lua52 lua5.2 lua-5.2 lua51 lua5.1 lua-5.1 lua)
ENDIF(WITH_LUAJIT)

find_program (LUA_PROGRAM_PATH ${LUA_PROGRAM_NAMES}
  PATHS
    ENV LUA_DIR
    /opt
    /opt/local
    ~
    ~/Library/Frameworks
    /Library/Frameworks
)

IF (LUA_PROGRAM_PATH)
  SET(LUA_PROGRAM_FOUND TRUE)
ELSE (LUA_PROGRAM_PATH)
  SET(LUA_PROGRAM_FOUND FALSE)
ENDIF (LUA_PROGRAM_PATH)

# Find doxygen.
find_package(Doxygen)

# Generate build targets and the doc/index.html file.
IF (DOXYGEN_FOUND OR LUA_PROGRAM_FOUND)
  add_custom_target(doc)

ELSE (DOXYGEN_FOUND OR LUA_PROGRAM_FOUND)
  message("Cannot locate Doxygen or lua, 'doc' target is not available")

ENDIF (DOXYGEN_FOUND OR LUA_PROGRAM_FOUND)


# Add sub-targets of the 'doc' target.
IF (DOXYGEN_FOUND)
  add_custom_target(doc_animview
    ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/DoxyGen/animview.doxygen
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/doc
    COMMENT "Generating API documentation for AnimView" VERBATIM
  )
  add_dependencies(doc doc_animview)


  add_custom_target(doc_leveledit
    ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/DoxyGen/leveledit.doxygen
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/doc
    COMMENT "Generating API documentation for LevelEdit" VERBATIM
  )
  add_dependencies(doc doc_leveledit)


  add_custom_target(doc_mapedit
    ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/DoxyGen/mapedit.doxygen
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/doc
    COMMENT "Generating API documentation for MapEdit" VERBATIM
  )
  add_dependencies(doc doc_mapedit)


  add_custom_target(doc_corsixth_engine
    ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/DoxyGen/corsixth_engine.doxygen
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/doc
    COMMENT "Generating API documentation for corsixth_engine" VERBATIM
  )
  add_dependencies(doc doc_corsixth_engine)
ENDIF (DOXYGEN_FOUND)

IF (LUA_PROGRAM_FOUND)
  add_custom_target(doc_corsixth_lua
    ${LUA_PROGRAM_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/LDocGen/main.lua
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/LDocGen/output/corner_right.gif ${CMAKE_CURRENT_BINARY_DIR}/doc/corsixth_lua
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/LDocGen/output/logo.png         ${CMAKE_CURRENT_BINARY_DIR}/doc/corsixth_lua
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/LDocGen/output/main.css         ${CMAKE_CURRENT_BINARY_DIR}/doc/corsixth_lua
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/doc
    COMMENT "Generating API documentation for corsixth_lua" VERBATIM
  )
  add_dependencies(doc doc_corsixth_lua)
ENDIF (LUA_PROGRAM_FOUND)

# Generate doc/index.html file.
IF (DOXYGEN_FOUND OR LUA_PROGRAM_FOUND)
  file(WRITE  ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<html>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<head><title>CorsixTH source code documentation</title></head>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<body>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<h1>CorsixTH main program source code documentation</h1>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<ul>\n")
ENDIF (DOXYGEN_FOUND OR LUA_PROGRAM_FOUND)

IF (DOXYGEN_FOUND)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "  <li><a href=\"corsixth_engine/html/index.html\">CorsixTH engine documentation</a>\n")
ENDIF (DOXYGEN_FOUND)

IF (LUA_PROGRAM_FOUND)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "  <li><a href=\"corsixth_lua/index.html\">CorsixTH Lua documentation</a>\n")
ENDIF (LUA_PROGRAM_FOUND)

IF (DOXYGEN_FOUND)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "</ul>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<h1>CorsixTH helper programs source code documentation</h1>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<ul>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "  <li><a href=\"animview/html/index.html\">Animation viewer documentation</a>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "  <li><a href=\"leveledit/html/index.html\">Level editor documentation</a>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "  <li><a href=\"mapedit/html/index.html\">Map editor documentation</a>\n")
ENDIF (DOXYGEN_FOUND)

IF (DOXYGEN_FOUND OR LUA_PROGRAM_FOUND)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "</ul>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "</body>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "</html>\n")
ENDIF (DOXYGEN_FOUND OR LUA_PROGRAM_FOUND)
