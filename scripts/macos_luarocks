#!/bin/bash
: ' Copyright (c) 2016- Toby "tobylane"
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
SOFTWARE.'
## Settings
# Lua version, if not the lua CorsixTH was built with. Use 5.1 for luajit
#lua_version="5.4"
# The luarocks executable if not in PATH
luarocks="luarocks"
# The luarocks folder, assuming all rocks are together
dir="$($luarocks show --rock-tree luafilesystem)"
# Always overwrite existing rocks if uncommented
#always_copy=true
# Always build new rocks if uncommented
#always_build=true

set -ae
if [ "$CTH_VERBOSE" ] || [ "$CI" ]; then
  set -x
fi

# Find target app
if [ -d "$1" ]; then
  cd "$1"
elif [ -d /Applications/CorsixTH.app ]; then
  cd /Applications/
fi
if [ -d CorsixTH.app ]; then
  cd CorsixTH.app/Contents/Resources/
else
  echo "No CorsixTH.app found"
  exit 1
fi

# Find lua version
if [ -n "$lua_version" ]; then
  lua=$lua_version
elif otool -L ../MacOS/CorsixTH | grep -q 'lua'; then
  lua="$(otool -L ../MacOS/CorsixTH | grep 'lua' | sed -rn "s/.*current.* ([0-9]\.[0-9]).*/\1/p")"
elif lua -v >/dev/null; then
  lua="$(lua -v | cut -d" " -f2 | cut -d. -f1-2)"
fi
if [ -z "$lua" ]; then
  lua=5.4
  echo "No Lua library or executable found, using version 5.4."
fi

# Collect rocks
if [ -e lfs.so ] && [ -e lpeg.so ] && [ -z "$always_copy" ] && [ -z "$always_build" ]
  then echo "Luarocks for $lua in place."
  exit 0
elif [ -e "$dir/lib/lua/$lua/lfs.so" ] && [ -e "$dir/lib/lua/$lua/lpeg.so" ] &&
 [ -d "$dir/share/lua/" ] && [ -z "$always_build" ]
  then mkdir -p lib/lua/"$lua/" share/lua/"$lua/"
  cp -RL "$dir/lib/lua" lib/
  cp -RL "$dir/share/lua" share/
  echo "Copied luarocks from global installation for $lua."
else
  luarocks="$luarocks install --lua-version $lua --tree ."
  $luarocks luafilesystem
  $luarocks lpeg
  echo "Installed local luarocks for $lua."
fi

# Move into place for CorsixTH
rsync -r "lib/lua/$lua/"lpeg.so "lib/lua/$lua/"lfs.so .
rsync -r "share/lua/$lua/"re.lua ./Lua/
rm -rf lib/ share/
