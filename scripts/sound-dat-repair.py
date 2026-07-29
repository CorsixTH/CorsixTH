#!/usr/bin/env python3

"""CorsixTH SOUND-0.DAT Repair Utility

Some localized versions of Theme Hospital have malformed WAV data in some of
their SOUND-#.DAT files. This utility fixes an observed form of corruption
where individual WAV entries included invalid data in their trailing tags.

The script iterates through all wav files in the DAT file and strips their
trailing tags, rewriting the RIFF header with the updated length and generating
a new DAT file.

USAGE:
python3 sound-dat-repair.py <input.dat> <output.dat>
"""

import sys
import os
import struct

ARCHIVE_HEADER_SIZE = 234
ARCHIVE_HEADER_TABLE_POS_OFFSET = 50
ARCHIVE_HEADER_TABLE_LEN_OFFSET = 58

SOUND_ENTRY_SIZE = 32
SOUND_ENTRY_NAME_SIZE = 18
SOUND_ENTRY_POS_OFFSET = 18
SOUND_ENTRY_LEN_OFFSET = 26


def fix_wav_buffer(raw_wav: bytes, clean_name: str) -> bytes:
    """Parses internal RIFF sub-chunks, trims trailing junk after 'data',
    and updates the main RIFF header length.
    """
    if len(raw_wav) < 12 or raw_wav[:4] != b'RIFF' or raw_wav[8:12] != b'WAVE':
        print("Warning: Could not find the signature of sound "
              f"'{clean_name}', skipping this entry.", file=sys.stderr)
        return raw_wav

    offset = 12
    data_found = False
    true_end_offset = len(raw_wav)

    # Walk sub-chunks to locate 'data'
    while offset + 8 <= len(raw_wav):
        chunk_id = raw_wav[offset:offset+4]
        chunk_size = struct.unpack('<I', raw_wav[offset+4:offset+8])[0]
        chunk_data_start = offset + 8

        if chunk_id == b'data':
            data_found = True
            true_end_offset = chunk_data_start + chunk_size
            break

        offset = chunk_data_start + chunk_size

    if not data_found:
        print(f"Warning: Could not find the data of sound '{clean_name}', "
              "skipping this entry.", file=sys.stderr)
        return raw_wav

    # Slice off extra bytes past the data chunk payload
    cleaned_wav = bytearray(raw_wav[:true_end_offset])

    # Correct the RIFF header length field at byte offset 4
    new_riff_size = len(cleaned_wav) - 8
    cleaned_wav[4:8] = struct.pack('<I', new_riff_size)

    return bytes(cleaned_wav)


def process_dat(input_dat_path: str, output_dat_path: str):
    if not os.path.isfile(input_dat_path):
        print(f"Error: Input file '{input_dat_path}' not found.",
              file=sys.stderr)
        sys.exit(1)

    file_size = os.path.getsize(input_dat_path)

    if file_size < 4 + ARCHIVE_HEADER_SIZE:
        print("Error: File is too small to be a valid sound archive.",
              file=sys.stderr)
        sys.exit(1)

    with open(input_dat_path, 'rb') as f:
        # 1. Read last 4 bytes -> headerPosition
        f.seek(-4, os.SEEK_END)
        header_position = struct.unpack('<I', f.read(4))[0]

        # Safety check.
        if header_position >= (file_size - ARCHIVE_HEADER_SIZE):
            print(f"Error: Header position {header_position} out of bounds.",
                  file=sys.stderr)
            sys.exit(1)

        # 2. Read Archive Header values (using exact offsets 50 and 58)
        f.seek(header_position + ARCHIVE_HEADER_TABLE_POS_OFFSET)
        table_position = struct.unpack('<I', f.read(4))[0]

        f.seek(header_position + ARCHIVE_HEADER_TABLE_LEN_OFFSET)
        table_length = struct.unpack('<I', f.read(4))[0]

        # Read the raw full archive header block so we preserve any original bytes/metadata
        f.seek(header_position)
        raw_archive_header = bytearray(f.read(ARCHIVE_HEADER_SIZE))

        # 3. Read Table Entries
        sound_file_count = table_length // SOUND_ENTRY_SIZE
        print(f"Header located at offset {header_position}.")
        print(f"Table located at offset {table_position} (Length: "
              f"{table_length} bytes, Count: {sound_file_count}).")
        print("-" * 70)

        entries_to_process = []

        for i in range(sound_file_count):
            entry_offset = table_position + i * SOUND_ENTRY_SIZE
            if entry_offset + SOUND_ENTRY_SIZE > file_size:
                print(f"Error: Table entry {i} out of bounds.", file=sys.stderr)
                sys.exit(1)

            f.seek(entry_offset)
            entry_data = bytearray(f.read(SOUND_ENTRY_SIZE))

            # Name takes bytes 0..18
            raw_name = entry_data[:SOUND_ENTRY_NAME_SIZE]
            pos = struct.unpack('<I', entry_data[SOUND_ENTRY_POS_OFFSET:SOUND_ENTRY_POS_OFFSET+4])[0]
            length = struct.unpack('<I', entry_data[SOUND_ENTRY_LEN_OFFSET:SOUND_ENTRY_LEN_OFFSET+4])[0]

            null_pos = raw_name.find(b'\x00')
            clean_name = raw_name[:null_pos].decode('ascii', errors='ignore') if null_pos != -1 else raw_name.decode('ascii', errors='ignore')

            entries_to_process.append((clean_name, raw_name, pos, length, entry_data))

        # 4. Extract, fix WAV buffers, and prepare repack data
        repack_entries = []
        new_audio_payload = bytearray()

        for idx, (clean_name, raw_name, pos, length, orig_entry) in enumerate(entries_to_process, 1):
            f.seek(pos)
            raw_sample = f.read(length)

            fixed_sample = fix_wav_buffer(raw_sample, clean_name)

            new_pos = len(new_audio_payload)
            new_length = len(fixed_sample)

            trimmed_bytes = length - new_length
            status = f"Trimmed {trimmed_bytes:>4} bytes" if trimmed_bytes > 0 else "Clean"
            print(f"[{idx:03d}/{sound_file_count}] {clean_name:<18} | "
                  f"Old Len: {length:<6} -> New Len: {new_length:<6} | {status}")

            new_audio_payload.extend(fixed_sample)
            repack_entries.append((orig_entry, new_pos, new_length))

    print("-" * 70)

    # 5. Repack file using exact soundfile structures
    with open(output_dat_path, 'wb') as out_f:
        # Write clean audio payloads
        out_f.write(new_audio_payload)

        # Record new table position
        new_table_position = out_f.tell()

        # Write 32-byte table entries (patching updated pos and length fields)
        for orig_entry, pos, length in repack_entries:
            entry_bytes = bytearray(orig_entry)
            entry_bytes[SOUND_ENTRY_POS_OFFSET:SOUND_ENTRY_POS_OFFSET+4] = struct.pack('<I', pos)
            entry_bytes[SOUND_ENTRY_LEN_OFFSET:SOUND_ENTRY_LEN_OFFSET+4] = struct.pack('<I', length)
            out_f.write(entry_bytes)

        new_table_length = len(repack_entries) * SOUND_ENTRY_SIZE

        # Record new header position
        new_header_position = out_f.tell()

        # Update table_position and table_length inside the 234-byte archive header block
        raw_archive_header[ARCHIVE_HEADER_TABLE_POS_OFFSET:ARCHIVE_HEADER_TABLE_POS_OFFSET+4] = struct.pack('<I', new_table_position)
        raw_archive_header[ARCHIVE_HEADER_TABLE_LEN_OFFSET:ARCHIVE_HEADER_TABLE_LEN_OFFSET+4] = struct.pack('<I', new_table_length)

        # Write 234-byte archive header
        out_f.write(raw_archive_header)

        # Write final 4-byte pointer to the archive header
        out_f.write(struct.pack('<I', new_header_position))

    print(f"Successfully repacked archive to '{output_dat_path}'.")


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: python sound-dat-repair.py <input.dat> <output.dat>")
        sys.exit(1)

    process_dat(sys.argv[1], sys.argv[2])
