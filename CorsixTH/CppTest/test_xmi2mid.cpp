#include <array>
#include <catch2/catch_test_macros.hpp>
#include <catch2/matchers/catch_matchers.hpp>

#include "xmi2mid.h"

// Templated XMI header
// Replace the following:
// Bytes 26-29 = CAT payload size (N + 72)
// Bytes 38-41 = XMID FORM size (N + 56)
// Bytes 98-101 = EVNT SIZE (N)
constexpr std::array<uint8_t, 102> xmi_header = {
    'F',  'O',  'R',  'M',  0x00, 0x00, 0x00, 0x0E, 'X',  'D',  'I',  'R',
    'I',  'N',  'F',  'O',  0x00, 0x00, 0x00, 0x02, 0x01, 0x00, 'C',  'A',
    'T',  ' ',  0x00, 0x00, 0x00, 0x00, 'X',  'M',  'I',  'D',  'F',  'O',
    'R',  'M',  0x00, 0x00, 0x00, 0x00, 'X',  'M',  'I',  'D',  'T',  'I',
    'M',  'B',  0x00, 0x00, 0x00, 0x28, 0x13, 0x00, 0x2A, 0x7F, 0x43, 0x00,
    0x38, 0x00, 0x25, 0x00, 0x00, 0x00, 0x26, 0x00, 0x32, 0x00, 0x0C, 0x00,
    0x4B, 0x00, 0x24, 0x7F, 0x28, 0x7F, 0x2E, 0x7F, 0x31, 0x7F, 0x2F, 0x7F,
    0x2D, 0x7F, 0x37, 0x7F, 0x3A, 0x7F, 0x33, 0x7F, 0x4B, 0x7F, 'E',  'V',
    'N',  'T',  0x00, 0x00, 0x00, 0x00};

std::array<uint8_t, 4> be_size(uint32_t size) {
  return std::array<uint8_t, 4>{
      static_cast<uint8_t>(size >> 24u), static_cast<uint8_t>(size >> 16u),
      static_cast<uint8_t>(size >> 8u), static_cast<uint8_t>(size)};
}

[[nodiscard]]
std::vector<uint8_t> prepend_xmi_header(const std::vector<uint8_t>& xmi_chunk) {
  std::vector<uint8_t> result;

  auto cat_size = be_size(xmi_chunk.size() + 72);
  auto xmid_form_size = be_size(xmi_chunk.size() + 56);
  auto evnt_size = be_size(xmi_chunk.size());

  result.reserve(xmi_header.size() + xmi_chunk.size());
  result.insert(result.end(), xmi_header.begin(), xmi_header.end());
  result.insert(result.end(), xmi_chunk.begin(), xmi_chunk.end());

  std::copy(cat_size.begin(), cat_size.end(), result.begin() + 26);
  std::copy(xmid_form_size.begin(), xmid_form_size.end(), result.begin() + 38);
  std::copy(evnt_size.begin(), evnt_size.end(), result.begin() + 98);

  return result;
}

// XMI delay is a sum of 0x7F followed by the 7 bit number smaller than that
// a zero is excluded (the lack of delay is detected by the following byte
// being a midi event (with the high bit set to true)
void push_xmi_delay(std::vector<uint8_t>& xmi, uint32_t delay) {
  while (delay > 0x7f) {
    xmi.emplace_back(0x7f);
    delay >>= 7u;
  }
  if (delay > 0) {
    xmi.emplace_back(delay);
  }
}

// XMI note duration uses a concatenated format where a high bit of 1 means
// more bytes follow. This is the same as the VLQ format in MIDI,
// that is 7 bit numbers
void push_xmi_duration(std::vector<uint8_t>& xmi, uint32_t duration) {
  int byte_count = 1;
  uint32_t dc = duration;
  while (dc > 0x7f) {
    byte_count++;
    dc >>= 7u;
  }
  for (int i = 0; i < byte_count; i++) {
    xmi.emplace_back(0);
  }
  std::size_t xmi_dur_idx = xmi.size() - 1;
  for (int i = 0; i < byte_count; i++) {
    xmi[xmi_dur_idx - i] = (duration & 0x7fu);
    if (i != 0) {
      xmi[xmi_dur_idx - i] |= 0x80u;
    }
    duration >>= 7u;
  }
}

void push_xmi_note_on(std::vector<uint8_t>& xmi, uint8_t channel, uint8_t note,
                      uint8_t velocity, uint32_t duration) {
  xmi.emplace_back(midi_event_note_on | channel);
  xmi.emplace_back(note);
  xmi.emplace_back(velocity);
  push_xmi_duration(xmi, duration);
}

// Allow either of the valid MIDI representations for note off
bool is_note_off(const midi_token& token) {
  if ((token.type & midi_event_note_off) == midi_event_note_off) {
    return true;
  }
  if ((token.type & midi_event_note_on) == midi_event_note_on) {
    return token.buffer.size() == 1 && token.buffer[0] == 0;
  }
  return false;
}

TEST_CASE("verify test VLQ encoding", "[push_xmi_duration]") {
  std::vector<uint8_t> chunk{};

  SECTION("smallest duration") {
    push_xmi_duration(chunk, 0x0);
    REQUIRE(chunk.size() == 1);
    REQUIRE(chunk[0] == 0);
    chunk.clear();
  }

  SECTION("largest 1 byte duration") {
    push_xmi_duration(chunk, 0x7F);
    REQUIRE(chunk.size() == 1);
    REQUIRE(chunk[0] == 0x7F);
    chunk.clear();
  }

  SECTION("two byte duration, show continuation bit") {
    push_xmi_duration(chunk, 0x80);
    REQUIRE(chunk.size() == 2);
    REQUIRE(chunk[0] == 0x81);  // continuation and first bit
    REQUIRE(chunk[1] == 0);
    chunk.clear();
  }

  SECTION("duration is pushed to end of vector") {
    chunk.push_back(0xDE);
    push_xmi_duration(chunk, 0x84);
    REQUIRE(chunk.size() == 3);
    REQUIRE(chunk[0] == 0xDE);  // don't clobber existing data
    REQUIRE(chunk[1] == 0x81);  // continuation and first bit
    REQUIRE(chunk[2] == 4);
  }
}

TEST_CASE("xmi2mid converts basic file", "[xmi_to_midi_token_list]") {
  std::vector<uint8_t> xmi_chunk{};
  push_xmi_note_on(xmi_chunk, 1, 0x0C, 0xFF, 100u);
  std::vector<uint8_t> res = prepend_xmi_header(xmi_chunk);

  uint32_t tempo;
  midi_token_list midi = xmi_to_midi_token_list(res.data(), res.size(), tempo);

  // note on, note off. There is no end of track in the midi_token_list
  REQUIRE(midi.size() == 2);
  REQUIRE(midi[0].time == 0);
  REQUIRE(midi[0].type == (midi_event_note_on | 0x01u));  // note-on channel 1
  REQUIRE(midi[0].data == 0x0C);
  REQUIRE(midi[0].buffer.size() == 1);
  REQUIRE(midi[0].buffer[0] == 0xFF);
  REQUIRE(midi[1].time == 100u * time_multiplier);
  REQUIRE(is_note_off(midi[1]));
}

TEST_CASE("zero duration note is off before on", "[xmi_to_midi_token_list]") {
  std::vector<uint8_t> xmi_chunk{};
  push_xmi_note_on(xmi_chunk, 1, 0x0C, 0xFF, 0u);
  std::vector<uint8_t> res = prepend_xmi_header(xmi_chunk);

  uint32_t tempo;
  midi_token_list midi = xmi_to_midi_token_list(res.data(), res.size(), tempo);

  // note on, note off. There is no end of track in the midi_token_list
  REQUIRE(midi.size() == 2);
  REQUIRE(midi[0].time == 0);
  REQUIRE(midi[0].type == (midi_event_note_on | 0x01u));  // note-on channel 1
  REQUIRE(midi[1].time == 0);
  REQUIRE(is_note_off(midi[1]));
}

TEST_CASE("note with duration off before same note on",
          "[xmi_to_midi_token_list]") {
  std::vector<uint8_t> xmi_chunk{};
  push_xmi_note_on(xmi_chunk, 1, 0x0C, 0xFF, 100u);
  push_xmi_delay(xmi_chunk, 100u);
  push_xmi_note_on(xmi_chunk, 1, 0x0C, 0xFF, 200u);

  std::vector<uint8_t> res = prepend_xmi_header(xmi_chunk);

  uint32_t tempo;
  midi_token_list midi = xmi_to_midi_token_list(res.data(), res.size(), tempo);

  // note on, note off. There is no end of track in the midi_token_list
  REQUIRE(midi.size() == 4);
  REQUIRE(midi[0].time == 0);
  REQUIRE(midi[0].type == (midi_event_note_on | 0x01u));  // note-on channel 1
  REQUIRE(midi[1].time == 100 * time_multiplier);
  REQUIRE(is_note_off(midi[1]));
  REQUIRE(midi[2].time == 100 * time_multiplier);
  REQUIRE(midi[2].type == (midi_event_note_on | 0x01u));
  REQUIRE(midi[3].time == 300 * time_multiplier);
  REQUIRE(is_note_off(midi[3]));
}
