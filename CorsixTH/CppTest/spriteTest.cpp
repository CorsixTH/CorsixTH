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

	// -- Test helpers --
	std::unique_ptr<uint8_t[]> populateLegacySpriteData(size_t length, uint8_t inputVal) {
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
		auto input = populateLegacySpriteData(length, inputVal);

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
		auto input = populateLegacySpriteData(length, inputVal);

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

		auto input = populateLegacySpriteData(blockSize, inputVal);
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

		auto input = populateLegacySpriteData(totalSize, inputVal);
		auto result = convertLegacySprite(input.get(), totalSize);
		ASSERT_TRUE(result);

		const size_t headerOffset = 3;
		EXPECT_EQ(result[blockSize + headerOffset], partialBlockSize + 0xC0);
		// Check first and last partial blocks were copied. We now have 2 headers to walk past
		EXPECT_EQ(result[blockSize + (headerOffset * 2)], inputVal);
		EXPECT_EQ(result[blockSize + (headerOffset * 2) + (partialBlockSize - 1)], inputVal);

		delete[] result;
	}

} // End of namespace
