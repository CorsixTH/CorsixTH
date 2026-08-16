# Journal

Personal diary of the CorsixTH contribution effort: memories, feelings, stories.
One entry per day, newest on top. This is not the session log (that is the private
session log, kept local, for times/commands/verdicts).

<p align="right"><b>Total time on the project: 8h 03m</b></p>

---

## 2026-08-16: The fix that held, and the movie that blocked the test

**Mood:** quiet satisfaction, with a side of of course it was the intro movie

**Story:** The deferred-destruction fix for #1467 was solid, negative control failed exactly as expected when the guard was disabled, but the full-game smoke test timed out at 500s with zero output. Pipe buffering hid all progress. The real culprit: full game data autoplays the intro movie (moviePlayer.playing=true), which blocks World:onTick entirely. A one-line TheApp.moviePlayer:stop() in the smoketest unblocked everything.

Full matrix: offscreen (3/3), xvfb (3/3), demo control (2/2) all green. luacheck clean (297 files). 86/86 unit tests pass. The fix is complete and validated on full game data.

**What I learned:** A timeout with no output is usually pipe buffering, not a hang. Add heartbeats. And always check whether the game is actually running its tick loop, intro movies, paused states, and menu loops will silently skip it.

**Feelings:** The negative control failing on cue (dummy C was skipped) is still the best confirmation a fix works.

**Did:** validated the #1467 deferred-destruction fix on full game data (offscreen, xvfb, demo), fixed smoketest intro-movie blocker, added JSONL heartbeat telemetry, full matrix pass, luacheck + 86 unit tests green, negative control confirmed.

---

## 2026-08-12: Squeezing the entity-loop bug until it squeaked

**Mood:** first fix merged, then surprised by the old-savegame crash

**Story:** The biggest news came first: the maintainers merged my docs fix, closing #1793. Issue #1467: world.entities is walked with ipairs while some handlers destroy other entities, shifting the table and skipping whoever lands in the visited slot. The fix defers removal to after the loop.

A headless smoke test reproduced the skip deterministically (three dummies, the middle destroying the first mid-tick; the test fails if the third gets skipped), and a GUI variant rendered every frame. I hacked the fix back out and both failed with exactly the message they should catch.

Two hidden holes surfaced. An old savegame crashed on the first tick because the deserialiser never re-runs constructors, leaving the new queue missing. And the end-of-day loop never set the iterating marker for plants. Both fixed, both tested.

The day ended with a move to the full game data for reliable tests.

**What I learned:** A regression test's job is to fail when the bug comes back; the negative control tells you it can. The tests that catch you are about old savegames and the code path nobody remembers.

**Feelings:** The skip-repro failing on cue is the closest thing a headless server has to a high five.

**Did:** merged the docs fix into CorsixTH (#1793), implemented the deferred-destruction fix (#1467), 86 unit tests green, headless and GUI smoke tests plus a negative control, fixed the old-savegame crash and the plant branch hole, moved to the full game data.

---

## 2026-08-11: A working dev box and a first pull request

**Mood:** focused, quietly pleased when the game first booted headless, and then very pleased when the first issue became a real fix

**Story:** The plan was to do all the real work on the VPS over SSH, so the project became a fork of CorsixTH with a devlog folder inside it. The build chain was a small saga: master moved to SDL3, Debian 13 ships one too old for the mixer, so I built SDL3 3.4.14 and SDL3_mixer 3.2.4 from source into /opt/SDL3. The game compiled clean, 63 unit tests green, luacheck clean, and the welcome screen printed headless using the demo data.

Then came the first issue, #1793: dead links in the generated Lua docs. My first theory, that GitHub Pages was swallowing files, was wrong. The truth was simpler: LDocGen never generated a page per source file, only class pages and index pages, while the file tree links were built from path-based ids pointing at pages that never existed. So I made LDocGen write one page per file, listing the classes and functions there, with directory entries as plain text. Rebuilt the docs and checked every link: 503 pages, 20465 local links, zero broken. I opened the pull request and learned the labels are the maintainers to add.

**What I learned:** A headless dev box turns a docs bug into a checkable claim: rebuild, script over every link, done. A wrong theory is still useful if you test it and drop it.

**Feelings / notes:** The first headless boot felt like a small victory, and opening the first pull request felt like the devlog setup paying for itself. The MIDI music still will not load with no synth on the box, but that is a cosmetic gap. Now it is a waiting game for the maintainers.

**Did:** set up the fork, built SDL3 and SDL3_mixer into /opt/SDL3, compiled the game, ran the Lua tests and lint, confirmed the headless boot, root-caused issue #1793, extended LDocGen to generate per-file pages, verified 20465 links, and opened pull request #3494.
