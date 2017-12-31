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

#include "config.h"
#include "th_lua.h"
#include <cstdio>

//! Layer for reading Theme Hospital files out of an .iso disk image
/*!
    An instance of this class can read files which contain an ISO 9660 file
    system (as described at http://alumnus.caltech.edu/~pje/iso9660.html and
    http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-119.pdf)
    which are typically called iso disk images. Once given a disk image, it
    searches for the Theme Hospital data files, and can then be used to read
    these data files.
*/
class IsoFilesystem
{
public:
    IsoFilesystem();
    ~IsoFilesystem();

    //! Set the character to be used between components in file paths
    void setPathSeparator(char cSeparator);

    //! Load an .iso disk image and search for Theme Hospital data files
    /*!
        \param fRawFile A file handle of an .iso disk image. This handle must
          remain valid for as long as the IsoFilesystem instance exists, and
          is not automatically closed by the IsoFilesystem instance.
        \return true on success, false on failure - call getError() for reason
    */
    bool initialise(FILE* fRawFile);

    //! Get the reason for the most recent failure
    /*!
        Can be called after initialise() or getFileData() return false.
    */
    const char* getError() const;

    typedef int file_handle_t;

    //! Find a file in the loaded .iso disk image
    /*!
        If (and only if) the given file could not be found, then isHandleGood()
        will return false on the returned handle.
    */
    file_handle_t findFile(const char* sPath) const;

    //! Iterate all files of the .iso disk image within a given directory
    /*!
        \param sPath The directory to iterate
        \param fnCallback The function to be called for each file. The first
          parameter to this function is pCallbackData. The second is the name
          of a file which is in sPath.
        \param pCallbackData Opaque value to be called to fnCallback.
    */
    void visitDirectoryFiles(const char* sPath,
                             void (*fnCallback)(void*, const char*),
                             void* pCallbackData) const;

    //! Test if a file handle from findFile() is good or is invalid
    static inline bool isHandleGood(file_handle_t x) {return x != 0;}

    //! Get the size (in bytes) of a file in the loaded .iso disk image
    /*!
        \param iFile A file handle returned by findFile()
    */
    uint32_t getFileSize(file_handle_t iFile) const;

    //! Get the contents of a file in the loaded .iso disk image
    /*!
        \param iFile A file handle returned by findFile()
        \param pBuffer The buffer to place the resulting data in
        \return true on success, false on failure - call getError() for reason
    */
    bool getFileData(file_handle_t iFile, uint8_t *pBuffer);

private:
    struct _file_t
    {
        char *sPath;
        uint32_t iSector;
        uint32_t iSize;
    };

    FILE* m_fRawFile;
    char* m_sError;
    _file_t* m_pFiles;
    size_t m_iNumFiles;
    size_t m_iFileTableSize;
    long m_iSectorSize;
    char m_cPathSeparator;

    //! Free any memory in use
    void _clear();

    //! Set the last error, printf-style
    void _setError(const char* sFormat, ...);

    //! Seek to a logical sector of the disk image
    bool _seekToSector(uint32_t iSector);

    //! Read data from the disk image
    bool _readData(uint32_t iByteCount, uint8_t *pBuffer);

    //! Scan the given array of directory entries for a Theme Hospital file
    /*!
        \param pDirEnt Pointer to a padded array of ISO 9660 directory entries.
        \param iDirEntsSize The number of bytes in the directory entry array.
        \param iLevel The recursion level (used to prevent infinite loops upon
          maliciously-formed .iso disk images).
        \return 0 if no Theme Hospital files were found. 1 if the given array
          contains a Theme Hospital data file. 2 if the given array is the
          top-level Theme Hospital data directory. Other values otherwise.
    */
    int _findHospDirectory(const uint8_t *pDirEnt, int iDirEntsSize, int iLevel);

    //! Build the list of Theme Hospital data files
    /*!
        \param iSector The ordinal of a logical sector containing a padded
          arrary of ISO 9660 directory entries.
        \param iDirEntsSize The number of bytes in the directory entry array.
        \param sPrefix The path name to prepend to filenames in the directory.
    */
    void _buildFileLookupTable(uint32_t iSector, int iDirEntsSize, const char* sPrefix);

    //! Return the next free entry in m_pFiles
    _file_t* _allocFileRecord();

    static char _normalise(char c);
    static int _fileNameComp(const void* lhs, const void* rhs);
    static void _trimIdentifierVersion(const uint8_t* sIdent, uint8_t& iLength);
};

int luaopen_iso_fs(lua_State *L);
