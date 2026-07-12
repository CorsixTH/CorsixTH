# Windows ARM64 Contribution Notes

## Scope
This branch adds first-class Windows ARM64 configure/build/test support and points ffmpeg resolution at the registry repo revision carrying the ARM64 Windows port updates.

## Changes in this branch

### 1) ARM64 preset and CI wiring
- Added `win-arm64-rel` configure/build/test presets in `CMakePresets.json`.
- Added `win-arm64-rel` workflow_dispatch preset option in `.github/workflows/Windows.yml`.
- Added `_arm64` artifact suffix for ARM64 workflow builds.
- Fixed Windows workflow `if:` conditions to use `env.PRESET` for install/list/upload steps.

### 2) FFmpeg ARM64 registry wiring
- Updated `vcpkg-configuration.json` to resolve `ffmpeg` and `ffmpeg-bin2c` from the registry repo revision containing the ARM64 Windows ffmpeg port updates.
- The registry ffmpeg port keeps ARM64 asm disabled on Windows (`--disable-asm --disable-x86asm`) to avoid the long configure/build stall observed during investigation.

## Why move the FFmpeg port to the registry?
The original experiment edited a local cache file under `%LOCALAPPDATA%\vcpkg\registries\git-trees\...`, which is not tracked by git and cannot be reviewed or merged. The port now lives in the vcpkg registry repository where packaging changes belong, while this repository only references that registry revision.

## Validation summary

### Configure/build/test
- `cmake --preset win-arm64-rel -DVCPKG_INSTALL_OPTIONS="--x-abi-tools-use-exact-versions"` completed.
- `cmake --build --preset win-arm64-rel` completed.
- `ctest --preset win-arm64-rel --output-on-failure` passed (7/7 tests).

### Runtime
- `UnitTests.exe` passed all test cases.
- `CorsixTH.exe` launches on ARM64 when passed interpreter path:
  - `--interpreter=<repo>/CorsixTH/CorsixTH.lua`

## Launch command used for ARM64 runtime check
From `build/win-arm64-rel`:

```powershell
$env:Path = (Resolve-Path .\vcpkg_installed\arm64-windows\bin).Path + ";" + $env:Path
.\CorsixTH\RelWithDebInfo\CorsixTH.exe --interpreter=C:\Users\v-allens\Repo\ThemePark\CorsixTH\CorsixTH.lua
```

## Suggested feature request

### Title
Add first-class Windows ARM64 build and CI preset support

### Description
Windows ARM64 users can build CorsixTH locally, but ARM64 support is not currently a first-class documented target in project presets and CI workflow options. This request proposes adding and maintaining official Windows ARM64 preset and CI coverage.

Proposed scope:
- Add `win-arm64-rel` configure/build/test presets.
- Add `win-arm64-rel` option to the Windows workflow dispatch input.
- Ensure artifact naming clearly identifies ARM64 output.
- Ensure workflow condition checks evaluate correctly for selected preset.

Acceptance criteria:
- Configure/build/test all succeed on Windows ARM64 host.
- Windows workflow can be manually dispatched with `win-arm64-rel`.
- Artifact naming includes ARM64 identifier.

## Suggested PR template content

`Fixes #<issue-number>`

Describe what changed:
- Added Windows ARM64 CMake presets (`win-arm64-rel`) for configure/build/test.
- Updated Windows workflow to accept ARM64 preset and name ARM64 artifacts distinctly.
- Corrected workflow preset condition checks to use `env.PRESET`.
- Updated vcpkg registry configuration so ARM64 Windows ffmpeg behavior is reproducible through the registry revision that carries the ffmpeg port changes.

## Suggested PR labels
- `PR:DevTools/Repo`
- Optional status in title: `[WIP]` until final review
