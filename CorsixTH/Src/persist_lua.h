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
#include <stdlib.h>
#ifdef CORSIX_TH_HAS_MALLOC_H
#include <malloc.h> // for alloca
#endif
#ifdef CORSIX_TH_HAS_ALLOCA_H
#include <alloca.h>
#endif

template <class T> struct LuaPersistVInt {};
template <> struct LuaPersistVInt<int> {typedef unsigned int T;};

//! Interface used for persisting Lua objects
/*!
    When userdata are persisted, they get an instance of this interface for
    writing binary data and other Lua objects.
*/
class LuaPersistWriter
{
public:
    virtual ~LuaPersistWriter();

    virtual lua_State* getStack() = 0;
    virtual void writeStackObject(int iIndex) = 0;
    virtual void writeByteStream(const uint8_t *pBytes, size_t iCount) = 0;
    virtual void setError(const char *sError) = 0;

    // writeStackObject for userdata without growing the Lua call stack
    // The given index should be a userdata whose __persist metamethod supports
    // fast persistance (being called with extra arguments and the wrong
    // environment / upvalues).
    virtual void fastWriteStackObject(int iIndex) = 0;

    // Writes an unsigned integer as a variable number of bytes
    // Endian independant and underlying type size independant
    template <class T>
    void writeVUInt(T tValue)
    {
        T tTemp(tValue);
        int iNumBytes;
        for(iNumBytes = 1; tTemp >= (T)0x80; tTemp /= (T)0x80)
            ++iNumBytes;
        if(iNumBytes == 1)
        {
            uint8_t iByte = (uint8_t)tValue;
            writeByteStream(&iByte, 1);
        }
        else
        {
            uint8_t *pBytes = (uint8_t*)alloca(iNumBytes);
            pBytes[iNumBytes - 1] = 0x7F & (uint8_t)(tValue);
            for(int i = 1; i < iNumBytes; ++i)
            {
                tValue /= (T)0x80;
                pBytes[iNumBytes - 1 - i] = 0x80 | (0x7F & (uint8_t)tValue);
            }
            writeByteStream(pBytes, iNumBytes);
        }
    }

    template <class T>
    void writeVInt(T tValue)
    {
        typename LuaPersistVInt<T>::T tValueToWrite;
        if(tValue >= 0)
        {
            tValueToWrite = (typename LuaPersistVInt<T>::T)tValue;
            tValueToWrite <<= 1;
        }
        else
        {
            tValueToWrite = (typename LuaPersistVInt<T>::T)(-(tValue + 1));
            tValueToWrite <<= 1;
            tValueToWrite |= 1;
        }
        writeVUInt(tValueToWrite);
    }

    template <class T>
    void writeVFloat(T fValue)
    {
        writeByteStream(reinterpret_cast<uint8_t*>(&fValue), sizeof(T));
    }
};

//! Interface used for depersisting Lua objects
/*!
    When userdata are depersisted, they get an instance of this interface for
    reading binary data and other Lua objects.
*/
class LuaPersistReader
{
public:
    virtual ~LuaPersistReader();

    virtual lua_State* getStack() = 0;
    virtual bool readStackObject() = 0;
    virtual bool readByteStream(uint8_t *pBytes, size_t iCount) = 0;
    virtual void setError(const char *sError) = 0;

    // Reads an integer previously written by LuaPersistWriter::writeVUInt()
    template <class T>
    bool readVUInt(T& tValue)
    {
        T tTemp(0);
        uint8_t iByte;

        while(true)
        {
            if(!readByteStream(&iByte, 1))
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
    bool readVInt(T& tValue)
    {
        typename LuaPersistVInt<T>::T tWrittenValue;
        if(!readVUInt(tWrittenValue))
            return false;
        if(tWrittenValue & 1)
            tValue = (-(T)(tWrittenValue >> 1)) - 1;
        else
            tValue = static_cast<T>(tWrittenValue >> 1);
        return true;
    }

    template <class T>
    bool readVFloat(T& fValue)
    {
        if(!readByteStream(reinterpret_cast<uint8_t*>(&fValue), sizeof(T)))
            return false;
        return true;
    }
};

int luaopen_persist(lua_State *L);

#endif // CORSIX_TH_PERSIST_LUA_H_
