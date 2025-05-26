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

#include <algorithm>
#include <cstdarg>
#include <cstdio>
#include <cstring>
#include <exception>
#include <iterator>
#include <memory>
#include <stdexcept>
#include <utility>
#include <vector>

#include "th.h"

namespace {

enum iso_volume_descriptor_type : uint8_t {
  vdt_primary_volume = 0x01,
  // Other type numbers are either reserved for future use, or are not
  // interesting to us.
  vdt_terminator = 0xFF,
};

/// Flag values for directory table entries. The flag itself is a bitmask.
enum iso_dir_ent_flag : uint8_t {
  def_hidden = 0x01,
  def_directory = 0x02,
  def_multi_extent = 0x80,
};

/// Offset to the 32bit sector of the file data
/// from the start of the file entry.
constexpr ptrdiff_t file_sector_offset = 2;

/// Offset to the 32bit length of the file data
/// from the start of the file entry
constexpr ptrdiff_t file_data_length_offset = 10;

/// The offset of the file flags (e.g. directory vs file)
/// from the start of the file entry.
constexpr ptrdiff_t file_flags_offset = 25;

/// The offset of the byte that stores the length of the filename
/// from the start of the file entry.
constexpr ptrdiff_t filename_length_offset = 32;

/// The offset of the start of the filename or directory identifier
/// from the start of the file entry.
constexpr ptrdiff_t filename_offset = 33;

/// The minimum valid size of a valid file entry.
/// Accounts for all fixed header value offsets and even number padding.
constexpr uint8_t minimum_file_entry_size = 34;

/// Formal depth limit in spec is 8. We allows for loose implementations.
constexpr int max_directory_depth = 16;

/// Reasonably unique name of a file from Theme Hospital that can be used to
/// indicate that we've loaded the right directory.
constexpr const char* vblk_0_filename = "VBLK-0.TAB";

/// Sector sizes can vary, but they must be powers of two, and the minimum
/// size is 2048.
constexpr size_t min_sector_size = 2048;

/// Offset of the sector size from the primary volume descriptor
constexpr size_t sector_size_offset = 128;

/// Offset of the root directory entry from the primary volume descriptor
constexpr ptrdiff_t root_directory_offset = 156;

/// The root directory entry is a fixed size.
constexpr size_t root_directory_entry_size = 34;

/// ISO 9660 has a 32kb reserve area at the beginning of the file formal
/// e.g. boot information.
constexpr uint32_t first_filesystem_sector = 16;

/// Finds the length of the file name within a file identifier.
/// The file identifier is `filename;file id`.
void trim_file_id(const uint8_t* sIdent, uint8_t& iLength) {
  for (uint8_t i = 0; i < iLength; ++i) {
    if (sIdent[i] == ';') {
      iLength = i;
      return;
    }
  }
}

/// Convert character to filename normalized format conforming to ISO filename
/// limitations. All letters are converted to upper case, and `_` to `-`.
char normalise(char c) {
  if (c == '_') {
    return '-';
  } else if ('a' <= c && c <= 'z') {
    return static_cast<char>(c - 'a' + 'A');
  } else {
    return c;
  }
}

/// Convert length bytes from the start pointer to a normalized filename
/// string. All ASCII letters are converted to upper case, and `_` to `-`.
std::string normalise(const uint8_t* start, size_t length) {
  std::string ret;
  const uint8_t* p = start;
  for (size_t i = 0; i < length; i++) {
    ret.push_back(normalise(static_cast<char>(*p)));
    ++p;
  }
  return ret;
}

/// Convert c string to normalized filename string. All ASCII letters are
/// converted to upper case, and `_` to `-`.
std::string normalise(const char* str) {
  std::string ret;
  const char* p = str;
  while (*p != '\0') {
    ret.push_back(normalise(*p));
    ++p;
  }
  return ret;
}

/// A file entry from the directory table
class iso_file_entry {
 public:
  /// Construct dummy entry.
  iso_file_entry() = default;

  /// Construct entry from the given memory location.
  /// The first byte is the size of the entry. Other useful headers are read
  /// from their offsets from that location.
  ///
  /// \param Pointer to first byte of file entry in directory table.
  iso_file_entry(const uint8_t* b) {
    uint8_t size = *b;
    if (size < minimum_file_entry_size) {
      throw std::runtime_error("size specified for file entry is too small.");
    }

    uint8_t filename_length = b[filename_length_offset];
    if (filename_length + filename_offset > size) {
      throw std::runtime_error("size specified for file entry is too small.");
    }
    trim_file_id(b + filename_offset, filename_length);
    filename = normalise(b + filename_offset, filename_length);

    data_sector = bytes_to_uint32_le(b + file_sector_offset);
    data_length = bytes_to_uint32_le(b + file_data_length_offset);
    flags = b[file_flags_offset];
  }

  /// Logical location of the data for this file in the ISO image.
  uint32_t data_sector;

  /// The length of the data for this file.
  uint32_t data_length;

  /// Flags that indicate whether this entry is a file or directory, along
  /// with other properties.
  ///
  /// \see iso_dir_ent_flag
  uint8_t flags;

  /// The filename of this entry.
  std::string filename;
};

/**
 * Input iterator (forward only, read only) for an ISO 9660 directory table
 * stored in a byte buffer.
 */
class iso_directory_iterator final {
  using iterator_category = std::input_iterator_tag;
  using value_type = const iso_file_entry;
  using difference_type = ptrdiff_t;
  using pointer = const iso_file_entry*;
  using reference = const iso_file_entry&;

 public:
  iso_directory_iterator() = delete;

  /**
   * Initialize an iterator for the directory table in the memory region
   * defined by by begin and end. This iterator is aware of its container
   * and will throw an exception if an attempt is made to access it out of
   * range.
   *
   * \param begin pointer to the first byte of the directory table.
   * \param end pointer to the first byte following the directory table.
   */
  iso_directory_iterator(const uint8_t* begin, const uint8_t* end) {
    directory_ptr = begin;
    end_ptr = end;
    if (directory_ptr >= end_ptr) {
      // dummy value, not accessible.
      entry = iso_file_entry();
    } else {
      entry = iso_file_entry(begin);
    }
  }

  /**
   * Copy the given iso_directory_iterator
   */
  iso_directory_iterator(iso_directory_iterator& it) {
    directory_ptr = it.directory_ptr;
    end_ptr = it.end_ptr;
    entry = it.entry;
  }

  /**
   * Move the given iso_directory_iterator
   */
  iso_directory_iterator(iso_directory_iterator&& it) noexcept {
    directory_ptr = it.directory_ptr;
    end_ptr = it.end_ptr;
    entry = std::move(it.entry);
    it.directory_ptr = nullptr;
    it.end_ptr = nullptr;
    it.entry = iso_file_entry();
  }

  ~iso_directory_iterator() = default;

  /**
   * Determine whether two iso_directory_iterators point to the same table
   * entry.
   */
  bool operator==(const iso_directory_iterator& rhs) const {
    return (this->directory_ptr == rhs.directory_ptr);
  }

  /**
   * Determine whether to iso_directory_iterators do not point to the same
   * table entry.
   */
  bool operator!=(const iso_directory_iterator& rhs) const {
    return !((*this) == rhs);
  }

  /**
   * Get the file entry pointed to by the iterator.
   */
  reference operator*() const {
    if (directory_ptr >= end_ptr) {
      throw std::out_of_range("iso directory iterator is past end of input");
    }
    return entry;
  }

  /**
   * Assign this iterator the value of another iterator by copy
   */
  iso_directory_iterator& operator=(iso_directory_iterator& rhs) = default;

  /**
   * Assign this iterator the value of another iterator by move
   */
  iso_directory_iterator& operator=(iso_directory_iterator&& rhs) noexcept {
    directory_ptr = rhs.directory_ptr;
    end_ptr = rhs.end_ptr;
    entry = std::move(rhs.entry);
    rhs.directory_ptr = nullptr;
    rhs.end_ptr = nullptr;
    rhs.entry = {};
    return *this;
  }

  /**
   * Advance this iterator to the next file entry in the directory table,
   * returning the result.
   * In cases where advancing the iterator would read past the end of the
   * directory table, an exception is thrown and the iterator is not
   * advanced.
   */
  iso_directory_iterator& operator++() {
    if (directory_ptr >= end_ptr) {
      throw std::out_of_range(
          "Cannot advance iso directory iterator past end of input");
    }

    const uint8_t* new_dir_ptr = directory_ptr + *directory_ptr;
    while (new_dir_ptr < end_ptr && *new_dir_ptr == 0) {
      ++new_dir_ptr;
    }

    // Catch a malformed directory entry where the size would extend past
    // the end of the table.
    if (new_dir_ptr < end_ptr && new_dir_ptr + *new_dir_ptr > end_ptr) {
      throw std::runtime_error(
          "The last directory entry was larger than the defined "
          "table region.");
    }

    if (new_dir_ptr < end_ptr) {
      entry = iso_file_entry(new_dir_ptr);
    } else {
      entry = iso_file_entry();
    }
    directory_ptr = new_dir_ptr;
    return *this;
  }

  /**
   * Advance this iterator to the next file entry in the directory table,
   * returning a copy of the old iterator.
   */
  iso_directory_iterator operator++(int) {
    iso_directory_iterator old(*this);
    ++(*this);
    return old;
  }

 private:
  /// Pointer to the current entry.
  const uint8_t* directory_ptr;

  /// Pointer to the end of the directory table.
  const uint8_t* end_ptr;

  /// Current entry.
  iso_file_entry entry;
};

}  // namespace

iso_filesystem::iso_filesystem()
    : raw_file(nullptr), error(nullptr), files(), path_seperator('\\') {}

iso_filesystem::~iso_filesystem() { clear(); }

void iso_filesystem::clear() {
  delete[] error;
  error = nullptr;
  files.clear();
  if (raw_file) {
    std::fclose(raw_file);
    raw_file = nullptr;
  }
}

void iso_filesystem::set_path_separator(char cSeparator) {
  path_seperator = cSeparator;
}

bool iso_filesystem::initialise(const char* path) {
  clear();
  FILE* f = std::fopen(path, "rb");
  if (!f) {
    set_error("Failed to open ISO file");
    return false;
  }
  raw_file = f;

  // Until we know better, assume that sectors are 2048 bytes.
  sector_size = min_sector_size;

  // The first 16 sectors are reserved for bootable media.
  // Volume descriptor records follow this, with one record per sector.
  for (uint32_t iSector = first_filesystem_sector; seek_to_sector(iSector);
       ++iSector) {
    uint8_t aBuffer[root_directory_offset + root_directory_entry_size];
    if (!read_data(sizeof(aBuffer), aBuffer)) {
      break;
    }
    // CD001 is a standard identifier, \x01 is a version number
    if (std::memcmp(aBuffer + 1, "CD001\x01", 6) == 0) {
      if (aBuffer[0] == vdt_primary_volume) {
        sector_size = bytes_to_uint16_le(aBuffer + sector_size_offset);
        try {
          find_hosp_directory(aBuffer + root_directory_offset,
                              root_directory_entry_size, 0);
          if (files.empty()) {
            set_error(
                "Could not find CorsixTH data "
                "directory.");
            return false;
          } else {
            return true;
          }
        } catch (const std::exception& ex) {
          set_error(ex.what());
          return false;
        }
      } else if (aBuffer[0] == vdt_terminator) {
        break;
      }
    }
  }
  set_error("Could not find primary volume descriptor.");
  return false;
}

bool iso_filesystem::file_metadata_less(const file_metadata& lhs,
                                        const file_metadata& rhs) {
  return lhs.path < rhs.path;
}

int iso_filesystem::find_hosp_directory(const uint8_t* pDirEnt,
                                        const uint32_t dirEntsSize, int level) {
  // Sanity check
  // Apart from at the root level, directory record arrays must take up whole
  // sectors, whose sizes are powers of two and at least 2048.
  // The formal limit on directory depth is 8, so hitting 16 is insane.
  if ((level != 0 && (dirEntsSize & (min_sector_size - 1)) != 0) ||
      level > max_directory_depth)
    return 0;

  std::unique_ptr<uint8_t[]> pBuffer(nullptr);
  uint32_t iBufferSize = 0;
  iso_directory_iterator dir_iter(pDirEnt, pDirEnt + dirEntsSize);
  iso_directory_iterator end_iter(pDirEnt + dirEntsSize, pDirEnt + dirEntsSize);
  for (; dir_iter != end_iter; ++dir_iter) {
    const iso_file_entry& ent = *dir_iter;
    if (ent.flags & def_directory) {
      // The names "\x00" and "\x01" are used for the current directory and
      // the parent directory respectively. We only want to visit these
      // when at the root level.
      if (level == 0 || !(ent.filename == std::string(1, '\x00') ||
                          ent.filename == std::string(1, '\x01'))) {
        if (ent.data_length > iBufferSize) {
          iBufferSize = ent.data_length;
          pBuffer = std::make_unique<uint8_t[]>(iBufferSize);
        }
        if (seek_to_sector(ent.data_sector) &&
            read_data(ent.data_length, pBuffer.get())) {
          int iFoundLevel =
              find_hosp_directory(pBuffer.get(), ent.data_length, level + 1);
          if (iFoundLevel != 0) {
            if (iFoundLevel == 2) {
              build_file_lookup_table(ent.data_sector, ent.data_length,
                                      std::string(""));
            }
            return iFoundLevel + 1;
          }
        }
      }
    } else {
      // Look for VBLK-0.TAB to serve as indication that we've found the
      // Theme Hospital data.
      if (ent.filename == vblk_0_filename) {
        return 1;
      }
    }
  }

  return 0;
}

void iso_filesystem::build_file_lookup_table(uint32_t iSector,
                                             uint32_t dirEntsSize,
                                             const std::string& prefix) {
  // Sanity check
  // Apart from at the root level, directory record arrays must take up whole
  // sectors, whose sizes are powers of two and at least 2048.
  // Path lengths shouldn't exceed 256 either (or at least not for the files
  // which we're interested in).
  if ((prefix.size() != 0 && (dirEntsSize & 0x7FF)) || (prefix.size() > 256))
    return;

  uint8_t* pBuffer = new uint8_t[dirEntsSize];
  if (!seek_to_sector(iSector) || !read_data(dirEntsSize, pBuffer)) {
    delete[] pBuffer;
    return;
  }

  uint8_t* pDirEnt = pBuffer;
  iso_directory_iterator dir_iter(pDirEnt, pDirEnt + dirEntsSize);
  iso_directory_iterator end_iter(pDirEnt + dirEntsSize, pDirEnt + dirEntsSize);
  for (; dir_iter != end_iter; ++dir_iter) {
    const iso_file_entry& ent = *dir_iter;
    std::string path;
    if (prefix.empty()) {
      path = ent.filename;
    } else {
      path = prefix + path_seperator + ent.filename;
    }

    if (ent.flags & def_directory) {
      // None of the directories which we're interested in have length 1.
      // This also avoids the dummy "current" and "parent" directories.
      if (ent.filename.size() > 1) {
        build_file_lookup_table(ent.data_sector, ent.data_length, path);
      }
    } else {
      file_metadata file{};
      file.path = std::move(path);
      file.sector = ent.data_sector;
      file.size = ent.data_length;
      files.push_back(file);
    }
  }
  delete[] pBuffer;

  if (prefix.size() == 0) {
    // The lookup table will be ordered by the underlying ordering of the
    // disk. we want it sorted by the path for ease of lookup.
    std::sort(files.begin(), files.end(), file_metadata_less);
  }
}

void iso_filesystem::visit_directory_files(
    const char* sPath, void (*fnCallback)(void*, const char*, const char*),
    void* pCallbackData) const {
  std::string normalised_path = normalise(sPath);

  // Inefficient (better would be to binary search for first and last files
  // which begin with sPath), but who cares - this isn't called often
  for (const file_metadata& file : files) {
    if (normalised_path.size() < file.path.size() &&
        std::equal(normalised_path.begin(), normalised_path.end(),
                   file.path.begin())) {
      size_t filename_pos = normalised_path.size();
      if (file.path.at(normalised_path.size()) == path_seperator) {
        ++filename_pos;
      }
      std::string filename(file.path.substr(filename_pos));

      if (filename.find(path_seperator) == filename.npos) {
        fnCallback(pCallbackData, filename.c_str(), file.path.c_str());
      }
    }
  }
}

iso_filesystem::file_handle iso_filesystem::find_file(const char* sPath) const {
  std::string normalised_path = normalise(sPath);

  // Standard binary search over sorted list of files
  int iLower = 0;
  int iUpper = static_cast<int>(files.size());
  while (iLower != iUpper) {
    int iMid = (iLower + iUpper) / 2;
    int iComp = normalised_path.compare(files[iMid].path);
    if (iComp == 0) {
      return iMid + 1;
    } else if (iComp < 0) {
      iUpper = iMid;
    } else {
      iLower = iMid + 1;
    }
  }
  return 0;
}

uint32_t iso_filesystem::get_file_start(file_handle iFile) const {
  if (iFile <= 0 || static_cast<size_t>(iFile) > files.size())
    return 0;
  else
    return files[iFile - 1].sector * sector_size;
}

uint32_t iso_filesystem::get_file_size(file_handle iFile) const {
  if (iFile <= 0 || static_cast<size_t>(iFile) > files.size())
    return 0;
  else
    return files[iFile - 1].size;
}

bool iso_filesystem::get_file_data(file_handle iFile, uint8_t* pBuffer) {
  if (iFile <= 0 || static_cast<size_t>(iFile) > files.size()) {
    set_error("Invalid file handle.");
    return false;
  } else {
    return seek_to_sector(files[iFile - 1].sector) &&
           read_data(files[iFile - 1].size, pBuffer);
  }
}

const char* iso_filesystem::get_error() const { return error; }

bool iso_filesystem::seek_to_sector(uint32_t iSector) {
  if (!raw_file) {
    set_error("No raw file.");
    return false;
  }
  int res =
      std::fseek(raw_file, sector_size * static_cast<long>(iSector), SEEK_SET);
  if (res == 0) {
    return true;
  } else {
    set_error("Unable to seek to sector %i.", static_cast<int>(iSector));
    return false;
  }
}

bool iso_filesystem::read_data(uint32_t iByteCount, uint8_t* pBuffer) {
  if (!raw_file) {
    set_error("No raw file.");
    return false;
  }
  if (std::fread(pBuffer, 1, iByteCount, raw_file) == iByteCount)
    return true;
  else {
    set_error("Unable to read %i bytes.", static_cast<int>(iByteCount));
    return false;
  }
}

void iso_filesystem::set_error(const char* sFormat, ...) {
  if (error == nullptr) {
    // None of the errors which we generate will be longer than 1024.
    error = new char[1024];
  }
  va_list a;
  va_start(a, sFormat);
  // The valist test is buggy in this environment
  // (https://bugs.llvm.org/show_bug.cgi?id=41311)
  // NOLINTNEXTLINE(clang-analyzer-valist.Uninitialized)
  std::vsnprintf(error, 1024, sFormat, a);
  va_end(a);
}
