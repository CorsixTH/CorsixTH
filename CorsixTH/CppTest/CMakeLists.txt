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

enable_testing()


add_custom_target(AllTests)
find_package(GTest REQUIRED)


# Move gtest into its own folder
# set_target_properties(gtest gtest_main PROPERTIES FOLDER UnitTests)

# Expose the header files from CorsixTH
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/CorsixTH/inc/)

# Link together all the unit test files - we should gradually move 
# CorsixTH to use libraries, instead we recompile and link them together

# Remove main.cpp and main.h from the files we compile in
set(TEST_SOURCE_FILES ${corsixth_source_files})
list(REMOVE_ITEM TEST_SOURCE_FILES "${CMAKE_SOURCE_DIR}/CorsixTH/Src/main.cpp" "${CMAKE_SOURCE_DIR}/CorsixTH/SrcUnshared/main.cpp")
list(REMOVE_ITEM TEST_SOURCE_FILES "${CMAKE_SOURCE_DIR}/CorsixTH/inc/main.h")

add_executable(UnitTests ${TESTING_FILES} ${TEST_SOURCE_FILES})
target_link_libraries(UnitTests GTest::GTest GTest::Main)

# XXX: When we move the backend to a library we can avoid 
# pulling in these deps for testing
IF (MSVC AND USE_VCPKG_DEPS)
  TARGET_LINK_LIBRARIES(UnitTests SDL2::SDL2)
  TARGET_LINK_LIBRARIES(UnitTests SDL2::SDL2main)
ELSE()
target_link_libraries(UnitTests ${SDL_LIBRARY})
ENDIF()

if(CORSIX_TH_USE_FFMPEG)
  target_link_libraries(UnitTests ${FFMPEG_LIBRARIES})
endif()

if(CORSIX_TH_USE_LIBAV)
  target_link_libraries(UnitTests ${LIBAV_LIBRARIES})
endif()

TARGET_LINK_LIBRARIES(UnitTests ${LUA_LIBRARY} ${SDLMIXER_LIBRARY} ${FREETYPE_LIBRARIES})

# Add the target to CTest

add_test(NAME UnitTests COMMAND UnitTests)

# Make sure we add it as a dependency to all tests
add_dependencies(AllTests UnitTests)