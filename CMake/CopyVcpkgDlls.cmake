# Add an extra step to copy built DLLs on MSVC
IF (MSVC AND USE_VCPKG_DEPS)
# Have to do this in two custom steps as we have some DLLs in a top level
# and some in a debug folder so the $<CONFIGURATION> flag won't help

    add_custom_command(TARGET Copy_Release_DLLS CorsixTH 
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${VCPKG_INSTALLED_PATH}/bin"
        $<TARGET_FILE_DIR:CorsixTH>)

    add_custom_command(TARGET Copy_Debug_DLLS CorsixTH 
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${VCPKG_INSTALLED_PATH}/debug/bin"
        $<TARGET_FILE_DIR:CorsixTH>)

ENDIF()