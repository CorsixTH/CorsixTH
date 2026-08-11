# CorsixTH Contribution Devlog

The working notes of a first open source contribution. Target: CorsixTH, the
open source reimplementation of the 1997 Bullfrog game Theme Hospital. The game
logic is mostly Lua on a C++ engine, which makes it a good place to learn both.

This folder lives inside the CorsixTH fork (`BrunosGits/CorsixTH`) so the code
and the story of writing it stay together. It mirrors the structure used by the
AI Lab project: journal, decision log, plan, achievements and a time tracker.

## Machine split

- **The VPS** is the workspace. It holds the fork, the build, the tests and the
  legal Theme Hospital demo data. Everything that needs a terminal happens here.
- **The computer** only ever SSHes into the VPS. It no longer runs the game,
  the demo or any CorsixTH install.

## What's here

- `journal.md` — personal journal, one entry per day
- `project-conception-log.md` — every decision, chosen or rejected, and why
- `plan.md` — the roadmap for the first contribution
- `achievements.md` — running record of GitHub achievements earned by this account
- `scripts/time-tracker/` — the Rust time tracker, same tool as the AI Lab project
- `scripts/check-achievements.sh` — checks the GitHub achievements page against the log

`time-tracker.json` and `session-log.md` are private and stay off git. So do the
agent instructions at the repo root (`AGENTS.md`, `opencode.json`, `.opencode/`).

## Status

- Setup is done: fork created, VPS build environment working, demo data in
  place, dev build boots headless, unit tests green.
- Next: pick a small open bug, reproduce it, fix it, open a PR.
