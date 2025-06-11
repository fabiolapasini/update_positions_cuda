#include "files.h"

#include <fstream>
#include <iostream>

namespace nbody {

void read_values_from_file(const std::string& filename, float* buffer,
                           size_t count) {
  std::ifstream file(filename, std::ios::binary);
  if (!file) {
    std::cerr << "Failed to open file for reading: " << filename << '\n';
    std::exit(EXIT_FAILURE);
  }

  file.read(reinterpret_cast<char*>(buffer), count * sizeof(float));
  if (!file) {
    std::cerr << "Failed to read expected number of bytes from " << filename
              << '\n';
    std::exit(EXIT_FAILURE);
  }
}

void write_values_to_file(const std::string& filename, const float* buffer,
                          size_t count) {
  std::ofstream file(filename, std::ios::binary);
  if (!file) {
    std::cerr << "Failed to open file for writing: " << filename << '\n';
    std::exit(EXIT_FAILURE);
  }

  file.write(reinterpret_cast<const char*>(buffer), count * sizeof(float));
  if (!file) {
    std::cerr << "Failed to write expected number of bytes to " << filename
              << '\n';
    std::exit(EXIT_FAILURE);
  }
}

}  // namespace nbody
