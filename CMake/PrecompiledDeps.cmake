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

# Clones and sets any dependencies up
include(ExternalProject)

# Inform CMake about the external project
set(_DEPS_PROJECT_NAME PrecompiledDependencies)

# Place files into ./precompiled_deps folder
set(PRECOMPILED_DEPS_BASE_DIR ${PROJECT_SOURCE_DIR}/PrecompiledDeps CACHE PATH "Destination for pre-built dependencies")
set(_DEPS_GIT_URL "https://github.com/CorsixTH/deps.git")
# Select the optimal dependencies commit regardless where master is.
set(_DEPS_GIT_SHA "a23eb28bb8998b93215eccf805ee5462d75a57f2")

ExternalProject_Add(${_DEPS_PROJECT_NAME}
  PREFIX ${PRECOMPILED_DEPS_BASE_DIR}
  GIT_REPOSITORY ${_DEPS_GIT_URL}
  GIT_TAG ${_DEPS_GIT_SHA}
  # As the deps are already build we can skip these
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  TEST_COMMAND ""
)

unset(_DEPS_GIT_URL)
unset(_DEPS_GIT_SHA)

# Make sure the final make file / solution does not attempt to build
# the dependencies target
set_target_properties(${_DEPS_PROJECT_NAME} PROPERTIES
  EXCLUDE_FROM_ALL 1
  EXCLUDE_FROM_DEFAULT_BUILD 1
)

set(_DEPS_TMP_PATH ${PRECOMPILED_DEPS_BASE_DIR}/tmp)
set(_DEPS_MODULES_TEMPLATE_NAME ${_DEPS_TMP_PATH}/${_DEPS_PROJECT_NAME})

# Clone if we don't have the deps
if(NOT EXISTS ${PRECOMPILED_DEPS_BASE_DIR}/src/${_DEPS_PROJECT_NAME}/.git)
  message(STATUS "Getting Precompiled Dependencies...")
  execute_process(COMMAND ${CMAKE_COMMAND} ARGS -P
    ${_DEPS_MODULES_TEMPLATE_NAME}-gitclone.cmake
    RESULT_VARIABLE return_value
  )
  if(return_value)
    message(FATAL_ERROR "Failed to clone precompiled dependencies.")
  endif()

# Deps exist, check for updates and checkout the correct tag
else()
  message(STATUS "Checking for Precompiled Dependency Updates...")
  execute_process(COMMAND ${CMAKE_COMMAND} ARGS -P
    ${_DEPS_MODULES_TEMPLATE_NAME}-gitupdate.cmake
    RESULT_VARIABLE return_value
  )
  if(return_value)
    message(FATAL_ERROR "Failed to update precompiled dependencies.")
  endif()
endif()

# We can dispose of tmp and modules template name afterwards
unset(_DEPS_TMP_PATH)
unset(_DEPS_MODULES_TEMPLATE_NAME)

# Determine the appropriate libs to use for this compiler
if(UNIX AND CMAKE_COMPILER_IS_GNU)
  # We need user to choose which arch they are intending to compile for
  set(DEPS_ARCH "x86" CACHE STRING "Architecture of precompiled dependencies to use.")
  set_property(CACHE DEPS_ARCH
    PROPERTY STRINGS "x86" "x64"
  )
  # Generate the folder to use
  set(_DEPS_FOLDER_NAME "gnu-linux-" + ${DEPS_ARCH})
else()
  message(FATAL_ERROR "Precompiled dependencies do not exist for this platform / compiler combination yet.")
endif()

set(_DEPS_PATH ${PRECOMPILED_DEPS_BASE_DIR}/src/${_DEPS_PROJECT_NAME}/${_DEPS_FOLDER_NAME})

# Update the prefix path - this refers to the base directory that find_xx
# commands use. For example using find_include would automatically append
# the 'include' subdirectory in.
set(CMAKE_PREFIX_PATH ${_DEPS_PATH})

unset(_DEPS_FOLDER_NAME)
unset(_DEPS_PATH)
