project(WhereamiLib)

add_library(WhereamiLib)
target_include_directories(WhereamiLib PRIVATE ".")

target_sources(WhereamiLib PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/whereami.c
  ${CMAKE_CURRENT_SOURCE_DIR}/whereami.h
)
