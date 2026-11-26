#!/usr/bin/env python3
'''
Script to check correct form of class definitions, both for Lua and LuaLS.

Lua requires

    class "Foo" (Bar)

LuaLS requires

    ---@class Foo: Bar
    (other '---' or empty lines)
    ---@operator call: Foo
    local Foo = _G["Foo"] ---@type Foo

with LuaLS below Lua in the same file due to using '_G["Foo"]' which
retrieves the global Foo class created by 'class "Foo"'.
'''
import os
from collections import defaultdict
from dataclasses import dataclass
from enum import Enum
import re
from typing import Optional

# {{{ def get_lua_files(lua_root):
def get_lua_files(lua_root):
    '''
    Get the paths of the *.lua files (except for the *.d.lua files).

    @param lua_root: Root of the tree to search for Lua files.
    @return File paths of all found Lua files.
    '''
    lua_files = []
    for path, dirs, fnames in os.walk(lua_root):
        # Avoid processing the 'languages' directory in a next iteration.
        if 'languages' in dirs:
            dirs.remove('languages')

        for fname in fnames:
            # Skip *.d.lua and anything not *.lua
            if not fname.endswith('.lua') or fname.endswith('.d.lua'):
                continue

            fpath = os.path.join(path, fname)
            lua_files.append(fpath)

    return lua_files
# }}}
# {{{ def read_file(fpath):
def read_file(fpath):
    '''
    Read the lines of the indicated file.
    '''
    with open(fpath, encoding='utf-8') as handle:
        lines = []
        for line in handle:
            lines.append(line.rstrip())

        return lines
# }}}

class ClassType(Enum):
    '''Type of class definition context.'''

    RUNTIME = "runtime"
    '''For code executed at runtime.'''

    EDITOR = "editor"
    '''For the LuaLS editor.'''

@dataclass
class ClassDef:
    '''
    Storage for a class definition used while playing a game.
    '''
    class_name: str
    parent_name: Optional[str]
    line_num: int
    usage: ClassType


@dataclass
class Report:
    message: str
    line_num: Optional[int] # 1-based.

class FileOverview:
    def __init__(self, fpath):
        self.fpath = fpath
        self.classes: list[ClassDef] = []
        self.reports: list[Report] = []

    def dump(self):
        print("---------------------")
        print(f"{self.fpath}")
        print(f"{self.classes}")
        print(f"{self.reports}")

def _collect_runtime_classes(lines, overview: FileOverview):
    '''
    Find Lua runtime class definitions, and check and store each of them.
    '''
    cldef_pat = re.compile(' *class +"([A-Za-z0-9]+)"( *[(]([A-Za-z0-9]+)[)])?( .*)?')

    for i, line in enumerate(lines):
        m = cldef_pat.fullmatch(line)
        if m:
            class_name = m.group(1)
            parent_name = m.group(3)
            overview.classes.append(
                        ClassDef(class_name, parent_name, i + 1, ClassType.RUNTIME))

# {{{ def _collect_editor_classes(lines, overview: FileOverview):
def _collect_editor_classes(lines, overview: FileOverview):
    '''
    Find class definitions for the LuaLS editor, and check and store each.
    '''
    cldef_pat = re.compile('--- *@class ([A-Z][A-Za-z0-9_]+)(: +([A-Z][A-Za-z0-9_]+))?')
    operator_pat = re.compile('--- *@operator +call *: +([A-Z][A-Za-z0-9_]+)')
    local_pat = re.compile('local +([A-Z][A-Za-z0-9_]+) *= *'
                    '_G\\["([A-Z][A-Za-z0-9_]+)"\\] +--- *@type +([A-Z][A-Za-z0-9_]+)')

    def compare_cl_names(ref_name, ref_lnum, cl_name, cl_num, overview):
        '''
        Compare the reference class name against the other class name. If they
        don't match, report an error in the overview.
        '''
        if ref_name == cl_name:
            return

        mesg = (f"Class name '{cl_name}' does not match with the name "
                f"of the '{ref_name}' class defined at line {ref_lnum}")
        overview.reports.append(Report(mesg, cl_num))

    # Main code of the function.
    cur_line = 0
    while cur_line < len(lines):
        line = lines[cur_line]
        m = cldef_pat.fullmatch(line)
        if not m:
            cur_line = cur_line + 1
            continue

        class_lnum = cur_line + 1
        class_name = m.group(1)
        parent_name = m.group(3)
        editor_cldef = ClassDef(class_name, parent_name, class_lnum, ClassType.EDITOR)
        overview.classes.append(editor_cldef)

        while True:
            cur_line = cur_line + 1
            if cur_line >= len(lines):
                break

            line = lines[cur_line]
            if not line:
                continue # Empty line, check the next line.
            if not line.lstrip().startswith('---'):
                # Neither a LuaLS doc comment nor an empty line. Some lines
                # are missing. Report them.
                text1 = f'---@operator call: {class_name}'
                text2 = f'local {class_name} = _G[\"{class_name}\"] ---@type {class_name}'
                for text in (text1, text2):
                    mesg = (f"Missing the line '{text}' for the class "
                                        f"definition at line {class_lnum}")
                    report = Report(mesg, cur_line + 1)
                    overview.reports.append(report)

                # Find the next runtime class definition.
                break # Line increment is done at the top of the loop.

            # Check the operator line.
            m = operator_pat.fullmatch(line)
            if not m:
                continue # Some other '---' line. Check the next line.
            else:
                compare_cl_names(class_name, class_lnum,
                                    m.group(1), cur_line + 1, overview)

            # Check the local line.
            cur_line = cur_line + 1
            if cur_line >= len(lines):
                m = False
            else:
                line = lines[cur_line]
                m = local_pat.fullmatch(line)

            if not m:
                text = f'local {class_name} = _G[\"{class_name}\"] ---@type {class_name}'
                mesg = f"Missing the line '{text}' that should be below the operator line"
                report = Report(mesg, cur_line + 1)
                overview.reports.append(report)

            else:
                # Compare class names and report differences. Avoid creating
                # duplicate error messages.
                local_name = m.group(1)
                compare_cl_names(class_name, class_lnum,
                                        local_name, cur_line + 1, overview)

                g_name = m.group(2)
                if g_name != local_name:
                    compare_cl_names(class_name, class_lnum,
                                        g_name, cur_line + 1, overview)

                type_name = m.group(3)
                if type_name not in (local_name, g_name):
                    compare_cl_names(class_name, class_lnum,
                                        type_name, cur_line + 1, overview)

            break # Line increment is done at the top of the loop.
# }}}

def analyze_classes(overviews: list[FileOverview]):
    # Build a global map of classname to a set of overviews that define it.
    class_to_files: dict[str, set[FileOverview]] = defaultdict(set)
    for ov in overviews:
        for cl in ov.classes:
            class_to_files[cl.class_name].add(ov)

    # Each class should be define in one file.
    for cl_name, ov_set in class_to_files.items():
        if len(ov_set) > 1:
            fpath_text = ", ".join(sorted(ov.fpath) for ov in ov_set)
            for ov in ov_set:
                ov.reports.append(Report(f"Class '{cl_name}' is duplicated across filed ({{{fpath_text}}})", None))

    def report_def_count(defs, def_text, lnum_single_other, where, reports):
        count = len(defs)
        if count > 1:
            text = f"Expected 1 but found {count} '{def_text}' class definitions"
            for d in defs:
                reports.append(Report(text, d.line_num))
        elif count == 0:
            if lnum_single_other is not None:
                text = f"Missing class definition '{def_text}' {where} line {lnum_single_other}"
            else:
                text = f"Missing class definition '{def_text}'"
            reports.append(Report(text, None))

    for ov in overviews:
        # Process each file separately.
        defs_by_name = defaultdict(list)
        for cl in ov.classes:
            defs_by_name[cl.class_name].append(cl)

        # Verify that the file defines a class once for Lua runtime and once for the LuaLS editor.
        for cl_name, defs in defs_by_name.items():
            runtime_defs = [d for d in defs if d.usage == ClassType.RUNTIME]
            editor_defs = [d for d in defs if d.usage == ClassType.EDITOR]

            # Report about runtime definitions.
            def_text = f'class \"{cl_name}\" ...'
            lnum_single_other = editor_defs[0].line_num if len(editor_defs) == 1 else None
            report_def_count(runtime_defs, def_text, lnum_single_other, "above", ov.reports)

            # Report about editor definitions.
            def_text = f'---@class {cl_name} ...'
            lnum_single_other = runtime_defs[0].line_num if len(runtime_defs) == 1 else None
            report_def_count(editor_defs, def_text, lnum_single_other, "below", ov.reports)


            if len(runtime_defs) == 1 and len(editor_defs) == 1:
                # Verify consistency between parent classes.
                parents = [d.parent_name for d in defs]
                if parents[0] != parents[1]:
                    line_nums = ' and '.join(str(ln) for ln in sorted(d.line_num for d in defs))
                    text = (f"Parent class of class '{cl_name}' is not consistent "
                            f"between the classes at lines {line_nums}")
                    ov.reports.append(Report(text, None))

                # Verify existence of the parent class.
                for d in defs:
                    if d.parent_name and not d.parent_name in class_to_files:
                        text = f"Parent class {d.parent_name} is not defined"
                        ov.reports.append(Report(text, d.line_num))


def format_reports(files: list[FileOverview]) -> str:
    '''
    Format all reports from a list of FileOverview objects.
    Output is grouped by file, sorted by fpath, with line numbers and messages.
    '''
    lines = []
    total_reports = 0

    def sort_func(report) -> int:
        return report.line_num if report.line_num is not None else -1

    # Sort files by fpath for deterministic, user-friendly ordering
    for ov in sorted(files, key=lambda f: f.fpath):
        if not ov.reports:
            continue

        total_reports += len(ov.reports)

        lines.append(f"\n{'─' * 60}")
        lines.append(f"Path: {ov.fpath}")
        lines.append("")
        #lines.append(f"{'─' * 60}")

        for r in sorted(ov.reports, key=sort_func):
            line_str = f"line {r.line_num}" if r.line_num is not None else "unknown line"
            lines.append(f"  Error at {line_str}: {r.message}")

    if total_reports == 0:
        return ["No issues found in class definitions!"]

    return ([
        '=' * 60,
        f"Found {total_reports} issue{'s' if total_reports > 1 else ''}:"]
            + lines + ['=' * 60])



def create_file_overview(fpath):
    '''
    Collect basic information for the file overview. In particular, find runtime
    and editor class definitions.
    '''
    lines = read_file(fpath)
    overview = FileOverview(fpath)
    _collect_runtime_classes(lines, overview)
    _collect_editor_classes(lines, overview)
    return overview

def main():
    lua_root = os.path.join(os.path.dirname(__file__), "..", "CorsixTH", "Lua")
    fpaths = get_lua_files(lua_root)

    # Find and check individual class definitions for all Lua files.
    overviews: list[FileOverview] = [] # Found results for each file.
    for fpath in fpaths:
        overviews.append(create_file_overview(fpath))

    analyze_classes(overviews)
    report_lines = format_reports(overviews)

    for line in report_lines:
        print(line)

if __name__ == '__main__':
    main()
