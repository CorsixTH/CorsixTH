#ifdef _ /* Copyright (c) 2009 Peter "Corsix" Cawley
--[[
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

This file is used to ensure that the compiled binary being used by Lua is up
to date. Without this system, if the binary was not recent enough, then the
user would get a confusing error message along the lines of attemping to call
a nil value (as new API functions are nil in older binaries).

When a new API call is added to the C++ source, the version number in this
file should be incremented. Traditionally, the version number will be similar
to the SVN revision number. Likewise, if an existing function is changed in a
way incompatible with old Lua code, then the version number needs to change.

Note: This file compiles as both Lua and C++. */

#endif /*]]--*/

return 1188;
