# Project Declaration
PROJECT(AnimView)

# Generate source files list
# Note: do not use generic includes (*.cpp and such) this will break things with cmake
SET(animview_source_files
  app.cpp
  frmMain.cpp
  frmSprites.cpp
  rnc.cpp
  th.cpp
  app.h
  backdrop.h
  frmMain.h
  frmSprites.h
  th.h
)

# Declaration of the executable
IF(APPLE)

  set(corsixth_icon_file ${CMAKE_SOURCE_DIR}/CorsixTH/Icon.icns)
  set_source_files_properties(
    ${corsixth_icon_file}
    PROPERTIES
    MACOSX_PACKAGE_LOCATION Resources
  )
  set(MACOSX_BUNDLE_ICON_FILE Icon.icns)

  add_executable( 
    AnimView
    MACOSX_BUNDLE
    ${animview_source_files}
    ${corsixth_icon_file}
  )

  set_target_properties(AnimView PROPERTIES LINK_FLAGS_MINSIZEREL "-dead_strip")
ELSE()
  add_executable( 
    AnimView 
    WIN32 # This prevents the dos console showing up
    ${animview_source_files}
  )
ENDIF()

# Finding libraries

# Find WxWidgets
SET(wxWidgets_USE_LIBS core base) # optionally: more than wx std libs
FIND_PACKAGE(wxWidgets REQUIRED)
IF(wxWidgets_FOUND)
  LINK_LIBRARIES(${wxWidgets_LIBRARIES})
  INCLUDE_DIRECTORIES(${wxWidgets_INCLUDE_DIRS})
  INCLUDE(${wxWidgets_USE_FILE})
  TARGET_LINK_LIBRARIES(AnimView ${wxWidgets_LIBRARIES})
  message("  wxWidgets found")
ELSE(wxWidgets_FOUND)
  message(FATAL_ERROR "error: wxWdigets library not found, it is required to build")
  message("Make sure the path is correctly defined or set the environment variable WXWIN to the correct location")
ENDIF(wxWidgets_FOUND)

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

IF(APPLE)
  install(TARGETS AnimView BUNDLE DESTINATION .)
ELSE()
  install(TARGETS AnimView RUNTIME DESTINATION AnimView)
  install(FILES LICENSE.txt DESTINATION AnimView )
ENDIF()
