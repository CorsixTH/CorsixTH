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

if ( MSVC )
    set ( _VCPKG_COMMIT_SHA "01f47f5823b0c0db4a7e3e5b690dbc809429da56")

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

    string(CONCAT _VCPKG_ARGS ${_VCPKG_ARGS} "-VcpkgCommitSha " ${_VCPKG_COMMIT_SHA})

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
    # The arch is determined by the generator in use on Windows such as 
    # Visual Studio xx Win64 <= 64 bit build. If we use a toolchain this
    # always defaults to a 32 bit build.
    
    # Also we would need to restart the build at this point, delete the 
    # cache and invoke cmake again with the toolchain set if the user
    # specified their own generator as it is too late at this point.
    
    # For both of these reasons we will use CMAKE_PREFIX_PATH

    set ( VCPKG_INSTALLED_PATH ${VCPKG_PARENT_DIR}/vcpkg/installed/)
    if (CMAKE_CL_64)
        string(CONCAT VCPKG_INSTALLED_PATH ${VCPKG_INSTALLED_PATH} "x64-windows")
    else()
        string(CONCAT VCPKG_INSTALLED_PATH ${VCPKG_INSTALLED_PATH} "x86-windows")
    endif()

    set (CMAKE_PREFIX_PATH ${VCPKG_INSTALLED_PATH} CACHE 
         PATH "Base directory with include and lib directories")

endif()