project(RncLib)

add_library(RncLib STATIC
  ${CMAKE_CURRENT_SOURCE_DIR}/rnc.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/rnc.h
)

target_include_directories(RncLib INTERFACE ${CMAKE_CURRENT_SOURCE_DIR})

set_property(TARGET RncLib PROPERTY CXX_STANDARD 14)
set_property(TARGET RncLib PROPERTY CXX_EXTENSIONS OFF)
set_property(TARGET RncLib PROPERTY CXX_STANDARD_REQUIRED ON)
