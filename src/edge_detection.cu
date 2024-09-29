#include "edge_detection.hpp"
#include <iostream>
#include <chrono>

/**
 * @brief Kernel to apply Sobel filter to an image.
 * 
 * @param pSrc Input image data.
 * @param pDst Output image data.
 * @param oSizeROI Structure that holds the width and height of the image.
 *
 * @note This kernel is a simple implementation of the Sobel filter. It follows the steps below:
 * 1. Calculate the x and y gradients using the Sobel operator.
 * 2. Compute the gradient magnitude.
 * 3. Normalize the gradient magnitude to the range [0, 255].
**/
__global__ void sobelFilterKernel(const unsigned char* input, unsigned char* output, int width, int height) {
    // Sobel operator kernels
    int Gx[3][3] = {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}};
    int Gy[3][3] = {{-1, -2, -1}, {0, 0, 0}, {1, 2, 1}};
    
    // Get the thread's x and y position in the image
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x > 0 && y > 0 && x < width - 1 && y < height - 1) {
        int sumX = 0;
        int sumY = 0;

        // Apply Sobel filter
        for (int i = -1; i <= 1; ++i) {
            for (int j = -1; j <= 1; ++j) {
                int pixel = input[(y + i) * width + (x + j)];
                sumX += pixel * Gx[i + 1][j + 1];
                sumY += pixel * Gy[i + 1][j + 1];
            }
        }

        // Calculate the gradient magnitude
        int magnitude = min(255, (int)sqrtf(sumX * sumX + sumY * sumY));
        output[y * width + x] = magnitude;
    }
}

void checkNppError(NppStatus status, const char* message) {
    if (status != NPP_SUCCESS) {
        std::cerr << message << ": Error code " << status << std::endl;
        exit(EXIT_FAILURE);
    }
}

void loadImage(const char* filename, Npp8u** pSrc, NppiSize* oSizeROI) {
    cv::Mat h_image = cv::imread(filename, cv::IMREAD_GRAYSCALE);
    
    if (h_image.empty()) {
        std::cerr << "Error: Could not load image " << filename << std::endl;
        exit(EXIT_FAILURE);
    }

    oSizeROI->width = h_image.cols;
    oSizeROI->height = h_image.rows;

    size_t imageSize = oSizeROI->width * oSizeROI->height * sizeof(Npp8u);
    cudaMalloc((void**)pSrc, imageSize);
    cudaMemcpy(*pSrc, h_image.data, imageSize, cudaMemcpyHostToDevice);
}

void saveImage(const char* filename, Npp8u* pDst, NppiSize oSizeROI) {
    cv::Mat h_image(oSizeROI.height, oSizeROI.width, CV_8UC1);
    cudaMemcpy(h_image.data, pDst, oSizeROI.width * oSizeROI.height * sizeof(Npp8u), cudaMemcpyDeviceToHost);
    cv::imwrite(filename, h_image);
}

void applyCustomSobel(Npp8u* pSrc, Npp8u* pDst, NppiSize oSizeROI) {
    int width = oSizeROI.width;
    int height = oSizeROI.height;

    dim3 blockSize(16, 16);
    dim3 gridSize((width + blockSize.x - 1) / blockSize.x, 
                  (height + blockSize.y - 1) / blockSize.y);

    sobelFilterKernel<<<gridSize, blockSize>>>(pSrc, pDst, width, height);

    cudaError_t err = cudaDeviceSynchronize();
    if (err != cudaSuccess) {
        std::cerr << "CUDA error: " << cudaGetErrorString(err) << std::endl;
        exit(EXIT_FAILURE);
    }
}

void applyNppSobel(Npp8u* pSrc, Npp8u* pDst, NppiSize oSizeROI) {
    NppStatus status = nppiFilterSobelVert_8u_C1R(pSrc, oSizeROI.width, pDst, oSizeROI.width, oSizeROI);
    checkNppError(status, "Failed to apply NPP Sobel filter");
}

void processImage(const std::string& imageFile, const std::string& outputDir, bool useCustom) {
    NppiSize oSizeROI;
    Npp8u* pSrc = nullptr;
    Npp8u* pDst = nullptr;

    loadImage(imageFile.c_str(), &pSrc, &oSizeROI);

    std::cout << "Processing image: " << imageFile << std::endl;
    std::cout << "Image size: " << oSizeROI.width << "x" << oSizeROI.height << std::endl;

    cudaMalloc((void**)&pDst, oSizeROI.width * oSizeROI.height * sizeof(Npp8u));

    if (useCustom) {
        applyCustomSobel(pSrc, pDst, oSizeROI);
    } else {
        applyNppSobel(pSrc, pDst, oSizeROI);
    }

    std::string outputFilename = outputDir + "/output_" + (useCustom ? "custom_" : "npp_") + imageFile.substr(imageFile.find_last_of("/") + 1);
    saveImage(outputFilename.c_str(), pDst, oSizeROI);

    cudaFree(pSrc);
    cudaFree(pDst);
}

void processBatch(const std::string& inputDir, const std::string& outputDir, int batchSize, bool useCustom) {
    std::vector<std::string> imageFiles;
    for (const auto& entry : std::filesystem::directory_iterator(inputDir)) {
        if (entry.is_regular_file()) {
            imageFiles.push_back(entry.path().string());
        }
        if (imageFiles.size() == batchSize) break;
    }

    for (const std::string& imageFile : imageFiles) {
        processImage(imageFile, outputDir, useCustom);
    }
}

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "Usage: " << argv[0] << " <input_dir> <output_dir>" << std::endl;
        return 1;
    }

    std::string inputDir = argv[1];
    std::string outputDir = argv[2];
    int batchSize = 210;

    // Create separate directories for custom and NPP outputs
    std::string customOutputDir = outputDir + "/output_custom";
    std::string nppOutputDir = outputDir + "/output_npp";
    std::filesystem::create_directories(customOutputDir);
    std::filesystem::create_directories(nppOutputDir);

    std::cout << "|----------------------CUSTOM SOBEL START----------------------|" << std::endl;

    // Benchmark and process custom Sobel
    auto start = std::chrono::high_resolution_clock::now();
    processBatch(inputDir, customOutputDir, batchSize, true);  // true for custom Sobel
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> customDuration = end - start;
    std::cout << "Custom Sobel processing time: " << customDuration.count() << " seconds" << std::endl;

    std::cout << "|----------------------CUSTOM SOBEL END----------------------|" << std::endl;
    std::cout << "|----------------------NPP SOBEL START----------------------|" << std::endl;

    // Benchmark and process NPP Sobel
    start = std::chrono::high_resolution_clock::now();
    processBatch(inputDir, nppOutputDir, batchSize, false);  // false for NPP Sobel
    end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> nppDuration = end - start;
    std::cout << "NPP Sobel processing time: " << nppDuration.count() << " seconds" << std::endl;

    std::cout << "|----------------------NPP SOBEL END----------------------|" << std::endl;

    return 0;
}