#!/usr/bin/python

"""
  Usage: check_language_files_not_BOM.py [root]
  This script will check the presence of language files encoded in UTF-8 with BOM.
  It will return 0 if none is found. Otherwise, it will print the
  path of the violating files and return an error code.
  If root is not specified, it will use the current directory.
"""

import codecs
import os
import sys

def is_BOM_encoded_file(path):
  """ Returns whether |path| is a file that is encoded in UTF-8 with BOM. """
  with open(path, 'rb') as f:
    raw = f.read(4)
    return raw.startswith(codecs.BOM_UTF8)

if (len(sys.argv) > 2):
  sys.exit('Usage: ' + sys.argv[0] + ' [root]')

top = os.getcwd()
if len(sys.argv) == 2:
  top += '/' + sys.argv[1]

offending_files = []
for root, dirs, files in os.walk(top):
  for f in files:
    if f.endswith('.lua'):
         path = root + '/' + f
         if is_BOM_encoded_file(path):
           offending_files.append(f)

if offending_files:
  sys.exit('Found files with UTF-8 with BOM encoding: ' + str(offending_files))
sys.exit(0)
