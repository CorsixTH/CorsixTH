/*
Copyright (c) 2010 Peter "Corsix" Cawley

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

#ifndef CORSIX_TH_PERSIST_LUA_H_
#define CORSIX_TH_PERSIST_LUA_H_
#include "config.h"
#include "th_lua.h"
#include <vector>
#include <cstdlib>

template <class T> struct lua_persist_int {};
template <> struct lua_persist_int<int> {typedef unsigned int T;};

//! Interface used for persisting Lua objects
/*!
    When userdata are persisted, they get an instance of this interface for
    writing binary data and other Lua objects.
*/
class lua_persist_writer
{
public:
    virtual ~lua_persist_writer() = default;

    virtual lua_State* get_stack() = 0;
    virtual void write_stack_object(int iIndex) = 0;
    virtual void write_byte_stream(const uint8_t *pBytes, size_t iCount) = 0;
    virtual void set_error(const char *sError) = 0;

    // write_stack_object for userdata without growing the Lua call stack
    // The given index should be a userdata whose __persist metamethod supports
    // fast persistance (being called with extra arguments and the wrong
    // environment / upvalues).
    virtual void fast_write_stack_object(int iIndex) = 0;

    // Writes an unsigned integer as a variable number of bytes
    // Endian independant and underlying type size independant
    template <class T>
    void write_uint(T tValue)
    {
        T tTemp(tValue);
        int iNumBytes;
        for(iNumBytes = 1; tTemp >= (T)0x80; tTemp /= (T)0x80)
            ++iNumBytes;
        if(iNumBytes == 1)
        {
            uint8_t iByte = (uint8_t)tValue;
            write_byte_stream(&iByte, 1);
        }
        else
        {
            std::vector<uint8_t> bytes(iNumBytes);
            bytes[iNumBytes - 1] = 0x7F & (uint8_t)(tValue);
            for(int i = 1; i < iNumBytes; ++i)
            {
                tValue /= (T)0x80;
                bytes[iNumBytes - 1 - i] = 0x80 | (0x7F & (uint8_t)tValue);
            }
            write_byte_stream(bytes.data(), iNumBytes);
        }
    }

    template <class T>
    void write_int(T tValue)
    {
        typename lua_persist_int<T>::T tValueToWrite;
        if(tValue >= 0)
        {
            tValueToWrite = (typename lua_persist_int<T>::T)tValue;
            tValueToWrite <<= 1;
        }
        else
        {
            tValueToWrite = (typename lua_persist_int<T>::T)(-(tValue + 1));
            tValueToWrite <<= 1;
            tValueToWrite |= 1;
        }
        write_uint(tValueToWrite);
    }

    template <class T>
    void write_float(T fValue)
    {
        write_byte_stream(reinterpret_cast<uint8_t*>(&fValue), sizeof(T));
    }
};

//! Interface used for depersisting Lua objects
/*!
    When userdata are depersisted, they get an instance of this interface for
    reading binary data and other Lua objects.
*/
class lua_persist_reader
{
public:
    virtual ~lua_persist_reader() = default;

    virtual lua_State* get_stack() = 0;
    virtual bool read_stack_object() = 0;
    virtual bool read_byte_stream(uint8_t *pBytes, size_t iCount) = 0;
    virtual void set_error(const char *sError) = 0;

    // Reads an integer previously written by lua_persist_writer::write_uint()
    template <class T>
    bool read_uint(T& tValue)
    {
        T tTemp(0);
        uint8_t iByte;

        while(true)
        {
            if(!read_byte_stream(&iByte, 1))
                return false;
            if(iByte & 0x80)
            {
                tTemp = static_cast<T>(tTemp | (iByte & 0x7F));
                tTemp = static_cast<T>(tTemp << 7);
            }
            else
            {
                tTemp = static_cast<T>(tTemp | iByte);
                break;
            }
        }

        tValue = tTemp;
        return true;
    }

    template <class T>
    bool read_int(T& tValue)
    {
        typename lua_persist_int<T>::T tWrittenValue;
        if(!read_uint(tWrittenValue))
            return false;
        if(tWrittenValue & 1)
            tValue = (-(T)(tWrittenValue >> 1)) - 1;
        else
            tValue = static_cast<T>(tWrittenValue >> 1);
        return true;
    }

    template <class T>
    bool read_float(T& fValue)
    {
        if(!read_byte_stream(reinterpret_cast<uint8_t*>(&fValue), sizeof(T)))
            return false;
        return true;
    }
};

int luaopen_persist(lua_State *L);

#endif // CORSIX_TH_PERSIST_LUA_H_
