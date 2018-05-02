# Project Declaration
project(AnimView)

# Generate source files list
# Note: do not use generic includes (*.cpp and such) this will break things with cmake
set(animview_source_files
  app.cpp
  frmMain.cpp
  frmSprites.cpp
  ${CMAKE_SOURCE_DIR}/common/rnc.h
  ${CMAKE_SOURCE_DIR}/common/rnc.cpp
  th.cpp
  app.h
  backdrop.h
  frmMain.h
  frmSprites.h
  th.h
  AnimView.rc
)

# Declaration of the executable
if(APPLE)
  set(corsixth_icon_file ${CMAKE_SOURCE_DIR}/AnimView/Icon.icns)
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
  set_target_properties(AnimView PROPERTIES XCODE_ATTRIBUTE_LD_RUNPATH_SEARCH_PATHS "@executable_path/../Frameworks")
else()
  add_executable( 
    AnimView 
    WIN32 # This prevents the dos console showing up
    ${animview_source_files}
  )
endif()

## Finding libraries

# Find WxWidgets
set(wxWidgets_USE_LIBS core base) # optionally: more than wx std libs
find_package(wxWidgets REQUIRED)
if(wxWidgets_FOUND)
  link_libraries(${wxWidgets_LIBRARIES})
  include_directories(${wxWidgets_INCLUDE_DIRS})
  include(${wxWidgets_USE_FILE})
  target_link_libraries(AnimView ${wxWidgets_LIBRARIES})
  message("  wxWidgets found")
else()
  message(FATAL_ERROR "error: wxWdigets library not found, it is required to build")
  message("Make sure the path is correctly defined or set the environment variable WXWIN to the correct location")
endif()

if(MSVC)
  # We want to bind against the very latest versions of the MSVC runtimes
  add_definitions(/D "_BIND_TO_CURRENT_VCLIBS_VERSION=1")
endif()

if(APPLE)
  install(TARGETS AnimView BUNDLE DESTINATION .)
  
  # Fix the OS X bundle to include required libraries (create a redistributable app)
  install(CODE "
    INCLUDE(BundleUtilities)
    SET(BU_CHMOD_BUNDLE_ITEMS ON)
    FIXUP_BUNDLE(${CMAKE_INSTALL_PREFIX}/AnimView.app \"\" \"\")
    ")
else()
  install(TARGETS AnimView RUNTIME DESTINATION AnimView)
  install(FILES LICENSE.txt DESTINATION AnimView )
endif()
