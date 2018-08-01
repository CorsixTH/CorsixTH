#!/usr/bin/env python3

"""
  Usage: check_trailing_whitespaces.py [root]
  This script will check the presence of trailing whitespaces in any file
  below |root|. It will return 0 if none is found. Otherwise, it will print the
  path of the violating file and return an error code.
  If root is not specified, it will use the current directory.
"""

import os
import re
import sys

TRAILING_SEQUENCE = re.compile(r'[ \t][\r\n]')


def has_trailing_whitespace(path):
    """ Returns whether |path| has trailing whitespace. """
    if os.path.isfile(path):
        with open(path, 'r') as handle:
            for line in handle:
                m = TRAILING_SEQUENCE.search(line)
                if m:
                    return True

    return False


if len(sys.argv) > 2:
    sys.exit('Usage: {} [root]'.format(sys.argv[0]))

top = os.getcwd()
if len(sys.argv) == 2:
    top = os.path.join(top, sys.argv[1])

count = 0
offending_files = []
for root, dirs, files in os.walk(top):
    for f in files:
        if f.endswith(('.py', '.lua', '.h', '.cpp', '.cc', '.c')):
            count += 1
            path = os.path.join(root, f)
            if has_trailing_whitespace(path):
                offending_files.append(path)

print('Checked {} files'.format(count))
if offending_files:
    print('Found files with trailing whitespace:')
    for path in offending_files:
        print(path)
    sys.exit(1)

sys.exit(0)
