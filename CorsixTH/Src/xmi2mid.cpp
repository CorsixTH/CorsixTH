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

#include "xmi2mid.h"

#include "config.h"

#include <algorithm>
#include <cmath>
#include <cstring>
#include <new>
#include <stdexcept>
#include <vector>

//! Determines if the system is little-endian
//! This function can be replaced with std::endian when we move to C++20
bool is_little_endian() {
  uint16_t i = 0x0102;
  return *reinterpret_cast<uint8_t*>(&i) == 0x02;
}

bool operator<(const midi_token& oLeft, const midi_token& oRight) {
  return oLeft.time < oRight.time;
}

/*!
    Utility class for reading or writing to memory as if it were a file.
*/
class memory_buffer {
 public:
  memory_buffer()
      : data(nullptr),
        pointer(nullptr),
        data_end(nullptr),
        buffer_end(nullptr) {}

  memory_buffer(const uint8_t* pData, size_t iLength) {
    data = pointer = (char*)pData;
    data_end = data + iLength;
    buffer_end = nullptr;
  }

  ~memory_buffer() {
    if (buffer_end != nullptr) delete[] data;
  }

  uint8_t* take_data(size_t* pLength) {
    if (pLength) *pLength = data_end - data;
    uint8_t* pResult = reinterpret_cast<uint8_t*>(data);
    data = pointer = data_end = buffer_end = nullptr;
    return pResult;
  }

  size_t tell() const { return pointer - data; }

  bool seek(size_t position) {
    if (data == nullptr || data + position > data_end) {
      if (!resize_buffer(position)) return false;
    }
    pointer = data + position;
    return true;
  }

  bool skip(std::ptrdiff_t distance) {
    if (distance < 0) {
      if (pointer + distance < data) return false;
    }
    return seek(pointer - data + distance);
  }

  bool scan_to(const void* pData, size_t iLength) {
    for (; pointer + iLength <= data_end; ++pointer) {
      if (std::memcmp(pointer, pData, iLength) == 0) return true;
    }
    return false;
  }

  const char* get_pointer() const { return pointer; }

  template <class T>
  bool read(T& value) {
    return read(&value, 1);
  }

  template <class T>
  bool read(T* values, size_t count) {
    if (pointer + sizeof(T) * count > data_end) return false;
    std::memcpy(values, pointer, sizeof(T) * count);
    pointer += sizeof(T) * count;
    return true;
  }

  uint32_t read_big_endian_uint24() {
    uint8_t iByte0, iByte1, iByte2;
    if (read(iByte0) && read(iByte1) && read(iByte2))
      return (((iByte0 << 8) | iByte1) << 8) | iByte2;
    else
      return 0;
  }

  uint32_t read_variable_length_uint() {
    unsigned int iValue = 0;
    uint8_t iByte;
    for (int i = 0; i < 4; ++i) {
      if (!read(iByte)) return false;
      iValue = (iValue << 7) | static_cast<unsigned int>(iByte & 0x7F);
      if ((iByte & 0x80) == 0) break;
    }
    return iValue;
  }

  template <class T>
  bool write(const T& value) {
    return write(&value, 1);
  }

  template <class T>
  bool write(const T* values, size_t count) {
    if (!skip(static_cast<std::ptrdiff_t>(sizeof(T) * count))) return false;
    std::memcpy(pointer - sizeof(T) * count, values, sizeof(T) * count);
    return true;
  }

  bool write_big_endian_uint16(uint16_t iValue) {
    return write(is_little_endian() ? byte_swap(iValue) : iValue);
  }

  bool write_big_endian_uint32(uint32_t iValue) {
    return write(is_little_endian() ? byte_swap(iValue) : iValue);
  }

  bool write_variable_length_uint(unsigned int iValue) {
    int iByteCount = 1;
    unsigned int iBuffer = iValue & 0x7F;
    for (; iValue >>= 7; ++iByteCount) {
      iBuffer = (iBuffer << 8) | 0x80 | (iValue & 0x7F);
    }
    for (int i = 0; i < iByteCount; ++i) {
      uint8_t iByte = iBuffer & 0xFF;
      if (!write(iByte)) return false;
      iBuffer >>= 8;
    }
    return true;
  }

  bool is_end_of_buffer() const { return pointer == data_end; }

 private:
  //! Byte-swap a value
  //! Replace with std::byteswap when we move to C++23
  template <class T>
  static T byte_swap(T value) {
    T swapped = 0;
    for (int i = 0; i < static_cast<int>(sizeof(T)) * 8; i += 8) {
      swapped = static_cast<T>(swapped | ((value >> i) & 0xFF)
                                             << (sizeof(T) * 8 - 8 - i));
    }
    return swapped;
  }

  bool resize_buffer(size_t size) {
    if (data != nullptr && data + size <= buffer_end) {
      data_end = data + size;
      return true;
    }

    char* pNewData = new (std::nothrow) char[size * 2];
    if (pNewData == nullptr) return false;
    size_t iOldLength = data_end - data;
    if (iOldLength > 0) {
      std::memcpy(pNewData, data, size > iOldLength ? iOldLength : size);
    }
    pointer = pointer - data + pNewData;
    if (buffer_end != nullptr) delete[] data;
    data = pNewData;
    data_end = pNewData + size;
    buffer_end = pNewData + size * 2;
    return true;
  }

  char *data, *pointer, *data_end, *buffer_end;
};

void early_eof() { throw std::runtime_error("unexpected end of XMI data"); }

midi_token_list xmi_to_midi_token_list(const unsigned char* xmi_data,
                                       size_t xmi_length, uint32_t& iTempo) {
  if (xmi_data == nullptr) {
    throw std::invalid_argument("xmi_data is null");
  }

  memory_buffer bufInput(xmi_data, xmi_length);

  // CorsixTH uses a simplified XMI format with no RBRN chunk and only a single
  // song per file.

  // There is a TIMB chunk, but on all tracks it has a length of zero and
  // appears to be otherwise gibberish, so we skip it.

  if (!bufInput.scan_to("EVNT", 4) || !bufInput.skip(8)) {
    throw std::runtime_error("XMI EVNT chunk not found");
  }

  midi_token_list lstTokens;
  int iTokenTime = 0;
  iTempo = 500000;
  bool bTempoSet = false;
  bool bEnd = false;
  uint8_t iTokenType;
  uint8_t iExtendedType;

  while (!bufInput.is_end_of_buffer() && !bEnd) {
    while (true) {
      if (!bufInput.read(iTokenType)) {
        early_eof();
      }

      // If the high bit is set this is a MIDI event, otherwise it is part of
      // the duration of the previous event. Durations are summed together in
      // XMI and omitted entirely if zero.
      if (iTokenType & 0x80) break;

      iTokenTime += static_cast<int>(iTokenType) * time_multiplier;
    }
    midi_token& token = lstTokens.emplace_back(iTokenTime, iTokenType);
    // XMI events type ids match their corresponding MIDI event type ids.
    // The high nibble is the event type, the low nibble is the channel except
    // for 0xFn.
    switch (iTokenType & 0xF0) {
      case midi_event_program_change:
      case midi_event_channel_pressure:
        // Single data byte.
        if (!bufInput.read(token.data)) early_eof();
        break;
      case midi_event_note_off:
      case midi_event_poly_key_pressure:
      case midi_event_control_change:
      case midi_event_pitch_bend: {
        if (!bufInput.read(token.data)) early_eof();
        // Two data bytes.
        uint8_t b1;
        if (!bufInput.read(b1)) early_eof();
        token.buffer.push_back(b1);
      } break;
      case midi_event_note_on: {
        // Note on: read note and velocity
        uint8_t note;
        if (!bufInput.read(note)) early_eof();
        token.data = note;

        uint8_t velocity;
        if (!bufInput.read(velocity)) early_eof();
        token.buffer.push_back(velocity);
        // Insert a note off event after the specified duration since MIDI
        // does not support duration. A note on event with a velocity of zero
        // is a note off (alternative to 0x8n) according to the MIDI spec.
        midi_token& offToken = lstTokens.emplace_back(
            iTokenTime +
                static_cast<int>(bufInput.read_variable_length_uint()) *
                    time_multiplier,
            iTokenType);
        offToken.data = note;
        offToken.buffer.push_back(0);
      } break;
      case 0xF0:
        iExtendedType = 0;
        if (iTokenType == midi_event_meta) {
          if (!bufInput.read(iExtendedType)) {
            early_eof();
          }

          if (iExtendedType == midi_meta_event_end_of_track)
            bEnd = true;
          else if (iExtendedType == midi_meta_event_set_tempo) {
            if (!bTempoSet) {
              bufInput.skip(1);
              iTempo = bufInput.read_big_endian_uint24();
              bTempoSet = true;
              bufInput.skip(-4);
            } else {
              lstTokens.pop_back();
              if (!bufInput.skip(static_cast<std::ptrdiff_t>(
                      bufInput.read_variable_length_uint()))) {
                early_eof();
              }
              break;
            }
          }
        }
        token.data = iExtendedType;
        uint32_t buffer_length = bufInput.read_variable_length_uint();
        token.buffer.assign(bufInput.get_pointer(),
                            bufInput.get_pointer() + buffer_length);
        if (!bufInput.skip(buffer_length)) {
          early_eof();
        }
        break;
    }
  }

  std::sort(lstTokens.begin(), lstTokens.end());
  return lstTokens;
}

uint8_t* transcode_xmi_to_midi(const unsigned char* xmi_data, size_t xmi_length,
                               size_t* midi_length) {
  uint32_t iTempo;
  midi_token_list lstTokens =
      xmi_to_midi_token_list(xmi_data, xmi_length, iTempo);

  if (lstTokens.empty()) return nullptr;

  memory_buffer bufOutput;
  // SMF header for single track type 0.
  if (!bufOutput.write("MThd\0\0\0\x06\0\0\0\x01", 12)) return nullptr;

  // Write the division (ticks per quarter note if positive).
  // XMI files run at 120Hz, which works out to 25000/3 microseconds per tick.
  // The MIDI tempo is specified in microseconds per quarter note.
  // To get ticks per quarter note we need to invert microseconds per tick and
  // multiply by microseconds per quarter note, giving the formula below.
  long division = std::clamp(
      std::lround(static_cast<long double>(iTempo) * xmi_ticks_per_microsecond),
      1L, 0x7FFFL);
  if (!bufOutput.write_big_endian_uint16(static_cast<uint16_t>(division)))
    return nullptr;

  // Track chunk header with placeholder length.
  if (!bufOutput.write("MTrk\xBA\xAD\xF0\x0D", 8)) return nullptr;

  int iTokenTime = 0;
  uint8_t iTokenType = 0;
  bool bEnd = false;

  for (auto itr = lstTokens.begin(), itrEnd = lstTokens.end();
       itr != itrEnd && !bEnd; ++itr) {
    if (!bufOutput.write_variable_length_uint(itr->time - iTokenTime))
      return nullptr;
    iTokenTime = itr->time;
    if (itr->type >= 0xF0) {
      iTokenType = itr->type;
      if (!bufOutput.write(iTokenType)) return nullptr;
      if (iTokenType == 0xFF) {
        if (!bufOutput.write(itr->data)) return nullptr;
        if (itr->data == 0x2F) bEnd = true;
      }
      if (!bufOutput.write_variable_length_uint(
              static_cast<unsigned int>(itr->buffer.size())))
        return nullptr;
      if (!bufOutput.write(itr->buffer.data(), itr->buffer.size()))
        return nullptr;
    } else {
      if (itr->type != iTokenType) {
        iTokenType = itr->type;
        if (!bufOutput.write(iTokenType)) return nullptr;
      }
      if (!bufOutput.write(itr->data)) return nullptr;
      if (!itr->buffer.empty()) {
        if (!bufOutput.write(itr->buffer.data(), 1)) return nullptr;
      }
    }
  }

  // Replace the placeholder length in the header with the actual length.
  uint32_t iLength = static_cast<uint32_t>(bufOutput.tell() - 22);
  bufOutput.seek(18);
  bufOutput.write_big_endian_uint32(iLength);

  return bufOutput.take_data(midi_length);
}
