# Makefile for building CorsixTH
# This is quite a simple makefile and could probably do with some love from
# someone who understands the *nix buildchain better than I do.

CC= gcc
CPP= g++
RM= rm -f
CFLAGS= `sdl-config --cflags`
LIBS= -llua `sdl-config --libs`

ALL_T= CorsixTH
ALL_O= lfs.o main.o rnc.o sdl_core.o sdl_video.o sdl_wm.o th.o th_gfx.o \
	th_lua.o th_map.o th_pathfind.o dx9_video.o th_gfx_dx9.o th_gfx_sdl.o

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

rnc.o:
	$(CPP) -c Src/rnc.cpp $(CFLAGS)

sdl_core.o:
	$(CPP) -c Src/sdl_core.cpp $(CFLAGS)

sdl_video.o:
	$(CPP) -c Src/sdl_video.cpp $(CFLAGS)

dx9_video.o:
	$(CPP) -c Src/dx9_video.cpp $(CFLAGS)

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

