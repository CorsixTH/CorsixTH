# Find Lua
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

# Find Doxygen.
find_package(Doxygen)

if(DOXYGEN_FOUND OR LUA_PROGRAM_PATH)
  add_custom_target(doc)
  # Add sub-targets of the 'doc' target.
  file(WRITE  ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<!DOCTYPE html>\n<html>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<head><title>CorsixTH source code documentation</title></head>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<body>\n<h1>CorsixTH main program source code documentation</h1>\n<ul>\n")
else()
  message("Cannot locate Doxygen or Lua, 'doc' target is not available")
endif()

if(LUA_PROGRAM_PATH)
  add_custom_target(doc_corsixth_lua
    ${LUA_PROGRAM_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/LDocGen/main.lua
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/LDocGen/output/corner_right.gif ${CMAKE_CURRENT_BINARY_DIR}/doc/corsixth_lua
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/LDocGen/output/logo.png         ${CMAKE_CURRENT_BINARY_DIR}/doc/corsixth_lua
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/LDocGen/output/main.css         ${CMAKE_CURRENT_BINARY_DIR}/doc/corsixth_lua
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/doc
    COMMENT "Generating API documentation for corsixth_lua" VERBATIM
  )
  add_dependencies(doc doc_corsixth_lua)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<li><a href='corsixth_lua/index.html'>CorsixTH Lua documentation</a>\n")
endif()

if(DOXYGEN_FOUND)
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/DoxyGen/corsixth_engine.doxygen.in
    ${CMAKE_CURRENT_BINARY_DIR}/DoxyGen/corsixth_engine.doxygen @ONLY)

  add_custom_target(doc_corsixth_engine
    ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/DoxyGen/corsixth_engine.doxygen
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/doc
    COMMENT "Generating API documentation for corsixth_engine" VERBATIM
  )
  add_dependencies(doc doc_corsixth_engine)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<li><a href='corsixth_engine/html/index.html'>CorsixTH engine documentation</a>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "</ul>\n<h1>CorsixTH helper programs source code documentation</h1>\n<ul>\n")

  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/DoxyGen/leveledit.doxygen.in
    ${CMAKE_CURRENT_BINARY_DIR}/DoxyGen/leveledit.doxygen @ONLY)

  add_custom_target(doc_leveledit
    ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/DoxyGen/leveledit.doxygen
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/doc
    COMMENT "Generating API documentation for LevelEdit" VERBATIM
  )
  add_dependencies(doc doc_leveledit)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<li><a href='leveledit/html/index.html'>Level editor documentation</a>\n")

  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/DoxyGen/animview.doxygen.in
    ${CMAKE_CURRENT_BINARY_DIR}/DoxyGen/animview.doxygen @ONLY)

  add_custom_target(doc_animview
    ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/DoxyGen/animview.doxygen
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/doc
    COMMENT "Generating API documentation for AnimView" VERBATIM
  )
  add_dependencies(doc doc_animview)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<li><a href='animview/html/index.html'>Animation viewer documentation</a>\n")
endif()

if(DOXYGEN_FOUND OR LUA_PROGRAM_PATH)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "</ul>\n</body>\n</html>\n")
endif()
