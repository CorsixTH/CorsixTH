# AGENTS.md

This file contains repository-specific instructions for AI coding agents
working on CorsixTH. These instructions apply to the entire repository
unless a more specific `AGENTS.md` exists in a subdirectory.

Read `CONTRIBUTING.md` before making changes.

## Project overview

CorsixTH is a faithful, open-source reimplementation of the 1997 game
Theme Hospital in a modern engine.

Much of the project is written in Lua. C++ is used to handle the I/O
(sound, movies and graphics) and to compute more complex functionality,
such as pathfinding. The project uses CMake for build management, SDL3
and other libraries for platform functionality, and vcpkg for dependency
management.
Before changing unfamiliar code, inspect nearby implementations, existing
tests, repository configuration, and relevant project documentation.

## Architecture and code layout

CorsixTH has two main implementation layers:

- `CorsixTH/Src/` and `CorsixTH/SrcUnshared/` contain the C++ engine
  layer. It uses SDL3 to provide lower-level facilities including
  graphics, animation playback, audio, video, input, and other
  platform-facing functionality. C++ also implements performance-sensitive
  functionality such as pathfinding and exposes engine facilities to Lua.
  SDL3 events are passed to the Lua layer for handling.
- `CorsixTH/Lua/` contains the game-logic layer, which is written in Lua.
  Most gameplay changes should begin by locating the relevant code in this
  directory.

Important Lua entry points and subsystems include:

- `CorsixTH/Lua/app.lua` is the high-level application controller. It
  creates and starts game levels, scenarios, and the map editor, and
  dispatches game ticks and SDL3 events to other Lua code.
- `CorsixTH/Lua/world.lua` manages the game world. It creates hospitals
  and coordinates shared systems including time and date tracking,
  patient spawning, purchasable parcels, disasters, epidemics, and access
  to pathfinding.
- `CorsixTH/Lua/hospital.lua` contains the base `Hospital`
  implementation.
- `CorsixTH/Lua/hospitals/player_hospital.lua` contains
  `PlayerHospital`, which implements the player's hospital.
- `CorsixTH/Lua/hospitals/ai_hospital.lua` contains `AIHospital`, which
  implements computer-controlled hospitals.
- `CorsixTH/Lua/rooms/` contains room definitions.
- `CorsixTH/Lua/entities/` contains entity implementations, including
  patients, staff, objects, and machines.
- `CorsixTH/Lua/humanoid_actions/` contains actions performed by
  humanoid entities. Actions are managed through an action queue, but
  may be suspended, interrupted, or have other actions inserted ahead of
  them.
- `CorsixTH/Lua/dialogs/` contains game-window implementations.
- `CorsixTH/Lua/game_ui.lua` manages the in-game user interface.
- `CorsixTH/Lua/window.lua` defines the widget classes used by user
  interface windows.

This is a navigation guide rather than an exhaustive description. Before
making a change, inspect the relevant files, nearby implementations, and
tests instead of relying on this summary alone.

## Clean-room development

Follow the clean-room development policy described in `CONTRIBUTING.md`.

## Documentation

Much of the development documentation is maintained on the CorsixTH
GitHub wiki. Consult the relevant named wiki pages when needed, including:

- How To Compile
- Coding Conventions
- Code Documentation Style
- Unit Testing

Use documentation that applies to the current checkout. Repository files
such as `CMakeLists.txt`, `CMakePresets.json`, CI configuration, lint
configuration, and existing tests are authoritative for the mechanics of
the checked-out revision.

If wiki access is unavailable, inspect the repository and state which
external documentation could not be consulted. Do not invent missing
project requirements.

If documentation conflicts with the current source tree or configuration,
identify the conflict for human review rather than silently choosing one.

## Working practices

- Keep changes focused on the task requested by the human contributor.
- Do not make unrelated refactors, formatting changes, dependency
  updates, or cleanups.
- Preserve existing behaviour unless the task explicitly requires a
  behavioural change.
- Follow established patterns in adjacent code before introducing a new
  abstraction or convention.
- Prefer the smallest complete change that addresses the task.
- Do not weaken validation, remove tests, or suppress warnings merely to
  make a change pass.
- Do not modify generated files, vendored dependencies, binary assets,
  translations, or packaging metadata unless the task requires it.
- Do not assume that an existing implementation is wrong solely because
  it differs from a more modern or familiar approach.

When requirements are ambiguous, investigate related code,
documentation, tests, issues, and configuration. Ask the human contributor
when a decision would materially affect behaviour, compatibility, scope,
or saved-game state.

## C++ changes

- Use the C++ standard selected by the current project configuration.
- Follow the repository's coding and documentation conventions.
- Follow `.clang-format` and `.clang-tidy`.
- Match the naming, ownership, error-handling, and lifetime patterns used
  by surrounding code.
- Avoid formatting code unrelated to the requested change.
- Add or update C++ tests under `CorsixTH/CppTest/` where appropriate.

Do not change compiler requirements, dependencies, build options, or
platform support unless the task specifically requires it.

## Lua compatibility

CorsixTH Lua source must remain compatible with all of the following:

- Lua 5.1;
- Lua 5.2;
- Lua 5.3;
- Lua 5.4;
- Lua 5.5;
- later Lua versions supported by the project; and
- LuaJIT.

Lua 5.1 and LuaJIT are not recommended as the primary local
development runtimes, but source changes must not unnecessarily break
their compatibility.

Expect differences between supported Lua runtimes: the same code may
behave differently across runtimes, and a function available in one
version may not exist in another.

CorsixTH contains compatibility code which:

- provides selected functionality from newer Lua versions on older
  runtimes; and
- preserves or emulates selected Lua 5.1 functionality on newer runtimes,
  including functionality related to `getfenv` and `setfenv`.

Before adding, replacing, or directly using version-dependent Lua
functionality:

1. Search the current checkout for an existing compatibility helper.
2. Inspect existing uses of the relevant function or behaviour.
3. Check both older and newer Lua semantics.
4. Reuse the existing compatibility layer where possible.
5. Add or update tests for relevant version differences.

Relevant compatibility code may be found in or reached from:

- `CorsixTH/Lua/app.lua`
- `CorsixTH/Lua/utility.lua`
- `CorsixTH/Src/lua.hpp`
- `CorsixTH/CorsixTH.lua`

These paths are starting points, not an exhaustive list. Search the
current checkout for the relevant symbols rather than relying on
historical line numbers.

Follow `.luacheckrc`, the project coding conventions, and the style of
adjacent Lua code. Do not introduce newer Lua syntax unless it is
confirmed to be accepted by every supported runtime.

## Tests

Agents are encouraged to create and improve unit tests.

Tests must follow the structure, conventions, fixtures, and assertion
patterns of the existing test suites:

- C++ tests are under `CorsixTH/CppTest/`.
- Lua tests are under `CorsixTH/Luatest/`.

Before writing a test:

1. Inspect tests for the same subsystem or a similar behaviour.
2. Reuse existing test helpers and fixtures where suitable.
3. Test externally meaningful behaviour rather than implementation
   details where practical.
4. Keep tests deterministic and independent of execution order.
5. Include regression coverage for bug fixes where practical.

Do not:

- rewrite existing tests solely into a preferred style;
- duplicate coverage without a reason;
- make production interfaces public only to simplify a test unless this
  is consistent with existing project practice;
- replace meaningful assertions with less precise assertions;
- delete or disable a failing test merely to obtain a passing result; or
- alter unrelated expectations without explaining why the behaviour
  should change.

When fixing a defect, first consider whether a regression test can
demonstrate the defect. Ensure the test fails for the relevant reason
before the fix and passes afterwards where the available tooling permits
this workflow.

## Building and validation

Consult the How To Compile and Unit Testing wiki pages before selecting
build or test commands. Inspect `CMakePresets.json`, `CMakeLists.txt`, and
the current CI workflows rather than inventing a new build process.

Before finishing a change, where the environment permits:

- build the affected target;
- run the most relevant unit tests;
- run applicable formatting, linting, and static-analysis checks;
- run broader tests when the change affects shared or compatibility code;
  and
- inspect the final diff for accidental or unrelated changes.

For Lua compatibility changes, test with multiple supported Lua families
where the available environment provides them. Do not treat a successful
test under one Lua version as proof of compatibility with every version.

Report:

- the commands that were run;
- whether each command passed or failed;
- relevant warnings or failures; and
- checks that could not be run, together with the reason.

Never state or imply that unperformed validation passed.

## Pull requests

Pull-request submission, review decisions, and communication with reviewers
remain the responsibility of the human contributor. Follow the pull-request
policy described in `CONTRIBUTING.md`.

## Completion summary

When completing a coding task, provide the human contributor with a
concise summary containing:

- what changed;
- why it changed;
- tests and other checks performed;
- checks not performed and why;
- compatibility or behavioural assumptions;
- files or areas that deserve particular human review; and
- any unresolved concerns.

Do not include a proposed response to a pull-request reviewer.
