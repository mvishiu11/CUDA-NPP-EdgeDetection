#!/bin/bash

# Build the project
make clean
make

# Run the edge detection batch processing on 250 images
if [ $? -eq 0 ]; then
    ./bin/edge_detection data/images output/images
else
    echo "Build failed"
fi