add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy
  "${VCPKG_INSTALLED_PATH}/$<$<CONFIG:Debug>:debug/>bin/modplug.dll"
  $<TARGET_FILE_DIR:CorsixTH>
)
