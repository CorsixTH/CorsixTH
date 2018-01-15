# MIT License
# 
# Copyright (c) 2017 David Fairbrother
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set (TESTING_FILES
    example.cpp
    spriteTest.cpp

)

add_custom_target(AllTests)

# Download and unpack googletest at configure time
configure_file(CMakeLists.txt.in ${CMAKE_BINARY_DIR}/googletest-download/CMakeLists.txt)
execute_process(COMMAND "${CMAKE_COMMAND}" -G "${CMAKE_GENERATOR}" .
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/googletest-download" )
execute_process(COMMAND "${CMAKE_COMMAND}" --build .
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/googletest-download" )

# Prevent GoogleTest from overriding our compiler/linker options
# when building with Visual Studio
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

# Add googletest directly to our build. This adds
# the following targets: gtest, gtest_main, gmock
# and gmock_main
add_subdirectory("${CMAKE_BINARY_DIR}/googletest-src"
                 "${CMAKE_BINARY_DIR}/googletest-build"
                 EXCLUDE_FROM_ALL)

# Move gtest into its own folder
set_target_properties(gtest gtest_main PROPERTIES FOLDER UnitTests)

# Expose the header files from CorsixTH
include_directories(${CMAKE_SOURCE_DIR}/CorsixTH/Src/)

# Link together all the unit test files - we should gradually move 
# CorsixTH to use libraries, instead we recompile and link them together

# Remove main.cpp and main.h from the files we compile in
set(TEST_SOURCE_FILES ${corsixth_source_files})
list(REMOVE_ITEM TEST_SOURCE_FILES "${CMAKE_SOURCE_DIR}/CorsixTH/Src/main.cpp" "${CMAKE_SOURCE_DIR}/CorsixTH/SrcUnshared/main.cpp")
list(REMOVE_ITEM TEST_SOURCE_FILES "${CMAKE_SOURCE_DIR}/CorsixTH/inc/main.h")

add_executable(UnitTests ${TESTING_FILES} ${TEST_SOURCE_FILES})
target_link_libraries(UnitTests gtest_main)

# XXX: When we move the backend to a library we can avoid 
# pulling in these deps for testing
if (MSVC AND USE_VCPKG_DEPS)
  target_link_libraries(UnitTests SDL2::SDL2)
  target_link_libraries(UnitTests SDL2::SDL2main)
else()
  target_link_libraries(UnitTests ${SDL_LIBRARY})
endif()

if(CORSIX_TH_USE_FFMPEG)
  target_link_libraries(UnitTests ${FFMPEG_LIBRARIES})
endif()

if(CORSIX_TH_USE_LIBAV)
  target_link_libraries(UnitTests ${LIBAV_LIBRARIES})
endif()

target_link_libraries(UnitTests ${LUA_LIBRARY} ${SDLMIXER_LIBRARY} ${FREETYPE_LIBRARIES})

# Add the target to CTest

add_test(NAME UnitTests COMMAND UnitTests)

set_target_properties(UnitTests PROPERTIES FOLDER UnitTests)

# Make sure we add it as a dependency to all tests
add_dependencies(AllTests UnitTests)
