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

set(VCPKG_COMMIT_SHA "c2691026a5e5aad05d7e7d89d605ccb595cbbcb6")

# Setup the various paths we are using
set(_VCPKG_SCRIPT_NAME "build_vcpkg_deps.ps1")
set(_SCRIPT_DIR ${CMAKE_SOURCE_DIR}/scripts)
# By default place VCPKG into root folder
set(VCPKG_PARENT_DIR ${CMAKE_SOURCE_DIR} CACHE PATH "Destination for vcpkg dependencies")

# Determine the args to use
if(VCPKG_TARGET_TRIPLET)
  set(_VCPKG_TARGET_TRIPLET ${VCPKG_TARGET_TRIPLET})
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Xx]64$" OR CMAKE_GENERATOR MATCHES "Win64$")
  set(_VCPKG_TARGET_TRIPLET "x64-windows")
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Aa][Rr][Mm]$" OR CMAKE_GENERATOR MATCHES "ARM$")
  set(_VCPKG_TARGET_TRIPLET "arm-windows")
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Ww][Ii][Nn]32$")
  set(_VCPKG_TARGET_TRIPLET "x86-windows")
elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 16 2019$")
  set(_VCPKG_TARGET_TRIPLET "x64-windows")
else()
  set(_VCPKG_TARGET_TRIPLET "x86-windows")
endif()

set(_VCPKG_ARGS "-VcpkgTriplet " ${_VCPKG_TARGET_TRIPLET})

if(BUILD_ANIMVIEWER)
  string(CONCAT _VCPKG_ARGS ${_VCPKG_ARGS} " -BuildAnimView $True")
else()
  string(CONCAT _VCPKG_ARGS ${_VCPKG_ARGS} " -BuildAnimView $False")
endif()

string(CONCAT _VCPKG_ARGS ${_VCPKG_ARGS} " -VcpkgCommitSha " ${VCPKG_COMMIT_SHA} " ")

# Run the build script
set(_SCRIPT_COMMAND  powershell ${_SCRIPT_DIR}/${_VCPKG_SCRIPT_NAME})
execute_process(WORKING_DIRECTORY ${VCPKG_PARENT_DIR}
  COMMAND ${_SCRIPT_COMMAND} ${_VCPKG_ARGS}
  RESULT_VARIABLE err_val
)
if(err_val)
  message(FATAL_ERROR "Failed to build vcpkg dependencies. "
    "\nIf this error persists try deleting the 'vcpkg' folder.\n")
endif()

set(VCPKG_INSTALLED_PATH ${VCPKG_PARENT_DIR}/vcpkg/installed/${_VCPKG_TARGET_TRIPLET})
set(CMAKE_TOOLCHAIN_FILE ${VCPKG_PARENT_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake CACHE STRING "Vcpkg toolchain file")
