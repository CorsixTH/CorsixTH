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

## First contribution

- [ ] pick a small open bug from the Good First Issue list
- [ ] read the code that owns the bug and understand the flow
- [ ] reproduce the bug with the demo data on the VPS
- [ ] write a fix, following the project coding conventions
- [ ] run the unit tests, lint and a fresh build on the VPS
- [ ] open a pull request from a branch cut off `upstream/master`
- [ ] respond to maintainer review

## Skills to build along the way

- reading Lua game logic and the Lua/C++ boundary
- writing Lua unit tests in the busted style used by CorsixTH
- running a CI-like loop on a headless server
- contributing to a real open source project with a review process
