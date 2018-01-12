## Try to find Visual Leak Debugger library (VDL)
## http://vld.codeplex.com
##
## Sets the following variables:
## VLD_FOUND
## VLD_INCLUDE_DIR
## VLD_LIBRARY
##
## Stephen E. Baker 2014
set(VLD_FOUND FALSE)

if(${CMAKE_SIZEOF_VOID_P} MATCHES 8)
  set (VLD_LIB_SUBDIRS lib/Win64 lib)
else()
  set (VLD_LIB_SUBDIRS lib/Win32 lib)
endif()

set(PROG_FILES_X86_ENV "PROGRAMFILES(X86)")
set(PROG_FILES_ENV "PROGRAMFILES")

find_path(VLD_INCLUDE_DIR vld.h
  HINTS
    ENV VLD_HOME
  PATH_SUFFIXES include
  PATHS
  "$ENV{${PROG_FILES_X86_ENV}}/Visual Leak Detector"
  "$ENV{${PROG_FILES_ENV}}/Visual Leak Detector"
)

find_library(VLD_LIBRARY NAMES vld
  HINTS
    ENV VLD_HOME
  PATH_SUFFIXES ${VLD_LIB_SUBDIRS}
  PATHS
  "$ENV{${PROG_FILES_X86_ENV}}/Visual Leak Detector"
  "$ENV{${PROG_FILES_ENV}}/Visual Leak Detector"
)

if(VLD_INCLUDE_DIR AND VLD_LIBRARY)
  set(VLD_FOUND TRUE)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(VLD DEFAULT_MSG VLD_LIBRARY VLD_INCLUDE_DIR)

mark_as_advanced(
  VLD_INCLUDE_DIR
  VLD_LIBRARY
)
