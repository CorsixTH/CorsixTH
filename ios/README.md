# CorsixTH for iOS (experimental)

This directory contains an experimental native iOS target for CorsixTH. It is
intended for personal sideloading and does not bundle the copyrighted Theme
Hospital data.

## First launch and game data

1. Install the unsigned IPA with AltStore or another personal signing tool.
2. Launch CorsixTH once. If the game data is missing, the app creates its
   import folder and shows the required folder layout.
3. In the iOS Files app, open
   **On My iPhone > CorsixTH > Theme Hospital**.
4. Copy or extract the complete contents of the original game folder so that
   `DATA`, `LEVELS`, `QDATA` and `SOUND` are directly inside that folder.
   Copy the other original game folders as well.
5. Close and reopen CorsixTH. The game-data discovery code will find
   `Documents/Theme Hospital` automatically.

The GOG game directory works. The Windows `DOSBOX` directory and uninstaller
are not required by CorsixTH but are harmless if present. If startup fails,
send the `CorsixTH.log` file created in **On My iPhone > CorsixTH**.

## Input

- Tap with one finger for a primary (left) click.
- Hold and move one finger for a primary-button drag.
- Place one finger on the target and briefly tap with a second finger for a
  secondary (right) click.
- Move or pinch with two fingers to pan or zoom the map.
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
