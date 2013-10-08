#!/bin/sh

# Copyright (c) 2013 Albert "Alberth" Hofkamp
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -e -u -x

CCFLAGS="-Wall -g"
FLEXFLAGS=

bison --defines=tokens.h --output=parser.cpp parser.y
flex $FLEXFLAGS --outfile=scanner.cpp scanner.l

g++ $CCFLAGS -c -o parser.o parser.cpp
g++ $CCFLAGS -c -o scanner.o scanner.cpp
g++ $CCFLAGS -c -o encode.o encode.cpp
g++ $CCFLAGS -c -o ast.o ast.cpp
g++ $CCFLAGS -c -o image.o image.cpp
g++ $CCFLAGS -c -o output.o output.cpp

g++ $CCFLAGS -o encoder parser.o scanner.o encode.o ast.o image.o output.o -lpng

