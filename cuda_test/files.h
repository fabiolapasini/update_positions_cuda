#ifndef FILES_H
#define FILES_H

#include <string>

namespace nbody {

void read_values_from_file(const std::string& filename, float* buffer,
                           size_t count);
void write_values_to_file(const std::string& filename, const float* buffer,
                          size_t count);

}  // namespace nbody

#endif  // FILES_H
