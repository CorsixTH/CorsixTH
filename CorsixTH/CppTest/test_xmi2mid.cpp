#include <catch2/catch_test_macros.hpp>
#include <cstdint>
#include <map>
#include <utility>
#include <vector>

#include "../Src/xmi2mid.h"

namespace {

//! MIDI channel used by the fixtures, as a status byte nibble.
constexpr uint8_t test_channel = 4;

//! Note on status byte for the test channel.
constexpr uint8_t note_on_status = midi_event_note_on | test_channel;

//! Builder for the minimal subset of XMI that xmi_to_midi_token_list reads.
//!
//! The parser scans for the EVNT chunk and then reads events, so the fixture
//! only needs that chunk. Delays are stored as bytes with the high bit clear
//! and are summed until an event byte is reached.
class xmi_builder {
 public:
  xmi_builder() {
    const char* header = "EVNT";
    data.insert(data.end(), header, header + 4);
    // Chunk length. The parser skips over it without reading it.
    data.insert(data.end(), {0, 0, 0, 0});
  }

  //! Advance the event clock by the given number of XMI ticks.
  xmi_builder& delay(uint8_t ticks) {
    data.push_back(ticks & 0x7F);
    return *this;
  }

  //! Add a note with an explicit duration, as XMI stores them.
  xmi_builder& note(uint8_t pitch, uint8_t velocity, uint8_t duration) {
    data.push_back(note_on_status);
    data.push_back(pitch);
    data.push_back(velocity);
    data.push_back(duration & 0x7F);
    return *this;
  }

  //! Terminate the track.
  xmi_builder& end_of_track() {
    data.push_back(midi_event_meta);
    data.push_back(midi_meta_event_end_of_track);
    data.push_back(0);
    return *this;
  }

  midi_token_list parse() const {
    uint32_t tempo = 0;
    return xmi_to_midi_token_list(data.data(), data.size(), tempo);
  }

 private:
  std::vector<uint8_t> data{};
};

//! XMI tick durations are scaled by time_multiplier during conversion.
int ticks(int xmi_ticks) { return xmi_ticks * time_multiplier; }

bool is_note_off(const midi_token& token) {
  const uint8_t event = token.type & 0xF0;
  if (event == midi_event_note_off) {
    return true;
  }
  return event == midi_event_note_on && !token.buffer.empty() &&
         token.buffer[0] == 0;
}

bool is_note_on(const midi_token& token) {
  return (token.type & 0xF0) == midi_event_note_on && !token.buffer.empty() &&
         token.buffer[0] != 0;
}

//! Every note event in order, as (time, pitch, is note on) triples.
struct note_event {
  int time;
  uint8_t pitch;
  bool on;
};

std::vector<note_event> note_events(const midi_token_list& tokens) {
  std::vector<note_event> events;
  for (const midi_token& token : tokens) {
    if (is_note_on(token)) {
      events.push_back({token.time, token.data, true});
    } else if (is_note_off(token)) {
      events.push_back({token.time, token.data, false});
    }
  }
  return events;
}

}  // namespace

TEST_CASE("xmi2mid converts a note duration into a note off", "[xmi2mid]") {
  const midi_token_list tokens =
      xmi_builder().note(60, 100, 10).delay(20).end_of_track().parse();

  const std::vector<note_event> events = note_events(tokens);
  REQUIRE(events.size() == 2);

  CHECK(events[0].on);
  CHECK(events[0].time == 0);
  CHECK(events[0].pitch == 60);

  CHECK_FALSE(events[1].on);
  CHECK(events[1].time == ticks(10));
  CHECK(events[1].pitch == 60);
}

TEST_CASE(
    "xmi2mid releases a note before re-striking the same pitch at that instant",
    "[xmi2mid]") {
  // The first note ends exactly where the second begins. If the note off is
  // ordered after the note on, the second note is silenced immediately.
  const midi_token_list tokens = xmi_builder()
                                     .note(60, 100, 10)
                                     .delay(10)
                                     .note(60, 100, 10)
                                     .delay(10)
                                     .end_of_track()
                                     .parse();

  const std::vector<note_event> events = note_events(tokens);
  REQUIRE(events.size() == 4);

  CHECK(events[0].on);
  CHECK(events[0].time == 0);

  // The release must come first at the shared timestamp.
  CHECK_FALSE(events[1].on);
  CHECK(events[1].time == ticks(10));

  CHECK(events[2].on);
  CHECK(events[2].time == ticks(10));

  CHECK_FALSE(events[3].on);
  CHECK(events[3].time == ticks(20));
}

TEST_CASE("xmi2mid does not truncate a note which overlaps the same pitch",
          "[xmi2mid]") {
  // The first note runs to tick 20, the second from tick 10 to tick 30.
  // Releasing the first note at tick 20 would cut the second one short.
  const midi_token_list tokens = xmi_builder()
                                     .note(60, 100, 20)
                                     .delay(10)
                                     .note(60, 100, 20)
                                     .delay(30)
                                     .end_of_track()
                                     .parse();

  const std::vector<note_event> events = note_events(tokens);
  REQUIRE(events.size() == 4);

  CHECK(events[0].on);
  CHECK(events[0].time == 0);

  CHECK_FALSE(events[1].on);
  CHECK(events[1].time == ticks(10));

  CHECK(events[2].on);
  CHECK(events[2].time == ticks(10));

  // The surviving note runs to its own end, not the earlier note's end.
  CHECK_FALSE(events[3].on);
  CHECK(events[3].time == ticks(30));
}

TEST_CASE("xmi2mid merges notes struck at the same instant", "[xmi2mid]") {
  // Two notes of the same pitch starting on the same tick cannot be separated
  // in MIDI, because a note off applies to the whole (channel, note) pair.
  // They must collapse into one voice running to the later end time, rather
  // than being released a tick after they start.
  const midi_token_list tokens = xmi_builder()
                                     .note(60, 100, 10)
                                     .note(60, 100, 30)
                                     .delay(40)
                                     .end_of_track()
                                     .parse();

  const std::vector<note_event> events = note_events(tokens);
  REQUIRE(events.size() == 3);

  CHECK(events[0].on);
  CHECK(events[0].time == 0);
  CHECK(events[1].on);
  CHECK(events[1].time == 0);

  // One release, at the later of the two end times.
  CHECK_FALSE(events[2].on);
  CHECK(events[2].time == ticks(30));
}

TEST_CASE("xmi2mid leaves no note sounding at the end of the track",
          "[xmi2mid]") {
  const midi_token_list tokens = xmi_builder()
                                     .note(60, 100, 20)
                                     .note(60, 100, 30)
                                     .note(64, 100, 10)
                                     .delay(5)
                                     .note(60, 100, 20)
                                     .note(64, 100, 40)
                                     .delay(60)
                                     .end_of_track()
                                     .parse();

  std::map<std::pair<uint8_t, uint8_t>, int> sounding;
  for (const midi_token& token : tokens) {
    if (token.type >= 0xF0) {
      continue;
    }
    const std::pair<uint8_t, uint8_t> key{token.type, token.data};
    if (is_note_on(token)) {
      sounding[key] = 1;
    } else if (is_note_off(token)) {
      // A single release silences the whole (channel, note) pair.
      sounding[key] = 0;
    }
  }

  for (const auto& [key, count] : sounding) {
    INFO("pitch " << static_cast<int>(key.second) << " left sounding");
    CHECK(count == 0);
  }
}

TEST_CASE("xmi2mid never releases a note that was not struck", "[xmi2mid]") {
  const midi_token_list tokens = xmi_builder()
                                     .note(60, 100, 20)
                                     .note(64, 100, 30)
                                     .delay(5)
                                     .note(60, 100, 20)
                                     .delay(5)
                                     .note(67, 100, 5)
                                     .note(60, 100, 40)
                                     .delay(60)
                                     .end_of_track()
                                     .parse();

  int note_ons = 0;
  int note_offs = 0;
  for (const midi_token& token : tokens) {
    if (is_note_on(token)) {
      note_ons++;
    } else if (is_note_off(token)) {
      note_offs++;
    }
  }

  CHECK(note_ons == 5);
  // Notes struck at the same instant on one pitch share a release, so there may
  // be fewer note offs, but never more.
  CHECK(note_offs <= note_ons);
  CHECK(note_offs > 0);
}

TEST_CASE("xmi2mid never orders a note off after a note on of the same pitch",
          "[xmi2mid]") {
  const midi_token_list tokens = xmi_builder()
                                     .note(60, 100, 10)
                                     .delay(10)
                                     .note(60, 100, 10)
                                     .note(64, 100, 10)
                                     .delay(10)
                                     .note(64, 100, 30)
                                     .note(60, 100, 5)
                                     .delay(40)
                                     .end_of_track()
                                     .parse();

  // Walk the stream the way a synthesizer would. A note off for a pitch that
  // is not sounding means an earlier note on was silenced by its predecessor's
  // release.
  for (size_t i = 0; i < tokens.size(); ++i) {
    if (!is_note_on(tokens[i])) {
      continue;
    }
    for (size_t j = i + 1;
         j < tokens.size() && tokens[j].time == tokens[i].time; ++j) {
      const bool same_note =
          tokens[j].type == tokens[i].type && tokens[j].data == tokens[i].data;
      INFO("note on at time " << tokens[i].time << " pitch "
                              << static_cast<int>(tokens[i].data)
                              << " is followed by its own note off");
      CHECK_FALSE((same_note && is_note_off(tokens[j])));
    }
  }
}

TEST_CASE("xmi2mid gives a zero length note a non-zero duration", "[xmi2mid]") {
  // A note released at the instant it is struck would have its note off
  // ordered ahead of its own note on, leaving the voice sounding forever.
  const midi_token_list tokens =
      xmi_builder().note(60, 100, 0).delay(20).end_of_track().parse();

  const std::vector<note_event> events = note_events(tokens);
  REQUIRE(events.size() == 2);
  CHECK(events[0].on);
  CHECK_FALSE(events[1].on);
  CHECK(events[1].time > events[0].time);
}
