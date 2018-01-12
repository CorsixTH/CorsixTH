# Add an extra step to copy LUA files from vcpkg
add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_directory
  "${VCPKG_INSTALLED_PATH}/share/lua"
  $<TARGET_FILE_DIR:CorsixTH>
)

add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E remove
  $<TARGET_FILE_DIR:CorsixTH>/COPYRIGHT
)

add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy
  "${VCPKG_INSTALLED_PATH}/$<$<CONFIG:Debug>:debug/>bin/lfs.dll"
  $<TARGET_FILE_DIR:CorsixTH>/lfs.dll
)

add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy
  "${VCPKG_INSTALLED_PATH}/$<$<CONFIG:Debug>:debug/>bin/lpeg.dll"
  $<TARGET_FILE_DIR:CorsixTH>/lpeg.dll
)

add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy
  "${VCPKG_INSTALLED_PATH}/$<$<CONFIG:Debug>:debug/>bin/mime/core.dll"
  $<TARGET_FILE_DIR:CorsixTH>/mime/core.dll
)

add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy
  "${VCPKG_INSTALLED_PATH}/$<$<CONFIG:Debug>:debug/>bin/socket/core.dll"
  $<TARGET_FILE_DIR:CorsixTH>/socket/core.dll
)
