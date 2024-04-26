# Add an extra step to copy LUA files from vcpkg
add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy
  "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/lua/re.lua"
  $<TARGET_FILE_DIR:CorsixTH>
)
