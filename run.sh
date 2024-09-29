#!/bin/bash

# Build the project
make clean
make

# Run the edge detection
if [ $? -eq 0 ]; then
    ./bin/edge_detection data/input_image.jpg output/output_image.jpg
else
    echo "Build failed"
fi