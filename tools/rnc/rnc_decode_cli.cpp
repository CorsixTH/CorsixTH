/*
Copyright (c) 2022 Albert "Alberth" Hofkamp

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

#include <cstdio>
#include <cstdlib>
#include <cstring>

#include "rnc.h"

static std::uint8_t* decompress(const std::uint8_t* in, std::size_t inlen,
                                std::size_t* outlen) {
  if (inlen < rnc_header_size) {
    fprintf(stderr, "Input is not RNC compressed data\n");
    exit(2);
  }

  *outlen = rnc_output_size(in);
  if (*outlen > 0xFFFFFF) {
    fprintf(stderr, "Output file too long (> 16MB).\n");
    exit(1);
  }
  std::uint8_t* outbuf = new std::uint8_t[*outlen];
  if (outbuf == nullptr) {
    fprintf(stderr, "Cannot allocate memory for output file.\n");
    exit(1);
  }

  switch (rnc_unpack(in, outbuf)) {
    case rnc_status::ok:
      return outbuf;

    case rnc_status::file_is_not_rnc:
      fprintf(stderr, "Input is not RNC compressed data\n");
      exit(2);

    case rnc_status::huf_decode_error:
      fprintf(stderr, "Huffman decoding error\n");
      exit(2);

    case rnc_status::file_size_mismatch:
      fprintf(stderr, "Size mismatch\n");
      exit(2);

    case rnc_status::packed_crc_error:
      fprintf(stderr, "Incorrect packed CRC\n");
      exit(2);

    case rnc_status::unpacked_crc_error:
      fprintf(stderr, "Incorrect unpacked CRC\n");
      exit(2);

    default:
      fprintf(stderr, "Unknown error decompressing RNC data\n");
      exit(2);
  }
}

static bool ishelp(const char* txt) {
  if (!strcmp(txt, "-h")) return true;
  if (!strcmp(txt, "--help")) return true;
  return false;
}

int main(int argc, char* argv[]) {
  if (argc != 3 || ishelp(argv[1])) {
    fprintf(stderr, "Usage: rnc_decode <input> <output>\n");
    exit(1);
  }

  FILE* inhandle = fopen(argv[1], "rb");
  if (inhandle == nullptr) {
    fprintf(stderr, "Cannot open input file.\n");
    exit(1);
  }

  fseek(inhandle, 0, SEEK_END);
  std::size_t insize = ftell(inhandle);
  fseek(inhandle, 0, SEEK_SET);
  printf("Input file is %lu bytes.\n", insize);

  std::uint8_t* indata = new std::uint8_t[insize];
  if (indata == nullptr) {
    fprintf(stderr, "Cannot allocate memory for input file.\n");
    exit(1);
  }

  std::size_t count = fread(indata, 1, insize, inhandle);
  if (count != insize) {
    fprintf(stderr, "Cannot read input file.\n");
    exit(1);
  }
  fclose(inhandle);

  std::size_t outlen;
  std::uint8_t* outdata = decompress(indata, insize, &outlen);

  FILE* outhandle = fopen(argv[2], "wb");
  count = fwrite(outdata, 1, outlen, outhandle);
  if (count != outlen) {
    fprintf(stderr, "Cannot write output file.\n");
    exit(1);
  }
  fclose(outhandle);
  printf("Wrote %lu bytes output file.\n", outlen);

  delete[] outdata;
  return 0;
}
