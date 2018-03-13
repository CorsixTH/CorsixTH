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
#include <cstring>
#include <cstdarg>
#include <cstdlib>
#include <vector>
#include <algorithm>

iso_filesystem::iso_filesystem()
{
    raw_file = nullptr;
    error = nullptr;
    files = nullptr;
    file_count = 0;
    file_table_size = 0;
    path_seperator = '\\';
}

iso_filesystem::~iso_filesystem()
{
    clear();
}

void iso_filesystem::clear()
{
    delete[] error;
    error = nullptr;

    if(files)
    {
        for(size_t i = 0; i < file_count; ++i)
            delete[] files[i].path;
        delete[] files;
        files = nullptr;
        file_count = 0;
        file_table_size = 0;
    }
}

void iso_filesystem::set_path_separator(char cSeparator)
{
    path_seperator = cSeparator;
}

enum iso_volume_descriptor_type : uint8_t
{
    vdt_privary_volume = 0x01,
    // Other type numbers are either reserved for future use, or are not
    // interesting to us.
    vdt_terminator = 0xFF,
};

enum iso_dir_ent_flag : uint8_t
{
    def_hidden = 0x01,
    def_directory = 0x02,
    def_multi_extent = 0x80,
};

template <class T> static inline T read_native_int(const uint8_t *p)
{
    // ISO 9660 commonly encodes multi-byte integers as little endian followed
    // by big endian. Note that the first byte of iEndianness will be a zero on
    // little endian systems, and a one on big endian.
    static const uint16_t iEndianness = 0x0100;
    return reinterpret_cast<const T*>(p)[*reinterpret_cast<const uint8_t*>(&iEndianness)];
}

bool iso_filesystem::initialise(FILE* fRawFile)
{
    raw_file = fRawFile;
    clear();

    // Until we know better, assume that sectors are 2048 bytes.
    sector_size = 2048;

    // The first 16 sectors are reserved for bootable media.
    // Volume descriptor records follow this, with one record per sector.
    for(uint32_t iSector = 16; seek_to_sector(iSector); ++iSector)
    {
        uint8_t aBuffer[190];
        if(!read_data(sizeof(aBuffer), aBuffer))
            break;
        // CD001 is a standard identifier, \x01 is a version number
        if(std::memcmp(aBuffer + 1, "CD001\x01", 6) == 0)
        {
            if(aBuffer[0] == vdt_privary_volume)
            {
                sector_size = read_native_int<uint16_t>(aBuffer + 128);
                find_hosp_directory(aBuffer + 156, 34, 0);
                if(file_count == 0)
                {
                    set_error("Could not find Theme Hospital data directory.");
                    return false;
                }
                else
                {
                    return true;
                }
            }
            else if(aBuffer[0] == vdt_terminator)
                break;
        }
    }
    set_error("Could not find primary volume descriptor.");
    return false;
}

int iso_filesystem::filename_compare(const void* lhs, const void* rhs)
{
    return std::strcmp(
        reinterpret_cast<const file_metadata*>(lhs)->path,
        reinterpret_cast<const file_metadata*>(rhs)->path);
}

char iso_filesystem::normalise(char c)
{
    if(c == '_') // underscore to hyphen
        return '-';
    else if('a' <= c && c <= 'z') // ASCII lowercase to ASCII uppercase
        return static_cast<char>(c - 'a' + 'A');
    else
        return c;
}

void iso_filesystem::trim_identifier_version(const uint8_t* sIdent, uint8_t& iLength)
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

int iso_filesystem::find_hosp_directory(const uint8_t *pDirEnt, int iDirEntsSize, int iLevel)
{
    // Sanity check
    // Apart from at the root level, directory record arrays must take up whole
    // sectors, whose sizes are powers of two and at least 2048.
    // The formal limit on directory depth is 8, so hitting 16 is insane.
    if((iLevel != 0 && (iDirEntsSize & 0x7FF)) || iLevel > 16)
        return 0;

    uint8_t *pBuffer = nullptr;
    uint32_t iBufferSize = 0;
    for(; iDirEntsSize > 0; iDirEntsSize -= *pDirEnt, pDirEnt += *pDirEnt)
    {
        // There is zero padding so that no record spans multiple sectors.
        if(*pDirEnt == 0)
        {
            --iDirEntsSize, ++pDirEnt;
            continue;
        }

        uint32_t iDataSector = read_native_int<uint32_t>(pDirEnt + 2);
        uint32_t iDataLength = read_native_int<uint32_t>(pDirEnt + 10);
        uint8_t iFlags = pDirEnt[25];
        uint8_t iIdentLength = pDirEnt[32];
        trim_identifier_version(pDirEnt + 33, iIdentLength);
        if(iFlags & def_directory)
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
                if(seek_to_sector(iDataSector) && read_data(iDataLength, pBuffer))
                {
                    int iFoundLevel = find_hosp_directory(pBuffer, iDataLength, iLevel + 1);
                    if(iFoundLevel != 0)
                    {
                        if(iFoundLevel == 2)
                            build_file_lookup_table(iDataSector, iDataLength, "");
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
                    if(normalise(pDirEnt[33 + i]) != sName[i])
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

void iso_filesystem::build_file_lookup_table(uint32_t iSector, int iDirEntsSize, const char* sPrefix)
{
    // Sanity check
    // Apart from at the root level, directory record arrays must take up whole
    // sectors, whose sizes are powers of two and at least 2048.
    // Path lengths shouldn't exceed 256 either (or at least not for the files
    // which we're interested in).
    size_t iLen = std::strlen(sPrefix);
    if((iLen != 0 && (iDirEntsSize & 0x7FF)) || (iLen > 256))
        return;

    uint8_t *pBuffer = new uint8_t[iDirEntsSize];
    if(!seek_to_sector(iSector) || !read_data(iDirEntsSize, pBuffer))
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

        uint32_t iDataSector = read_native_int<uint32_t>(pDirEnt + 2);
        uint32_t iDataLength = read_native_int<uint32_t>(pDirEnt + 10);
        uint8_t iFlags = pDirEnt[25];
        uint8_t iIdentLength = pDirEnt[32];
        trim_identifier_version(pDirEnt + 33, iIdentLength);

        // Build new path
        char *sPath = new char[iLen + iIdentLength + 2];
        std::memcpy(sPath, sPrefix, iLen);
#ifdef _MSC_VER
#pragma warning(disable: 4996)
#endif
        std::transform(pDirEnt + 33, pDirEnt + 33 + iIdentLength, sPath + iLen, normalise);
#ifdef _MSC_VER
#pragma warning(default: 4996)
#endif
        sPath[iLen + iIdentLength] = 0;

        if(iFlags & def_directory)
        {
            // None of the directories which we're interested in have length 1.
            // This also avoids the dummy "current" and "parent" directories.
            if(iIdentLength > 1)
            {
                sPath[iLen + iIdentLength] = path_seperator;
                sPath[iLen + iIdentLength + 1] = 0;
                build_file_lookup_table(iDataSector, iDataLength, sPath);
            }
        }
        else
        {
            file_metadata *file = allocate_file_record();
            file->path = sPath;
            file->sector = iDataSector;
            file->size = iDataLength;
            sPath = nullptr;
        }
        delete[] sPath;
    }
    delete[] pBuffer;

    if(iLen == 0)
    {
        // The lookup table will be ordered by the underlying ordering of the
        // disk, which isn't quite the ordering we want.
        qsort(files, file_count, sizeof(file_metadata), filename_compare);
    }
}

iso_filesystem::file_metadata* iso_filesystem::allocate_file_record()
{
    if(file_count == file_table_size)
    {
        size_t iNewTableSize = file_table_size * 2 + 1;
        file_metadata* pNewFiles = new file_metadata[iNewTableSize];
        std::memcpy(pNewFiles, files, sizeof(file_metadata) * file_count);
        delete[] files;
        files = pNewFiles;
        file_table_size = iNewTableSize;
    }
    return files + file_count++;
}

void iso_filesystem::visit_directory_files(const char* sPath,
                             void (*fnCallback)(void*, const char*),
                             void* pCallbackData) const
{
    size_t iLen = std::strlen(sPath) + 1;
    std::vector<char> sNormedPath(iLen);
    for(size_t i = 0; i < iLen; ++i)
        sNormedPath[i] = normalise(sPath[i]);

    // Inefficient (better would be to binary search for first and last files
    // which begin with sPath), but who cares - this isn't called often
    for(size_t i = 0; i < file_count; ++i)
    {
        const char *sName = files[i].path;
        if(std::strlen(sName) >= iLen && std::memcmp(sNormedPath.data(), sName, iLen - 1) == 0)
        {
            sName += iLen - 1;
            if(*sName == path_seperator)
                ++sName;
            if(std::strchr(sName, path_seperator) == nullptr)
                fnCallback(pCallbackData, sName);
        }
    }
}

iso_filesystem::file_handle iso_filesystem::find_file(const char* sPath) const
{
    size_t iLen = std::strlen(sPath) + 1;
    std::vector<char> sNormedPath(iLen);
    for(size_t i = 0; i < iLen; ++i)
        sNormedPath[i] = normalise(sPath[i]);

    // Standard binary search over sorted list of files
    int iLower = 0, iUpper = static_cast<int>(file_count);
    while(iLower != iUpper)
    {
        int iMid = (iLower + iUpper) / 2;
        int iComp = std::strcmp(sNormedPath.data(), files[iMid].path);
        if(iComp == 0)
            return iMid + 1;
        else if(iComp < 0)
            iUpper = iMid;
        else
            iLower = iMid + 1;
    }
    return 0;
}

uint32_t iso_filesystem::get_file_size(file_handle iFile) const
{
    if(iFile <= 0 || static_cast<size_t>(iFile) > file_count)
        return 0;
    else
        return files[iFile - 1].size;
}

bool iso_filesystem::get_file_data(file_handle iFile, uint8_t *pBuffer)
{
    if(iFile <= 0 || static_cast<size_t>(iFile) > file_count)
    {
        set_error("Invalid file handle.");
        return false;
    }
    else
    {
        return seek_to_sector(files[iFile - 1].sector) &&
               read_data(files[iFile - 1].size, pBuffer);
    }
}

const char* iso_filesystem::get_error() const
{
    return error;
}

bool iso_filesystem::seek_to_sector(uint32_t iSector)
{
    if(!raw_file)
    {
        set_error("No raw file.");
        return false;
    }
    if(std::fseek(raw_file, sector_size * static_cast<long>(iSector), SEEK_SET) == 0)
        return true;
    else
    {
        set_error("Unable to seek to sector %i.", static_cast<int>(iSector));
        return false;
    }
}

bool iso_filesystem::read_data(uint32_t iByteCount, uint8_t *pBuffer)
{
    if(!raw_file)
    {
        set_error("No raw file.");
        return false;
    }
    if(std::fread(pBuffer, 1, iByteCount, raw_file) == iByteCount)
        return true;
    else
    {
        set_error("Unable to read %i bytes.", static_cast<int>(iByteCount));
        return false;
    }
}

void iso_filesystem::set_error(const char* sFormat, ...)
{
    if(error == nullptr)
    {
        // None of the errors which we generate will be longer than 1024.
        error = new char[1024];
    }
    va_list a;
    va_start(a, sFormat);
#ifdef _MSC_VER
#pragma warning(disable: 4996)
#endif
    std::vsprintf(error, sFormat, a);
#ifdef _MSC_VER
#pragma warning(default: 4996)
#endif
    va_end(a);
}

static int l_isofs_new(lua_State *L)
{
    luaT_stdnew<iso_filesystem>(L, luaT_environindex, true);
    return 1;
}

static int l_isofs_set_path_separator(lua_State *L)
{
    iso_filesystem *pSelf = luaT_testuserdata<iso_filesystem>(L);
    pSelf->set_path_separator(luaL_checkstring(L, 2)[0]);
    lua_settop(L, 1);
    return 1;
}

static int l_isofs_set_root(lua_State *L)
{
    iso_filesystem *pSelf = luaT_testuserdata<iso_filesystem>(L);
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
        lua_pushstring(L, pSelf->get_error());
        return 2;
    }
}

static int l_isofs_read_contents(lua_State *L)
{
    iso_filesystem *pSelf = luaT_testuserdata<iso_filesystem>(L);
    const char* sFilename = luaL_checkstring(L, 2);
    iso_filesystem::file_handle iFile = pSelf->find_file(sFilename);
    if(!iso_filesystem::isHandleGood(iFile))
    {
        lua_pushnil(L);
        lua_pushfstring(L, "Could not find \'%s\' in .iso image", sFilename);
        return 2;
    }
    void* pBuffer = lua_newuserdata(L, pSelf->get_file_size(iFile));
    if(!pSelf->get_file_data(iFile, reinterpret_cast<uint8_t*>(pBuffer)))
    {
        lua_pushnil(L);
        lua_pushstring(L, pSelf->get_error());
        return 2;
    }
    lua_pushlstring(L, reinterpret_cast<char*>(pBuffer), pSelf->get_file_size(iFile));
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
    iso_filesystem *pSelf = luaT_testuserdata<iso_filesystem>(L);
    const char* sPath = luaL_checkstring(L, 2);
    lua_settop(L, 2);
    lua_newtable(L);
    pSelf->visit_directory_files(sPath, l_isofs_list_files_callback, L);
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

    luaT_pushcclosure(L, luaT_stdgc<iso_filesystem, luaT_environindex>, 0);
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
