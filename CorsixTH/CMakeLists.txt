# Sanity check
if(CORSIX_TH_DONE_TOP_LEVEL_CMAKE)
else()
  message(FATAL_ERROR "Please run cmake on the top-level directory, not this one.")
endif()

# Project Declaration
project(CorsixTH)

if(APPLE)
  add_subdirectory(SDLMain)
elseif(MSVC)
  # We want to bind against the very latest versions of the MSVC runtimes
  add_definitions(/D "_BIND_TO_CURRENT_VCLIBS_VERSION=1")
endif()

# Modify the config.h based upon our selection of options
configure_file(${CMAKE_SOURCE_DIR}/CorsixTH/Src/config.h.in ${CMAKE_BINARY_DIR}/CorsixTH/Src/config.h)
include_directories(${CMAKE_BINARY_DIR}/CorsixTH/Src/)

# Generate source files list
# Note: Done after generating config.h
file(GLOB_RECURSE corsixth_source_files
  ${CMAKE_SOURCE_DIR}/CorsixTH/SrcUnshared/*.cpp
  ${CMAKE_SOURCE_DIR}/CorsixTH/SrcUnshared/*.c
  ${CMAKE_SOURCE_DIR}/CorsixTH/SrcUnshared/*.h
  ${CMAKE_SOURCE_DIR}/CorsixTH/SrcUnshared/*.hpp
  ${CMAKE_SOURCE_DIR}/CorsixTH/Src/*.cpp
  ${CMAKE_SOURCE_DIR}/CorsixTH/Src/*.c
  ${CMAKE_SOURCE_DIR}/CorsixTH/Src/*.hpp
  ${CMAKE_SOURCE_DIR}/CorsixTH/Src/*.h
  ${CMAKE_SOURCE_DIR}/CorsixTH/Src/shaders/*.psh
  ${CMAKE_BINARY_DIR}/CorsixTH/Src/config.h
  ${CMAKE_SOURCE_DIR}/CorsixTH/Lua/api_version.lua
  ${CMAKE_SOURCE_DIR}/CorsixTH/CorsixTH.rc
  ${CMAKE_SOURCE_DIR}/LFS/*.c
  ${CMAKE_SOURCE_DIR}/LPEG/*.c
)

# Declaration of the executable
if(APPLE)
  add_definitions(-DIS_CORSIXTH_APP)

  set(corsixth_icon_file ${CMAKE_SOURCE_DIR}/CorsixTH/Icon.icns)
  set_source_files_properties(
    ${corsixth_icon_file}
    PROPERTIES
    MACOSX_PACKAGE_LOCATION Resources
  )
  set(MACOSX_BUNDLE_ICON_FILE Icon.icns)

  add_executable(CorsixTH MACOSX_BUNDLE ${corsixth_source_files} ${corsixth_icon_file})

  set_target_properties(CorsixTH PROPERTIES LINK_FLAGS_MINSIZEREL "-dead_strip")
  set_target_properties(CorsixTH PROPERTIES XCODE_ATTRIBUTE_LD_RUNPATH_SEARCH_PATHS "@executable_path/../Frameworks")

  #Add an extra step at the end of the build process to copy the resources into the bundle.
  add_custom_command(TARGET CorsixTH
    POST_BUILD
    COMMAND rsync -rv --include-from ${CMAKE_SOURCE_DIR}/CorsixTH/RequiredResources.txt ${CMAKE_SOURCE_DIR}/CorsixTH/ \${TARGET_BUILD_DIR}/\${FULL_PRODUCT_NAME}/Contents/MacOS
    COMMAND rsync -rv ${CMAKE_SOURCE_DIR}/CorsixTH/Icon.icns \${TARGET_BUILD_DIR}/\${FULL_PRODUCT_NAME}/Contents/Resources/
  )

  target_link_libraries(CorsixTH SDL2main)
  include_directories(${CMAKE_BINARY_DIR}/CorsixTH/SDLMain/)
else()
  add_executable(CorsixTH ${corsixth_source_files})
endif()

# Add an extra step to copy built DLLs on MSVC
if(USE_VCPKG_DEPS)
  include(CopyVcpkgLua)
ENDIF()

## Finding libraries

# Find SDL
if(MSVC AND USE_VCPKG_DEPS)
  find_package(SDL2 CONFIG REQUIRED)
  target_link_libraries(CorsixTH SDL2::SDL2)
  target_link_libraries(CorsixTH SDL2::SDL2main)
else()
  find_package(SDL2 REQUIRED)
  if(SDL_FOUND)
    include_directories(${SDL_INCLUDE_DIR})
    if(SDLMAIN_LIBRARY STREQUAL "")
      message(FATAL_ERROR "Error: SDL was found but SDLmain was not")
      message("Make sure the path is correctly defined or set the environment variable SDLDIR to the correct location")
    endif()
    # No need to specify sdlmain separately, the FindSDL.cmake file will take care of that. If not we get an error about it
    target_link_libraries(CorsixTH ${SDL_LIBRARY})
    message("  SDL found")
  else()
    message(FATAL_ERROR "Error: SDL library not found, it is required to build. Make sure the path is correctly defined or set the environment variable SDLDIR to the correct location")
  endif()
endif()

# Find Lua
find_package(Lua REQUIRED)
if(Lua_FOUND)
  target_link_libraries(CorsixTH ${LUA_LIBRARY})
  include_directories(${LUA_INCLUDE_DIR})
  # Special link flags needed on OSX/64bit, according to: http://luajit.org/install.html
  # If these are not specified, luaL_newstate() returns NULL and we get this:
  #   Fatal error starting CorsixTH: Cannot open Lua state.
  if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin" AND LUA_INTERPRETER_TYPE STREQUAL "LuaJIT" AND CMAKE_SIZEOF_VOID_P EQUAL 8)
    target_link_libraries(CorsixTH "-pagezero_size 10000" "-image_base 100000000")
  endif()
  message("  ${LUA_INTERPRETER_TYPE} found")
else()
  message(FATAL_ERROR "Error: Lua library not found, it is required to build")
endif()

# Add threading library
find_package(Threads)
target_link_libraries(CorsixTH ${CMAKE_THREAD_LIBS_INIT})

# Find SDL_mixer
if(CORSIX_TH_USE_SDL_MIXER)
  find_package(SDL2_mixer REQUIRED)
  if(SDLMIXER_FOUND)
    target_link_libraries(CorsixTH ${SDLMIXER_LIBRARY})
    include_directories(${SDLMIXER_INCLUDE_DIR})
    message("  SDL_mixer found")
  else()
    message(FATAL_ERROR "Error: SDL_mixer library not found, even though it was selected to be included")
  endif()
endif()

message(STATUS "CMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}")

# Find FFMPEG
if(CORSIX_TH_USE_FFMPEG)
  find_package(FFmpeg COMPONENTS AVFORMAT AVCODEC AVUTIL SWSCALE SWRESAMPLE REQUIRED)
  if(FFMPEG_FOUND)
    target_link_libraries(CorsixTH ${FFMPEG_LIBRARIES})
    include_directories(${FFMPEG_INCLUDE_DIRS})
    if(APPLE)
      target_link_libraries(CorsixTH libz.dylib)
    endif()
    message("  FFmpeg found")
  else()
    message(FATAL_ERROR "Error: FFmpeg library not found, even though it was selected to be included")
  endif()
endif()

if(CORSIX_TH_USE_LIBAV)
  find_package(LibAV COMPONENTS AVFORMAT AVCODEC AVRESAMPLE AVUTIL SWSCALE REQUIRED)
  if(LIBAV_FOUND)
    target_link_libraries(CorsixTH ${LIBAV_LIBRARIES})
    include_directories(${LIBAV_INCLUDE_DIRS})
    if(APPLE)
      target_link_libraries(CorsixTH libz.dylib)
    endif()
    message("  LibAV found")
  else()
    message(FATAL_ERROR "Error: LibAV library not found, even though it was selected to be included")
  endif()
endif()

# Find Freetype2
if(CORSIX_TH_USE_FREETYPE2)
  find_package(Freetype REQUIRED)
  if(FREETYPE_FOUND)
    target_link_libraries(CorsixTH ${FREETYPE_LIBRARIES})
    include_directories(${FREETYPE_INCLUDE_DIRS})
    if(APPLE)
      target_link_libraries(CorsixTH libz.dylib)
      target_link_libraries(CorsixTH libbz2.dylib)
    endif()
    message("  FreeType2 found")
  else()
    message(FATAL_ERROR "Error: FreeType2 library not found, even though it was selected to be used")
  endif()
endif()

if(MSVC AND CORSIX_TH_USE_VLD)
  find_package(VLD REQUIRED)
  if(VLD_FOUND)
    target_link_libraries(CorsixTH ${VLD_LIBRARY})
    include_directories(CorsixTH ${VLD_INCLUDE_DIR})
    message("  VLD found")
  else()
    message(FATAL_ERROR "Error: VLD Library not found, it is required to build when USE_VLD is set")
  endif()
endif()

# Declaration of the install process
if(APPLE)
  #Just use the prefix as it's sufficient to just set the prefix to /Applications on Mac.
  install(TARGETS CorsixTH BUNDLE DESTINATION .)

  # Fix the OS X bundle to include required libraries (create a redistributable app)
  install(CODE "
    INCLUDE(BundleUtilities)
    SET(BU_CHMOD_BUNDLE_ITEMS ON)
    FIXUP_BUNDLE(${CMAKE_INSTALL_PREFIX}/CorsixTH.app \"\" \"\")
    ")
else()
  install(TARGETS CorsixTH RUNTIME DESTINATION CorsixTH)
  install(DIRECTORY Campaigns Lua Levels DESTINATION CorsixTH)
  install(DIRECTORY Bitmap DESTINATION CorsixTH
    FILES_MATCHING REGEX ".*\\.(tab|pal|dat|png)$"
    PATTERN "*.svn" EXCLUDE
  )
  install(FILES CorsixTH.lua ../LICENSE.txt CorsixTH.ico DESTINATION CorsixTH )
endif()
