project(RncLib)

add_library(RncLib)

target_sources(RncLib PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/rnc.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/rnc.h
)
