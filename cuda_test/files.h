#include <fstream>
#include <stdexcept>
#include <string>

void read_values_from_file(const std::string& filename, float* buffer,
                           size_t count) {
  std::ifstream file(filename, std::ios::binary);
  if (!file) {
    std::cerr << "Failed to open file for reading: " << filename << '\n';
    exit(1);
  }
  file.read(reinterpret_cast<char*>(buffer), count * sizeof(float));
  if (!file) {
    std::cerr << "Failed to read expected number of bytes from " << filename
              << '\n';
    exit(1);
  }
}


void write_values_to_file(const std::string& filename, const float* buffer,
                          size_t count) {
  std::ofstream file(filename, std::ios::binary);
  if (!file) {
    std::cerr << "Failed to open file for writing: " << filename << '\n';
    exit(1);
  }
  file.write(reinterpret_cast<const char*>(buffer), count * sizeof(float));
  if (!file) {
    std::cerr << "Failed to write expected number of bytes to " << filename
              << '\n';
    exit(1);
  }
}
