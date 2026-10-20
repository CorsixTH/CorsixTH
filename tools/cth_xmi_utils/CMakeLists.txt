# Sanity check
if(CORSIX_TH_DONE_TOP_LEVEL_CMAKE)
else()
    message(FATAL_ERROR "Please run CMake from the top-level directory instead of here.")
endif()

# Project Declaration
project(CorsixXmiUtils)

add_executable(
    CorsixXmiUtils
        cth_xmi_utils_main.cpp
)

set_target_properties(CorsixXmiUtils PROPERTIES OUTPUT_NAME "cth_xmi_utils")

target_link_libraries(CorsixXmiUtils CorsixTH_lib)

# Set language standard
set_property(TARGET CorsixXmiUtils PROPERTY CXX_STANDARD 17)
set_property(TARGET CorsixXmiUtils PROPERTY CXX_EXTENSIONS OFF)
set_property(TARGET CorsixXmiUtils PROPERTY CXX_STANDARD_REQUIRED ON)

if(MSVC)
    # We want to bind against the very latest versions of the MSVC runtimes
    add_definitions(/D "_BIND_TO_CURRENT_VCLIBS_VERSION=1")
endif()
