# vim: ts=2 sw=2
# - Try to find the required ffmpeg components(default: AVFORMAT, AVUTIL, AVCODEC)
#
# Once done this will define
#  FFMPEG_FOUND         - System has the all required components.
#  FFMPEG_INCLUDE_DIRS  - Include directory necessary for using the required components headers.
#  FFMPEG_LIBRARIES     - Link these to use the required ffmpeg components.
#
# For each of the components it will additionally set.
#   - AVCODEC
#   - AVDEVICE
#   - AVFORMAT
#   - AVUTIL
#   - POSTPROCESS
#   - SWSCALE
#   - SWRESAMPLE
# the following variables will be defined
#  <component>_FOUND          - System has <component>
#  <component>_INCLUDE_DIRS   - Include directory necessary for using the <component> headers
#  <component>_LIBRARIES      - Link these to use <component>
#  <component>_VERSION_STRING - The component's version
#
# Copyright (c) 2006, Matthias Kretz, <kretz@kde.org>
# Copyright (c) 2008, Alexander Neundorf, <neundorf@kde.org>
# Copyright (c) 2011, Michael Jansen, <kde@michael-jansen.biz>
# Copyright (c) 2013, Stephen Baker
# Copyright (c) 2015, Alexander Bessman
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.

include(FindPackageHandleStandardArgs)
include(${CMAKE_CURRENT_LIST_DIR}/CMakeFFmpegLibavMacros.cmake)

# The default components were taken from a survey over other FindFFMPEG.cmake files
if(NOT FFmpeg_FIND_COMPONENTS)
  set(FFmpeg_FIND_COMPONENTS AVCODEC AVFORMAT AVUTIL)
endif()

# Check for cached results. If there are skip the costly part.
if(NOT FFMPEG_LIBRARIES)

  # Check for all possible component.
  find_component(AVCODEC  avcodec  libavcodec/avcodec.h   libavcodec/version.h)
  find_component(AVFORMAT avformat libavformat/avformat.h libavformat/version.h)
  find_component(AVDEVICE avdevice libavdevice/avdevice.h libavdevice/version.h)
  find_component(AVUTIL   avutil   libavutil/avutil.h     libavutil/version.h)
  find_component(SWSCALE  swscale  libswscale/swscale.h   libswscale/version.h)
  find_component(POSTPROC postproc libpostproc/postprocess.h libpostproc/version.h)
  find_component(SWRESAMPLE swresample libswresample/swresample.h libswresample/version.h)

  # Check if the required components were found and add their stuff to the FFMPEG_* vars.
  foreach(_component ${FFmpeg_FIND_COMPONENTS})
    if(${_component}_FOUND)
      # message(STATUS "Required component ${_component} present.")
      set(FFMPEG_LIBRARIES   ${FFMPEG_LIBRARIES}   ${${_component}_LIBRARIES})
      list(APPEND FFMPEG_INCLUDE_DIRS ${${_component}_INCLUDE_DIRS})
    else()
      # message(STATUS "Required component ${_component} missing.")
    endif()
  endforeach()

  # Build the include path with duplicates removed.
  if(FFMPEG_INCLUDE_DIRS)
    list(REMOVE_DUPLICATES FFMPEG_INCLUDE_DIRS)
  endif()

  # cache the vars.
  set(FFMPEG_INCLUDE_DIRS ${FFMPEG_INCLUDE_DIRS} CACHE STRING "The FFmpeg include directories." FORCE)
  set(FFMPEG_LIBRARIES    ${FFMPEG_LIBRARIES}    CACHE STRING "The FFmpeg libraries." FORCE)

  mark_as_advanced(FFMPEG_INCLUDE_DIRS FFMPEG_LIBRARIES)
endif()

# Now set the noncached _FOUND vars for the components.
foreach(_component AVCODEC AVDEVICE AVFORMAT AVUTIL POSTPROCESS SWSCALE SWRESAMPLE)
  set_component_found(${_component})
endforeach()

# Compile the list of required vars
set(_FFmpeg_REQUIRED_VARS FFMPEG_LIBRARIES FFMPEG_INCLUDE_DIRS)
foreach(_component ${FFmpeg_FIND_COMPONENTS})
  list(APPEND _FFmpeg_REQUIRED_VARS ${_component}_LIBRARIES ${_component}_INCLUDE_DIRS)
endforeach()

# Give a nice error message if some of the required vars are missing.
find_package_handle_standard_args(FFmpeg DEFAULT_MSG ${_FFmpeg_REQUIRED_VARS})
