UNIT TESTING

In order to run the unit test suite you need a unit test framework called Busted.
The easiest way to get it is through Luarocks. All information can be found at

http://olivinelabs.com/busted/

The framework uses its own syntax, which is also described at the above location.


RUNNING UNIT TESTS

When you have Busted on your system, run the following command from
the CorsixTH/Luatest folder to run all tests:

(Windows)
busted --lpath=../Lua/\?.lua

(Linux)
busted --lpath=../Lua/?.lua


CREATING UNIT TESTS

If you have added functionality to an existing file you will need to extend
the unit test suite for that file. It is found in the Luatest/spec folder using
the same hierarchy as in the normal Lua folder. All test files are called
<original_file_name>_spec.lua. If you have created a new lua file, then
you also create a new *_spec.lua test file.
