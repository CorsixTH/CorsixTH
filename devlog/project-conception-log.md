# Project Conception Log

Timeline of decisions behind the CorsixTH contribution effort. Every idea
considered, chosen or rejected, and why. This complements the private session
log (what was done, kept local) and `journal.md` (how it felt). Updated whenever
a decision is made.

---

## 2026-08-11 - Setup day

**Decision: the first open source contribution is a bugfix PR to CorsixTH.**
- Why: the game logic is mostly Lua with a C++ engine, the project keeps an
  open Good First Issue list, and the game data requirement is satisfiable with
  the free, legal Theme Hospital demo, so no game purchase is needed
- Chosen: the official demo at `https://th.corsix.org/Demo.zip`, hosted by the
  CorsixTH project itself
- Status: demo copied to the VPS, dev build boots headless against it

**Decision: the project lives inside the fork, not in a separate repo.**
- Considered: a dedicated ai-lab-style repo plus the fork, as two repos
- Chosen: a single `BrunosGits/CorsixTH` fork with a `devlog/` folder holding
  the journal, decision log, plan, achievements and time tracker
- Why: the fork is the project, and keeping the story next to the code avoids a
  second repo to maintain
- Consequence: PR branches are always cut from `upstream/master` so the devlog
  folder never leaks into a pull request
- Status: applied

**Decision: all development work happens on the VPS.**
- Chosen: the VPS is the workspace, driven over SSH from the computer
- Rejected: the computer stays clean, no CorsixTH install, no demo copy, no
  source clone
- Why: one environment to reproduce bugs, matching the CI box as closely as the
  distro allows
- Status: the previous computer install and demo were deleted

**Decision: build SDL3 from source into a private prefix.**
- Chosen: SDL3 3.4.14 and SDL3_mixer 3.2.4 built into `/opt/SDL3`, with the
  CorsixTH build pointed at that prefix
- Why: CorsixTH master requires SDL3, and Debian 13 ships SDL3 3.2.10, which is
  too old for the SDL_mixer 3.x releases the project fetches. The fetched mixer
  tags fail to compile against the distro SDL3
- Rejected: installing a newer SDL3 system wide, which would shadow the distro
  package and risk breaking other software
- Status: applied, the game builds and runs

**Decision: unit tests follow the project CI recipe.**
- Chosen: Lua 5.1 for syntax checks (`luac5.1 -p`), luacheck, and busted for the
  Luatest suite, installed exactly like the CorsixTH GitHub workflow does
- Status: 63/63 busted tests green, luacheck clean, syntax valid

**Decision: private and agent files stay off git.**
- Chosen: `time-tracker.json` and `session-log.md` stay local like the AI Lab
  project, and the agent instructions (`AGENTS.md`, `opencode.json`,
  `.opencode/`) are gitignored so none of it is ever public
- Status: applied, all of them added to the fork's `.gitignore`

---

## Standing decisions (apply always)

- **VPS-only**: the computer never runs the game or holds a clone. Everything
  terminal happens over SSH.
- **Privacy**: never commit `time-tracker.json`, `session-log.md`, or the agent
  config. Never write emails or server addresses in docs or commits. If one
  leaks in, scrub it from history and force-push.
- **PR hygiene**: code changes branch from `upstream/master` only. The `devlog/`
  folder never appears in a pull request.
- **Writing rules**: no semicolons, no em or en dashes, first person and human
  in the journal, no invented facts.
- **Demo is the legal free demo**: the Theme Hospital demo from the CorsixTH
  site is the data source. No pirated game data, ever.
