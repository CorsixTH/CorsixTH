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

#include "run_length_encoder.h"

#include <algorithm>
#include <cstdio>
#include <new>

#include "persist_lua.h"

integer_run_length_encoder::integer_run_length_encoder(size_t iRecordSize)
    : buffer(iRecordSize * 8 * 4),
      output(iRecordSize * 8 * 4),
      record_size(iRecordSize) {}

void integer_run_length_encoder::write(uint32_t iValue) {
  buffer[(buffer_offset + buffer_size) % buffer.size()] = iValue;
  if (++buffer_size == buffer.size()) flush(false);
}

void integer_run_length_encoder::finish() {
  if (buffer_size != 0) flush(true);
}

void integer_run_length_encoder::flush(bool bAll) {
  do {
    if (object_size == 0) {
      // Decide on the size of the next object
      // Want the object size which gives most object repeats, then for
      // two sizes with the same repeat count, the smaller size.
      size_t iBestRepeats = 0;
      size_t iBestSize = 0;
      size_t iBestOffset = 0;
      for (size_t iNumRecords = 1; iNumRecords <= 8; ++iNumRecords) {
        for (size_t iOffset = 0; iOffset < iNumRecords; ++iOffset) {
          size_t iNumRepeats = 0;
          size_t iObjSize = iNumRecords * record_size;
          while (iObjSize * (iOffset + iNumRepeats + 1) <= buffer_size &&
                 are_ranges_equal(0, iNumRepeats, iOffset, iObjSize)) {
            ++iNumRepeats;
          }
          if (iNumRepeats > iBestRepeats ||
              (iNumRepeats == iBestRepeats && iObjSize < iBestSize)) {
            iBestRepeats = iNumRepeats;
            iBestSize = iObjSize;
            iBestOffset = iOffset;
          }
        }
      }
      if (iBestRepeats == 1) {
        // No repeats were found, so the best we can do is output
        // a large non-repeating blob.
        move_object_to_output(std::min(buffer_size, 8 * record_size), 1);
      } else {
        if (iBestOffset != 0)
          move_object_to_output(iBestOffset * record_size, 1);
        // Mark the object as the current one, and remove all but the
        // last instance of it from the buffer. On the next flush, the
        // new data might continue the same object, hence why the
        // object isn't output just yet.
        object_size = iBestSize;
        object_copies = iBestRepeats - 1;
        buffer_offset =
            (buffer_offset + object_size * object_copies) % buffer.size();
        buffer_size -= object_size * object_copies;
      }
    } else {
      // Try to match more of the current object
      while (object_size * 2 <= buffer_size &&
             are_ranges_equal(0, 1, 0, object_size)) {
        ++object_copies;
        buffer_offset = (buffer_offset + object_size) % buffer.size();
        buffer_size -= object_size;
      }
      // Write data
      if (object_size * 2 <= buffer_size || bAll) {
        move_object_to_output(object_size, object_copies + 1);
        object_size = 0;
        object_copies = 0;
      }
    }
  } while (bAll && buffer_size != 0);
}

bool integer_run_length_encoder::are_ranges_equal(size_t iObjIdx1,
                                                  size_t iObjIdx2,
                                                  size_t iOffset,
                                                  size_t iObjSize) const {
  iObjIdx1 = buffer_offset + iOffset * record_size + iObjIdx1 * iObjSize;
  iObjIdx2 = buffer_offset + iOffset * record_size + iObjIdx2 * iObjSize;
  for (size_t i = 0; i < iObjSize; ++i) {
    if (buffer[(iObjIdx1 + i) % buffer.size()] !=
        buffer[(iObjIdx2 + i) % buffer.size()]) {
      return false;
    }
  }
  return true;
}

bool integer_run_length_encoder::move_object_to_output(size_t iObjSize,
                                                       size_t iObjCount) {
  // Grow the output array if needed
  if (output.size() - output_size <= iObjSize) {
    size_t iNewSize = (output.size() + iObjSize) * 2;
    output.resize(iNewSize);
  }
  size_t iHeader = (iObjSize / record_size - 1) + 8 * (iObjCount - 1);
  output[output_size++] = static_cast<uint32_t>(iHeader);
  // Move the object from the buffer to the output
  for (size_t i = 0; i < iObjSize; ++i) {
    output[output_size++] = buffer[buffer_offset];
    buffer_offset = (buffer_offset + 1) % buffer.size();
  }
  buffer_size -= iObjSize;
  return true;
}

const uint32_t* integer_run_length_encoder::get_output(size_t* pCount) const {
  if (pCount) *pCount = output_size;
  return output.data();
}

void integer_run_length_encoder::pump_output(
    lua_persist_writer* pWriter) const {
  pWriter->write_uint(output_size);
  for (size_t i = 0; i < output_size; ++i) {
    pWriter->write_uint(output[i]);
  }
}

integer_run_length_decoder::integer_run_length_decoder(
    size_t iRecordSize, lua_persist_reader* pReader)
    : buffer(9 * iRecordSize), reader(pReader), record_size(iRecordSize) {
  pReader->read_uint(reads_remaining);
}

uint32_t integer_run_length_decoder::read() {
  if (object_copies == 0) {
    uint32_t iHeader = 0;
    reader->read_uint(iHeader);
    --reads_remaining;
    object_size = record_size * (1 + (iHeader & 7));
    object_copies = (iHeader / 8) + 1;
    for (size_t i = 0; i < object_size; ++i) {
      reader->read_uint(buffer[i]);
      --reads_remaining;
    }
  }

  uint32_t iValue = buffer[object_index];
  if (++object_index == object_size) {
    object_index = 0;
    --object_copies;
  }
  return iValue;
}

bool integer_run_length_decoder::is_finished() const {
  return reads_remaining == 0 && object_copies == 0;
}
