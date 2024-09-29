# CUDA NPP Edge Detection

This project implements edge detection using NVIDIA NPP library. The program applies the Sobel filter to detect edges in an image.

## Requirements
- NVIDIA CUDA Toolkit
- NPP (NVIDIA Performance Primitives)

## Build and Run

1. Clone the repository:
   ```bash
   git clone https://github.com/mvishiu11/CUDA-NPP-EdgeDetection
   cd CUDA-NPP-EdgeDetection
   ```

2. Run the provided `run.sh` script:
   ```bash
   ./run.sh
   ```

This will compile and execute the edge detection on the sample image located in the `data` directory.

## Input/Output

- Input image: `data/input_image.jpg`
- Output image: `output/output_image.jpg`
```

### Setting up the Project

1. Make sure CUDA and NPP libraries are installed.
2. Use the provided `Makefile` to compile the project.
3. Use the `run.sh` script to execute the program with input and output image files.