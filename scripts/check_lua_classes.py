#!/usr/bin/env python3
'''
Script to check good form of class definitions.
'''

import os
import re
import sys
from dataclasses import dataclass
from typing import Optional

CLASS_LINE_RE = re.compile(' *class *"([A-Za-z0-9]+)"( *[(]([A-Za-z0-9]+)[)])?')

@dataclass
class ClassDef:
    linenum: int # 0-based
    class_name: str
    parent_name: Optional[str]


def plural_count(count: int, singular: str, plural: Optional[str]=None):
    '''
    Select or create the correct '<count> singular' resp '<count> plural' form
    depending on the count. If 'plural' is None, it is created by taking the
    singular form and appending an 's' to it.
    '''
    if count == 1:
        return f'1 {singular}'

    if not plural:
        plural = singular + 's'
    return f'{count} {plural}'


def process_file(fpath, report_path):
    '''
    Check the file for class lines and check that they have the expected form.

    @return: Error message lines and number of found errors in the file.
    '''
    # Read the file while finding class definition lines.
    text_lines = []
    class_defs: list[ClassDef] = []
    with open(fpath) as handle:
        for linenum, line in enumerate(handle):
            line = line.rstrip()
            text_lines.append(line)

            if 'class' in line: # Try a quick match first.
                m = CLASS_LINE_RE.fullmatch(line)
                if m:
                    class_defs.append(ClassDef(linenum, m.group(1), m.group(3)))

    result_lines = []
    error_count = 0

    # If no class definitions are found, the check is done.
    if not class_defs:
        return result_lines, error_count

    for cd in class_defs:
        # Create a matcher for the '--- @class Foo: Bar' line that should exist.
        if cd.parent_name:
            orig_class_line = f'class "{cd.class_name}" ({cd.parent_name})'
            class_line_text = f'---@class {cd.class_name}: {cd.parent_name}'
            class_line_re_text = f'--- ?@class +{cd.class_name} *: +{cd.parent_name}'
        else:
            orig_class_line = f'class "{cd.class_name}"'
            class_line_text = f'---@class {cd.class_name}'
            class_line_re_text = f'--- ?@class +{cd.class_name}'
        class_line_re = re.compile(class_line_re_text)

        operator_text = f'---@operator call: {cd.class_name}'
        operator_re_text = f'--- ?@operator +call *: +{cd.class_name}'
        operator_line_re = re.compile(operator_re_text)

        local_text = f'local {cd.class_name} = _G["{cd.class_name}"] ---@type {cd.class_name}'
        local_re_text = f'local +{cd.class_name} += +_G\\["{cd.class_name}"\\] +--- ?@type +{cd.class_name}'
        local_line_re = re.compile(local_re_text)

        doc_start_line_re = re.compile('--- ?@')

        # cd.linenum has the 'class "Foo" (Bar)' line, which was found above.
        # Start checking at the line below it.
        linenum = cd.linenum + 1 # cd.linenum has the 'class "Foo" (Bar)' line.
        last_lnum = len(text_lines) - 1
        err = None

        # Should find an empty line.
        if err is None and linenum <= last_lnum:
            if text_lines[linenum]:
                err = (linenum, "Expected empty line below the 'class' line.")
            else:
                linenum = linenum + 1

        # Should find the  '@class' line.
        if err is None and linenum <= last_lnum:
            m = class_line_re.fullmatch(text_lines[linenum])
            if not m:
                err = (linenum, f"Expected the line '{class_line_text}'.")
            else:
                linenum = linenum + 1

        # Possibly more ---@ lines follow, eventually followed by the
        # '---@operator call: Fee' line.
        while err is None and linenum <= last_lnum:
            m = operator_line_re.fullmatch(text_lines[linenum])
            if m:
                # Found the operator line, break out of the loop.
                linenum = linenum + 1
                break

            # Otherwise ensure that the line is documentation.
            m = doc_start_line_re.match(text_lines[linenum])
            if not m:
                err = (linenum, f"Expected the line '{operator_text}'.")
                break

            linenum = linenum + 1

        # After the '@operator' line, the 'local X = _G["X"] ---@type X' line is expected.
        if err is None and linenum <= last_lnum:
            m = local_line_re.fullmatch(text_lines[linenum])
            if not m:
                err = (linenum, f"Expected the line '{local_text}'.")
            else:
                linenum = linenum + 1

        if err is None:
            # Somewhere above we may have run out of text lines and skipped checks.
            # Make sure that doesn't happen without getting noticed.
            if linenum >= last_lnum:
                err = (linenum, "Reached end of the file.")


        if err is None:
            # No problem found with this class; continue with the next definition.
            continue

        # Found a problem in the file. Initialize 'result_lines' if not done
        # already.
        if not result_lines:
            result_lines.append('') # Set afterwards since it gives a cumulative overview.
        else:
            # Separator between error reports.
            result_lines.append('')
            result_lines.append('')
            result_lines.append('')

        result_lines.append(f'Error at line {err[0] + 1}: {err[1]}')
        result_lines.append('---')
        result_lines.append(f'For reference, the expected lines of the class definition at line {cd.linenum + 1} are')
        result_lines.append('')
        result_lines.append(orig_class_line)
        result_lines.append('')
        result_lines.append(class_line_text)
        result_lines.append('<<possibly other ---@ lines to document the class>>')
        result_lines.append(operator_text)
        result_lines.append(local_text)
        error_count = error_count + 1

    if result_lines:
        count_text = f'{plural_count(error_count, "problem")}'
        result_lines[0] = f'Found {count_text} in file {report_path}:'

    return result_lines, error_count


def main():
    script_dir = os.path.join(os.path.dirname(__file__), "..", "CorsixTH", "Lua")

    result_lines = []
    total_error_count = 0
    total_file_count = 0
    for path, dirs, fnames in os.walk(script_dir):
        # Avoid processing the 'languages' directory in a next iteration.
        if 'languages' in dirs:
            dirs.remove('languages')

        for fname in fnames:
            if not fname.endswith('.lua'):
                continue

            # Lua file that needs checking found. Process it.
            fpath = os.path.join(path, fname)
            lua_idx = path.find('Lua')
            if lua_idx > 0:
                report_path = fpath[lua_idx:]
            else:
                report_path = fpath # Shouldn't happen, but safe fallback.

            err_lines, err_count = process_file(fpath, report_path)

            if err_count == 0:
                continue

            total_file_count = total_file_count + 1
            total_error_count = total_error_count + err_count

            if result_lines:
                # Previous file reported, insert a separator.
                result_lines.append('')
                result_lines.append('======================================')
                result_lines.append('')
            result_lines.extend(err_lines)


    # Add final line with grand totals.
    if result_lines:
        result_lines.append('')
    result_lines.append(f'Checked {plural_count(total_file_count, "Lua file")}, '
                        f'found {plural_count(total_error_count, "error")}.')

    if total_error_count == 0:
        sys.exit(0)

    # Errors found, write the output text.
    for line in result_lines:
        print(line)

    sys.exit(1)

if __name__ == '__main__':
    main()
