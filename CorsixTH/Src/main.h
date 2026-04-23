/*
Copyright (c) 2010 Peter "Corsix" Cawley

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

#ifndef CORSIX_TH_MAIN_H_
#define CORSIX_TH_MAIN_H_
#include "lua.hpp"

//! Lua mode entry point
/*!
    Performs initialization tasks for setting up the lua environment, and
    then calls the main lua entry point: CorsixTH.lua or an alternative
    script passed in via the command line.

    \see lua_init_no_eval
*/
int lua_init(lua_State* L);

//! Alternative lua mode entry point
/*!
    Performs initialization tasks for setting up the lua environment,
    including preloading libraries and registering C functions; verifying
    the lua runtime version matches; and preparing the stack to call
    CorsixTH.lua or an alternate Lua entry script passed via the command
    line.
*/
int lua_init_no_eval(lua_State* L);

//! Process a caught error before returning it to the caller
/*!
    Processing of the error message is done here so that a stack trace can be
    added before the stack is unwound, and so that if an error occurs while
    processing the error, the caller receives LUA_ERRERR rather than panicking
    while processing it itself.
*/
int lua_stacktrace(lua_State* L);

//! Process an uncaught Lua error before aborting
/*!
    Lua errors shouldn't occur outside of protected mode, and there isn't much
    which can be done when they do, but at least the user should be informed,
    and the error message printed.
*/
int lua_panic(lua_State* L);

#endif  // CORSIX_TH_MAIN_H_
