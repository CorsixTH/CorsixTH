#!/usr/bin/env python3

"""
  Usage: check_whitespace.py [-e EXCL] [root-dir ...]

  This script will check for incorrect whitespace (usage of TAB and trailing
  whitespace) in Lua, Python, and C/C++ files below one of the listed
  |root-dir| directories. With the -e option you can specify one or more EXCL
  fragments that skips file paths that have one of the fragments.
    It will return 0 (ie success) if only correct whitespace is found.
  Otherwise, it will print the path of the violating file(s) and return an
  error code.

  If no root-dir is specified, it will use the current directory.
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

MESSAGES = {
    (True, False): "has at least one tab character",
    (False, True): "has trailing whitespace",
    (True, True): "has both at least one tab character and trailing whitespace"
}

def check_for_bad_whitespace(path):
    """
    Checks the file at |path| for tab and trailing white space and returns an
    error-message if something bad was found, or None.
    """
    has_bad_tab = False
    has_bad_space = False
    if os.path.isfile(path):
        with open(path, 'r') as handle:
            for line in handle:
                bad_whites = BAD_WHITESPACE.findall(line)
                if bad_whites:
                    bad_tab_count = sum(1 for bw in bad_whites if bw == '\t')
                    bad_space_count = len(bad_whites) - bad_tab_count

                    has_bad_tab = has_bad_tab or (bad_tab_count > 0)
                    has_bad_space = has_bad_space or (bad_space_count > 0)

                    if has_bad_tab and has_bad_space:
                        break # Found everything we can possibly find, done.

    if has_bad_tab or has_bad_space:
        return f"File \"{path}\" {MESSAGES[(has_bad_tab, has_bad_space)]}"
    return None


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
    messages = []
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
                    message = check_for_bad_whitespace(path)
                    if message is not None:
                        found_errors = True
                        messages.append(message)

                except UnicodeDecodeError:
                    print(f"ERROR: File {path} has Unicode errors.")
                    found_errors = True

    # Report files with bad whitespace.
    print('Checked {} files'.format(count))
    if messages:
        print()
        print('Found files with bad whitespace:')
        for message in messages:
            print(message)

    # And construct the return code.
    if found_errors:
        sys.exit(1)
    else:
        sys.exit(0)

if __name__ == '__main__':
    main()
