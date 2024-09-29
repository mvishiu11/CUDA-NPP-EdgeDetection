# Compiler and flags
NVCC = nvcc
CXXFLAGS = -std=c++17 `pkg-config --cflags opencv4` -Iinclude -I/usr/local/cuda/include

# Directories
OBJ_DIR = obj
BIN_DIR = bin
SRC_DIR = src
INCLUDE_DIR = include

# Executable name
EXEC = $(BIN_DIR)/edge_detection

# Source and object files
SRC_FILES = $(SRC_DIR)/edge_detection.cu
OBJ_FILES = $(OBJ_DIR)/edge_detection.o

# CUDA libraries
CUDA_LIBS = -lcuda -lnppig -lnppif -lnppc

# OpenCV libraries (added for linking)
OPENCV_LIBS = `pkg-config --libs opencv4`

# Targets

.PHONY: all clean

# Default target: build the executable
all: $(EXEC)

# Create the executable by linking object files
$(EXEC): $(OBJ_FILES) | $(BIN_DIR)
	$(NVCC) $(OBJ_FILES) -o $(EXEC) $(CUDA_LIBS) $(OPENCV_LIBS)

# Compile the source files to object files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cu | $(OBJ_DIR)
	$(NVCC) -diag-suppress=611 $(CXXFLAGS) -c $< -o $@

# Create the obj and bin directories if they don't exist
$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# Clean the build
clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR)