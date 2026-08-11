# Journal

Personal diary of the CorsixTH contribution effort: memories, feelings, stories.
One entry per day, appended. This is not the session log (that's the private
session log, kept local, for times/commands/verdicts).

<p align="right"><b>Total time on the project: 0h 00m</b></p>

---

## 2026-08-11: A working dev box for a first PR

**Mood:** focused, and quietly pleased when the game finally booted headless

**Story:** The plan was simple at first: install CorsixTH on the computer,
download the free demo, and start poking at bugs. Then I decided the real work
should happen on the VPS instead, with the computer reduced to an SSH terminal.
So the project became a fork of CorsixTH with a devlog folder inside it, mirroring
the AI Lab setup. The VPS needed the whole build chain, which turned out to be a
small saga: current CorsixTH master moved to SDL3, and Debian 13 ships an SDL3
that is too old for the SDL_mixer version the project fetches. After two failed
attempts with the pinned mixer tags I built SDL3 3.4.14 and SDL3_mixer 3.2.4 from
source into /opt/SDL3, and the game compiled cleanly. Then the unit tests, 63
green, luacheck clean, every Lua file passing the 5.1 syntax check. The last step
was pointing the dev build at the demo data and running it with SDL's dummy video
driver, and there it was, the welcome screen printed to a terminal with no display
at all.

**What I learned:** A game from 1997 with a modern engine is still just software,
and the debug loop works headless once you stop trying to open a window. Version
mismatches between a library a project fetches and the one the distro ships are
normal, and building the newer one into a private prefix is a clean way out that
does not touch the system packages.

**Feelings / notes:** The moment the game said it was using the demo data files,
over SSH, on a machine with no screen, felt like a small victory. The MIDI music
still will not load because there is no synth on the box, but that is a cosmetic
gap, not a blocker.

**Did:** created the fork, built SDL3 and SDL3_mixer from source into /opt/SDL3,
compiled CorsixTH dev264 with CMake and Ninja, ran the Lua unit tests and lint,
copied the demo to the VPS, and confirmed the dev build boots headless with the
demo data.
