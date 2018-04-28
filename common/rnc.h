/*
Copyright (c) 2009 Peter "Corsix" Cawley

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

#ifndef CORSIX_TH_RNC_H_
#define CORSIX_TH_RNC_H_

#include <cstddef>
#include <cstdint>

/*! Result status values from #rnc_inpack. */
enum class rnc_status
{
    ok, ///< Everything is fine
    file_is_not_rnc, ///< The file does not begin with an RNC signature
    huf_decode_error, ///< Error decoding the file
    file_size_mismatch, ///< The file size does not match the header
    packed_crc_error, ///< The compressed file does not match its checksum
    unpacked_crc_error ///< The uncompressed file does not match its checksum
};

const std::size_t rnc_header_size = 18;

std::size_t rnc_output_size(const std::uint8_t* input);

std::size_t rnc_input_size(const std::uint8_t* input);

rnc_status rnc_unpack(const std::uint8_t* input, std::uint8_t* output);

#endif // CORSIX_TH_RNC_H_
