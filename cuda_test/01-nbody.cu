#include <cmath>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <memory>
#include <sstream>
#include <string>
#include <vector>

#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "files.h"
#include "timer.h"

constexpr float SOFTENING = 1e-9f;

/*
 * Each body contains x, y, and z coordinate positions,
 * as well as velocities in the x, y, and z directions.
 */
struct Body {
  float x, y, z;     // position
  float vx, vy, vz;  // speed
};

/*
 * CUDA kernel to compute gravitational forces between all bodies.
 */
__global__ void bodyForce(Body* p, float dt, int n) {
  int index = threadIdx.x + blockIdx.x * blockDim.x;  // Global thread index
  int stride = blockDim.x * gridDim.x;                // Total number of threads

  for (int i = index; i < n; i += stride) {
    float Fx = 0.0f, Fy = 0.0f, Fz = 0.0f;

    for (int j = 0; j < n; ++j) {
      float dx = p[j].x - p[i].x;
      float dy = p[j].y - p[i].y;
      float dz = p[j].z - p[i].z;
      float distSqr = dx * dx + dy * dy + dz * dz + SOFTENING;
      float invDist = rsqrtf(distSqr);
      float invDist3 = invDist * invDist * invDist;

      Fx += dx * invDist3;
      Fy += dy * invDist3;
      Fz += dz * invDist3;
    }

    // Update velocity based on force
    p[i].vx += dt * Fx;
    p[i].vy += dt * Fy;
    p[i].vz += dt * Fz;
  }
}

int main(int argc, char** argv) {
  int nBodies = 1 << 12;  // means 2 * 2^11 = 4096
  if (argc > 1) {
    try {
      nBodies = 2 << std::stoi(argv[1]);  // means 2 * 2^argv[1]
    } catch (...) {
      std::cerr << "Invalid argument for body count. Using default.\n";
    }
  }

  std::string base_path = "files/";
  std::string file_suffix = (nBodies == (1 << 12)) ? "4096" : "65536";
  std::string initialized_values = base_path + "initialized_" + file_suffix;
  std::string solution_values = base_path + "solution_" + file_suffix;

  if (argc > 2) initialized_values = argv[2];
  if (argc > 3) solution_values = argv[3];

  constexpr float dt = 0.01f;
  constexpr int nIters = 10;

  // Set active GPU device
  if (cudaSetDevice(0) != cudaSuccess) {
    std::cerr << "Failed to set CUDA device.\n";
    return 1;
  }
  int deviceId;
  cudaGetDevice(&deviceId);  // Get current GPU device ID

  size_t size = static_cast<size_t>(nBodies) * sizeof(Body);
  size_t nFloats = size / sizeof(float);
  Body* p = nullptr;

  // Allocate unified memory accessible by CPU and GPU
  if (cudaMallocManaged(&p, size) != cudaSuccess) {
    std::cerr << "CUDA malloc error.\n";
    return 1;
  }

  // Prefetch memory to GPU to improve performance
  cudaMemPrefetchAsync(p, size, deviceId);

  // Read initial values into a temporary float vector
  std::vector<float> inputBuffer(nFloats);
  read_values_from_file(initialized_values, inputBuffer.data(), nFloats);
  std::memcpy(reinterpret_cast<float*>(p), inputBuffer.data(), size);

  int threadsPerBlock = 256;
  int numberOfBlocks = (nBodies + threadsPerBlock - 1) / threadsPerBlock;

  cudaStream_t stream;
  cudaStreamCreate(&stream);  // Create CUDA stream for concurrent operations

  double totalTime = 0.0;
  for (int iter = 0; iter < nIters; ++iter) {
    StartTimer();

    // Launch kernel on the specified CUDA stream
    bodyForce<<<numberOfBlocks, threadsPerBlock, 0, stream>>>(p, dt, nBodies);

    // Synchronize to wait for kernel execution to finish
    cudaStreamSynchronize(stream);

    // Integrate position based on updated velocity
    for (int i = 0; i < nBodies; ++i) {
      p[i].x += p[i].vx * dt;
      p[i].y += p[i].vy * dt;
      p[i].z += p[i].vz * dt;
    }

    totalTime += GetTimer() / 1000.0;
  }

  // Destroy the CUDA stream after use
  cudaStreamDestroy(stream);

  double avgTime = totalTime / static_cast<double>(nIters);
  double interactionsPerSecond = 1e-9 * nBodies * nBodies / avgTime;
  std::ostringstream interactionsPerSecondString;
  interactionsPerSecondString << std::fixed << std::setprecision(3)
                              << interactionsPerSecond;
  std::cout << interactionsPerSecondString.str()
            << " Billion Interactions / second\n";

  // Write output data to file
  std::vector<float> outputBuffer(reinterpret_cast<float*>(p),
                                  reinterpret_cast<float*>(p) + nFloats);
  write_values_to_file(solution_values, outputBuffer.data(), nFloats);

  // Free unified memory
  cudaFree(p);

  return 0;
}
