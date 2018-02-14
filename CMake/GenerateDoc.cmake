# Find doxygen.
find_package(Doxygen)

# Generate build targets and the doc/index.html file.
if(DOXYGEN_FOUND OR LUA_PROGRAM_FOUND)
  add_custom_target(doc)
else()
  message("Cannot locate Doxygen or lua, 'doc' target is not available")
endif()

# Add sub-targets of the 'doc' target.
if(DOXYGEN_FOUND)
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/DoxyGen/animview.doxygen.in
    ${CMAKE_CURRENT_BINARY_DIR}/DoxyGen/animview.doxygen @ONLY)

  add_custom_target(doc_animview
    ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/DoxyGen/animview.doxygen
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/doc
    COMMENT "Generating API documentation for AnimView" VERBATIM
  )
  add_dependencies(doc doc_animview)

  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/DoxyGen/leveledit.doxygen.in
    ${CMAKE_CURRENT_BINARY_DIR}/DoxyGen/leveledit.doxygen @ONLY)

  add_custom_target(doc_leveledit
    ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/DoxyGen/leveledit.doxygen
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/doc
    COMMENT "Generating API documentation for LevelEdit" VERBATIM
  )
  add_dependencies(doc doc_leveledit)

  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/DoxyGen/corsixth_engine.doxygen.in
    ${CMAKE_CURRENT_BINARY_DIR}/DoxyGen/corsixth_engine.doxygen @ONLY)

  add_custom_target(doc_corsixth_engine
    ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/DoxyGen/corsixth_engine.doxygen
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/doc
    COMMENT "Generating API documentation for corsixth_engine" VERBATIM
  )
  add_dependencies(doc doc_corsixth_engine)
endif()

if(LUA_PROGRAM_FOUND)
  add_custom_target(doc_corsixth_lua
    ${LUA_PROGRAM_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/LDocGen/main.lua
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/LDocGen/output/corner_right.gif ${CMAKE_CURRENT_BINARY_DIR}/doc/corsixth_lua
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/LDocGen/output/logo.png         ${CMAKE_CURRENT_BINARY_DIR}/doc/corsixth_lua
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/LDocGen/output/main.css         ${CMAKE_CURRENT_BINARY_DIR}/doc/corsixth_lua
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/doc
    COMMENT "Generating API documentation for corsixth_lua" VERBATIM
  )
  add_dependencies(doc doc_corsixth_lua)
endif()

# Generate doc/index.html file.
if(DOXYGEN_FOUND OR LUA_PROGRAM_FOUND)
  file(WRITE  ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<html>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<head><title>CorsixTH source code documentation</title></head>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<body>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<h1>CorsixTH main program source code documentation</h1>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<ul>\n")
endif()

if(DOXYGEN_FOUND)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "  <li><a href=\"corsixth_engine/html/index.html\">CorsixTH engine documentation</a>\n")
endif()

if(LUA_PROGRAM_FOUND)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "  <li><a href=\"corsixth_lua/index.html\">CorsixTH Lua documentation</a>\n")
endif()

if(DOXYGEN_FOUND)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "</ul>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<h1>CorsixTH helper programs source code documentation</h1>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "<ul>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "  <li><a href=\"animview/html/index.html\">Animation viewer documentation</a>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "  <li><a href=\"leveledit/html/index.html\">Level editor documentation</a>\n")
endif()

if(DOXYGEN_FOUND OR LUA_PROGRAM_FOUND)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "</ul>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "</body>\n")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/doc/index.html "</html>\n")
endif()
