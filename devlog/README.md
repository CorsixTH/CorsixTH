# CorsixTH Contribution Devlog

The working notes of a first open source contribution. Target: CorsixTH, the
open source reimplementation of the 1997 Bullfrog game Theme Hospital. The game
logic is mostly Lua on a C++ engine, which makes it a good place to learn both.

This folder lives inside the CorsixTH fork (`BrunosGits/CorsixTH`) so the code
and the story of writing it stay together. It keeps the journal, decision log, plan and a time tracker all in one place.

## Machine split

- **The VPS** is the workspace. It holds the fork, the build, the tests and the
  legal Theme Hospital demo data. Everything that needs a terminal happens here.
- **The computer** only ever SSHes into the VPS. It no longer runs the game,
  the demo or any CorsixTH install.

## What's here

- `journal.md` — personal journal, one entry per day
- `project-conception-log.md` — every decision, chosen or rejected, and why
- `plan.md` — the roadmap for the first contribution
- `scripts/time-tracker/` — the Rust time tracker used for this project

`time-tracker.json` and `session-log.md` are private and stay off git.

## Status

- Setup is done: fork created, VPS build environment working, demo data in
  place, dev build boots headless, unit tests green.
- Next: pick a small open bug, reproduce it, fix it, open a PR.
