#!/usr/bin/python

import fileinput
import os
import re
import sys

#This regex can't find all class declaration mistakes and only checks the first few lines:
#Regex: ^class "(.+)".*\n\n(?!---@type \1\nlocal \1 = _G\["\1"])
regex = r"^class \"(.+)\".*\n\n(?!---@type \1\nlocal \1 = _G\[\"\1\"])"

print_root_regex = re.compile("Lua.*")
script_dir = os.getcwd() + "/../CorsixTH/Lua"
ignored = os.listdir(script_dir + "/languages")
problem_found = False
for root, _, files in os.walk(script_dir):
  for script in files:
    if script.endswith(".lua") and script not in ignored:
      script_string = open(root + "/" + script, 'r').read()
      for found_class in re.findall(regex, script_string, re.MULTILINE):
        if not problem_found:
          print("******* CHECK CLASS DECLARATIONS *******")
          problem_found = True
          print("Invalid/Improper Class Declarations Found:")
        print("*" + print_root_regex.search(root).group(0) + "\\" + script + ":" + found_class)

if problem_found:
  print("\nReason: The class declaration(s) didn't begin as follows:")
  print("")
  print("class \"Name\" / class \"Name\" (Parent)")
  print("")
  print("---@type Name")
  print("local Name = _G[\"Name\"]")
  print("-----------------------------------------\n")
  sys.exit(1)

sys.exit(0)
