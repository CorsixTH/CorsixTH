# Sanity check
IF(CORSIX_TH_DONE_TOP_LEVEL_CMAKE)
ELSE(CORSIX_TH_DONE_TOP_LEVEL_CMAKE)
message(FATAL_ERROR "Please run cmake on the top-level directory, not this one.")
ENDIF(CORSIX_TH_DONE_TOP_LEVEL_CMAKE)

# Project Declaration
PROJECT(CorsixTH)

# Basic platform dependant stuff
IF(UNIX)
  IF(APPLE)
    # fruit goes here
    add_subdirectory(SDLMain)
  ELSE(APPLE)
    # regular unix/linux
  ENDIF(APPLE)
ELSE()
  IF(WIN32)
    # Win32 specific
    IF(MSVC)
      # We want to bind against the very latest versions of the MSVC runtimes
      add_definitions(/D "_BIND_TO_CURRENT_VCLIBS_VERSION=1")
    ELSE(MSVC)
      IF(MSYS)
        # MSYS stuff
      ELSE(MSYS)
        # What's left? MINGW? CYGWIN? BORLAND?
      ENDIF(MSYS)
    ENDIF(MSVC)
  ELSE(WIN32)
    # other OS (not UNIX, not 32/64 bit Windows)
  ENDIF(WIN32)
ENDIF(UNIX)

# Modify the config.h based upon our selection of options
CONFIGURE_FILE(${CMAKE_SOURCE_DIR}/CorsixTH/Src/config.h.in ${CMAKE_BINARY_DIR}/CorsixTH/Src/config.h)
INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR}/CorsixTH/Src/)
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/agg/include/)

# Generate source files list
# Note: Done after generating config.h
FILE(GLOB_RECURSE corsixth_source_files
  ${CMAKE_SOURCE_DIR}/CorsixTH/SrcUnshared/*.cpp
  ${CMAKE_SOURCE_DIR}/CorsixTH/SrcUnshared/*.c
  ${CMAKE_SOURCE_DIR}/CorsixTH/SrcUnshared/*.h
  ${CMAKE_SOURCE_DIR}/CorsixTH/SrcUnshared/*.hpp
  ${CMAKE_SOURCE_DIR}/CorsixTH/Src/*.cpp
  ${CMAKE_SOURCE_DIR}/CorsixTH/Src/*.c
  ${CMAKE_SOURCE_DIR}/CorsixTH/Src/*.hpp
  ${CMAKE_SOURCE_DIR}/CorsixTH/Src/*.h
  ${CMAKE_BINARY_DIR}/CorsixTH/Src/config.h
  ${CMAKE_SOURCE_DIR}/CorsixTH/Lua/api_version.lua
  ${CMAKE_SOURCE_DIR}/CorsixTH/CorsixTH.rc
  ${CMAKE_SOURCE_DIR}/LFS/*.c
  ${CMAKE_SOURCE_DIR}/LPEG/*.c
  ${CMAKE_SOURCE_DIR}/agg/src/agg_image_filters.cpp
)

# Declaration of the executable
IF(APPLE)
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

  #Add an extra step at the end of the build process to copy the resources into the
  #bundle. I haven't yet found a way to keep the folder structure when adding resources
  #into XCode. I would have thought we could use source_group but apparently not.
  set(corsixth_bundle_resources 
    ${CMAKE_SOURCE_DIR}/CorsixTH/CorsixTH.lua
    ${CMAKE_SOURCE_DIR}/CorsixTH/Bitmap
    ${CMAKE_SOURCE_DIR}/CorsixTH/Lua
    ${CMAKE_SOURCE_DIR}/CorsixTH/Levels
  )
  add_custom_command(TARGET CorsixTH 
					 POST_BUILD
					 COMMAND /Developer/Library/PrivateFrameworks/DevToolsCore.framework/Resources/pbxcp -exclude .DS_Store -exclude CVS -exclude .svn -exclude *.bmp -exclude *.png -resolve-src-symlinks ${corsixth_bundle_resources} \${TARGET_BUILD_DIR}/\${FULL_PRODUCT_NAME}/Contents/Resources
  )

  target_link_libraries(CorsixTH SDLmain)
  INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR}/CorsixTH/SDLMain/)
ELSE()
  add_executable(CorsixTH ${corsixth_source_files})
ENDIF()

# Finding libraries

# Find SDL
FIND_PACKAGE(SDL REQUIRED)
IF(SDL_FOUND)
  INCLUDE_DIRECTORIES(${SDL_INCLUDE_DIR})
  IF(SDLMAIN_LIBRARY STREQUAL "")
    IF(WIN32)
      # SDLmain not being found is not fatal, as the win32 SDLmain.c is distributed with CorsixTH
    ELSE(WIN32)
      message(FATAL_ERROR "Error: SDL was found but SDLmain was not")
      message("Make sure the path is correctly defined or set the environment variable SDLDIR to the correct location")
    ENDIF(WIN32)
  ENDIF(SDLMAIN_LIBRARY STREQUAL "")
  # No need to specify sdlmain seperately, the FindSDL.cmake file will take care of that. If not we get an error about it
  TARGET_LINK_LIBRARIES(CorsixTH ${SDL_LIBRARY})
  message("  SDL found")
ELSE(SDL_FOUND)
  message(FATAL_ERROR "Error: SDL library not found, it is required to build. Make sure the path is correctly defined or set the environment variable SDLDIR to the correct location")
ENDIF(SDL_FOUND)

# Find Lua
FIND_PACKAGE(Lua51 REQUIRED)
IF(LUA51_FOUND)
  TARGET_LINK_LIBRARIES(CorsixTH ${LUA_LIBRARY})
  INCLUDE_DIRECTORIES(${LUA_INCLUDE_DIR})
  message("  Lua 5.1 found")
ELSE(LUA51_FOUND)
  message(FATAL_ERROR "Error: Lua library not found, it is required to build")
ENDIF(LUA51_FOUND)

# Find SDL_mixer
IF(CORSIX_TH_USE_SDL_MIXER)
  FIND_PACKAGE(SDL_mixer REQUIRED)
  IF(SDLMIXER_FOUND)
    TARGET_LINK_LIBRARIES(CorsixTH ${SDLMIXER_LIBRARY})
    INCLUDE_DIRECTORIES(${SDLMIXER_INCLUDE_DIR})
    message("  SDL_mixer found")
  ELSE(SDLMIXER_FOUND)
    message("Error: SDL_mixer library not found, even though it was selected to be included")
  ENDIF(SDLMIXER_FOUND)
ENDIF(CORSIX_TH_USE_SDL_MIXER)

# Find Freetype2
IF(CORSIX_TH_USE_FREETYPE2)
  FIND_PACKAGE(Freetype REQUIRED)
  IF(FREETYPE_FOUND)
    TARGET_LINK_LIBRARIES(CorsixTH ${FREETYPE_LIBRARIES})
    INCLUDE_DIRECTORIES(${FREETYPE_INCLUDE_DIRS})
    message("  FreeType2 found")
  ELSE(FREETYPE_FOUND)
    message("Error: FreeType2 library not found, even though it was selected to be used")
  ENDIF(FREETYPE_FOUND)
ENDIF(CORSIX_TH_USE_FREETYPE2)

# Find OpenGL
IF(CORSIX_TH_USE_OGL_RENDERER)
  FIND_PACKAGE(OpenGL REQUIRED)
  IF(OPENGL_FOUND)
    TARGET_LINK_LIBRARIES(CorsixTH ${OPENGL_gl_LIBRARY})
    INCLUDE_DIRECTORIES(${OPENGL_INCLUDE_DIR})
    message("  OpenGL found")
  ELSE(OPENGL_FOUND)
    message(FATAL_ERROR "Error: OpenGL library not found, it is required to build (consider changing choice of renderer)")
  ENDIF(OPENGL_FOUND)
ENDIF(CORSIX_TH_USE_OGL_RENDERER)

# Declaration of the install process
IF(APPLE)
  #Just use the prefix as it's sufficient to just set the prefix to /Applications on Mac.
  install(TARGETS CorsixTH BUNDLE DESTINATION .)

  #Copy the required frameworks into the bundle.
  IF(SDL_FOUND)
	IF(SDL_LIBRARY MATCHES "\\.framework") #Only copy if it's an actual framework.
      string(REPLACE "-framework Cocoa" "" SDL_FRAMEWORK_LOC ${SDL_LIBRARY})
      install(DIRECTORY ${SDL_FRAMEWORK_LOC} DESTINATION CorsixTH.app/Contents/Frameworks)
    ENDIF()
  ENDIF()

  IF(SDLMIXER_FOUND)
    IF(${SDLMIXER_LIBRARY} MATCHES "\\.framework$") #Only copy if it's an actual framework.
      install(DIRECTORY ${SDLMIXER_LIBRARY} DESTINATION CorsixTH.app/Contents/Frameworks)
    ENDIF()
  ENDIF()

  IF(LUA51_FOUND)
    IF(${LUA_LIBRARY} MATCHES "\\.framework$") #Only copy if it's an actual framework.
  	  install(DIRECTORY ${LUA_LIBRARY} DESTINATION CorsixTH.app/Contents/Frameworks)
    ENDIF()
  ENDIF()

ELSE()
  install(TARGETS CorsixTH RUNTIME DESTINATION CorsixTH)
  install(DIRECTORY Lua Levels DESTINATION CorsixTH PATTERN "*.svn" EXCLUDE)
  install(DIRECTORY Bitmap DESTINATION CorsixTH
        FILES_MATCHING REGEX ".*\\.(tab|pal|dat|png)$"
        PATTERN "*.svn" EXCLUDE)
  install(FILES CorsixTH.lua LICENSE.txt CorsixTH.ico DESTINATION CorsixTH )
ENDIF()
