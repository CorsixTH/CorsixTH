#!/usr/bin/env python3
"""
Program to decode the first sprite of a CTHG 2 file.
Mainly intended as a test for the checking the encoder, but also a demonstration of how to decode.
"""

_license = """
Copyright (c) 2013 Alberth "Alberth" Hofkamp

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""

from PIL import Image

class Infile:
    def __init__(self, fname):
        self.fname = fname
        self.handle = open(self.fname, "rb")

        # Read header
        for h in [ord('C'), ord('T'), ord('H'), ord('G'), 2, 0]:
            v = self.getByte()
            assert v == h

    def getByte(self):
        v = self.handle.read(1)[0]
        return v

    def getWord(self):
        b = self.getByte()
        return b | (self.getByte() << 8)

    def getLong(self):
        w = self.getWord()
        return w | (self.getWord() << 16)

    def getData(self, size):
        data = []
        for i in range(size):
            data.append(self.getByte())
        return data

def decode_xy(pix_idx, w, h):
    y = pix_idx // w
    x = pix_idx - w * y
    assert x >= 0 and x < w
    assert y >= 0 and y < h
    return x, y

def get_colour(table, idx):
    if table == 0:
        return (0, 0, 0, 255)
    if table == 1:
        return (idx, 0, 0, 255)
    if table == 2:
        return (0, idx, 0, 255)
    if table == 3:
        return (0, 0, idx, 255)
    if table == 4:
        return (0, idx, idx, 255)
    if table == 5:
        return (idx, 0, idx, 255)
    assert False

class Sprite:
    def __init__(self, infile):
        size = infile.getLong() - 2 - 2 - 2
        self.number = infile.getWord()
        self.width = infile.getWord()
        self.height = infile.getWord()
        self.data = infile.getData(size)

        print("Sprite number {}".format(self.number))
        print("Width {}".format(self.width))
        print("Height {}".format(self.height))
        print("Size {}".format(size))
        print("Data size {}".format(len(self.data)))

    def get_data(self, idx):
        return self.data[idx], idx + 1

    def save(self):
        im = Image.new("RGBA", (self.width, self.height), (0,0,0,0))
        pix = im.load()

        idx = 0
        pix_idx = 0
        while idx < len(self.data):
            length, idx = self.get_data(idx)

            if length <= 63: # Fixed non-transparent 32bpp pixels (RGB)
                length = length & 63
                x, y = decode_xy(pix_idx, self.width, self.height)
                for i in range(length):
                    d = (self.data[idx], self.data[idx+1], self.data[idx+2], 255)
                    pix[x,y] = d
                    idx = idx + 3
                    pix_idx = pix_idx + 1
                    x = x + 1
                    if x == self.width:
                        x = 0
                        y = y + 1
                continue

            elif length <= 64+63: # Partially transparent 32bpp pixels (RGB)
                length = length & 63
                opacity, idx = self.get_data(idx)
                x, y = decode_xy(pix_idx, self.width, self.height)
                for i in range(length):
                    d = (self.data[idx], self.data[idx+1], self.data[idx+2], opacity)
                    pix[x,y] = d
                    idx = idx + 3
                    pix_idx = pix_idx + 1
                    x = x + 1
                    if x == self.width:
                        x = 0
                        y = y + 1
                continue

            elif length <= 128+63: # Fixed fully transparent pixels
                length = length & 63
                pix_idx = pix_idx + length
                continue

            else: # Recolour layer.
                length = length & 63
                table, idx = self.get_data(idx)
                opacity, idx = self.get_data(idx)
                x, y = decode_xy(pix_idx, self.width, self.height)
                for i in range(length):
                    col, idx = self.get_data(idx)
                    pix[x, y] = get_colour(table, col)
                    pix_idx = pix_idx + 1
                    x = x + 1
                    if x == self.width:
                        x = 0
                        y = y + 1
                continue

        im.save("sprite_" + str(self.number) + ".png")


inf = Infile("x.out")
spr = Sprite(inf)
spr.save()
