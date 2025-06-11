# CUDA N-Body Simulation

This project is a gravitational N-body simulation written in C++ and CUDA. Each body interacts with all others according to Newton's law of universal gravitation. The goal is to leverage GPU parallelization to achieve high performance compared to a CPU-only version.

## 🧠 Description

Each body has a 3D position `(x, y, z)` and velocity `(vx, vy, vz)`. The simulation evolves these properties over time based on the gravitational forces between bodies.

Key features:
- Uses CUDA unified memory (`cudaMallocManaged`)
- Prefetches data to the GPU for performance
- Runs for a configurable number of time steps
- Outputs the final body states to a binary file

## 📁 Project Structure

```
.
├── main.cu                 # Main CUDA simulation code
├── files.h / files.cpp     # I/O functions for reading/writing binary data
├── timer.h                 # Timer functions for performance measurement
├── files/
│   ├── initialized_4096    # Example input binary file
│   └── solution_4096       # Output binary file
├── .gitignore
└── README.md
```

## ⚙️ Compilation

Ensure you have the following installed:

- NVIDIA CUDA Toolkit
- A compiler compatible with `nvcc` (e.g., `g++`)

## 🚀 Execution

```bash
./nbody [exponent] [input_file] [output_file]
```

- `exponent` (optional): sets the number of bodies to `2 << exponent`. Default is `2 << 11` = 4096
- `input_file`: binary file with initial body states
- `output_file`: binary file for output results

### Example

```bash
./nbody 14 files/initialized_16384 files/solution_16384
```

## 📥 Input Data (not committed)

The input binary files (`initialized_4096`, `initialized_65536`, etc.) are **not committed to the repository** due to size and practicality. These files contain the initial positions and velocities of all bodies.

Each body is represented by 6 consecutive `float` values:

```
[x, y, z, vx, vy, vz]
```

Example (first 5 bodies):

```
Body 0:  [ 0.6804, -0.2112,  0.5662,  0.5969,  0.8233, -0.6049 ]
Body 1:  [-0.3296,  0.5365, -0.4445,  0.1079, -0.0452,  0.2577 ]
Body 2:  [-0.2704,  0.0268,  0.9045,  0.8324,  0.2714,  0.4346 ]
Body 3:  [-0.7168,  0.2139, -0.9674, -0.5142, -0.7255,  0.6084 ]
Body 4:  [-0.6866, -0.1981, -0.7404, -0.7824,  0.9978, -0.5635 ]
```

Ensure the total number of `float` values in the file equals:

```
nBodies * 6
```

## 📦 Output

At the end of the simulation, the program prints the performance:

```
X.XXX Billion Interactions / second
```

It also writes the final state of the system to the specified binary output file.
