add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy
  "${VCPKG_INSTALLED_PATH}/$<$<CONFIG:Debug>:debug/>bin/FLAC.dll"
  "${VCPKG_INSTALLED_PATH}/$<$<CONFIG:Debug>:debug/>bin/FLAC++.dll"
  "${VCPKG_INSTALLED_PATH}/$<$<CONFIG:Debug>:debug/>bin/mpg123.dll"
  "${VCPKG_INSTALLED_PATH}/$<$<CONFIG:Debug>:debug/>bin/modplug.dll"
  "${VCPKG_INSTALLED_PATH}/$<$<CONFIG:Debug>:debug/>bin/ogg.dll"
  "${VCPKG_INSTALLED_PATH}/$<$<CONFIG:Debug>:debug/>bin/vorbis.dll"
  "${VCPKG_INSTALLED_PATH}/$<$<CONFIG:Debug>:debug/>bin/vorbisenc.dll"
  "${VCPKG_INSTALLED_PATH}/$<$<CONFIG:Debug>:debug/>bin/vorbisfile.dll"
  $<TARGET_FILE_DIR:CorsixTH>
)
