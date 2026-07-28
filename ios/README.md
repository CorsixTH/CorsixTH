# CorsixTH for iOS (experimental)

This directory contains an experimental native iOS target for CorsixTH. It is
intended for personal sideloading and does not bundle the copyrighted Theme
Hospital data.

## First launch and game data

1. Install the unsigned IPA with AltStore or another personal signing tool.
2. In the iOS Files app, open **On My iPhone > CorsixTH**.
3. Copy or extract the original game into a folder named **Theme Hospital**.
4. The resulting folder must contain `DATA`, `LEVELS` and `QDATA` directly.
5. Launch CorsixTH. The existing game-data discovery code will find
   `Documents/Theme Hospital` automatically.

The GOG game directory works. The Windows `DOSBOX` directory and uninstaller
are not required by CorsixTH but are harmless if present.

## Input

- One-finger touch acts as the primary mouse.
- Bluetooth and USB mice are exposed through SDL's native iOS mouse support.
- The app declares indirect-input support so primary and secondary mouse
  buttons can be delivered by iOS.

## Build

The `iOS.yml` workflow configures CMake with vcpkg's `arm64-ios` triplet,
builds an unsigned device application with Xcode, and packages it as an IPA.
The IPA still needs to be signed by the sideloading tool for the target device.

The first port build intentionally disables FFmpeg movies, update checking and
external MIDI-device access. SDL_mixer and FluidSynth remain enabled for sound
effects, announcements and in-game music.

The FluidSynth overlay carries a narrow iOS packaging fix for the vcpkg
baseline pinned in `ios/vcpkg.json`. It does not change FluidSynth's library
code. Local CMake builds must pass
`-DVCPKG_OVERLAY_PORTS="$PWD/ios/vcpkg-overlays"` and
`-DCORSIXTH_TARGET_IOS=ON`.
