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

import getopt
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


def main():
    # Process the command line.
    short_opts = "he:"
    long_opts = []
    try:
        opts, args = getopt.getopt(sys.argv[1:], short_opts, long_opts)
    except getopt.GetoptError as ex:
        print(f"ERROR: {ex}")
        sys.exit(1)

    # Process the found options.
    excludes = []
    for opt, optval in opts:
        if opt == '-h':
            print("Usage: check_whitespace [options] [ROOT-DIR ...]")
            print()
            print("Checks source files for bad whitespace. Recursively examines all")
            print("supplied ROOT-DIR, or the current directory if no root is provided.")
            print()
            print("Options:")
            print("  -h       Print this help text")
            print("  -e TEXT  Exclude source files with TEXT in their path")
            print("           This option may be used multiple times")
            print()
            print("Have a nice day!")
            sys.exit(0)

        if opt == '-e':
            excludes.append(optval)
            continue

        # Shouldn't happen due to getopt checking.
        assert False, f"Unexpected option ({(opt, optval)} found."

    # Setup root directories.
    cur_dir = os.getcwd()
    if args:
        tops = [os.path.join(cur_dir, arg) for arg in args]
    else:
        tops = [cur_dir]

    # Process files.
    count = 0
    offending_files = []
    found_errors = False
    for top in tops:
        for root, dirs, files in os.walk(top):
            for f in files:
                # Skip non-source files.
                if not f.lower().endswith(('.py', '.lua', '.h', '.cpp', '.cc', '.c')):
                    continue

                # Skip files with excluded patterns.
                path = os.path.join(root, f)
                if any(excl in path for excl in excludes):
                    continue

                # Check the file.
                count += 1
                try:
                    if has_bad_whitespace(path):
                        found_errors = True
                        offending_files.append(path)

                except UnicodeDecodeError:
                    print(f"ERROR: File {path} has Unicode errors.")
                    found_errors = True

    # Report files with bad whitespace.
    print('Checked {} files'.format(count))
    if offending_files:
        print('Found files with bad whitespace:')
        for path in offending_files:
            print(path)

    # And construct the return code.
    if found_errors:
        sys.exit(1)
    else:
        sys.exit(0)

if __name__ == '__main__':
    main()
