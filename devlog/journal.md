# Journal

Personal diary of the CorsixTH contribution effort: memories, feelings, stories.
One entry per day, newest on top. This is not the session log (that's the private
session log, kept local, for times/commands/verdicts).

<p align="right"><b>Total time on the project: 1h 11m</b></p>

---

## 2026-08-11: A working dev box and a first pull request

**Mood:** focused, quietly pleased when the game finally booted headless, and then very pleased when the first issue turned out to be a real bug with a real fix

**Story:** The plan was simple at first: install CorsixTH on the computer,
download the free demo, and start poking at bugs. Then I decided the real work
should happen on the VPS instead, with the computer reduced to an SSH terminal.
So the project became a fork of CorsixTH with a devlog folder inside it. The VPS needed the whole build chain, which turned out to be a
small saga: current CorsixTH master moved to SDL3, and Debian 13 ships an SDL3
that is too old for the SDL_mixer version the project fetches. After two failed
attempts with the pinned mixer tags I built SDL3 3.4.14 and SDL3_mixer 3.2.4 from
source into /opt/SDL3, and the game compiled cleanly. Then the unit tests, 63
green, luacheck clean, every Lua file passing the 5.1 syntax check. The last step
was pointing the dev build at the demo data and running it with SDL's dummy video
driver, and there it was, the welcome screen printed to a terminal with no display
at all.

Then came the first issue, the Lua docs file hierarchy, and it turned into a real
root-cause hunt. The reported symptom was dead links in the generated docs. My
first theory, that GitHub Pages was quietly swallowing files, was wrong. The truth
was simpler: LDocGen never generated a page per source file at all, only the class
pages and the index pages, while the file tree links were built from path-based
ids. Every link pointed at a page that was never created. So I extended LDocGen to
write one page per file listing the classes and functions declared there, and made
the directory entries in the tree plain text, since no directory pages exist. Then
I rebuilt the docs and checked every generated page: 503 pages, 20465 local links,
zero broken. The unit tests stayed 63 for 63 and luacheck stayed clean. I opened
the pull request, wrote an explanation comment on the issue, and learned the labels
on pull requests are the maintainers' to add, not the contributors'.

**What I learned:** A game from 1997 with a modern engine is still just software,
and the debug loop works headless once you stop trying to open a window. Version
mismatches between a library a project fetches and the one the distro ships are
normal, and building the newer one into a private prefix is a clean way out that
does not touch the system packages. A working dev box turns a documentation bug
into a checkable claim: I could rebuild the docs and run a script over every link
instead of trusting a hunch. And a wrong theory is still useful if you hold it long
enough to test it and drop it.

**Feelings / notes:** The moment the game said it was using the demo data files,
over SSH, on a machine with no screen, felt like a small victory. The MIDI music
still will not load because there is no synth on the box, but that is a cosmetic
gap, not a blocker. Opening the first pull request on the real project felt like
the point where the devlog setup paid for itself. Now it is a waiting game for the
maintainers, and that is fine.

**Did:** created the fork, built SDL3 and SDL3_mixer from source into /opt/SDL3,
compiled CorsixTH dev264 with CMake and Ninja, ran the Lua unit tests and lint,
copied the demo to the VPS, and confirmed the dev build boots headless with the
demo data. Root-caused issue #1793, extended LDocGen to generate one page per
source file, rebuilt the docs and verified 20465 local links with none broken,
opened pull request #3494, and posted an explanation comment on the issue.
