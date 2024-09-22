#!/usr/bin/env python3

"""
  Usage: check_whitespace.py [root-dir]

  This script will check for incorrect whitespace (usage of TAB and trailing
  whitespace) in Lua, Python, and C/C++ files below |root-dir|.
    It will return 0 (ie success) if only correct whitespace is found.
  Otherwise, it will print the path of the violating file(s) and return an
  error code.

  If root-dir is not specified, it will use the current directory.
"""

import os
import re
import sys

# Bad whitespace is
# - a TAB (anywhere),
# - a SPACE before CR,
# - a SPACE before NL, or
# - a SPACE as last character.
BAD_WHITESPACE = re.compile(r'\t| \r| \n| $')


def has_bad_whitespace(path):
    """
    Returns whether the file at |path| has bad whitespace.
    """
    if os.path.isfile(path):
        with open(path, 'r') as handle:
            for line in handle:
                m = BAD_WHITESPACE.search(line)
                if m:
                    return True

    return False

# Main program.
if len(sys.argv) > 2:
    sys.exit(f'Usage: {sys.argv[0]} [root-dir]')

top = os.getcwd()
if len(sys.argv) == 2:
    top = os.path.join(top, sys.argv[1])

count = 0
offending_files = []
for root, dirs, files in os.walk(top):
    for f in files:
        if f.lower().endswith(('.py', '.lua', '.h', '.cpp', '.cc', '.c')):
            count += 1
            path = os.path.join(root, f)
            if has_bad_whitespace(path):
                offending_files.append(path)

print('Checked {} files'.format(count))
if offending_files:
    print('Found files with bad whitespace:')
    for path in offending_files:
        print(path)
    sys.exit(1)

sys.exit(0)
