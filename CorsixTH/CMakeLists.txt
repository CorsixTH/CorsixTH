# Sanity check
if(CORSIX_TH_DONE_TOP_LEVEL_CMAKE)
else()
  message(FATAL_ERROR "Please run CMake from the top-level directory instead of here.")
endif()

# Project Declaration
project(CorsixTH)

if(MSVC)
  # We want to bind against the very latest versions of the MSVC runtimes
  add_definitions(/D "_BIND_TO_CURRENT_VCLIBS_VERSION=1")
  # Suppress warnings about insecure functions
  add_definitions(-D_CRT_SECURE_NO_WARNINGS)
endif()

if(USE_SOURCE_DATADIRS)
  set(CORSIX_TH_DATADIR ${CMAKE_CURRENT_SOURCE_DIR})
  set(CORSIX_TH_INTERPRETER_PATH ${CORSIX_TH_DATADIR}/CorsixTH.lua)
elseif(MSVC)
  set(CORSIX_TH_DATADIR CorsixTH)
  set(CORSIX_TH_INTERPRETER_PATH CorsixTH.lua)
elseif(APPLE)
  set(CORSIX_TH_DATADIR CorsixTH.app/Contents/Resources/)
  set(CORSIX_TH_INTERPRETER_PATH ${CMAKE_INSTALL_PREFIX}/${CORSIX_TH_DATADIR}/CorsixTH.lua)
else()
  set(CORSIX_TH_DATADIR ${CMAKE_INSTALL_DATADIR}/corsix-th)
  set(CORSIX_TH_INTERPRETER_PATH ${CMAKE_INSTALL_FULL_DATADIR}/corsix-th/CorsixTH.lua)
endif()

# Declaration of the executable
if(APPLE)
  set(corsixth_icon_file ${CMAKE_SOURCE_DIR}/CorsixTH/Icon.icns)
  set_source_files_properties(
    ${corsixth_icon_file}
    PROPERTIES
    MACOSX_PACKAGE_LOCATION Resources
  )
  set(MACOSX_BUNDLE_ICON_FILE Icon.icns)

  add_executable(CorsixTH MACOSX_BUNDLE ${corsixth_icon_file})

  set_target_properties(CorsixTH PROPERTIES LINK_FLAGS_MINSIZEREL "-dead_strip")
  set_target_properties(CorsixTH PROPERTIES XCODE_ATTRIBUTE_LD_RUNPATH_SEARCH_PATHS "@executable_path/../Frameworks")
elseif(MSVC)
  add_executable(CorsixTH CorsixTH.rc)
else()
  add_executable(CorsixTH "")
endif()

# Report operating system in compile_opts.os
if(WIN32)
  set(CORSIX_TH_OS "windows")
elseif(APPLE)
  set(CORSIX_TH_OS "macos")
else()
  set(CORSIX_TH_OS "unix")
endif()

# Report system architecture in compile_opts.arch
if(MSVC)
  set(CORSIX_TH_ARCH ${CMAKE_CXX_COMPILER_ARCHITECTURE_ID})
else()
  set(CORSIX_TH_ARCH ${CMAKE_SYSTEM_PROCESSOR})
endif()

# Ensure config.h is picked up by cmake - moving this into subdir cmake files will
# prevent it applying to the CorsixTH project
set(CorsixTH_generated_src_dir ${CMAKE_BINARY_DIR}/CorsixTH/Src/)
add_library(CorsixTH_lib STATIC ${CorsixTH_generated_src_dir})

target_include_directories(CorsixTH_lib PUBLIC ${CorsixTH_generated_src_dir})

target_link_libraries(CorsixTH_lib RncLib)
target_link_libraries(CorsixTH CorsixTH_lib)

if(UNIX AND NOT APPLE)
  set_target_properties(CorsixTH PROPERTIES OUTPUT_NAME corsix-th)
endif()

# Generate source files list
# Note: Done after generating targets
add_subdirectory(${PROJECT_SOURCE_DIR}/Src)
add_subdirectory(${PROJECT_SOURCE_DIR}/SrcUnshared)

# Set language standard
set_property(TARGET CorsixTH_lib PROPERTY CXX_STANDARD 14)
set_property(TARGET CorsixTH_lib PROPERTY CXX_EXTENSIONS OFF)
set_property(TARGET CorsixTH_lib PROPERTY CXX_STANDARD_REQUIRED ON)

set_property(TARGET CorsixTH PROPERTY CXX_STANDARD 14)
set_property(TARGET CorsixTH PROPERTY CXX_EXTENSIONS OFF)
set_property(TARGET CorsixTH PROPERTY CXX_STANDARD_REQUIRED ON)

# Add an extra step to copy built DLLs on MSVC
if(USE_VCPKG_DEPS)
  include(CopyVcpkgLua)
  include(CopyVcpkgSdlMixerBackends)
endif()

## Finding libraries

# Find SDL
if(MSVC AND USE_VCPKG_DEPS)
  find_package(SDL2 CONFIG REQUIRED)
  target_link_libraries(CorsixTH_lib SDL2::SDL2)
  target_link_libraries(CorsixTH SDL2::SDL2main)
else()
  find_package(SDL2 REQUIRED)
  if(SDL_FOUND)
    include_directories(${SDL_INCLUDE_DIR})
    if(SDLMAIN_LIBRARY STREQUAL "")
      message(FATAL_ERROR "Error: SDL2 was found but SDL2main was not")
      message("Make sure the path is correctly defined or set the environment variable SDLDIR to the correct location")
    endif()
    # No need to specify sdl2main separately, the FindSDL.cmake file will take care of that. If not we get an error about it
    target_link_libraries(CorsixTH ${SDL_LIBRARY})
    message("  SDL2 found")
  else()
    message(FATAL_ERROR "Error: SDL2 library not found, it is required to build. Make sure the path is correctly defined or set the environment variable SDLDIR to the correct location")
  endif()
endif()

# Find Lua
find_package(Lua REQUIRED)
if(Lua_FOUND)
  target_link_libraries(CorsixTH ${LUA_LIBRARY})
  include_directories(${LUA_INCLUDE_DIR})
  # Special link flags needed on macOS 64bit, according to: http://luajit.org/install.html
  # If these are not specified, luaL_newstate() returns NULL and we get this:
  #   Fatal error starting CorsixTH: Cannot open Lua state.
  if(APPLE AND LUA_LIBRARIES MATCHES "libluajit" AND CMAKE_SIZEOF_VOID_P EQUAL 8)
    target_link_libraries(CorsixTH "-pagezero_size 10000" "-image_base 100000000")
  endif()
  if(LUA_LIBRARIES MATCHES "libluajit")
    message("  LuaJIT${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR} found")
  else()
    message("  Lua${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR} found")
    if(WITH_LUAJIT)
      message("    Did you want to use LuaJIT? Please specify the path")
    endif()
    unset(WITH_LUAJIT CACHE)
  endif()
else()
  message(FATAL_ERROR "Error: Lua library not found, it is required to build")
endif()

# Add threading library
find_package(Threads)
target_link_libraries(CorsixTH ${CMAKE_THREAD_LIBS_INIT})

# Find SDL_mixer
if(CORSIX_TH_USE_SDL_MIXER)
  if(MSVC AND USE_VCPKG_DEPS)
    find_package(sdl2-mixer CONFIG REQUIRED)
    target_link_libraries(CorsixTH SDL2::SDL2_mixer)
  else()
    find_package(SDL2_mixer REQUIRED)
    if(SDLMIXER_FOUND)
      target_link_libraries(CorsixTH ${SDLMIXER_LIBRARY})
      include_directories(${SDLMIXER_INCLUDE_DIR})
      message("  SDL_mixer found")
    else()
      message(FATAL_ERROR "Error: SDL_mixer library not found, even though it was selected to be included")
    endif()
  endif()
endif()

# Find FFMPEG
if(CORSIX_TH_USE_FFMPEG)
  find_package(FFmpeg COMPONENTS AVFORMAT AVCODEC AVUTIL SWSCALE SWRESAMPLE REQUIRED)
  if(FFMPEG_FOUND)
    target_link_libraries(CorsixTH ${FFMPEG_LIBRARIES})
    include_directories(${FFMPEG_INCLUDE_DIRS})
    if(APPLE)
      target_link_libraries(CorsixTH libz.dylib)
      # These LDFLAGS are necessary for static ffmpeg, harmless for dynamic ffmpeg
      set(CMAKE_EXE_LINKER_FLAGS "-liconv -framework CoreVideo")
    endif()
    message("  FFmpeg found")
  else()
    message(FATAL_ERROR "Error: FFmpeg library not found, even though it was selected to be included")
  endif()
endif()

# Find Freetype2
if(CORSIX_TH_USE_FREETYPE2)
  if(MSVC AND USE_VCPKG_DEPS)
    find_package(Freetype REQUIRED)
    target_link_libraries(CorsixTH Freetype::Freetype)
  else()
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

# Launch script to facilitate out of source builds
if(USE_SOURCE_DATADIRS)
  # Do not generate launch script. The default is fine for this case.
elseif(XCODE)
  message(WARNING "By default you will not be able to run CorsixTH from Xcode. If you do not plan to deploy then run cmake with -DUSE_SOURCE_DATADIRS. If you want to both run and deploy from Xcode then set the command line arguments in your run scheme to --interpreter=${CMAKE_CURRENT_SOURCE_DIR}/CorsixTH.lua")
elseif(APPLE)
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/run-corsix-th-dev.sh.in.apple ${CMAKE_CURRENT_BINARY_DIR}/run-corsixth-dev.sh @ONLY)
elseif(UNIX)
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/run-corsix-th-dev.sh.in ${CMAKE_CURRENT_BINARY_DIR}/run-corsixth-dev.sh @ONLY)
elseif(MSVC)
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/CorsixTH.vcxproj.user.in ${CMAKE_CURRENT_BINARY_DIR}/CorsixTH.vcxproj.user @ONLY)
endif()

# Adding testing files whilst we also have the list of source files and have found libs
if(ENABLE_UNIT_TESTS)
  message("Building Unit Tests")
  # Enable testing if set at this level so we can use CTest from the root of the build dir
  enable_testing()
  add_subdirectory(${PROJECT_SOURCE_DIR}/CppTest)
endif()

# Declaration of the install process
if(NOT USE_SOURCE_DATADIRS)
  if(APPLE)
    # Just use the prefix as it's sufficient to just set the prefix to /Applications on Mac.
    install(TARGETS CorsixTH BUNDLE DESTINATION .)
  elseif(MSVC)
    install(TARGETS CorsixTH
      RUNTIME DESTINATION ${CORSIX_TH_DATADIR}
      LIBRARY DESTINATION ${CORSIX_TH_DATADIR}
      ARCHIVE DESTINATION ${CORSIX_TH_DATADIR}
    )
    install(FILES CorsixTH.ico DESTINATION ${CORSIX_TH_DATADIR})

    # Install dependencies
    file(GLOB DLL_DEPS "${CMAKE_CURRENT_BINARY_DIR}/*.dll")
    install(FILES ${DLL_DEPS} DESTINATION ${CORSIX_TH_DATADIR})
    file(GLOB LUA_DEPS "${CMAKE_CURRENT_BINARY_DIR}/*.lua")
    install(FILES ${LUA_DEPS} DESTINATION ${CORSIX_TH_DATADIR})
    if(EXISTS "${CMAKE_CURRENT_BINARY_DIR}/mime")
      install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/mime" "${CMAKE_CURRENT_BINARY_DIR}/socket" DESTINATION ${CORSIX_TH_DATADIR})
    endif()
  else()
    install(TARGETS CorsixTH
      RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
      LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
      ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )
  endif()
  install(DIRECTORY Campaigns Lua Levels DESTINATION ${CORSIX_TH_DATADIR})
  install(DIRECTORY Bitmap DESTINATION ${CORSIX_TH_DATADIR}
    FILES_MATCHING REGEX ".*\\.(tab|pal|dat|png)$"
  )
  install(FILES CorsixTH.lua ../LICENSE.txt DESTINATION ${CORSIX_TH_DATADIR})

  if(UNIX AND NOT APPLE)
    install(FILES corsix-th.6 DESTINATION ${CMAKE_INSTALL_MANDIR}/man6)
    install(FILES com.corsixth.corsixth.metainfo.xml DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/metainfo)
    install(FILES com.corsixth.corsixth.desktop DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/applications)
    install(FILES Original_Logo.svg DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/scalable/apps RENAME corsix-th.svg)
  endif()

  if(APPLE)
    # Fix the macOS bundle to include required libraries (create a redistributable app)
    install(CODE "
      INCLUDE(BundleUtilities)
      SET(BU_CHMOD_BUNDLE_ITEMS ON)
      FIXUP_BUNDLE(\"${CMAKE_INSTALL_PREFIX}/CorsixTH.app\" \"\" \"\")
      ")
    if(WITH_LUAROCKS)
      install(CODE "execute_process(
        COMMAND bash \"${CMAKE_SOURCE_DIR}/scripts/macos_luarocks\" \"${CMAKE_INSTALL_PREFIX}\")
      ")
    endif()
  endif()
endif()

add_custom_target(windowsconfig ${LUA_PROGRAM_PATH} ${CMAKE_SOURCE_DIR}/scripts/generate_windows_config.lua
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
