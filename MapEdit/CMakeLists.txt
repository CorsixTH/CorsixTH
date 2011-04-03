# Project Declaration
PROJECT(MapEdit)
# 2.8.3 is required for the wxWidgets finder to know about ribbon
CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

# Generate source files list
# Note: Done after generating config.h
INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR}/CorsixTH/Src/)
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/agg/include/)
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/CorsixTH/Src/)
FILE(GLOB_RECURSE mapedit_source_files
  ${CMAKE_SOURCE_DIR}/MapEdit/Src/*.cpp
  ${CMAKE_SOURCE_DIR}/MapEdit/Src/*.c
  ${CMAKE_SOURCE_DIR}/MapEdit/Src/*.h
  ${CMAKE_SOURCE_DIR}/CorsixTH/Src/*.h
  ${CMAKE_SOURCE_DIR}/CorsixTH/Src/*.c
  ${CMAKE_SOURCE_DIR}/CorsixTH/Src/*.cpp
  ${CMAKE_SOURCE_DIR}/LFS/*.c
  ${CMAKE_SOURCE_DIR}/LPEG/*.c
)

# Declaration of the executable
IF(APPLE) 
  add_definitions(-DIS_MAPEDIT_APP)

  set(corsixth_icon_file ${CMAKE_SOURCE_DIR}/CorsixTH/Icon.icns)
  set_source_files_properties(
    ${corsixth_icon_file}
    PROPERTIES
    MACOSX_PACKAGE_LOCATION Resources
  )
  set(MACOSX_BUNDLE_ICON_FILE Icon.icns)

  add_executable(MapEdit
    MACOSX_BUNDLE
    ${mapedit_source_files}
    ${corsixth_icon_file}
  )

  set_target_properties(MapEdit PROPERTIES LINK_FLAGS_MINSIZEREL "-dead_strip")

  #Add an extra step at the end of the build process to copy the resources into the
  #bundle. I haven't yet found a way to keep the folder structure when adding resources
  #into XCode. I would have thought we could use source_group but apparently not.
  set(corsixth_bundle_resources 
    ${CMAKE_SOURCE_DIR}/CorsixTH/CorsixTH.lua
    ${CMAKE_SOURCE_DIR}/CorsixTH/Bitmap
    ${CMAKE_SOURCE_DIR}/CorsixTH/Lua
  )
  add_custom_command(TARGET MapEdit 
					 POST_BUILD
					 COMMAND /Developer/Library/PrivateFrameworks/DevToolsCore.framework/Resources/pbxcp -exclude .DS_Store -exclude CVS -exclude .svn -resolve-src-symlinks ${corsixth_bundle_resources} \${TARGET_BUILD_DIR}/\${FULL_PRODUCT_NAME}/Contents/Resources
)

ELSE()
  add_executable(MapEdit 
    WIN32 
    ${mapedit_source_files}
)
ENDIF()

# Basic platform dependant stuff
IF(UNIX)
  IF(APPLE)
    # fruit goes here
  ELSE(APPLE)
    # regular unix/linux
  ENDIF(APPLE)
ELSE(UNIX)
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

# Finding libraries

# Find WxWidgets
SET(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}")
SET(wxWidgets_USE_LIBS gl ribbon core base) # optionally: more than wx std libs
FIND_PACKAGE(wxWidgets REQUIRED)
IF(wxWidgets_FOUND)
  LINK_LIBRARIES(${wxWidgets_LIBRARIES})
  INCLUDE_DIRECTORIES(${wxWidgets_INCLUDE_DIRS})
  INCLUDE(${wxWidgets_USE_FILE})
  TARGET_LINK_LIBRARIES(MapEdit ${wxWidgets_LIBRARIES})
  message("  wxWidgets found")
ELSE(wxWidgets_FOUND)
  message( FATAL_ERROR "error: wxWdigets library (or one of it's components) not found, it is required to build")
  message( "Make sure the path is correctly defined or set the envirnomental variable WXWIN to the correct location" )
ENDIF(wxWidgets_FOUND)

# Find SDL
FIND_PACKAGE(SDL REQUIRED)
IF(SDL_FOUND)
  INCLUDE_DIRECTORIES(${SDL_INCLUDE_DIR})
  TARGET_LINK_LIBRARIES(MapEdit ${SDL_LIBRARY})
  message( "  SDL found" )
ELSE(SDL_FOUND)
  message( FATAL_ERROR "error: SDL library not found, it is required to build")
  message( "Make sure the path is correctly defined or set the envirnomental variable SDLDIR to the correct location" )
ENDIF(SDL_FOUND)

# Find SDL_mixer
IF(CORSIX_TH_USE_SDL_MIXER)
  FIND_PACKAGE(SDL_mixer REQUIRED)
  IF(SDLMIXER_FOUND)
    TARGET_LINK_LIBRARIES(MapEdit ${SDLMIXER_LIBRARY})
    INCLUDE_DIRECTORIES(${SDLMIXER_INCLUDE_DIR})
  message( "  SDL_mixer found" )
  ELSE(SDLMIXER_FOUND)
    message( "error: SDL_mixer library not found, it was selected to be included")
  ENDIF(SDLMIXER_FOUND)
ENDIF(CORSIX_TH_USE_SDL_MIXER)

# Find Freetype2
IF(CORSIX_TH_USE_FREETYPE2)
  FIND_PACKAGE(Freetype REQUIRED)
  IF(FREETYPE_FOUND)
    TARGET_LINK_LIBRARIES(MapEdit ${FREETYPE_LIBRARIES})
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
    TARGET_LINK_LIBRARIES( MapEdit ${OPENGL_gl_LIBRARY})
    INCLUDE_DIRECTORIES(${OPENGL_INCLUDE_DIR})
    message( "  OpenGL found" )
  ELSE(OPENGL_FOUND)
    message( FATAL_ERROR "error: OpenGL library not found, it is required to build")
  ENDIF(OPENGL_FOUND)
ENDIF(CORSIX_TH_USE_OGL_RENDERER)

# Find Lua
FIND_PACKAGE(Lua51 REQUIRED)
IF(LUA51_FOUND)
  TARGET_LINK_LIBRARIES( MapEdit ${LUA_LIBRARY})
  INCLUDE_DIRECTORIES(${LUA_INCLUDE_DIR})
  message( "  Lua 5.1 found" )
ELSE(LUA51_FOUND)
  message( FATAL_ERROR "error: Lua library not found, it is required to build")
ENDIF(LUA51_FOUND)

IF(APPLE)
  #Just use the prefix as it's sufficient to just set the prefix to /Applications on Mac.
  install(TARGETS MapEdit BUNDLE DESTINATION .)

  #Copy the required frameworks into the bundle.
  IF(SDL_FOUND)
	IF(SDL_LIBRARY MATCHES "\\.framework") #Only copy if it's an actual framework.
      string(REPLACE "-framework Cocoa" "" SDL_FRAMEWORK_LOC ${SDL_LIBRARY})
      install(DIRECTORY ${SDL_FRAMEWORK_LOC} DESTINATION MapEdit.app/Contents/Frameworks)
    ENDIF()
  ENDIF()

  IF(SDLMIXER_FOUND)
    IF(${SDLMIXER_LIBRARY} MATCHES "\\.framework$") #Only copy if it's an actual framework.
      install(DIRECTORY ${SDLMIXER_LIBRARY} DESTINATION MapEdit.app/Contents/Frameworks)
    ENDIF()
  ENDIF()

  IF(LUA51_FOUND)
    IF(${LUA_LIBRARY} MATCHES "\\.framework$") #Only copy if it's an actual framework.
  	  install(DIRECTORY ${LUA_LIBRARY} DESTINATION MapEdit.app/Contents/Frameworks)
    ENDIF()
  ENDIF()

ELSE()
  install(TARGETS MapEdit RUNTIME DESTINATION CorsixTH)
ENDIF()
