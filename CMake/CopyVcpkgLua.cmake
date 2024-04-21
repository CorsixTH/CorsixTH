# Add an extra step to copy LUA files from vcpkg
add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy
  "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/lua/re.lua"
  "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/$<$<CONFIG:Debug>:debug/>bin/lfs.dll"
  "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/$<$<CONFIG:Debug>:debug/>bin/lpeg.dll"
  $<TARGET_FILE_DIR:CorsixTH>
)
