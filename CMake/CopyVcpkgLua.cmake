# Add an extra step to copy LUA files from vcpkg
add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_directory
  "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/lua/socket"
  $<TARGET_FILE_DIR:CorsixTH>/socket
)

add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_directory
  "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/lua/ssl"
  $<TARGET_FILE_DIR:CorsixTH>/ssl
)

add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy
  "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/lua/ltn12.lua"
  "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/lua/mime.lua"
  "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/lua/re.lua"
  "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/lua/socket.lua"
  "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/lua/ssl.lua"
  "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/$<$<CONFIG:Debug>:debug/>bin/lfs.dll"
  "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/$<$<CONFIG:Debug>:debug/>bin/lpeg.dll"
  $<TARGET_FILE_DIR:CorsixTH>
)

add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy
  "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/$<$<CONFIG:Debug>:debug/>bin/lua-ssl.dll"
  $<TARGET_FILE_DIR:CorsixTH>/ssl.dll
)

if(${VCPKG_TARGET_TRIPLET} MATCHES "x64-windows.*")
  set(_OPENSSL_SUFFIX "-x64")
else()
  set(_OPENSSL_SUFFIX "")
endif()

add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy
  "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/$<$<CONFIG:Debug>:debug/>bin/libcrypto-3${_OPENSSL_SUFFIX}.dll"
  "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/$<$<CONFIG:Debug>:debug/>bin/libssl-3${_OPENSSL_SUFFIX}.dll"
  $<TARGET_FILE_DIR:CorsixTH>
)

add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy
  "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/$<$<CONFIG:Debug>:debug/>bin/mime/core.dll"
  $<TARGET_FILE_DIR:CorsixTH>/mime/core.dll
)

add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy
  "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/$<$<CONFIG:Debug>:debug/>bin/socket/core.dll"
  $<TARGET_FILE_DIR:CorsixTH>/socket/core.dll
)
