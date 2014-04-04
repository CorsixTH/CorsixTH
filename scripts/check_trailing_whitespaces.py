#!/usr/bin/python

"""
  Usage: check_trailing_whitespaces.py [root]
  This script will check the presence of trailing whitespaces in any file
  below |root|. It will return 0 if none is found. Otherwise, it will print the
  path of the violating file and return an error code.
  If root is not specified, it will use the current directory.
"""

import fileinput
import os
import re
import sys

def has_trailing_whitespaces(path):
  """ Returns whether |path| has trailing whitespaces. """
  for line in open(path, 'r'):
    for idx in range(-1, -len(line) - 1, -1):
      if line[idx] == '\n' or line[idx] == '\r':
        continue
      if line[idx] == ' ':
        return True
      break
  return False

if (len(sys.argv) > 2):
  sys.exit('Usage: ' + sys.argv[0] + ' [root]')

top = os.getcwd()
if len(sys.argv) == 2:
  top += '/' + sys.argv[1]

for root, dirs, files in os.walk(top):
  for f in files:
    if f.endswith('.py') or f.endswith('.lua') or f.endswith('.h') or \
       f.endswith('.cpp') or f.endswith('.cc') or f.endswith('.c'):
         path = root + '/' + f
         if has_trailing_whitespaces(path):
           sys.exit('Found a file with trailing whitespaces: ' + path)

sys.exit(0)

