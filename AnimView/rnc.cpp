/*
    RNC decompression library.

    Original code was from http://www.yoda.arachsys.com/dk/utils.html,
    which links to http://www.yoda.arachsys.com/dk/utilsrc.zip
    which itself includes this LICENSE.TXT:

The MIT License (MIT)

Copyright (c) 2009 Jon Skeet, Simon Tatham

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the"Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

    Modifications made to the original code include:
      * Const correctness
      * Prebuilt CRC table
      * Indentation and code style
*/

#include "th.h"

#define RNC_OK                  0
#define RNC_FILE_IS_NOT_RNC    -1
#define RNC_HUF_DECODE_ERROR   -2
#define RNC_FILE_SIZE_MISMATCH -3
#define RNC_PACKED_CRC_ERROR   -4
#define RNC_UNPACKED_CRC_ERROR -5
#define RNC_SIGNATURE 0x524E4301       /* "RNC\001" */

static const unsigned short rnc_crc_table[256] = {
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
    unsigned long bitbuf;           /* holds between 16 and 32 bits */
    int bitcount;               /* how many bits does bitbuf hold? */
};

struct huf_table
{
    int num;                   /* number of nodes in the tree */
    struct
    {
        unsigned long code;
        int codelen;
        int value;
    } table[32];
};

/*
 * Calculate a CRC, the RNC way.
 */
static long rnc_crc(const unsigned char* data, long len)
{
    unsigned short val = 0;

    while(len--)
    {
        val ^= *data++;
        val = (val >> 8) ^ rnc_crc_table[val & 0xFF];
    }

    return val;
}


/*
 * Return the big-endian longword at p.
 */
static unsigned long blong (const unsigned char *p)
{
    unsigned long n;
    n = p[0];
    n = (n << 8) + p[1];
    n = (n << 8) + p[2];
    n = (n << 8) + p[3];
    return n;
}

/*
 * Return the little-endian longword at p.
 */
static unsigned long llong (const unsigned char *p)
{
    unsigned long n;
    n = p[3];
    n = (n << 8) + p[2];
    n = (n << 8) + p[1];
    n = (n << 8) + p[0];
    return n;
}

/*
 * Return the big-endian word at p.
 */
static unsigned long bword (const unsigned char *p)
{
    unsigned long n;
    n = p[0];
    n = (n << 8) + p[1];
    return n;
}

/*
 * Return the little-endian word at p.
 */
static unsigned long lword (const unsigned char *p)
{
    unsigned long n;
    n = p[1];
    n = (n << 8) + p[0];
    return n;
}

/*
 * Mirror the bottom n bits of x.
 */
static unsigned long mirror (unsigned long x, int n)
{
    unsigned long top = 1 << (n-1), bottom = 1;
    while (top > bottom)
    {
        unsigned long mask = top | bottom;
        unsigned long masked = x & mask;
        if (masked != 0 && masked != mask)
        {
            x ^= mask;
        }
        top >>= 1;
        bottom <<= 1;
    }
    return x;
}


/*
 * Initialises a bit stream with the first two bytes of the packed
 * data.
 */
static void bitread_init (bit_stream *bs, const unsigned char **p)
{
    bs->bitbuf = lword (*p);
    bs->bitcount = 16;
}

/*
 * Fixes up a bit stream after literals have been read out of the
 * data stream.
 */
static void bitread_fix (bit_stream *bs, const unsigned char **p)
{
    bs->bitcount -= 16;
    bs->bitbuf &= (1<<bs->bitcount)-1; /* remove the top 16 bits */
    bs->bitbuf |= (lword(*p)<<bs->bitcount);/* replace with what's at *p */
    bs->bitcount += 16;
}

/*
 * Returns some bits.
 */
static unsigned long bit_peek (bit_stream *bs, const unsigned long mask)
{
    return bs->bitbuf & mask;
}

/*
 * Advances the bit stream.
 */
static void bit_advance (bit_stream *bs, int n, const unsigned char **p)
{
    bs->bitbuf >>= n;
    bs->bitcount -= n;
    if (bs->bitcount < 16)
    {
        (*p) += 2;
        bs->bitbuf |= (lword(*p)<<bs->bitcount);
        bs->bitcount += 16;
    }
}

/*
 * Reads some bits in one go (ie the above two routines combined).
 */
static unsigned long bit_read (bit_stream *bs, unsigned long mask, int n, const unsigned char **p)
{
    unsigned long result = bit_peek(bs, mask);
    bit_advance(bs, n, p);
    return result;
}

/*
 * Read a Huffman table out of the bit stream and data stream given.
 */
static void read_huftable(huf_table *h, bit_stream *bs, const unsigned char **p)
{
    int i, j, k, num;
    int leaflen[32];
    int leafmax;
    unsigned long codeb;           /* big-endian form of code */

    num = bit_read(bs, 0x1F, 5, p);

    if(num == 0)
    {
        return;
    }

    leafmax = 1;
    for(i = 0; i < num; i++)
    {
        leaflen[i] = bit_read(bs, 0x0F, 4, p);
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

/*
 * Read a value out of the bit stream using the given Huffman table.
 */
static unsigned long huf_read(huf_table *h, bit_stream *bs, const unsigned char **p)
{
    int i;
    unsigned long val;

    for (i = 0; i < h->num; i++)
    {
        unsigned long mask = (1 << h->table[i].codelen) - 1;
        if(bit_peek(bs, mask) == h->table[i].code)
        {
            break;
        }
    }
    if(i == h->num)
    {
        return -1;
    }
    bit_advance(bs, h->table[i].codelen, p);

    val = h->table[i].value;

    if (val >= 2)
    {
        val = 1 << (val-1);
        val |= bit_read(bs, val-1, h->table[i].value - 1, p);
    }
    return val;
}

static int rnc_unpack(const unsigned char* input, unsigned char* output)
{
    const unsigned char *inputend;
    unsigned char *outputend;
    bit_stream bs;
    huf_table raw, dist, len;
    unsigned long ch_count;
    unsigned long ret_len;
    unsigned out_crc;
    if(blong(input) != RNC_SIGNATURE)
    {
        return RNC_FILE_IS_NOT_RNC;
    }
    ret_len = blong(input + 4);
    outputend = output + ret_len;
    inputend = input + 18 + blong(input + 8);

    input += 18;               /* skip header */

    /*
     * Check the packed-data CRC. Also save the unpacked-data CRC
     * for later.
     */
    if(rnc_crc(input, inputend-input) != bword(input - 4))
    {
        return RNC_PACKED_CRC_ERROR;
    }
    out_crc = bword(input - 6);

    bitread_init(&bs, &input);
    bit_advance(&bs, 2, &input);      /* discard first two bits */

    /*
     * Process chunks.
     */
    while (output < outputend)
    {
        read_huftable(&raw, &bs, &input);
        read_huftable(&dist, &bs, &input);
        read_huftable(&len, &bs, &input);
        ch_count = bit_read(&bs, 0xFFFF, 16, &input);

        while(true)
        {
            long length, posn;

            length = huf_read(&raw, &bs, &input);
            if(length == -1)
            {
                return RNC_HUF_DECODE_ERROR;
            }
            if(length)
            {
                while(length--)
                    *output++ = *input++;
                bitread_fix(&bs, &input);
            }
            if(--ch_count <= 0)
            {
                break;
            }

            posn = huf_read(&dist, &bs, &input);
            if(posn == -1)
            {
                return RNC_HUF_DECODE_ERROR;
            }
            length = huf_read(&len, &bs, &input);
            if(length == -1)
            {
                return RNC_HUF_DECODE_ERROR;
            }
            posn += 1;
            length += 2;
            while(length--)
            {
                *output = output[-posn];
                output++;
            }
        }
    }

    if(outputend != output)
    {
        return RNC_FILE_SIZE_MISMATCH;
    }

    /*
     * Check the unpacked-data CRC.
     */
    if(rnc_crc(outputend - ret_len, ret_len) != out_crc)
    {
        return RNC_UNPACKED_CRC_ERROR;
    }

    return RNC_OK;
}

unsigned char* THAnimations::Decompress(unsigned char* pData, size_t& iLength)
{
    unsigned long outlen = blong(pData + 4);
    unsigned char* outbuf = new unsigned char[outlen];
    if(rnc_unpack(pData, outbuf) == RNC_OK)
    {
        delete[] pData;
        iLength = outlen;
        return outbuf;
    }
    else
    {
        delete[] pData;
        delete[] outbuf;
        iLength = 0;
        return NULL;
    }
}
