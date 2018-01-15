#ifndef CORSIXTH_TEST_EXAMPLE_H_
#define CORSIXTH_TEST_EXAMPLE_H_

#include <gtest/gtest.h>

namespace {

	// This file provides a sanity check. If it fails something 
	// is wrong with our unit test setup

	TEST(ExampleSuite, ExampleTest) {
		EXPECT_EQ(true, true);
		EXPECT_EQ(false, false);
}
}

#endif //CORSIXTH_TEST_EXAMPLE_H
