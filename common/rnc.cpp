/*
Copyright (c) 1997 Simon Tatham

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

    Original code was from http://www.yoda.arachsys.com/dk/utils.html. While
    that site and the original code do not state copyright or license, email
    communication releaved the original author, and they agreed to releasing it
    under the MIT license (above).

    Modifications made to the original code include:
      * Const correctness
      * Prebuilt CRC table
      * Lua interface
      * Indentation and code style
      * Bit stream pointers to data
      * Fix bit operations near end of stream
      * Style changes to conform to CorsixTH
*/

#include "rnc.h"
#include <vector>
#include <cstdint>
#include <cstddef>

static const std::uint32_t rnc_signature = 0x524E4301; /*!< "RNC\001" */

static const std::uint16_t rnc_crc_table[256] = {
    0x0000, 0xC0C1, 0xC181, 0x0140, 0xC301, 0x03C0, 0x0280, 0xC241,
    0xC601, 0x06C0, 0x0780, 0xC741, 0x0500, 0xC5C1, 0xC481, 0x0440,
    0xCC01, 0x0CC0, 0x0D80, 0xCD41, 0x0F00, 0xCFC1, 0xCE81, 0x0E40,
    0x0A00, 0xCAC1, 0xCB81, 0x0B40, 0xC901, 0x09C0, 0x0880, 0xC841,
    0xD801, 0x18C0, 0x1980, 0xD941, 0x1B00, 0xDBC1, 0xDA81, 0x1A40,
    0x1E00, 0xDEC1, 0xDF81, 0x1F40, 0xDD01, 0x1DC0, 0x1C80, 0xDC41,
    0x1400, 0xD4C1, 0xD581, 0x1540, 0xD701, 0x17C0, 0x1680, 0xD641,
    0xD201, 0x12C0, 0x1380, 0xD341, 0x1100, 0xD1C1, 0xD081, 0x1040,
    0xF001, 0x30C0, 0x3180, 0xF141, 0x3300, 0xF3C1, 0xF281, 0x3240,
    0x3600, 0xF6C1, 0xF781, 0x3740, 0xF501, 0x35C0, 0x3480, 0xF441,
    0x3C00, 0xFCC1, 0xFD81, 0x3D40, 0xFF01, 0x3FC0, 0x3E80, 0xFE41,
    0xFA01, 0x3AC0, 0x3B80, 0xFB41, 0x3900, 0xF9C1, 0xF881, 0x3840,
    0x2800, 0xE8C1, 0xE981, 0x2940, 0xEB01, 0x2BC0, 0x2A80, 0xEA41,
    0xEE01, 0x2EC0, 0x2F80, 0xEF41, 0x2D00, 0xEDC1, 0xEC81, 0x2C40,
    0xE401, 0x24C0, 0x2580, 0xE541, 0x2700, 0xE7C1, 0xE681, 0x2640,
    0x2200, 0xE2C1, 0xE381, 0x2340, 0xE101, 0x21C0, 0x2080, 0xE041,
    0xA001, 0x60C0, 0x6180, 0xA141, 0x6300, 0xA3C1, 0xA281, 0x6240,
    0x6600, 0xA6C1, 0xA781, 0x6740, 0xA501, 0x65C0, 0x6480, 0xA441,
    0x6C00, 0xACC1, 0xAD81, 0x6D40, 0xAF01, 0x6FC0, 0x6E80, 0xAE41,
    0xAA01, 0x6AC0, 0x6B80, 0xAB41, 0x6900, 0xA9C1, 0xA881, 0x6840,
    0x7800, 0xB8C1, 0xB981, 0x7940, 0xBB01, 0x7BC0, 0x7A80, 0xBA41,
    0xBE01, 0x7EC0, 0x7F80, 0xBF41, 0x7D00, 0xBDC1, 0xBC81, 0x7C40,
    0xB401, 0x74C0, 0x7580, 0xB541, 0x7700, 0xB7C1, 0xB681, 0x7640,
    0x7200, 0xB2C1, 0xB381, 0x7340, 0xB101, 0x71C0, 0x7080, 0xB041,
    0x5000, 0x90C1, 0x9181, 0x5140, 0x9301, 0x53C0, 0x5280, 0x9241,
    0x9601, 0x56C0, 0x5780, 0x9741, 0x5500, 0x95C1, 0x9481, 0x5440,
    0x9C01, 0x5CC0, 0x5D80, 0x9D41, 0x5F00, 0x9FC1, 0x9E81, 0x5E40,
    0x5A00, 0x9AC1, 0x9B81, 0x5B40, 0x9901, 0x59C0, 0x5880, 0x9841,
    0x8801, 0x48C0, 0x4980, 0x8941, 0x4B00, 0x8BC1, 0x8A81, 0x4A40,
    0x4E00, 0x8EC1, 0x8F81, 0x4F40, 0x8D01, 0x4DC0, 0x4C80, 0x8C41,
    0x4400, 0x84C1, 0x8581, 0x4540, 0x8701, 0x47C0, 0x4680, 0x8641,
    0x8201, 0x42C0, 0x4380, 0x8341, 0x4100, 0x81C1, 0x8081, 0x4040,
};

struct bit_stream
{
    std::uint32_t bitbuf;       ///< holds between 16 and 32 bits.
    int bitcount;          ///< how many bits does bitbuf hold?
    const std::uint8_t* endpos; ///< pointer past the readable data
    const std::uint8_t* p;      ///< pointer in data that stream is reading.
};

struct huf_table
{
    int num;               ///< number of nodes in the tree.
    struct
    {
        std::uint32_t code;
        int codelen;
        int value;
    } table[32];
};

//! Calculate a CRC, the RNC way.
/*!
    @param data data for which to calculate the CRC
    @param len length of the data in bytes
*/
static std::uint16_t rnc_crc(const std::uint8_t* data, std::size_t len)
{
    std::uint16_t val = 0;

    while(len--)
    {
        val = static_cast<std::uint16_t>(val ^ *data++);
        val = static_cast<std::uint16_t>((val >> 8) ^ rnc_crc_table[val & 0xFF]);
    }

    return val;
}


//! Return the big-endian 32 bit word at p.
/*!
    @param p Pointer to data containing the word
*/
static std::uint32_t blong (const std::uint8_t *p)
{
    std::uint32_t n;
    n = p[0];
    n = (n << 8) + p[1];
    n = (n << 8) + p[2];
    n = (n << 8) + p[3];
    return n;
}

//! Return the big-endian 16 bit word at p.
/*!
    @param p Pointer to data containing the word
*/
static std::uint32_t bword (const std::uint8_t *p)
{
    std::uint32_t n;
    n = p[0];
    n = (n << 8) + p[1];
    return n;
}

//! Return the little-endian 16 bit word at p.
/*!
    @param p Pointer to data containing the word
 */
static std::uint32_t lword (const std::uint8_t *p)
{
    std::uint32_t n;
    n = p[1];
    n = (n << 8) + p[0];
    return n;
}

//! Mirror the bottom n bits of x.
/*!
    @param x
    @param n
*/
static std::uint32_t mirror (std::uint32_t x, int n)
{
    std::uint32_t top = 1 << (n-1), bottom = 1;
    while (top > bottom)
    {
        std::uint32_t mask = top | bottom;
        std::uint32_t masked = x & mask;
        if (masked != 0 && masked != mask)
        {
            x ^= mask;
        }
        top >>= 1;
        bottom <<= 1;
    }
    return x;
}


//! Initialises a bit stream with the first two bytes of the packed
//! data.
/*!
    @param bs Bit stream to be initialized
    @param p Pointer to start of memory block the bitstream is to
        traverse
    @param endpos Pointer to byte after the last memory block the bitstream is
        to traverse
*/
static void bitread_init (bit_stream *bs, const std::uint8_t *p, const std::uint8_t* endpos)
{
    bs->bitbuf = lword(p);
    bs->bitcount = 16;
    bs->p = p;
    bs->endpos = endpos;
}

//! Fixes up a bit stream after literals have been read out of the
//! data stream and the pointer has been moved.
/*!
    @param bs Bit stream to correct
*/
static void bitread_fix (bit_stream *bs)
{
    // Remove the top 16 bits
    bs->bitcount -= 16;
    bs->bitbuf &= (1<<bs->bitcount)-1;

    // Replace with what is in the new current location
    // in the bit stream
    if(bs->p < bs->endpos - 1)
    {
        bs->bitbuf |= (lword(bs->p)<<bs->bitcount);
        bs->bitcount += 16;
    } else if (bs->p == bs->endpos - 1) {
        bs->bitbuf |= (*(bs->p)<<bs->bitcount);
        bs->bitcount += 16;
    }
}

//! Return a word consisting of the specified bits without advancing
//! the bit stream.
/*!
    @param bs Bit stream from which to peek
    @param mask A 32 bit bit mask specifying which bits to peek
*/
static std::uint32_t bit_peek (bit_stream *bs, const std::uint32_t mask)
{
    return bs->bitbuf & mask;
}

//! Advances the bit stream.
/*!
    @param bs Bit stream to advance
    @param n Number of bits to advance the stream.  Must be
        between 0 and 16
*/
static void bit_advance (bit_stream *bs, int n)
{
    bs->bitbuf >>= n;
    bs->bitcount -= n;

    if (bs->bitcount < 16)
    {
        // At this point it is possible for bs->p to advance past
        // the end of the data.  In that case we simply do not read
        // anything more into the buffer.  If we are on the last
        // byte the lword matches what is in that byte.
        bs->p += 2;

        if (bs->p < (bs->endpos - 1))
        {
            bs->bitbuf |= (lword(bs->p)<<bs->bitcount);
            bs->bitcount += 16;
        } else if (bs->p < bs->endpos) {
            bs->bitbuf |= (*(bs->p)<<bs->bitcount);
            bs->bitcount += 16;
        }
    }
}

//! Returns bits from the bit stream matching the mask and advances it
//! n places.
/*!
    @param bs Bit stream to read
    @param mask A 32 bit bit mask specifying which bits to read
    @param n Number of bits to advance the stream.  Must be
        between 0 and 16
*/
static std::uint32_t bit_read (bit_stream *bs, std::uint32_t mask, int n)
{
    std::uint32_t result = bit_peek(bs, mask);
    bit_advance(bs, n);
    return result;
}

//! Read a Huffman table out of the bit stream given.
/*!
    @param h huf_table structure to populate
    @param bs Bit stream pointing to the start of the Huffman table
        description
*/
static void read_huftable(huf_table *h, bit_stream *bs)
{
    int i, j, k, num;
    int leaflen[32];
    int leafmax;
    std::uint32_t codeb;     /* big-endian form of code. */

    num = bit_read(bs, 0x1F, 5);

    if(num == 0)
    {
        return;
    }

    leafmax = 1;
    for(i = 0; i < num; i++)
    {
        leaflen[i] = bit_read(bs, 0x0F, 4);
        if (leafmax < leaflen[i])
        {
            leafmax = leaflen[i];
        }
    }

    codeb = 0L;
    k = 0;
    for(i = 1; i <= leafmax; i++)
    {
        for(j = 0; j < num; j++)
        {
            if(leaflen[j] == i)
            {
                h->table[k].code = mirror(codeb, i);
                h->table[k].codelen = i;
                h->table[k].value = j;
                codeb++;
                k++;
            }
        }
        codeb <<= 1;
    }
    h->num = k;
}

//! Read a value out of the bit stream using the given Huffman table.
/*!
    @param h Huffman table to transcribe from
    @param bs bit stream
    @param p input data
    @return The value from the table with the matching bits, or -1 if none found.
*/
static std::uint32_t huf_read(huf_table *h, bit_stream *bs, const std::uint8_t **p)
{
    int i;
    std::uint32_t val;
    std::uint32_t mask;

    // Find the current bits in the table
    for (i = 0; i < h->num; i++)
    {
        mask = (1 << h->table[i].codelen) - 1;
        if(bit_peek(bs, mask) == h->table[i].code)
        {
            break;
        }
    }

    // No match found in table (error)
    if(i == h->num)
    {
        return -1;
    }

    bit_advance(bs, h->table[i].codelen);

    val = h->table[i].value;
    if (val >= 2)
    {
        val = 1 << (val-1);
        val |= bit_read(bs, val-1, h->table[i].value - 1);
    }
    return val;
}

std::size_t rnc_output_size(const std::uint8_t* input)
{
    return static_cast<std::size_t>(blong(input + 4));
}

std::size_t rnc_input_size(const std::uint8_t* input)
{
    return static_cast<std::size_t>(blong(input + 8) + rnc_header_size);
}

//! Decompresses RNC data
/*!
    @param input Pointer to compressed RNC data
    @param output Pointer to allocated memory region to hold uncompressed
        data.  The size of output must match the value specified in the
        4 byte segment of the input header starting at the 4th byte
        in Big-endian.
*/
rnc_status rnc_unpack(const std::uint8_t* input, std::uint8_t* output)
{
    const std::uint8_t *inputend;
    std::uint8_t *outputend;
    bit_stream input_bs;
    huf_table raw = {0}, dist = {0}, len = {0};
    std::uint32_t ch_count;
    std::uint32_t ret_len;
    std::uint32_t out_crc;
    if(blong(input) != rnc_signature)
    {
        return rnc_status::file_is_not_rnc;
    }
    ret_len = blong(input + 4);
    outputend = output + ret_len;
    inputend = input + 18 + blong(input + 8);

    //skip header
    input += 18;

    // Check the packed-data CRC. Also save the unpacked-data CRC
    // for later.
    if (rnc_crc(input, inputend - input) != bword(input - 4))
    {
        return rnc_status::packed_crc_error;
    }
    out_crc = bword(input - 6);

    //initialize the bitstream to the input and advance past the
    //first two bits as they don't have any understood use.
    bitread_init(&input_bs, input, inputend);
    bit_advance(&input_bs, 2);

    //process chunks
    while (output < outputend)
    {
        read_huftable(&raw, &input_bs); //raw byte length table
        read_huftable(&dist, &input_bs); //distance prior to copy table
        read_huftable(&len, &input_bs); //length bytes to copy table
        ch_count = bit_read(&input_bs, 0xFFFF, 16);

        while(true)
        {
            long length, posn;

            // Copy bit pattern to output based on lookup
            // of bytes from input.
            length = huf_read(&raw, &input_bs, &input);
            if(length == -1)
            {
                return rnc_status::huf_decode_error;
            }
            if(length)
            {
                while(length--)
                {
                    *output++ = *(input_bs.p++);
                }
                bitread_fix(&input_bs);
            }
            if(--ch_count <= 0)
            {
                break;
            }

            // Read position to copy output to
            posn = huf_read(&dist, &input_bs, &input);
            if(posn == -1)
            {
                return rnc_status::huf_decode_error;
            }
            posn += 1;

            // Read length of output to copy back
            length = huf_read(&len, &input_bs, &input);
            if(length == -1)
            {
                return rnc_status::huf_decode_error;
            }
            length += 2;

            // Copy length bytes from output back posn
            while (length > 0)
            {
                length--;
                *output = output[-posn];
                output++;
            }
        }
    }

    if(outputend != output)
    {
        return rnc_status::file_size_mismatch;
    }

    // Check the unpacked-data CRC.
    if (rnc_crc(outputend - ret_len, ret_len) != out_crc)
    {
        return rnc_status::unpacked_crc_error;
    }

    return rnc_status::ok;
}
