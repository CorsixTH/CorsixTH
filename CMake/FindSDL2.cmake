# - Locate SDL2 library
# This module defines
#  SDL_LIBRARY, the name of the library to link against
#  SDL_FOUND, if false, do not try to link to SDL
#  SDL_INCLUDE_DIR, where to find SDL.h
#  SDL_VERSION_STRING, human-readable string containing the version of SDL
#
# This module responds to the the flag:
#  SDL_BUILDING_LIBRARY
#    If this is defined, then no SDL_main will be linked in because
#    only applications need main().
#    Otherwise, it is assumed you are building an application and this
#    module will attempt to locate and set the the proper link flags
#    as part of the returned SDL_LIBRARY variable.
#
# Don't forget to include SDL_main.h and SDLmain.m your project for the
# OS X framework based version. (Other versions link to -lSDLmain which
# this module will try to find on your behalf.) Also for OS X, this
# module will automatically add the -framework Cocoa on your behalf.
#
#
# Additional Note: If you see an empty SDL_LIBRARY_TEMP in your configuration
# and no SDL_LIBRARY, it means CMake did not find your SDL library
# (SDL2.dll, libSDL2.so, SDL2.framework, etc).
# Set SDL_LIBRARY_TEMP to point to your SDL library, and configure again.
# Similarly, if you see an empty SDLMAIN_LIBRARY, you should set this value
# as appropriate. These values are used to generate the final SDL_LIBRARY
# variable, but when these values are unset, SDL_LIBRARY does not get created.
#
#
# $SDLDIR is an environment variable that would
# correspond to the ./configure --prefix=$SDLDIR
# used in building SDL.
# l.e.galup  9-20-02

#=============================================================================
# Copyright 2003-2009 Kitware, Inc.
# Copyright 2012 Benjamin Eikel
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

find_path(SDL_INCLUDE_DIR SDL.h
  HINTS
    ENV SDLDIR
  PATH_SUFFIXES include/SDL2 include
)

find_library(SDL_LIBRARY_TEMP
  NAMES SDL2
  HINTS
    ENV SDLDIR
  PATH_SUFFIXES lib
)

# Find debug library
find_library(SDL_LIBRARY_TEMP_D
NAMES SDL2d
HINTS
  ENV SDLDIR
PATH_SUFFIXES lib
)

if (SDL_LIBRARY_TEMP_D)
  set (_FOUND_SDL_D_LIBRARY TRUE)
endif()


if(NOT SDL_BUILDING_LIBRARY)
  if(NOT ${SDL_INCLUDE_DIR} MATCHES ".framework")
    # Non-OS X framework versions expect you to also dynamically link to
    # SDL2main. This is mainly for Windows and OS X. Other (Unix) platforms
    # seem to provide SDL2main for compatibility even though they don't
    # necessarily need it.
    find_library(SDLMAIN_LIBRARY
      NAMES SDL2main
      HINTS
        ENV SDLDIR
      PATH_SUFFIXES lib
      PATHS
      /sw
      /opt/local
      /opt/csw
      /opt
    )

    find_library(SDLMAIN_LIBRARY_D
      NAMES SDL2maind
      HINTS
        ENV SDLDIR
      PATH_SUFFIXES lib
    )
  endif()
endif()

# SDL may require threads on your system.
# The Apple build may not need an explicit flag because one of the
# frameworks may already provide it.
# But for non-OSX systems, I will use the CMake Threads package.
if(NOT APPLE)
  find_package(Threads)
endif()

# MinGW needs an additional library, mwindows
# It's total link flags should look like -lmingw32 -lSDL2main -lSDL2 -lmwindows
# (Actually on second look, I think it only needs one of the m* libraries.)
if(MINGW)
  set(MINGW32_LIBRARY mingw32 CACHE STRING "mwindows for MinGW")
endif()

if(SDL_LIBRARY_TEMP)
  # For SDL2main
  if(SDLMAIN_LIBRARY AND NOT SDL_BUILDING_LIBRARY)
    list(FIND SDL_LIBRARY_TEMP "${SDLMAIN_LIBRARY}" _SDL_MAIN_INDEX)
    if(_SDL_MAIN_INDEX EQUAL -1)
      set(SDL_LIBRARY_TEMP "${SDLMAIN_LIBRARY}" ${SDL_LIBRARY_TEMP})
      set(SDL_LIBRARY_TEMP_D "${SDLMAIN_LIBRARY_D}" ${SDL_LIBRARY_TEMP_D})
    endif()
    unset(_SDL_MAIN_INDEX)
  endif()

  # For OS X, SDL uses Cocoa as a backend so it must link to Cocoa.
  # CMake doesn't display the -framework Cocoa string in the UI even
  # though it actually is there if I modify a pre-used variable.
  # I think it has something to do with the CACHE STRING.
  # So I use a temporary variable until the end so I can set the
  # "real" variable in one-shot.
  if(APPLE)
    set(SDL_LIBRARY_TEMP ${SDL_LIBRARY_TEMP} "-framework Cocoa")
  endif()

  # For threads, as mentioned Apple doesn't need this.
  # In fact, there seems to be a problem if I used the Threads package
  # and try using this line, so I'm just skipping it entirely for OS X.
  if(NOT APPLE)
    set(SDL_LIBRARY_TEMP ${SDL_LIBRARY_TEMP} ${CMAKE_THREAD_LIBS_INIT})
    set(SDL_LIBRARY_TEMP_D ${SDL_LIBRARY_TEMP_D} ${CMAKE_THREAD_LIBS_INIT})
  endif()

  # For MinGW library
  if(MINGW)
    set(SDL_LIBRARY_TEMP ${MINGW32_LIBRARY} ${SDL_LIBRARY_TEMP})
  endif()

  # Set the final string here so the GUI reflects the final state.
  set(SDL_LIBRARY ${SDL_LIBRARY_TEMP} CACHE STRING "Where the SDL Library can be found")
  set(SDL_LIBRARY_D ${SDL_LIBRARY_TEMP_D} CACHE STRING "Where the SDL Debug Library can be found")
  # Set the temp variable to INTERNAL so it is not seen in the CMake GUI
  set(SDL_LIBRARY_TEMP "${SDL_LIBRARY_TEMP}" CACHE INTERNAL "")
  set(SDL_LIBRARY_TEMP_D "${SDL_LIBRARY_TEMP_D}" CACHE INTERNAL "")
endif()

if(SDL_INCLUDE_DIR AND EXISTS "${SDL_INCLUDE_DIR}/SDL_version.h")
  file(STRINGS "${SDL_INCLUDE_DIR}/SDL_version.h" SDL_VERSION_MAJOR_LINE REGEX "^#define[ \t]+SDL_MAJOR_VERSION[ \t]+[0-9]+$")
  file(STRINGS "${SDL_INCLUDE_DIR}/SDL_version.h" SDL_VERSION_MINOR_LINE REGEX "^#define[ \t]+SDL_MINOR_VERSION[ \t]+[0-9]+$")
  file(STRINGS "${SDL_INCLUDE_DIR}/SDL_version.h" SDL_VERSION_PATCH_LINE REGEX "^#define[ \t]+SDL_PATCHLEVEL[ \t]+[0-9]+$")
  string(REGEX REPLACE "^#define[ \t]+SDL_MAJOR_VERSION[ \t]+([0-9]+)$" "\\1" SDL_VERSION_MAJOR "${SDL_VERSION_MAJOR_LINE}")
  string(REGEX REPLACE "^#define[ \t]+SDL_MINOR_VERSION[ \t]+([0-9]+)$" "\\1" SDL_VERSION_MINOR "${SDL_VERSION_MINOR_LINE}")
  string(REGEX REPLACE "^#define[ \t]+SDL_PATCHLEVEL[ \t]+([0-9]+)$" "\\1" SDL_VERSION_PATCH "${SDL_VERSION_PATCH_LINE}")
  set(SDL_VERSION_STRING ${SDL_VERSION_MAJOR}.${SDL_VERSION_MINOR}.${SDL_VERSION_PATCH})
  unset(SDL_VERSION_MAJOR_LINE)
  unset(SDL_VERSION_MINOR_LINE)
  unset(SDL_VERSION_PATCH_LINE)
  unset(SDL_VERSION_MAJOR)
  unset(SDL_VERSION_MINOR)
  unset(SDL_VERSION_PATCH)
endif()

#include(${CMAKE_CURRENT_LIST_DIR}/FindPackageHandleStandardArgs.cmake)
include(FindPackageHandleStandardArgs)


# Combine the debug and optimized paths if we have found both
if (_FOUND_SDL_D_LIBRARY AND SDL_LIBRARY_D)
  set(SDL_LIBRARY "optimized" ${SDL_LIBRARY} "debug" ${SDL_LIBRARY_D})
endif()

FIND_PACKAGE_HANDLE_STANDARD_ARGS(SDL
                                  REQUIRED_VARS SDL_LIBRARY SDL_INCLUDE_DIR
                                  VERSION_VAR SDL_VERSION_STRING)
