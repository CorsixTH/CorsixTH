#ifndef CORSIXTH_TEST_EXAMPLE_H_
#define CORSIXTH_TEST_EXAMPLE_H_

#include <gtest/gtest.h>

namespace {

	TEST(ExampleSuite, ExampleTest) {
		EXPECT_EQ(true, true);
		EXPECT_EQ(false, false);
}
}

#endif //CORSIXTH_TEST_EXAMPLE_H