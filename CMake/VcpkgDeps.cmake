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

if ( MSVC AND USE_VCPKG_DEPS)
    set ( VCPKG_COMMIT_SHA "7fb0342b8a16b43ce9887fcc879a2321954646be")

    # Setup the various paths we are using
    set ( _VCPKG_SCRIPT_NAME "build_vcpkg_deps.ps1")
    set ( _SCRIPT_DIR ${PROJECT_SOURCE_DIR}/scripts)
    # By default place VCPKG into root folder
    set ( VCPKG_PARENT_DIR ${PROJECT_SOURCE_DIR} CACHE PATH "Destination for vcpkg dependencies")

    # Determine the args to use
    if ( CMAKE_CL_64 )
        set ( _VCPKG_ARGS "-IsX64Build $True ")
    else()
        set ( _VCPKG_ARGS "-IsX64Build $False ")
    endif()

    if ( BUILD_ANIMVIEWER )
        string(CONCAT _VCPKG_ARGS ${_VCPKG_ARGS} "-BuildAnimView $True ")
    else ()
        string(CONCAT _VCPKG_ARGS ${_VCPKG_ARGS} "-BuildAnimView $False ")
    endif()

    string(CONCAT _VCPKG_ARGS ${_VCPKG_ARGS} "-VcpkgCommitSha " ${VCPKG_COMMIT_SHA} " ")

    # Run the build script
    set ( _SCRIPT_COMMAND  powershell ${_SCRIPT_DIR}/${_VCPKG_SCRIPT_NAME})
    execute_process(WORKING_DIRECTORY ${VCPKG_PARENT_DIR}
                    COMMAND ${_SCRIPT_COMMAND} ${_VCPKG_ARGS}
                    RESULT_VARIABLE err_val)
    if (err_val)
        message(FATAL_ERROR "Failed to build vcpkg dependencies. "
                "\nIf this error persists try deleting the 'vcpkg' folder.\n")
    endif()

    # We cannot use a toolchain file at this point despite it being recommended by MS.
    # The arch is determined by the generator in use on Windows. For example
    # Visual Studio xx Win64 <= implies 64 bit build. If we use a toolchain this
    # always defaults to a 32 bit build.
    
    # If the user specified their own generator it is too late at this point.
    # We would need to restart CMake at this point, delete the
    # cache and invoke CMake again with the toolchain set.
    
    # For both of these reasons we will use CMAKE_PREFIX_PATH

    set ( VCPKG_INSTALLED_PATH ${VCPKG_PARENT_DIR}/vcpkg/installed/)
    if (CMAKE_CL_64)
        string(CONCAT VCPKG_INSTALLED_PATH ${VCPKG_INSTALLED_PATH} "x64-windows")
    else()
        string(CONCAT VCPKG_INSTALLED_PATH ${VCPKG_INSTALLED_PATH} "x86-windows")
    endif()

    if(CMAKE_BUILD_TYPE MATCHES "^Debug$" OR NOT DEFINED CMAKE_BUILD_TYPE)
        list(APPEND CMAKE_PREFIX_PATH ${VCPKG_INSTALLED_PATH}/debug)
        list(APPEND CMAKE_LIBRARY_PATH ${VCPKG_INSTALLED_PATH}/debug/lib/manual-link)
    endif()

    list(APPEND CMAKE_PREFIX_PATH ${VCPKG_INSTALLED_PATH})
    list(APPEND CMAKE_LIBRARY_PATH ${_VCPKG_INSTALLED_DIR}/lib/manual-link)

endif()