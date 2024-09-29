#ifndef EDGE_DETECTION_HPP
#define EDGE_DETECTION_HPP

#include <npp.h>
#include <filesystem>
#include <vector>
#include <opencv2/opencv.hpp>
#include <opencv2/core/cuda.hpp>

/**
 * @brief Loads an image from the specified file and copies it to device memory.
 * 
 * @param filename Path to the input image file.
 * @param pSrc Pointer to the device memory where the image will be stored.
 * @param oSizeROI Structure that holds the width and height of the image.
 */
void loadImage(const char* filename, Npp8u** pSrc, NppiSize* oSizeROI);

/**
 * @brief Saves an image from device memory to the specified file.
 * 
 * @param filename Path to the output image file.
 * @param pDst Pointer to the device memory containing the image.
 * @param oSizeROI Structure that holds the width and height of the image.
 */
void saveImage(const char* filename, Npp8u* pDst, NppiSize oSizeROI);

/**
 * @brief Applies a custom Sobel filter on the image.
 * 
 * @param pSrc Pointer to source image in device memory.
 * @param pDst Pointer to destination image in device memory.
 * @param oSizeROI Structure that holds the width and height of the image.
 */
void applyCustomSobel(Npp8u* pSrc, Npp8u* pDst, NppiSize oSizeROI);

/**
 * @brief Applies NPP's Sobel filter on the image.
 * 
 * @param pSrc Pointer to source image in device memory.
 * @param pDst Pointer to destination image in device memory.
 * @param oSizeROI Structure that holds the width and height of the image.
 */
void applyNppSobel(Npp8u* pSrc, Npp8u* pDst, NppiSize oSizeROI);

/**
 * @brief Processes a single image with either custom or NPP Sobel.
 * 
 * @param imageFile Path to the input image file.
 * @param outputDir Path to the directory where output will be saved.
 * @param useCustom Boolean flag to indicate whether to use custom Sobel filter.
 */
void processImage(const std::string& imageFile, const std::string& outputDir, bool useCustom);

/**
 * @brief Processes a batch of images.
 * 
 * @param inputDir Directory containing input images.
 * @param outputDir Directory to save processed images.
 * @param batchSize Number of images to process in a batch.
 * @param useCustom Boolean flag to indicate whether to use custom Sobel filter.
 */
void processBatch(const std::string& inputDir, const std::string& outputDir, int batchSize, bool useCustom);

#endif  // EDGE_DETECTION_HPP