# Modify the config.h based upon our selection of options
configure_file(${CMAKE_SOURCE_DIR}/CorsixTH/Src/config.h.in ${CMAKE_BINARY_DIR}/CorsixTH/Src/config.h)


set(LPEG_SRC_FILES "")
set(LPEG_HRC_FILES "")
set(LFS_SRC_FILES "")
set(LFS_HRC_FILES "")
if (EMSCRIPTEN)
    include(FetchContent)
    FetchContent_Declare(lpeg
            URL  "https://github.com/roberto-ieru/LPeg/archive/refs/heads/master.zip"
            SOURCE_DIR "${CMAKE_BINARY_DIR}/ep_lpeg"
            DOWNLOAD_EXTRACT_TIMESTAMP false
    )
    FetchContent_Declare(lfs
            URL  "https://github.com/lunarmodules/luafilesystem/archive/refs/tags/v1_8_0.zip"
            SOURCE_DIR "${CMAKE_BINARY_DIR}/ep_lfs"
            DOWNLOAD_EXTRACT_TIMESTAMP false
    )
    FetchContent_MakeAvailable(lpeg)
    FetchContent_MakeAvailable(lfs)

    file(GLOB LPEG_SRC_FILES
            ${lpeg_SOURCE_DIR}/*.c
    )
    file(GLOB LPEG_HRC_FILES
            ${lpeg_SOURCE_DIR}/*.h
    )
    file(GLOB LFS_SRC_FILES
            ${lfs_SOURCE_DIR}/src/*.c
    )
    file(GLOB LFS_HRC_FILES
            ${lfs_SOURCE_DIR}/src/*.h
    )
endif ()

target_sources(CorsixTH_lib
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/random.c
    ${CMAKE_CURRENT_SOURCE_DIR}/bootstrap.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/iso_fs.cpp
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
    ${CMAKE_CURRENT_SOURCE_DIR}/th_strings.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/xmi2mid.cpp

    ${LPEG_SRC_FILES}
    ${LFS_SRC_FILES}
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
    ${CMAKE_CURRENT_SOURCE_DIR}/th_strings.h
    ${CMAKE_CURRENT_SOURCE_DIR}/xmi2mid.h

    ${LPEG_HRC_FILES}
    ${LFS_HRC_FILES}

    ${CMAKE_BINARY_DIR}/CorsixTH/Src/config.h
)

target_sources(CorsixTH
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/main.h
)
