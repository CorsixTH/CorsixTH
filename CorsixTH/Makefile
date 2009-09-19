# Makefile for building CorsixTH
# This is quite a simple makefile and could probably do with some love from
# someone who understands the *nix buildchain better than I do.

CC= gcc
CPP= g++
RM= rm -f
CFLAGS= `sdl-config --cflags`
LIBS= -llua `sdl-config --libs` -lSDL_mixer

ALL_T= CorsixTH
ALL_O= lfs.o main.o rnc.o sdl_core.o sdl_wm.o th.o th_gfx.o \
	th_lua.o th_map.o th_pathfind.o th_gfx_dx9.o th_gfx_sdl.o \
	random.o SDL_main_win32.o xmi2mid.o sdl_audio.o th_sound.o

default: all

all: $(ALL_T)

clean:
	$(RM) $(ALL_O) $(ALL_T)

CorsixTH: $(ALL_O)
	$(CPP) -o $@ $(ALL_O) $(LIBS)

lfs.o:
	$(CC) -c ../LFS/lfs.c $(CFLAGS)
  
main.o:
	$(CPP) -c Src/main.cpp $(CFLAGS)

random.o:
	$(CC) -c Src/random.c $(CFLAGS)

rnc.o:
	$(CPP) -c Src/rnc.cpp $(CFLAGS)

sdl_audio.o:
	$(CPP) -c Src/sdl_audio.cpp $(CFLAGS)

sdl_core.o:
	$(CPP) -c Src/sdl_core.cpp $(CFLAGS)

SDL_main_win32.o:
	$(CC) -c Src/SDL_main_win32.c $(CFLAGS)

sdl_wm.o:
	$(CPP) -c Src/sdl_wm.cpp $(CFLAGS)

th.o:
	$(CPP) -c Src/th.cpp $(CFLAGS)

th_gfx.o:
	$(CPP) -c Src/th_gfx.cpp $(CFLAGS)

th_gfx_dx9.o:
	$(CPP) -c Src/th_gfx_dx9.cpp $(CFLAGS)

th_gfx_sdl.o:
	$(CPP) -c Src/th_gfx_sdl.cpp $(CFLAGS)
  
th_lua.o:
	$(CPP) -c Src/th_lua.cpp $(CFLAGS)

th_map.o:
	$(CPP) -c Src/th_map.cpp $(CFLAGS)

th_pathfind.o:
	$(CPP) -c Src/th_pathfind.cpp $(CFLAGS)

th_sound.o:
	$(CPP) -c Src/th_sound.cpp $(CFLAGS)

xmi2mid.o:
	$(CPP) -c Src/xmi2mid.cpp $(CFLAGS)
