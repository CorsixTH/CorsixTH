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

#include "config.h"
#ifdef CORSIX_TH_USE_SDL_MIXER
#include <cstring>
#include <algorithm>
#include <iterator>
#include <new>
#include <vector>

/*!
    Utility class for reading or writing to memory as if it were a file.
*/
class memory_buffer
{
public:
    memory_buffer()
        : data(nullptr), pointer(nullptr), data_end(nullptr), buffer_end(nullptr)
    {
    }

    memory_buffer(const uint8_t* pData, size_t iLength)
    {
        data = pointer = (char*)pData;
        data_end = data + iLength;
        buffer_end = nullptr;
    }

    ~memory_buffer()
    {
        if(buffer_end != nullptr)
            delete[] data;
    }

    uint8_t* take_data(size_t *pLength)
    {
        if(pLength)
            *pLength = data_end - data;
        uint8_t* pResult = (unsigned char*)data;
        data = pointer = data_end = buffer_end = nullptr;
        return pResult;
    }

    size_t tell() const
    {
        return pointer - data;
    }

    bool seek(size_t position)
    {
        if(data + position > data_end)
        {
            if(!resize_buffer(position))
                return false;
        }
        pointer = data + position;
        return true;
    }

    bool skip(int distance)
    {
        if(distance < 0)
        {
            if(pointer + distance < data)
                return false;
        }
        return seek(pointer - data + distance);
    }

    bool scan_to(const void* pData, size_t iLength)
    {
        for(; pointer + iLength <= data_end; ++pointer)
        {
            if(std::memcmp(pointer, pData, iLength) == 0)
                return true;
        }
        return false;
    }

    const char* get_pointer() const
    {
        return pointer;
    }

    template <class T>
    bool read(T& value)
    {
        return read(&value, 1);
    }

    template <class T>
    bool read(T* values, size_t count)
    {
        if(pointer + sizeof(T) * count > data_end)
            return false;
        std::memcpy(values, pointer, sizeof(T) * count);
        pointer += sizeof(T) * count;
        return true;
    }

    unsigned int read_big_endian_uint24()
    {
        uint8_t iByte0, iByte1, iByte2;
        if(read(iByte0) && read(iByte1) && read(iByte2))
            return (((iByte0 << 8) | iByte1) << 8) | iByte2;
        else
            return 0;
    }

    unsigned int read_variable_length_uint()
    {
        unsigned int iValue = 0;
        uint8_t iByte;
        for(int i = 0; i < 4; ++i)
        {
            if(!read(iByte))
                return false;
            iValue = (iValue << 7) | static_cast<unsigned int>(iByte & 0x7F);
            if((iByte & 0x80) == 0)
                break;
        }
        return iValue;
    }

    template <class T>
    bool write(const T& value)
    {
        return write(&value, 1);
    }

    template <class T>
    bool write(const T* values, size_t count)
    {
        if(!skip(static_cast<int>(sizeof(T) * count)))
            return false;
        std::memcpy(pointer - sizeof(T) * count, values, sizeof(T) * count);
        return true;
    }

    bool write_big_endian_uint16(uint16_t iValue)
    {
        return write(byte_swap(iValue));
    }

    bool write_big_endian_uint32(uint32_t iValue)
    {
        return write(byte_swap(iValue));
    }

    bool write_variable_length_uint(unsigned int iValue)
    {
        int iByteCount = 1;
        unsigned int iBuffer = iValue & 0x7F;
        for(; iValue >>= 7; ++iByteCount)
        {
            iBuffer = (iBuffer << 8) | 0x80 | (iValue & 0x7F);
        }
        for(int i = 0; i < iByteCount; ++i)
        {
            uint8_t iByte = iBuffer & 0xFF;
            if(!write(iByte))
                return false;
            iBuffer >>= 8;
        }
        return true;
    }

    bool is_end_of_buffer() const
    {
        return pointer == data_end;
    }

private:
    template <class T>
    static T byte_swap(T value)
    {
        T swapped = 0;
        for(int i = 0; i < static_cast<int>(sizeof(T)) * 8; i += 8)
        {
            swapped = static_cast<T>(swapped | ((value >> i) & 0xFF) << (sizeof(T) * 8 - 8 - i));
        }
        return swapped;
    }

    bool resize_buffer(size_t size)
    {
        if(data + size <= buffer_end)
        {
            data_end = data + size;
            return true;
        }

        char *pNewData = new (std::nothrow) char[size * 2];
        if(pNewData == nullptr)
            return false;
        size_t iOldLength = data_end - data;
        std::memcpy(pNewData, data, size > iOldLength ? iOldLength : size);
        pointer = pointer - data + pNewData;
        if(buffer_end != nullptr)
            delete[] data;
        data = pNewData;
        data_end = pNewData + size;
        buffer_end = pNewData + size * 2;
        return true;
    }

    char *data, *pointer, *data_end, *buffer_end;
};

struct midi_token
{
    int time;
    unsigned int buffer_length;
    const char *buffer;
    uint8_t    type;
    uint8_t    data;
};

static bool operator < (const midi_token& oLeft, const midi_token& oRight)
{
    return oLeft.time < oRight.time;
}

struct midi_token_list : std::vector<midi_token>
{
    midi_token* append(int iTime, uint8_t iType)
    {
        push_back(midi_token());
        midi_token* pToken = &back();
        pToken->time = iTime;
        pToken->type = iType;
        return pToken;
    }
};

uint8_t* transcode_xmi_to_midi(const unsigned char* xmi_data,
                                 size_t xmi_length, size_t* midi_length)
{
    memory_buffer bufInput(xmi_data, xmi_length);
    memory_buffer bufOutput;

    if(!bufInput.scan_to("EVNT", 4) || !bufInput.skip(8))
        return nullptr;

    midi_token_list lstTokens;
    midi_token* pToken;
    int iTokenTime = 0;
    int iTempo = 500000;
    bool bTempoSet = false;
    bool bEnd = false;
    uint8_t iTokenType, iExtendedType;

    while(!bufInput.is_end_of_buffer() && !bEnd)
    {
        while(true)
        {
            if(!bufInput.read(iTokenType))
                return nullptr;

            if(iTokenType & 0x80)
                break;
            else
                iTokenTime += static_cast<int>(iTokenType) * 3;
        }
        pToken = lstTokens.append(iTokenTime, iTokenType);
        pToken->buffer = bufInput.get_pointer() + 1;
        switch(iTokenType & 0xF0)
        {
        case 0xC0:
        case 0xD0:
            if(!bufInput.read(pToken->data))
                return nullptr;
            pToken->buffer = nullptr;
            break;
        case 0x80:
        case 0xA0:
        case 0xB0:
        case 0xE0:
            if(!bufInput.read(pToken->data))
                return nullptr;
            if(!bufInput.skip(1))
                return nullptr;
            break;
        case 0x90:
            if(!bufInput.read(iExtendedType))
                return nullptr;
            pToken->data = iExtendedType;
            if(!bufInput.skip(1))
                return nullptr;
            pToken = lstTokens.append(iTokenTime + bufInput.read_variable_length_uint() * 3,
                iTokenType);
            pToken->data = iExtendedType;
            pToken->buffer = "\0";
            break;
        case 0xF0:
            iExtendedType = 0;
            if(iTokenType == 0xFF)
            {
                if(!bufInput.read(iExtendedType))
                    return nullptr;

                if(iExtendedType == 0x2F)
                    bEnd = true;
                else if(iExtendedType == 0x51)
                {
                    if(!bTempoSet)
                    {
                        bufInput.skip(1);
                        iTempo = bufInput.read_big_endian_uint24() * 3;
                        bTempoSet = true;
                        bufInput.skip(-4);
                    }
                    else
                    {
                        lstTokens.pop_back();
                        if(!bufInput.skip(bufInput.read_variable_length_uint()))
                            return nullptr;
                        break;
                    }
                }
            }
            pToken->data = iExtendedType;
            pToken->buffer_length = bufInput.read_variable_length_uint();
            pToken->buffer = bufInput.get_pointer();
            if(!bufInput.skip(pToken->buffer_length))
                return nullptr;
            break;
        }
    }

    if(lstTokens.empty())
        return nullptr;
    if(!bufOutput.write("MThd\0\0\0\x06\0\0\0\x01", 12))
        return nullptr;
    if(!bufOutput.write_big_endian_uint16(static_cast<uint16_t>((iTempo * 3) / 25000)))
        return nullptr;
    if(!bufOutput.write("MTrk\xBA\xAD\xF0\x0D", 8))
        return nullptr;

    std::sort(lstTokens.begin(), lstTokens.end());

    iTokenTime = 0;
    iTokenType = 0;
    bEnd = false;

    for(midi_token_list::iterator itr = lstTokens.begin(),
        itrEnd = lstTokens.end(); itr != itrEnd && !bEnd; ++itr)
    {
        if(!bufOutput.write_variable_length_uint(itr->time - iTokenTime))
            return nullptr;
        iTokenTime = itr->time;
        if(itr->type >= 0xF0)
        {
            if(!bufOutput.write(iTokenType = itr->type))
                return nullptr;
            if(iTokenType == 0xFF)
            {
                if(!bufOutput.write(itr->data))
                    return nullptr;
                if(itr->data == 0x2F)
                    bEnd = true;
            }
            if(!bufOutput.write_variable_length_uint(itr->buffer_length))
                return nullptr;
            if(!bufOutput.write(itr->buffer, itr->buffer_length))
                return nullptr;
        }
        else
        {
            if(itr->type != iTokenType)
            {
                if(!bufOutput.write(iTokenType = itr->type))
                    return nullptr;
            }
            if(!bufOutput.write(itr->data))
                return nullptr;
            if(itr->buffer)
            {
                if(!bufOutput.write(itr->buffer, 1))
                    return nullptr;
            }
        }
    }

    uint32_t iLength = static_cast<uint32_t>(bufOutput.tell() - 22);
    bufOutput.seek(18);
    bufOutput.write_big_endian_uint32(iLength);

    return bufOutput.take_data(midi_length);
}

#endif
