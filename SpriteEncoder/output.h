/*
Copyright (c) 2013 Albert "Alberth" Hofkamp

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
*/

#ifndef OUTPUT_H
#define OUTPUT_H

#define BUF_SIZE    100000

class DataBlock
{
public:
    DataBlock();

    bool Full();
    void Add(unsigned char byte);
    void Write(FILE *handle);

    unsigned char buffer[BUF_SIZE];
    int m_iUsed;
    DataBlock *m_pNext;
};

class Output
{
public:
    Output();
    ~Output();

    void Write(const char *fname);

    void Uint8(unsigned char byte);
    void Uint16(int val);
    void Write(int address, unsigned char byte);
    int Reserve(int size);

    DataBlock *m_pFirst;
    DataBlock *m_pLast;
};

#endif

// vim: et sw=4 ts=4 sts=4
