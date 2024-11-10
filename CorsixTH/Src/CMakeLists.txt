# Modify the config.h based upon our selection of options
configure_file(${CMAKE_SOURCE_DIR}/CorsixTH/Src/config.h.in ${CMAKE_BINARY_DIR}/CorsixTH/Src/config.h)

target_sources(CorsixTH_lib
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/random.c
    ${CMAKE_CURRENT_SOURCE_DIR}/bootstrap.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/iso_fs.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/lua_logger.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/lua_rnc.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/persist_lua.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/run_length_encoder.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/sdl_audio.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/sdl_core.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/sdl_wm.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/th.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/th_gfx.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/th_gfx_font.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/th_gfx_sdl.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/th_lua.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/th_lua_anims.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/th_lua_gfx.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/th_lua_iso.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/th_lua_lfs_ext.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/th_lua_map.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/th_lua_movie.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/th_lua_sound.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/th_lua_strings.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/th_lua_ui.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/th_map.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/th_map_overlays.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/th_movie.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/th_pathfind.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/th_sound.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/xmi2mid.cpp
)

# These are for IDEs such as XCode and MSVC to track headers within their
# project files. They are not used by the build system.
target_sources(CorsixTH_lib
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/bootstrap.h
    ${CMAKE_CURRENT_SOURCE_DIR}/cp437_table.h
    ${CMAKE_CURRENT_SOURCE_DIR}/cp936_table.h
    ${CMAKE_CURRENT_SOURCE_DIR}/iso_fs.h
    ${CMAKE_CURRENT_SOURCE_DIR}/lua_rnc.h
    ${CMAKE_CURRENT_SOURCE_DIR}/lua_sdl.h
    ${CMAKE_CURRENT_SOURCE_DIR}/persist_lua.h
    ${CMAKE_CURRENT_SOURCE_DIR}/run_length_encoder.h
    ${CMAKE_CURRENT_SOURCE_DIR}/th.h
    ${CMAKE_CURRENT_SOURCE_DIR}/th_gfx.h
    ${CMAKE_CURRENT_SOURCE_DIR}/th_gfx_font.h
    ${CMAKE_CURRENT_SOURCE_DIR}/th_gfx_sdl.h
    ${CMAKE_CURRENT_SOURCE_DIR}/th_lua.h
    ${CMAKE_CURRENT_SOURCE_DIR}/th_lua_internal.h
    ${CMAKE_CURRENT_SOURCE_DIR}/th_map.h
    ${CMAKE_CURRENT_SOURCE_DIR}/th_map_overlays.h
    ${CMAKE_CURRENT_SOURCE_DIR}/th_movie.h
    ${CMAKE_CURRENT_SOURCE_DIR}/th_pathfind.h
    ${CMAKE_CURRENT_SOURCE_DIR}/th_sound.h
    ${CMAKE_CURRENT_SOURCE_DIR}/xmi2mid.h

    ${CMAKE_BINARY_DIR}/CorsixTH/Src/config.h
)

target_sources(CorsixTH
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/main.h
)
