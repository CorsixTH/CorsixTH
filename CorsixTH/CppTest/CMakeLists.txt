# MIT License
# 
# Copyright (c) 2019 David Fairbrother
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
    test_main.cpp
    example.cpp
)

# Ubuntu 16.04 does not have catch and it requires a different
# path from the bare "catch.hpp" if a user manually installs
# so instead use a bundled copy
set(CATCH_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Catch)
add_library(catch2 INTERFACE)
target_include_directories(catch2 INTERFACE ${CATCH_INCLUDE_DIR})


add_custom_target(AllTests)

# Expose the header files from CorsixTH
include_directories(${CMAKE_SOURCE_DIR}/CorsixTH/Src/)

add_executable(UnitTests ${TESTING_FILES} ${TEST_SOURCE_FILES})
target_link_libraries(UnitTests catch2)
target_link_libraries(UnitTests corsixth_lib)

# Add the target to CTest
add_test(NAME UnitTests COMMAND UnitTests)
set_target_properties(UnitTests PROPERTIES FOLDER UnitTests)

# Make sure we add it as a dependency to all tests (some day we can add LuaTest here)
add_dependencies(AllTests UnitTests)