#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iterator>
#include <vector>

#include "xmi2mid.h"

namespace {
bool ishelp(const char* txt) {
  if (!std::strcmp(txt, "-h")) return true;
  if (!std::strcmp(txt, "--help")) return true;
  return false;
}

void help() {
  std::printf("Covert xmi files to midi files with:\n");
  std::printf("    cth_xmi_utils xmi2mid <input> <output>\n");
  exit(1);
}

int xmi2mid(const char* input, const char* output) {
  std::ifstream in_file(input, std::ios::in | std::ios::binary);
  if (!in_file.is_open()) {
    std::fprintf(stderr, "Could not open %s\n", input);
    return -1;
  }

  std::vector<char> xmi_buf{std::istreambuf_iterator(in_file),
                            std::istreambuf_iterator<char>()};
  in_file.close();

  auto* xmi = reinterpret_cast<unsigned char*>(xmi_buf.data());

  std::size_t midi_len;
  uint8_t* midi_data = transcode_xmi_to_midi(xmi, xmi_buf.size(), &midi_len);
  if (midi_data == nullptr) {
    std::fprintf(stderr, "Could not translate midi file\n");
    return -1;
  }

  std::ofstream out_file(output, std::ios::out | std::ios::binary);
  out_file.write(reinterpret_cast<char*>(midi_data),
                 static_cast<std::streamsize>(midi_len));
  out_file.close();
  delete[] midi_data;

  return 0;
}
}  // namespace

int main(int argc, char* argv[]) {
  if (argc < 2 || ishelp(argv[1])) {
    help();
  }

  if (std::strcmp(argv[1], "xmi2mid") == 0 && argc == 4) {
    return xmi2mid(argv[2], argv[3]);
  }

  help();
}
