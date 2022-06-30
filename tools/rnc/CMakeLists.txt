# Sanity check
if(CORSIX_TH_DONE_TOP_LEVEL_CMAKE)
else()
  message(FATAL_ERROR "Please run CMake from the top-level directory instead of here.")
endif()

# Project Declaration
project(RncDecodeCli)

add_executable(
	RncDecodeCli
	rnc_decode_cli.cpp
)

set_target_properties(RncDecodeCli PROPERTIES OUTPUT_NAME "rnc_decode")

target_link_libraries(RncDecodeCli RncLib)

# Set language standard
set_property(TARGET RncDecodeCli PROPERTY CXX_STANDARD 14)
set_property(TARGET RncDecodeCli PROPERTY CXX_EXTENSIONS OFF)
set_property(TARGET RncDecodeCli PROPERTY CXX_STANDARD_REQUIRED ON)

if(MSVC)
  # We want to bind against the very latest versions of the MSVC runtimes
  add_definitions(/D "_BIND_TO_CURRENT_VCLIBS_VERSION=1")
endif()
