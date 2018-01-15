/*
Copyright (c) 2017 David Fairbrother

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#include "sprite.h"

#include <cstdint>
#include <gtest/gtest.h>
#include <memory>
#include <cstddef>

namespace {

	std::unique_ptr<uint8_t[]> populateArrayWithVal(size_t length, uint8_t inputVal) {
		auto input = std::make_unique<uint8_t[]>(length);

		for (size_t i = 0; i < length; i++) {
			input[i] = inputVal;
		}
		// Have to force an rValue until we use std c++17.
		return std::move(input);
	}

	// -- ConvertLegacySprite Tests --
	TEST(ConvertLegacySprite, ConvertsSingleSprite) {
		// A single block is 63 pixels
		const size_t length = 63;
		const uint8_t inputVal = 0x55;
		auto input = populateArrayWithVal(length, inputVal);

		auto result = convertLegacySprite(input.get(), length);
		ASSERT_TRUE(result);
		
		// Check the layer type has been correctly changed to reflect the original length
		EXPECT_EQ(result[0], static_cast<uint8_t>(length + 0xC0));

		// Next two bytes should be 255
		EXPECT_EQ(result[1], 0xFF);
		EXPECT_EQ(result[2], 0xFF);

		// Next the original data should have been copied into place
		// Account for the fact the first 3 bytes are already set
		const size_t arrayOffset = 3;
		// Check the first
		EXPECT_EQ(result[arrayOffset], inputVal);
		// Middle
		EXPECT_EQ(result[10 + arrayOffset], inputVal);
		// Last (63 at 0 index)
		EXPECT_EQ(result[62 + arrayOffset], inputVal);

		delete[] result;
	}

	TEST(ConvertLegacySprite, ConvertMultipleSprites) {
		// Pretend each sprite is 63 pixels
		const size_t blockSize = 63;
		const size_t repeatedBlocks = 3;
		const size_t length = blockSize * repeatedBlocks;
		
		const uint8_t inputVal = 0x55;
		auto input = populateArrayWithVal(length, inputVal);

		auto result = convertLegacySprite(input.get(), length);
		ASSERT_TRUE(result);

		// Check the pattern is repeated with multiple data
		// Skip to position one as the previous test checks the single case
		for (int i = 1; i < repeatedBlocks; i++) {
			// Move forwards blocksize + 3 (for our bits) each time).
			const size_t currentOffset = (blockSize * i) + (3 * i);

			// Check the layer type has been correctly changed to 63 + offset instead of our length
			EXPECT_EQ(result[0 + currentOffset], static_cast<uint8_t>(63 + 0xC0));

			// Next two bytes should be 255
			EXPECT_EQ(result[1 + currentOffset], 0xFF);
			EXPECT_EQ(result[2 + currentOffset], 0xFF);

			// Next the original data should have been copied into place
			// Account for the fact the first 3 bytes are already set
			const size_t arrayOffset = 3;
			// Check the first
			EXPECT_EQ(result[currentOffset + arrayOffset], inputVal);
			// Middle
			EXPECT_EQ(result[10 + currentOffset + arrayOffset], inputVal);
			// Last 63 at 0 index
			EXPECT_EQ(result[62 + currentOffset + arrayOffset], inputVal);
		}

		delete[] result;
	}

	TEST(ConvertLegacySprite, HandlesPartialBlock) {
		// Use a block size of 50 instead of 
		const size_t blockSize = 50;
		const uint8_t inputVal = 0x55;

		auto input = populateArrayWithVal(blockSize, inputVal);
		auto result = convertLegacySprite(input.get(), blockSize);
		ASSERT_TRUE(result);

		const size_t headerOffset = 3;

		EXPECT_EQ(result[0], blockSize + 0xC0);
		
		// Check first middle and last 
		EXPECT_EQ(result[headerOffset], inputVal);
		EXPECT_EQ(result[headerOffset + 30], inputVal);
		EXPECT_EQ(result[headerOffset + (blockSize - 1)], inputVal);

		delete[] result;
	}

	TEST(ConvertLegacySprite, HandlesMultiplePartialBlock) {
		const size_t blockSize = 63;
		const size_t partialBlockSize = 30;
		const size_t totalSize = blockSize + partialBlockSize;
		
		const uint8_t inputVal = 0x55;

		auto input = populateArrayWithVal(totalSize, inputVal);
		auto result = convertLegacySprite(input.get(), totalSize);
		ASSERT_TRUE(result);

		const size_t headerOffset = 3;
		EXPECT_EQ(result[blockSize + headerOffset], partialBlockSize + 0xC0);
		// Check first and last partial blocks were copied. We now have 2 headers to walk past
		EXPECT_EQ(result[blockSize + (headerOffset * 2)], inputVal);
		EXPECT_EQ(result[blockSize + (headerOffset * 2) + (partialBlockSize - 1)], inputVal);

		delete[] result;
	}

	// --THChunkRenderer Tests--

	TEST(THChunkRenderer, ConstructorWithNoBuffer) {
		const int widthHeight = 10;
		// If this constructs the test passes
		THChunkRenderer testInstance(widthHeight, widthHeight, nullptr);
	}

	TEST(THChunkRenderer, ConstructorWithBuffer) {
		const int widthHeight = 10;
		auto data = std::make_unique<uint8_t[]>(widthHeight * widthHeight);
		THChunkRenderer testInstance(widthHeight, widthHeight, data.release());
	}

	TEST(THChunkRenderer, chunkCopy) {
		const int widthHeight = 10;
		const uint8_t knownVal = 55;
		const uint8_t newVal = 11;

		const int arrayLength = widthHeight * widthHeight;
		
		auto data = populateArrayWithVal(arrayLength, knownVal);
		auto newValues = populateArrayWithVal(arrayLength, newVal);

		THChunkRenderer testInstance(widthHeight, widthHeight, data.release());

        // Copy all but the last pixel to ensure that it respects our pixel length
		testInstance.chunkCopy((arrayLength - 1), newValues.get());

		auto internalValues = testInstance.getData();

		EXPECT_NE(newValues.get(), internalValues) << "chunkCopy() took ownership of the pointer";

		// Check the first, middle and last values are equal 
		EXPECT_EQ(internalValues[0], newVal);
		EXPECT_EQ(internalValues[arrayLength / 2], newVal);
        EXPECT_EQ(internalValues[arrayLength - 2], newVal);
		EXPECT_EQ(internalValues[arrayLength - 1], knownVal) << "chunkCopy() is not respecting number of pixels";
	}

	TEST(THChunkRenderer, chunkFill) {
        const int widthHeight = 10;
        const uint8_t knownVal = 55;
        const uint8_t newVal = 11;

        const int arrayLength = widthHeight * widthHeight;
        auto data = populateArrayWithVal(arrayLength, knownVal);

        THChunkRenderer testInstance(widthHeight, widthHeight, data.release());
        testInstance.chunkFill((arrayLength - 1), newVal);

        auto internalValues = testInstance.getData();
        EXPECT_EQ(internalValues[0], newVal);
        EXPECT_EQ(internalValues[arrayLength / 2], newVal);
        EXPECT_EQ(internalValues[arrayLength - 2], newVal);
        EXPECT_EQ(internalValues[arrayLength - 1], knownVal) << "chunkFill() is not respecting number of pixels";
	}

    TEST(THChunkRenderer, chunkFillToEndOfLine) {
        const int widthHeight = 10;
        const uint8_t knownVal = 55;
        const uint8_t newVal = 11;

        const int arrayLength = widthHeight * widthHeight;
        auto data = populateArrayWithVal(arrayLength, knownVal);

        THChunkRenderer testInstance(widthHeight, widthHeight, data.release());
        // Move the internal counter along by using chunk fill as this is skipped at the
        // beginning of a line
        testInstance.chunkFill(1, knownVal);
        testInstance.chunkFillToEndOfLine(newVal);

        auto internalVals = testInstance.getData();
        
        // If chunkFill is not working there is no point continuing this test as we
        // start with an unknown state
        ASSERT_EQ(internalVals[0], knownVal);

        EXPECT_EQ(internalVals[1], newVal);
        EXPECT_EQ(internalVals[widthHeight / 2], newVal);
        EXPECT_EQ(internalVals[widthHeight - 1], newVal);
        EXPECT_EQ(internalVals[widthHeight], knownVal) << "chunkFillToEndOfLine has gone beyond the width of the line";
    }

    TEST(THChunkRenderer, chunkFinish) {
        const int widthHeight = 10;
        const uint8_t knownVal = 55;
        const uint8_t newVal = 11;

        const int arrayLength = widthHeight * widthHeight;
        auto data = populateArrayWithVal(arrayLength, knownVal);

        THChunkRenderer testInstance(widthHeight, widthHeight, data.release());
        // Move the internal counter along by using chunk fill to middle of buffer
        testInstance.chunkFill((arrayLength / 2), knownVal);
        testInstance.chunkFinish(newVal);

        auto internalVals = testInstance.getData();

        // Check chunkFill gave us a sane starting state
        ASSERT_EQ(internalVals[(arrayLength / 2) - 1], knownVal);

        EXPECT_EQ(internalVals[arrayLength / 2], newVal);
        EXPECT_EQ(internalVals[arrayLength - 1], newVal) << "chunkFinish did not fill to end of buffer";
    }

    TEST(THChunkRenderer, decodeChunksComplexCase_ZeroVal) {
        const int widthHeight = 10;
        THChunkRenderer testInstance(widthHeight, widthHeight);

        // When the value is 0 we fill with 0xFF to the EOL
        // Check that is does this to end of the line
        const int onePixel = 1;
        const uint8_t knownVal = 55;
        
        // Add a single pixel of known value so we know it is not trampling data
        
        testInstance.chunkFill(onePixel, knownVal);
        
        const size_t inputLen = 1;
        auto inputData = std::make_unique<uint8_t[]>(inputLen);
        inputData[0] = 0;        // 0 Triggers the EOL fill

        const bool complexCase = true;
        testInstance.decodeChunks(inputData.get(), inputLen, complexCase);
        auto internalVals = testInstance.getData();

        // Check the first value was not modified
        EXPECT_EQ(internalVals[0], knownVal) << "First value was not expected, was data overwritten for the whole line";
        
        // And we filled with 0xFF to the EOL
        const uint8_t expectedVal = 0xFF;
        EXPECT_EQ(internalVals[1], expectedVal);
        EXPECT_EQ(internalVals[(widthHeight / 2)], expectedVal);
        EXPECT_EQ(internalVals[(widthHeight - 1)], expectedVal);
    }

    TEST(THChunkRenderer, decodeChunksComplexCase_LessThan64) {
        const int widthHeight = 10;
        THChunkRenderer testInstance(widthHeight, widthHeight);

        const uint8_t knownValueOne = 77;
        const uint8_t knownValueTwo = 88;

        // Any values between 1 and 63 written to the buffer determines the number of 
        // pixels of the adjacent colour to fill with
        // e.g. 63 55 - Fill the buffer with the val '55' 63 times. 
        const uint8_t lowerBoundaryNum = 1;
        const uint8_t upperBoundaryNum = 63;

        // Need to expand the input length to accommodate for the extra pixels
        const size_t extraInputLen = lowerBoundaryNum + upperBoundaryNum;

        const size_t inputLen = 2 + extraInputLen;
        auto inputData = std::make_unique<uint8_t[]>(inputLen);
        inputData[0] = upperBoundaryNum; // Boundary value to trigger in the following 63 pixels

        for (size_t i = 0; i < upperBoundaryNum; i++) {
            // Account for the fact the first value is taken
            inputData[i + 1] = knownValueOne;
        }

        inputData[upperBoundaryNum + 1] = lowerBoundaryNum; // Opposite boundary value to trigger copy of '1' once.
        inputData[upperBoundaryNum + 2] = knownValueTwo;

        const bool complexCase = true;
        testInstance.decodeChunks(inputData.get(), inputLen, complexCase);
        auto internalValues = testInstance.getData();

        size_t currentIndex = 0;
        EXPECT_EQ(internalValues[currentIndex], knownValueOne);
        // As we have checked the first pixel already offset by one
        currentIndex += (upperBoundaryNum - 1);
        EXPECT_EQ(internalValues[currentIndex], knownValueOne) << "The decoder did not chunk fill enough values";

        currentIndex++;
        EXPECT_EQ(internalValues[currentIndex], knownValueTwo) << "The decoder probably overfilled from previous value";
        
        currentIndex++;
        // Lastly we should see the decoder fill the remainder with 0xFF
        EXPECT_EQ(internalValues[currentIndex], 0xFF);
    }

    TEST(THChunkRenderer, decodeChunksComplexCase_ValueIsBetween128And191) {
        const int widthHeight = 20;
        THChunkRenderer testInstance(widthHeight, widthHeight);

        const size_t inputLen = 3;
        auto inputData = std::make_unique<uint8_t[]>(inputLen);
        // When any value with the bit 128 set without the 64 bit 
        // i.e. 128 <= x < 192
        // We fill the next 21 pixels with 0xFF
        inputData[0] = 128; // Lower bound
        inputData[1] = 160; // Arbitrary midpoint
        inputData[2] = 191; // Upper bound

        const bool complexCase = true;
        testInstance.decodeChunks(inputData.get(), inputLen, complexCase);
        auto internalValues = testInstance.getData();
        
        // The length is subtracted by 128 to determine the number of 0xFF to fill
        const size_t subtractedValue = 128;
        const uint8_t expectedVal = 0xFF;

        // For the lower bound case no pixels should have been copied as 128 - 128 = 0
        // So we just check the other ones instead 
        size_t currentIndex = 0;
        EXPECT_EQ(internalValues[currentIndex], expectedVal);
        currentIndex += (inputData[1] - subtractedValue) - 1;
        EXPECT_EQ(internalValues[currentIndex], expectedVal);
        
        // Check upper bounds
        currentIndex++;
        EXPECT_EQ(internalValues[currentIndex], expectedVal);
        currentIndex += (inputData[2] - subtractedValue) - 1;
        EXPECT_EQ(internalValues[currentIndex], expectedVal);
    }

    TEST(THChunkRenderer, decodeChunksComplexCase_ValIs64OrGreater) {
        // We need space for at least 255 pixels so use 20x20 
        const int widthHeight = 20;
        THChunkRenderer testInstance(widthHeight, widthHeight);

        // The boundary conditions this runs is 64 <= x < 128 
        // and 192 <= x < 255
        const uint8_t lowerBoundaryValue = 64;
        const uint8_t lowerMidValue = 127;

        const uint8_t upperMidValue = 192;
        const uint8_t upperBoundaryValue = 254; // 255 is a special case which has its own unit test

        // Set some known values to check
        const uint8_t knownValLower = 60;
        const uint8_t knownValMidLower = 65;
        const uint8_t knownValMidUpper = 70;
        const uint8_t knownValUpper = 75;

        const size_t inputLen = 8;
        auto inputData = std::make_unique<uint8_t[]>(inputLen);
        size_t index = 0;
        
        inputData[index++] = lowerBoundaryValue;
        inputData[index++] = knownValLower;
        
        inputData[index++] = lowerMidValue;
        inputData[index++] = knownValMidLower;

        inputData[index++] = upperMidValue;
        inputData[index++] = knownValMidUpper;

        inputData[index++] = upperBoundaryValue;
        inputData[index++] = knownValUpper;

        const bool complexCase = true;
        testInstance.decodeChunks(inputData.get(), inputLen, complexCase);
        auto internalValues = testInstance.getData();

        // Create a lambda which copies the calculation of amount directly from the source code
        auto calculateAmount = [](uint8_t val)->uint8_t {return val - 60 - (val & 0x80) / 2; };

        // Check the low boundary
        size_t currentIndex = 0;
        EXPECT_EQ(internalValues[currentIndex], knownValLower);
        currentIndex += (calculateAmount(lowerBoundaryValue) - 1);
        EXPECT_EQ(internalValues[currentIndex], knownValLower);

        // Check the mid lower boundary
        currentIndex++;
        EXPECT_EQ(internalValues[currentIndex], knownValMidLower);
        currentIndex += (calculateAmount(lowerMidValue) - 1);
        EXPECT_EQ(internalValues[currentIndex], knownValMidLower);

        // Check the mid upper boundary
        currentIndex++;
        EXPECT_EQ(internalValues[currentIndex], knownValMidUpper);
        currentIndex += (calculateAmount(upperMidValue) - 1);
        EXPECT_EQ(internalValues[currentIndex], knownValMidUpper);

        // Check the upper boundary
        currentIndex++;
        EXPECT_EQ(internalValues[currentIndex], knownValUpper);
        currentIndex += (calculateAmount(upperBoundaryValue) - 1);
        EXPECT_EQ(internalValues[currentIndex], knownValUpper);
    }

    TEST(THChunkRenderer, decodeChunksComplexCase_ValIs255) {
        const int widthHeight = 5;
        THChunkRenderer testInstance(widthHeight, widthHeight);

        const uint8_t knownVal = 66;
        const uint8_t numPixelsToCopy = 21;

        const int inputLen = 3;
        auto inputData = std::make_unique<uint8_t[]>(inputLen);
        inputData[0] = 255;             // This value triggers copying
        inputData[1] = numPixelsToCopy; // This many pixels with
        inputData[2] = knownVal;        // this known value

        const bool complexCase = true;
        testInstance.decodeChunks(inputData.get(), inputLen, complexCase);
        auto internalValues = testInstance.getData();

        EXPECT_EQ(internalValues[0], knownVal);
        EXPECT_EQ(internalValues[numPixelsToCopy - 1], knownVal);

        // The next value should not be the known value
        EXPECT_NE(internalValues[numPixelsToCopy], knownVal) << "Copied more than expected number of pixels";
    }


    TEST(THChunkRenderer, decodeChunksSimpleCase) {
        // We need at least 256+ pixels so instead use 100 * 100
        const int widthHeight = 100;
        THChunkRenderer testInstance(widthHeight, widthHeight);

        // Populate with zeros as we need to setup complex data
        const size_t numberOfSteps = 5;

        // Extra data which is copied to internal buffer, we have 127 + 1 from the vals below
        const size_t extraData = 127 + 1;
        const size_t totalSize = numberOfSteps + extraData;
        auto data = std::make_unique<uint8_t[]>(totalSize);

        size_t index = 0;
        // 1. The magic value 128 triggers chunk filling for (256 - magic val) pixels to 0xFF
        data[index++] = 128;
        // 2. Check the subtraction works correctly with a pixel of value 255 (should subtract 1)
        data[index++] = 255;
        // 3. This should trigger a fill to the end of the line
        data[index++] = 0;
        // 4. Check that pixels below the boundary condition 128 trigger the correct behaviour too
        // This should copy the next 127 pixels
        const size_t longNumPixels = 127;
        const uint8_t longKnownVal = 22;
        data[index++] = longNumPixels;

        // Set the 127 pixels which will be copied excluding the first value
        for (size_t i = 0; i < (longNumPixels - 1); i++) {
            data[index++] = longKnownVal;
        }

        // 5. Set the last pixel to copy too
        data[index] = 1;

        // Now we can run the decoder
        const bool complex = false;
        testInstance.decodeChunks(data.get(), totalSize, complex);
        
        auto internalVals = testInstance.getData();
        size_t currentOffset = 0;
        // Step 1. tests
        EXPECT_EQ(internalVals[currentOffset], 0xFF) << "A value >= 128 did not trigger chunk filling";
        // The first (256 - 128) = 128 pixels should be set to 0xFF
        currentOffset += 128;
        EXPECT_EQ(internalVals[currentOffset], 0xFF) << "The chunk filling did not run to the correct point";

        // Step 2. test - only one pixel should be set to 0xFF
        currentOffset++;
        EXPECT_EQ(internalVals[currentOffset], 0xFF);

        // Step 3. test - the remainder of the line should be now set to 0xFF
        // Round to the nearest EOL by adding the remainder (minus 1 for 0 indexing)
        size_t remainder = widthHeight - (currentOffset % widthHeight);
        currentOffset += (remainder - 1);
        EXPECT_EQ(internalVals[currentOffset], 0xFF);

        // Peek at the next value - if it is also 0xFF abort the other tests
        ASSERT_NE(internalVals[currentOffset + 1], 0xFF) << "Chunk filling overfilled the internal buffer";

        // Step 4. test - The next 127 pixels should have the known value
        currentOffset++;
        EXPECT_EQ(internalVals[currentOffset], longKnownVal);
        currentOffset += (longNumPixels - 2);
        EXPECT_EQ(internalVals[currentOffset], longKnownVal);

        // Step 5. test - The next single pixel should be 1 and only be itself
        currentOffset++;
        EXPECT_EQ(internalVals[currentOffset], 1);
    }

	TEST(THChunkRenderer, takeData) {
		const int widthHeight = 10;
		const uint8_t knownVal = 55;  //Chosen at random
		const size_t arrayLength = widthHeight * widthHeight;

		auto data = populateArrayWithVal(arrayLength, knownVal);

		// Get the pointer address to check we get the same pointer back
		auto dataPtr = data.release();
		THChunkRenderer testInstance(widthHeight, widthHeight, dataPtr);

		auto returnedPtr = testInstance.takeData();
		EXPECT_EQ(dataPtr, returnedPtr) << "The returned pointer did not match the passed pointer";

		// If we do this again a nullptr_t should be returned
		auto secondPtr = testInstance.takeData();
		EXPECT_EQ(secondPtr, nullptr) << "Expected a null pointer the second time takeData was called";

		// We need to delete the pointer as we called release ourselves
		delete[] dataPtr;
	}

} // End of namespace
