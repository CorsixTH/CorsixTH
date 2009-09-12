# Makefile for building AnimViewer
# This is quite a simple makefile and could probably do with some love from
# someone who understands the *nix buildchain better than I do.

CC= gcc
CPP= g++
RM= rm -f
CFLAGS= `wx-config --cflags`
LIBS= `wx-config --libs`

ALL_T= AnimViewer
ALL_O= app.o frmMain.o frmSprites.o rnc.o th.o

default: all

all: $(ALL_T)

clean:
	$(RM) $(ALL_O) $(ALL_T)

AnimViewer: $(ALL_O)
	$(CPP) -o $@ $(ALL_O) $(LIBS)

app.o:
	$(CPP) -c app.cpp $(CFLAGS)

frmMain.o:
	$(CPP) -c frmMain.cpp $(CFLAGS)

frmSprites.o:
	$(CPP) -c frmSprites.cpp $(CFLAGS)

rnc.o:
	$(CPP) -c rnc.cpp $(CFLAGS)

th.o:
	$(CPP) -c th.cpp $(CFLAGS)

