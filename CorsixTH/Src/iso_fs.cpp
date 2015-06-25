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

#include "iso_fs.h"
#include <memory.h>
#include <cstring>
#include <cstdarg>
#include <cstdlib>
#ifdef CORSIX_TH_HAS_MALLOC_H
#include <malloc.h> // for alloca
#endif
#ifdef CORSIX_TH_HAS_ALLOCA_H
#include <alloca.h>
#endif
#include <algorithm>

IsoFilesystem::IsoFilesystem()
{
    m_fRawFile = NULL;
    m_sError = NULL;
    m_pFiles = NULL;
    m_iNumFiles = 0;
    m_iFileTableSize = 0;
    m_cPathSeparator = '\\';
}

IsoFilesystem::~IsoFilesystem()
{
    _clear();
}

void IsoFilesystem::_clear()
{
    delete[] m_sError;
    m_sError = NULL;

    if(m_pFiles)
    {
        for(size_t i = 0; i < m_iNumFiles; ++i)
            delete[] m_pFiles[i].sPath;
        delete[] m_pFiles;
        m_pFiles = NULL;
        m_iNumFiles = 0;
        m_iFileTableSize = 0;
    }
}

void IsoFilesystem::setPathSeparator(char cSeparator)
{
    m_cPathSeparator = cSeparator;
}

enum IsoVolumeDescriptorType
{
    VDT_PRIVARY_VOLUME = 0x01,
    // Other type numbers are either reserved for future use, or are not
    // interesting to us.
    VDT_TERMINATOR = 0xFF,
};

enum IsoDirEntFlag
{
    DEF_HIDDEN = 0x01,
    DEF_DIRECTORY = 0x02,
    DEF_MULTI_EXTENT = 0x80,
};

template <class T> static inline T ReadNativeInt(const uint8_t *p)
{
    // ISO 9660 commonly encodes multi-byte integers as little endian followed
    // by big endian. Note that the first byte of iEndianness will be a zero on
    // little endian systems, and a one on big endian.
    static const uint16_t iEndianness = 0x0100;
    return reinterpret_cast<const T*>(p)[*reinterpret_cast<const uint8_t*>(&iEndianness)];
}

bool IsoFilesystem::initialise(FILE* fRawFile)
{
    m_fRawFile = fRawFile;
    _clear();

    // Until we know better, assume that sectors are 2048 bytes.
    m_iSectorSize = 2048;

    // The first 16 sectors are reserved for bootable media.
    // Volume descriptor records follow this, with one record per sector.
    for(uint32_t iSector = 16; _seekToSector(iSector); ++iSector)
    {
        uint8_t aBuffer[190];
        if(!_readData(sizeof(aBuffer), aBuffer))
            break;
        // CD001 is a standard identifier, \x01 is a version number
        if(memcmp(aBuffer + 1, "CD001\x01", 6) == 0)
        {
            if(aBuffer[0] == VDT_PRIVARY_VOLUME)
            {
                m_iSectorSize = ReadNativeInt<uint16_t>(aBuffer + 128);
                _findHospDirectory(aBuffer + 156, 34, 0);
                if(m_iNumFiles == 0)
                {
                    _setError("Could not find Theme Hospital data directory.");
                    return false;
                }
                else
                {
                    return true;
                }
            }
            else if(aBuffer[0] == VDT_TERMINATOR)
                break;
        }
    }
    _setError("Could not find primary volume descriptor.");
    return false;
}

int IsoFilesystem::_fileNameComp(const void* lhs, const void* rhs)
{
    return strcmp(
        reinterpret_cast<const _file_t*>(lhs)->sPath,
        reinterpret_cast<const _file_t*>(rhs)->sPath);
}

char IsoFilesystem::_normalise(char c)
{
    if(c == '_') // underscore to hyphen
        return '-';
    else if('a' <= c && c <= 'z') // ASCII lowercase to ASCII uppercase
        return static_cast<char>(c - 'a' + 'A');
    else
        return c;
}

void IsoFilesystem::_trimIdentifierVersion(const uint8_t* sIdent, uint8_t& iLength)
{
    for(uint8_t i = 0; i < iLength; ++i)
    {
        if(sIdent[i] == ';')
        {
            iLength = i;
            return;
        }
    }
}

int IsoFilesystem::_findHospDirectory(const uint8_t *pDirEnt, int iDirEntsSize, int iLevel)
{
    // Sanity check
    // Apart from at the root level, directory record arrays must take up whole
    // sectors, whose sizes are powers of two and at least 2048.
    // The formal limit on directory depth is 8, so hitting 16 is insane.
    if((iLevel != 0 && (iDirEntsSize & 0x7FF)) || iLevel > 16)
        return 0;

    uint8_t *pBuffer = NULL;
    uint32_t iBufferSize = 0;
    for(; iDirEntsSize > 0; iDirEntsSize -= *pDirEnt, pDirEnt += *pDirEnt)
    {
        // There is zero padding so that no record spans multiple sectors.
        if(*pDirEnt == 0)
        {
            --iDirEntsSize, ++pDirEnt;
            continue;
        }

        uint32_t iDataSector = ReadNativeInt<uint32_t>(pDirEnt + 2);
        uint32_t iDataLength = ReadNativeInt<uint32_t>(pDirEnt + 10);
        uint8_t iFlags = pDirEnt[25];
        uint8_t iIdentLength = pDirEnt[32];
        _trimIdentifierVersion(pDirEnt + 33, iIdentLength);
        if(iFlags & DEF_DIRECTORY)
        {
            // The names "\x00" and "\x01" are used for the current directory
            // the parent directory respectively. We only want to visit these
            // when at the root level.
            if(iLevel == 0 || iIdentLength != 1 || pDirEnt[33] > 1)
            {
                if(iDataLength > iBufferSize)
                {
                    delete[] pBuffer;
                    iBufferSize = iDataLength;
                    pBuffer = new uint8_t[iBufferSize];
                }
                if(_seekToSector(iDataSector) && _readData(iDataLength, pBuffer))
                {
                    int iFoundLevel = _findHospDirectory(pBuffer, iDataLength, iLevel + 1);
                    if(iFoundLevel != 0)
                    {
                        if(iFoundLevel == 2)
                            _buildFileLookupTable(iDataSector, iDataLength, "");
                        delete[] pBuffer;
                        return iFoundLevel + 1;
                    }
                }
            }
        }
        else
        {
            // Look for VBLK-0.TAB to serve as indication that we've found the
            // Theme Hospital data.
            if(iIdentLength == 10)
            {
                const char sName[10] = {'V','B','L','K','-','0','.','T','A','B'};
                int i = 0;
                for(; i < 10; ++i)
                {
                    if(_normalise(pDirEnt[33 + i]) != sName[i])
                        break;
                }
                if(i == 10)
                {
                    return 1;
                }
            }
        }
    }
    delete[] pBuffer;

    return 0;
}

void IsoFilesystem::_buildFileLookupTable(uint32_t iSector, int iDirEntsSize, const char* sPrefix)
{
    // Sanity check
    // Apart from at the root level, directory record arrays must take up whole
    // sectors, whose sizes are powers of two and at least 2048.
    // Path lengths shouldn't exceed 256 either (or at least not for the files
    // which we're interested in).
    size_t iLen = strlen(sPrefix);
    if((iLen != 0 && (iDirEntsSize & 0x7FF)) || (iLen > 256))
        return;

    uint8_t *pBuffer = new uint8_t[iDirEntsSize];
    if(!_seekToSector(iSector) || !_readData(iDirEntsSize, pBuffer))
    {
        delete[] pBuffer;
        return;
    }
    uint8_t *pDirEnt = pBuffer;
    for(; iDirEntsSize > 0; iDirEntsSize -= *pDirEnt, pDirEnt += *pDirEnt)
    {
        // There is zero padding so that no record spans multiple sectors.
        if(*pDirEnt == 0)
        {
            --iDirEntsSize, ++pDirEnt;
            continue;
        }

        uint32_t iDataSector = ReadNativeInt<uint32_t>(pDirEnt + 2);
        uint32_t iDataLength = ReadNativeInt<uint32_t>(pDirEnt + 10);
        uint8_t iFlags = pDirEnt[25];
        uint8_t iIdentLength = pDirEnt[32];
        _trimIdentifierVersion(pDirEnt + 33, iIdentLength);

        // Build new path
        char *sPath = new char[iLen + iIdentLength + 2];
        memcpy(sPath, sPrefix, iLen);
#ifdef _MSC_VER
#pragma warning(disable: 4996)
#endif
        std::transform(pDirEnt + 33, pDirEnt + 33 + iIdentLength, sPath + iLen, _normalise);
#ifdef _MSC_VER
#pragma warning(default: 4996)
#endif
        sPath[iLen + iIdentLength] = 0;

        if(iFlags & DEF_DIRECTORY)
        {
            // None of the directories which we're interested in have length 1.
            // This also avoids the dummy "current" and "parent" directories.
            if(iIdentLength > 1)
            {
                sPath[iLen + iIdentLength] = m_cPathSeparator;
                sPath[iLen + iIdentLength + 1] = 0;
                _buildFileLookupTable(iDataSector, iDataLength, sPath);
            }
        }
        else
        {
            _file_t *pFile = _allocFileRecord();
            pFile->sPath = sPath;
            pFile->iSector = iDataSector;
            pFile->iSize = iDataLength;
            sPath = NULL;
        }
        delete[] sPath;
    }
    delete[] pBuffer;

    if(iLen == 0)
    {
        // The lookup table will be ordered by the underlying ordering of the
        // disk, which isn't quite the ordering we want.
        qsort(m_pFiles, m_iNumFiles, sizeof(_file_t), _fileNameComp);
    }
}

IsoFilesystem::_file_t* IsoFilesystem::_allocFileRecord()
{
    if(m_iNumFiles == m_iFileTableSize)
    {
        size_t iNewTableSize = m_iFileTableSize * 2 + 1;
        _file_t* pNewFiles = new _file_t[iNewTableSize];
        memcpy(pNewFiles, m_pFiles, sizeof(_file_t) * m_iNumFiles);
        delete[] m_pFiles;
        m_pFiles = pNewFiles;
        m_iFileTableSize = iNewTableSize;
    }
    return m_pFiles + m_iNumFiles++;
}

void IsoFilesystem::visitDirectoryFiles(const char* sPath,
                             void (*fnCallback)(void*, const char*),
                             void* pCallbackData) const
{
    size_t iLen = strlen(sPath) + 1;
    char *sNormedPath = (char*)alloca(iLen);
    for(size_t i = 0; i < iLen; ++i)
        sNormedPath[i] = _normalise(sPath[i]);

    // Inefficient (better would be to binary search for first and last files
    // which begin with sPath), but who cares - this isn't called often
    for(size_t i = 0; i < m_iNumFiles; ++i)
    {
        const char *sName = m_pFiles[i].sPath;
        if(strlen(sName) >= iLen && memcmp(sNormedPath, sName, iLen - 1) == 0)
        {
            sName += iLen - 1;
            if(*sName == m_cPathSeparator)
                ++sName;
            if(strchr(sName, m_cPathSeparator) == NULL)
                fnCallback(pCallbackData, sName);
        }
    }
}

IsoFilesystem::file_handle_t IsoFilesystem::findFile(const char* sPath) const
{
    size_t iLen = strlen(sPath) + 1;
    char *sNormedPath = (char*)alloca(iLen);
    for(size_t i = 0; i < iLen; ++i)
        sNormedPath[i] = _normalise(sPath[i]);

    // Standard binary search over sorted list of files
    int iLower = 0, iUpper = static_cast<int>(m_iNumFiles);
    while(iLower != iUpper)
    {
        int iMid = (iLower + iUpper) / 2;
        int iComp = strcmp(sNormedPath, m_pFiles[iMid].sPath);
        if(iComp == 0)
            return iMid + 1;
        else if(iComp < 0)
            iUpper = iMid;
        else
            iLower = iMid + 1;
    }
    return 0;
}

uint32_t IsoFilesystem::getFileSize(file_handle_t iFile) const
{
    if(iFile <= 0 || static_cast<size_t>(iFile) > m_iNumFiles)
        return 0;
    else
        return m_pFiles[iFile - 1].iSize;
}

bool IsoFilesystem::getFileData(file_handle_t iFile, uint8_t *pBuffer)
{
    if(iFile <= 0 || static_cast<size_t>(iFile) > m_iNumFiles)
    {
        _setError("Invalid file handle.");
        return false;
    }
    else
    {
        return _seekToSector(m_pFiles[iFile - 1].iSector) &&
               _readData(m_pFiles[iFile - 1].iSize, pBuffer);
    }
}

const char* IsoFilesystem::getError() const
{
    return m_sError;
}

bool IsoFilesystem::_seekToSector(uint32_t iSector)
{
    if(!m_fRawFile)
    {
        _setError("No raw file.");
        return false;
    }
    if(fseek(m_fRawFile, m_iSectorSize * static_cast<long>(iSector), SEEK_SET) == 0)
        return true;
    else
    {
        _setError("Unable to seek to sector %i.", static_cast<int>(iSector));
        return false;
    }
}

bool IsoFilesystem::_readData(uint32_t iByteCount, uint8_t *pBuffer)
{
    if(!m_fRawFile)
    {
        _setError("No raw file.");
        return false;
    }
    if(fread(pBuffer, 1, iByteCount, m_fRawFile) == iByteCount)
        return true;
    else
    {
        _setError("Unable to read %i bytes.", static_cast<int>(iByteCount));
        return false;
    }
}

void IsoFilesystem::_setError(const char* sFormat, ...)
{
    if(m_sError == NULL)
    {
        // None of the errors which we generate will be longer than 1024.
        m_sError = new char[1024];
    }
    va_list a;
    va_start(a, sFormat);
#ifdef _MSC_VER
#pragma warning(disable: 4996)
#endif
    vsprintf(m_sError, sFormat, a);
#ifdef _MSC_VER
#pragma warning(default: 4996)
#endif
    va_end(a);
}

static int l_isofs_new(lua_State *L)
{
    luaT_stdnew<IsoFilesystem>(L, luaT_environindex, true);
    return 1;
}

static int l_isofs_set_path_separator(lua_State *L)
{
    IsoFilesystem *pSelf = luaT_testuserdata<IsoFilesystem>(L);
    pSelf->setPathSeparator(luaL_checkstring(L, 2)[0]);
    lua_settop(L, 1);
    return 1;
}

static int l_isofs_set_root(lua_State *L)
{
    IsoFilesystem *pSelf = luaT_testuserdata<IsoFilesystem>(L);
    FILE *fIso = *luaT_testuserdata<FILE*>(L, 2);
    if(pSelf->initialise(fIso))
    {
        lua_pushvalue(L, 2);
        luaT_setenvfield(L, 1, "file");
        lua_settop(L, 1);
        return 1;
    }
    else
    {
        lua_pushnil(L);
        lua_pushstring(L, pSelf->getError());
        return 2;
    }
}

static int l_isofs_read_contents(lua_State *L)
{
    IsoFilesystem *pSelf = luaT_testuserdata<IsoFilesystem>(L);
    const char* sFilename = luaL_checkstring(L, 2);
    IsoFilesystem::file_handle_t iFile = pSelf->findFile(sFilename);
    if(!IsoFilesystem::isHandleGood(iFile))
    {
        lua_pushnil(L);
        lua_pushfstring(L, "Could not find \'%s\' in .iso image", sFilename);
        return 2;
    }
    void* pBuffer = lua_newuserdata(L, pSelf->getFileSize(iFile));
    if(!pSelf->getFileData(iFile, reinterpret_cast<uint8_t*>(pBuffer)))
    {
        lua_pushnil(L);
        lua_pushstring(L, pSelf->getError());
        return 2;
    }
    lua_pushlstring(L, reinterpret_cast<char*>(pBuffer), pSelf->getFileSize(iFile));
    return 1;
}

static void l_isofs_list_files_callback(void *p, const char* s)
{
    lua_State *L = reinterpret_cast<lua_State*>(p);
    lua_pushstring(L, s);
    lua_pushboolean(L, 1);
    lua_settable(L, 3);
}

static int l_isofs_list_files(lua_State *L)
{
    IsoFilesystem *pSelf = luaT_testuserdata<IsoFilesystem>(L);
    const char* sPath = luaL_checkstring(L, 2);
    lua_settop(L, 2);
    lua_newtable(L);
    pSelf->visitDirectoryFiles(sPath, l_isofs_list_files_callback, L);
    return 1;
}

int luaopen_iso_fs(lua_State *L)
{
    lua_settop(L, 1);
    if(!lua_tostring(L, 1))
    {
        lua_pushliteral(L, "ISO_FS");
        lua_replace(L, 1);
    }

    // Metatable
    lua_createtable(L, 0, 2);
    lua_pushvalue(L, -1);
    lua_replace(L, luaT_environindex);

    luaT_pushcclosure(L, luaT_stdgc<IsoFilesystem, luaT_environindex>, 0);
    lua_setfield(L, -2, "__gc");

    // Methods table
    luaT_pushcclosuretable(L, l_isofs_new, 0);
    lua_pushvalue(L, -1);
    lua_setfield(L, -3, "__index");

    lua_pushcfunction(L, l_isofs_set_path_separator);
    lua_setfield(L, -2, "setPathSeparator");

    lua_getfield(L, LUA_REGISTRYINDEX, LUA_FILEHANDLE);
    luaT_pushcclosure(L, l_isofs_set_root, 1);
    lua_setfield(L, -2, "setRoot");

    lua_pushcfunction(L, l_isofs_read_contents);
    lua_setfield(L, -2, "readContents");

    lua_pushcfunction(L, l_isofs_list_files);
    lua_setfield(L, -2, "listFiles");

    lua_pushvalue(L, 1);
    lua_pushvalue(L, 2);
#ifndef LUA_GLOBALSINDEX
    lua_pushglobaltable(L);
    lua_insert(L, -3);
    lua_settable(L, -3);
    lua_pop(L, 1);
#else
    lua_settable(L, LUA_GLOBALSINDEX);
#endif
    return 1;
}
