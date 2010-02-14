IF(APPLE)
	find_package(SDL REQUIRED)

	set(CMAKE_OSX_ARCHITECTURES "x86_64;i386;ppc")	
	include_directories(${SDL_INCLUDE_DIR})

	add_library (SDLmain STATIC SDLMain.m)
endif(APPLE)
