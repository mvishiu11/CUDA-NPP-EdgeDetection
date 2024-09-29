# CUDA NPP vs Custom Sobel Edge Detection

## Introduction

This repository showcases the performance comparison between a custom Sobel filter implemented using the CUDA runtime API and NVIDIA’s NPP (NVIDIA Performance Primitives) Sobel filter. Both filters are applied to a batch of 210 grayscale images, each sized at 250x250 pixels, taken from the [Modified USC-SIPI Image Database](https://github.com/orukundo/Modified-USC-SIPI-Image-Database). The primary goal of this project is to demonstrate how much faster the NPP-based implementation is compared to a custom-written Sobel filter in CUDA, while providing a deeper understanding of Sobel filtering and its importance in image processing.

---

## Table of Contents
- [CUDA NPP vs Custom Sobel Edge Detection](#cuda-npp-vs-custom-sobel-edge-detection)
  - [Introduction](#introduction)
  - [Table of Contents](#table-of-contents)
  - [What is Sobel Filtering?](#what-is-sobel-filtering)
    - [Sobel Filter Overview](#sobel-filter-overview)
    - [Custom Sobel Implementation](#custom-sobel-implementation)
      - [Pseudocode:](#pseudocode)
  - [NVIDIA NPP Library](#nvidia-npp-library)
    - [Why is NPP faster?](#why-is-npp-faster)
  - [Dataset](#dataset)
  - [Benchmark Results](#benchmark-results)
    - [Analysis](#analysis)
    - [Visual Comparison](#visual-comparison)
  - [Output](#output)
  - [Build and Run Instructions](#build-and-run-instructions)
    - [Requirements](#requirements)
    - [Setup](#setup)
  - [Directory Structure](#directory-structure)
  - [LICENSE](#license)

---

## What is Sobel Filtering?

### Sobel Filter Overview

The Sobel filter is a popular edge detection technique that computes an approximation of the gradient of an image's intensity function. It applies two 3x3 convolution masks (Sobel kernels) to the image to detect horizontal and vertical edges separately. The gradients produced by these masks are combined to determine the magnitude of the edge at each pixel.

The Sobel filter uses two kernels:
- **Gx** for detecting horizontal edges:
  ```
  -1  0  1
  -2  0  2
  -1  0  1
  ```
- **Gy** for detecting vertical edges:
  ```
  -1 -2 -1
   0  0  0
   1  2  1
  ```

These kernels are convolved with the image to compute the gradient at each pixel. The overall gradient magnitude at each pixel is then computed as:
```
G = sqrt(Gx^2 + Gy^2)
```

### Custom Sobel Implementation

Our custom Sobel filter is implemented using CUDA kernels, where each pixel's gradient is computed in parallel across GPU threads. The algorithm iterates through the image, applying the Sobel kernels to the pixel’s neighborhood and calculating the gradient magnitude. Though highly parallelized, this custom implementation is not optimized as heavily as NVIDIA’s NPP library.

#### Pseudocode:
```c
for each pixel (x, y) in the image:
    Gx = sum of horizontal kernel applied to neighborhood
    Gy = sum of vertical kernel applied to neighborhood
    Gradient = sqrt(Gx^2 + Gy^2)
    output(x, y) = min(255, Gradient)
```

---

## NVIDIA NPP Library

NPP (NVIDIA Performance Primitives) is a library designed to accelerate image, signal, and video processing on NVIDIA GPUs. NPP offers highly optimized implementations of commonly used functions, including edge detection filters like Sobel. These implementations take full advantage of the GPU’s hardware architecture, resulting in significant performance gains compared to custom implementations.

NPP Sobel filter benefits:
- Highly optimized for the GPU
- Supports multi-channel and large images
- Scales well with large datasets
- Provides a broad set of image processing functions

### Why is NPP faster?

NPP leverages low-level optimizations, such as:
- Using GPU-specific memory handling for faster access
- Parallel computation strategies optimized for image data
- Minimizing redundant memory transfers
- Efficient use of shared memory and registers

This results in dramatic improvements in processing time compared to custom, non-optimized code.

---

## Dataset

We used 210 grayscale images (each 250x250 pixels) from the [Modified USC-SIPI Image Database](https://github.com/orukundo/Modified-USC-SIPI-Image-Database). This dataset contains images that have been resized to various dimensions and converted to 8-bit grayscale format, which is suitable for edge detection algorithms like Sobel.

---

## Benchmark Results

The processing time for applying Sobel edge detection to all 210 images is compared between the custom CUDA implementation and the NPP-based Sobel filter:

| Sobel Filter     | Processing Time (seconds) |
|------------------|---------------------------|
| **Custom Sobel** | 1.95859                   |
| **NPP Sobel**    | 0.0981251                 |

Those results were obtained on an Nvidia GeForce RTX 4080 (Ada Lovelace) GPU.

### Analysis

- The **Custom Sobel** implementation takes about **1.96 seconds** to process all 210 images.
- The **NPP Sobel** filter, in contrast, finishes the task in just **0.098 seconds**, which is about **20x faster** than the custom implementation.

While the custom Sobel filter is straightforward and demonstrates how edge detection works at a lower level, it cannot compete with the highly optimized NPP library, which is specifically designed for performance on NVIDIA GPUs.

### Visual Comparison

Both the NPP-based Sobel filter and our custom implementation generate similar edge-detection results, but we observed slight differences in visual quality, where the custom filter sometimes provides crisper edges. The output images for both implementations are saved in separate directories for easy comparison.

---

## Output

- **Custom Sobel Filter Results**: Saved in `output_custom/`
- **NPP Sobel Filter Results**: Saved in `output_npp/`

Each image in these folders is named according to its original name in the dataset, suffixed with the appropriate processing method.

---

## Build and Run Instructions

### Requirements

- **NVIDIA CUDA Toolkit** (for compiling CUDA code)
- **NPP** (part of the CUDA Toolkit)
- **OpenCV** (for handling image I/O)
- **C++17** (or later)

### Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/mvishiu11/CUDA-NPP-EdgeDetection.git
   cd CUDA-NPP-EdgeDetection
   ```

2. Make sure you have the necessary dependencies installed:
   ```bash
   sudo apt-get install libopencv-dev
   ```

3. Build the project using the provided `Makefile`:
   ```bash
   make all
   ```

4. Run the edge detection program:
   ```bash
   ./bin/edge_detection <input_directory> <output_directory>
   ```

This will apply both the custom Sobel filter and the NPP Sobel filter on the batch of images and store the results in two separate output directories under `<output_directory>`.

---

## Directory Structure

```
.
├── data/                     # Input images in JPG format
├── include/                  # Header files
│   └── edge_detection.hpp
├── src/                      # Source files
│   └── edge_detection.cu
├── obj/                      # Compiled object files
├── bin/                      # Compiled executables
├── output/                   # Output files
    └── output.txt            # run.sh artifact
    └── images/               # Output images
    └── output_custom/            # Output images processed using custom Sobel filter
    └── output_npp/               # Output images processed using NPP Sobel filter
├── Makefile                  # Build script
└── run.sh                    # Run script
```

---

## LICENSE

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.