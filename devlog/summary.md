# Summary

The master plan for the CorsixTH contribution effort: context, roadmap, status
and tooling in one place. The short tick-box version is `plan.md`, the daily
record is `journal.md`, and every decision with its reasoning is in
`project-conception-log.md`.

## Context

CorsixTH is the open source reimplementation of the 1997 Bullfrog game Theme
Hospital. The game logic is mostly Lua running on a C++ engine. This fork exists
to make a first real contribution to that project, driven entirely from a VPS.

All development happens on the VPS: the fork, the build, the tests and the legal
Theme Hospital demo data. The computer is only an SSH terminal and never runs
the game.

## Roadmap

| Phase | Status |
|---|---|
| Setup: fork, VPS build environment, demo data, tests | done |
| First contribution: root-cause and fix issue #1793 | in progress |
| Second contribution: #1467 | pending |
| Third contribution: #2469 | pending |
| Backlog: #1738 | pending |

## Current status

Setup is complete. The dev build boots headless with the demo data and the test
suite is green. The first issue is chosen: #1793, broken Lua documentation links
on GitHub Pages. The next step is to root-cause it in LDocGen, fix it, and open
a pull request.

## Issue queue

Chosen order: #1793, #1467, #2469. #1738 stays in the backlog.

| Issue | What it is | Status |
|---|---|---|
| #1793 | Lua docs links broken on GitHub Pages. The generated links point to pages that 404, with extra `lua` segments in the names, for example `_0_1_lua_1announcer.lua.html`. Maintainers point at `LDocGen/templates/lua_file_tree.htlua` line 2 and `LDocGen/lua_code_model.lua` line 73 as likely culprits, and note the file pages are not generated at all while the class pages are | first fix |
| #1467 | Entities table is modified inside an `ipairs` loop over entities, which can skip some tick calls | next |
| #2469 | Right mouse panning causes object jitter and an unintentional rotation on mouse up | next |
| #1738 | Handymen do not water plants placed in the middle of benches | backlog |

## Tooling

- Build: CMake with the Ninja generator, release config, pointed at `/opt/SDL3`
  for SDL3 and SDL3_mixer built from source (Debian 13 ships SDL3 3.2.10, too
  old for the SDL_mixer 3.x the project fetches)
- Run: `build/CorsixTH/run-corsixth-dev.sh`, headless with
  `SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy` and
  `LD_LIBRARY_PATH=/opt/SDL3/lib`
- Data: legal Theme Hospital demo at `~/ThemeHospitalDemo/demo/HOSP`, pointed to
  from `~/.config/CorsixTH/config.txt`
- Tests: busted on `CorsixTH/Luatest`, luacheck, and a Lua 5.1 syntax check,
  matching the project CI recipe

## Skills to build

- reading Lua game logic and the Lua/C++ boundary
- writing Lua unit tests in the busted style used by CorsixTH
- running a CI-like loop on a headless server
- contributing to a real open source project with a review process
