# Plan

Roadmap for the first CorsixTH contribution. Checked items are done, unchecked
items are next.

## Setup

- [x] create the fork `BrunosGits/CorsixTH`
- [x] build the dev environment on the VPS (SDL3 + SDL3_mixer in `/opt/SDL3`)
- [x] compile CorsixTH from master with CMake and Ninja
- [x] run the Lua unit tests (busted), lint (luacheck) and syntax checks
- [x] copy the Theme Hospital demo data to the VPS
- [x] boot the dev build headless with the demo data
- [x] scaffold the `devlog/` docs and push them to the fork
- [x] pick the first issue: #1793, broken Lua docs links on GitHub Pages

## First contribution (issue #1793)

- [ ] read `LDocGen` and understand how the docs pages and links are generated
- [ ] reproduce the broken links locally by building the docs
- [ ] write the fix in `LDocGen`, following the project conventions
- [ ] run the unit tests, lint and a fresh build on the VPS
- [ ] open a pull request from a branch cut off `upstream/master`
- [ ] respond to maintainer review

## Issue queue

Chosen order: #1793 first, then #1467 and #2469. #1738 stays in the backlog.

- #1793 — Lua docs links broken on GitHub Pages
- #1467 — entities table modified inside an `ipairs` loop over entities
- #2469 — right mouse panning causes object placement glitches
- #1738 — handymen do not water plants in the middle of benches (backlog)

## Skills to build along the way

- reading Lua game logic and the Lua/C++ boundary
- writing Lua unit tests in the busted style used by CorsixTH
- running a CI-like loop on a headless server
- contributing to a real open source project with a review process
